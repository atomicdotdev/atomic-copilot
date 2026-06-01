#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(pwd)"
HOOKS_SRC="$SCRIPT_DIR/hooks/atomic-hooks.json"
HOOKS_DST="$PROJECT_ROOT/.github/hooks/atomic-hooks.json"

# 1. Install hooks by copying the bundled definitions into the project's
#    .github/hooks/. Copilot hooks are a dedicated, project-local file that is
#    committed to the repo (and required on the default branch for the cloud
#    agent). The hook definitions ship in this package, so there's no
#    dependency on the `atomic` binary's hook wiring and no rebuild needed when
#    Copilot changes its hook schema.
if [ "$PROJECT_ROOT" = "$SCRIPT_DIR" ]; then
  HOOKS_STATUS="SKIPPED — run this from your project root (not the package dir)"
elif [ -f "$HOOKS_SRC" ]; then
  mkdir -p "$PROJECT_ROOT/.github/hooks"
  cp "$HOOKS_SRC" "$HOOKS_DST"
  HOOKS_STATUS="copied to .github/hooks/atomic-hooks.json"
  echo "  hooks: copied atomic-hooks.json to .github/hooks/"
else
  HOOKS_STATUS="FAILED — bundled hooks/atomic-hooks.json not found"
fi

cat <<EOF

────────────────────────────────────────────────────────────
✓ Installed atomic-copilot
────────────────────────────────────────────────────────────

What was installed:
  • Hooks      ${HOOKS_STATUS}
               → <project>/.github/hooks/atomic-hooks.json (copied from this
                 package's hooks/atomic-hooks.json; entries call
                 'atomic agent hooks copilot'). Definitions live in
                 ${HOOKS_SRC}
  • Skills     bundled with this package — not symlinked
               → ${SCRIPT_DIR}/skills/  (atomic-vault, atomic-vcs, code-intelligence)
               Copilot has no global skills dir; the skills ship inside the
               package and are pulled in on demand via the references in AGENTS.md.

Manual steps to finish (per project):
  1. (If you ran this outside your project) copy the hooks into the project:
       mkdir -p .github/hooks
       cp "${SCRIPT_DIR}/hooks/atomic-hooks.json" .github/hooks/
  2. Copy the Copilot instructions and base agent prompt to the project:
       cp "${SCRIPT_DIR}/copilot-instructions.md" .github/copilot-instructions.md
       cp "${SCRIPT_DIR}/AGENTS.md" .
  3. Ensure the project is an Atomic repo (one-time):
       atomic init
  4. Commit the artifacts to the default branch — required for the Copilot cloud agent:
       git add .github/hooks/ .github/copilot-instructions.md AGENTS.md
       git commit -m "Add Atomic VCS hooks for GitHub Copilot"
     For the Copilot CLI, hooks load from the current working directory, so a
     commit to the default branch is not strictly required there.

Verify:
  • Hooks:        ls .github/hooks/atomic-hooks.json && echo OK
  • Instructions: ls .github/copilot-instructions.md AGENTS.md && echo OK
  • Skills:       referenced from AGENTS.md (/atomic-vault, /atomic-vcs, /code-intelligence)

Uninstall:
  ./install.sh is install-only; to remove run (from the project):
    node install.js --uninstall
────────────────────────────────────────────────────────────
EOF
