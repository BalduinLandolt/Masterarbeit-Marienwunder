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

#qplot(page_overview$no_abbreviations)

#obsolete
page_overview_transposed = as.data.frame(t(page_overview), row.names=page_overview$informations)
head(page_overview_transposed)
