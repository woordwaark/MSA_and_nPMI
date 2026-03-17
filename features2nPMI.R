# Read a feature table and partition, calculate nPMI values for each combination
# of group and feature value.

library(openxlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

feat_lex  <- read.xlsx ("GroningsRND_Lex0.xlsx" , na.strings = "")
feat_pho  <- read.xlsx ("GroningsRND_Feat0.xlsx", na.strings = "")

part_lex  <- read.delim("resultaten/partition_lex.TSV")
part_pho  <- read.delim("resultaten/partition_pho.TSV")

part_lex_group <- feat_lex$variety

for (i in 1:length(part_lex_group))
{
  index <- which(part_lex==part_lex_group[i])
  part_lex_group[i] <- part_lex$group[index]
}

part_pho_group <- feat_pho$variety

for (i in 1:length(part_pho_group))
{
  index <- which(part_pho==part_pho_group[i])
  part_pho_group[i] <- part_pho$group[index]
}

# # #

results <- data.frame(
  feature = character(),
  value   = character(),
  group   = integer  (),
  npmi    = numeric  ()
)

for (i in 2:ncol(feat_pho))
{
  cat(colnames(feat_pho)[i], "\n")
  
  # Select only cases where a feature value is given
  index    <- which(!is.na(feat_pho[,i]))

  # Get cross table of frequencies where varieties are rows and feature values are columns
  freq     <- table(feat_pho$variety[index], feat_pho[index,i])
  print(freq)
  
  # Per variety divide each feature value frequency by the sum of the feature value frequencies
  rel_freq <- prop.table(freq, margin = 1)
  print(rel_freq)
  
  # For each variety give the relative frequencies only for the feature values that actually were recorded
  rel_freq_vec <- rel_freq[cbind(feat_pho$variety[index], feat_pho[index,i])]
  
  # Feature values of feature i
  x <- unique(feat_pho[index,i])

  # Groups found for feature i
  y <- sort(unique(part_pho_group[index]))
  
  # For all feature values j and groups k (including group 0) do
  for (j in 1:length(x))
  {
    for (k in 1:length(y))
    {
      x_idx  <- which(feat_pho      [index,i]==x[j])
      y_idx  <- which(part_pho_group[index  ]==y[k])
      xy_idx <- intersect(x_idx, y_idx)

      x_p <- sum(rel_freq_vec[x_idx]) / sum(rel_freq_vec)
      y_p <- sum(rel_freq_vec[y_idx]) / sum(rel_freq_vec)

      if (length(xy_idx) > 0)
      {
        xy_p <- sum(rel_freq_vec[xy_idx]) / sum(rel_freq_vec)
        pmi  <- log2(xy_p / (x_p * y_p))
        npmi <- pmi / -log2(xy_p)
      }      
      else
        npmi <- -1
      
      results <- rbind(results, data.frame(
        feature = colnames(feat_pho)[i],
        value   = x[j],
        group   = y[k],
        npmi    = npmi
      ))
    }
  }
}  

# Group 0 contains unclassified varieties, therefore, the results for group 0 are not meaningful
results        <- subset(results, group!=0)

# Give per group the nPMI values per feature, sorted in descending order
results_sorted <- results[order(results$group, -results$npmi), ]

# Give per group only the top 10
results_top10  <- results_sorted[ave(results_sorted$npmi, results_sorted$group, FUN = seq_along) <= 10, ]
