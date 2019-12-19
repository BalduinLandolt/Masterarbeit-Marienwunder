# Balduin Landolt, 2019
# License: AGPL (see file `LICENSE-AGPL` in project root)


# set working directory
# setwd() # adjust to set working dir
getwd()

# load package
library(ggplot2)


# read data from file
page_overview = read.csv("../tmp_data/page_overview.csv")
head(page_overview)
data_by_line = read.csv("../tmp_data/data_by_line.csv")
head(data_by_line)


page_overview$s_fact = as.factor(page_overview$sample)
page_overview$abbreviations_per_word = page_overview$no_abbreviations/page_overview$no_words
page_overview$abbreviations_per_line = page_overview$no_abbreviations/page_overview$no_lines
page_overview$abbreviations_per_page = page_overview$no_abbreviations/page_overview$no_pages
page_overview$abbreviations_per_100chars = page_overview$no_abbreviations/page_overview$no_characters*1000
page_overview$lines_per_page = page_overview$no_lines/page_overview$no_pages
page_overview$chars_per_page = page_overview$no_characters/page_overview$no_pages
page_overview$chars_per_line = page_overview$no_characters/page_overview$no_lines



# plot words per line
ggplot(data_by_line, aes(data_by_line$no_words)) + geom_histogram(fill="red")
qplot(data_by_line$no_words, geom="histogram", fill=factor(data_by_line$sample))
ggplot(data_by_line, aes(data_by_line$no_words, fill=factor(data_by_line$sample))) + geom_histogram(position = "dodge")
ggplot(data_by_line, aes(y=data_by_line$no_words, x=factor(data_by_line$sample))) + geom_boxplot()


# plot characters per line
qplot(data_by_line$no_characters, geom="histogram", fill=factor(data_by_line$sample))
ggplot(data_by_line, aes(data_by_line$no_characters, fill=factor(data_by_line$sample))) + geom_histogram(position = "dodge")
ggplot(data_by_line, aes(y=data_by_line$no_characters, x=factor(data_by_line$sample))) + geom_boxplot()


# plot abbreviations per line
qplot(data_by_line$no_abbreviations, geom="histogram", fill=factor(data_by_line$sample))
ggplot(data_by_line, aes(data_by_line$no_abbreviations, fill=factor(data_by_line$sample))) +
  geom_histogram(position = "dodge", bins = max(data_by_line$no_abbreviations))
ggplot(data_by_line, aes(data_by_line$no_abbreviations, fill=factor(data_by_line$sample))) +
  geom_density(fill="red", adjust=0.65) 
ggplot(data_by_line, aes(data_by_line$no_abbreviations, fill=factor(data_by_line$sample))) +
  geom_density(alpha=0.5, adjust=0.65) 
ggplot(data_by_line, aes(y=data_by_line$no_abbreviations, x=factor(data_by_line$sample))) + geom_boxplot()



