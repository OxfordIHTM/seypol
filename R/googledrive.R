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
#' @returns A dribble of names and ids of files and folders within the the
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
  
  ## Get dribble of files and folders inside Google Drive
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
#' @author Ernest Guevarra
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
#' @param directory_name Name of Google Drive directory to get contents from.
#' @param sc_policy_drive_contents A data.frame/dribble of SC policy Google
#'   Drive contents.
#'   
#' @returns A data.frame Google Drive contents with name of file and Google 
#'   Drive identifier.
#'   
#' @examples
#' get_directory_contents("ACT", sc_policy_drive_contents)
#'
#' @author Ernest Guevarra
#' 
#' @export
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


#'
#' Create SC Policy Google Drive catalogue
#' 
#' @param sc_policy_drive_contents A data.frame/dribble of SC policy Google
#'   Drive contents.
#' @param tabular Logical. Should output be a table or a list? Default to
#'   TRUE.
#'
#' @returns A data.frame (if `tabular = TRUE`) or a list for the SC policy 
#'   Google Drive catalogue
#'   
#' @examples
#' create_drive_catalogue(sc_policy_drive_contents)
#' 
#' @author Ernest Guevarra
#' 
#' @export
#'

create_drive_catalogue <- function(sc_policy_drive_contents) {
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
  
  ## Name outputs by their parent directory ----
  names(directory_contents) <- directory_names

  ## Create vector of policy documents to remove or keep ----
  index_docs_to_remove <- list(
    -c(6, 15, 17, 33, 35, 45, 50, 52, 53), 
    #-c(60, 66, 68, 72, 85:87, 89, 90, 100, 103),
    -c(2, 5:6, 9, 11, 15, 28:30, 32:33, 43, 46, 55),
    c(2:4, 6:22),
    1:8,
    -4,
    1,
    1:5
  )

  ## Remove DOC/DOCX duplicates and other non-policy docs ----
  #directory_contents <- directory_contents[index_docs_to_remove]

  directory_contents <- Map(
    function(x, a) x[a, ],
    x = directory_contents,
    a = index_docs_to_remove
  )
  
  ## Flatten output and process outputs ----
  directory_contents <- dplyr::bind_rows(directory_contents, .id = "type") |>
    create_policy_names()

  ## Return directory contents ----
  directory_contents
}
