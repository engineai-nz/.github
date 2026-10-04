# .github

This is the Engine AI organisation-level defaults repo.

Files in here cascade to every repo under the Engine AI org that doesn't define its own version.

## What lives here

- `profile/README.md` — shown on the org profile page at github.com/<org>
- `.github/pull_request_template.md` — default PR template for all org repos
- `.github/ISSUE_TEMPLATE/*.yml` — default issue forms (feature, bug, tech-debt, incident)
- `CONTRIBUTING.md` — how outside contributors (or future hires) work with us
- `SECURITY.md` — security reporting policy
- `SUPPORT.md` — where to go for help

## What does NOT cascade from here

- GitHub Actions workflows (use reusable workflows in a central repo for that)
- Branch protection rules (set per repo or via org ruleset)
- CODEOWNERS (must live in each repo)
- Labels (use `gh label create` per repo, or a central script)

## Upgrading these defaults

If you change anything here, it affects every repo in the org that hasn't overridden it. Treat changes like a risky change — both founders approve, or it doesn't merge.

## Bootstrap verification

`scripts/new-project.sh` requires authenticated `gh` and `jq`. It keeps auto-merge off during setup and enables it only after readable effective main protection requires pull requests, strict updates and both `Project package exists` and `ci / Install, lint, test, typecheck`. Each required context must be bound by effective rules to one unambiguous positive integration ID. Each must have one completed successful run on the current main SHA whose app ID matches that binding and whose trusted app slug is `github-actions`, with complete check-run readback and an unchanged default branch/head. Effective PR/strict-check protection and the same source bindings are re-read and validated immediately before and after enabling; protection or source races abort or roll back. Missing, failed, stale, unbound, mismatched, untrusted or ambiguous evidence aborts setup. Failures attempt to disable auto-merge, then independently read back state even when that write returns an error. Verified OFF is reported only after successful readback; otherwise the state remains an operational blocker requiring provider readback before further action.

`--no-ci` keeps auto-merge off. `--dry-run` performs no provider mutations. Bootstrap adds no spending, access or release authority. Substantive independent review of each exact PR head and its merge/release gates remain separate.

Run source verification locally with `bash -n scripts/new-project.sh` and `python3 -B -m unittest discover -s tests -v`. The tests invoke the actual Bash script with a mocked `gh` provider; they perform no live setup or account changes. The scoped `Bootstrap source checks` workflow runs those checks. Mocked evidence does not prove a live repository's readiness. The both-founder approval requirement above remains binding for these infrastructure changes.
