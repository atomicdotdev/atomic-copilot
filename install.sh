#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing atomic-copilot..."

# 1. Install hooks via atomic CLI (to project .github/hooks/)
if command -v atomic &>/dev/null; then
  atomic agent enable --agent copilot 2>/dev/null && echo "  hooks: installed into .github/hooks/" || echo "  hooks: manual install needed"
else
  echo "  Warning: 'atomic' not found on PATH."
  echo "  Install Atomic VCS first, then run: atomic agent enable --agent copilot"
fi

echo ""
echo "✓ Installed atomic-copilot"
echo ""
echo "  To set up a project:"
echo "    1. Copy hooks:        mkdir -p .github/hooks && cp $SCRIPT_DIR/hooks/atomic-hooks.json .github/hooks/"
echo "    2. Copy instructions: cp $SCRIPT_DIR/copilot-instructions.md .github/copilot-instructions.md"
echo "    3. Copy agent file:   cp $SCRIPT_DIR/AGENTS.md ."
echo "    4. Commit to default branch (required for cloud agent)"
echo ""
echo "  Note: Hooks must be on the default branch for Copilot cloud agent."
echo "  For Copilot CLI, hooks are loaded from the current working directory."
