# Convert a feature table with multiple feature values listed vertically into a 
# feature table with multiple feature values combined in a single cell next to
# each other, separated by ‘/’.

library(openxlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

feat_pho  <- read.xlsx ("DutchRND010_Features.xlsx", na.strings = "")

 vars <- unique(feat_pho$variety)
feats <- unique(colnames(feat_pho))

df <- data.frame(matrix(NA, nrow = length(vars), ncol = length(feats)))
df[,1]       <-  vars
colnames(df) <- feats

for (i in 1:length(vars))
{
  for (j in 2:ncol(df))
  {
    feats   <- subset(feat_pho, variety==vars[i])[,j]
    feats   <- feats[!is.na(feats)]
    df[i,j] <- paste(feats, collapse = " / ")
  }
}

write.xlsx(df, "DutchRND010_Features_multiple_grouped.xlsx")
