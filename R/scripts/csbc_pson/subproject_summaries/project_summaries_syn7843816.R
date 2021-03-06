source("R/charts.R")
source("R/tables.R")
source("R/synapse_helpers.R")
synapseLogin()
update_remote <- TRUE

# Script/template to create summary tables and charts for a "project"

# Config ------------------------------------------------------------------

synproject_id <- "syn7843816" # Synapse project for project Center
project_id <- "syn7843816" # Synapse folder associated with study
parent_id <- "syn11213433" # Center 'Reporting' folder where files should be stored
master_fileview_id <- "syn11143697" # Synapse fileview associated with project


# Collect data ------------------------------------------------------------

fileview_df <- get_table_df(master_fileview_id)

# Add Synapse project info --------------------------------------------

fileview_df <- fileview_df %>%
    left_join(summarize_project_info(.), by = "projectId")

# Data files by assay and tumor type --------------------------------------

table_filename <- glue::glue("{source_id}_DataFileCountsByDrugAndDose.html",
                             source_id = project_id)

# create and save table
group_keys <- c("compoundName", "compoundDose")
count_cols <- c("id", "specimenID", "individualID")

datafile_counts <- fileview_df %>%
    summarize_files_by_annotationkey(
        annotation_keys = group_keys,
        table_id = master_fileview_id,
        count_cols = count_cols
    )

datafile_counts_dt <- datafile_counts %>%
    format_summarytable_columns(group_keys) %>%
    as_datatable()

if (update_remote) {
    syn_dt_entity <- datafile_counts_dt %>%
        save_datatable(parent_id, table_filename, .)
}

# view table
datafile_counts_dt


# Individuals by assays and tumor type ------------------------------------

chart_filename <- glue::glue("{source_id}_IndividualsByDrugAndDose.html",
                             source_id = project_id)

# create and save chart
plot_keys <- list(drugScreenType="Screen",compoundName = "Drug") #list(assay = "Assay", tumorType = "Tumor Type")

chart <- fileview_df %>%
    plot_sample_counts_by_annotationkey_2d(sample_key = "individualID",
                                           annotation_keys = plot_keys)

if (update_remote) {
    syn_chart_entity <- save_chart(parent_id, chart_filename, chart)
}

# view chart
chart


# Files by category -------------------------------------------------------

chart_filename <- glue::glue("{source_id}_DataFilesByCategory.html",
                             source_id = project_id)

# create and save chart
plot_keys <- list(assay = "Assay", tumorType = "Tumor Type",
    diagnosis = "Diagnosis", species = "Species",
    organ = "Organ", tissue = "Tissue", compoundName="Drug", study = "Study")

chart <- fileview_df %>%
    plot_file_counts_by_annotationkey(plot_keys, chart_height = 300)

# syn_entity <-
if (update_remote) {
    save_chart(parent_id, chart_filename, chart)
}

# view chart
chart
