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
<!-- Use GitHub closing keywords so this PR auto-closes the issue on merge. -->
Closes #

## Validation
- [ ] Acceptance criteria met (listed below or linked)
- [ ] Tests pass locally or in CI
- [ ] Happy path tested manually
- [ ] Screenshots or Loom attached if UI change
- [ ] Rollback plan considered

### Acceptance criteria
<!-- Copy from the GitHub issue. Tick as validated. -->
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
