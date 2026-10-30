---
name: spict-render
description: Render the SPiCT project's Quarto documents safely — code-review first, run long renders detached with a log, and manage the caching toggles. Use whenever a SPiCT document needs compiling.
---

<!-- pack-resources:start -->
**Pack resources:** the `spict-wise` root is `~/.spict-wise/config.json` → `spict_template_path`, else `~/.fiskwise/config.json` →
`components.spict-wise.path`, else the checkout containing this skill. Paths such as `knowledge/`
and `project-template/` are relative to that root, never `../../` from a skills folder; resolve
links that leave this skill's folder against the source skill there. Use absolute paths.
<!-- pack-resources:end -->


# Render

Goal: get the documents compiled without wasting hours on a render that was going to fail on
line three.

Read `knowledge/rendering.md`.

## Review first

A SPiCT render fits a model, peels a retrospective, and runs a hindcast. The failure modes that
cost the most are the cheapest to catch by reading:

- A `!expr` caption whose object does not exist. `!expr` is evaluated even under `eval: false`.
- An object referenced before the chunk that builds it.
- A path that assumes the wrong working directory.
- A chunk label reused, so a cross-reference silently points at the wrong float.

**Review changed chunks and scripts and resolve findings before an expensive render.**
Use available review tools or a careful independent pass; `/code-review` is optional.

## What renders how

| Output | How |
|---|---|
| Any HTML preview | The Preview button in Positron, the Render button in RStudio, or `quarto render <file>` |
| The advice sheet, Word | `Rscript docs/render.R advice-sheet docx` |
| The working-group chapter, Word | `Rscript docs/render.R assessment-report docx` |
| Everything | `Rscript docs/render.R` |

Word must go through `docs/render.R`: it post-processes the output to unwrap Quarto's float
wrapper tables, without which the tables do not sit where the templates expect.

## The toggles

The assessment document caches the fit, the retrospective, the hindcast, and the initial-value
check to `data/output/`, each behind a parameter:

```yaml
params:
  refit: true
  run_retro: true
  run_hindcast: true
  run_check_ini: true
```

Run once with all four `true`; set them `false` while iterating on prose and tables; set them
back to `true` for the final render.

**A cached diagnostic that outlived its fit is worse than no diagnostic.** When the data, the
priors, or the settings change, invalidate the affected fit and dependent diagnostics rather than trusting the toggles;
preserve unrelated outputs and previous results. And
never add `freeze:` or `cache:` to a document silently — Quarto's own freezing produces a
document that disagrees with its own data, invisibly.

## Long renders

A benchmark-scale render — several candidates, each with a retrospective — takes hours. Run it
detached, with a unique log and completion status. Use the host background facility;
`screen` below is an optional Unix example, not a prerequisite. Create `logs/` first.
On Windows use PowerShell `Start-Process` with redirected stdout/stderr and retain the
process ID. Follow wise-writing’s `academic-conventions` rendering guidance for the shared
execution and cache-provenance contract.

For example:

```bash
screen -dmS spict-render bash -c 'Rscript docs/render.R > logs/render-$(date +%F-%H%M).log 2>&1'
```

Tell the user the session name and the log path. Reattach with `screen -r spict-render`; follow
progress with `tail -f`. Suggest a server for anything that will outlast a laptop lid.

## After the render

Check the output, do not assume it:

- The HTML title block shows the authors and the version date, and the sidebar heading matches
  the title.
- Code blocks are folded, not hidden — a data report with `echo: false` has silently stopped
  being a data report.
- The references section resolved; no `[@key?]` markers remain.
- Cross-references resolved; no `?fig-...` markers.
- In Word: heading styles came from the template, tables sit inline, and no table runs off the
  page.

## Common failures

| Symptom | Cause |
|---|---|
| `object 'cap_...' not found` in a caption | A `!expr` caption evaluated ahead of the chunk that builds its object |
| Paths break when previewing one document | `.here` missing from the project root |
| Word tables float to the end of a section | Rendered with the button instead of `docs/render.R` |
| Heading styles wrong in the `.docx` | The wrong `reference-doc` in the YAML |
| The render quietly uses last year's numbers | A cache that outlived its fit |
