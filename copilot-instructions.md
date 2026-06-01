# Atomic VCS

This project uses **Atomic VCS** (not git) for version control. A draft view is created for each agent session automatically.

## Key Rules

- **Do NOT run `git` commands.** This project uses `atomic` instead.
- **Do NOT run `atomic add` or `atomic record`.** The hook system records changes automatically with full AI provenance.
- **Do NOT create or switch views.** The session view is created automatically.

## Intent Workflow

Every prompt should follow the intent-per-turn workflow:

1. Create an intent: `atomic vault intent create --title "<short title>"`
2. Define the problem — reframe solution-requests as problems
3. Write the plan into the intent file before coding
4. Run `atomic vault sync` after editing the intent file, and always before `intent show`/`update` (the CLI reads the DB, not the file; an unsynced `update` clobbers your edits)
5. Execute the tasks
6. Update the intent: `atomic vault sync` then `atomic vault intent update <ID> --status done`
