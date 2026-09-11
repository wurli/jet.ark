set -euo pipefail

# ─── config ────────────────────────────────────────────────────────────
ARK_VERSION="${ARK_VERSION:-0.1.252}"
R_VERSION="${R_VERSION:-4.5.0}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KERNELS_DIR="$REPO_ROOT/test-kernels"

# ─── R version check ───────────────────────────────────────────────────
# Tests capture ark's R startup banner in snapshots, so the R version
# has to match across local and CI. Fail fast with a clear message if
# it doesn't. We only warn if R is missing entirely — ark tests skip
# cleanly in that case.
if command -v R >/dev/null 2>&1; then
  actual_r=$(R --version 2>&1 | head -n1 | awk '{print $3}')
  if [[ "$actual_r" != "$R_VERSION" ]]; then
    echo "ERROR: R version mismatch — expected $R_VERSION, found $actual_r" >&2
    echo "  Install R $R_VERSION (e.g. via rig: 'rig add $R_VERSION')," >&2
    echo "  or override the pin with R_VERSION=$actual_r if you know what you're doing." >&2
    exit 1
  fi
  echo "==> R $actual_r matches pin"
else
  echo "==> R not on PATH; ark tests will skip"
fi

# ─── platform detection ────────────────────────────────────────────────
uname_s=$(uname -s)
uname_m=$(uname -m)
case "$uname_s-$uname_m" in
  Linux-x86_64)   ark_asset="ark-${ARK_VERSION}-linux-x64.zip" ;;
  Linux-aarch64)  ark_asset="ark-${ARK_VERSION}-linux-arm64.zip" ;;
  Darwin-arm64)   ark_asset="ark-${ARK_VERSION}-darwin-arm64.zip" ;;
  Darwin-x86_64)  ark_asset="ark-${ARK_VERSION}-darwin-x64.zip" ;;
  *) echo "unsupported platform: $uname_s-$uname_m" >&2; exit 1 ;;
esac


# ─── ark ───────────────────────────────────────────────────────────────
ark_dir="$KERNELS_DIR/ark"
ark_bin="$ark_dir/ark"
if [[ -x "$ark_bin" ]] && [[ "$("$ark_bin" --version 2>/dev/null || true)" == *"$ARK_VERSION"* ]]; then
  echo "==> ark ${ARK_VERSION} already installed at $ark_bin"
else
  echo "==> downloading ark ${ARK_VERSION} ($ark_asset)"
  mkdir -p "$ark_dir"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL -o "$tmp/ark.zip" \
    "https://github.com/posit-dev/ark/releases/download/${ARK_VERSION}/${ark_asset}"
  unzip -q -o "$tmp/ark.zip" -d "$ark_dir"
  chmod +x "$ark_bin"
  rm -rf "$tmp"
  trap - EXIT
fi

cat >"$ark_dir/kernel.json" <<JSON
{
  "argv": [
    "$ark_bin",
    "--connection_file",
    "{connection_file}",
    "--session-mode",
    "notebook",
    "--log",
    "$ark_dir/ark.log",
    "--",
    "--quiet"
  ],
  "display_name": "Ark R Kernel",
  "language": "R",
  "env": {
    "RUST_LOG": "error"
  }
}
JSON
echo "==> wrote $ark_dir/kernel.json"

# ─── summary ───────────────────────────────────────────────────────────
echo
echo "Kernels ready under $KERNELS_DIR:"
ls "$KERNELS_DIR"
echo
echo "Run tests with:"
echo "  JUPYTER_PATH=$REPO_ROOT cargo test --workspace"
