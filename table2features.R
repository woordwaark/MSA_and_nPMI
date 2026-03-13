# Read a table with word transcriptions, perform multiple sequence alignment, 
# save the result as feature table.

library(openxlsx)
library(reticulate)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

df <- read.xlsx("DutchRND010.xlsx")

# Count maximum number of variants per variety
minVar <- rep(1, nrow(df))

for (i in 1:nrow(df))
{
  for (j in 2:ncol(df))
  {
    if (grepl(" / ", df[i,j]))
    {
      nVar <- length(unlist(strsplit(df[i,j], split = " / ")))
      if (nVar > minVar[i])
        minVar[i] <- nVar
    }
  }
}

# Initialize an empty list to hold rows
rows_list <- vector("list", length = nrow(df))

for (i in 1:nrow(df)) 
{
  # Original row
  original_row <- df[i, , drop = FALSE]
  
  # Number of empty rows to add
  n_empty <- max(minVar[i] - 1, 0)
  
  if (n_empty > 0) 
  {
    # Create empty rows
    empty_rows <- as.data.frame(matrix(NA, nrow = n_empty, ncol = ncol(df)))
    colnames(empty_rows) <- colnames(df)
    
    # Combine original + empty rows
    rows_list[[i]] <- rbind(original_row, empty_rows)
  } 
  else
  {
    rows_list[[i]] <- original_row
  }
}

# Combine all rows
df <- do.call(rbind, rows_list)
rownames(df) <- NULL

# Process multiple variants
for (i in 1:nrow(df))
{
  for (j in 2:ncol(df))
  {
    if (grepl(" / ", df[i,j]))
    {
      s <- unlist(strsplit(df[i,j], split = " / "))
      
      for (k in 1:length(s))
      {
        df[i + k - 1,j] <- s[k]
      }
    }
  }
}

# Duplicate location names
for (i in 1:nrow(df))
{
  if (is.na(df[i,1]))
    df[i,1] <- df[i-1,1]
}

# Set virtual environment if necessary
# virtualenv_install(envname  = "/home/heeringa/python_envs/r-reticulate", packages = "lingpy")

lingpy   <- import("lingpy")
builtins <- import_builtins()

# Do multiple sequence alignment
for (j in 2:ncol(df))
{
  cat("Processing feature in column", j, "\n")
  
  seqs <- c(df[,j])
  none <- which(is.na(seqs))
  seqs[is.na(seqs)] <- "_"
  
  # a [j] after a vowel and followed by a consonant or nothing is replaced by an
  # [i] for getting a correct alignment
  seqs <- gsub(
    "(?<=[iyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔæɐaɶɑɒɛ̠ɛːĭeˑ])(j|j̆)(?=[pbtdʈɖcɟkɡqɢʔmɱnɳɲŋɴʙrʀⱱɾɽɸβfvθðszʃʒʂʐçʝxɣχʁħʕhɦɬɮwʋɹɻɰlɭʎʟə]|$)",
    "i",
    seqs,
    perl = TRUE
  )

  # a [w] after a vowel and followed by a consonant or nothing is replaced by an
  # [u] for getting a correct alignment
  seqs <- gsub(
    "(?<=[iyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔæɐaɶɑɒɛ̠ɛːĭeˑ])(w|w̆)(?=[pbtdʈɖcɟkɡqɢʔmɱnɳɲŋɴʙrʀⱱɾɽɸβfvθðszʃʒʂʐçʝxɣχʁħʕhɦɬɮʋɹɻjɰlɭʎʟə]|$)",
    "u",
    seqs,
    perl = TRUE
  )
  
  multi <- lingpy$Multiple(seqs)
  multi$prog_align()

  res <- capture.output(str(multi))
  split_lines <- strsplit(res, "\t")
  features0 <- do.call(rbind, split_lines)
  features0 <- as.data.frame(features0, stringsAsFactors = FALSE)

  if (length(none) > 0)
  {
    features0[none,][features0[none,]=="-"] <- ""
    features0 <- features0[, sapply(features0, function(col) any(!col %in% c("-", "_", "")))]
  }
  
  colnames(features0) <- paste0(colnames(df)[j], 1:ncol(features0))

  if (j==2)
    features <- features0
  else
    features <- cbind(features, features0)
}

features[features=="-"] <- "0"
features <- cbind(variety=df[,1], features)

write.xlsx(features, "DutchRND010_Features.xlsx")
