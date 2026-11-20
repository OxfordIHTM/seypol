#'
#' Create and store a markdown document
#' 
#' @param markdown_text A character string of text extracted from a policy
#'   document.
#' @param policy_label A corresponding label for the policy from which
#'   `markdown_text` has been extracted from.
#' @param directory A character value for the directory to store/save the
#'   created markdown document.
#' 
#' @returns A file path to the stored/saved markdown document.
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

create_markdown_doc <- function(markdown_text, policy_label, directory) {
  file_path <- file.path(directory, paste0(policy_label, ".md"))

  strsplit(x = markdown_text, split = "\n")[[1L]] |>
    writeLines(con = file_path)

  file_path
}
