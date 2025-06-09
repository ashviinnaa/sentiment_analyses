library(tidyverse)
library(tidytext)
library(tm)
library(textclean)
data <- read.csv("C:/Users/raias/OneDrive/Desktop/updated_mapping_table_with_stim_text.csv")

# Clean text
data$text_clean <- data$text %>%
tolower() %>%
replace_contraction() %>%
replace_number() %>%
removePunctuation() %>%
removeWords(stopwords("en"))
grouped_tokens <- tokens %>%
group_by(factor_group, word) %>%
summarise(word_count = n()) %>%
arrange(factor_group, desc(word_count))
themes <- grouped_tokens %>%
group_by(factor_group) %>%
slice_max(word_count, n = 10)
print(themes)

# Plot word frequencies
library(ggplot2)
ggplot(themes, aes(x = reorder(word, -word_count), y = word_count, fill = factor_group)) +
geom_bar(stat = "identity", show.legend = FALSE) +
facet_wrap(~ factor_group, scales = "free_y") +
coord_flip() +
labs(title = "Top Words by Factor Group",
x = "Words",
y = "Frequency")

