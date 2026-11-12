#'
#' Get identifiers for PDF documents
#' 
#' @param catalogue A data.frame of all the files in the SC policy Google Drive
#' 
#' @returns A vector of Google Drive identifiers for each file in `catalogue`
#' 
#' @auther Ernest Guevarra 
#' 
#' @export
#'

get_pdf_docs_ids <- function(catalogue) {
  catalogue |>
    dplyr::filter(stringr::str_detect(name, pattern = ".pdf")) |>
    dplyr::pull(id)
}


#'
#' Read the raw text of a PDF document from the SC Google Drive catalogue
#' 
#' @param id A Google Drive identifier of an SC policy document
#' 
#' @returns A list of text extraction from each page of the PDF document with 
#'   each element of the list corresponding to each page of the PDF document.
#'   
#' @author Ernest Guevarra
#' 
#' @export
#'
read_pdf_doc <- function(id) {
  file_path <- tempfile()
  
  download_googledrive(
    id = id,
    path = file_path,
    overwrite = TRUE
  )
  
  pdftools::pdf_text(pdf = file_path) |>
    stringr::str_split(pattern = "\n")
}



get_word_docs_ids <- function(catalogue) {
  doc_files_names <- catalogue |>
    dplyr::filter(stringr::str_detect(
      string = name, 
      pattern = ".docx.docx|.docx.doc|.doc.docx|.docx")
    ) |>
    dplyr::pull(name) |>
    stringr::str_remove_all(
      pattern = ".doc.docx|.docx.docx|.docx.doc|.docx"
    )
  
  pdf_files_names <- catalogue |>
    dplyr::filter(stringr::str_detect(string = name, pattern = ".pdf|.PDF")) |>
    dplyr::pull(name) |>
    stringr::str_remove_all(pattern = ".pdf|.PDF")
  
  doc_files_names_no_pdf <- doc_files_names[!doc_files_names %in% pdf_files_names]
  
  catalogue |>
    dplyr::filter(
      stringr::str_detect(
        string = name, pattern = paste(doc_files_names_no_pdf, collapse = "|")
      )
    ) |>
    dplyr::filter(!tools::file_ext(name) %in% c("doc", "pdf")) |>
    dplyr::pull(id)
}


read_word_doc <- function(id) {
  file_dir <- tempdir()
  
  download_googledrive(
    id = id,
    path = file.path(file_dir, paste0(id, ".docx")),
    overwrite = TRUE
  )
  
  officer::read_docx(file.path(file_dir, paste0(id, ".docx"))) |>
    officer::docx_summary() |>
    dplyr::pull(text)
}


#'
#' Convert policy documents to markdown
#' 
#' @param id A Google Drive identifier of an SC policy document
#' @param label A character object to label the markdown text of the policy
#'   document
#' @param directory A character value for the directory to download the policy
#'   documents to before conversion
#' 
#' @returns A markdown object of the policy document
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

convert_to_markdown <- function(file_name, directory, id, label) {
  ext <- file_name |>
    stringr::str_extract_all(pattern = ".pdf|.PDF|.docx|.doc") |>
    lapply(FUN = function(x) x[length(x)] |> tolower()) |>
    unlist()

  file_path <- file.path(directory, paste0(label, ext))
  
  download_googledrive(
    id = id,
    path = file_path,
    overwrite = TRUE
  )

  ## docs that have empty markdowns ----
  x <- c(
    "act-08-2014_food-act",
    "act-13-2015_public-health-act",
    "act-09-2003_data-protection-act",
    "apl-xx-xxxx_seychelles-national-plan-for-people-with-dementia",
    "crc-02-2021_results-based-management-framework"
  )


  
  ragnar::read_as_markdown(path = file_path, origin = label)
}
