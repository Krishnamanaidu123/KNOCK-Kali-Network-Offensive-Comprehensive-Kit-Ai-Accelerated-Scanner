#!/usr/bin/env bash
#
# KNOCK v7.2 - Full nmap-compatible AI Accelerator
# =================================================
# - All nmap options supported.
# - Output filtered to show "KNOCK" instead of "Nmap".
# - URL changed to https://knock.org.
# - Root check included.

set -o pipefail
set -o errtrace

# -------------------------------------------------------------------
# COLOURS
# -------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

VERSION="7.2"
SCRIPT_NAME="$(basename "$0")"

# ---- Global state --------------------------------------------------
SMART_MODE=0
MASSCAN_RATE=5000
SHOW_LOGO=1
CACHE_DIR="/tmp/knock_cache"
mkdir -p "$CACHE_DIR" 2>/dev/null

EXTRA_OPTS=()
TARGETS=()
VERBOSE=0

# -------------------------------------------------------------------
# LOGO
# -------------------------------------------------------------------
show_logo() {
    if [[ $SHOW_LOGO -eq 1 ]]; then
        cat << "LOGO_END"
${BOLD}${BLUE}
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        ██╗  ██╗ ███╗   ██╗  ██████╗   ██████╗ ██╗  ██╗         ║
║        ██║ ██╔╝ ████╗  ██║ ██╔═══██╗ ██╔════╝ ██║ ██╔╝         ║
║        █████╔╝  ██╔██╗ ██║ ██║   ██║ ██║      █████╔╝          ║
║        ██╔═██╗  ██║╚██╗██║ ██║   ██║ ██║      ██╔═██╗          ║
║        ██║  ██╗ ██║ ╚████║ ╚██████╔╝ ╚██████╗ ██║  ██╗         ║
║        ╚═╝  ╚═╝ ╚═╝  ╚═══╝  ╚═════╝   ╚═════╝ ╚═╝  ╚═╝         ║
║                                                                ║
║           Kali Network Offensive Comprehensive Kit             ║
║                    AI‑Accelerated Scanner                      ║
╚════════════════════════════════════════════════════════════════╝
${NC}
LOGO_END
    fi
}

# -------------------------------------------------------------------
# HELP
# -------------------------------------------------------------------
show_help() {
    show_logo
    cat << "HELP_END"
${BOLD}KNOCK v$VERSION – AI‑Accelerated nmap Wrapper${NC}

${BOLD}Usage:${NC} $SCRIPT_NAME [--ai] [nmap options] <target(s)>

If you pass ${BOLD}--ai${NC}, KNOCK will:
  1. Use masscan (or a ping sweep) to discover open ports.
  2. Then run nmap ONLY on those ports, with ALL your extra nmap flags.

If you do ${BOLD}not${NC} use --ai, KNOCK just forwards everything to nmap
(so it behaves exactly like nmap, but with KNOCK branding).

${BOLD}KNOCK‑specific options:${NC}
  --ai, --smart          Enable AI‑accelerated mode (masscan + nmap)
  --no-cache             Disable result caching (only with --ai)
  --masscan-rate N       Set masscan packet rate (default: 5000)
  --no-logo              Suppress logo
  -h, --help             Show this help (or pass -h to nmap)

${BOLD}Root requirements:${NC}
  Scans using raw packets (-sS, -sA, -sW, -sM, -sI, -sO, -sY, -sZ, -f, --mtu, -D, -S, -g, --data-length, --badsum) require root.
  Smart mode (--ai) also requires root because masscan uses raw packets.
  Use ${BOLD}sudo${NC} to run such scans.

${BOLD}Examples:${NC}
  # Plain nmap (all flags work)
  $SCRIPT_NAME -sS -sV -O -p- 10.0.2.11

  # AI‑accelerated (masscan top 1000 ports, then nmap with -sV -O)
  sudo $SCRIPT_NAME --ai -sV -O 10.0.2.11

  # AI with custom masscan rate and extra nmap flags
  sudo $SCRIPT_NAME --ai --masscan-rate 10000 -sC -A 10.0.2.11

  # Ping sweep (AI auto‑falls back to nmap)
  $SCRIPT_NAME --ai -sn 10.0.2.0/24
HELP_END
}

# -------------------------------------------------------------------
# UTILITIES
# -------------------------------------------------------------------
die() {
    echo -e "${RED}[KNOCK] ERROR: $*${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[KNOCK] WARNING: $*${NC}" >&2
}

is_uint() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

sanitize_name() {
    echo "$1" | tr -c 'A-Za-z0-9._-' '_'
}

get_cpu_cores() {
    if command -v nproc &>/dev/null; then
        nproc
    else
        echo 4
    fi
}

check_deps() {
    local missing=()
    for cmd in nmap; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing dependencies: ${missing[*]}. Install with: sudo apt install ${missing[*]}"
    fi

    if [[ $SMART_MODE -eq 1 ]] && ! command -v masscan &>/dev/null; then
        warn "masscan not found; Smart mode falling back to standard nmap."
        SMART_MODE=0
    fi
}

# -------------------------------------------------------------------
# NMAP FILTER (replaces "Nmap" with "KNOCK" and changes URL)
# -------------------------------------------------------------------
run_nmap_filtered() {
    # Usage: run_nmap_filtered nmap [arguments...]
    # Runs nmap, piping output through sed to replace branding and URL.
    "$@" 2>&1 | sed -e 's/^Starting Nmap /Starting KNOCK /' \
                     -e 's/^Nmap scan report /KNOCK scan report /' \
                     -e 's|https://nmap.org|https://knock.org|g'
    return ${PIPESTATUS[0]}
}

# -------------------------------------------------------------------
# CACHE HELPERS
# -------------------------------------------------------------------
cache_key() {
    local target="$1"
    local ports="$2"
    echo "$target|$ports" | md5sum | cut -d' ' -f1
}

cache_get() {
    local key="$1"
    local cache_file="$CACHE_DIR/$key"
    if [[ -f "$cache_file" ]]; then
        local age
        age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
        if [[ $age -lt 300 ]]; then  # 5 minutes
            cat "$cache_file"
            return 0
        fi
    fi
    return 1
}

cache_set() {
    local key="$1"
    local data="$2"
    echo "$data" > "$CACHE_DIR/$key"
}

# -------------------------------------------------------------------
# PARSE AND DISPLAY – PLAIN LIST
# -------------------------------------------------------------------
parse_and_display() {
    local grepfile="$1"
    if [[ ! -f "$grepfile" ]]; then
        echo -e "${YELLOW}[KNOCK] No grepable output found.${NC}"
        return 1
    fi

    local ports_line
    ports_line=$(grep -E "^Host:.*Ports:" "$grepfile" | head -1)
    if [[ -z "$ports_line" ]]; then
        echo -e "${YELLOW}[KNOCK] No port information found.${NC}"
        return
    fi

    local host
    host=$(echo "$ports_line" | sed -n 's/^Host: \([^ ]*\).*/\1/p')

    local ports_data="${ports_line#*Ports: }"
    ports_data="${ports_data%%  *}"   # drop trailing fields
    ports_data="$(echo "$ports_data" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    IFS=',' read -ra port_entries <<< "$ports_data"

    echo -e "${BOLD}${CYAN}─── Open ports${host:+ for $host} ─────────────────────────────────────${NC}"

    local any_printed=0
    for entry in "${port_entries[@]}"; do
        entry="$(echo "$entry" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        entry="${entry%/}"
        [[ -z "$entry" ]] && continue

        local port state proto owner service rpc version
        IFS='/' read -r port state proto owner service rpc version <<< "$entry"
        [[ -z "$port" || -z "$state" ]] && continue

        state_col=$(color_state "$state")
        printf "${BOLD}%-6s${NC} %-8s %-10s %-14s %s\n" \
               "$port" "$proto" "$state_col" "$service" "$version"
        any_printed=1
    done

    if [[ $any_printed -eq 0 ]]; then
        echo -e "${YELLOW}  (no parsable port entries)${NC}"
    fi
    echo -e "${BOLD}${CYAN}────────────────────────────────────────────────────────────────────${NC}"
}

# -------------------------------------------------------------------
# PORT STATE COLOUR
# -------------------------------------------------------------------
color_state() {
    case "$1" in
        open)       echo -e "${GREEN}OPEN${NC}" ;;
        closed)     echo -e "${RED}CLOSED${NC}" ;;
        filtered)   echo -e "${YELLOW}FILTERED${NC}" ;;
        unfiltered) echo -e "${BLUE}UNFILTERED${NC}" ;;
        *)          echo -e "${MAGENTA}$1${NC}" ;;
    esac
}

# -------------------------------------------------------------------
# SMART SCAN (masscan + nmap with user's extra options)
# -------------------------------------------------------------------
run_smart_scan() {
    local target="$1"
    local cache_enabled=1
    if [[ -n "$KNOCK_NO_CACHE" ]]; then
        cache_enabled=0
    fi

    # Detect if this is a ping scan (-sn) – if so, just run nmap directly
    if [[ " ${EXTRA_OPTS[*]} " =~ " -sn " ]]; then
        echo -e "${CYAN}[SMART] Ping scan detected – using nmap directly.${NC}"
        run_nmap_filtered nmap "${EXTRA_OPTS[@]}" "$target"
        return
    fi

    # If target is localhost, use nmap directly (masscan is slow on loopback)
    if [[ "$target" == "127.0.0.1" || "$target" == "localhost" ]]; then
        echo -e "${CYAN}[SMART] Localhost detected – using nmap directly.${NC}"
        run_nmap_filtered nmap "${EXTRA_OPTS[@]}" "$target"
        return
    fi

    local open_ports=""
    local cache_key_str
    cache_key_str=$(cache_key "$target" "${PORTS:-all}")

    if [[ $cache_enabled -eq 1 ]] && cache_get "$cache_key_str" >/dev/null; then
        open_ports=$(cache_get "$cache_key_str")
        echo -e "${CYAN}[SMART] Using cached open ports for $target: $open_ports${NC}"
    else
        # Build masscan command
        local masscan_cmd="masscan --rate=${MASSCAN_RATE}"
        # Determine port spec from EXTRA_OPTS
        local has_port_spec=0
        for opt in "${EXTRA_OPTS[@]}"; do
            if [[ "$opt" == "-p" ]] || [[ "$opt" == "--top-ports" ]]; then
                has_port_spec=1
                break
            fi
        done
        if [[ $has_port_spec -eq 1 ]]; then
            local masscan_port_opts=""
            local i=0
            while [[ $i -lt ${#EXTRA_OPTS[@]} ]]; do
                if [[ "${EXTRA_OPTS[$i]}" == "-p" ]] && [[ $i+1 -lt ${#EXTRA_OPTS[@]} ]]; then
                    masscan_port_opts="-p ${EXTRA_OPTS[$i+1]}"
                    i=$((i+2))
                elif [[ "${EXTRA_OPTS[$i]}" == "--top-ports" ]] && [[ $i+1 -lt ${#EXTRA_OPTS[@]} ]]; then
                    masscan_port_opts="--top-ports ${EXTRA_OPTS[$i+1]}"
                    i=$((i+2))
                else
                    i=$((i+1))
                fi
            done
            if [[ -n "$masscan_port_opts" ]]; then
                masscan_cmd+=" $masscan_port_opts"
            else
                masscan_cmd+=" --top-ports 1000"
            fi
        else
            masscan_cmd+=" --top-ports 1000"
        fi

        masscan_cmd+=" $target -oG /tmp/masscan.grep 2>/dev/null"

        echo -e "${CYAN}[SMART] Running masscan for $target...${NC}"
        if [[ $VERBOSE -eq 1 ]]; then
            echo -e "${YELLOW}Command: $masscan_cmd${NC}"
        fi
        eval "$masscan_cmd"

        if [[ -f /tmp/masscan.grep ]]; then
            open_ports=$(grep -E "^Host:.*Ports:" /tmp/masscan.grep | sed -n 's/.*Ports: \([0-9,]*\)\/.*/\1/p' | tr ',' '\n' | sort -n | uniq | paste -sd, -)
            rm -f /tmp/masscan.grep
        fi

        if [[ -z "$open_ports" ]]; then
            echo -e "${YELLOW}[SMART] No open ports found by masscan.${NC}"
            return
        fi
        if [[ $cache_enabled -eq 1 ]]; then
            cache_set "$cache_key_str" "$open_ports"
        fi
        echo -e "${GREEN}[SMART] Open ports discovered: $open_ports${NC}"
    fi

    # Build final nmap command: use -p with open_ports, plus all EXTRA_OPTS (but remove any -p or --top-ports)
    local final_opts=()
    local skip_next=0
    for opt in "${EXTRA_OPTS[@]}"; do
        if [[ $skip_next -eq 1 ]]; then
            skip_next=0
            continue
        fi
        if [[ "$opt" == "-p" ]] || [[ "$opt" == "--top-ports" ]]; then
            skip_next=1
            continue
        fi
        final_opts+=("$opt")
    done

    echo -e "${CYAN}[SMART] Running nmap on $target...${NC}"
    if [[ $VERBOSE -eq 1 ]]; then
        echo -e "${YELLOW}Command: nmap ${final_opts[*]} -p $open_ports $target${NC}"
    fi
    run_nmap_filtered nmap "${final_opts[@]}" -p "$open_ports" "$target"
}

# -------------------------------------------------------------------
# MAIN
# -------------------------------------------------------------------
main() {
# --- Root check ---
if [[ $EUID -ne 0 ]]; then
    # Check if any argument requires root
    for arg in "${EXTRA_OPTS[@]}"; do
        case "$arg" in
            -sS|-sA|-sW|-sM|-sI|-sO|-sY|-sZ|-f|--mtu|-D|-S|-g|--data-length|--badsum)
                echo -e "${RED}[KNOCK] ERROR: This scan requires root privileges.${NC}" >&2
                echo -e "${YELLOW}Please run with: sudo $SCRIPT_NAME $*${NC}" >&2
                exit 1
                ;;
        esac
    done
    # If SMART_MODE=1, masscan also needs root
    if [[ $SMART_MODE -eq 1 ]]; then
        echo -e "${RED}[KNOCK] ERROR: Smart mode (--ai) requires root privileges.${NC}" >&2
        echo -e "${YELLOW}Please run with: sudo $SCRIPT_NAME $*${NC}" >&2
        exit 1
    fi
fi


    # Parse arguments
    local args=("$@")
    local i=0
    while [[ $i -lt ${#args[@]} ]]; do
        case "${args[$i]}" in
            --ai|--smart)
                SMART_MODE=1
                i=$((i+1))
                ;;
            --no-cache)
                export KNOCK_NO_CACHE=1
                i=$((i+1))
                ;;
            --masscan-rate)
                if [[ $i+1 -lt ${#args[@]} ]]; then
                    MASSCAN_RATE="${args[$i+1]}"
                    i=$((i+2))
                else
                    die "--masscan-rate requires an argument"
                fi
                ;;
            --no-logo)
                SHOW_LOGO=0
                i=$((i+1))
                ;;
            -v|--verbose)
                VERBOSE=1
                EXTRA_OPTS+=("-v")
                i=$((i+1))
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                EXTRA_OPTS+=("${args[$i]}")
                i=$((i+1))
                ;;
        esac
    done

    # Root check
    if [[ $EUID -ne 0 ]]; then
        local needs_root=0
        for arg in "${EXTRA_OPTS[@]}"; do
            case "$arg" in
                -sS|-sA|-sW|-sM|-sI|-sO|-sY|-sZ|-f|--mtu|-D|-S|-g|--data-length|--badsum)
                    needs_root=1
                    ;;
            esac
        done
        if [[ $needs_root -eq 1 ]] || [[ $SMART_MODE -eq 1 ]]; then
            echo -e "${RED}[KNOCK] ERROR: This scan requires root privileges.${NC}" >&2
            echo -e "${YELLOW}Please run with: sudo $SCRIPT_NAME $*${NC}" >&2
            exit 1
        fi
    fi

    # If not smart mode, just pass through to nmap with filter
    if [[ $SMART_MODE -eq 0 ]]; then
        show_logo
        echo -e "${CYAN}[KNOCK] Running nmap with your options...${NC}"
        run_nmap_filtered nmap "${EXTRA_OPTS[@]}"
        exit $?
    fi

    # Smart mode
    check_deps
    show_logo

    # Extract targets from EXTRA_OPTS
    local targets=()
    local remaining_opts=()
    local skip_next=0
    for opt in "${EXTRA_OPTS[@]}"; do
        if [[ $skip_next -eq 1 ]]; then
            skip_next=0
            remaining_opts+=("$opt")
            continue
        fi
        if [[ "$opt" == "-iL" ]]; then
            if [[ $i+1 -lt ${#EXTRA_OPTS[@]} ]]; then
                local infile="${EXTRA_OPTS[$i+1]}"
                if [[ -f "$infile" ]]; then
                    mapfile -t targets < "$infile"
                else
                    die "Input file '$infile' not found."
                fi
                skip_next=1
                remaining_opts+=("$opt" "$infile")
            else
                die "-iL requires a filename"
            fi
            continue
        fi
        if [[ "$opt" == "-"* ]]; then
            remaining_opts+=("$opt")
        else
            targets+=("$opt")
        fi
    done
    EXTRA_OPTS=("${remaining_opts[@]}")

    if [[ ${#targets[@]} -eq 0 ]]; then
        die "No targets specified. Use --ai with a target or -iL."
    fi

    for target in "${targets[@]}"; do
        run_smart_scan "$target"
    done
}

main "$@"
