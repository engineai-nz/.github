#!/usr/bin/env bash
#
# new-project.sh — bootstrap an Engine AI repo to the house standard.
#
#   ./new-project.sh <slug> [--create] [--client <name>] [--no-ci] [--dry-run]
#
# GitHub templates copy FILES ONLY. Rulesets, branch protection, labels, project
# boards and repo settings never propagate. This script is therefore the only
# mechanism that actually configures a repo — a checklist in a markdown file has
# never once been followed to completion.
#
# The org ruleset "Org baseline: protect default branch" already blocks deletion
# and force-push on every repo's default branch. This script layers the per-repo
# rules on top: PR-required, linear history, and (with CI) a required check.
#
# Idempotent: safe to re-run against an existing repo to repair drift.

set -euo pipefail

ORG="engineai-nz"
TEMPLATE="$ORG/engine-ai-starter"

# A reusable workflow reports its check as "<caller-job-id> / <job-name>", NOT the
# bare job name. Requiring the bare name leaves every PR BLOCKED forever on a green
# build. The caller's job id must therefore be `ci`, matching the template's ci.yml.
CI_CONTEXT="ci / Install, lint, test, typecheck"

SLUG=""; CLIENT=""; CREATE=false; WANT_CI=true; DRY=false

usage() { sed -n '2,12p' "$0"; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --create)   CREATE=true; shift ;;
    --client)   CLIENT="${2:-}"; shift 2 ;;
    --no-ci)    WANT_CI=false; shift ;;
    --dry-run)  DRY=true; shift ;;
    -h|--help)  usage ;;
    -*)         echo "unknown flag: $1" >&2; usage ;;
    *)          SLUG="$1"; shift ;;
  esac
done
[[ -n "$SLUG" ]] || usage

REPO="$ORG/$SLUG"
run() { if $DRY; then echo "DRY: $*"; else "$@"; fi; }
say() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

command -v gh >/dev/null || { echo "gh CLI not found" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh not authenticated" >&2; exit 1; }

# ---------------------------------------------------------------- create
if $CREATE; then
  if gh repo view "$REPO" >/dev/null 2>&1; then
    say "repo $REPO already exists — skipping create"
  else
    say "creating $REPO from $TEMPLATE"
    run gh repo create "$REPO" --template "$TEMPLATE" --private
    sleep 5
  fi
else
  gh repo view "$REPO" >/dev/null 2>&1 || { echo "repo $REPO not found (pass --create)" >&2; exit 1; }
fi

# ---------------------------------------------------------------- settings
# Auto-merge is only safe when something holds it. With no required check,
# `gh pr merge --auto` merges instantly — approvals are 0 by design, so the
# pull_request rule alone gates nothing. Under --no-ci we therefore fail closed:
# allow_auto_merge=false makes `--auto` error rather than silently ship.
say "repo settings: auto-merge=$WANT_CI, delete branch on merge, squash+rebase only"
run gh api -X PATCH "repos/$REPO" \
  -F allow_auto_merge=$($WANT_CI && echo true || echo false) \
  -F delete_branch_on_merge=true \
  -F allow_merge_commit=false \
  -F allow_squash_merge=true \
  -F allow_rebase_merge=true >/dev/null

# ---------------------------------------------------------------- properties
# Intended for a future org ruleset that targets props.ci=true. As of 2026-07-10
# `orgs/engineai-nz/properties/schema` is empty, so this is a no-op — the values
# have nowhere to land. Kept because the write is harmless and becomes live the
# moment the schema is defined. Repos without CI must NOT be swept into such a
# ruleset: a required check that never reports leaves every PR BLOCKED forever.
say "custom properties: ci=$WANT_CI client=${CLIENT:-none}"
props="[{\"property_name\":\"ci\",\"value\":\"$($WANT_CI && echo true || echo false)\"}]"
if [[ -n "$CLIENT" ]]; then
  props="[{\"property_name\":\"ci\",\"value\":\"$($WANT_CI && echo true || echo false)\"},{\"property_name\":\"client\",\"value\":\"$CLIENT\"}]"
fi
if $DRY; then
  echo "DRY: set custom properties -> $props"
elif echo "{\"properties\":$props}" | gh api -X PATCH "repos/$REPO/properties/values" --input - >/dev/null 2>&1; then
  echo "  ✓ properties set"
else
  echo "  ⚠ properties NOT set — no org-level schema defines 'ci'/'client'."
  echo "    Harmless today (nothing targets them). Define the schema at"
  echo "    github.com/organizations/$ORG/settings/custom-properties, then re-run."
fi

# ---------------------------------------------------------------- ruleset
# No approving reviews: Ben and Joe do not gate each other. CI is the gate.
say "ruleset 'Protect main'"
RULES='[
  {"type":"deletion"},
  {"type":"non_fast_forward"},
  {"type":"required_linear_history"},
  {"type":"pull_request","parameters":{
    "required_approving_review_count":0,
    "dismiss_stale_reviews_on_push":true,
    "require_code_owner_review":false,
    "require_last_push_approval":false,
    "required_review_thread_resolution":false,
    "allowed_merge_methods":["squash","rebase"]}}'
if $WANT_CI; then
  RULES="$RULES,
  {\"type\":\"required_status_checks\",\"parameters\":{
    \"strict_required_status_checks_policy\":false,
    \"required_status_checks\":[{\"context\":\"$CI_CONTEXT\"}]}}"
fi
RULES="$RULES]"

BODY=$(cat <<JSON
{"name":"Protect main","target":"branch","enforcement":"active",
 "conditions":{"ref_name":{"include":["~DEFAULT_BRANCH"],"exclude":[]}},
 "rules":$RULES}
JSON
)

existing=$(gh api "repos/$REPO/rulesets" -q '.[]|select(.name=="Protect main").id' 2>/dev/null | head -1 || true)
if $DRY; then
  if [[ -n "$existing" ]]; then echo "DRY: update ruleset $existing"; else echo "DRY: create ruleset"; fi
elif [[ -n "$existing" ]]; then
  printf '%s' "$BODY" | gh api -X PUT "repos/$REPO/rulesets/$existing" --input - -q '"updated ruleset: \(.name)"'
else
  printf '%s' "$BODY" | gh api -X POST "repos/$REPO/rulesets" --input - -q '"created ruleset: \(.name)"'
fi

# ---------------------------------------------------------------- labels
say "labels"
labels=(
  "risk/low|0e8a16|Low blast radius"
  "risk/medium|fbca04|Needs care"
  "risk/high|b60205|Auth, billing, migrations, secrets, infra"
  "ai/authored|5319e7|Written primarily by an agent"
  "ai/assisted|c5def5|Human-led, agent-assisted"
  "type/feature|1d76db|New capability"
  "type/bug|d73a4a|Something is broken"
  "type/tech-debt|cfd3d7|Cleanup or refactor"
  "type/incident|b60205|Production incident"
  "status/blocked|e99695|Waiting on something"
  "status/needs-decision|d4c5f9|Needs a call from Joe or Ben"
)
for l in "${labels[@]}"; do
  IFS='|' read -r name colour desc <<< "$l"
  if $DRY; then echo "DRY: label $name"; else
    gh label create "$name" -R "$REPO" --color "$colour" --description "$desc" --force >/dev/null 2>&1 || true
  fi
done
echo "  ${#labels[@]} labels applied"

# ---------------------------------------------------------------- verify
# A required context that never reports blocks every PR permanently. Check that
# the name we just required has actually been emitted by a recent run.
if $WANT_CI && ! $DRY; then
  say "verifying required check '$CI_CONTEXT' is a real context"
  seen=$(gh api "repos/$REPO/commits/$(gh api "repos/$REPO" -q .default_branch)/check-runs" \
           -q '.check_runs[].name' 2>/dev/null || true)
  if [[ -z "$seen" ]]; then
    echo "  ⚠ no check runs on the default branch yet — cannot verify."
    echo "    Open a PR and confirm it reaches CLEAN before trusting this ruleset."
  elif grep -Fxq "$CI_CONTEXT" <<< "$seen"; then
    echo "  ✓ '$CI_CONTEXT' reported by a real run"
  else
    echo "  ✗ MISMATCH — required '$CI_CONTEXT' but the repo emits:"
    sed 's/^/      /' <<< "$seen"
    echo "    Every PR will sit BLOCKED. Fix CI_CONTEXT or the caller job id, then re-run."
    exit 1
  fi
fi

# ---------------------------------------------------------------- report
say "done — $REPO"
if ! $DRY; then
  gh api "repos/$REPO" -q '"  auto_merge=\(.allow_auto_merge)  delete_branch=\(.delete_branch_on_merge)"'
  gh api "repos/$REPO/rules/branches/$(gh api "repos/$REPO" -q .default_branch)" \
    -q '"  rules: " + ([.[].type]|unique|join(", "))' 2>/dev/null || true
fi
cat <<EOF

  Not automated (deliberate):
    - Slack channel #client-${CLIENT:-<name>}  — create it, then pin repo + Notion links
    - Notion project page
    - Seed issues from docs/prd.md
EOF

if ! $WANT_CI; then
  cat <<EOF

  Bootstrapped with --no-ci: auto-merge is OFF, so \`gh pr merge --auto\` errors
  instead of merging an unchecked PR. Add a caller ci.yml emitting
  "$CI_CONTEXT", then re-run this script without --no-ci to
  require the check and turn auto-merge on.
EOF
fi
