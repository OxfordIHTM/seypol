#'
#' Download SC policy documents locally
#' 
#' 
#' 

download_policy_docs <- function(file_name, directory,id, label, overwrite = FALSE) {
  ext <- file_name |>
    stringr::str_extract_all(pattern = ".pdf|.PDF|.docx|.doc") |>
    lapply(FUN = function(x) x[length(x)] |> tolower()) |>
    unlist()

  file_path <- file.path(directory, paste0(label, ext))

  if (!file.exists(file_path)) {
    download_googledrive(id = id, path = file_path)
  } else {
    if (overwrite)
      download_googledrive(id = id, path = file_path, overwrite = TRUE)
  }

  file_path
}
