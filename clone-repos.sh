#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/Developer/milroc"
PUBLIC_DIR="$BASE_DIR/public"
PRIVATE_DIR="$BASE_DIR/private"

info()    { printf "\033[0;34m[info]\033[0m %s\n" "$1"; }
success() { printf "\033[0;32m[ok]\033[0m %s\n" "$1"; }
warn()    { printf "\033[0;33m[warn]\033[0m %s\n" "$1"; }

# --- Auth check ---
if ! gh auth status &>/dev/null; then
  warn "Not logged in to GitHub CLI. Run: gh auth login"
  exit 1
fi
USERNAME=$(gh api user --jq .login)
info "Authenticated as $USERNAME"

# --- Fetch repos ---
info "Fetching repos from GitHub..."
REPOS_JSON=$(gh repo list --json name,visibility,sshUrl,isArchived --limit 1000)
REPO_COUNT=$(echo "$REPOS_JSON" | jq length)
info "Found $REPO_COUNT repos on GitHub"

# --- Compare local vs remote ---
to_clone=()
already=()
remote_names=()

while IFS=$'\t' read -r name visibility archived sshUrl; do
  remote_names+=("$name")

  if [ "$visibility" = "PUBLIC" ]; then
    parent="$PUBLIC_DIR"
  else
    parent="$PRIVATE_DIR"
  fi

  if [ "$archived" = "true" ]; then
    parent="$parent/archive"
  fi

  target="$parent/$name"

  if [ -d "$target" ]; then
    already+=("${target#"$BASE_DIR/"}")
  else
    to_clone+=("$sshUrl|$target|${target#"$BASE_DIR/"}")
  fi
done < <(echo "$REPOS_JSON" | jq -r '.[] | [.name, .visibility, (.isArchived | tostring), .sshUrl] | @tsv')

# --- Scan for local-only dirs ---
local_only=()
for search_dir in "$PUBLIC_DIR" "$PUBLIC_DIR/archive" "$PRIVATE_DIR" "$PRIVATE_DIR/archive"; do
  [ -d "$search_dir" ] || continue
  for dir in "$search_dir"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    # skip the archive dir itself when scanning public/ or private/
    [ "$name" = "archive" ] && continue
    found=false
    for rn in "${remote_names[@]}"; do
      if [ "$rn" = "$name" ]; then
        found=true
        break
      fi
    done
    if [ "$found" = false ]; then
      local_only+=("${dir#"$BASE_DIR/"}")
    fi
  done
done

# --- Dry-run summary ---
echo ""

if [ ${#already[@]} -gt 0 ]; then
  info "Already cloned (${#already[@]}):"
  for item in "${already[@]}"; do
    echo "  $item"
  done
  echo ""
fi

if [ ${#to_clone[@]} -gt 0 ]; then
  info "To clone (${#to_clone[@]}):"
  for entry in "${to_clone[@]}"; do
    IFS='|' read -r sshUrl target display <<< "$entry"
    echo "  $display  ($sshUrl)"
  done
  echo ""
fi

if [ ${#local_only[@]} -gt 0 ]; then
  warn "Local only — not on GitHub (${#local_only[@]}):"
  for item in "${local_only[@]}"; do
    echo "  $item"
  done
  echo ""
fi

# --- Early exit if nothing to clone ---
if [ ${#to_clone[@]} -eq 0 ]; then
  success "All repos already cloned. Nothing to do."
  exit 0
fi

# --- Confirm ---
read -rp "Clone ${#to_clone[@]} repos? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
  info "Aborted."
  exit 0
fi

# --- Clone ---
echo ""
for entry in "${to_clone[@]}"; do
  IFS='|' read -r sshUrl target display <<< "$entry"
  mkdir -p "$(dirname "$target")"
  info "Cloning $display..."
  git clone "$sshUrl" "$target"
  success "Cloned $display"
done

echo ""
success "Done! Cloned ${#to_clone[@]} repos."
