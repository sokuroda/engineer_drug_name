#library の読み込み
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(tidyverse)

#データの読み込みhere
path <- "./data/2023_06_16.csv"

df <- read_csv(
  path,
  locale = locale(encoding = "Shift-jis"),
  col_types = cols(.default = col_character())
) 

#「品名」の加工
#functioのsource
source(here::here("script","function.R"))
#新品名が正しく加工されているのかテスト
source(here::here("script","test.R"))


