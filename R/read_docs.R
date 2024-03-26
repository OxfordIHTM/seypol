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
    dplyr::filter(stringr::str_detect(string = name, pattern = ".docx|.doc")) |>
    dplyr::pull(name) |>
    stringr::str_remove_all(pattern = ".docx|.doc")
  
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