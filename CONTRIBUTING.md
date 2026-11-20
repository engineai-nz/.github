# Contributing to Engine AI repos

Engine AI is a two-founder shop. Most repos are internal, some are client work. This file sets the baseline for anyone contributing, including us.

## Before you start

1. Read the `HOW_WE_BUILD.md` in the specific repo. It has the rules calibrated to that project.
2. Read `docs/brief.md` and `docs/master-spec.md` in that repo so you understand what you're changing.
3. Check `docs/DECISIONS.md` — if a decision has already been made about something, don't relitigate it. Propose a supersede entry if you disagree.

## The golden path

1. Clarify the problem before writing code.
2. Create a Linear slice issue, one per reviewable PR. Link the Notion page if there is one.
3. Branch per slice: `eng-<slice-id>-<slug>`. Use the slice ID, never the parent or epic ID.
4. Open a draft PR early. Link issues in the PR body as described in [Linear links](#linear-links).
5. Validate against acceptance criteria.
6. At least one founder approves.
7. Squash-merge.

## Pull requests

- Use the PR template in the repo (or the org-level default).
- Title format: `[ENG-123] Short action-focused description`, with the slice ID only.
- Every PR gets a `risk/` label and an `ai/` label.
- Checks must pass.

## Linear links

Linear auto-closes parent issues once all their sub-issues are done; sub-issues do not auto-close when the parent does. When a PR merges to `main`, Linear moves every issue the PR body links with a closing keyword (`Closes`, `Fixes`, `Resolves`) to `Done` within seconds. Plain English such as "please don't close" does not stop it.

- `Closes ENG-<slice>` only when the merge completes that slice.
- `Part of ENG-<id>` for a parent, an epic, or a slice the merge leaves unfinished. Never put a closing keyword on a parent.
- `skip ENG-<id>` to mention an issue without linking it.

Merged with a closing link means `Done`. Never merge partial work under a closing link and reopen the issue afterwards. Before merging, split leftover work into a new slice issue, or drop the closing keyword. Record post-merge deploy and verification readback as comments on the closed slice or the PR. If post-merge work or a rollback is needed, open a new follow-up issue.

When you close a PR without merging, move its Linear issue out of `In Progress` or `In Review` in the same session: to `Todo`, or to `Canceled` with a note.

## Risky changes

If the PR touches auth, billing, migrations, destructive scripts, infra, secrets, or user data deletion, it is a risky change. The Risky Change Checklist must be completed in full. Both founders must approve. No exceptions.

## AI usage

We use AI heavily. We don't ship AI-generated code we don't understand, especially on risky paths. If a line is opaque, one of us walks the other through it before merge.

## Outside contributors

If you're not Ben or Joe and you want to contribute, open an issue first and tag a founder. We'll tell you whether the PR is worth your time before you spend it.
