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
