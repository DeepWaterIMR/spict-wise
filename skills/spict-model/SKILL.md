---
name: spict-model
description: Explain, write, review, or debug a SPiCT surplus-production assessment in any project or folder layout — the inp object, catch and index units and timing, stdevfac multipliers, fixed logn, priors (logr, logbkfrac, logsdb) and prior-posterior checks, the WKLIFE acceptance checklist (convergence, OSA residuals, retro and Mohn's rho, BMSY/K, CI ratios, check.ini), hindcasting, reference points, and management scenarios. Use for any SPiCT question ("is my fit acceptable?", "check my priors", "why does retro fail?") in an existing repository, or before writing or reviewing SPiCT code; use the spict-* step skills inside a scaffolded spict-wise project.
---

<!-- pack-resources:start -->
**Pack resources:** the `spict-wise` root is `~/.spict-wise/config.json` → `spict_template_path`, else `~/.fiskwise/config.json` →
`components.spict-wise.path`, else the checkout containing this skill. Paths such as `knowledge/`
and `project-template/` are relative to that root, never `../../` from a skills folder; resolve
links that leave this skill's folder against the source skill there. Use absolute paths.
<!-- pack-resources:end -->


# SPiCT assessments in any project

The method-level spict-wise skill: what an agent needs to read, write, review, or explain a
SPiCT assessment wherever the code lives. It does not scaffold anything and does not assume
spict-wise's folder layout.

**Detect the project first.** `R/spict_helpers.R` with a `config.yaml` and
`docs/data-report/spict-assessment/` means a scaffolded spict-wise project: follow the step
skills (`spict-compile-data` → `spict-fit-model` → `spict-explore` → `spict-assessment-report`
→ `spict-advice-sheet`). Otherwise, work in the user's own structure, and use this skill.

**Authority order:** the installed source (`args(spict::fit.spict)`, `?spict::check.inp`,
`packageVersion("spict")`) > the SPiCT guidelines and GitHub (`DTUAqua/spict`) > the pack
knowledge below. State the version you checked.

## Read, as the task needs

| Need | Pack file |
|---|---|
| Input object, conventions, priors, reference points, scenarios | `knowledge/spict.md` |
| Acceptance checklist, hindcast, residuals, prior vs posterior | `knowledge/diagnostics.md` |
| The index contract and its timing | `knowledge/indices.md` |
| Catch sources and sanity checks | `knowledge/catch-data.md` |
| Moving from a fit to the chapter and advice | `knowledge/advice.md` |

## Checklist before trusting a fit

1. **Units and gaps.** Catches in tonnes, no missing years; index timing as a fraction of the
   year; index scaled by its own mean.
2. **`stdevfac` vectors average to 1.** They are multipliers, not standard deviations.
3. **Shape.** `logn` fixed at the Schaefer value unless a benchmark decided otherwise; the
   `logalpha`/`logbeta` priors off when `logsdb` is informative.
4. **Priors** have a stated source. A prior copied from another stock is a placeholder; check
   `plotspict.priors()` for posteriors on top of, or pushed against, the prior.
5. **Acceptance:** convergence, finite variances, OSA residual tests with p-values, Mohn's rho
   inside the stated bar, BMSY/K in 0.1–0.9, CI ratios, and `check.ini()` landing on one
   optimum. Report a verdict and one sentence per check.
6. **Reference points** are relative; Blim and MSY Btrigger come from the advice framework.
   Say whether deterministic or stochastic values are used.
7. **Scenarios** report tail risks (P(B < Blim), P(F > Fmsy)), not only medians.

## Writing and reviewing code

- Use `r-code-style` for any R created or edited, and the project's own style where it differs.
- The pack's `project-template/R/spict_helpers.R` encodes the conventions
  (`build_spict_input()`, `normalise_stdevfac()`, `acceptance_checks()`, `spictRisk()`). They
  read the scaffold's `cfg` and `ensure_packages()`, so do not source them into another
  project; reproduce the convention in the project's code and cite the helper.
- A survey index from sdmTMB comes from index-wise (`index-sdmtmb`); Biotic catches or
  samples come through BAIT.
- Retro, hindcast and `check.ini()` are slow: cache their results and note which fit they
  came from.
