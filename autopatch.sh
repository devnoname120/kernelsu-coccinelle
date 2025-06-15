#!/usr/bin/env bash

set -e

# Settings
PATCH_REPO_URL="https://github.com/devnoname120/kernelsu-coccinelle.git"
PATCH_DIR_NAME="kernelsu-coccinelle"
SCOPE_PATCH="scope-minimized-hooks/kernelsu-scope-minimized.cocci"

# Usage info
if [[ -z "$1" ]]; then
  echo "Usage: bash autopatch.sh <kernel-source-path> [-ksu|-scope] [-o|-m] [patch1.cocci patch2.cocci ...]"
  echo
  echo "Examples:"
  echo "  bash autopatch.sh ~/kernel -ksu -o                # Apply all patches across full tree"
  echo "  bash autopatch.sh ~/kernel -ksu -m input.cocci    # Apply specific patches to matched files"
  echo "  bash autopatch.sh ~/kernel -scope                 # Apply scope-minimized patch only"
  exit 1
fi

KERNEL_DIR="$1"
shift

# Check Coccinelle installed
if ! command -v spatch &>/dev/null; then
  echo "[!] Error: 'spatch' (Coccinelle) is not installed."
  echo "Install: https://coccinelle.gitlabpages.inria.fr/website/download.html"
  exit 2
fi

# Clone patch repo if needed
if [[ ! -d "$PATCH_DIR_NAME" ]]; then
  echo "[+] Cloning patch repo: $PATCH_REPO_URL"
  git clone --depth=1 "$PATCH_REPO_URL" "$PATCH_DIR_NAME"
else
  echo "[=] Patch repo already exists: $PATCH_DIR_NAME"
fi

# Mode flags
MODE="ksu"
APPLY_STYLE="all" # all = search whole tree, map = target file mapping

# Detect mode flags
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -scope)
      MODE="scope"
      ;;
    -ksu)
      MODE="ksu"
      ;;
    -o)
      APPLY_STYLE="all"
      ;;
    -m)
      APPLY_STYLE="map"
      ;;
    -*)
      echo "[!] Unknown option: $1"
      exit 3
      ;;
    *)
      COCCI_LIST+=("$1")
      ;;
  esac
  shift
done

echo "[+] Kernel source: $KERNEL_DIR"
echo "[+] Mode: $MODE"
echo "[+] Apply style: $APPLY_STYLE"

# --- SCOPE MODE ---
if [[ "$MODE" == "scope" ]]; then
  PATCH_FILE="$PATCH_DIR_NAME/$SCOPE_PATCH"
  if [[ ! -f "$PATCH_FILE" ]]; then
    echo "[!] Scope patch not found: $PATCH_FILE"
    exit 4
  fi

  echo "[*] Applying scope-minimized patch to relevant dirs..."
  TARGETS=(
    fs
    drivers/input
    drivers/tty
    arch/arm/kernel
    kernel
    include/linux/cred.h
    security/selinux
  )

  for target in "${TARGETS[@]}"; do
    TARGET_PATH="$KERNEL_DIR/$target"
    if [[ -d "$TARGET_PATH" ]]; then
      echo "[→] Dir: $TARGET_PATH"
      spatch --sp-file "$PATCH_FILE" --dir "$TARGET_PATH" --in-place --linux-spacing
    elif [[ -f "$TARGET_PATH" ]]; then
      echo "[→] File: $TARGET_PATH"
      spatch --sp-file "$PATCH_FILE" --in-place --linux-spacing "$TARGET_PATH"
    else
      echo "[!] Skipping missing: $TARGET_PATH"
    fi
  done

  echo "[✓] Scope-minimized patching complete."
  exit 0
fi

# --- KSU MODE ---

# Predefined file mappings for each patch
declare -A PATCH_MAP=(
  [devpts_get_priv.cocci]="fs/devpts/inode.c"
  [execveat.cocci]="fs/exec.c"
  [faccessat.cocci]="fs/open.c"
  [input_handle_event.cocci]="drivers/input/input.c"
  [path_umount.cocci]="fs/namespace.c"
  [vfs_read.cocci]="fs/read_write.c"
  [vfs_statx.cocci]="fs/stat.c"
)

# If no patches specified, use all from repo
if [[ ${#COCCI_LIST[@]} -eq 0 ]]; then
  mapfile -t COCCI_LIST < <(find "$PATCH_DIR_NAME" -maxdepth 1 -name '*.cocci')
fi

echo "[+] Patches to apply: ${#COCCI_LIST[@]}"

for COCCI in "${COCCI_LIST[@]}"; do
  BASENAME=$(basename "$COCCI")
  FULL_PATH="$PATCH_DIR_NAME/$BASENAME"

  if [[ ! -f "$FULL_PATH" ]]; then
    echo "[!] Patch not found: $FULL_PATH"
    continue
  fi

  if [[ "$APPLY_STYLE" == "map" ]]; then
    TARGET_REL=${PATCH_MAP[$BASENAME]}
    if [[ -z "$TARGET_REL" ]]; then
      echo "[!] No mapping for $BASENAME, skipping"
      continue
    fi
    TARGET_PATH="$KERNEL_DIR/$TARGET_REL"
    echo "[*] Applying $BASENAME → $TARGET_PATH"
    spatch --sp-file "$FULL_PATH" --in-place --linux-spacing "$TARGET_PATH"
  else
    echo "[*] Applying $BASENAME → recursively to $KERNEL_DIR"
    spatch --sp-file "$FULL_PATH" --dir "$KERNEL_DIR" --in-place --linux-spacing
  fi
done

echo "[✓] All KernelSU patches applied."