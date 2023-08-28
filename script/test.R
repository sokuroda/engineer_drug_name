#ステップ①
to_engineer <- df %>% filter(condition(品名)) 
not_to_engineer <- df %>% filter(!condition(品名))

#ステップ②
df_engineered_sec <- engineer_sec(to_engineer)
not_df_engineered_sec <- engineer_sec(not_to_engineer)

#ステップ③
to_engineer_again_sec <- df_engineered_sec %>% filter(condition(新品名))
to_engineer_ok_sec <- df_engineered_sec %>% filter(!condition(新品名))
to_engineer_num <- df %>% filter(condition(品名)) %>% nrow()
to_engineer_ok_num_sec <-  to_engineer_ok_sec %>% nrow()
to_engineer_again_num_sec <- to_engineer_again_sec %>% nrow()

#ステップ④
mistake_change_sec <- sum(not_df_engineered_sec$品名 %in% not_df_engineered_sec$新品名 == FALSE)
no_change_sec <- sum(not_df_engineered_sec$品名 %in% not_df_engineered_sec$新品名 == TRUE)

#表の作成
name <- c("加工しないといけないデータ数",
          "①新品名がconditionに引っかからないデータ数",
          "②新品名が再度conditionに引っかかったデータ数",
          "③加工すべきでない変数を、誤って加工してしまう",
          "④加工すべきでない変数を、正しく無加工")

outcome_sec <- c(to_engineer_num,
                 to_engineer_ok_num_sec,
                 to_engineer_again_num_sec,
                 mistake_change_sec,
                 no_change_sec)
outcome_table_sec <- data.frame(cbind(name,outcome_sec))
print(outcome_table_sec)






