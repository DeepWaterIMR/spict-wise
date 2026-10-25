source("project-template/R/index_contract.R")
ensure_packages <- function(...) invisible(NULL)
source("project-template/R/spict_helpers.R")
observations <- data.frame(year = 2020:2021, est = c(10, 12), lwr = c(8, 9), upr = c(12, 15), se = c(.1, .2))
metadata <- list(units = "relative", uncertainty = list(column = "se", scale = "log", measure = "standard_error"), index_type = "survey biomass",
                 timing = .5, spatial_scope = "synthetic", provenance = list(project = "test"))
handoff <- list(schema_version = 1L, selected_name = "total", observations = observations, metadata = metadata)
parsed <- read_assessment_index_handoff(handoff, "total", .5)
stopifnot(identical(parsed$observations, observations), identical(parsed$metadata, metadata))
expect_error <- function(expr) stopifnot(inherits(try(force(expr), silent = TRUE), "try-error"))
expect_error(read_assessment_index_handoff(handoff, "other", .5))
expect_error(read_assessment_index_handoff(handoff, "total", .25))
expect_error(read_assessment_index_handoff(list(schema_version = 1L, selected_name = "total",
  observations = observations, metadata = list()), "total", .5))
legacy <- read_assessment_index_handoff(list(total = observations), "total", .5)
stopifnot(is.null(legacy$metadata), identical(legacy$observations, observations))
stopifnot(isTRUE(all.equal(normalise_stdevfac(c(1, 2)), c(2/3, 4/3))))
expect_error(normalise_stdevfac(c(1, NA_real_)))
expect_error(normalise_stdevfac(c(1, Inf)))
expect_error(normalise_stdevfac(c(1, 0)))
message("Synthetic assessment-index consumer contract passed.")

bad <- handoff
bad$metadata$uncertainty$scale <- "natural"
expect_error(read_assessment_index_handoff(bad, "total", .5))
bad <- handoff
bad$schema_version <- 2L
expect_error(read_assessment_index_handoff(bad, "total", .5))
bad <- observations
bad$est[1] <- 0
expect_error(validate_index_observations(bad))
bad <- observations
bad$year[2] <- bad$year[1]
expect_error(validate_index_observations(bad))
# Exercise the actual producer when the sibling checkout is available.
producer <- "../index-wise/project-template/R/assessment_index_handoff.R"
if (file.exists(producer)) {
  source(producer)
  produced <- build_assessment_index_handoff(list(total = observations), "total", metadata)
  stopifnot(identical(read_assessment_index_handoff(produced, "total", .5)$observations, observations))
}
