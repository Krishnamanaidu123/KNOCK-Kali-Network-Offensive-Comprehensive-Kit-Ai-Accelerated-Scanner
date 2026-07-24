# 📖 KNOCK – Usage Guide

This guide covers everything you need to know to use **KNOCK** effectively.  
For a full list of features, see [FEATURES.md](FEATURES.md).

---

## 🚀 Basic Syntax


KNOCK [--ai] [options] <target(s)>
Without --ai – KNOCK behaves exactly like nmap (all flags work).

With --ai – KNOCK uses masscan for fast port discovery, then runs nmap on open ports.

## 🧠 AI Mode – The Smart Way
AI mode (--ai) dramatically speeds up scans by first discovering open ports with masscan, then running nmap only on those ports.

bash
sudo KNOCK --ai -sV -O 10.0.2.11
What happens under the hood:
masscan scans the target (default: top 1000 ports) at high speed.

Open ports are cached for 5 minutes.

nmap runs with your options only on open ports.

Results are displayed with KNOCK branding.

Note: AI mode requires sudo because masscan uses raw packets.

## ⚙️ KNOCK‑Specific Options

Option	Description
--ai, --smart	Enable AI mode (masscan + nmap)
--no-cache	Disable caching (forces a fresh masscan)
--masscan-rate N	Set masscan packet rate (default: 5000)
--no-logo	Suppress the ASCII logo


##📌 Common Use Cases

1. Quick port scan with service detection
bash
sudo KNOCK --ai -sV 10.0.2.11
2. Full aggressive scan with OS detection
bash
sudo KNOCK --ai -A -O 10.0.2.11
3. Scan specific ports
bash
sudo KNOCK --ai -p 22,80,443 -sV 10.0.2.11
4. Scan top 100 ports (even faster)
bash
sudo KNOCK --ai --top-ports 100 -sV 10.0.2.11
5. Ping sweep (host discovery)
bash
KNOCK --ai -sn 10.0.0.0/24
6. Scan a whole subnet for open ports (parallel)
bash
sudo KNOCK --ai -sV 10.0.2.0/24 -j 8
7. Save results in JSON format
bash
sudo KNOCK --ai -sV -oJ scan.json 10.0.2.11
8. Use NSE scripts with AI mode
bash
sudo KNOCK --ai -sC --script=http-title,ssh-brute 10.0.2.11
9. Stealth scan with evasion
bash
sudo KNOCK --ai -sS -f --data-length 200 -D 10.0.2.1 10.0.2.11
10. Increase masscan rate for even faster scans
bash
sudo KNOCK --ai --masscan-rate 10000 -sV 10.0.2.11


##🎯 Full nmap Options (All Supported)

Because KNOCK is a wrapper, every nmap flag works. Here are the most common categories:

Category	Common Flags
Scan techniques	-sS, -sT, -sU, -sN, -sF, -sX, -sA, -sW, -sM, -sI, -sO, -b
Host discovery	-sn, -Pn, -PS/PA/PU/PY, -PE/PP/PM, -PO, -n/-R, --dns-servers, --traceroute
Port specification	-p, --top-ports, -F, -r, --exclude-ports
Service/version	-sV, --version-intensity, --version-light, --version-all
Script scan	-sC, --script, --script-args, --script-trace
OS detection	-O, --osscan-limit, --osscan-guess
Evasion	-f, --mtu, -D, -S, -e, -g, --data-length, --badsum
Performance	-T, --min-rate, --max-rate, --scan-delay, --max-retries, --host-timeout
Output	-oN, -oX, -oJ, -oG, -oA, -v, -d, --reason, --open, --resume
Misc	-6, -A, --privileged, --unprivileged, -V


## 🧪 Examples with Output

Example 1: Quick scan
bash
$ sudo KNOCK --ai -sV 10.0.2.11
Output:

text

╔════════════════════════════════════════════════════════════════╗

║                                                             (ASCII logo)                               ║

╚════════════════════════════════════════════════════════════════╝

[SMART] Running masscan for 10.0.2.11...
[SMART] Open ports discovered: 22,80,443
[SMART] Running nmap on 10.0.2.11...
─── Open ports for 10.0.2.11 ─────────────────────────────────────
22     tcp       OPEN       ssh          OpenSSH 8.2p1 Ubuntu 4ubuntu0.5
80     tcp       OPEN       http         Apache httpd 2.4.41
443    tcp       OPEN       https        nginx/1.18.0
────────────────────────────────────────────────────────────────────
Example 2: Ping sweep
bash
$ KNOCK --ai -sn 10.0.2.0/24
Output:

text
[SMART] Ping scan detected – using nmap directly.
Starting KNOCK 7.99 ( https://knock.org ) at ...
KNOCK scan report for 10.0.2.1
Host is up (0.0012s latency).
...


## ❓ Troubleshooting

Problem	Solution
Operation not permitted	Run with sudo (raw packets need root)
masscan: command not found	Install masscan: sudo apt install masscan
KNOCK: command not found	Use full path: /usr/local/bin/KNOCK or add to PATH
Scan is slow	Increase masscan rate with --masscan-rate 10000
No open ports found	Target might be down; try --no-ping or check your network
Cache not working	Use --no-cache to force a fresh scan
📚 More Resources
Full features: FEATURES.md

Installation: README.md

Official nmap documentation: nmap.org/book/man.html

# Happy scanning! 🔍
