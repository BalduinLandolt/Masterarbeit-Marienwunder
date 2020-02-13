# Balduin Landolt, 2019
# License: AGPL (see file `LICENSE-AGPL` in project root)


# set working directory
# setwd() # adjust to set working dir
current_working_dir <- dirname(rstudioapi::getActiveDocumentContext()$path) # NB: only works in RStudio!
setwd(current_working_dir) # Dito!
getwd()

# load package
library(ggplot2)
library(reshape2) #unused?
#library(cowplot)


# load custom functions
# ---------------------

# normalize by total amount of abbreviations for a sample
normalize = function(value, sample){
  no_abbreviations = page_overview$no_abbreviations[page_overview$sample == sample]
  res = value/no_abbreviations
  return(res)
}

# extract abbreviation mark subframe
get_subframe_am = function(abbr_mk){
  res = subset(abbreviations[which(abbreviations$am == abbr_mk),])
  res$am = factor(res$am)
  res$ex = factor(res$ex)
  return(res)
}

# extract expansion subframe
get_subframe_ex = function(ex){
  res = subset(abbreviations[which(abbreviations$ex == ex),])
  res$am = factor(res$am)
  res$ex = factor(res$ex)
  return(res)
}


# read data from file
page_overview = read.csv("../tmp_data/page_overview.csv", encoding = 'UTF-8')
head(page_overview)
data_by_line = read.csv("../tmp_data/data_by_line.csv", encoding = 'UTF-8')
head(data_by_line)
abbreviations = read.csv("../tmp_data/abbreviations.csv", encoding = 'UTF-8')
head(abbreviations)


page_overview$s_fact = as.factor(page_overview$sample)
page_overview$abbreviations_per_word = page_overview$no_abbreviations/page_overview$no_words
page_overview$abbreviations_per_line = page_overview$no_abbreviations/page_overview$no_lines
page_overview$abbreviations_per_page = page_overview$no_abbreviations/page_overview$no_pages
page_overview$abbreviations_per_1000chars = page_overview$no_abbreviations/page_overview$no_characters*1000
page_overview$lines_per_page = page_overview$no_lines/page_overview$no_pages
page_overview$chars_per_page = page_overview$no_characters/page_overview$no_pages
page_overview$chars_per_line = page_overview$no_characters/page_overview$no_lines


# ensures output folder exists
if (!dir.exists("../out/plots")){
  dir.create("../out/plots")
}
if (!dir.exists("../out/plots/perLine")){
  dir.create("../out/plots/perLine")
}
if (!dir.exists("../out/plots/abbreviations")){
  dir.create("../out/plots/abbreviations")
}
if (!dir.exists("../out/plots/abbreviations/forEach")){
  dir.create("../out/plots/abbreviations/forEach")
}
# NB: to be sure the time stamp of the output plots is correct, make sure to delete all previously existing plots


# plot words per line
plot = ggplot(data_by_line, aes(data_by_line$no_words)) + geom_histogram(fill="red")
ggsave("../out/plots/perLine/hist_wordsPerLine.png", plot = plot)

plot = qplot(data_by_line$no_words, geom="histogram", fill=factor(data_by_line$sample))
ggsave("../out/plots/perLine/hist_wordsPerLine_bySample_stack.png", plot = plot)

plot = ggplot(data_by_line, aes(data_by_line$no_words, fill=factor(data_by_line$sample))) + geom_histogram(position = "dodge")
ggsave("../out/plots/perLine/hist_wordsPerLine_bySample_dodge.png", plot = plot)

plot = ggplot(data_by_line, aes(y=data_by_line$no_words, x=factor(data_by_line$sample))) + geom_boxplot()
ggsave("../out/plots/perLine/box_wordsPerLine_bySample.png", plot = plot)


# plot characters per line
plot = qplot(data_by_line$no_characters, geom="histogram", fill=factor(data_by_line$sample))
ggsave("../out/plots/perLine/hist_charactersPerLine_bySample_stack.png", plot = plot)

plot = ggplot(data_by_line, aes(data_by_line$no_characters, fill=factor(data_by_line$sample))) + geom_histogram(position = "dodge")
ggsave("../out/plots/perLine/hist_charactersPerLine_bySample_dodge.png", plot = plot)

plot = ggplot(data_by_line, aes(y=data_by_line$no_characters, x=factor(data_by_line$sample))) + geom_boxplot()
ggsave("../out/plots/perLine/box_charactersPerLine_bySample.png", plot = plot)


# plot abbreviations per line
plot = qplot(data_by_line$no_abbreviations, geom="histogram", fill=factor(data_by_line$sample))
ggsave("../out/plots/perLine/hist_abbreviationsPerLine_bySample_stack.png", plot = plot)

plot = ggplot(data_by_line, aes(data_by_line$no_abbreviations, fill=factor(data_by_line$sample))) +
  geom_histogram(position = "dodge", bins = max(data_by_line$no_abbreviations))
ggsave("../out/plots/perLine/hist_abbreviationsPerLine_bySample_dodge.png", plot = plot)

plot = ggplot(data_by_line, aes(data_by_line$no_abbreviations, fill=factor(data_by_line$sample))) +
  geom_density(fill="red", adjust=0.65)
ggsave("../out/plots/perLine/density_abbreviationsPerLine.png", plot = plot)

plot = ggplot(data_by_line, aes(data_by_line$no_abbreviations, fill=factor(data_by_line$sample))) +
  geom_density(alpha=0.5, adjust=0.65) 
ggsave("../out/plots/perLine/density_abbreviationsPerLine_bySample.png", plot = plot)

plot = ggplot(data_by_line, aes(y=data_by_line$no_abbreviations, x=factor(data_by_line$sample))) + geom_boxplot()
ggsave("../out/plots/perLine/box_abbreviationsPerLine_bySample.png", plot = plot)

# test normal distribution
shapiro.test(data_by_line$no_abbreviations)
shapiro.test(data_by_line$no_abbreviations[which(data_by_line$sample == 0)])
shapiro.test(data_by_line$no_abbreviations[which(data_by_line$sample == 1)])



# abbreviations
# -------------

# plot abbreviation mark distribution
plot = ggplot(abbreviations, aes(abbreviations$am))
plot = plot + geom_bar()
ggsave("../out/plots/abbreviations/hist_amDistribution.png", plot = plot, width = 20)

abbr_count = data.frame(table(abbreviations$sample, abbreviations$am, dnn = c("sample", "am")))
abbr_count$Freq_normalized = mapply(normalize, abbr_count$Freq, abbr_count$sample)

plot = ggplot(abbr_count, aes(abbr_count$am, abbr_count$Freq_normalized, fill=abbr_count$sample))
plot = plot + geom_bar(position = "dodge", stat = "identity")
ggsave("../out/plots/abbreviations/hist_amDistribution_bySample.png", plot = plot, width = 20)

# plot expansion distribution
plot = ggplot(abbreviations, aes(abbreviations$ex))
plot = plot + geom_bar()
ggsave("../out/plots/abbreviations/hist_exDistribution.png", plot = plot, width = 30)

ex_count = data.frame(table(abbreviations$sample, abbreviations$ex, dnn = c("sample", "ex")))
ex_count$Freq_normalized = mapply(normalize, ex_count$Freq, ex_count$sample)

plot = ggplot(ex_count, aes(ex_count$ex, ex_count$Freq_normalized, fill=ex_count$sample))
plot = plot + geom_bar(position = "dodge", stat = "identity")
ggsave("../out/plots/abbreviations/hist_exDistribution_bySample.png", plot = plot, width = 30)


# look at them separately
sub_frame_am = as.vector(lapply(levels(abbreviations$am), get_subframe_am))

for (val in sub_frame_am){
  fr = as.data.frame(val)
  ex_count = data.frame(table(fr$sample, fr$ex, dnn = c("sample", "ex")))
  ex_count$Freq_normalized = mapply(normalize, ex_count$Freq, ex_count$sample)
  plot = ggplot(ex_count, aes(ex_count$ex, ex_count$Freq_normalized, fill=ex_count$sample))
  plot = plot + geom_bar(position = position_dodge(width = 1), stat = "identity")
  plot = plot + geom_text(aes(label=ex_count$Freq), vjust=-0.3, size=3.5, check_overlap = TRUE, position = position_dodge(width = 1))
  plot = plot + ggtitle(paste("AM: ", levels(fr$am)))
  ggsave(paste("../out/plots/abbreviations/forEach/am_",levels(fr$am),".png", sep = ""), plot = plot)
}

sub_frame_ex = as.vector(lapply(levels(abbreviations$ex), get_subframe_ex))

for (val in sub_frame_ex){
  fr = as.data.frame(val)
  am_count = data.frame(table(fr$sample, fr$am, dnn = c("sample", "am")))
  am_count$Freq_normalized = mapply(normalize, am_count$Freq, am_count$sample)
  plot = ggplot(am_count, aes(am_count$am, am_count$Freq_normalized, fill=am_count$sample))
  plot = plot + geom_bar(position = position_dodge(width = 1), stat = "identity")
  plot = plot + geom_text(aes(label=am_count$Freq), vjust=-0.3, size=3.5, check_overlap = TRUE, position = position_dodge(width = 1))
  plot = plot + ggtitle(paste("EX: ", levels(fr$ex)))
  ggsave(paste("../out/plots/abbreviations/forEach/ex_",levels(fr$ex),".png", sep = ""), plot = plot)
}












