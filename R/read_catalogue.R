#'
#'
#'
#'
#'
#'

get_sc_policy_catalogue_info <- function(sc_policy_drive_contents) {
  file_name <- sc_policy_drive_contents |>
    dplyr::filter(stringr::str_detect(name, "Policy Catalogue")) |>
    dplyr::pull(name)
  
  file_id <- sc_policy_drive_contents |>
    dplyr::filter(stringr::str_detect(name, "Policy Catalogue")) |>
    dplyr::pull(id)
  
  list(file_id, file_name)
}


#'
#' Read policy catalogue
#'

read_sc_policy_catalogue <- function(sc_policy_catalogue_file) {
  pdftools::pdf_text(sc_policy_catalogue_file) |>
    stringr::str_split(pattern = "\n")
}

#'
#' Process SC policy catalogue
#'

process_sc_policy_catalogue <- function(sc_policy_catalogue_text) {
  ## Process page 2 ----
  sc_policy_catalogue_text[[2]] |>
    (\(x) x[4:38])()
}


detect_duplicate_docs <- function() {
  
}