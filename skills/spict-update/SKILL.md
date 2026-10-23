---
name: spict-update
description: Update spict-wise to the latest version — git pull the repository and re-sync the spict-* skills into the global skills folder. Use when the user says "update spict-wise", "pull the latest spict-wise", or asks for newer SPiCT assessment recipes or skills.
---

# Update spict-wise

Goal: pull the latest spict-wise and re-sync its skills, mirroring wise-writing's
`academic-writing-update`.

## Step 1 — Locate the install

Read `spict_template_path` from `~/.spict-wise/config.json` first. If it is missing or
invalid, check legacy `~/.spict-template/config.json`; both use the compatible
`spict_template_path` key. If no configured path resolves to a Git repository, tell the user to
run `spict-install` first and stop.

## Step 2 — Pull

```bash
git -C "<spict_template_path>" fetch --quiet
git -C "<spict_template_path>" pull --ff-only
```

If the working tree has local changes, report them and let the user decide. Do not discard
work, and do not stash silently — a local change in this repo is usually an improvement
someone meant to contribute upstream.

## Step 3 — Update wise-writing too

spict-wise's scaffolder calls wise-writing's, so the two drift apart if only one is
pulled. Offer to run `academic-writing-update` in the same pass.

## Step 4 — Re-sync the skills

Reconcile only this pack's `spict-*` entries in the locations used by the installed agents
(`~/.claude/skills/` for Claude Code, `~/.agents/skills/` for Codex). Leave a destination
symlink in place when it resolves to the matching source skill; updates to the repository then
appear automatically. Skip any source and destination that resolve to the same path. Before
replacing a differing directory or link, move that single entry to a timestamped backup. Never
copy the pack tree onto itself, delete a skills root, or touch the `academic-*`, `index-*`, and
`biotic-*` entries.

## Step 5 — Report

Summarise what changed since the last pull from the git log — new or updated skills, knowledge
files, and changes to `project-template/`.

Say explicitly that **existing assessment projects are not migrated**. They keep the templates
they were scaffolded with; a new project picks up the new ones. Where a change matters to an
existing project — a fixed helper, a corrected convention — name it, and let the analyst decide
when in the assessment cycle to take it. Mid-advice-round is rarely the moment.
