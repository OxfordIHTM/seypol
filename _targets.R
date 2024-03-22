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
    name = sc_policies_drive_contents,
    command = sc_policies_ls(),
    cue = tar_cue("always")
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
