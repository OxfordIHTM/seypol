#'
#' Create and store a markdown document
#' 
#' @param markdown_text A MarkdownDocument object
#' @param directory A character value for the directory to store/save the
#'   created markdown document
#' 
#' @returns A file path to the stored/saved markdown document
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

create_markdown_doc <- function(markdown_text, directory) {
  file_path <- file.path(directory, paste0(markdown_text@origin, ".md"))

  strsplit(x = markdown_text, split = "\n")[[1L]] |>
    writeLines(con = file_path)

  file_path
}
