<!--
Engine AI PR Template

For standard PRs, fill in every section.
For tiny changes (typos, copy tweaks, lint-only, doc-only, dep bumps), delete the standard sections and use the Light PR block at the bottom.
-->

## What changed
<!-- One or two sentences. What is different after this PR? -->

## Why
<!-- What problem this solves. Link the Notion spec if one exists. -->

## Linked issue
<!--
PR title and branch carry the slice Linear ID only: `[ENG-123] ...` and `eng-123-slug`. Never the parent or epic ID.
Linear moves every issue linked with a closing keyword (Closes, Fixes, Resolves) to Done seconds after merge to main. Plain English such as "don't close" does not stop it.
Keep one line per issue, and pick per issue:
- `Closes ENG-<slice>` only when this merge completes that slice.
- `Part of ENG-<id>` for a parent, an epic, or a slice this merge leaves unfinished. Never put a closing keyword on a parent.
- `skip ENG-<id>` to mention an issue without linking it.
Leftover work: split it into a new slice issue before merging. Never merge under a closing link and reopen the issue afterwards.
After merge: record deploy and verification readback as a comment on the closed slice or the PR. If post-merge work or a rollback is needed, open a new follow-up issue. Never reopen the closed issue.
Closed without merging: move the Linear issue out of `In Progress` or `In Review` in the same session, to `Todo` or to `Canceled` with a note.
-->
Closes ENG-
Part of ENG-

## Validation
- [ ] Acceptance criteria met (listed below or linked)
- [ ] Tests pass locally or in CI
- [ ] Happy path tested manually
- [ ] Screenshots or Loom attached if UI change
- [ ] Rollback plan considered

### Acceptance criteria
<!-- Copy from the Linear issue. Tick as validated. -->
- [ ]
- [ ]
- [ ]

### Evidence
<!-- Screenshots, Loom link, test output, or notes on manual steps. "Looks fine in the diff" is not evidence. -->

## Risk classification
- [ ] Low risk (UI-only, additive, or isolated)
- [ ] Medium risk (business logic, integrations, schema-adjacent)
- [ ] **Risky change** (auth, billing, migrations, destructive scripts, infra, secrets, user data deletion)

If risky, attach the Risky Change Checklist from `docs/RISKY_CHANGE_CHECKLIST.md`.

## Reviewer focus
<!-- What should the reviewer spend their time on? What did AI assume? What could break? -->

## Rollback
<!-- One sentence on how to undo this safely. For risky changes, link the rehearsed rollback plan. -->

---

<!--
Light PR block (for tiny changes only).
Delete everything above and uncomment this block.

## Light PR
Reason this qualifies: typo | copy | docs | dep bump | lint-only

Short description of the change:

Checks must still pass. One approval still required.
-->
