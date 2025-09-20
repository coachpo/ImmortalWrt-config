#!/usr/bin/env bash

set -euo pipefail

# Validate that CONFIG_PACKAGE_* entries in seed.config files exist in the current
# ImmortalWrt tree (core packages and feeds). Detects packages that were removed
# or renamed in feeds.
#
# Usage:
#   ./validate-seed-configs.sh [--immortalwrt DIR] [--update-feeds] [--verbose]
#
# Defaults:
#   --immortalwrt defaults to ./immortalwrt (this repo's subdirectory)
#   --update-feeds runs ./scripts/feeds update -a and regenerates metadata

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMMORTALWRT_DIR="${IMMORTALWRT_DIR:-"$ROOT_DIR/immortalwrt"}"
DO_UPDATE_FEEDS=false
VERBOSE=false

log()  { printf '%s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" 1>&2; }
err()  { printf '[ERROR] %s\n' "$*" 1>&2; exit 2; }

usage() {
  cat <<EOF
Validate seed.config package entries against available packages.

Options:
  -r, --immortalwrt DIR   Path to ImmortalWrt source tree (default: $IMMORTALWRT_DIR)
  -u, --update-feeds      Run ./scripts/feeds update -a and refresh metadata
  -v, --verbose           Verbose output
  -h, --help              Show this help
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -r|--immortalwrt)
        [[ $# -ge 2 ]] || err "--immortalwrt requires a path"
        IMMORTALWRT_DIR="$(cd "$2" && pwd)"
        shift 2
        ;;
      -u|--update-feeds)
        DO_UPDATE_FEEDS=true
        shift
        ;;
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        usage; exit 0
        ;;
      *)
        err "Unknown argument: $1"
        ;;
    esac
  done
}

run_update_and_metadata() {
  # Update feeds and indexes, then generate core metadata
  ( cd "$IMMORTALWRT_DIR" && \
    info "Updating feeds (-a)..." && \
    ./scripts/feeds update -a && \
    info "Generating feed indices..." && \
    ./scripts/feeds update -i -a || true )

  # Prepare combined core metadata
  if command -v gmake >/dev/null 2>&1; then
    MAKE_BIN=gmake
  else
    MAKE_BIN=make
  fi

  if "$MAKE_BIN" -v | grep -q "GNU Make"; then
    ( cd "$IMMORTALWRT_DIR" && \
      info "Preparing core package metadata (tmp/.packageinfo)..." && \
      "$MAKE_BIN" -s prepare-tmpinfo OPENWRT_BUILD= >/dev/null ) || warn "prepare-tmpinfo failed; core packages may be incomplete"
  else
    warn "GNU make not found; skipping core metadata generation"
  fi
}

declare -A AVAILABLE_PKGS=()

add_from_metadata_file() {
  local file="$1"
  [[ -s "$file" ]] || return 0
  # Collect concrete packages
  while IFS= read -r line; do
    [[ $line == Package:\ * ]] || continue
    local name
    name="${line#Package: }"
    [[ -n "$name" ]] && AVAILABLE_PKGS["$name"]=1
  done < "$file"
  # Collect virtual provided names
  while IFS= read -r line; do
    [[ $line == Provides:\ * ]] || continue
    local provides
    provides="${line#Provides: }"
    for token in $provides; do
      [[ -n "$token" ]] && AVAILABLE_PKGS["$token"]=1
    done
  done < "$file"
}

gather_available_packages() {
  local feeds_idx=( )
  # Feed indexes (symlinks to .packageinfo)
  while IFS= read -r -d $'\0' idx; do
    feeds_idx+=("$idx")
  done < <(find "$IMMORTALWRT_DIR/feeds" -maxdepth 1 -name '*.index' -type l -print0 2>/dev/null || true)

  for idx in "${feeds_idx[@]}"; do
    add_from_metadata_file "$idx"
  done

  # Core metadata if present
  if [[ -f "$IMMORTALWRT_DIR/tmp/.packageinfo" ]]; then
    add_from_metadata_file "$IMMORTALWRT_DIR/tmp/.packageinfo"
  fi

  if $VERBOSE; then
    info "Loaded ${#AVAILABLE_PKGS[@]} available package names (including virtual provides)"
  fi

  if [[ ${#AVAILABLE_PKGS[@]} -eq 0 ]]; then
    warn "No package metadata found. Consider running with --update-feeds"
  fi
}

list_seed_configs() {
  # Find seed.config files at repo root subdirectories (excluding vendor tree)
  find "$ROOT_DIR" -maxdepth 2 -type f -name 'seed.config' \
    -not -path "$IMMORTALWRT_DIR/*" \
    -print | sort
}

validate_seed_file() {
  local seed_path="$1"
  local rel_path
  rel_path="${seed_path#"$ROOT_DIR"/}"
  $VERBOSE && info "Validating $rel_path"

  local missing=( )
  # Extract CONFIG_PACKAGE_* entries set to y or m (ignore comments and others)
  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    if [[ -z ${AVAILABLE_PKGS["$pkg"]+x} ]]; then
      missing+=("$pkg")
    fi
  done < <(sed -n -E 's/^CONFIG_PACKAGE_([A-Za-z0-9_.+-]+)=(y|m)$/\1/p' "$seed_path")

  if [[ ${#missing[@]} -gt 0 ]]; then
    printf '\n==> %s\n' "$rel_path"
    printf 'Missing packages (%d):\n' "${#missing[@]}"
    for p in "${missing[@]}"; do
      printf '  - %s\n' "$p"
    done
    return 1
  fi
  $VERBOSE && info "OK: $rel_path"
  return 0
}

main() {
  parse_args "$@"
  [[ -d "$IMMORTALWRT_DIR" ]] || err "ImmortalWrt directory not found: $IMMORTALWRT_DIR"
  [[ -x "$IMMORTALWRT_DIR/scripts/feeds" ]] || err "Missing feeds tool: $IMMORTALWRT_DIR/scripts/feeds"

  if $DO_UPDATE_FEEDS; then
    run_update_and_metadata
  fi

  gather_available_packages

  local seeds=( )
  while IFS= read -r s; do
    seeds+=("$s")
  done < <(list_seed_configs)

  if [[ ${#seeds[@]} -eq 0 ]]; then
    warn "No seed.config files found to validate"
    exit 0
  fi

  $VERBOSE && info "Found ${#seeds[@]} seed config(s)"

  local failed=0
  for s in "${seeds[@]}"; do
    if ! validate_seed_file "$s"; then
      failed=1
    fi
  done

  if [[ $failed -ne 0 ]]; then
    printf '\nValidation failed. One or more seed.config files reference packages not present in current feeds/core.\n' 1>&2
    printf 'Hint: run with --update-feeds to refresh indices, or search with:\n  (cd %s && ./scripts/feeds search <name>)\n' "$IMMORTALWRT_DIR" 1>&2
    exit 1
  fi

  info "All seed.config files are valid against current package metadata."
}

main "$@"


