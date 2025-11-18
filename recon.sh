#!/bin/bash

# ─────────────────────────────────────────────
# Color-coded echo functions
info()    { echo -e "\e[34m[*] $1\e[0m"; }     # Blue
success() { echo -e "\e[32m[✓] $1\e[0m"; }     # Green
warn()    { echo -e "\e[33m[!] $1\e[0m"; }     # Yellow
error()   { echo -e "\e[31m[✗] $1\e[0m"; }     # Red

# ─────────────────────────────────────────────
# Get target domain
info "Enter the target domain:"
read domain

if [ -z "$domain" ]; then
    error "No domain entered. Exiting."
    exit 1
fi

# ─────────────────────────────────────────────
# Create working directory
info "Creating directory: $domain"
mkdir -p "$HOME/$domain"
success "Directory created at $HOME/$domain"

# ─────────────────────────────────────────────
# WHOIS
info "Running whois..."
whois "$domain" > "$HOME/$domain/report.txt"
success "WHOIS report saved"

# ─────────────────────────────────────────────
# Subfinder
info "Running subfinder..."
subfinder -silent -d "$domain" > "$HOME/$domain/subs.txt"
sub_count=$(wc -l < "$HOME/$domain/subs.txt")
success "Subfinder found $sub_count subdomains"

# ─────────────────────────────────────────────
# Amass
info "Running amass..."
amass enum -d "$domain" -rf "$HOME/resolvers.txt" > "$HOME/$domain/amass.txt"
amass_count=$(wc -l < "$HOME/$domain/amass.txt")
if [ "$amass_count" -eq 0 ]; then
    warn "Amass found no subdomains"
else
    success "Amass found $amass_count subdomains"
fi

# ─────────────────────────────────────────────
# Assetfinder
info "Running assetfinder..."
assetfinder -subs-only "$domain" > "$HOME/$domain/asset.txt"
success "Assetfinder completed"

# ─────────────────────────────────────────────
# Combine all subdomains
info "Combining all subdomains into all_domain.txt"
cat "$HOME/$domain"/subs.txt "$HOME/$domain"/amass.txt "$HOME/$domain"/asset.txt > "$HOME/$domain/all_domain.txt"
success "Combined subdomains saved"

# ─────────────────────────────────────────────
# Httpx
info "Running httpx-toolkit..."
httpx-toolkit -silent -l "$HOME/$domain/all_domain.txt" -o "$HOME/$domain/live.txt"
success "Live subdomains saved"

info "Extracting unique live domains..."
sort -u "$HOME/$domain/live.txt" > "$HOME/$domain/alive.txt"
live_count=$(wc -l < "$HOME/$domain/alive.txt")
success "Extracted $live_count unique live domains"

# ─────────────────────────────────────────────
# Subzy
info "Running subzy for vulnerability detection..."
subzy run --targets "$HOME/$domain/alive.txt" --vuln --hide_fails > "$HOME/$domain/subzy.txt"
success "Subzy scan completed"

# ─────────────────────────────────────────────
# Final message
success "Recon completed successfully for $domain"
