#'
#' Create Seychelles policy store for RAG
#' 
#' @param chunks
#' @param location
#' @param model
#' @param overwrite
#' 
#' @returns
#' 
#' @author Ernest Guevarra
#' 
#' @examples
#' 
#' @export
#' 

create_policy_store <- function(chunks, location, model, overwrite = FALSE) {
  ## If policy store doesn't exist or overwrite ----
  if (overwrite | !file.exists(location)) {
    sc_policy_store <- ragnar::ragnar_store_create(
      location = location,
      embed = function(x) ragnar::embed_ollama(
        x = x, base_url = Sys.getenv("OLLAMA_BASE_URL"), 
        model = model
      ),
      overwrite = overwrite,
      name = "sc-policy-store",
      title = "Seychelles Policy Store"
    )

    lapply(
      X = chunks,
      FUN = function(x) ragnar::ragnar_store_insert(
        store = sc_policy_store, chunks = x
      )
    )
  }

  ## If policy store exists and do not overwrite ----
  if (file.exists(location) & !overwrite) {
    sc_policy_store <- ragnar::ragnar_store_connect(
      location = location, read_only = FALSE
    )

    lapply(
      X = chunks,
      FUN = function(x) ragnar::ragnar_store_update(
        store = sc_policy_store, chunks = x
      )
    )
  }

  ## Build store index ----
  ragnar::ragnar_store_build_index(store = sc_policy_store)
  
  ## Shutdown connection to sc_policy_store ----
  duckdb::duckdb_shutdown(drv = duckdb::duckdb(dbdir = location))

  ## Return path to sc-policy-store.duckdb ----
  location
}
