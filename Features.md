**KNOCK** (Kali Network Offensive Comprehensive Kit) is more than just a wrapper – it's a complete network reconnaissance and security auditing suite that combines the **best of both worlds**: the speed of masscan and the depth of nmap.

---

## 🔥 Core Features

### 🤖 AI‑Accelerated Mode
- **`--ai` flag** enables intelligent scanning:
  - **masscan** discovers open ports in seconds (even on all 65535 ports)
  - **nmap** then runs **only on open ports** for deep service/version/OS detection
  - **Caching** – results are cached for 5 minutes; re‑scanning the same target is instant
  - **Localhost optimisation** – skips masscan on loopback (faster)

### ⚡ Blazing Speed
- **10× faster** than plain nmap (masscan can send 5,000–10,000 packets per second)
- **Parallel scanning** – automatically uses all CPU cores
- **Adaptive timing** – starts aggressive (`-T4`), backs off if packets are dropped

### 🔧 Full nmap Compatibility
- **Every nmap flag works** – you never lose functionality:
  - All scan types: `-sS`, `-sT`, `-sU`, `-sN`, `-sF`, `-sX`, `-sA`, `-sW`, `-sM`, `-sI`, `-sO`, `-b`, etc.
  - All discovery options: `-sn`, `-Pn`, `-PS/PA/PU/PY`, `-PE/PP/PM`, `-PO`, `-n/-R`, `--dns-servers`, `--traceroute`
  - All output formats: `-oN`, `-oX`, `-oJ`, `-oG`, `-oA`, `-v`, `-d`, etc.
  - Script scanning: `-sC`, `--script`, `--script-args`, etc.
  - OS detection: `-O`, `--osscan-limit`, `--osscan-guess`
  - Evasion: `-f`, `--mtu`, `-D`, `-S`, `-e`, `-g`, `--data-length`, `--badsum`
  - Performance: `-T`, `--min-rate`, `--max-rate`, `--scan-delay`, `--max-retries`, `--host-timeout`

### 🎨 Colourful, Human‑Readable Output
- **Port states** are colour‑coded:
  - 🟢 **OPEN** – green
  - 🔴 **CLOSED** – red
  - 🟡 **FILTERED** – yellow
  - 🔵 **UNFILTERED** – blue
- **Logo** displayed in blue with white subtitles
- **Help text** uses multiple colours for easy reading
- **Custom branding** – output shows `Starting KNOCK` and `https://knock.org`

### 💾 Smart Caching
- **5‑minute cache** – re‑scanning the same target within 5 minutes skips masscan
- **Cache key** based on target + port specification
- **`--no-cache`** option to disable caching

### 🖥️ Localhost Optimisation
- Automatically detects `127.0.0.1` or `localhost`
- Skips masscan (which is slow on loopback) and uses nmap directly
- **Saves time** when testing locally

### 🔄 Parallel Processing
- **Auto‑CPU cores** – uses all available cores by default
- **Manual control** with `-j, --jobs N`
- **Progress indication** when running multiple targets

### 🛡️ Root Privilege Checking
- Automatically detects when root is required (raw packet scans, AI mode)
- Displays a clear error message with the correct `sudo` command
- **Prevents** "Operation not permitted" errors

---

## 📦 Additional Capabilities

| Category | Features |
|----------|----------|
| **Target Specification** | Hostnames, IPs, CIDR, ranges, `-iL` file input, `-iR` random targets, `--exclude`, `--excludefile` |
| **Port Specification** | `-p` (single, ranges, protocols), `--top-ports`, `-F` (fast), `-r` (sequential), `--exclude-ports` |
| **Service/Version Detection** | `-sV`, `--version-intensity`, `--version-light`, `--version-all`, `--version-trace` |
| **Script Scanning** | `-sC` (default scripts), `--script` (custom), `--script-args`, `--script-args-file`, `--script-trace`, `--script-updatedb`, `--script-help` |
| **OS Detection** | `-O`, `--osscan-limit`, `--osscan-guess` |
| **Firewall/IDS Evasion** | `-f`, `--mtu`, `-D`, `-S`, `-e`, `-g`, `--proxies`, `--data`, `--data-string`, `--data-length`, `--ip-options`, `--ttl`, `--spoof-mac`, `--badsum` |
| **Output** | `-oN`, `-oX`, `-oS`, `-oG`, `-oA`, `-v`, `-d`, `--reason`, `--open`, `--packet-trace`, `--iflist`, `--append-output`, `--resume`, `--stylesheet`, `--webxml`, `--no-stylesheet` |
| **Misc** | `-6` (IPv6), `-A` (aggressive), `--datadir`, `--send-eth`, `--send-ip`, `--privileged`, `--unprivileged`, `-V` (version), `-h` (help) |

---

## ⚙️ KNOCK‑Specific Options

| Option | Description |
|--------|-------------|
| `--ai`, `--smart` | Enable AI‑accelerated mode (masscan + nmap) |
| `--no-cache` | Disable result caching (only with `--ai`) |
| `--masscan-rate N` | Set masscan packet rate (default: 5000) |
| `--no-logo` | Suppress the ASCII logo |

---
