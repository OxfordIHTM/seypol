#'
#' Extract text from policy documents
#' 
#' @param file_name A file path to the policy document file
#' @param extractor An `{ellmer}` Chat object setup for OCR text extraction
#'   using LLM.
#' @param max_tries Number of OCR text extraction attempts to perform. Default is
#'   3.
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
    extracted_text <- pdftools::pdf_text(pdf = file_name)

    if (all(extracted_text == "")) {
      image_paths <- convert_pdf_to_image(pdf_file = file_name)
    
      extracted_text <- lapply(
        X = image_paths, FUN = extract_text_ocr,
        extractor = extractor, max_tries = max_tries
      )

      unlink(image_paths)
    }

    policy_md <- extracted_text |>
      unlist() |>
      paste(collapse = "\n")
  }

  names(policy_md) <- label
  
  policy_md
}


#'
#' Extract text using OCR via LLM
#' 
#' @param image_path File path to image from which text is to be extracted.
#' @param extractor An `{ellmer}` Chat object setup for OCR text extraction
#'   using LLM.
#' @param max_tries Number of OCR text extraction attempts to perform. Default is
#'   3.
#' 
#' @returns A character string of extracted text
#' 
#' @author Ernest Guevarra
#' 
#' @export
#' 

extract_text_ocr <- function(image_path, extractor, max_tries = 3L) {
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
