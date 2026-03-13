# Read a feature table and partition, calculate nPMI values for each combination
# of group and feature value.

library(openxlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

feat_pho  <- read.xlsx ("DutchRND010_Features.xlsx", na.strings = "")
part_pho  <- read.delim("DutchRND010_Partition.tsv")

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
  cat("Processing feature", colnames(feat_pho)[i], "\n")
  
  index    <- which(!is.na(feat_pho[,i]))
  tab      <- table(feat_pho$variety[index], feat_pho[index,i])
  rel_freq <- prop.table(tab, margin = 1)
  freq_vec <- rel_freq[cbind(feat_pho$variety[index], feat_pho[index,i])]
  
  x <- unique(feat_pho[index,i])
  y <- sort(unique(part_pho_group[index]))
  
  for (j in 1:length(x))
  {
    for (k in 1:length(y))
    {
      x_idx  <- which(feat_pho      [index,i]==x[j])
      y_idx  <- which(part_pho_group[index  ]==y[k])
      xy_idx <- intersect(x_idx, y_idx)

      x_p <- sum(freq_vec[x_idx]) / sum(freq_vec)
      y_p <- sum(freq_vec[y_idx]) / sum(freq_vec)

      if (length(xy_idx) > 0)
      {
        xy_p <- sum(freq_vec[xy_idx]) / sum(freq_vec)
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

results              <- subset(results, group!=0)
results_sorted       <- results[order(results$group, -results$npmi), ]
results_sorted_top10 <- results_sorted[ave(results_sorted$npmi, results_sorted$group, FUN = seq_along) <= 10, ]

write.table(results_sorted_top10, file = "DutchRND010_nPMI.txt", sep = "\t", row.names = FALSE, quote = FALSE)
