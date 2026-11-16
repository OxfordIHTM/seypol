#'
#' Convert PDF to image
#' 
#' @param pdf_file File path to the PDF file to be converted to image
#' @param format A string with desired output format of either "png" or "jpg".
#'   Default to "jpg".
#' 
#' @returns File path/s to the rendered image
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

convert_pdf_to_image <- function(pdf_file, format = "jpg") {
  destdir <- tempdir()

  pdf_pages <- seq_len(pdftools::pdf_info(pdf_file)$pages)

  file_path <- file.path(
    destdir, 
    basename(pdf_file) |>
      gsub(pattern = ".pdf", replacement = "", x = _) |>
      paste(
        stringr::str_pad(string = pdf_pages, width = 2, pad = "0"), 
        sep = "_"
      ) |>
      paste(format, sep = ".")
  )

  pdftools::pdf_convert(
    pdf = pdf_file, format = format, filenames = file_path, dpi = 72,
    antialias = "text", verbose = FALSE
  )

  file_path
}
