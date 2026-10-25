#' Validate a positive annual index with log-scale standard errors
#' @param x Index data frame with year, est and se columns.
#' @return The input invisibly, or an informative error.
validate_index_observations <- function(x) {
  required <- c("year", "est", "se")
  if (!is.data.frame(x) || !nrow(x) || !all(required %in% names(x))) {
    stop("Index needs non-empty year, est and se columns.", call. = FALSE)
  }
  if (!all(vapply(x[required], function(z) is.numeric(z) && all(is.finite(z)), logical(1))) ||
      any(x$year != floor(x$year)) || anyDuplicated(x$year) || any(x$est <= 0) || any(x$se <= 0)) {
    stop("Index requires unique integer years, finite positive estimates and positive log SEs.", call. = FALSE)
  }
  invisible(x)
}

# Read the stable interchange format from index-wise, with legacy compatibility.
read_assessment_index_handoff <- function(raw, selected_name, timing) {
  if (is.list(raw) && !is.data.frame(raw) && !is.null(raw$schema_version)) {
    if (!identical(raw$schema_version, 1L)) stop("Unsupported assessment-index schema version.", call. = FALSE)
    if (!identical(raw$selected_name, selected_name)) {
      stop("Configured INDEX_ELEMENT does not match handoff selected_name.", call. = FALSE)
    }
    required <- c("units", "uncertainty", "index_type", "timing", "spatial_scope", "provenance")
    missing <- setdiff(required, names(raw$metadata))
    if (length(missing)) stop("Handoff metadata missing: ", paste(missing, collapse = ", "), call. = FALSE)
    text_fields <- c("units", "index_type", "spatial_scope")
    if (!all(vapply(raw$metadata[text_fields], function(x) is.character(x) &&
        length(x) == 1L && !is.na(x) && nzchar(trimws(x)), logical(1)))) {
      stop("Handoff units, index_type and spatial_scope must be non-empty strings.", call. = FALSE)
    }
    uncertainty <- raw$metadata$uncertainty
    if (!is.list(uncertainty) || !identical(uncertainty$column, "se") ||
        !identical(uncertainty$scale, "log") || !identical(uncertainty$measure, "standard_error")) {
      stop("Handoff must supply se as standard_error on the log scale; convert explicitly at the producer.", call. = FALSE)
    }
    if (!is.list(raw$metadata$provenance) || !length(raw$metadata$provenance)) {
      stop("Handoff provenance must describe its source.", call. = FALSE)
    }
    if (length(timing) != 1L || !is.numeric(timing) || !is.finite(timing) || timing < 0 || timing > 1) {
      stop("INDEX_TIMING must be a finite fraction between 0 and 1.", call. = FALSE)
    }
    if (!isTRUE(all.equal(as.numeric(raw$metadata$timing), as.numeric(timing)))) {
      stop("Handoff timing does not match INDEX_TIMING.", call. = FALSE)
    }
    validate_index_observations(raw$observations)
    return(list(observations = raw$observations, metadata = raw$metadata))
  }
  if (is.data.frame(raw)) return(list(observations = raw, metadata = NULL))
  if (is.list(raw) && !is.null(names(raw)) && selected_name %in% names(raw)) {
    return(list(observations = raw[[selected_name]], metadata = NULL))
  }
  stop("Unsupported index input. Provide a version 1 handoff, data frame, or named legacy list.", call. = FALSE)
}
