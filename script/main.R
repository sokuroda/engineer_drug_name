#library の読み込み
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(tidyverse)

#データの読み込みhere("./datafolder/datafile.csv")
#path <- here("data", "2023_06_16.csv")
path <- "C:/Users/sokur/OneDrive/ドキュメント/成育医療/薬価/yakka/data/2023_06_16.csv"
df <- read_csv(
  path,
  locale = locale(encoding = "Shift-jis"),
  col_types = cols(.default = col_character())
) 

#「品名」の加工
#functioのsource
source(here::here("function.R"))
#新品名が正しく加工されているのかテスト
source(here::here("test.R"))

# 「薬価基準収載医薬品こ」
a_warfarin_cat <- as.numeric(a_warfarin_day != "")
