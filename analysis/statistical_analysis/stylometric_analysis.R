# Balduin Landolt, 2019-2020
# License: AGPL (see file `LICENSE-AGPL` in project root)


# set working directory
# setwd() # adjust to set working dir
current_working_dir <- dirname(rstudioapi::getActiveDocumentContext()$path) # NB: only works in RStudio!
setwd(current_working_dir) # Dito!
getwd()



# load package
library(stylo)
library(ggplot2)


# manual testing with GUI
#stylo()
#oppose()








# Delta with Abbr only
# --------------------


# load samples
sample_01 = scan("../tmp_data/stylo/abbr_only/part_01_vol1_p1ff.txt", what="character", sep=" ")
sample_02 = scan("../tmp_data/stylo/abbr_only/part_02_vol1_p473ff.txt", what="character", sep=" ")
sample_03 = scan("../tmp_data/stylo/abbr_only/part_03_vol2_p303ff.txt", what="character", sep=" ")
sample_04 = scan("../tmp_data/stylo/abbr_only/part_04_imposter_am232fol.txt", what="character", sep=" ")

# make sample list
sample_list = list(sample_01, sample_02, sample_03, sample_04)
names(sample_list) = c("sample_01", "sample_02", "sample_03", "imposter")

# test: run stylo on sample list (props GUI)
#stylo(parsed.corpus = sample_list)

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
      custom.graph.title="Abbreviations Only",
      write.png.file=TRUE)








# Delta with am only
# --------------------


# load samples
sample_01 = scan("../tmp_data/stylo/am_only/part_01_vol1_p1ff.txt", what="character", sep=" ")
sample_02 = scan("../tmp_data/stylo/am_only/part_02_vol1_p473ff.txt", what="character", sep=" ")
sample_03 = scan("../tmp_data/stylo/am_only/part_03_vol2_p303ff.txt", what="character", sep=" ")
sample_04 = scan("../tmp_data/stylo/am_only/part_04_imposter_am232fol.txt", what="character", sep=" ")

# make sample list
sample_list = list(sample_01, sample_02, sample_03, sample_04)
names(sample_list) = c("sample_01", "sample_02", "sample_03", "imposter")

# test: run stylo on sample list (props GUI)
#stylo(parsed.corpus = sample_list)

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
      custom.graph.title="Abbreviation Marks Only",
      write.png.file=TRUE)








# Delta with whole word
# ---------------------

# load samples
sample_01 = scan("../tmp_data/stylo/whole_words/part_01_vol1_p1ff.txt", what="character", sep=" ")
sample_02 = scan("../tmp_data/stylo/whole_words/part_02_vol1_p473ff.txt", what="character", sep=" ")
sample_03 = scan("../tmp_data/stylo/whole_words/part_03_vol2_p303ff.txt", what="character", sep=" ")
sample_04 = scan("../tmp_data/stylo/whole_words/part_04_imposter_am232fol.txt", what="character", sep=" ")

# make sample list
sample_list = list(sample_01, sample_02, sample_03, sample_04)
names(sample_list) = c("sample_01", "sample_02", "sample_03", "imposter")

# test: run stylo on sample list (props GUI)
#stylo(parsed.corpus = sample_list)

# create frequency list and table
frequ_list_all = make.frequency.list(sample_list)
freq_table = make.table.of.frequencies(sample_list, frequ_list_all)


# calculate distance matrix
dist_matrix = dist.cosine(freq_table)
as.matrix(dist_matrix)



# plot graphs
stylo(frequencies = freq_table, 
      gui = F, 
      mfw.min=1000, 
      mfw.max=1000, 
      distance.measure="dist.cosine", 
      write.png.file=T, 
      custom.graph.title="Whole Words",
      write.png.file=TRUE)
stylo(frequencies = freq_table, 
      gui = F, 
      mfw.min=10000, 
      mfw.max=10000, 
      distance.measure="dist.cosine", 
      write.png.file=T, 
      custom.graph.title="Whole Words",
      write.png.file=TRUE)




# custom rolling delta
# ====================


# functions

roll = function(text, window_size=100, step_size=20){
   max_len = length(text)
   no_steps = floor((max_len - (2 * window_size)) / step_size) + 1 #starting from 1, not 0
   #print(no_steps)
   res = vector()
   delim_changes = vector()
   has_delim = vector()
   in_p2=FALSE
   for (i in 1:no_steps) {
      offset = (i - 1) * step_size + 1
#      print("offset:")
#      print(offset)
      a = offset
      b = offset+window_size-1
      c = offset+window_size
      d = offset+(2*window_size)-1
#      print("from - to:")
#      print(a)
#      print(b)
#      print(c)
#      print(d)
#      print("")
      part1 = text[a:b]
      part2 = text[c:d]
      delim_changes = c(delim_changes, in_p2 && "|" %in% part1)
      has_delim = c(has_delim, "|" %in% part1 || "|" %in% part2)
#      if("|" %in% part1){
#         delim_changes = c(delim_changes, in_p2) # if previousely in p2, now in p1, there is a change
#      }
      in_p2 = "|" %in% part2
      delta = compare_windows(part1, part2)
      res = c(res, delta)
   }
   return(list(deltas=res,delim_changes=delim_changes,has_delim=has_delim))
}

compare_windows = function(win1, win2){
   win_list = list(win1, win2)
   frequ_list_combined = make.frequency.list(win_list)
   freq_table = make.table.of.frequencies(win_list, frequ_list_combined)
   dist_matrix = as.matrix(dist.cosine(freq_table))
   return(dist_matrix[1,2])
}

do_rolling_delta = function(...){
   deltas = roll(...)
   delta_frame = as.data.frame(deltas$deltas)
   names(delta_frame) = "val"
   delta_frame$n = 1:length(deltas$deltas)
   plot = ggplot(data = delta_frame,aes(x=n, y=val, fill=as.factor(as.numeric(deltas$has_delim)+1)))+
      geom_bar(stat = "identity", width = 1)+
      geom_vline(xintercept=which(deltas$delim_changes), color = "red", linetype="dotted", size=1.5)+
      scale_fill_manual(name="transition", values = c("#1455d9", "#1cad1a"), labels=c("No", "Yes"))+
      labs(x = "Window", y = "Delta")
   return(plot)
}


# load data

text_abbr = scan("../tmp_data/stylo/rolling/all_texts_abbr_only.txt", what="character", sep=" ")
text_am = scan("../tmp_data/stylo/rolling/all_texts_am_only.txt", what="character", sep=" ")
text_wholeword = scan("../tmp_data/stylo/rolling/all_texts_whole_word.txt", what="character", sep=" ")

# roll
plot = do_rolling_delta(text_abbr, window_size=100, step_size=5)
plot = plot + labs(title = "Rolling Delta",
                   subtitle = "Abbreviations",
                   caption = "Window Size: 100\nStep Size: 5")
ggsave("../out/plots/rolling_abbr.png", plot = plot)

plot = do_rolling_delta(text_am, window_size=100, step_size=5)
plot = plot + labs(title = "Rolling Delta",
                   subtitle = "Abbreviation Marks",
                   caption = "Window Size: 100\nStep Size: 5")
ggsave("../out/plots/rolling_am.png", plot = plot)

plot = do_rolling_delta(text_wholeword, window_size=150, step_size=5)
plot = plot + labs(title = "Rolling Delta",
                   subtitle = "Whole Words",
                   caption = "Window Size: 150\nStep Size: 5")
ggsave("../out/plots/rolling_word.png", plot = plot)











library(quanteda)
library(tm)







# Keyness
# =======

plot_keynes = function(text1, text2){
   
   s1 = paste(text1, collapse = " ")
   s1 = gsub("[()|{}]", "", s1)
   s1 = gsub(";;", "_", s1)
   s1 = gsub(";", "_", s1)
   s2 = paste(text2, collapse = " ")
   s2 = gsub("[()|{}]", "", s2)
   s2 = gsub(";;", "_", s2)
   s2 = gsub(";", "_", s2)
   corpus = c(s1, s2)
   dfm = dfm(corpus)
   keys <- textstat_keyness(dfm)
   textplot_keyness(keys)
}


plot_keynes(sample_01, sample_02)
plot_keynes(sample_01, sample_03)
plot_keynes(sample_01, sample_04)
plot_keynes(sample_02, sample_03)
plot_keynes(sample_02, sample_04)
plot_keynes(sample_03, sample_04)















