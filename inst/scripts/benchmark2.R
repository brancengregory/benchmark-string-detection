library(tidyverse)
library(purrr)
library(bench)
library(ggplot2)
library(gt)
devtools::load_all(".")

set.seed(42)

# Define a helper function to generate strings of varying lengths
generate_strings <- function(n, length) {
  stringi::stri_rand_strings(n, length)
}

# Setup a pattern for regex operations
pattern <- "([a-zA-Z0-9]+)"

# Use bench::press to run benchmarks across a grid of parameters
benchmark_results <- press(
  n = c(10, 100, 1000, 10000, 100000, 1000000), # Number of strings
  length = c(10, 50, 100, 1000), # Length of each string
  {
    strings <- generate_strings(n, length)

    mark(
      min_iterations = 10,
      R_stringr = stringr::str_detect(strings, pattern),
      R_stringi = stringi::stri_detect_regex(strings, pattern),
      Rust = string_detect(strings, pattern),
      Rust_par = string_detect_par(strings, pattern)
    )
  }
)

autoplot(benchmark_results, type = "violin")

benchmark_results |>
  select(expression, n, length, median) |>
  arrange(desc(n), desc(length), median) |>
  gt()

benchmark_results |>
  mutate(
    expression = as.character(expression),
    median = as.numeric(median)
  ) |>
  ggplot(aes(x = n, y = median, color = expression)) +
    geom_line() +
    facet_wrap(vars(length)) +
    scale_x_log10() +
    scale_y_log10()
