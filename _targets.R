################################################################################
#
# Workflow for the Review of Seychelles Ministry of Health Five-Year Plan
#
################################################################################

## Load libraries and custom functions -----------------------------------------
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

## Create targets and list targets objects -------------------------------------

### Data targets
data_targets <- tar_plan(
  ## Get directory contents of SC Policies Google Drive ----
  tar_target(
    name = sc_policy_drive_contents,
    command = sc_policy_ls(),
    cue = tar_cue("thorough")
  ),
  ## Get file info for SC policies catalogue ----
  tar_target(
    name = sc_policy_catalogue_info,
    command = get_sc_policy_catalogue_info(sc_policy_drive_contents)
  ),
  ## Download SC policies catalogue ----
  tar_target(
    name = sc_policy_catalogue_file,
    command = download_googledrive(
      id = sc_policy_catalogue_info[[1]], 
      path = file.path("data-raw", sc_policy_catalogue_info[[2]]),
      overwrite = TRUE
    ),
    format = "file"
  ),
  ## Read SC policies catalogue ----
  tar_target(
    name = sc_policy_catalogue_text,
    command = read_sc_policy_catalogue(sc_policy_catalogue_file)
  ),
  ## Create SC Policies Google Drive catalogue ----
  tar_target(
    name = sc_policy_drive_catalogue,
    command = create_drive_catalogue(sc_policy_drive_contents)
  ),
  ## Get Google Drive identifiers for pdf documents ----
  tar_target(
    name = sc_policy_pdf_docs_ids,
    command = get_pdf_docs_ids(sc_policy_drive_catalogue)
  ),
  ## Extract text from pdfs ----
  tar_target(
    name = sc_policy_pdf_docs_text,
    command = read_pdf_doc(sc_policy_pdf_docs_ids),
    pattern = map(sc_policy_pdf_docs_ids),
    iteration = "list"
  ),
  ## Get Google Drive identifiers for DOC/DOCX documents ----
  tar_target(
    name = sc_policy_word_docs_ids,
    command = get_word_docs_ids(sc_policy_drive_catalogue)
  ),
  ## Extract text from word docs ----
  tar_target(
    name = sc_policy_word_docs_text,
    command = read_word_doc(sc_policy_word_docs_ids),
    pattern = map(sc_policy_word_docs_ids),
    iteration = "list"
  )
)


### Processing targets
processing_targets <- tar_plan(
  
)


### Analysis targets
analysis_targets <- tar_plan(
  
)


### Output targets
output_targets <- tar_plan(
  
)


### Reporting targets
report_targets <- tar_plan(
  
)


### Deploy targets
deploy_targets <- tar_plan(
  
)


## List targets
all_targets()
