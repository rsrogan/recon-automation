💥 Recon-Automation 💥
Automated Subdomain Discovery Tool for Pentesters
This project provides an automated approach for penetration testers to discover subdomains of a target domain using several popular tools, followed by subdomain validity checking and Whois information retrieval. It streamlines the initial reconnaissance phase of a security assessment.
✨ Features

    🕵️ Automated Subdomain Discovery: Uses subfinder, amass, and assetfinder to find a wide range of subdomains.
    ✅ Subdomain Validation: Employs subzy to check the validity and status of discovered subdomains.
    🌐 Whois Lookup: Automatically performs a Whois query on the main target domain for registration information.
    🗃️ Organized Output: Saves results into clearly named text files for easy review.

🛠️ Prerequisites
Before running this script, you need to ensure that the required tools are installed on your system. This project is intended to be run in a Linux/macOS environment.
Install the necessary command-line tools:

    subfinder
    amass
    assetfinder
    subzy
    whois (usually pre-installed on most Linux distributions; if not, install via your package manager, e.g., sudo apt install whois).

🚀 Recommended Installation Method (Go)
Most of these tools are written in Go. If you have Go installed and configured (ensure your $GOPATH/bin is in your system's $PATH), you can install them using these commands:
________________________________________________________________________________________________________________________________
**crt.sh**

# 🔎 Subdomain Enumeration via Certificate Transparency Logs

This project provides a simple script to **enumerate subdomains** of a target domain by querying **Certificate Transparency (CT) logs** from [crt.sh](https://crt.sh) and [Certspotter](https://certspotter.com).  
It is designed for penetration testers, bug bounty hunters, and security researchers who want to automate reconnaissance.

---

## ✨ Features
- **Automated CT log queries** from crt.sh and Certspotter
- **Deduplication** of results for clean output
- **Flexible integration** into larger recon pipelines
- **Simple CLI usage** with minimal dependencies
- **Output ready** for chaining into tools like `dnsx`, `httpx`, `nuclei`, or `nmap`

---

## ⚙️ Prerequisites
- Python 3.7+
- `requests` library (`pip install requests`)

---

## 🚀 Usage

```bash
python subdomain_enum.py example.com

