library(tidyverse)
library(stringr)
library(tidytext)
library(syuzhet)

# Load raw .vtt file
vtt_lines <- readLines('/Users/ashvinarai/Desktop/CERN_FGD/CERN_FGD2/GMT20250416-055548_Recording.transcript.vtt')

# Filter only lines with speaker dialogue (exclude timestamps and metadata and whatever Charlene spoke)
dialogue_lines <- vtt_lines %>%
  discard(~ str_detect(.x, "^WEBVTT|^Kind:|^Language:|^\\d{2}:\\d{2}:\\d{2}\\.\\d{3} -->|^$")) %>%
  str_trim()
filtered_dialogues <- dialogue_lines %>%
  discard(~ str_detect(.x, "^Charlene \\(SUSS\\):"))
# Optional: Remove timestamps from lines before dialogue
dialogue_lines <- dialogue_lines[!str_detect(dialogue_lines, "^\\d{2}:\\d{2}:\\d{2}\\.\\d{3}")]


# Extract speaker and spoken line
cleaned_df <- tibble(raw = filtered_dialogues) %>%
  filter(str_detect(raw, ":")) %>%
  mutate(
    speaker = str_extract(raw, "^[^:]+"),
    text = str_remove(raw, "^[^:]+:\\s*")
  )

# Run emotion analyses with NRC
nrc_scores <- get_nrc_sentiment(cleaned_df$text)
# Combine scores with speaker/text
sentiment_df <- bind_cols(cleaned_df, nrc_scores)
write_csv(sentiment_df, "filtered_sentiment_output.csv")

# visualise emoptional distribution
emotion_summary <- sentiment_df %>%
  select(anger:trust) %>%
  summarise(across(everything(), sum)) %>%
  pivot_longer(cols = everything(), names_to = "emotion", values_to = "total")

ggplot(emotion_summary, aes(x = reorder(emotion, -total), y = total)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Emotion Distribution (excluding Charlene)",
    x = "Emotion", y = "Total Count"
  ) +
  theme_minimal()

### Map emotions by speaker 
responses_with_emotion %>%
  group_by(speaker) %>%
  summarise(across(anger:trust, sum)) %>%
  pivot_longer(-speaker, names_to = "emotion", values_to = "count") %>%
  ggplot(aes(x = emotion, y = count, fill = speaker)) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(title = "Emotion by Speaker")


