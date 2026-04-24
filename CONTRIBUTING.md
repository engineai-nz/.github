# Contributing to Engine AI repos

Engine AI is a two-founder shop. Most repos are internal, some are client work. This file sets the baseline for anyone contributing, including us.

## Before you start

1. Read the `HOW_WE_BUILD.md` in the specific repo. It has the rules calibrated to that project.
2. Read `docs/brief.md` and `docs/master-spec.md` in that repo so you understand what you're changing.
3. Check `docs/DECISIONS.md` — if a decision has already been made about something, don't relitigate it. Propose a supersede entry if you disagree.

## The golden path

1. Clarify the problem before writing code.
2. Create a GitHub issue using the appropriate template. Link the Notion page if there is one.
3. Branch per issue: `eng-<issue-number>-<slug>`.
4. Open a draft PR early. Include `Closes #<issue-number>` in the PR body.
5. Validate against acceptance criteria.
6. At least one founder approves.
7. Squash-merge.

## Pull requests

- Use the PR template in the repo (or the org-level default).
- Title format: `[#123] Short action-focused description`.
- Every PR gets a `risk/` label and an `ai/` label.
- Checks must pass.

## Risky changes

If the PR touches auth, billing, migrations, destructive scripts, infra, secrets, or user data deletion, it is a risky change. The Risky Change Checklist must be completed in full. Both founders must approve. No exceptions.

## AI usage

We use AI heavily. We don't ship AI-generated code we don't understand, especially on risky paths. If a line is opaque, one of us walks the other through it before merge.

## Outside contributors

If you're not Ben or Joe and you want to contribute, open an issue first and tag a founder. We'll tell you whether the PR is worth your time before you spend it.
