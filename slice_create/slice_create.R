library(ActiveDriverWGS)
library(parallel)
library(plyr)

options(stringsAsFactors = FALSE)

###read in elements - 20185 unique genes###
elements = prepare_elements_from_BED12('/u/amammoliti/lymph/elements/gc19_pc.cds.bed')
names(elements)[2] <- "start"
names(elements)[3] <- "end"


###split genes into individual lists###
gene_split_1 <- split(elements, f=elements$id)

###group genes into 404 individual slices for parallelization###
gene_split_2 <- parallel::splitIndices(nx=length(gene_split_1), ncl=ceiling(length(gene_split_1) / 50))
for(i in seq_along(gene_split_2)){
  slice <- gene_split_1[gene_split_2[[i]]]
  saveRDS(slice, file=paste0("/u/amammoliti/lymph/parallel/slices/slice_", i, ".rds"))
}