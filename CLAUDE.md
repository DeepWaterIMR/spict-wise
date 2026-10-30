@AGENTS.md

# Claude Code notes

- **Skills** live in `~/.claude/skills/spict-*`. Invoke the matching skill to compile data,
  fit, explore or report; outside a scaffolded project, use `spict-model`. Defer prose and
  document structure to `academic-*`, survey indices to `index-*`, and Biotic data to `biotic-*`.
- **Project memory, not local memory.** Inside a generated project, use its `ai/memory/`
  folder; in this pack, use `memory/`. Do not put project facts in
  `~/.claude/projects/.../memory/`.
- **Plan mode** after the `spict-new-assessment` questionnaire, before scaffolding.
- **Code review before render**: run `/code-review` on changed chunks. See `knowledge/rendering.md`.
- **This is a template repository.** Documents under `project-template/` contain
  `{{STOCK_NAME}}` placeholders that resolve only after `scaffold_spict()`; do not render them
  here. Stock-specific priors, narrative and data belong in the generated project; fixes to
  `docs/render.R` or `R/0_setup.R` belong in wise-writing.
