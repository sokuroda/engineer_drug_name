薬価基準収載医薬品コードにもとづく医薬品名
================
2023-07-11 (updated: 2023-08-28)

## はじめに

ここでは、加工するデータのパターン把握を行なう。その加工すべきデータを加工した後、それが正しく加工されているか否かをテストする手順も記す。

## データの事前調査

実データファイルに、「局」「麻」「※」の有無を示す項目があり、
実際データを目視で確認してみると、3つ文字に関して
加工を加えないといけない場面が多かったため、
これらの文字を含んでいるデータを確認対象とし
修正すべきデータの抽出を行った。以後、Rを用いて調査・加工を行う。

必要なライブラリーを読み込む。

``` r
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(tidyverse)
```

無加工な実データを読み込む。

``` r
path <- here("data", "2023_06_16.csv")

df <- read_csv(
  path,
  locale = locale(encoding = "Shift-jis"),
  col_types = cols(.default = col_character())
) 
```

なお、重複を含まないようにする。また、欠測値が1つあったが、conditionの網羅性の評価であり、欠測は扱わない為、欠測値は取り除いた。

``` r
df <- df %>% 
  distinct(品名) %>% 
  drop_na(品名)
df
```

    ## # A tibble: 33,806 × 1
    ##    品名                            
    ##    <chr>                           
    ##  1 ブロムワレリル尿素              
    ##  2 局　ブロムワレリル尿素          
    ##  3 ブロモバレリル尿素              
    ##  4 局　ブロムワレリル尿素「エビス」
    ##  5 ブロムワレリル尿素「三恵」      
    ##  6 局　ブロムワレリル尿素「三恵」  
    ##  7 「純生」ブロムワレリル尿素      
    ##  8 局　「純生」ブロムワレリル尿素  
    ##  9 ブロムワレリル尿素「メタル」    
    ## 10 局　ブロムワレリル尿素「メタル」
    ## # ℹ 33,796 more rows

## 加工するデータのパターン把握

### 局に対して

品名の中に、どんな形であれ「局」が含まれているものを抽出。また、該当するデータ数を出力する。

``` r
df_kyoku <- df %>% filter(str_detect(品名,"局")) 
df_kyoku_num <- df_kyoku %>% nrow()
# print(df_kyoku_num)
```

すると、該当する品名が 2828 個存在することが分かった。

抽出したデータを目視して、パターンの把握を行い、「局 + 全角スペース
」「局※」「局）」「局麻+
全角スペース」の4つの加工しなければならないパターンが発見された。

また、「局麻用フリードカイン注」のような「局」が含まれていても加工しなくてよいデータも確認された。

| 変数名      | パターン           |
|-------------|--------------------|
| kyoku_all   | 局含むデータ全数   |
| kyoku_space | 局 + 全角スペース  |
| kyoku_kome  | 局※                |
| kyoku_kakko | 局） 　　　　　    |
| kyoku_asa   | 局麻+ 全角スペース |

### 麻に対して

品名の中に、どんな形であれ「麻」が含まれているものを抽出。また、該当するデータ数を出力する。

``` r
df_asa <- df %>% filter(str_detect(品名,"麻")) 
df_asa_num <- df_asa %>% nrow()
#print(df_asa_num)
```

すると、該当する品名が 137 個存在することが分かった。
抽出したデータを目視して、パターンの把握を行い、「（麻）」「麻+全角スペース」「局麻+
全角スペース」の3つの加工しなければならないパターンが発見された。

| 変数名    | パターン           |
|-----------|--------------------|
| asa_all   | 麻含むデータ全数　 |
| asa_space | 麻 + 全角スペース  |
| asa_kakko | （麻）             |

### ※に対して

品名の中に、どんな形であれ「※」が含まれているものを抽出。また、該当するデータ数を出力する。

``` r
df_kome <- df %>% filter(str_detect(品名,"※")) 
df_kome_num <- df_kome %>% nrow()
#print(df_kome_num)
```

すると、該当する品名が 374 個存在することが分かった。
抽出したデータを目視して、パターンの把握を行い、 「※
+全角スペース」というパターンが発見された。

| 変数名     | パターン         |
|------------|------------------|
| kome_all   | ※ 含むデータ全数 |
| kome_space | ※ + 全角スペース |

イレギュラーなパターンを発見するため、「match」という’局’,‘麻’,’※’のどれか一つでも含んでいたらTRUEを、含んでいなければFALSEを返す変数も作成する。

## 集計

パターン間の重複を考慮し、パターンごとのデータ数を集計(集計結果は下記に記載)

※「(局）」左かっこが半角で、右かっこが全角の本来加工しなければならないデータを加工しなくてよいパターンで確認された。このようなイレギュラーなパターンはその都度対応する。今回は、「局）」というパターンで再度抽出を行った。該当した場合は、その変数にTRUEを返し、該当しない場合は、FALSEを返す。

``` r
df_add <- df %>% 
  mutate(
    match = str_detect(品名,"局")|str_detect(品名,"麻")|str_detect(品名,"※"),
    kyoku_space = str_detect(品名,"局　"),
    kyoku_kome = str_detect(品名,"局※"),
    kyoku_kakko = str_detect(品名,"局）"),
    kyoku_asa = str_detect(品名,"局麻　"),
    asa_space = str_detect(品名,"麻　"),
    asa_kakko = str_detect(品名,"（麻）"),
    kome_space = str_detect(品名,"※　"),
  ) 
```

上記で作成されたdf_addを可視化するため、出力を「1 or 0」の二値とする。
集計結果は、下記の表1の通りである。

``` r
# across→「TRUE or FALSE」を「1 or 0」
# summarizeは、group_by(グループ分け)とセットで使う。
# summarizeのn()は、カウントである。
table <- df_add %>% 
  mutate(across(where(is.logical), as.integer)) %>% 
  group_by(
    match,
    kyoku_space,
    kyoku_kome,
    kyoku_kakko,
    kyoku_asa,
    asa_space,
    asa_kakko,
    kome_space,
    #condition,
  ) %>% 
  summarize(count = n(), .groups = "drop") %>% 
  #列の並び替えを行う
  arrange(-match,-kyoku_space,-kyoku_kome,-kyoku_kakko,
          -kyoku_asa,-asa_space,-asa_kakko,-kome_space) 


table %>% 
  knitr::kable()
```

| match | kyoku_space | kyoku_kome | kyoku_kakko | kyoku_asa | asa_space | asa_kakko | kome_space | count |
|------:|------------:|-----------:|------------:|----------:|----------:|----------:|-----------:|------:|
|     1 |           1 |          0 |           0 |         0 |         0 |         0 |          0 |  2284 |
|     1 |           0 |          1 |           0 |         0 |         0 |         0 |          1 |   305 |
|     1 |           0 |          0 |           1 |         0 |         0 |         0 |          0 |   207 |
|     1 |           0 |          0 |           0 |         1 |         1 |         0 |          0 |    24 |
|     1 |           0 |          0 |           0 |         0 |         1 |         0 |          0 |    47 |
|     1 |           0 |          0 |           0 |         0 |         0 |         1 |          0 |     3 |
|     1 |           0 |          0 |           0 |         0 |         0 |         0 |          1 |    69 |
|     1 |           0 |          0 |           0 |         0 |         0 |         0 |          0 |    64 |
|     0 |           0 |          0 |           0 |         0 |         0 |         0 |          0 | 30803 |

**表1　無加工データのパターン別の集計表**

表の見方について説明を行う。表の1行目は、「match」と「kyoku_space」が1となり、残りの変数は0となっている。つまり、「局+全角スペース」を含む変数は、2284あることがわかる。一番下の行であるallとパターンに関して全て0のcountは、データの全数である。

最後に、「match」が1で残りが全て0である行の説明を行う。こちらは、イレギュラーな修正すべきパターンの可能性があるため、目視して確認を行う。

``` r
to_check <- filter(df_add,match == TRUE,
            kyoku_space == FALSE,
            kyoku_kome == FALSE,
            kyoku_kakko == FALSE,
            kyoku_asa == FALSE,
            asa_space == FALSE,
            asa_kakko == FALSE,
            kome_space == FALSE)
print(to_check$品名)
```

    ##  [1] "マツウラの天麻末（調剤用）"                  
    ##  [2] "テンマ（天麻）Ｒ"                            
    ##  [3] "マツウラの天麻（調剤用）"                    
    ##  [4] "〔東洋〕桂麻各半湯エキス細粒"                
    ##  [5] "ツムラ升麻葛根湯エキス顆粒（医療用）"        
    ##  [6] "コタロー半夏白朮天麻湯エキス細粒"            
    ##  [7] "三和半夏白朮天麻湯エキス細粒"                
    ##  [8] "クラシエ半夏白朮天麻湯エキス細粒"            
    ##  [9] "ツムラ半夏白朮天麻湯エキス顆粒（医療用）"    
    ## [10] "コタロー麻黄湯エキス細粒"                    
    ## [11] "ジュンコウ　麻黄湯ＦＣエキス細粒　医療用"    
    ## [12] "ジュンコウ麻黄湯ＦＣエキス細粒医療用"        
    ## [13] "クラシエ麻黄湯エキス細粒"                    
    ## [14] "ＫＴＳ麻黄湯エキス顆粒"                      
    ## [15] "ツムラ麻黄湯エキス顆粒（医療用）"            
    ## [16] "テイコク麻黄湯エキス顆粒"                    
    ## [17] "本草麻黄湯エキス顆粒－Ｓ"                    
    ## [18] "ジュンコウ麻黄湯ＦＣエキス錠医療用"          
    ## [19] "三和麻黄附子細辛湯エキス細粒"                
    ## [20] "ツムラ麻黄附子細辛湯エキス顆粒（医療用）"    
    ## [21] "コタロー麻黄附子細辛湯エキスカプセル"        
    ## [22] "コタロー麻杏甘石湯エキス細粒"                
    ## [23] "ジュンコウ　麻杏甘石湯ＦＣエキス細粒　医療用"
    ## [24] "ジュンコウ麻杏甘石湯ＦＣエキス細粒医療用"    
    ## [25] "オースギ麻杏甘石湯エキスＧ"                  
    ## [26] "ツムラ麻杏甘石湯エキス顆粒（医療用）"        
    ## [27] "テイコク麻杏甘石湯エキス顆粒"                
    ## [28] "本草麻杏甘石湯エキス顆粒－Ｍ"                
    ## [29] "麻杏甘石湯エキス顆粒Ｔ"                      
    ## [30] "マツウラ麻杏甘石湯エキス顆粒"                
    ## [31] "ジュンコウ麻杏甘石湯ＦＣエキス錠医療用"      
    ## [32] "コタロー麻杏よく甘湯エキス細粒"              
    ## [33] "三和麻杏よく甘湯エキス細粒"                  
    ## [34] "クラシエ麻杏よく甘湯エキス細粒"              
    ## [35] "オースギ麻杏よく甘湯エキスＧ"                
    ## [36] "ＪＰＳ麻杏よく甘湯エキス顆粒〔調剤用〕"      
    ## [37] "ツムラ麻杏よく甘湯エキス顆粒（医療用）"      
    ## [38] "麻杏よく甘湯エキス顆粒Ｔ"                    
    ## [39] "コタロー麻子仁丸料エキス細粒"                
    ## [40] "オースギ麻子仁丸料エキスＧ"                  
    ## [41] "ツムラ麻子仁丸エキス顆粒（医療用）"          
    ## [42] "麻酔用エーテル"                              
    ## [43] "エスカイン吸入麻酔液"                        
    ## [44] "フォーレン吸入麻酔液"                        
    ## [45] "イソフルラン吸入麻酔液「ファイザー」"        
    ## [46] "イソフルラン吸入麻酔液「ＶＴＲＳ」"          
    ## [47] "セボフルラン吸入麻酔液「メルク」"            
    ## [48] "セボフルラン吸入麻酔液「マイラン」"          
    ## [49] "セボフレン吸入麻酔液"                        
    ## [50] "セボフルラン吸入麻酔液「ニッコー」"          
    ## [51] "スープレン吸入麻酔液"                        
    ## [52] "「純生」局エタ"                              
    ## [53] "クロロマイセチン局所用"                      
    ## [54] "クロロマイセチン局所用液５％"                
    ## [55] "トロンビンＦ局所用液"                        
    ## [56] "トロンビン経口・局所用液５千「Ｆ」"          
    ## [57] "コーパロン歯科用表面麻酔液６％"              
    ## [58] "０．３％ペルカミンエス注脊麻用"              
    ## [59] "局麻用フリードカイン注０．５％"              
    ## [60] "局麻用フリードカイン注１％"                  
    ## [61] "局麻用フリードカイン注２％"                  
    ## [62] "マーカイン注脊麻用０．５％高比重"            
    ## [63] "マーカイン注脊麻用０．５％等比重"            
    ## [64] "ネオペルカミンＳ注脊麻用"

上の一覧表を見てわかる通り、修正すべき箇所は見当たらなかった。
そのため、実データの修正すべきパターンは、全て網羅されていることが示された。
以上が、実データの事前調査である。

## 加工の要否を判定する関数 condition の作成

したがって、加工前および加工後の品名にあたる変数を引数として、引数に与えた品名が
修正対象か否かを返すcondition関数を以下のように定義する。

この関数を、他のファイル「function.R」に記載してある。

``` r
condition <- function(var){
  out <- str_detect(var,"局　") | str_detect(var,"局※") | 
    str_detect(var,"局）") | str_detect(var,"局麻　") |
    str_detect(var,"麻　") | str_detect(var,"（麻）") |
    str_detect(var,"※　") 
  return(out)
}
```

function.Rを読み込む。

``` r
source(here::here("script","function.R"))
```

## 加工対象の品名を加工するための関数の作成

次に、condition関数で加工対象となった変数を加工するengineer関数を作成する。
※engineer関数は、他のファイル「function.R」に記載してある。

## テストの仕組み

最後に、これまで作成したcondition関数とengineer関数を用いることで、
修正すべき変数を正しく修正し、修正する必要のない変数はそのままの状態を保てるのかテストを行う。
※実際のテストは、他のファイル「engineer.RMD」で行っている。

### 加工する前後での変化の種類

変数の加工精度を検証するには、変数を加工するまでに二つのステップが存在する。
一つ目が、対象変数の識別(condition関数)、二つ目が、対象変数の加工(engineer関数)である。

そのため、加工前後での変化の種類は、以下の4通り存在する。

①加工すべき変数が、想定通り加工できた→conditionに引っかからない

②加工すべき変数が、無加工も含め想定通りではない加工→再度conditionに引っかかる

③加工すべきでない変数を、誤って加工してしまう。「局麻用」など。

④加工すべきでない変数を、正しく無加工。

つまり、変数全て①か④に当てはまればよい。

### 検証方法

加工前後の変化の仕方がどのようになっているのか検証するには、４つのステップを
踏む必要がある。

ステップ1：condition関数で、加工対象か否か識別する。

ステップ2：ステップ１で加工すべき変数、すべきではない変数をそれぞれengineer関数
を用いて加工する。

ステップ3：加工すべき変数に対し、加工後の変数【新品名】を
再度condition関数の引数に代入する。これは、加工後の変数が再度conditionに
ひっかかるか確認するためである。　　

ステップ4：加工すべきでない変数に対し、加工前後で変更があるか否かを確認する。
変更があれば、不要な加工が行われていることとなり、変更がなければ正しい加工を意味する。

最後に、結果を表にまとめ、加工前後での変化の種類を可視化する。
