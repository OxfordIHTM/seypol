#'
#' Create Seychelles policy store for RAG
#' 
#' @param 
#' 

create_policy_store <- function(chunks, location, model, overwrite = FALSE) {
  if (overwrite | !file.exists(location)) {
    sc_policy_store <- ragnar::ragnar_store_create(
      location = location,
      embed = function(x) ragnar::embed_ollama(
        x = x, base_url = Sys.getenv("OLLAMA_BASE_URL"), 
        model = model
      )
    )
  } else {
    sc_policy_store <- ragnar::ragnar_store_connect(
      location = location, read_only = FALSE
    )
  }

  lapply(
    X = chunks,
    FUN = function(x) ragnar::ragnar_store_insert(
      store = sc_policy_store, chunks = x
    )
  )
}
