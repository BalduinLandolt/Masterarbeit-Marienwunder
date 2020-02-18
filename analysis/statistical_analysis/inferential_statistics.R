# Balduin Landolt, 2019
# License: AGPL (see file `LICENSE-AGPL` in project root)


# set working directory
# setwd() # adjust to set working dir
current_working_dir <- dirname(rstudioapi::getActiveDocumentContext()$path) # NB: only works in RStudio!
setwd(current_working_dir) # Dito!
getwd()



# load package
library(gmodels)


# read data from file
page_overview = read.csv("../tmp_data/page_overview.csv", encoding = 'UTF-8')
head(page_overview)
data_by_line = read.csv("../tmp_data/data_by_line.csv", encoding = 'UTF-8')
head(data_by_line)
abbreviations = read.csv("../tmp_data/abbreviations.csv", encoding = 'UTF-8')
head(abbreviations)
abbreviations = read.csv("../tmp_data/v_anlaut.csv", encoding = 'UTF-8')
head(abbreviations)


# Sample chi square test



