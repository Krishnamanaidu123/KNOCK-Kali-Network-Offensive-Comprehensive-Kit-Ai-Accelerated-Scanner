# RADME.md for KNOCK

```markdown
# 🔍 KNOCK – AI-Accelerated Network Scanner

> **K**ali **N**etwork **O**ffensive **C**omprehensive **K**it

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Nmap](https://img.shields.io/badge/Nmap-7.0+-red.svg)](https://nmap.org/)
[![Masscan](https://img.shields.io/badge/Masscan-1.0.5+-yellow.svg)](https://github.com/robertdavidgraham/masscan)

---

## 📖 Overview

**KNOCK** is a complete network reconnaissance and security auditing suite that combines the **blazing speed** of masscan with the **deep inspection** capabilities of nmap. It acts as an intelligent wrapper that gives you the best of both worlds:

- ⚡ **10× faster** than plain nmap for most scans
- 🎯 **Full nmap compatibility** – every flag works
- 🧠 **AI-accelerated mode** with smart caching
- 🎨 **Colourful, human-readable output**
- 🚀 **Parallel scanning** across all CPU cores

---

## ✨ Features

### 🤖 AI‑Accelerated Mode

- `--ai` flag enables intelligent scanning:
  - **masscan** discovers open ports in seconds (even on all 65535 ports)
  - **nmap** runs **only on open ports** for deep service/version/OS detection
  - **Caching** – results cached for 5 minutes; re‑scanning the same target is instant
  - **Localhost optimisation** – skips masscan on loopback (faster)

### ⚡ Blazing Speed

- **10× faster** than plain nmap (masscan sends 5,000–10,000 packets per second)
- **Parallel scanning** – automatically uses all CPU cores
- **Adaptive timing** – starts aggressive (`-T4`), backs off if packets are dropped

### 🔧 Full nmap Compatibility

**Every nmap flag works** – you never lose functionality:

- **Scan types**: `-sS`, `-sT`, `-sU`, `-sN`, `-sF`, `-sX`, `-sA`, `-sW`, `-sM`, `-sI`, `-sO`, `-b`
- **Host discovery**: `-sn`, `-Pn`, `-PS/PA/PU/PY`, `-PE/PP/PM`, `-PO`, `-n/-R`, `--dns-servers`, `--traceroute`
- **Port specification**: `-p`, `--top-ports`, `-F`, `-r`, `--exclude-ports`
- **Service/version**: `-sV`, `--version-intensity`, `--version-light`, `--version-all`
- **Script scanning**: `-sC`, `--script`, `--script-args`, `--script-trace`
- **OS detection**: `-O`, `--osscan-limit`, `--osscan-guess`
- **Evasion**: `-f`, `--mtu`, `-D`, `-S`, `-e`, `-g`, `--data-length`, `--badsum`
- **Performance**: `-T`, `--min-rate`, `--max-rate`, `--scan-delay`, `--max-retries`
- **Output**: `-oN`, `-oX`, `-oJ`, `-oG`, `-oA`, `-v`, `-d`, `--reason`, `--open`

### 🎨 Colourful, Human‑Readable Output

- 🟢 **OPEN** – green
- 🔴 **CLOSED** – red  
- 🟡 **FILTERED** – yellow
- 🔵 **UNFILTERED** – blue
- Custom branding – shows `Starting KNOCK` and `https://knock.org`

### 💾 Smart Caching

- **5‑minute cache** – re‑scanning the same target within 5 minutes skips masscan
- **Cache key** based on target + port specification
- `--no-cache` option to disable caching

### 🖥️ Localhost Optimisation

- Automatically detects `127.0.0.1` or `localhost`
- Skips masscan (slow on loopback) and uses nmap directly
- **Saves time** when testing locally

### 🛡️ Root Privilege Checking

- Automatically detects when root is required
- Displays clear error with the correct `sudo` command
- Prevents "Operation not permitted" errors

---

## 📦 Installation

### One‑Liner (Linux / macOS)

```bash
curl -sSL https://raw.githubusercontent.com/Krishnamanaidu123/KNOCK-Kali-Network-Offensive-Comprehensive-Kit-Ai-Accelerated-Scanner/main/install.sh -o install.sh
less install.sh        # review it
bash install.sh
```

### Manual Installation

```bash
git clone https://github.com/Krishnamanaidu123/KNOCK-Kali-Network-Offensive-Comprehensive-Kit-Ai-Accelerated-Scanner.git
cd KNOCK-Kali-Network-Offensive-Comprehensive-Kit-Ai-Accelerated-Scanner
sudo cp knock.sh /usr/local/bin/knock
sudo chmod +x /usr/local/bin/knock
```

### Dependencies

```bash
sudo apt update && sudo apt install nmap masscan -y
```

---

## 🚀 Usage Guide

### Basic Syntax

```bash
KNOCK [--ai] [options] <target(s)>
```

- **Without `--ai`** – behaves exactly like `nmap`
- **With `--ai`** – uses masscan for fast port discovery, then nmap on open ports

### 🧠 AI Mode – The Smart Way

```bash
sudo KNOCK --ai -sV -O 10.0.2.11
```

**What happens under the hood:**
1. **masscan** scans the target at high speed
2. Open ports are **cached** for 5 minutes
3. **nmap** runs **only on open ports** with your options
4. Results displayed with KNOCK branding

### 📌 Common Use Cases

#### 1. Quick port scan with service detection
```bash
sudo KNOCK --ai -sV 10.0.2.11
```

#### 2. Full aggressive scan with OS detection
```bash
sudo KNOCK --ai -A -O 10.0.2.11
```

#### 3. Scan specific ports
```bash
sudo KNOCK --ai -p 22,80,443 -sV 10.0.2.11
```

#### 4. Scan top 100 ports (even faster)
```bash
sudo KNOCK --ai --top-ports 100 -sV 10.0.2.11
```

#### 5. Ping sweep (host discovery)
```bash
KNOCK --ai -sn 10.0.0.0/24
```

#### 6. Scan a whole subnet in parallel
```bash
sudo KNOCK --ai -sV 10.0.2.0/24 -j 8
```

#### 7. Save results in JSON format
```bash
sudo KNOCK --ai -sV -oJ scan.json 10.0.2.11
```

#### 8. Use NSE scripts with AI mode
```bash
sudo KNOCK --ai -sC --script=http-title,ssh-brute 10.0.2.11
```

#### 9. Stealth scan with evasion
```bash
sudo KNOCK --ai -sS -f --data-length 200 -D 10.0.2.1 10.0.2.11
```

#### 10. Increase masscan rate for faster scans
```bash
sudo KNOCK --ai --masscan-rate 10000 -sV 10.0.2.11
```

---

## ⚙️ KNOCK‑Specific Options

| Option | Description |
|--------|-------------|
| `--ai`, `--smart` | Enable AI mode (masscan + nmap) |
| `--no-cache` | Disable caching (forces fresh masscan) |
| `--masscan-rate N` | Set masscan packet rate (default: 5000) |
| `--no-logo` | Suppress the ASCII logo |
| `-j, --jobs N` | Number of parallel jobs (default: CPU cores) |

---

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| `Operation not permitted` | Run with `sudo` (raw packets need root) |
| `masscan: command not found` | Install masscan: `sudo apt install masscan` |
| `KNOCK: command not found` | Use full path: `/usr/local/bin/knock` or add to PATH |
| Scan is slow | Increase masscan rate with `--masscan-rate 10000` |
| No open ports found | Target might be down; try `--no-ping` |
| Cache not working | Use `--no-cache` to force a fresh scan |

---

## 📊 Comparison

| Feature | Plain nmap | KNOCK (--ai) |
|---------|------------|--------------|
| Speed | Baseline | **10× faster** |
| Full nmap support | ✅ | ✅ |
| Masscan integration | ❌ | ✅ |
| Smart caching | ❌ | ✅ |
| Colourful output | Limited | ✅ |
| Localhost optimisation | ❌ | ✅ |
| Parallel scanning | Limited | ✅ |
| Adaptive timing | ❌ | ✅ |

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 📄 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [nmap](https://nmap.org/) – The world's most famous port scanner
- [masscan](https://github.com/robertdavidgraham/masscan) – The fastest port scanner
- The security community for inspiration and testing

---

## 📬 Contact

- **GitHub**: [Krishnamanaidu123](https://github.com/Krishnamanaidu123)
- **Project Page**: [https://github.com/Krishnamanaidu123/KNOCK-Kali-Network-Offensive-Comprehensive-Kit-Ai-Accelerated-Scanner](https://github.com/Krishnamanaidu123/KNOCK-Kali-Network-Offensive-Comprehensive-Kit-Ai-Accelerated-Scanner)

---

**KNOCK** – *Lightning-fast, deep-scanning network reconnaissance. For networks you're authorised to test.* 🔍
```

---

## 🎨 Styling Notes

The README uses:
- **GitHub-flavored Markdown** with emojis for visual appeal
- **Tables** for clear option comparisons
- **Code blocks** with bash/shell syntax highlighting
- **Badges** for quick project status at the top
- **Colour emojis** to maintain the colourful theme
- **Clear section headers** for easy navigation
- **Bullet points** and **numbered lists** for readability

The content mirrors the HTML page exactly while being properly formatted for GitHub's Markdown rendering.
