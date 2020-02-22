# Balduin Landolt, 2019-2020
# License: AGPL (see file `LICENSE-AGPL` in project root)


# set working directory
# setwd() # adjust to set working dir
current_working_dir <- dirname(rstudioapi::getActiveDocumentContext()$path) # NB: only works in RStudio!
setwd(current_working_dir) # Dito!
getwd()

# load package
library(ggplot2)
library(psych)
#library(reshape2) #unused?
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
v_anlaut = read.csv("../tmp_data/v_anlaut.csv", encoding = 'UTF-8')
head(v_anlaut)


page_overview$s_fact = as.factor(page_overview$sample)
page_overview$abbreviations_per_word = page_overview$no_abbreviations/page_overview$no_words
page_overview$abbreviations_per_line = page_overview$no_abbreviations/page_overview$no_lines
page_overview$abbreviations_per_page = page_overview$no_abbreviations/page_overview$no_pages
page_overview$abbreviations_per_1000chars = page_overview$no_abbreviations/page_overview$no_characters*1000
page_overview$lines_per_page = page_overview$no_lines/page_overview$no_pages
page_overview$chars_per_page = page_overview$no_characters/page_overview$no_pages
page_overview$chars_per_line = page_overview$no_characters/page_overview$no_lines


# test normality

describe(data_by_line)
by(data_by_line, data_by_line$sample, describe)

shapiro.test(data_by_line$no_words)
by(data_by_line$no_words, data_by_line$sample, shapiro.test)
shapiro.test(data_by_line$no_characters)
by(data_by_line$no_characters, data_by_line$sample, shapiro.test)
shapiro.test(data_by_line$no_abbreviations)
by(data_by_line$no_abbreviations, data_by_line$sample, shapiro.test)



#TODO: delete old plots?

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
plot = ggplot(data_by_line, aes(no_words)) + 
  geom_bar(fill="#303030", width = 0.7)+
  scale_x_continuous(breaks=0:max(data_by_line$no_words))+
  labs(x = "Words per Line", y = "Count")
ggsave("../out/plots/perLine/bar_wordsPerLine.png", plot = plot)

plot = ggplot(data_by_line, aes(no_words, fill=factor(sample))) + 
  geom_bar(width = 0.7)+
  scale_x_continuous(breaks=0:max(data_by_line$no_words))+
  labs(x = "Words per Line", y = "Count")+
  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))
ggsave("../out/plots/perLine/bar_wordsPerLine_bySample_stack.png", plot = plot)

# not working correctly
#plot = ggplot(data_by_line, aes(no_words, fill=factor(sample))) + 
#  geom_bar(width = 0.7)+
#  scale_x_continuous(breaks=0:max(data_by_line$no_words))+
#  labs(x = "Words per Line", y = "Count")+
#  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))+
#  stat_function(fun = dnorm, args = list(mean=mean(data_by_line$no_words), sd=sd(data_by_line$no_words)), color="black", size = 1, aes(x=data_by_line$no_words))
#ggsave("../out/plots/perLine/bar_wordsPerLine_bySample_stack_with_norm.png", plot = plot,width = 7, height = 7)
#ggplot(data_by_line, aes(no_words, fill=factor(sample)))+ 
#  geom_histogram(aes(y=..density..))+
#  stat_function(fun = dnorm, args = list(mean=mean(data_by_line$no_words), sd=sd(data_by_line$no_words)), color="black", size = 1, aes(x=data_by_line$no_words,y=data_by_line$no_words+1))

plot = ggplot(data_by_line, aes(no_words, fill=factor(sample))) + 
  geom_bar(position = position_dodge2(preserve = "single"), width = 0.9)+
  scale_x_continuous(breaks=0:max(data_by_line$no_words))+
  labs(x = "Words per Line", y = "Count")+
  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))
ggsave("../out/plots/perLine/bar_wordsPerLine_bySample_dodge.png", plot = plot)

plot = ggplot(data_by_line, aes(y=data_by_line$no_words, x=factor(data_by_line$sample))) + 
  geom_boxplot()+
  scale_x_discrete(labels=levels(data_by_line$sample_name))+
  labs(y = "Words per Line", x = "Sample")
ggsave("../out/plots/perLine/box_wordsPerLine_bySample.png", plot = plot)





# TODO: ab hier schön machen


# plot characters per line
plot = ggplot(data_by_line, aes(no_characters)) + 
  geom_bar(fill="#303030", width = 0.7)+
  labs(x = "Characters per Line", y = "Count")
ggsave("../out/plots/perLine/bar_charPerLine.png", plot = plot)

plot = ggplot(data_by_line, aes(no_characters, fill=factor(sample))) + 
  geom_bar(width = 0.7)+
  labs(x = "Characters per Line", y = "Count")+
  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))
ggsave("../out/plots/perLine/bar_CharsPerLine_bySample_stack.png", plot = plot)

plot = ggplot(data_by_line, aes(no_characters, fill=factor(sample))) + 
  geom_bar(position = position_dodge2(preserve = "single"), width = 0.9)+
  labs(x = "Characters per Line", y = "Count")+
  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))
ggsave("../out/plots/perLine/bar_charsPerLine_bySample_dodge.png", plot = plot)

plot = ggplot(data_by_line, aes(y=data_by_line$no_characters, x=factor(data_by_line$sample))) + 
  geom_boxplot()+
  scale_x_discrete(labels=levels(data_by_line$sample_name))+
  labs(y = "Characters per Line", x = "Sample")
ggsave("../out/plots/perLine/box_charsPerLine_bySample.png", plot = plot, width = 7, height = 5)




# plot abbreviations per line


plot = ggplot(data_by_line, aes(no_abbreviations)) + 
  geom_bar(fill="#303030", width = 0.7)+
  labs(x = "Abbreviation per Line", y = "Count")
ggsave("../out/plots/perLine/bar_abbPerLine.png", plot = plot)

plot = ggplot(data_by_line, aes(no_abbreviations, fill=factor(sample))) + 
  geom_bar(width = 0.7)+
  labs(x = "Abbreviation per Line", y = "Count")+
  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))
ggsave("../out/plots/perLine/bar_abbPerLine_bySample_stack.png", plot = plot)

plot = ggplot(data_by_line, aes(no_abbreviations, fill=factor(sample))) + 
  geom_bar(position = position_dodge2(preserve = "single"), width = 0.9)+
  labs(x = "Abbreviation per Line", y = "Count")+
  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))
ggsave("../out/plots/perLine/bar_abbPerLine_bySample_dodge.png", plot = plot)

plot = ggplot(data_by_line, aes(y=data_by_line$no_abbreviations, x=factor(data_by_line$sample))) + 
  geom_boxplot()+
  scale_x_discrete(labels=levels(data_by_line$sample_name))+
  labs(y = "Abbreviation per Line", x = "Sample")
ggsave("../out/plots/perLine/box_abbPerLine_bySample.png", plot = plot)


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
shapiro.test(data_by_line$no_abbreviations[which(data_by_line$sample == 2)])
shapiro.test(data_by_line$no_abbreviations[which(data_by_line$sample == 3)])







# upper case chars 
plot = ggplot(page_overview, aes(y = page_overview$no_uppercases/page_overview$no_characters, x = page_overview$sample)) + 
  geom_bar(stat="identity", width = .6)+
  ggtitle("Capital Letters")+
  labs(x = "Sample", y = "Capital letter per Character")
ggsave("../out/plots/perLine/bar_uppers_per_char.png", plot = plot)





# v anlaut

anl = data.frame(table(v_anlaut$sample, v_anlaut$letter, dnn = c("sample", "letter")))
anl$sample = as.numeric(anl$sample)
vect = vector()
for (r in 1: nrow(anl)){
  sample = anl$sample[r]
  sum = sum(anl$Freq[which(anl$sample == sample)])
  print(sum)
  val = anl$Freq[r]/sum
  vect = c(vect, val)
}
anl$sample = as.factor(anl$sample)
anl$rel_freq = vect
#anl_sample_frequ = data.frame("sample"=levels(as.factor(anl$sample)))
#anl_sample_frequ$total_freq = lapply()
#anl$freq_rel = anl$Freq/
plot = ggplot(anl, aes(y = rel_freq, x = letter, fill=sample)) + 
  geom_bar(stat="identity", position = "dodge", width = .6)+
  labs(x = "Letter", y = "Relative Frequency")+
  scale_fill_discrete(name = "Sample", labels = levels(data_by_line$sample_name))
ggsave("../out/plots/perLine/bar_bar_v_anlaut.png", plot = plot, height = 5, width = 7)






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
#plot = plot + facet_wrap(~ ex_count$sample)
#plot = plot + stat_summary(fun.data = mean(), geom = "errorbar", position = position_dodge(width = 0.9), width = 0.2)
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
  plot = plot + ggtitle(paste("Abbreviation Mark: ", levels(fr$am)))+
    labs(x = "Feature", y = "Relative Frequency")+
    scale_fill_discrete(name = "Sample", labels = levels(abbreviations$sample_name))
  ggsave(paste("../out/plots/abbreviations/forEach/am_",levels(fr$am),".png", sep = ""), plot = plot, width = 7, height = 5)
}

sub_frame_ex = as.vector(lapply(levels(abbreviations$ex), get_subframe_ex))

for (val in sub_frame_ex){
  fr = as.data.frame(val)
  am_count = data.frame(table(fr$sample, fr$am, dnn = c("sample", "am")))
  am_count$Freq_normalized = mapply(normalize, am_count$Freq, am_count$sample)
  plot = ggplot(am_count, aes(am_count$am, am_count$Freq_normalized, fill=am_count$sample))
  plot = plot + geom_bar(position = position_dodge(width = 1), stat = "identity")
  plot = plot + geom_text(aes(label=am_count$Freq), vjust=-0.3, size=3.5, check_overlap = TRUE, position = position_dodge(width = 1))
  plot = plot + ggtitle(paste("Expansion: ", levels(fr$ex)))+
    labs(x = "Feature", y = "Relative Frequency")+
    scale_fill_discrete(name = "Sample", labels = levels(abbreviations$sample_name))
  ggsave(paste("../out/plots/abbreviations/forEach/ex_",levels(fr$ex),".png", sep = ""), plot = plot, width = 7, height = 5)
}





