myfn <- list.files("~/lymph/parallel/adwgs/computed_shm/", full.names=TRUE)
slices <- list()
for(fn in myfn){
        temp <- readRDS(fn)
        slices[[fn]] <- temp
}

result <- do.call(rbind, slices)
rownames(result) <- NULL
save(result, file="~/lymph/parallel/adwgs/result/lymph_ADWGS_SHM_Results.RData")