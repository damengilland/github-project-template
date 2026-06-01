#!/usr/bin/env bash
#
# setup-labels.sh — wipe and recreate the full issue-label scheme.
#
# Requires the GitHub CLI (https://cli.github.com/), authenticated via `gh auth login`.
# Usage: edit REPO below, then run:  bash setup-labels.sh
#
set -euo pipefail

REPO="damengilland/github-project-template"   # <-- set your repo, e.g. "acme/webapp"

# Format per entry: "Name|Color|Description"  (split on the FIRST two pipes)
labels=(
  # ── Owner (purple) — sets Priority ─────────────────────────────────────────
  "Owner: Product|8000FF|Roadmap deliverables, new capabilities, primary product functions."
  "Owner: Marketing|8000FF|Campaigns, SEO, growth initiatives, attribution tracking, paid-media landing pages."
  "Owner: Sales|8000FF|Pitch work, prototypes, pre-sales engineering, demo environments."
  "Owner: Support|8000FF|Client-reported bugs, helpdesk escalations, reactive break-fix work."
  "Owner: Engineering|8000FF|Tech debt, dependency updates, refactoring, internal tooling, dev experience, runbooks."
  "Owner: Reliability|8000FF|Uptime, latency, infrastructure stability, incident prevention, on-call burden reduction."
  "Owner: Security|8000FF|Active defense, vulnerability remediation, DevSecOps findings, pen-test follow-up."
  "Owner: Compliance|8000FF|Privacy regulations (GDPR/CCPA), audit evidence, accessibility (WCAG), regulatory adherence."

  # ── Priority (pink scale) — set by the Owner ───────────────────────────────
  "Priority: 0 Critical|FF0080|Production is broken or launch is blocked. Drop everything."
  "Priority: 1 High|FF3399|Must land in the current or next sprint."
  "Priority: 2 Normal|FF80BF|Standard sprint pull from the backlog. Most tickets live here."
  "Priority: 3 Low|FFCCE6|Opportunistic, nice-to-have, or captured for the record."

  # ── Type (green) — nature of the deliverable ───────────────────────────────
  "Type: Feature|00FF80|Net-new functionality."
  "Type: Enhancement|00FF80|Improvement to an existing feature."
  "Type: Defect|00FF80|Bug fix or regression."
  "Type: Design|00FF80|Mockups, wireframes, comps, prototypes, design-system additions, marketing creative."
  "Type: Refactor|00FF80|Internal cleanup with no behavior change."
  "Type: Research|00FF80|Spike, discovery, UX research, technical investigation. Time-boxed; output is findings."
  "Type: Technical Design|00FF80|Architecture proposals, RFCs, data modeling, requirements specs, acceptance criteria."
  "Type: Copy|00FF80|Text-only updates — microcopy edits, marketing copy, localization strings."
  "Type: Documentation|00FF80|READMEs, API docs, internal wikis, runbooks."
  "Type: Task|00FF80|General administrative or non-code to-do that doesn't fit above."
  "Type: Question|00FF80|Needs stakeholder clarification before work can begin."

  # ── Area (blue) — where the work lives ─────────────────────────────────────
  "Area: Front-end|0080FF|React, HTML, CSS, browser-side behavior. Default for client-side work."
  "Area: Back-end|0080FF|APIs, server logic, business rules, service integration."
  "Area: Data|0080FF|Databases, migrations, ETL, query optimization, warehousing."
  "Area: DevOps|0080FF|CI/CD, hosting, networking, observability, infrastructure as code, deployment, monitoring."
  "Area: Mobile|0080FF|iOS, Android, React Native. Drop this label if you don't ship native apps."
  "Area: Design|0080FF|Figma work, UX research, visual assets, interaction design, design-system curation. Designer queue."
  "Area: QA|0080FF|Test planning, automation, manual verification, regression passes. QA queue."
  "Area: CMS|0080FF|CMS platform — authoring tools, DAM integration, editor experience, content modeling."
  "Area: Commerce|0080FF|Cart, checkout, payments, billing, subscriptions, order management."
  "Area: Marketing Site|0080FF|Public marketing site, landing pages, blog, campaign microsites."
  "Area: Authentication|0080FF|Sign-up, login, SSO, password reset, MFA, session management."
  "Area: User Tools|0080FF|Account settings, personal preferences, profile pages, order history."
  "Area: Notifications|0080FF|Email, push, SMS, in-app messaging delivery."
  "Area: Search|0080FF|Indexing, query, discovery, recommendations, faceted browse."
  "Area: Reporting|0080FF|End-user dashboards, exports, in-product analytics views. Distinct from Area: Analytics."
  "Area: Integrations|0080FF|Webhooks, third-party APIs, ERP connectors, payment gateways, CRM sync."
  "Area: Analytics|0080FF|Tag management, tracking pixels, event schemas, attribution wiring. The instrumentation layer."
  "Area: Admin Tools|0080FF|Internal staff tooling, support consoles, ops dashboards."

  # ── Meta (yellow) — cross-cutting flags, no prefix ─────────────────────────
  "Epic|FFFF00|Parent ticket tracking multiple sub-issues via a task list. Use sparingly."
  "Blocked|FFFF00|Can't progress until something external resolves. Pair with a comment explaining the blocker."
  "Keep Open|FFFF00|Stale-bot exempt. Long-running tracker, known-issue placeholder, or ongoing initiative."
  "Duplicate|FFFF00|Closed in favor of another issue. Reference the canonical ticket in the closing comment."
)

echo "Target repo: $REPO"
echo "This will DELETE every existing label in the repo, then create ${#labels[@]} new ones."
read -r -p "Type 'yes' to continue: " confirm
[ "$confirm" = "yes" ] || { echo "Aborted."; exit 1; }

# 1) Wipe all existing labels
echo "Deleting existing labels..."
gh label list --repo "$REPO" --limit 500 --json name --jq '.[].name' \
  | while IFS= read -r old; do
      [ -n "$old" ] && gh label delete "$old" --repo "$REPO" --yes
    done

# 2) Create the scheme
echo "Creating labels..."
for entry in "${labels[@]}"; do
  name="${entry%%|*}"          # before first |
  rest="${entry#*|}"           # after first |
  color="${rest%%|*}"          # before second |
  desc="${rest#*|}"            # after second |
  gh label create "$name" --color "$color" --description "$desc" --repo "$REPO" --force
done

echo "Done. Created ${#labels[@]} labels."
