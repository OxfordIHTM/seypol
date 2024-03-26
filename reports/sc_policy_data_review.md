---
title: Seychelles Policy Data Review
author: Ernest Guevarra
date: "2024-03-26"
output: 
  rmarkdown::html_document:
    toc: true
    keep_md: true
---



This document reviews the set of documents on acts, policies, strategies, guidelines, action plans, public service orders, and results-based monitoring frameworks provided by the Seychelles Ministry of Health on the 27th of February 2024. This review was conducted with the view of assessing the directory organisation/structure, nomenclature, and file type and format of the documents for designing an appropriate text data ingest workflow.

## Summary statistics



A total of **159** documents were provided. These documents were organised in **7** directories named **Act**, **Policy**, **Strategy**, **Guideline**, **Action Plan**, **PSO**, and **RBM Framework**. Act and policy documents comprised 71% of the total number of documents.

<img src="sc_policy_data_review_files/figure-html/summary1-1.png" style="display: block; margin: auto;" />



In terms of file format type, **77%** of documents were in PDF format. There are 2 different types of Microsoft Word documents found, `.DOCX` and `.DOC` file formats, which comprise **18%** and **4%** of the documents respectively. There was one single file with a `.lnk` file extension which seems to be a shortcut link to another file but requires specific software to open.

<img src="sc_policy_data_review_files/figure-html/summary2-1.png" style="display: block; margin: auto;" />
 
<img src="sc_policy_data_review_files/figure-html/summary3-1.png" style="display: block; margin: auto;" />

## General observations

The following are the observations made through this review.

### Document file organisation

The documents were provided as a shared Dropbox link with 7 directories matching each of the document types mentione above. Within each of these directories, the structure is generally similar with sub-directories that identifies the topic/theme of the specific document within. In some sub-directories, there are further sub-directories. However, this structure is not consistent across the different main directories. Such structure (and the inconsistent application of this structure) adds complexity to the designing a programmatic workflow to access the documents for text extraction. Complexity is mainly related to being able to create appropriate metadata during the text extraction process.

### Document file naming

In some of the directories, a system of file naming can be gleaned. However, as is with the document file organisation, this is not true for all files. Other elements in the file naming that needs to be cleaned up is the multiple file extensions. For example, a few files have `.docx.docx` or `.docx.doc`

### Document file types

As described above, the documents came in 3 file types (excluding the junk `.lnk` file). Reading `PDF` and `DOCX` files in R is straightforward. However, working with the older Word file `DOC` is not as easy.

### Duplicate documents, different file types

There are **9** `.DOCX` or `.DOC` files that are replicates of the same document but in `PDF`. For the data ingest and data extraction workflow, only one file type should be used and added to the text dataset.

### Draft and final documents included

There are a number of files that have versions (a draft and a final one) included in the document list.

## Developing and testing a data ingest workflow

Given the context above, a data ingest worklow was developed and tested. Of the 159 documents, 141 documents were read and ingested as raw, unstructured text data. The 9 `DOCX` or `DOC` files that were duplicates of `PDF` files were left unread. The 9 `DOC` files were not read. This data ingest pipeline was developed in 4.5 hours and a full run of the text extraction took about 6-7 minutes.

The steps in the current data ingest workflow are show in the diagram below:

```mermaid
graph LR
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Graph
    direction LR
    xffe29aeaee157f80(["sc_policy_drive_contents"]):::uptodate --> x86e06af7b6a479ee(["sc_policy_catalogue_info"]):::outdated
    x677847acaae4d32d(["sc_policy_pdf_docs_ids"]):::outdated --> xf64fe3c990ad5884["sc_policy_pdf_docs_text"]:::outdated
    xffe29aeaee157f80(["sc_policy_drive_contents"]):::uptodate --> xb70e8be842aaaf39(["sc_policy_drive_catalogue"]):::uptodate
    xb70e8be842aaaf39(["sc_policy_drive_catalogue"]):::uptodate --> x677847acaae4d32d(["sc_policy_pdf_docs_ids"]):::outdated
    x4a9dec0b959c7d0a(["sc_policy_word_docs_ids"]):::outdated --> xd5982ac7eedf24f2["sc_policy_word_docs_text"]:::outdated
    xb70e8be842aaaf39(["sc_policy_drive_catalogue"]):::uptodate --> x4a9dec0b959c7d0a(["sc_policy_word_docs_ids"]):::outdated
    x86e06af7b6a479ee(["sc_policy_catalogue_info"]):::outdated --> xcf90ec254633ca52(["sc_policy_catalogue_file"]):::outdated
    xcf90ec254633ca52(["sc_policy_catalogue_file"]):::outdated --> x19ba61a7d210e288(["sc_policy_catalogue_text"]):::outdated
  end
```

On review of the data extraction outputs, the main issue noted was that there are a few `PDF` documents that produced empty data. When reviewed, all these files were scanned copies of the original and the quality of the scanning was poor with lots of non-text artifacts. A more customised text extraction process will be needed for these files. Other than this, data processing, cleaning, and structuring of the text data already ingested will be relatively straightforward with structuring being the most time-consuming step given the described inconsistent organisation of the documents above. 

## Next steps

Following are the next steps to be taken:

1. Re-create the structure and file naming of the various documents to improve the data ingest workflow but also simplify the text structuring step later on.

A clear file naming syntax will simplify the structure of the documents as the hierarchy of the directory structure that was initiated by the Seychelles Ministry of Health and will eliminate the need for sub-directories. The following file nomenclature syntax is recommended:

`[DOCUMENT TYPE CODE]-[DOCUMENT SHORT NAME]-[YEAR].pdf`

where:

* `[DOCUMENT TYPE CODE]` is any of the 7 types mentioned above (act, policy, strategy, guideline, action, pso, and rbm). If more document types get added in the future, a new type code will be added. Note that the recommended codes are single word or abbreviations and are all in small characters.

* `[DOCUMENT SHORT NAME]` is similar text to what would have been used as the sub-directories. The short name should be as short as possible while at the same time clearly and uniquely identifying the theme/topic to which the document pertains to. The words in the short name should be split using an underscore (`_`). There should be no white space between words.

* `[YEAR]` is the year associated with the document. This should usually be when the document was released/published. The year should be in `YYYY` format.

Once the files are renamed, there will be no need to keep the files in different directories.

2. Re-create a catalogue of documents

Seychelles Ministry of Health provided a catalogue along with the set of documents they provided. This was given in a `PDF` which is not the ideal format for a tabular catalogue as you cannot easily use the information as if it was data. For re-creating the catalogue once files have been renamed, a spreadsheet will be created for this purpose.

3. Convert `DOC` files to `DOCX` files

4. Remove `.lnk` file from document set

5. Remove duplicate documents but in different (`DOCX`) file type

6. Use only the final draft of all documents

7. Re-factor the data ingest workflow

<br>
<br>
