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
#
################################################################################

sc_policies_ls <- function(id = "1XlQM0Zte5dzc0-3cn7dA7kxaNjbN3OJQ") {
  ## Google Drive deauthorisation
  googledrive::drive_deauth()
  
  ## Get dribble of files and folders inside Open Marawi Google Drive
  googledrive::drive_ls(googledrive::drive_get(id = id))
}
