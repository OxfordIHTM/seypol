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
  formatter <- formatter$set_turns(list())

  lab <- text |> names()

  exceptions <- c(
    "act-08-2014_food-act", "act-13-2015_public-health-act",
    "act-03-2023_communications-act", "act-09-2003_data-protection-act",
    "act-22-2011_customs-management-act",
    "apl-xx-xxxx_seychelles-national-plan-for-people-with-dementia",
    "crc-02-2021_results-based-management-framework"
  )

  if (!lab %in% exceptions) {
    formatted_text <- formatter$chat_structured(
      text,
      type = ellmer::type_array(ellmer::type_string())
    )
  } else {
    formatted_text <- text
  }

  formatted_text
}