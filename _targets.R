# Workflow for curating Seychelles Policies ------------------------------------


## Load libraries and custom functions ----
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)


## LLM targets ----
llm_targets <- tar_plan(
  ### Ollama vision/ocr model ----
  local_gemma_model = "gemma4:31b",

  ### Ollama embedding model ----
  local_gemma_embedding_model = "embeddinggemma-2:740m",
  
  ### Prompt for text extraction ----
  tar_target(
    name = text_extraction_task_prompt,
    command = ellmer::interpolate_file("prompts/text_extraction_task_prompt.md"),
    cue = tar_cue("always")
  ),

  ### Prompt for text to markdown format ----
  tar_target(
    name = format_to_markdown_prompt,
    command = ellmer::interpolate_file("prompts/format_to_markdown_prompt.md"),
    cue = tar_cue("always")
  ),

  ### Create gemma extractor ----
  tar_target(
    name = gemma_extractor,
    command = ellmer::chat_ollama(
      system_prompt = text_extraction_task_prompt, 
      model = local_gemma_model,
      params = params(reasoning_effort = "none"),
      echo = "none"
    )
  ),

  ### Create gemma markdown formatter ----
  tar_target(
    name = gemma_formatter,
    command = ellmer::chat_ollama(
      system_prompt = format_to_markdown_prompt, 
      model = local_gemma_model,
      params = params(reasoning_effort = "none"),
      echo = "none"
    )
  )
)

## Data targets
data_targets <- tar_plan(
  ### Get directory contents of SC Policies Google Drive ----
  tar_target(
    name = sc_policy_drive_contents,
    command = sc_policy_ls(),
    cue = tar_cue("thorough")
  ),

  ### Create SC Policies Google Drive catalogue ----
  tar_target(
    name = sc_policy_drive_catalogue,
    command = create_drive_catalogue(sc_policy_drive_contents)
  ),

  ### Get the original file names of the policy documents ----
  tar_target(
    name = sc_policy_docs_file_names,
    command = sc_policy_drive_catalogue$name
  ),

  ### Get the file types of the policy documents ----
  tar_target(
    name = sc_policy_docs_file_types,
    command = sc_policy_drive_catalogue$file_type
  ),

  ### Get the Google Drive ids of the policy documents ----
  tar_target(
    name = sc_policy_docs_ids,
    command = as.character(sc_policy_drive_catalogue$id)
  ),

  ### Get the long names of the policy documents ----
  tar_target(
    name = sc_policy_docs_labels,
    command = sc_policy_drive_catalogue$long_name
  ),

  ### Download policy documents locally ----
  tar_target(
    name = sc_policy_downloads,
    command = download_policy_docs(
      file_name = sc_policy_docs_file_names, directory = "data-raw/policies", 
      id = sc_policy_docs_ids, label = sc_policy_docs_labels
    ),
    pattern = map(
      sc_policy_docs_file_names, sc_policy_docs_ids, sc_policy_docs_labels
    ),
    format = "file"
  ),

  ### Extract markdown text from policy documents ----
  tar_target(
    name = sc_policy_text,
    command = extract_text(
      file_name = sc_policy_downloads, file_type = sc_policy_docs_file_types,
      extractor = gemma_extractor
    ),
    pattern = map(sc_policy_downloads, sc_policy_docs_file_types),
    iteration = "list"
  ),

  ### Convert policy documents to markdown ----
  tar_target(
    name = sc_policy_markdown,
    command = format_text_to_markdown(
      text = sc_policy_text, formatter = gemma_formatter
    ),
    pattern = map(sc_policy_text),
    iteration = "list"
  ),

  ### Create policy documents markdown file ----
  tar_target(
    name = sc_policy_markdown_file,
    command = create_markdown_doc(
      markdown_text = sc_policy_markdown,
      policy_label = sc_policy_docs_labels,
      directory = "sc-policy-knowledge/documents"
    ),
    pattern = map(sc_policy_markdown, sc_policy_docs_labels),
    format = "file"
  )
)


## RAG targets ----
rag_targets <- tar_plan(
  ## Specify policy store location ----
  sc_policy_store_location = "sc-policy-store.duckdb",

  ## Add origin to policy markdowns ----
  tar_target(
    name = sc_policy_markdown_origins,
    command = ragnar::MarkdownDocument(
      text = sc_policy_markdown, origin = sc_policy_docs_labels
    ),
    pattern = map(sc_policy_markdown, sc_policy_docs_labels),
    iteration = "list"
  ),

  ## Chunk up policy markdowns ----
  tar_target(
    name = sc_policy_markdown_chunks,
    command = ragnar::markdown_chunk(md = sc_policy_markdown_origins),
    pattern = map(sc_policy_markdown_origins),
    iteration = "list"
  ),

  ## Create policy store and insert markdown chunks to policy store ----
  tar_target(
    name = sc_policy_store,
    command = create_policy_store(
      chunks = sc_policy_markdown_chunks, location = sc_policy_store_location,
      model = local_gemma_embedding_model, overwrite = FALSE
    ),
    format = "file"
  )
)


## Processing targets
processing_targets <- tar_plan(
  
)


## Analysis targets
analysis_targets <- tar_plan(
  
)


## Output targets
output_targets <- tar_plan(
  
)


## Reporting targets
report_targets <- tar_plan(
  tar_render(
    name = sc_policy_data_review_report,
    path = "reports/sc_policy_data_review.Rmd",
    knit_root_dir = here::here()
  )
)


## Deploy targets
deploy_targets <- tar_plan(
  
)


## List targets
all_targets()
