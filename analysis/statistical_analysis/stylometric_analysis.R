# Balduin Landolt, 2019-2020
# License: AGPL (see file `LICENSE-AGPL` in project root)


# set working directory
# setwd() # adjust to set working dir
current_working_dir <- dirname(rstudioapi::getActiveDocumentContext()$path) # NB: only works in RStudio!
setwd(current_working_dir) # Dito!
getwd()



# load package
library(stylo)


# manual testing with GUI
stylo()
oppose()


# load samples
sample_01 = scan("../tmp_data/stylo/abbr_only/part_01_vol1_p1ff.txt", what="character", sep=" ")
sample_02 = scan("../tmp_data/stylo/abbr_only/part_02_vol1_p473ff.txt", what="character", sep=" ")
sample_03 = scan("../tmp_data/stylo/abbr_only/part_03_vol2_p303ff.txt", what="character", sep=" ")

# make sample list
sample_list = list(sample_01, sample_02, sample_03)
names(sample_list) = c("sample_01", "sample_02", "sample_03")

# test: run stylo on sample list (props GUI)
stylo(parsed.corpus = sample_list)

# create frequency list and table
frequ_list_all = make.frequency.list(sample_list)
freq_table = make.table.of.frequencies(sample_list, frequ_list_all)


# calculate distance matrix
dist_matrix = dist.cosine(freq_table)
as.matrix(dist_matrix)

# plot graph
stylo(frequencies = freq_table, 
      gui = F, 
      mfw.min=1000, 
      mfw.max=1000, 
      distance.measure="dist.cosine", 
      write.png.file=T, 
      custom.graph.title="Titel")



