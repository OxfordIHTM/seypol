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

extract_text <- function(file_name, file_type, extractor, max_tries = 3L) {
  label <- basename(file_name) |>
    tools::file_path_sans_ext()

  if (file_type == "word") {
    extracted_text <- extract_text_ragnar(file_name = file_name, label = label)
  }

  if (file_type == "pdf") {
    extracted_text <- pdftools::pdf_text(pdf = file_name)
  }

  if (file_type == "image") {
    image_paths <- convert_pdf_to_image(pdf_file = file_name)
    
    extracted_text <- lapply(
      X = image_paths, FUN = extract_text_ocr,
      extractor = extractor, max_tries = max_tries
    )

    unlink(image_paths)
  }

  policy_md <- list(extracted_text)

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


#'
#' Extract text using {ragnar} package
#' 
#' @param file_name A file path to the policy document file.
#' 
#' 

extract_text_ragnar <- function(file_name, label) {
  ## Extract text using ragnar ----
  extracted_text <- ragnar::read_as_markdown(path = file_name, origin = label)

  ## Split text into lines and then split into lines of 50 ----
  xx <- extracted_text |>
    strsplit(split = "\n") |>
    unlist()

  extracted_text <- split(x = xx, f = ceiling(seq_len(length(xx)) / 50)) |>
    lapply(FUN = paste, collapse = "\n")

  names(extracted_text) <- NULL

  extracted_text
}