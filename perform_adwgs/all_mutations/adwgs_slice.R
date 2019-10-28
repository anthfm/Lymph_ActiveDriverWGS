library(ActiveDriverWGS)
library(parallel)
library(plyr)

options(stringsAsFactors = FALSE)

###read in filtered mutation data###
mutations <- read.csv("~/lymph/mutations/Project_Filtered_Maf.txt", sep="\t")
mutations_df <- mutations[,c("Chromosome", "Start_position", "End_position", "Reference_Allele", "Tumor_Seq_Allele2", "Donor_ID")]
colnames(mutations_df) <- c("chr", "pos1","pos2","ref","alt","patient")
mutations_df <- unique(mutations_df)
mutations_df$chr <- paste("chr", sep="",mutations_df$chr)


#read in individual slice specified by cluster job
myfn <- commandArgs(trailingOnly=TRUE)[1]
print("done loading")
print(myfn)
mybasenm <- basename(myfn)
print(mybasenm)
slice <- readRDS(myfn)

#perform ActiveDriverWGS on each slice

splitix <- parallel::splitIndices(nx=length(slice), ncl=ceiling(length(slice) / 1))

mcres <- parallel::mclapply(splitix, function(x, ele) {
    print(names(ele[x]))
    isolate <- ldply(ele[x], data.frame)[,2:5]
    results = ActiveDriverWGS(mutations = mutations_df,
                                elements = isolate)
    return(results)
  },ele=slice, mc.cores=8)


final <- ldply(mcres, data.frame)

saveRDS(final, file=paste0("~/lymph/parallel/adwgs/computed/", gsub(mybasenm, pattern = ".rds", replacement="_comp.rds", fixed=TRUE)))