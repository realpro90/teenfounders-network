#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  TeenFounders Network — Lobby Provisioning System v2.0                     ║
# ║  PaperMC 1.21.11 (Purpur 1.21.4 engine) | Railway Container Runtime       ║
# ║                                                                            ║
# ║  A production-grade, idempotent installer for the TeenFounders Build       ║
# ║  Network lobby world. Designed for Railway ephemeral containers with       ║
# ║  persistent /data volumes.                                                 ║
# ║                                                                            ║
# ║  © 2026 TeenFounders · https://teenfounders.in                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Usage:
#   /bin/bash lobby/setup_lobby_world.sh [DATA_DIR]
#
# Environment:
#   DATA_DIR           — Root data directory (default: /data)
#   LOBBY_ARCHIVE_URL  — Override the lobby world download URL
#   LOBBY_SHA256       — Expected SHA256 checksum of the archive
#   TF_SKIP_BACKUP     — Set to "1" to skip backup (CI/first-run)
#   TF_FORCE_REINSTALL — Set to "1" to force full reinstall
#
# Exit Codes:
#   0  — Success
#   1  — Fatal error (details in logs/provision.log)
#
# ShellCheck: This script passes shellcheck --severity=warning
# shellcheck shell=bash

# ─── Strict Mode ─────────────────────────────────────────────────────────────
set -euo pipefail
IFS=$'\n\t'

# ─── Constants ───────────────────────────────────────────────────────────────

readonly INSTALLER_VERSION="2.0.0"
readonly MINECRAFT_VERSION="1.21.11"
readonly PAPER_ENGINE="Purpur 1.21.4"

# Paths
readonly DATA_DIR="${1:-/data}"
readonly WORLD_DIR="${DATA_DIR}/world"
readonly LOG_DIR="${DATA_DIR}/logs"
readonly LOG_FILE="${LOG_DIR}/provision.log"
readonly BACKUP_DIR="${DATA_DIR}/backups/worlds"
readonly MARKER_FILE="${WORLD_DIR}/.tf_lobby_installed"
readonly ESSENTIALS_DIR="${DATA_DIR}/plugins/Essentials"

# Download configuration
readonly DEFAULT_LOBBY_URL="https://github.com/realpro90/teenfounders-network/releases/download/v1.0.0/teenfounders-lobby-world.tar.gz"
readonly LOBBY_URL="${LOBBY_ARCHIVE_URL:-${DEFAULT_LOBBY_URL}}"
readonly EXPECTED_SHA256="${LOBBY_SHA256:-}"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=5

# Spawn coordinates (Central Plaza)
readonly SPAWN_X="0.5"
readonly SPAWN_Y="66.0"
readonly SPAWN_Z="17.5"
readonly SPAWN_YAW="0.0"
readonly SPAWN_PITCH="0.0"

# Flat world generator config — Quartz surface over Blackstone over Bedrock
readonly FLAT_GENERATOR='{"layers":[{"block":"minecraft:bedrock","height":1},{"block":"minecraft:blackstone","height":5},{"block":"minecraft:smooth_quartz","height":1}],"biome":"minecraft:plains","features":false}'

# Required world subdirectories for validation
readonly -a REQUIRED_WORLD_DIRS=("region" "data")
readonly -a OPTIONAL_WORLD_DIRS=("poi" "entities" "playerdata" "datapacks")

# ─── ANSI Colour Palette ────────────────────────────────────────────────────
# TeenFounders brand: Orange (#FF9932), White, Black

readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_DIM='\033[2m'

# Brand colours
readonly C_ORANGE='\033[38;2;255;153;50m'     # #FF9932 — TeenFounders Orange
readonly C_WHITE='\033[97m'
readonly C_BLACK='\033[30m'

# Semantic colours
readonly C_GREEN='\033[38;2;80;200;120m'       # Success
readonly C_YELLOW='\033[38;2;255;204;0m'       # Warning
readonly C_RED='\033[38;2;255;69;58m'          # Error
readonly C_CYAN='\033[38;2;90;200;250m'        # Info
readonly C_GRAY='\033[38;2;140;140;140m'       # Muted

# Unicode glyphs
readonly ICON_OK="✓"
readonly ICON_FAIL="✗"
readonly ICON_WARN="⚠"
readonly ICON_INFO="▸"
readonly ICON_ARROW="▶"
readonly ICON_DOT="•"

# Separator line (60 chars)
readonly SEP="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─── Timing ──────────────────────────────────────────────────────────────────

PROVISION_START_EPOCH=""
STEP_COUNT=0
FILES_EXTRACTED=0
WORLD_SIZE_HUMAN="0B"
INSTALL_METHOD="unknown"

# ─── Logging ─────────────────────────────────────────────────────────────────

# Initialise the log file.
_init_log() {
    mkdir -p "${LOG_DIR}"
    {
        echo "════════════════════════════════════════════════════════════════"
        echo " TeenFounders Lobby Provisioning Log"
        echo " Installer v${INSTALLER_VERSION}"
        echo " Started: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        echo " Data Dir: ${DATA_DIR}"
        echo "════════════════════════════════════════════════════════════════"
    } > "${LOG_FILE}"
}

# Append a timestamped line to the log file.
_log() {
    local level="$1"
    shift
    echo "[$(date -u '+%H:%M:%S')] [${level}] $*" >> "${LOG_FILE}"
}

# ─── Output Helpers ──────────────────────────────────────────────────────────

# Print the startup banner.
_banner() {
    echo ""
    echo -e "${C_ORANGE}${C_BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              TEENFOUNDERS BUILD NETWORK                    ║"
    echo "║          Lobby Provisioning System v${INSTALLER_VERSION}                  ║"
    echo "║           PaperMC ${MINECRAFT_VERSION}  •  Railway Deploy               ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${C_RESET}"
    echo -e "  ${C_GRAY}https://teenfounders.in${C_RESET}"
    echo ""
}

# Print a section separator with a title.
_section() {
    local title="$1"
    echo ""
    echo -e "${C_ORANGE}${SEP}${C_RESET}"
    echo -e "${C_ORANGE}${C_BOLD} ${ICON_ARROW} ${title}${C_RESET}"
    echo -e "${C_ORANGE}${SEP}${C_RESET}"
    _log "INFO" "=== ${title} ==="
}

# Print a success step.
_ok() {
    local msg="$1"
    STEP_COUNT=$((STEP_COUNT + 1))
    echo -e "  ${C_GREEN}${ICON_OK}${C_RESET} ${msg}"
    _log "OK" "${msg}"
}

# Print a warning.
_warn() {
    local msg="$1"
    echo -e "  ${C_YELLOW}${ICON_WARN}${C_RESET} ${C_YELLOW}${msg}${C_RESET}"
    _log "WARN" "${msg}"
}

# Print an info message.
_info() {
    local msg="$1"
    echo -e "  ${C_CYAN}${ICON_INFO}${C_RESET} ${C_DIM}${msg}${C_RESET}"
    _log "INFO" "${msg}"
}

# Print a fatal error and exit.
_fatal() {
    local msg="$1"
    echo ""
    echo -e "  ${C_RED}${C_BOLD}${ICON_FAIL} FATAL: ${msg}${C_RESET}"
    echo ""
    _log "FATAL" "${msg}"
    _log "INFO" "Provision FAILED at $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    exit 1
}

# Print a detail bullet under the current step.
_detail() {
    local msg="$1"
    echo -e "    ${C_GRAY}${ICON_DOT} ${msg}${C_RESET}"
}

# ─── Utility Functions ───────────────────────────────────────────────────────

# Return elapsed seconds since provision start.
_elapsed() {
    local now
    now=$(date +%s)
    echo $(( now - PROVISION_START_EPOCH ))
}

# Format seconds into human-readable duration (e.g. "1m 23s").
_format_duration() {
    local total_secs="$1"
    local mins=$(( total_secs / 60 ))
    local secs=$(( total_secs % 60 ))

    if [[ ${mins} -gt 0 ]]; then
        echo "${mins}m ${secs}s"
    else
        echo "${secs}s"
    fi
}

# Get human-readable file size. Works on both GNU and BusyBox.
_file_size() {
    local file="$1"
    if [[ -f "${file}" ]]; then
        du -h "${file}" 2>/dev/null | awk '{print $1}'
    else
        echo "0B"
    fi
}

# Get directory size in human-readable format.
_dir_size() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        du -sh "${dir}" 2>/dev/null | awk '{print $1}'
    else
        echo "0B"
    fi
}

# Count files in a directory recursively.
_file_count() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        find "${dir}" -type f 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Set a property in server.properties without creating duplicates.
# Usage: _set_property "key" "value" "/path/to/server.properties"
_set_property() {
    local key="$1"
    local value="$2"
    local file="$3"

    # Ensure file exists
    touch "${file}"

    if grep -q "^${key}=" "${file}" 2>/dev/null; then
        # Replace existing property in-place
        sed -i "s|^${key}=.*|${key}=${value}|" "${file}"
    else
        # Append new property
        echo "${key}=${value}" >> "${file}"
    fi
}

# ─── Download with Retry ────────────────────────────────────────────────────

# Download a file with automatic retries, progress display, and validation.
# Returns 0 on success, 1 on failure.
_download() {
    local url="$1"
    local dest="$2"
    local description="${3:-file}"
    local attempt=0

    while [[ ${attempt} -lt ${MAX_RETRIES} ]]; do
        attempt=$((attempt + 1))

        if [[ ${attempt} -gt 1 ]]; then
            _warn "Retry ${attempt}/${MAX_RETRIES} in ${RETRY_DELAY}s..."
            sleep "${RETRY_DELAY}"
        fi

        _detail "Attempt ${attempt}/${MAX_RETRIES}: ${url}"

        # Use curl with progress bar, follow redirects, fail on HTTP errors
        if curl -fSL \
            --connect-timeout 15 \
            --max-time 300 \
            --retry 2 \
            --retry-delay 3 \
            -o "${dest}" \
            "${url}" 2>&1; then

            # Validate that something was actually downloaded
            if [[ -f "${dest}" ]]; then
                local size
                size=$(wc -c < "${dest}" 2>/dev/null || echo "0")
                if [[ ${size} -gt 1000 ]]; then
                    _detail "Downloaded ${description}: $(_file_size "${dest}")"
                    _log "INFO" "Downloaded ${description} from ${url} (${size} bytes)"
                    return 0
                else
                    _warn "Downloaded file too small (${size} bytes) — likely a GitHub 404 page"
                    rm -f "${dest}"
                fi
            fi
        else
            _warn "Download attempt ${attempt} failed (curl exit $?)"
            rm -f "${dest}"
        fi
    done

    _log "ERROR" "All ${MAX_RETRIES} download attempts failed for ${url}"
    return 1
}

# ─── SHA256 Checksum Verification ────────────────────────────────────────────

# Verify SHA256 checksum of a file.
# Returns 0 on match, 1 on mismatch, 2 if no checksum tool available.
_verify_sha256() {
    local file="$1"
    local expected="$2"

    # Skip if no expected checksum provided
    if [[ -z "${expected}" ]]; then
        _detail "No SHA256 checksum provided — skipping verification"
        return 0
    fi

    local actual=""

    # Try sha256sum (GNU/Linux), then shasum (macOS/BusyBox)
    if command -v sha256sum &>/dev/null; then
        actual=$(sha256sum "${file}" | awk '{print $1}')
    elif command -v shasum &>/dev/null; then
        actual=$(shasum -a 256 "${file}" | awk '{print $1}')
    else
        _warn "No SHA256 tool available — cannot verify checksum"
        return 2
    fi

    if [[ "${actual}" == "${expected}" ]]; then
        _detail "SHA256 checksum verified: ${actual:0:16}..."
        _log "INFO" "SHA256 OK: ${actual}"
        return 0
    else
        _warn "SHA256 MISMATCH!"
        _detail "Expected: ${expected:0:16}..."
        _detail "Actual:   ${actual:0:16}..."
        _log "ERROR" "SHA256 mismatch: expected=${expected} actual=${actual}"
        return 1
    fi
}

# ─── Backup System ───────────────────────────────────────────────────────────

# Create a timestamped compressed backup of the current world directory.
# Skips if TF_SKIP_BACKUP=1 or no world exists.
_backup_world() {
    # Skip if explicitly disabled
    if [[ "${TF_SKIP_BACKUP:-0}" == "1" ]]; then
        _info "Backup skipped (TF_SKIP_BACKUP=1)"
        return 0
    fi

    # Skip if no world directory exists
    if [[ ! -d "${WORLD_DIR}" ]]; then
        _info "No existing world to back up"
        return 0
    fi

    # Skip if world is empty
    local world_files
    world_files=$(_file_count "${WORLD_DIR}")
    if [[ ${world_files} -le 1 ]]; then
        _info "World directory is empty — skipping backup"
        return 0
    fi

    mkdir -p "${BACKUP_DIR}"

    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${BACKUP_DIR}/world_backup_${timestamp}.tar.gz"

    _info "Creating backup: world_backup_${timestamp}.tar.gz"

    if tar -czf "${backup_file}" -C "${DATA_DIR}" "world" 2>/dev/null; then
        _ok "World backed up ($(_file_size "${backup_file}"))"
        _log "INFO" "Backup created: ${backup_file} ($(_file_size "${backup_file}"))"

        # Prune old backups — keep only the 3 most recent
        local backup_count
        backup_count=$(find "${BACKUP_DIR}" -name 'world_backup_*.tar.gz' -type f | wc -l | tr -d ' ')
        if [[ ${backup_count} -gt 3 ]]; then
            _info "Pruning old backups (keeping 3 most recent)..."
            # shellcheck disable=SC2012
            ls -1t "${BACKUP_DIR}"/world_backup_*.tar.gz | tail -n +4 | xargs rm -f 2>/dev/null || true
        fi

        return 0
    else
        _warn "Backup creation failed — continuing anyway"
        _log "WARN" "Backup tar failed for ${WORLD_DIR}"
        return 0
    fi
}

# Restore the most recent backup. Called on installation failure.
_rollback() {
    local latest_backup
    latest_backup=$(find "${BACKUP_DIR}" -name 'world_backup_*.tar.gz' -type f 2>/dev/null | sort -r | head -n 1)

    if [[ -z "${latest_backup}" ]]; then
        _warn "No backup available for rollback"
        return 1
    fi

    _info "Rolling back to: $(basename "${latest_backup}")"

    rm -rf "${WORLD_DIR}"
    mkdir -p "${WORLD_DIR}"

    if tar -xzf "${latest_backup}" -C "${DATA_DIR}" 2>/dev/null; then
        _ok "Rollback complete"
        _log "INFO" "Rolled back to ${latest_backup}"
        return 0
    else
        _fatal "Rollback failed — world may be in an inconsistent state"
    fi
}

# ─── World Validation ────────────────────────────────────────────────────────

# Validate that the world directory has the expected structure.
# Returns 0 if valid, 1 if invalid.
_validate_world() {
    local world_path="$1"
    local errors=0

    _info "Validating world structure..."

    # Check world directory exists
    if [[ ! -d "${world_path}" ]]; then
        _warn "World directory does not exist: ${world_path}"
        return 1
    fi

    # Check for level.dat
    if [[ -f "${world_path}/level.dat" ]]; then
        _detail "level.dat present ($(_file_size "${world_path}/level.dat"))"
    else
        _detail "level.dat not found (will be generated by server)"
    fi

    # Check required subdirectories
    for dir in "${REQUIRED_WORLD_DIRS[@]}"; do
        if [[ -d "${world_path}/${dir}" ]]; then
            _detail "${dir}/ present ($(_file_count "${world_path}/${dir}") files)"
        else
            _detail "${dir}/ missing — creating..."
            mkdir -p "${world_path}/${dir}"
        fi
    done

    # Check optional subdirectories
    for dir in "${OPTIONAL_WORLD_DIRS[@]}"; do
        if [[ -d "${world_path}/${dir}" ]]; then
            _detail "${dir}/ present"
        else
            mkdir -p "${world_path}/${dir}"
        fi
    done

    if [[ ${errors} -gt 0 ]]; then
        _log "WARN" "World validation completed with ${errors} errors"
        return 1
    fi

    _ok "World structure validated"
    return 0
}

# ─── Server Properties Manager ──────────────────────────────────────────────

# Configure server.properties for the lobby server.
# Uses _set_property to avoid duplicate entries.
_configure_server_properties() {
    local props_file="${DATA_DIR}/server.properties"

    touch "${props_file}"

    # Core lobby settings
    _set_property "level-name"           "world"                "${props_file}"
    _set_property "spawn-protection"     "0"                    "${props_file}"
    _set_property "difficulty"           "peaceful"             "${props_file}"
    _set_property "allow-flight"         "true"                 "${props_file}"
    _set_property "view-distance"        "10"                   "${props_file}"
    _set_property "simulation-distance"  "8"                    "${props_file}"
    _set_property "online-mode"          "false"                "${props_file}"
    _set_property "server-port"          "25565"                "${props_file}"
    _set_property "server-ip"            ""                     "${props_file}"
    _set_property "gamemode"             "adventure"            "${props_file}"
    _set_property "force-gamemode"       "true"                 "${props_file}"
    _set_property "pvp"                  "false"                "${props_file}"
    _set_property "spawn-monsters"       "false"                "${props_file}"
    _set_property "spawn-animals"        "false"                "${props_file}"
    _set_property "spawn-npcs"           "true"                 "${props_file}"
    _set_property "max-players"          "100"                  "${props_file}"
    _set_property "enable-command-block" "true"                 "${props_file}"
    _set_property "motd"                 "\\u00A76\\u00A7lTEENFOUNDERS \\u00A7fLobby \\u00A77[${MINECRAFT_VERSION}]" "${props_file}"

    # Flat world type — force flat terrain for lobby
    _set_property "level-type"           "flat"                 "${props_file}"
    _set_property "generator-settings"   "${FLAT_GENERATOR}"    "${props_file}"

    _ok "Configured server.properties ($(grep -c '=' "${props_file}" 2>/dev/null || echo 0) properties)"
}

# ─── Essentials Spawn Configuration ──────────────────────────────────────────

# Write the Essentials spawn.yml with the lobby spawn point.
_configure_spawn() {
    mkdir -p "${ESSENTIALS_DIR}"

    cat > "${ESSENTIALS_DIR}/spawn.yml" << YAML
# ──────────────────────────────────────────────────────────────
# TeenFounders Network — Essentials Spawn Configuration
# Auto-generated by Lobby Provisioning System v${INSTALLER_VERSION}
# ──────────────────────────────────────────────────────────────

spawns:
  default:
    world: world
    x: ${SPAWN_X}
    y: ${SPAWN_Y}
    z: ${SPAWN_Z}
    yaw: ${SPAWN_YAW}
    pitch: ${SPAWN_PITCH}
YAML

    _ok "Spawn configured at (${SPAWN_X}, ${SPAWN_Y}, ${SPAWN_Z})"
    _log "INFO" "Spawn set to world=(world) x=${SPAWN_X} y=${SPAWN_Y} z=${SPAWN_Z}"
}

# ─── Archive Extraction ─────────────────────────────────────────────────────

# Extract a tar.gz archive into the world directory with validation.
# Returns 0 on success, 1 on failure.
_extract_archive() {
    local archive="$1"
    local dest="$2"

    _info "Verifying archive integrity..."

    # Test archive integrity before extracting
    if ! tar -tzf "${archive}" &>/dev/null; then
        _warn "Archive is corrupted or not a valid tar.gz"
        _log "ERROR" "Archive integrity check failed: ${archive}"
        return 1
    fi

    _ok "Archive integrity verified"

    _info "Extracting world files..."

    # Count files for progress reporting
    local total_files
    total_files=$(tar -tzf "${archive}" 2>/dev/null | wc -l | tr -d ' ')

    if tar -xzf "${archive}" -C "${dest}" 2>&1; then
        FILES_EXTRACTED=${total_files}
        _ok "Extracted ${FILES_EXTRACTED} files"
        _log "INFO" "Extracted ${FILES_EXTRACTED} files from ${archive} into ${dest}"
        return 0
    else
        _warn "Extraction failed"
        _log "ERROR" "tar extraction failed for ${archive}"
        return 1
    fi
}

# ─── Main Installation Logic ────────────────────────────────────────────────

# Check if lobby is already installed and skip if so.
_check_installed() {
    if [[ "${TF_FORCE_REINSTALL:-0}" == "1" ]]; then
        _info "Force reinstall requested (TF_FORCE_REINSTALL=1)"
        return 1
    fi

    if [[ -f "${MARKER_FILE}" ]]; then
        local installed_version
        installed_version=$(cat "${MARKER_FILE}" 2>/dev/null || echo "unknown")
        if [[ "${installed_version}" == "${INSTALLER_VERSION}" ]]; then
            _ok "Lobby already installed (v${installed_version})"
            _info "Set TF_FORCE_REINSTALL=1 to reinstall"
            return 0
        else
            _info "Installed v${installed_version} → upgrading to v${INSTALLER_VERSION}"
            return 1
        fi
    fi

    return 1
}

# Install the lobby world — either from archive or generate flat.
_install_lobby() {
    local archive_path="/tmp/tf-lobby-world.tar.gz"

    # ── Step 1: Backup existing world ────────────────────────────────────
    _section "Backup"
    _backup_world

    # ── Step 2: Download lobby archive ───────────────────────────────────
    _section "Downloading TeenFounders Lobby…"

    local download_ok=false

    if _download "${LOBBY_URL}" "${archive_path}" "TeenFounders Lobby World"; then
        # Verify checksum if provided
        if _verify_sha256 "${archive_path}" "${EXPECTED_SHA256}"; then
            download_ok=true
        else
            _warn "Checksum verification failed — discarding archive"
            rm -f "${archive_path}"
        fi
    fi

    # ── Step 3: Wipe old world & prepare directories ─────────────────────
    _section "Preparing World Directory"

    _info "Removing old terrain & player logoff data..."
    rm -rf "${WORLD_DIR}"
    rm -rf "${DATA_DIR}/plugins/Essentials/userdata"
    _ok "Old world & player logoff data removed"

    mkdir -p "${WORLD_DIR}"
    for dir in "${REQUIRED_WORLD_DIRS[@]}" "${OPTIONAL_WORLD_DIRS[@]}"; do
        mkdir -p "${WORLD_DIR}/${dir}"
    done
    _ok "World directory structure created"

    # ── Step 4: Extract pre-packaged local or downloadedd world ───────────
    _section "Installing Production Lobby World Package"

    local user_tar="/server/lobby/lobbyworld.tar.gz"
    local user_lobbyworld="/server/lobbyworld"

    if [[ -f "${user_tar}" ]]; then
        _info "Found user-provided lobbyworld archive: ${user_tar}"
        rm -rf "${WORLD_DIR}"
        mkdir -p "${WORLD_DIR}"
        tar -xzf "${user_tar}" --strip-components=1 -C "${WORLD_DIR}"
        INSTALL_METHOD="user_lobbyworld_tar"
        _ok "Extracted user-provided lobbyworld archive into ${WORLD_DIR}"
    elif [[ -d "${user_lobbyworld}" ]]; then
        _info "Found user-provided lobbyworld directory: ${user_lobbyworld}"
        cp -rf "${user_lobbyworld}/"* "${WORLD_DIR}/"
        INSTALL_METHOD="user_lobbyworld"
        _ok "Copied user-provided lobbyworld into ${WORLD_DIR}"
    elif [[ -f "${local_archive}" ]]; then
        _info "Found pre-bundled production lobby archive: ${local_archive}"
        tar -xzf "${local_archive}" -C "${DATA_DIR}"
        INSTALL_METHOD="bundled_archive"
        _ok "Extracted bundled production lobby world package"
    elif [[ -d "${local_world}" ]]; then
        _info "Found pre-bundled production lobby world directory: ${local_world}"
        cp -rf "${local_world}/"* "${WORLD_DIR}/"
        INSTALL_METHOD="bundled_directory"
        _ok "Copied bundled production lobby world package"
    elif [[ "${download_ok}" == true ]]; then
        _section "Extracting Downloaded Lobby World"
        if _extract_archive "${archive_path}" "${WORLD_DIR}"; then
            INSTALL_METHOD="archive"
            _ok "Lobby world installed from downloaded archive"
        fi
        rm -f "${archive_path}"
    fi

    # ── Step 5: Configure server.properties ──────────────────────────────
    _section "Configuring Server Properties"
    _configure_server_properties

    # ── Step 6: Configure spawn ──────────────────────────────────────────
    _section "Configuring Spawn Point"
    _configure_spawn

    # ── Step 7: Deploy Lobby Datapack ──────────────────────────────────
    _section "Deploying Lobby Datapack"

    local datapack_src="/server/lobby/datapacks/tf_lobby"
    local datapack_dest="${WORLD_DIR}/datapacks/tf_lobby"

    if [[ -d "${datapack_src}" ]]; then
        mkdir -p "${WORLD_DIR}/datapacks"
        cp -rf "${datapack_src}" "${datapack_dest}"
        local dp_files
        dp_files=$(_file_count "${datapack_dest}")
        _ok "Deployed tf_lobby datapack (${dp_files} files)"
        _detail "Plaza builder, portal districts, join handler, decorations"
        _log "INFO" "Datapack deployed: ${datapack_dest} (${dp_files} files)"
    else
        _warn "Datapack source not found: ${datapack_src}"
        _info "Lobby structures will not be auto-generated"
    fi

    # ── Step 8: Validate world ───────────────────────────────────────────
    _section "Final Validation"

    if ! _validate_world "${WORLD_DIR}"; then
        _warn "World validation failed"

        # Attempt rollback if a backup exists
        if [[ -d "${BACKUP_DIR}" ]] && [[ -n "$(ls -A "${BACKUP_DIR}" 2>/dev/null)" ]]; then
            _warn "Attempting rollback to previous world..."
            _rollback
            _fatal "Installation failed. Rolled back to previous world."
        fi
    fi

    # Write installation marker
    echo "${INSTALLER_VERSION}" > "${MARKER_FILE}"
    _ok "Installation marker written"

    WORLD_SIZE_HUMAN=$(_dir_size "${WORLD_DIR}")
}

# ─── Summary Report ─────────────────────────────────────────────────────────

# Print a beautiful installation summary with statistics.
_print_summary() {
    local elapsed
    elapsed=$(_elapsed)
    local duration
    duration=$(_format_duration "${elapsed}")

    local status_colour="${C_GREEN}"
    local status_text="SUCCESS"
    local status_icon="${ICON_OK}"

    echo ""
    echo -e "${C_ORANGE}${SEP}${C_RESET}"
    echo -e "${C_ORANGE}${C_BOLD} Installation Summary${C_RESET}"
    echo -e "${C_ORANGE}${SEP}${C_RESET}"
    echo ""
    echo -e "  ${C_WHITE}${C_BOLD}Lobby Installed${C_RESET}       ${C_GREEN}${ICON_OK} Yes${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Install Method${C_RESET}        ${C_CYAN}${INSTALL_METHOD}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}World Size${C_RESET}            ${C_CYAN}${WORLD_SIZE_HUMAN}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Files Extracted${C_RESET}       ${C_CYAN}${FILES_EXTRACTED}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Steps Completed${C_RESET}       ${C_CYAN}${STEP_COUNT}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Installation Time${C_RESET}     ${C_CYAN}${duration}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Minecraft Version${C_RESET}     ${C_CYAN}${MINECRAFT_VERSION}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Engine${C_RESET}                ${C_CYAN}${PAPER_ENGINE}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Installer Version${C_RESET}     ${C_CYAN}v${INSTALLER_VERSION}${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Railway Ready${C_RESET}         ${C_GREEN}${ICON_OK} Yes${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Spawn Configured${C_RESET}      ${C_GREEN}${ICON_OK} (${SPAWN_X}, ${SPAWN_Y}, ${SPAWN_Z})${C_RESET}"
    echo -e "  ${C_WHITE}${C_BOLD}Log File${C_RESET}              ${C_GRAY}${LOG_FILE}${C_RESET}"
    echo ""
    echo -e "  ${status_colour}${C_BOLD}Status: ${status_icon} ${status_text}${C_RESET}"
    echo ""
    echo -e "${C_ORANGE}${SEP}${C_RESET}"
    echo ""

    # Write summary to log
    {
        echo ""
        echo "════════════════════════════════════════════════════════════════"
        echo " Installation Summary"
        echo "════════════════════════════════════════════════════════════════"
        echo " Status:            ${status_text}"
        echo " Install Method:    ${INSTALL_METHOD}"
        echo " World Size:        ${WORLD_SIZE_HUMAN}"
        echo " Files Extracted:   ${FILES_EXTRACTED}"
        echo " Steps Completed:   ${STEP_COUNT}"
        echo " Duration:          ${duration} (${elapsed}s)"
        echo " MC Version:        ${MINECRAFT_VERSION}"
        echo " Engine:            ${PAPER_ENGINE}"
        echo " Installer:         v${INSTALLER_VERSION}"
        echo " Completed:         $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        echo "════════════════════════════════════════════════════════════════"
    } >> "${LOG_FILE}"
}

# ─── Entrypoint ──────────────────────────────────────────────────────────────

main() {
    PROVISION_START_EPOCH=$(date +%s)

    # Initialise logging
    _init_log

    # Display startup banner
    _banner

    # ── Pre-flight checks ────────────────────────────────────────────────
    _section "Pre-flight Checks"

    # Validate environment
    _info "Data directory: ${DATA_DIR}"
    mkdir -p "${DATA_DIR}"
    _ok "Environment validated"

    # Check disk space (warn if < 500MB available)
    local avail_kb
    avail_kb=$(df -k "${DATA_DIR}" 2>/dev/null | awk 'NR==2{print $4}' || echo "0")
    if [[ ${avail_kb} -lt 512000 ]]; then
        _warn "Low disk space: $((avail_kb / 1024))MB available (recommend ≥ 500MB)"
    else
        _ok "Disk space: $((avail_kb / 1024))MB available"
    fi

    # Check required tools
    for tool in curl tar gzip mkdir rm sed grep; do
        if ! command -v "${tool}" &>/dev/null; then
            _fatal "Required tool not found: ${tool}"
        fi
    done
    _ok "Required tools verified"

    # ── Idempotency check ────────────────────────────────────────────────
    _section "Installation Check"

    if _check_installed; then
        # Already installed — only ensure server.properties and spawn are correct
        _section "Refreshing Configuration"
        _configure_server_properties
        _configure_spawn
        _print_summary
        return 0
    fi

    # ── Run installation ─────────────────────────────────────────────────
    _install_lobby

    # ── Print summary ────────────────────────────────────────────────────
    _print_summary
}

# Run main
main "$@"
