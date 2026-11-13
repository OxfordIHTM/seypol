#'
#' Convert policy documents to markdown
#' 
#' @param file_name The file path to the policy document to be converted.
#' @param directory A character value for the directory to download the policy
#'   documents to before conversion.
#' @param id A Google Drive identifier of an SC policy document.
#' @param label A character object to label the markdown text of the policy
#'   document.
#' @param overwrite Logical. Should an already locally downloaded policy document
#'   be overwritten. Default is FALSE.
#' @param prompt A character string for the prompt to use with LLM to extract
#'   text from policy documents that cannot be converted by markitdown.
#' 
#' @returns A markdown object of the policy document.
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

convert_to_markdown <- function(file_name, directory, id, label,
                                overwrite = FALSE, prompt) {
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
  
  policy_md <- ragnar::read_as_markdown(path = file_path, origin = label)

  policy_md <- as.character(policy_md)

  ## docs that have empty markdowns ----
  # text_from_image <- c(
  #   "act-08-2014_food-act",
  #   "act-13-2015_public-health-act",
  #   "act-09-2003_data-protection-act",
  #   "apl-xx-xxxx_seychelles-national-plan-for-people-with-dementia",
  #   "crc-02-2021_results-based-management-framework"
  # )

  if (policy_md == "") {
    image_paths <- convert_pdf_to_image(pdf_file = file_path)

    claude_extractor <- ellmer::chat_claude(
      system_prompt = prompt, model = "claude-opus-5-5", echo = "none"
    )

    extracted_text <- vector(
      mode = "list", length = pdftools::pdf_info(pdf = file_path)$page
    )

    for (i in seq_len(length(image_paths))) {
      claude_extractor <- claude_extractor$set_turns(list())
      
      extracted_text[[i]] <- claude_extractor$chat_structured(
        ellmer::content_image_file(image_paths[i]),
        type = ellmer::type_string()
      )
    }

    policy_md <- paste(extracted_text, collapse = "\n")

    unlink(image_paths)
  }

  names(policy_md) <- label

  policy_md
}
