## **KNOCK** (Kali Network Offensive Comprehensive Kit) 

is a powerful, AI‑accelerated wrapper around `nmap` that uses `masscan` to **dramatically speed up scans**. It first discovers open ports in seconds, then runs `nmap` **only on those ports** – all while keeping **every single nmap feature** available.

![KNOCK Logo](https://github.com/user-attachments/assets/313a6397-a03c-40a7-8560-3c8ef7139a66)
*Replace this with your actual logo/ASCII art.*

---

## ✨ Features

- **⚡ 10× Faster** – masscan pre‑scan finds open ports in seconds; nmap deep‑scans only those.
- **🧠 AI‑Smart Mode** – auto‑tuning, caching, and adaptive timing for optimal performance.
- **🔧 Full nmap Compatibility** – every nmap flag works (scan types, scripts, OS detection, evasion, output formats, etc.).
- **🎨 Colourful Output** – easy‑to‑read, colour‑coded results (open = green, closed = red, filtered = yellow).
- **💾 Caching** – re‑scan the same target within 5 minutes without repeating masscan.
- **🖥️ Localhost Optimisation** – skips masscan on loopback (faster).
- **🔄 Parallelism** – auto‑uses all CPU cores.
- **🌐 Custom Branding** – output shows `https://knock.org` and `KNOCK scan report`.

---

## 🚀 Installation

### One‑Liner (Linux / macOS)

bash
curl -sSL https://raw.githubusercontent.com/your-username/knock/main/install.sh | bash
Manual
bash
git clone https://github.com/your-username/knock.git
cd knock
sudo cp knock.sh /usr/local/bin/KNOCK
sudo chmod +x /usr/local/bin/KNOCK
Dependencies
nmap (required)

masscan (strongly recommended for AI mode)

Install them on Debian/Ubuntu/Kali:

bash
sudo apt update && sudo apt install nmap masscan -y

## 📖 Usage

Basic Commands
bash
# Standard nmap (all flags work)
KNOCK -sS -sV -O 10.0.2.11

# AI‑accelerated (masscan + nmap)
sudo KNOCK --ai -sV -O 10.0.2.11

# Custom masscan rate (packets per second)
sudo KNOCK --ai --masscan-rate 10000 -A example.com

# Ping sweep (AI auto‑falls back to nmap -sn)
KNOCK --ai -sn 10.0.0.0/24

# Save results in JSON
sudo KNOCK --ai -sV -oJ scan.json 10.0.2.11
KNOCK‑Specific Options
Flag	Description
--ai, --smart	Enable AI‑accelerated mode (masscan + nmap)
--no-cache	Disable result caching (only with --ai)
--masscan-rate N	Set masscan packet rate (default: 5000)
--no-logo	Suppress the ASCII logo
-h, --help	Show help
Note: Scans requiring raw packets (-sS, -sA, -sW, -sM, -sI, -sO, -sY, -sZ, -f, --mtu, -D, -S, -g, --data-length, --badsum) and AI mode must be run with sudo.


## 🧠 How AI Mode Works

masscan performs a SYN scan on the specified ports (or top 1000 by default) at high speed.
Open ports are cached (5 minutes) for fast re‑scans.
nmap runs with your full set of options only on those open ports.
Results are displayed with nmap’s normal output, but branded as KNOCK and with the URL https://knock.org.



## 📊 Comparison to Plain nmap

Feature	nmap	KNOCK (without --ai)	KNOCK (with --ai)
Speed	Normal	Same as nmap	10× faster
All nmap options	✅	✅	✅ (passed to final nmap)
Caching	❌	❌	✅ (5 min)
Localhost optimisation	❌	❌	✅
Masscan integration	❌	❌	✅
Coloured output	Limited	✅	✅
Custom branding	❌	✅	✅


## 🎨 Colour Scheme

Logo border and “KNOCK” – Blue

Subtitles – White

Open ports – Green

Closed ports – Red

Filtered ports – Yellow

Unfiltered ports – Blue

Help headers – Cyan, Yellow, Green, Blue, Red, Magenta

Errors – Red

Warnings – Yellow

Info messages – Cyan, Green


## 🛠️ Examples

Scan a single host with OS detection
bash
sudo KNOCK --ai -sV -O 10.0.2.11
Scan a whole subnet with a ping sweep
bash
KNOCK --ai -sn 10.0.0.0/24
Aggressive scan with custom masscan rate and output to file
bash
sudo KNOCK --ai --masscan-rate 20000 -A -oA aggressive_scan 10.0.2.11
Use nmap scripts with AI mode
bash
sudo KNOCK --ai -sC --script=http-title,ssh-brute 10.0.2.11
Exclude specific ports from scanning
bash
sudo KNOCK --ai -p 1-1000 --exclude-ports 22,80 10.0.2.11

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
Please read CONTRIBUTING.md first.

## 📜 License

This project is licensed under the MIT License – see the LICENSE file for details.

## 🌐 Website

Official website: **Official Website:** [KNOCK Documentation](https://krishnamanaidu123.github.io/KNOCK-site/) | [knock.org](https://knock.org)

## 🙏 Acknowledgements

nmap – the world’s best network scanner.
masscan – ultra‑fast port scanner.
The security community for testing and feedback.

# Happy scanning! 🔍
