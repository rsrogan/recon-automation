#!/bin/bash

# Certificate Transparency Subdomain Enumerator
# Sources: crt.sh, Certspotter (with API key), CertWatch
# Output: subdomains.txt (default), with optional JSON/CSV/DNS resolution

set -euo pipefail

echo "Enter the domain name:"
read domain

# Output files
TXT_OUT="subdomains.txt"
JSON_OUT="subdomains.json"
CSV_OUT="subdomains.csv"

# --- crt.sh ---
echo "[+] Fetching from crt.sh..."
crtsh=$(curl --retry 3 --max-time 20 -s "https://crt.sh/?q=${domain}&output=json" \
  | jq -r '.[].name_value?' \
  | sed 's/\*\.//g' \
  | sort -u || true)

# --- Certspotter ---
echo "[+] Fetching from Certspotter..."
if [[ -z "${CERTSPOTTER_API_KEY:-}" ]]; then
  echo "[!] CERTSPOTTER_API_KEY not set, skipping Certspotter..."
  certspotter=""
else
  certspotter=$(curl --retry 3 --max-time 20 -s -H "Authorization: Bearer $CERTSPOTTER_API_KEY" \
    "https://api.certspotter.com/v1/issuances?domain=${domain}&include_subdomains=true&expand=dns_names" \
    | jq -r '.[] | select(.dns_names) | .dns_names[]?' \
    | sed 's/\*\.//g' \
    | sort -u || true)
fi

# --- CertWatch ---
echo "[+] Fetching from CertWatch..."
certwatch=$(curl --retry 3 --max-time 20 -s "https://binsec.tools/certwatch/?domain=${domain}" \
  | grep -Eo "[a-zA-Z0-9._-]+\.${domain}" \
  | sort -u || true)

# --- Merge & Deduplicate ---
echo "[+] Merging results..."
echo "$crtsh"$'\n'"$certspotter"$'\n'"$certwatch" | sort -u > "$TXT_OUT"

count=$(wc -l < "$TXT_OUT")
echo "[+] Found $count unique subdomains."
echo "[+] Results saved to $TXT_OUT"

# --- Optional JSON Output ---
jq -Rn --arg domain "$domain" \
  '{domain:$domain, subdomains:[inputs]}' < "$TXT_OUT" > "$JSON_OUT"


# --- Optional CSV Output ---
awk -v domain="$domain" 'BEGIN{print "domain,subdomain"} {print domain","$0}' "$TXT_OUT" > "$CSV_OUT"
echo "[+] CSV output saved to $CSV_OUT"

# --- Optional DNS Resolution ---
echo "[+] Resolving subdomains to IPs..."
while read -r sub; do
  # Skip blank lines
  [[ -z "$sub" ]] && continue

  ip=$(dig +short "$sub" | head -n1)
  if [[ -n "$ip" ]]; then
    echo "$sub -> $ip"
  fi
done < "$TXT_OUT"

