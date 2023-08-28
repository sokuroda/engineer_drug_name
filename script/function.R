
condition <- function(var){
  out <- str_detect(var,"局　") |
    str_detect(var,"局※") | 
    str_detect(var,"局）") |
    str_detect(var,"局麻　") |
    str_detect(var,"麻　") |
    str_detect(var,"（麻）") |
    str_detect(var,"※　") 
  return(out)
}

engineer <- function(df){
  df_engineered <- df %>% 
    mutate(新品名 = 品名 )
  return(df_engineered)
} 

engineer_sec <- function(df){
  df_engineered <- df %>% 
    mutate(
      新品名 = str_replace_all(
        品名, c(
          "局　"   = "",
          "局※　" = "",
          "局）"   = "",
          "局麻　" = "",
          "麻　"   = "",
          "（麻）" = "",
          "※　"   = ""
        )
      )
    )
  return(df_engineered)
} 