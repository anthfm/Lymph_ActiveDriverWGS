library(VennDiagram)
library(RColorBrewer)
library(stringr)
setwd("~/Desktop/")
options(stringsAsFactors = FALSE)

#################################
###### CREATE VENN DIAGRAM ######
#################################

all_set <- result_all$id[which(p.adjust(result_all$pp_element, method='fdr')<0.05)]
shm_set <-result_shm$id[which(p.adjust(result_shm$pp_element, method='fdr')<0.05)]

c <- do.call(rbind.data.frame, stringr::str_split(all_set, pattern = "::", n=4))
all_set_genes <- all_set_genes[,3]

shm_set_genes <- do.call(rbind.data.frame, stringr::str_split(shm_set, pattern = "::", n=4))
shm_set_genes <- shm_set_genes[,3]

shared_genes <- shm_set_genes[which(shm_set_genes %in% all_set_genes)]

draw.pairwise.venn(area1= length(all_set), 
                   area2=length(shm_set), 
                   cross.area = length(which(shm_set_genes %in% all_set_genes)), 
                   scaled = FALSE,
                   category = c("All Genes", "Genes with SHM Excluded"),
                   cat.pos = c(0,0),
                   lty = rep("blank", 2),
                   alpha = rep(0.5, 2),
                   # Numbers
                   cex = 1.4,
                   fontfamily = "sans",
            
                   # Circles
                   lwd = 3,
                   fill = c("light blue","light pink"))



###############################
###### CREATE BAR GRAPH #######
###############################

mutations_total <- c(length(all_set), length(shm_set))

barplot(mutations_total, main="Number of mutated genes with and without SHM's",
        xlab="Genes",
        ylab="Number of mutations",
        names.arg = c("All Genes", "Non-SHM Genes"),
        ylim=c(0,100),
        col=c("light blue","light pink"))


