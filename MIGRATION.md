# Migration to spict-wise

The repository is now named `spict-wise` at
[github.com/DeepWaterIMR/spict-wise](https://github.com/DeepWaterIMR/spict-wise), as part of
[Fiskwise](https://github.com/DeepWaterIMR/fiskwise), with its [project hub](https://deepwaterimr.github.io/fiskwise/). Skill IDs and folder names such as
`spict-install` remain stable.

New installs store configuration in `~/.spict-wise/config.json`. The compatible
`spict_template_path` key remains unchanged. The scaffolder also reads the former
`~/.spict-template/config.json`; the new config takes precedence when both are present. For the
wise-writing dependency it checks `~/.wise-writing/config.json` before the former
`~/.academic-writing/config.json`, and supports sibling clones named either `wise-writing` or
`academic-writing`.
