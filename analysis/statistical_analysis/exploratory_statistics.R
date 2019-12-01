# Balduin Landolt, 2019
# License: AGPL (see file `LICENSE-AGPL` in project root)


# set working directory
setwd()
getwd()

# load package
library(ggplot2)


# read data from file
page_overview = read.csv("../tmp_data/page_overview.csv")
head(page_overview)


page_overview$s_fact = as.factor(page_overview$sample)
page_overview$abbreviations_per_word = page_overview$no_abbreviations/page_overview$no_words
page_overview$abbreviations_per_line = page_overview$no_abbreviations/page_overview$no_lines
page_overview$abbreviations_per_page = page_overview$no_abbreviations/page_overview$no_pages
page_overview$lines_per_page = page_overview$no_lines/page_overview$no_pages


plot(page_overview$s_fact, page_overview$no_abbreviations)
plot(page_overview$no_abbreviations)
hist(page_overview$no_abbreviations, breaks = 10)



qplot(page_overview$no_abbreviations)
qplot(s_fact, lines_per_page, data = page_overview)
qplot(no_abbreviations, data = page_overview, geom = "density")



#obsolete
page_overview_transposed = as.data.frame(t(page_overview), row.names=page_overview$informations)
head(page_overview_transposed)
