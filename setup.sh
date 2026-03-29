#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Equinox Technology — One-Command Claude Code Setup
# ═══════════════════════════════════════════════════════════════
# Usage: bash setup.sh <your-gateway-key>
# Example: bash setup.sh eqx_ian_5042947af7204afd1da772a4926f6e6d

set -e

GATEWAY_KEY="${1}"
WORKSPACE="$HOME/equinox-workspace"
GATEWAY_URL="https://api.equinoxcell.com"

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
  echo "  Example: eqx_ian_5042947af7204afd1da772a4926f6e6d"
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

# ─── Step 1: Check/Install Claude Code ───────────────────────────
echo "  [1/7] Checking Claude Code..."
if command -v claude &> /dev/null; then
  echo "         Claude Code already installed ✓"
else
  echo "         Installing Claude Code..."
  if command -v npm &> /dev/null; then
    npm install -g @anthropic-ai/claude-code 2>/dev/null && echo "         Installed via npm ✓" || {
      echo ""
      echo "  Error: Could not install Claude Code."
      echo "  Install manually: npm install -g @anthropic-ai/claude-code"
      echo "  Or download from: https://claude.ai/download"
      echo ""
      exit 1
    }
  elif command -v brew &> /dev/null; then
    brew install claude-code 2>/dev/null && echo "         Installed via Homebrew ✓" || {
      echo ""
      echo "  Error: Could not install Claude Code."
      echo "  Install manually: brew install claude-code"
      echo "  Or download from: https://claude.ai/download"
      echo ""
      exit 1
    }
  else
    echo ""
    echo "  Error: npm or Homebrew not found."
    echo "  Install Claude Code manually from: https://claude.ai/download"
    echo "  Then run this script again."
    echo ""
    exit 1
  fi
fi

# ─── Step 2: Create workspace ────────────────────────────────────
echo "  [2/7] Creating workspace..."
mkdir -p "$WORKSPACE/.claude"
echo "         $WORKSPACE ✓"

# ─── Step 3: Validate gateway key ────────────────────────────────
echo "  [3/7] Validating your gateway key..."
VALIDATE=$(curl -sf -H "x-gateway-key: $GATEWAY_KEY" "$GATEWAY_URL/api/services" 2>/dev/null) || true
if [ -z "$VALIDATE" ] || echo "$VALIDATE" | grep -q '"error"'; then
  echo ""
  echo "  Warning: Could not validate key against gateway."
  echo "  The key might still work — continuing setup."
  echo "  If issues persist, check with Laurent."
  echo ""
else
  SERVICE_COUNT=$(echo "$VALIDATE" | python3 -c "import sys,json;print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
  echo "         Key valid — access to $SERVICE_COUNT services ✓"
fi

# ─── Step 4: Download CLAUDE.md ──────────────────────────────────
echo "  [4/7] Downloading workspace config..."
curl -sf "$GATEWAY_URL/setup/claude-md" -H "x-gateway-key: $GATEWAY_KEY" > "$WORKSPACE/.claude/CLAUDE.md" 2>/dev/null && {
  echo "         CLAUDE.md downloaded ✓"
} || {
  echo "         Warning: Could not download CLAUDE.md"
  echo "         Ask Laurent for the file"
}

# ─── Step 5: Save gateway key to .env ────────────────────────────
echo "  [5/7] Saving credentials..."
cat > "$WORKSPACE/.env" << ENVEOF
# ═══════════════════════════════════════════════════════════════
# Equinox Technology — $EMP_NAME's Gateway Key
# ═══════════════════════════════════════════════════════════════
# This is YOUR personal API key. Never share it.
# If compromised, tell Laurent immediately — he'll revoke and reissue.

EQX_GATEWAY_KEY=$GATEWAY_KEY
EQX_GATEWAY_URL=$GATEWAY_URL
ENVEOF
echo "         Gateway key saved to .env ✓"

# ─── Step 6: Install Equinox MCP Server ──────────────────────────
echo "  [6/8] Installing Equinox MCP server..."
mkdir -p "$WORKSPACE/mcp-server"
curl -sf "$GATEWAY_URL/setup/mcp-server" -H "x-gateway-key: $GATEWAY_KEY" > "$WORKSPACE/mcp-server/index.js" 2>/dev/null || {
  if [ -f "$(dirname "$0")/../equinox-mcp-server/index.js" ]; then
    cp "$(dirname "$0")/../equinox-mcp-server/index.js" "$WORKSPACE/mcp-server/index.js"
  else
    echo "         Warning: Could not download MCP server"
  fi
}
cat > "$WORKSPACE/mcp-server/package.json" << 'PKGJSON'
{"name":"equinox-mcp","version":"1.0.0","dependencies":{"@modelcontextprotocol/sdk":"^1.0.0"}}
PKGJSON
cd "$WORKSPACE/mcp-server" && npm install --silent 2>/dev/null && echo "         MCP server installed ✓" || echo "         Warning: run 'cd ~/equinox-workspace/mcp-server && npm install'"
cd "$WORKSPACE"

# ─── Step 7: Create Claude Code settings ─────────────────────────
echo "  [7/8] Configuring Claude Code + MCP..."
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
      "command": "node",
      "args": ["$WORKSPACE/mcp-server/index.js"],
      "env": {
        "EQX_GATEWAY_KEY": "$GATEWAY_KEY",
        "EQX_GATEWAY_URL": "$GATEWAY_URL"
      }
    }
  }
}
SETTINGSEOF
echo "         Claude Code + MCP configured ✓"

# ─── Step 8: Create helper scripts ───────────────────────────────
echo "  [8/8] Creating helper scripts..."

# Gateway helper
cat > "$WORKSPACE/gateway.sh" << 'GWEOF'
#!/bin/bash
# ═══════════════════════════════════════════════
# Equinox Gateway Helper
# ═══════════════════════════════════════════════
# Usage:
#   ./gateway.sh tph-shopify orders.json
#   ./gateway.sh sohnne-woo-read-only wp-json/wc/v3/orders
#   ./gateway.sh sohnne-ga4 properties/321024703:runReport
#   ./gateway.sh list                    (show all services)

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
  echo "  Usage: ./gateway.sh <service-id> <api-path>"
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
claude                    # Start Claude Code (AI assistant)
./gateway.sh list         # See all services you have access to
./gateway.sh tph-shopify orders.json   # Pull TPH orders
```

## Dashboard
https://api.equinoxcell.com (sign in with your @equinoxcell.com Google account)

## Rules
- Never share your gateway key (`.env`)
- Never hardcode credentials in scripts
- Ask Claude for help — that's what it's here for
READMEEOF

echo "         Helper scripts created ✓"

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
echo "  Test your access:"
echo "    ./gateway.sh list"
echo "    ./gateway.sh tph-shopify shop.json"
echo ""
echo "  Dashboard:"
echo "    https://api.equinoxcell.com"
echo ""
