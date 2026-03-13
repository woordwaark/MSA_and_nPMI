## Description
This repository provides software for decomposing phonetic transcriptions into individual features using multiple sequence alignment, as well as for computing nPMI over those features. The implementation follows the methodology introduced by Sung and Prokić (2024) / Sung (2026).

### Data

The file `DutchRND010.xlsx' is an example data set. The data is taken from the *Reeks Nederlandse Dialectatlassen* (RND) which is a series of atlasses covering the Dutch dialect area. The Dutch dialect area comprises the Netherlands, the northern part of Belgium, a smaller northwestern part of France and the German county Bentheim. The atlas was compiled by prof. E. Blancquaert and Willem Pée in the period 1925-1982. The RND contains the translations of 139 sentences in 1956 local dialects spread over this entire area. The sentences are translated and transcribed in phonetic script for each dialect. The atlas is online available at a website of Ghent University.

A selection of 360 local dialects is available at the Dutch Language Institute. The data set that we offer on this page includes a subset of 10 local dialects having transcriptions of 25 words each.

### Software

The software includes three R scripts.

#### table2features.R

Read a table with word transcriptions, perform multiple sequence alignment, save the result as feature table.

Input: DutchRND010.xlsx

Output: DutchRND010_Features.xlsx

#### features2nPMI

Read a feature table and partition, calculate nPMI values for each combination of group and feature value.

Input: DutchRND010_Features.xlsx, DutchRND010_Partition.tsv

Output: DutchRND010_nPMI.txt

#### features2features.R

Convert a feature table with multiple feature values listed vertically into a feature table with multiple feature values combined in a single cell next to each other, separated by ‘/’.

Input: DutchRND010_Features.xlsx

Output: DutchRND010_Features_multiple_grouped.xlsx

### References

Blancquaert, E. and Peé, W., editors (1925–1982). *Reeks Nederlands(ch)e Dialectatlassen*. De Sikkel, Antwerpen.

Sung, H. W. M. & Prokić, J. (2024). Detecting Dialect Features Using Normalised Pointwise Information. *Computational Linguistics in the Netherlands Journal*, 13, 121-145.

Sung, H. W. M. (2026). *Advancing Explanatory and Tonal Dialectometry* (Doctoral dissertation, Leiden University, Netherlands Graduate School of Linguistics).



