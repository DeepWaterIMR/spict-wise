# CLAUDE.md — spict-wise (Claude Code)

spict-wise is part of [Fiskwise](https://deepwaterimr.github.io/fiskwise/). See the
[ecosystem repository](https://github.com/DeepWaterIMR/fiskwise) for the canonical pack
names and migration guide. Existing skill IDs and scientific interfaces remain stable.

This is the **Claude Code** pointer. The full agent contract is in [`AGENTS.md`](AGENTS.md) —
read it. This file only adds Claude-specific notes.

## What this repo is

A **knowledge pack** (like [BAIT](https://github.com/DeepWaterIMR/BAIT) and
[index-wise](https://github.com/DeepWaterIMR/index-wise)) that teaches an agent to run a
**SPiCT** biomass-dynamic stock assessment and **generates a new project folder** for the stock.
It is installed once per machine; its skills live in `~/.claude/skills/` as `spict-*`.

It is **public — never commit data or private paths here.** See the confidentiality section of
[`AGENTS.md`](AGENTS.md).

It builds on [wise-writing](https://github.com/DeepWaterIMR/wise-writing): `scaffold.R`
calls that pack's `scaffold_document()` and overlays the SPiCT layer. There is one copy of the
shared infrastructure and it lives there, not here.

spict-wise owns the SPiCT method and model-specific artifacts. wise-writing owns shared
scientific style, package-loading, project layout, and generic reporting. Use **`r-code-style`**
for every managed R task. Keep standalone use available and install wise-writing on demand
before scaffolding. In managed mode, follow `fiskwise-install`, `fiskwise-update`, or
`fiskwise-uninstall`; honor saved R-install consent, disabled toggles, and `renv.lock`, and
avoid duplicate dependency updates. The SPiCT/TMB toolchain is installed only when needed and
permitted; index-wise and Biotic database refreshes remain separate opt-in workflows.
Use `fiskwise-workflow` to route requests spanning packs.

## Where things are

- **Skills** — `skills/spict-*/SKILL.md`. Installed globally by `skills/spict-install`.
- **Shared knowledge** — `knowledge/*.md`. `spict.md` and `constraints.md` are the two to read
  before touching anything.
- **Project overlay** — `project-template/`, copied over wise-writing's skeleton and
  stamped by `scaffold.R`.
- **Worked example** — `examples/redfish/`.
- **Pack development memory** — `memory/`. This is for developing spict-wise itself, not
  for generated projects.

## Claude-specific notes

- **Project memory, not local memory.** When working *inside a generated project*, use that
  project's `ai/memory/` folder (read `ai/memory/MEMORY.md` first). Do **not** use
  `~/.claude/projects/.../memory/` for project facts — that folder is only for user-level
  preferences and identity. When working *in this pack*, use `memory/` here.
- **Skills** — when the user asks to compile data, fit, explore, or report a SPiCT assessment,
  invoke the matching `spict-*` skill; outside a scaffolded project, use `spict-model`. For
  prose and document structure, defer to the `academic-*` skills. For a survey index, defer to index-wise's `index-*` skills; for
  Biotic data access, to BAIT's `biotic-*`.
- **Plan mode** — after the questionnaire in `spict-new-assessment`, use plan mode to confirm
  the approach before scaffolding.
- **Code review before render** — renders are slow; run `/code-review` on changed chunks first.
  See `knowledge/rendering.md`.
- **R code style** — use the installed `r-code-style` skill for all R changes in managed work.
- **This is a template repository, not a runnable assessment.** The documents under
  `project-template/` contain `{{STOCK_NAME}}` and other placeholders that resolve only when
  `scaffold_spict()` has run. Do not try to render them here.
- **Template-level changes belong here**; stock-specific priors, narrative, and data belong in
  the generated project. A fix to `docs/render.R` or `R/0_setup.R` belongs in wise-writing.

For everything else, see [`AGENTS.md`](AGENTS.md).

## Fiskwise version policy

Follow the [shared version policy](https://github.com/DeepWaterIMR/fiskwise/blob/main/docs/VERSIONING.md).
Every ordinary authored commit increments the patch by 0.0.1 and stamps the current date
(`VERSION` for knowledge packs; `DESCRIPTION` `Version` and `Date` for R packages).
Only an explicit user request may set `FISKWISE_VERSION_BUMP=minor|major`. Never choose one
autonomously or create tags/releases automatically. Let `.githooks/pre-commit` enforce the
policy, preserve other custom hooks, and replay existing stamps unchanged during merges or
rebases.
