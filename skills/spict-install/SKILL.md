---
name: spict-install
description: Install or set up spict-wise for building SPiCT biomass-dynamic stock assessments. Use when the user says "install spict-wise", "install https://github.com/DeepWaterIMR/spict-wise", "set up spict-wise", or first asks to run a SPiCT assessment and spict-wise is not yet installed. Clones the pack, installs its skills, and checks its toolchain; wise-writing is needed on demand before scaffolding.
---

<!-- pack-resources:start -->
**Pack resources:** the `spict-wise` root is `~/.spict-wise/config.json` → `spict_template_path`, else `~/.fiskwise/config.json` →
`components.spict-wise.path`, else the checkout containing this skill. Paths such as `knowledge/`
and `project-template/` are relative to that root, never `../../` from a skills folder; resolve
links that leave this skill's folder against the source skill there. Use absolute paths.
<!-- pack-resources:end -->


# Install spict-wise

Goal: get spict-wise working **once per machine** so it is available in every project — not
cloned into each stock repository. spict-wise builds on wise-writing, so that must be
present first.

> Trigger: the user prompts *"install https://github.com/DeepWaterIMR/spict-wise"* (or
> similar), or asks to run a SPiCT assessment with nothing installed yet.

For a direct machine-wide install, use `fiskwise-install` when the user chooses managed
lifecycle. If this skill was invoked by that workflow, handle only spict-wise-specific checks
and leave clone, registry, skill registration, and dependency bookkeeping to the parent. The
standalone procedure below remains available.

## Step 1 — wise-writing before scaffolding

spict-wise does not carry its own project skeleton, style rules, or rendering pipeline: it
overlays wise-writing's. Installing spict-wise alone does not require wise-writing; ensure the
shared pack is available on demand before the user asks to scaffold a project.

1. Before scaffolding, check `~/.wise-writing/config.json` first, then legacy
   `~/.academic-writing/config.json`; both use `academic_writing_path`. If wise-writing is
   **not** installed, run its `academic-writing-install` skill
   (`install https://github.com/DeepWaterIMR/wise-writing`) before going on.
2. Confirm the `academic-style`, `academic-conventions`, `academic-data-report`,
   `academic-assessment-report`, and `academic-advice-sheet` skills are available.

## Step 2 — Clone spict-wise

Before cloning, reuse an existing installation recorded in `~/.spict-wise/config.json` or the
legacy `~/.spict-template/config.json`; both use `spict_template_path`, and the new config takes
precedence when both exist.

Clone it beside wise-writing when that pack is already installed (read `academic_writing_path`
from its config and use its parent), or another user-space location the user prefers. **Never
clone at a filesystem root or a system directory** — refuse and suggest a safe location.

```bash
git clone https://github.com/DeepWaterIMR/spict-wise "<path>/spict-wise"
```

If the user started by cloning the URL into the current workspace, reuse that clone rather than
duplicating it.

## Step 3 — Install the skills globally

Link the `spict-*` skill folders individually into the agent's user-level skills folder so they
work in every project:

- Claude Code → `~/.claude/skills/`
- Codex → `~/.agents/skills/`
- Other agents → point their instructions at `<spict-wise>/skills/`

Leave a destination symlink in place when it resolves to that source skill; repository updates
then appear automatically. Skip any source and destination that resolve to the same path. If a
differing directory or link already occupies that skill's destination, move that single entry to
a timestamped backup before linking the source skill folder there. Never copy the pack tree onto
itself, delete a skills root, or touch unrelated skill entries.

Record the install in `~/.spict-wise/config.json`. In managed mode, leave registry and pack
config updates to `fiskwise-install`; it preserves the compatible `spict_template_path` key.
For standalone installation, legacy
`~/.spict-template/config.json` remains a scaffold fallback and uses the same
`spict_template_path` key:

```json
{ "spict_template_path": "<path>/spict-wise", "installed_at": "<date>" }
```

`scaffold.R` reads that file to locate itself, so skipping it means passing `pack=` by hand
every time.

## Step 4 — Verify the toolchain

`spict` is not on CRAN and compiles a TMB model, so it needs a working compiler. In
Fiskwise-managed mode, use its saved R-install consent and package helper; do not install or
update dependencies a second time here. Respect disabled install toggles and project
`renv.lock`; if installation is not permitted, report missing packages. For standalone use,
add only missing packages with the user's authorization.

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
if (!requireNamespace("spict", quietly = TRUE)) {
  remotes::install_github("DTUAqua/spict/spict", dependencies = TRUE, upgrade = "never")
}
library(spict)
packageVersion("spict")

for (p in c("quarto", "flextable", "officer", "icesAdvice", "cowplot", "readxl", "yaml")) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
}
```

If the `spict` install fails on a missing compiler, that is a toolchain problem: run
wise-writing's `academic-toolchain-setup` skill (Rtools on Windows, Xcode command line
tools on macOS) rather than retrying the install.

See `knowledge/packages.md` for the `dev` branch and why the version matters.

## Step 5 — Optional: index-wise

If the abundance index will come from an sdmTMB spatiotemporal model rather than an existing
producer, install [index-wise](https://github.com/DeepWaterIMR/index-wise) as well. It
sits on BAIT and produces the index a SPiCT project consumes. A SPiCT project never builds its
own survey index.

## Done

Tell the user spict-wise is installed, name the spict version, and say how to start:

> *"Let's set up the `<year>` SPiCT assessment for `<stock>` using spict-wise."*

That triggers `spict-new-assessment`.
