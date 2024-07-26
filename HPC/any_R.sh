#!/bin/bash

# # Resources on test system: 
# GANDALF: 20 nodes, each with 12 cores. 70GB RAM
# PETRICHOR: 324 nodes, each wtih 64 cores, 512GB RAM, 480 storage

#SBATCH --account=OD-221168
#SBATCH --time=03:00:00 # request time (walltime, not compute time)
#SBATCH --mem=500MB # request memory. This is just a coordinator, so shouldn't need its own memory
#SBATCH --nodes=1 # number of nodes. Need > 1 to test utilisation
#SBATCH --ntasks-per-node=1 # Cores per node

#SBATCH -o %x_%A_%a.out # Standard output
#SBATCH -e %x_%A_%a.err # Standard error

# timing
begin=`date +%s`

module load R/4.3.1

# This allows just passing qmd and purling on the fly
# $1 is the first argument (the file)
filename=$1
if echo $filename | grep '.qmd'; then
    Rscript HPC/purl_qmd.R $filename
    # change $1 to be the R script, leave 2 and above unchanged
    rname="${filename%.qmd}.R"
    set -- "$rname" "${@:2}"
fi

Rscript $*


end=`date +%s`
elapsed=`expr $end - $begin`

echo Time taken for code: $elapsed

