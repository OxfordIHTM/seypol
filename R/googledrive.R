#'
#' List files and folders within SC Policy Google Drive
#'
#' A convenience wrapper to [googledrive] functions set to specifically access
#' the SC Policies Google Drive directory and list files and folders within.
#'
#' @param id Character vector of the SC Policies **Google Drive** id. This is
#'   currently set to *"1XlQM0Zte5dzc0-3cn7dA7kxaNjbN3OJQ"* which is the id of
#'   the SC Policies **Google Drive**. Change this if SC Policies
#'   **Google Drive** is moved.
#'
#' @return A dribble of names and ids of files and folders within the the
#'   SC Policies **Google Drive**
#'
#' @author Ernest Guevarra
#'
#' @examples
#' sc_policies_ls()
#'
#' @rdname sc_policies_ls
#' @export
#'
sc_policy_ls <- function(id = "1XlQM0Zte5dzc0-3cn7dA7kxaNjbN3OJQ") {
  ## Google Drive deauthorisation
  googledrive::drive_deauth()
  
  ## Get dribble of files and folders inside Open Marawi Google Drive
  googledrive::drive_get(id = id) |>
    googledrive::drive_ls()
}


#' 
#' Download files from Google Drive
#' 
#' @param id Google Drive identifier for the file to be downloaded.
#' @param path File path to where download file should go.
#' @param overwrite Logical. Should another file with the same filename
#'   be overwritten? Default is FALSE.
#'   
#' @returns Relative file path to downloaded file. Specified file downloaded 
#'   to specified path (invisible). 
#'   
#' @examples
#' download_googledrive(
#'   id = "1SgV4uzle7WQAtmAbKDfU8xgY3BhXG8k3",
#'   path = "data-raw/Policy Catalogue (26.02.24).pdf"
#' )
#' 
#' @export
#'
download_googledrive <- function(id, 
                                 path,
                                 overwrite = FALSE) {
  ## Google Drive deauthorisation ----
  googledrive::drive_deauth()
  
  ## Download file ----
  googledrive::drive_download(
    file = googledrive::as_id(id),
    path = path,
    overwrite = overwrite
  )
  
  ## Return path ----
  path
}

#'
#' Catalogue SC Policies Google Drive contents
#'
#' @param directory_name
#' @param sc_policy_drive_contents 
#' @param tabular Logical. Should output be a table/data.frame? Default is TRUE.
#'   If FALSE, output is in a list.
#'   
#' @returns A data.frame (if `tabular = TRUE`) or a list of Google Drive
#'   contents with name of file and Google Drive identifier.
#'

get_directory_contents <- function(directory_name,
                                   sc_policy_drive_contents) {
  ## Deauth ----
  googledrive::drive_deauth()
  
  ## Get contents ----
  
  ### PSO and RBM FRAMEWORK ----
  if (directory_name %in% c("PSO (copied)", "RBM FRAMEWORK (copied)")) {
    drive_contents <- sc_policy_drive_contents |>
      dplyr::filter(name == directory_name) |>
      dplyr::pull(id) |>
      googledrive::drive_ls(recursive = TRUE)
  }
  
  ### POLICY and GUIDELINE ----
  if (directory_name %in% c("POLICY", "GUIDELINE")) {
    drive_contents <- sc_policy_drive_contents |>
      dplyr::filter(name == directory_name) |>
      dplyr::pull(id) |>
      googledrive::drive_ls() |>
      dplyr::pull(id) |>
      lapply(FUN = googledrive::drive_ls) |>
      dplyr::bind_rows()
  }

  ### ACT ----
  if (directory_name == "ACT") {
    drive_contents <- sc_policy_drive_contents |>
      dplyr::filter(name == directory_name) |>
      dplyr::pull(id) |>
      googledrive::drive_ls() |>
      dplyr::pull(id) |>
      lapply(FUN = googledrive::drive_ls) |>
      dplyr::bind_rows()
      
    drive_contents <- rbind(
      drive_contents |>
        dplyr::filter(!googledrive::is_folder(drive_contents)),
      drive_contents |>
        dplyr::filter(googledrive::is_folder(drive_contents)) |>
        dplyr::pull(id) |>
        lapply(FUN = googledrive::drive_ls) |>
        dplyr::bind_rows()
    )
  }
  
  ### STRATEGY ----
  if (directory_name == "STRATEGY") {
    drive_contents <- sc_policy_drive_contents |>
      dplyr::filter(name == directory_name) |>
      dplyr::pull(id) |>
      googledrive::drive_ls() |>
      dplyr::pull(id) |>
      lapply(FUN = googledrive::drive_ls) |>
      dplyr::bind_rows()
    
    drive_contents <- rbind(
      drive_contents |>
        dplyr::filter(!googledrive::is_folder(drive_contents)),
      drive_contents |>
        dplyr::filter(googledrive::is_folder(drive_contents)) |>
        dplyr::pull(id) |>
        lapply(FUN = googledrive::drive_ls) |>
        dplyr::bind_rows()
    )
  }
  
  ### ACTION PLAN ----
  if (directory_name == "ACTION PLAN") {
    drive_contents <- sc_policy_drive_contents |>
      dplyr::filter(name == directory_name) |>
      dplyr::pull(id) |>
      googledrive::drive_ls() |>
      dplyr::pull(id) |>
      lapply(FUN = googledrive::drive_ls) |>
      dplyr::bind_rows()
    
    drive_contents <- rbind(
      drive_contents |>
        dplyr::filter(!googledrive::is_folder(drive_contents)),
      drive_contents |>
        dplyr::filter(googledrive::is_folder(drive_contents)) |>
        dplyr::pull(id) |>
        lapply(FUN = googledrive::drive_ls) |>
        dplyr::bind_rows()
    )
  }
  
  ## Check that drive_contents are all files ----
  assertthat::assert_that(
    all(!googledrive::is_folder(drive_contents)),
    msg = "Output should contain all files only."
  )
  
  ## Return tibble of drive contents ----
  drive_contents
}


create_drive_catalogue <- function(sc_policy_drive_contents,
                                   tabular = TRUE) {
  ## Deauth ----
  googledrive::drive_deauth()
  
  ## Get directory names ----
  directory_names <- sc_policy_drive_contents |>
    dplyr::filter(
      stringr::str_detect(
        string = name, pattern = "Policy Catalogue", negate = TRUE
      )
    ) |>
    dplyr::pull(name)
  
  ## Get directory contents ----
  directory_contents <- lapply(
    X = directory_names,
    FUN = get_directory_contents,
    sc_policy_drive_contents = sc_policy_drive_contents
  )
  
  ## Name outputs by their parent directory ---
  names(directory_contents) <- directory_names
  
  ## Flatten output ----
  if (tabular)
    dplyr::bind_rows(directory_contents, .id = "type")
  else
    directory_contents
}
