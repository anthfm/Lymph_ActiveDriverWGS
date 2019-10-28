dir=~/lymph/parallel/slices/*

for file in $dir; do
    base_ext=${file##*/}
    base=${base_ext%.rds}
    qsub -cwd -b y -N $base -l h_vmem=130g -o /dev/null -e /dev/null "module load R/3.6.0; Rscript /u/amammoliti/lymph/parallel/adwgs/adwgs_slice.R $file > /u/amammoliti/lymph/parallel/adwgs/logs/$base.log"

done