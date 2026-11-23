#'
#' Format text to markdown
#' 
#' @param text A character string of text to format to Markdown
#' @param formatter An `{ellmer}` Chat object setup for formatting text to
#'   Markdown using LLM.
#' 
#' @returns A character string of Markdown-formatted text
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

format_text_to_markdown <- function(text, formatter) {
  formatted_text <- lapply(
    X = unlist(text, recursive = FALSE),
    FUN = function(x) {
      formatter <- formatter$set_turns(list())

      formatter$chat_structured(
        x,
        type = ellmer::type_array(ellmer::type_string())
      )
    }
  )

  formatted_text |>
    unlist() |>
    paste(collapse = "\n")
}
