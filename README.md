# atomic-copilot

[Atomic VCS](https://atomic.dev) integration for [GitHub Copilot](https://github.com/features/copilot) (cloud agent + CLI).

> **Definitive source:** this repository lives on Atomic storage at `https://atomic.atomic.storage/workspaces/oss/projects/atomic-copilot/code`. The GitHub repo is a mirror.

Automatic turn recording with AI provenance, intent tracking, and knowledge graph skills.

## What it does

- **1 session = 1 view** — a draft view is created automatically when a Copilot session starts
- **Every session records with provenance** — model, vendor, session, timing
- **Tool executions tracked** — shell commands captured in a causal decision graph
- **Intent workflow** — AGENTS.md and copilot-instructions.md guide problem-first development

## Install

### Quick start

```bash
git clone https://github.com/atomicdotdev/atomic-copilot
cd atomic-copilot
./install.sh
```

### Set up a project

```bash
cd my-project
atomic init                    # if not already an atomic repo

# Copy hooks (must be on default branch for cloud agent)
mkdir -p .github/hooks
cp /path/to/atomic-copilot/hooks/atomic-hooks.json .github/hooks/

# Copy instructions
cp /path/to/atomic-copilot/copilot-instructions.md .github/
cp /path/to/atomic-copilot/AGENTS.md .

# Commit to default branch
git add .github/hooks/ .github/copilot-instructions.md AGENTS.md
git commit -m "Add Atomic VCS hooks for GitHub Copilot"
```

## Prerequisites

- [Atomic VCS](https://atomic.dev) installed and on your PATH (`atomic --version`)
- A project with an `.atomic/` repository (`atomic init`)
- GitHub Copilot (cloud agent or CLI)

## Current limitations

- No `stop` event — changes are recorded on `sessionEnd` (one change per session)
- `postToolUse` currently provides limited tool output data
- Hooks must be committed to the default branch for cloud agent
- Full JSON input/output schemas are not yet published by GitHub

## How hooks work

Copilot reads hooks from `.github/hooks/*.json`. The Atomic hooks call back to `atomic agent hooks copilot <verb>`:

```
Copilot session start
  │
  ├── sessionStart → Rust creates haikunator-named draft view
  │
  ├── User sends prompt
  │   ├── userPromptSubmitted → Rust saves prompt + model on session
  │   ├── Agent works (shell commands, file edits)
  │   │   └── postToolUse → Rust appends to provenance graph
  │   └── (no stop event — continues until session ends)
  │
  ├── User sends another prompt → repeat
  │
  └── Session ends
      └── sessionEnd → Rust records all changes with provenance
```

## Uninstall

```bash
rm .github/hooks/atomic-hooks.json
rm .github/copilot-instructions.md
rm AGENTS.md
```

## License

Apache-2.0 — same as [Atomic VCS](https://github.com/atomicdotdev/atomic).
