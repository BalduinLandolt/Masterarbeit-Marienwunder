# Balduin Landolt, 2019-2020
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
anlaut = read.csv("../tmp_data/v_anlaut.csv", encoding = 'UTF-8')
head(anlaut)



# upper cases

table = cbind("uppers"=page_overview$no_uppercases, "lowers"=page_overview$no_characters - page_overview$no_uppercases)
CrossTable(table, 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")


# Sample chi square test
CrossTable(anlaut$letter, 
           anlaut$sample, 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")

# remove capital 'V', because it causes too small expected frequencies, samples 0 and 1
CrossTable(anlaut$letter[which(anlaut$letter != 'V' & as.numeric(anlaut$sample) < 2)], 
           anlaut$sample[which(anlaut$letter != 'V' & as.numeric(anlaut$sample) < 2)], 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")

# remove capital 'V', because it causes too small expected frequencies, samples 0 and 3
CrossTable(anlaut$letter[which(anlaut$letter != 'V' & as.numeric(anlaut$sample) %in% c(0, 3))], 
           anlaut$sample[which(anlaut$letter != 'V' & as.numeric(anlaut$sample) %in% c(0, 3))], 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")

# remove capital 'V', because it causes too small expected frequencies
CrossTable(anlaut$letter[which(anlaut$letter != 'V')], 
           anlaut$sample[which(anlaut$letter != 'V')], 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")







# abbreviations
# -------------

options = c("n")
CrossTable(abbreviations$am[which(abbreviations$ex %in% options)], 
           abbreviations$sample[which(abbreviations$ex %in% options)], 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")


options = c("uds")
CrossTable(abbreviations$am[which(abbreviations$ex %in% options)], 
           abbreviations$sample[which(abbreviations$ex %in% options)], 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")


options = c("u", "us", "ud", "uds")
CrossTable(abbreviations$am[which(abbreviations$ex %in% options)], 
           abbreviations$sample[which(abbreviations$ex %in% options)], 
           fisher = TRUE, 
           chisq = TRUE, 
           expected = TRUE, 
           sresid = TRUE, 
           format = "SPSS")




















