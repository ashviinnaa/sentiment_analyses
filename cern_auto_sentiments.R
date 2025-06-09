
library(tidyverse)
library(syuzhet)

input_folder <- "/Users/ashvinarai/Desktop/FGD_transcript"
output_file <- "/Users/ashvinarai/Desktop/FGD_sentiment_results_summary.csv"
# capture all .vtt Files
vtt_files <- list.files(path = input_folder, pattern = "\\.vtt$", full.names = TRUE)

# create function to process and summarize sentiment per file
process_and_summarize_vtt <- function(file_path) {
  vtt_lines <- read_lines(file_path)
  # remove metadata and timestamps
  dialogue_lines <- vtt_lines %>%
    discard(~ str_detect(.x, "^WEBVTT|^Kind:|^Language:|^\\d{2}:\\d{2}:\\d{2}\\.\\d{3} -->|^$")) %>%
    str_trim()
  # remove Charlene's lines (only capture participant responses)
  filtered_lines <- dialogue_lines %>%
    discard(~ str_detect(.x, "^Charlene \\(SUSS\\):"))
  # extract sentences
  text_lines <- filtered_lines %>%
    keep(~ str_detect(.x, ":")) %>%
    str_remove("^[^:]+:\\s*") %>%
    discard(~ .x == "")
  # get NRC sentiment scores
  nrc_scores <- get_nrc_sentiment(text_lines)
  # sum each sentiment column
  sentiment_summary <- colSums(nrc_scores) %>%
    as_tibble_row()
  # filename as an identifier
  sentiment_summary <- sentiment_summary %>%
    mutate(file = basename(file_path))
  return(sentiment_summary)
}
# Process and combine
summary_results <- map_dfr(vtt_files, process_and_summarize_vtt)
# order so filename is first column
summary_results <- summary_results %>%
  relocate(file)
write.csv(summary_results, file = output_file, row.names = FALSE)

# check
cat("Summarized sentiment results saved to:", output_file, "\n")

