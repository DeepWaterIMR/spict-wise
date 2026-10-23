#!/usr/bin/env Rscript

# Isolated config migration and dry-scaffold checks. Run from any directory with:
#
#   Rscript /path/to/spict-wise/config/test-migration.R
#
# A child R process receives a temporary HOME so these tests never read or write user config.

args <- commandArgs(trailingOnly = TRUE)
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_path <- sub("^--file=", "", script_arg[[1]])
script_path <- gsub("~\\+~", " ", script_path)
script <- normalizePath(script_path)
repo <- normalizePath(file.path(dirname(script), ".."))

valid_pack <- function(path, scaffold = FALSE) {
  dir.create(file.path(path, "project-template"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(path, "skills"), recursive = TRUE, showWarnings = FALSE)
  if (scaffold) file.create(file.path(path, "scaffold.R"))
  normalizePath(path)
}

write_config <- function(path, key, value) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(setNames(list(value), key), path, auto_unbox = TRUE)
}

run_worker <- function(base) {
  home <- path.expand("~")
  cfg <- function(name) file.path(home, name, "config.json")
  fake_aw_new <- valid_pack(file.path(base, "wise-new"), scaffold = TRUE)
  fake_aw_old <- valid_pack(file.path(base, "wise-old"), scaffold = TRUE)
  fake_sp_new <- valid_pack(file.path(base, "spict-new"))
  fake_sp_old <- valid_pack(file.path(base, "spict-old"))

  source(file.path(repo, "..", "wise-writing", "scaffold.R"))
  write_config(cfg(".wise-writing"), "academic_writing_path", fake_aw_new)
  write_config(cfg(".academic-writing"), "academic_writing_path", fake_aw_old)
  stopifnot(identical(.find_pack_root(), fake_aw_new))
  stopifnot(identical(.find_pack_root(pack = file.path(base, "missing")), fake_aw_new))

  # A stale new config must not mask a valid legacy config.
  write_config(cfg(".wise-writing"), "academic_writing_path", file.path(base, "gone"))
  stopifnot(identical(.find_pack_root(), fake_aw_old))
  unlink(cfg(".wise-writing"))
  stopifnot(identical(.find_pack_root(), fake_aw_old))

  source(file.path(repo, "scaffold.R"))
  write_config(cfg(".spict-wise"), "spict_template_path", fake_sp_new)
  write_config(cfg(".spict-template"), "spict_template_path", fake_sp_old)
  stopifnot(identical(.find_spict_pack(), fake_sp_new))
  stopifnot(identical(.find_spict_pack(pack = file.path(base, "missing")), fake_sp_new))
  write_config(cfg(".spict-wise"), "spict_template_path", file.path(base, "gone"))
  stopifnot(identical(.find_spict_pack(), fake_sp_old))
  unlink(cfg(".spict-wise"))
  stopifnot(identical(.find_spict_pack(), fake_sp_old))

  write_config(cfg(".wise-writing"), "academic_writing_path", fake_aw_new)
  write_config(cfg(".academic-writing"), "academic_writing_path", fake_aw_old)
  stopifnot(identical(.find_academic_writing(spict_pack = fake_sp_new), fake_aw_new))
  write_config(cfg(".wise-writing"), "academic_writing_path", file.path(base, "gone"))
  stopifnot(identical(.find_academic_writing(spict_pack = fake_sp_new), fake_aw_old))

  # With configs absent, both new and legacy sibling clone names remain supported.
  unlink(c(cfg(".wise-writing"), cfg(".academic-writing")))
  siblings <- file.path(base, "siblings")
  fake_sp_sibling <- valid_pack(file.path(siblings, "spict-wise"))
  fake_aw_sibling <- valid_pack(file.path(siblings, "wise-writing"), scaffold = TRUE)
  stopifnot(identical(.find_academic_writing(spict_pack = fake_sp_sibling), fake_aw_sibling))
  unlink(fake_aw_sibling, recursive = TRUE)
  fake_aw_sibling <- valid_pack(file.path(siblings, "academic-writing"), scaffold = TRUE)
  stopifnot(identical(.find_academic_writing(spict_pack = fake_sp_sibling), fake_aw_sibling))

  # Exercise a real dry scaffold using new config paths. It must resolve both packs and create
  # no target directory.
  unlink(c(cfg(".wise-writing"), cfg(".academic-writing"),
           cfg(".spict-wise"), cfg(".spict-template")))
  write_config(cfg(".wise-writing"), "academic_writing_path",
               normalizePath(file.path(repo, "..", "wise-writing")))
  write_config(cfg(".spict-wise"), "spict_template_path", repo)
  target <- file.path(base, "dry-project")
  scaffold_spict(file.path(repo, "examples", "redfish", "config.yaml"),
                 target, dry = TRUE)
  stopifnot(!dir.exists(target))
  invisible(TRUE)
}

if (length(args) >= 1L && identical(args[[1]], "--worker")) {
  run_worker(normalizePath(args[[2]]))
} else {
  base <- tempfile("spict-migration-test-")
  home <- file.path(base, "home")
  dir.create(home, recursive = TRUE)
  status <- system2(file.path(R.home("bin"), "Rscript"),
                    args = c(shQuote(script), "--worker", shQuote(base)),
                    env = paste0("HOME=", home))
  unlink(base, recursive = TRUE)
  stopifnot(identical(status, 0L))
  cat("test-migration.R: config precedence, stale-config fallback, sibling paths, and dry scaffold passed.\n")
}
