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


mtrx = as.matrix(dist_matrix)
v = mtrx[1,2]
class(v)

# plot graph
stylo(frequencies = freq_table, 
      gui = F, 
      mfw.min=1000, 
      mfw.max=1000, 
      distance.measure="dist.cosine", 
      write.png.file=T, 
      custom.graph.title="Titel")




# custom rolling delta
# ====================


# functions

roll = function(text, window_size=100, step_size=20){
   max_len = length(text)
   no_steps = floor((max_len - (2 * window_size)) / step_size) + 1 #starting from 1, not 0
   #print(no_steps)
   res = vector()
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
      delta = compare_windows(part1, part2)
      res = c(res, delta)
   }
   return(res)
}

compare_windows = function(win1, win2){
   win_list = list(win1, win2)
   frequ_list_combined = make.frequency.list(win_list)
   freq_table = make.table.of.frequencies(win_list, frequ_list_combined)
   dist_matrix = as.matrix(dist.cosine(freq_table))
   return(dist_matrix[1,2])
}


# load data

text_abbr = scan("../tmp_data/stylo/rolling/all_texts_abbr_only.txt", what="character", sep=" ")
text_wholeword = scan("../tmp_data/stylo/rolling/all_texts_whole_word.txt", what="character", sep=" ")

# roll
deltas = roll(text_abbr)
delta_frame = as.data.frame(deltas)
names(delta_frame) = "val"
delta_frame$n = 1:length(deltas)
plot = ggplot(data = delta_frame,aes(x=n, y=val))+
   geom_bar(stat = "identity")
plot
plot = ggplot(data = delta_frame,aes(x=n, y=val))+
   geom_line()
plot









