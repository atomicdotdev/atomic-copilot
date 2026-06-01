#!/usr/bin/env node

/**
 * atomic-copilot install
 *
 * Installs Atomic hooks for GitHub Copilot. Since Copilot hooks must be
 * in the repo's .github/hooks/ directory (and on the default branch for
 * cloud agent), this installer copies files rather than symlinking.
 *
 * Usage:
 *   npx atomic-copilot            # install to current project
 *   node install.js               # install to current project
 *   node install.js --silent      # postinstall
 *   node install.js --uninstall   # remove hooks from current project
 */

const fs = require("fs");
const path = require("path");

const silent = process.argv.includes("--silent");
const uninstall = process.argv.includes("--uninstall");

const PKG_DIR = __dirname;
const PROJECT_ROOT = process.cwd();
const HOOKS_DIR = path.join(PROJECT_ROOT, ".github", "hooks");
const HOOKS_FILE = path.join(HOOKS_DIR, "atomic-hooks.json");
const INSTRUCTIONS_FILE = path.join(
  PROJECT_ROOT,
  ".github",
  "copilot-instructions.md",
);
const ATOMIC_PREFIX = "atomic agent hooks copilot";

function doInstall() {
  // Copilot hooks live in a dedicated, project-local file
  // (.github/hooks/atomic-hooks.json) committed to the repo. The hook
  // definitions ship in this package — we copy them in directly, so there is
  // no dependency on the `atomic` binary's hook wiring and no rebuild needed
  // when Copilot changes its hook schema.

  // Ensure hooks directory exists and copy hooks file
  if (!fs.existsSync(HOOKS_DIR)) {
    fs.mkdirSync(HOOKS_DIR, { recursive: true });
  }

  const srcHooks = path.join(PKG_DIR, "hooks", "atomic-hooks.json");
  if (fs.existsSync(srcHooks)) {
    if (
      !fs.existsSync(HOOKS_FILE) ||
      !fs.readFileSync(HOOKS_FILE, "utf8").includes(ATOMIC_PREFIX)
    ) {
      fs.copyFileSync(srcHooks, HOOKS_FILE);
      if (!silent)
        console.log("  hooks: copied atomic-hooks.json to .github/hooks/");
    } else {
      if (!silent) console.log("  hooks: already installed");
    }
  }

  if (!silent) {
    console.log();
    console.log("✓ atomic-copilot installed to current project");
    console.log();
    console.log("  Next steps:");
    console.log(
      `    cp ${path.join(PKG_DIR, "copilot-instructions.md")} .github/copilot-instructions.md`,
    );
    console.log(`    cp ${path.join(PKG_DIR, "AGENTS.md")} .`);
    console.log(
      "    git add .github/hooks/ .github/copilot-instructions.md AGENTS.md",
    );
    console.log("    git commit -m 'Add Atomic VCS hooks for GitHub Copilot'");
    console.log();
    console.log("  Note: Hooks must be on the default branch for cloud agent.");
    console.log();
  }
}

function doUninstall() {
  if (fs.existsSync(HOOKS_FILE)) {
    fs.unlinkSync(HOOKS_FILE);
    if (!silent) console.log("  hooks: removed atomic-hooks.json");
  }

  // Clean up empty hooks directory
  if (fs.existsSync(HOOKS_DIR)) {
    try {
      fs.rmdirSync(HOOKS_DIR);
    } catch {
      /* not empty */
    }
  }

  if (!silent) {
    console.log();
    console.log("✓ atomic-copilot uninstalled");
    console.log(
      "  Note: copilot-instructions.md and AGENTS.md must be removed manually.",
    );
  }
}

if (uninstall) {
  doUninstall();
} else {
  doInstall();
}
