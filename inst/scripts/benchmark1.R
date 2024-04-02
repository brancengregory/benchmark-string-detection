library(bench)
library(stringr)
library(stringi)
library(dplyr)
library(gt)
library(ggplot2)
library(ojoregex)
library(benchmarkStringDetection)

wordlist <- state.name
regex_expression <- "(?i)ma"

bench1 <- bench::mark(
  grepl(regex_expression, wordlist),
  str_detect(wordlist, regex_expression),
  stri_detect(wordlist, regex = regex_expression),
  stri_detect_regex(wordlist, regex_expression),
  string_detect(wordlist, regex_expression),
  iterations = 10000
)

regex_expression <- "ma"

bench2 <- bench::mark(
  grepl(regex_expression, wordlist, ignore.case = TRUE),
  str_detect(wordlist, regex(regex_expression, ignore_case = TRUE)),
  stri_detect(wordlist, regex = regex_expression, case_insensitive = TRUE),
  stri_detect_regex(wordlist, regex_expression, opts_regex = list(case_insensitive = TRUE)),
  iterations = 10000
)

res <- bind_rows(
  bench1 |>
    mutate(case_insensitive_method = "regex"),
  bench2 |>
    mutate(case_insensitive_method = "function")
)

res |>
  summarise(
    .by = "case_insensitive_method",
    median = median(median) |>
      as.numeric()
  ) |>
  ggplot(aes(x = case_insensitive_method, y = median)) +
  geom_col()

res |>
  arrange(desc(`itr/sec`), mem_alloc) |>
  select(expression, case_insensitive_method, min, median, `itr/sec`, mem_alloc, `gc/sec`, total_time) |>
  gt()

data <- tibble(
  state = wordlist
)
