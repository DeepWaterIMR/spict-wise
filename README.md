[![Part of Fiskwise](https://deepwaterimr.github.io/fiskwise/assets/part-of-fiskwise.svg)](https://deepwaterimr.github.io/fiskwise/)

# 🐟 spict-wise — Run SPiCT stock assessments with AI agents

<!-- version -->
**Version 0.2.5** (2026-10-30)
<!-- /version -->

This repository is part of [Fiskwise](https://github.com/DeepWaterIMR/fiskwise), with its [project hub](https://deepwaterimr.github.io/fiskwise/). See [MIGRATION.md](MIGRATION.md) for repository and local config migration notes.

**Teach your AI coding agent to run a biomass-dynamic stock assessment — from catch series to catch advice — for any stock, on your own machine.**

spict-wise is a knowledge pack that turns a general coding agent (Claude Code, Codex, Cursor, Gemini CLI, Mistral, …) into a competent assistant for [**SPiCT**](https://github.com/DTUAqua/spict) assessments — the Surplus Production model in Continuous Time of [Pedersen & Berg (2017)](https://doi.org/10.1111/faf.12174). It is distilled from the `reg-spict` (golden redfish) and `reb-spict` (beaked redfish) assessments of the Deep-water species and cartilaginous fish group at the Institute of Marine Research.

Tell your agent which stock you want assessed, and it will:

1. **Ask you a structured questionnaire** and confirm a plan.
2. **Scaffold a project folder** with wise-writing's standard layout (`docs/`, `R/`, `data/`, `figures/`, `ai/`, `logs/`, `config/`).
3. **Compile the data** — the catch series and the abundance index — and record where every number came from.
4. **Fit, diagnose, and report** the model, then produce the **working-group chapter** and the **advice sheet**.

> **It is not a trained model.** Your data never leaves your machine and never enters any model's weights. The agent simply *reads this repo* while it helps you. See [Confidentiality](#-confidentiality).

## ✍️ Built on wise-writing

spict-wise owns the **SPiCT assessment** layer. [wise-writing](https://github.com/DeepWaterIMR/wise-writing) owns the shared project layout, scientific writing style, document conventions, and rendering pipeline. The dependency is real: `scaffold.R` calls wise-writing's `scaffold_document()` and overlays the SPiCT content, so there is exactly one copy of shared infrastructure. Install wise-writing on demand before scaffolding; installing spict-wise alone does not require it.

For length- and age-structured models of the same stocks, see [gadget-wise](https://github.com/DeepWaterIMR/gadget-wise) (gadget3).

Use `fiskwise-workflow` for requests spanning packs and `fiskwise-install`, `fiskwise-update`,
and `fiskwise-uninstall` for managed lifecycle. Standalone spict-wise skills remain available.
For managed R tasks, always use **`r-code-style`**.

```
install https://github.com/DeepWaterIMR/wise-writing
```

## 🚀 Quickstart

1. **Install spict-wise:**
   ```
   install https://github.com/DeepWaterIMR/spict-wise
   ```
   The agent runs [`spict-install`](skills/spict-install/SKILL.md): clone spict-wise → install its skills globally → check the SPiCT toolchain.
2. **Before scaffolding**, ensure wise-writing is installed; the agent will request it if needed.
3. **Start an assessment:**
   ```
   Let's set up the 2026 SPiCT assessment for beaked redfish in ICES subareas 1 and 2,
   using spict-wise.
   ```
   The agent runs the questionnaire, plans, scaffolds a project, and drives the workflow.

> **Manual install:** clone the repo and open your agent in the folder, or point its instructions at `<clone>/skills/`. Nothing here needs a network connection at use time.

## 🗺️ The workflow

| Step | Skill | Produces |
|------|-------|----------|
| Scaffold a project (questionnaire + plan) | [`spict-new-assessment`](skills/spict-new-assessment/SKILL.md) | The project folder and `config.yaml` |
| **1.** Compile the catches and the index | [`spict-compile-data`](skills/spict-compile-data/SKILL.md) | The two series the model is fitted to |
| **2.** Fit, diagnose, project | [`spict-fit-model`](skills/spict-fit-model/SKILL.md) | The assessment data report and the summary object |
| **3.** Explore alternatives *(benchmark)* | [`spict-explore`](skills/spict-explore/SKILL.md) | Candidate fits, comparisons, the Shiny explorer |
| **4.** The working-group chapter | [`spict-assessment-report`](skills/spict-assessment-report/SKILL.md) | A Word chapter in the group's template |
| **5.** The advice sheet | [`spict-advice-sheet`](skills/spict-advice-sheet/SKILL.md) | The catch advice |

Long renders go through [`spict-render`](skills/spict-render/SKILL.md) — code review first, then a screen session with a log in `logs/`.

**The model is fitted once.** Step 2 saves a small summary object; the chapter and the advice sheet read it rather than refitting, which is what makes all three documents quote the same numbers.

## 📚 What's in this repo

- [`AGENTS.md`](AGENTS.md) / [`CLAUDE.md`](CLAUDE.md) — the agent contract.
- [`skills/`](skills/) — the nine `spict-*` skills, installed globally.
- [`knowledge/`](knowledge/) — the shared source of truth: [the model conventions](knowledge/spict.md), [catch data](knowledge/catch-data.md), [indices](knowledge/indices.md), [diagnostics](knowledge/diagnostics.md), [advice](knowledge/advice.md), [the hard constraints](knowledge/constraints.md), [project structure](knowledge/project-structure.md), [the wise-writing contract](knowledge/wise-writing.md), [packages](knowledge/packages.md), and [rendering](knowledge/rendering.md).
- [`project-template/`](project-template/) — the SPiCT layer overlaid onto wise-writing's skeleton.
- [`scaffold.R`](scaffold.R) — `scaffold_spict()`, which stamps a project from `config.yaml`.
- [`examples/redfish/`](examples/redfish/) — a worked example.
- [`config/validate-scaffold.R`](config/validate-scaffold.R) — the structural check.

## ⚖️ The conventions this pack fixes

SPiCT is a state-space model fitted to two short series, and most of the ways it goes wrong are silent. These are the pack's conventions, documented in [`knowledge/spict.md`](knowledge/spict.md):

- Catches in **tonnes** throughout; the index scaled by its own mean; index timing a fraction of the year matching when the survey runs.
- **`stdevfac` vectors must average to 1** — they multiply an estimated observation error, so a vector that does not silently rescales it.
- **`logn` fixed** at the Schaefer value: a production-function shape estimated from one catch series and one index is not identified.
- **`logalpha` and `logbeta` priors deactivated**, so they do not fight an informative prior on `logsdb`.
- **Reference points are relative.** SPiCT estimates F~MSY~ and B~MSY~; B~lim~ and MSY B~trigger~ are conventions the advice framework supplies.
- **Priors carried over from another stock are placeholders, not defaults.**

Three [hard constraints](knowledge/constraints.md) override tidiness: exploratory-status callouts stay, official-track advice numbers do not change under a cosmetic edit, and advice-history rows are extended rather than fitted.

## 🔒 Confidentiality

This repo is **public and contains instructions only — never data**:

- **No data and no private paths** are ever committed here. Catch series, index files, and model output live only in the *project folder the agent generates for you*, where `data/`, `logs/`, `figures/`, and `ai/review/` are git-ignored.
- Norwegian sales-note data carry confidentiality constraints, and catch data by country or vessel can be commercially sensitive. **Generated projects default to a local Git repository with no remote**; publishing one follows a review of whether the series it contains can be published.

## 🧰 Siblings

- [**wise-writing**](https://github.com/DeepWaterIMR/wise-writing) — scientific writing style, document conventions, and the shared project skeleton. **Required before scaffolding**; install it on demand.
- [**index-wise**](https://github.com/DeepWaterIMR/index-wise) — sdmTMB spatiotemporal survey indices. Produces the index a SPiCT assessment consumes.
- [**BAIT**](https://github.com/DeepWaterIMR/BAIT) — IMR Biotic data access, privacy, maps, life history.
- [**wise-presentations**](https://github.com/DeepWaterIMR/wise-presentations) — Quarto RevealJS slides.

Install whichever you need alongside; the skills stay out of each other's way.

## 🚨 You are still in charge

This repo speeds up the data compilation, the fitting, and the writing. It does not decide what is true, and it does not produce advice that is ready to publish. A scaffolded project is a place to start: the priors are placeholders until someone calibrates them, the diagnostics need judging rather than displaying, and every number in an advice sheet is read by managers. Expert judgment is required throughout, and the humans named as authors are accountable for all of it.

## 📖 References

Pedersen, M.W. & Berg, C.W. (2017). A stochastic surplus production model in continuous time. *Fish and Fisheries* 18, 226–243. [doi:10.1111/faf.12174](https://doi.org/10.1111/faf.12174).

Mildenberger, T.K., Berg, C.W., Pedersen, M.W., Kokkalis, A. & Nielsen, J.R. (2020). Time-variant productivity in biomass dynamic models on seasonal and long-term scales. *ICES Journal of Marine Science* 77, 174–187. [doi:10.1093/icesjms/fsz154](https://doi.org/10.1093/icesjms/fsz154).

## 🙋 Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Run `Rscript config/validate-scaffold.R` before opening a pull request.

## 📄 Licence

GPL-3, matching `spict` itself. See [`LICENSE`](LICENSE). The Word reference documents and the citation style come from wise-writing at scaffold time and keep their own terms.
