zcat ./October_2016_whitelist_2583.snv_mnv_indel.maf.gz | { head -1; awk '/Lymph-BNHL/ || /Lymph-CLL/ || /Lymph-NOS/';} >> Project_Filtered_Maf.txt 

#keeps header of .maf file
#there are 36 duplicated mutations. There cannot be any duplicates to run active driver
