#'
#' Extract text from policy documents
#' 
#' @param file_name A file path to the policy document file
#' @param extractor
#' @param max_tries
#' 
#' @returns A string of extracted text
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

extract_text <- function(file_name, extractor, max_tries = 3L) {
  ext <- file_name |>
    stringr::str_extract_all(pattern = ".pdf|.docx") |>
    unlist()

  label <- basename(file_name) |>
    tools::file_path_sans_ext()

  if (ext == ".docx") {
    policy_md <- ragnar::read_as_markdown(path = file_name, origin = label)
    policy_md <- as.character(policy_md)
  } else {
    image_paths <- convert_pdf_to_image(pdf_file = file_name)

    # extracted_text <- vector(
    #   mode = "list", length = pdftools::pdf_info(pdf = file_name)$page
    # )

    # for (i in seq_len(length(image_paths))) {

    #   for (attempt in seq_len(max_tries)) {
    #     extractor <- extractor$set_turns(list())
    
    #     extracted_text[[i]] <- tryCatch(
    #       extractor$chat_structured(
    #         ellmer::content_image_file(image_paths[i]),
    #         type = ellmer::type_array(ellmer::type_string())
    #       ),
    #       error = function(e) {
    #         if (attempt == max_tries) {
    #           cli::cli_abort(
    #             "Structured text extraction failed after {max_tries} attempt/s.",
    #             parent = e
    #           )
    #         }
    #         cli::cli_warn(
    #           "Text extraction attempt {attempt}/{max_tries} failed ({conditionMessage(e)}); retrying."
    #         )
    #         NULL
    #       }
    #     )
    #   }
    # }

    extracted_text <- lapply(
      X = image_paths, FUN = get_text,
      extractor = extractor, max_tries = max_tries
    )

    unlink(image_paths)

    policy_md <- extracted_text |>
      unlist() |>
      paste(collapse = "\n")
  }

  names(policy_md) <- label
  
  policy_md
}



get_text <- function(image_path, extractor, max_tries = 3L) {
  for (attempt in seq_len(max_tries)) {
    extractor <- extractor$set_turns(list())
    
    extracted_text <- tryCatch(
      extractor$chat_structured(
        ellmer::content_image_file(image_path),
        type = ellmer::type_array(ellmer::type_string())
      ),
      error = function(e) {
        if (attempt == max_tries) {
          cli::cli_abort(
            "Structured text extraction failed after {max_tries} attempt/s.",
            parent = e
          )
        }
        cli::cli_warn(
          "Text extraction attempt {attempt}/{max_tries} failed ({conditionMessage(e)}); retrying."
        )
        NULL
      }
    )
    
  }
  
  extracted_text
}
