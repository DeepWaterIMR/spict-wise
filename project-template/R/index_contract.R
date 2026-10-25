# Read the stable interchange format from index-wise, with legacy compatibility.
read_assessment_index_handoff <- function(raw, selected_name, timing) {
  if (is.list(raw) && identical(raw$schema_version, 1L)) {
    if (!identical(raw$selected_name, selected_name)) {
      stop("Configured INDEX_ELEMENT does not match handoff selected_name.", call. = FALSE)
    }
    required <- c("units", "uncertainty", "index_type", "timing", "spatial_scope", "provenance")
    missing <- setdiff(required, names(raw$metadata))
    if (length(missing)) stop("Handoff metadata missing: ", paste(missing, collapse = ", "), call. = FALSE)
    if (!isTRUE(all.equal(as.numeric(raw$metadata$timing), as.numeric(timing)))) {
      stop("Handoff timing does not match INDEX_TIMING.", call. = FALSE)
    }
    return(list(observations = raw$observations, metadata = raw$metadata))
  }
  if (is.data.frame(raw)) return(list(observations = raw, metadata = NULL))
  if (is.list(raw) && !is.null(names(raw)) && selected_name %in% names(raw)) {
    return(list(observations = raw[[selected_name]], metadata = NULL))
  }
  stop("Unsupported index input. Provide a version 1 handoff, data frame, or named legacy list.", call. = FALSE)
}
