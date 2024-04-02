library(tidyverse)
library(purrr)
library(bench)
library(ggplot2)
library(gt)
library(ojodb)
devtools::load_all(".")

set.seed(42)

charges <- ojo_tbl("count") |>
  select(count_as_filed) |>
  filter(!is.na(count_as_filed)) |>
  distinct() |>
  pull()

# Setup a pattern for regex operations
pattern <- "(?i)\\b(c([\\.\\,]*)d([\\.\\,]*)(s([\\.\\,]*))*)\\b"

benchmark_results <- bench::mark(
  min_iterations = 10,
  R_stringr = stringr::str_detect(charges, pattern),
  R_stringi = stringi::stri_detect_regex(charges, pattern),
  Rust = string_detect(charges, pattern),
  Rust_par = string_detect_par(charges, pattern)
)

autoplot(benchmark_results, type = "beeswarm")
