# commit-and-push

You are an operator that will **draft a Conventional Commit message**, then **commit** the staged changes and **push** them.

## Inputs
- Treat any free text the user types after `/commit-and-push` as **hints** (e.g., desired scope, ticket IDs, or "dry-run").
- Only commit **staged** changes. If none are staged, ask once whether to `git add -A` and proceed.

## Plan
1) Collect context (read-only first; ask before running commands):
   - `git status --porcelain=v1`
   - `git --no-pager diff --staged`
   - `git rev-parse --abbrev-ref HEAD`          # current branch
   - `git remote -v`                             # discover push remote

2) Infer commit pieces from the staged diff + hints:
   - **type**: feat | fix | perf | refactor | docs | test | build | ci | style | chore | revert
   - **scope**: dominant folder/package (e.g., `api`, `web`, `infra`, `db`, `auth`)
   - **breaking?**: if API/CLI/DB contracts changed, mark `!` and add a `BREAKING CHANGE:` footer
   - **issues**: extract `ABC-123`, `#123`, or IDs from the branch name; add to `Closes:` or `Refs:`
   - Follow the **50/72** rule (≤50-char header; ~72-wrapped body)

3) Build the final message (no surrounding quotes):
   Header: `<type>(<scope>)<!?>: <summary>`
   Body: why + impact, bullets for key changes, risks, follow-ups
   Footers (as needed): 
     - `BREAKING CHANGE: ...`
     - `Closes: <#issue or ABC-123>`
     - `Refs: <#issue or ABC-123>`
     - `Co-authored-by: Name <email>`

4) Show the exact commit message to the user for a quick glance. 
   If the user typed "dry-run", **stop here** after showing the message and propose the commit/push commands you would run.

5) Commit & push (ask once to approve running commands):
   - Write the message to a temp file at **`.git/AI_COMMITMSG`** (use an OS-appropriate method).
   - If no staged changes: offer to `git add -A` and continue, or abort politely.
   - Run:
     - `git commit -F .git/AI_COMMITMSG`
     - Determine upstream:
         * If upstream is set: `git push`
         * Else: pick `origin` if present and run `git push -u origin $(git rev-parse --abbrev-ref HEAD)`
   - On failure:
     - If hooks/pre-commit fail: show output and ask whether to retry with fixes (never auto `--no-verify`).
     - If no remote exists: ask whether to create one and provide the exact `git remote add origin <URL>` and push command.
     - If repo is empty (initial commit), include `-u` form.

6) Clean up:
   - Remove `.git/AI_COMMITMSG`
   - Print `git show --name-status --oneline -1` to confirm the commit.

## Output rules
- Be concise. After push, print the short SHA, branch, and remote.
- If you staged nothing and declined staging, say so briefly.
- Do **not** include extra commentary once the commit summary and confirmation are printed.