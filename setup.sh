#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Equinox Technology — One-Command Claude Code Setup
# ═══════════════════════════════════════════════════════════════
# No admin access required. Everything installs to your home folder.
# Usage: bash setup.sh <your-gateway-key>

set -e

GATEWAY_KEY="${1}"
WORKSPACE="$HOME/equinox-workspace"
GATEWAY_URL="https://api.equinoxcell.com"
NVM_DIR="$HOME/.nvm"

# ─── Validation ──────────────────────────────────────────────────
if [ -z "$GATEWAY_KEY" ]; then
  echo ""
  echo "  ╔═══════════════════════════════════════════╗"
  echo "  ║   EQUINOX — Claude Code Setup             ║"
  echo "  ╚═══════════════════════════════════════════╝"
  echo ""
  echo "  Usage: bash setup.sh <your-gateway-key>"
  echo ""
  echo "  Your key looks like: eqx_yourname_abc123..."
  echo "  Get it from Laurent on Slack."
  echo ""
  exit 1
fi

if [[ ! "$GATEWAY_KEY" =~ ^eqx_ ]]; then
  echo ""
  echo "  Error: Invalid key. Gateway keys start with 'eqx_'"
  echo "  Example: eqx_ian_c5859895d2f5f95326f5489ce8927921"
  echo ""
  exit 1
fi

# Extract name from key (eqx_NAME_hex)
EMP_NAME=$(echo "$GATEWAY_KEY" | sed 's/eqx_//;s/_[a-f0-9]*$//')

echo ""
echo "  ╔═══════════════════════════════════════════╗"
echo "  ║   EQUINOX — Setting up for: $EMP_NAME"
echo "  ╚═══════════════════════════════════════════╝"
echo ""

# ─── Step 1: Ensure Node.js is available ─────────────────────────
echo "  [1/8] Checking Node.js..."
if command -v node &> /dev/null; then
  NODE_VERSION=$(node -v 2>/dev/null)
  echo "         Node.js $NODE_VERSION found ✓"
else
  echo "         Node.js not found — installing via nvm (no admin needed)..."
  # Install nvm to home directory (no admin required)
  curl -sf -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash 2>/dev/null

  # Load nvm immediately
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  if command -v nvm &> /dev/null; then
    nvm install --lts 2>/dev/null
    nvm use --lts 2>/dev/null
    echo "         Node.js $(node -v) installed via nvm ✓"
  else
    echo ""
    echo "  Error: Could not install nvm/Node.js."
    echo "  Ask Laurent or IT to run: brew install node"
    echo ""
    exit 1
  fi
fi

# Make sure nvm is loaded if it exists (for npm/npx)
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh" 2>/dev/null
fi

# ─── Step 2: Ensure Claude Code is available ─────────────────────
echo "  [2/8] Checking Claude Code..."
if command -v claude &> /dev/null; then
  echo "         Claude Code already installed ✓"
else
  echo "         Installing Claude Code..."
  # Try npm global install first (works if user has write access to npm prefix)
  npm install -g @anthropic-ai/claude-code 2>/dev/null && {
    echo "         Claude Code installed ✓"
  } || {
    # Fallback: install locally and add to PATH
    echo "         Global install failed (no admin) — installing locally..."
    mkdir -p "$HOME/.local/bin"
    npm install --prefix "$HOME/.local/lib/claude-code" @anthropic-ai/claude-code 2>/dev/null

    # Create wrapper script
    cat > "$HOME/.local/bin/claude" << 'CLEOF'
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 2>/dev/null
NODE=$(command -v node)
CLAUDE_DIR="$HOME/.local/lib/claude-code/node_modules/@anthropic-ai/claude-code"
if [ -f "$CLAUDE_DIR/cli.js" ]; then
  exec "$NODE" "$CLAUDE_DIR/cli.js" "$@"
elif [ -f "$CLAUDE_DIR/dist/cli.js" ]; then
  exec "$NODE" "$CLAUDE_DIR/dist/cli.js" "$@"
else
  echo "Error: Claude Code not found. Run the setup script again."
  exit 1
fi
CLEOF
    chmod +x "$HOME/.local/bin/claude"

    # Add to PATH in shell profiles
    for profile in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
      if [ -f "$profile" ] || [ "$(basename "$profile")" = ".zshrc" ]; then
        if ! grep -q '.local/bin' "$profile" 2>/dev/null; then
          echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
        fi
      fi
    done
    export PATH="$HOME/.local/bin:$PATH"

    if command -v claude &> /dev/null || [ -x "$HOME/.local/bin/claude" ]; then
      echo "         Claude Code installed locally ✓"
    else
      echo ""
      echo "  Error: Could not install Claude Code."
      echo "  Download manually from: https://claude.ai/download"
      echo "  Then run this script again."
      echo ""
      exit 1
    fi
  }
fi

# ─── Step 3: Create workspace ────────────────────────────────────
echo "  [3/8] Creating workspace..."
mkdir -p "$WORKSPACE/.claude"
mkdir -p "$WORKSPACE/.memsearch/memory"
mkdir -p "$WORKSPACE/outputs"
mkdir -p "$WORKSPACE/logs"

# Initialize memory index
if [ ! -f "$WORKSPACE/.memsearch/memory/MEMORY.md" ]; then
  cat > "$WORKSPACE/.memsearch/memory/MEMORY.md" << 'MEMEOF'
# Memory Index

## Notes
- Memory files are stored here automatically by Claude
- Each session creates/updates daily logs in this directory
MEMEOF
fi

echo "         $WORKSPACE ✓"

# ─── Step 4: Validate gateway key ────────────────────────────────
echo "  [4/8] Validating your gateway key..."
VALIDATE=$(curl -sf -H "x-gateway-key: $GATEWAY_KEY" "$GATEWAY_URL/api/services" 2>/dev/null) || true
if [ -z "$VALIDATE" ] || echo "$VALIDATE" | grep -q '"error"'; then
  echo "         Warning: Could not validate key — continuing setup."
else
  SERVICE_COUNT=$(echo "$VALIDATE" | python3 -c "import sys,json;print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
  echo "         Key valid — access to $SERVICE_COUNT services ✓"
fi

# ─── Step 5: Download CLAUDE.md ──────────────────────────────────
echo "  [5/8] Downloading workspace config..."
curl -sf "$GATEWAY_URL/setup/claude-md" -H "x-gateway-key: $GATEWAY_KEY" > "$WORKSPACE/.claude/CLAUDE.md" 2>/dev/null && {
  echo "         CLAUDE.md downloaded ✓"
} || {
  echo "         Warning: Could not download CLAUDE.md — ask Laurent"
}

# ─── Step 6: Save gateway key to .env ────────────────────────────
echo "  [6/8] Saving credentials..."
cat > "$WORKSPACE/.env" << ENVEOF
# ═══════════════════════════════════════════════════════════════
# Equinox Technology — $EMP_NAME's Gateway Key
# ═══════════════════════════════════════════════════════════════
# This is YOUR personal API key. Never share it.
# If compromised, tell Laurent immediately — he'll revoke and reissue.

EQX_GATEWAY_KEY=$GATEWAY_KEY
EQX_GATEWAY_URL=$GATEWAY_URL
ENVEOF
echo "         Gateway key saved ✓"

# ─── Step 7: Install Equinox MCP Server ──────────────────────────
echo "  [7/8] Installing MCP server (29 tools)..."
mkdir -p "$WORKSPACE/mcp-server"
curl -sf "$GATEWAY_URL/setup/mcp-server" -H "x-gateway-key: $GATEWAY_KEY" > "$WORKSPACE/mcp-server/index.js" 2>/dev/null || {
  echo "         Warning: Could not download MCP server"
}
cat > "$WORKSPACE/mcp-server/package.json" << 'PKGJSON'
{"name":"equinox-mcp","version":"1.0.0","dependencies":{"@modelcontextprotocol/sdk":"^1.0.0"}}
PKGJSON
cd "$WORKSPACE/mcp-server" && npm install --silent 2>/dev/null && echo "         MCP server installed ✓" || echo "         Warning: MCP install failed — run 'cd ~/equinox-workspace/mcp-server && npm install'"
cd "$WORKSPACE"

# ─── Step 8: Configure Claude Code + helpers ─────────────────────
echo "  [8/8] Configuring Claude Code..."

# Find node path (might be nvm or system)
NODE_PATH=$(command -v node)

cat > "$WORKSPACE/.claude/settings.json" << SETTINGSEOF
{
  "permissions": {
    "allow": [
      "Bash(npm *)",
      "Bash(node *)",
      "Bash(curl *)",
      "Bash(git *)",
      "Bash(./gateway.sh *)",
      "Bash(python3 *)",
      "Read",
      "Write",
      "Edit",
      "Grep",
      "Glob",
      "mcp__equinox-gateway"
    ]
  },
  "mcpServers": {
    "equinox-gateway": {
      "command": "$NODE_PATH",
      "args": ["$WORKSPACE/mcp-server/index.js"],
      "env": {
        "EQX_GATEWAY_KEY": "$GATEWAY_KEY",
        "EQX_GATEWAY_URL": "$GATEWAY_URL"
      }
    }
  }
}
SETTINGSEOF

# Gateway helper script
cat > "$WORKSPACE/gateway.sh" << 'GWEOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/.env"

if [ "$1" = "list" ] || [ -z "$1" ]; then
  echo ""
  echo "  Available services:"
  echo "  ─────────────────────────────────────────"
  curl -s -H "x-gateway-key: $EQX_GATEWAY_KEY" \
    "$EQX_GATEWAY_URL/api/services" | python3 -c "
import sys,json
for s in json.load(sys.stdin):
    print(f\"  {s['id']:<30s} {s['name']}\")
" 2>/dev/null || echo "  Error: Could not connect to gateway"
  echo ""
  exit 0
fi

SERVICE="$1"
shift
API_PATH="$*"

if [ -z "$API_PATH" ]; then
  echo "Usage: ./gateway.sh <service> <path>"
  echo "Example: ./gateway.sh tph-shopify orders.json"
  exit 1
fi

curl -s -H "x-gateway-key: $EQX_GATEWAY_KEY" \
  "$EQX_GATEWAY_URL/api/proxy/$SERVICE/$API_PATH" | python3 -m json.tool
GWEOF
chmod +x "$WORKSPACE/gateway.sh"

# README
cat > "$WORKSPACE/README.md" << 'READMEEOF'
# Equinox Workspace

## Quick Start
```bash
claude                    # Start Claude Code
./gateway.sh list         # See all services
./gateway.sh tph-shopify orders.json   # Pull TPH orders
```

## Dashboard
https://api.equinoxcell.com (sign in with your @equinoxcell.com Google account)

## Rules
- Never share your gateway key (`.env`)
- Never hardcode credentials in scripts
- Ask Claude for help — that's what it's here for
READMEEOF

echo "         Configured ✓"

# ─── Done ────────────────────────────────────────────────────────
echo ""
echo "  ╔═══════════════════════════════════════════╗"
echo "  ║   Setup complete!                         ║"
echo "  ╚═══════════════════════════════════════════╝"
echo ""
echo "  Start working:"
echo "    cd ~/equinox-workspace"
echo "    claude"
echo ""
echo "  If 'claude' is not found, restart Terminal first."
echo ""
echo "  Dashboard:"
echo "    https://api.equinoxcell.com"
echo ""
