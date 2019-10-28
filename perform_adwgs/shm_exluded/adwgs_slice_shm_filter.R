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


###Get sequence 2bp from each end of ref allele using getSeq package

#library(BSgenome.Hsapiens.UCSC.hg19)
#offset=2
#tt <- paste(getSeq(BSgenome.Hsapiens.UCSC.hg19,mutations_df$chr, start=mutations_df$pos1-offset, end=mutations_df$pos2-1),
       #mutations_df$ref,
       #getSeq(BSgenome.Hsapiens.UCSC.hg19,mutations_df$chr, start=mutations_df$pos1+1, end=mutations_df$pos2+offset)
   #)

#seq <- tt
#save(seq, file="~/lymph/mutations/mut_ref_sequence.RData")

###grep for DGYW and WRCH SHM motifs

load("~/lymph/mutations/mut_ref_sequence.RData")
mutations_df$segment <- gsub(" ","", seq)

D <- c("A","G","T")
G <- c("G")
Y <- c("C","T")
W <- c("A","T")

R <- c("A","G")
C <- c("C")
H <- c("C","T","A")

DGYW <- gsub(" ", "", do.call(paste, expand.grid(D,G,Y,W))) #all possible combinations for DGYW
WRCH <- gsub(" ", "", do.call(paste, expand.grid(W,R,C,H)))

shm_all <- c(DGYW, WRCH)

smh_matches <- mutations_df[grepl(paste(shm_all, collapse="|"), mutations_df$segment), ]
mutations_df <- mutations_df[setdiff(rownames(mutations_df),rownames(smh_matches)),]


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

saveRDS(final, file=paste0("~/lymph/parallel/adwgs/computed_shm/", gsub(mybasenm, pattern = ".rds", replacement="_comp.rds", fixed=TRUE)))


