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
  sc_policy_drive_catalogue |>
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


