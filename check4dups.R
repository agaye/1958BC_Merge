#
# Amadou Gaye - 13 September 2014
# This script checks for duplicates between two plink datasets. In the 1958BC datasets there duplicated
# IDs within and across datasets. Here I use the genotypes of the individuals to see whether or not
# they are truly duplicates. 
# I first merge two datasets using only their overlapping markers. This is done by calling the function
# 'align' which produced to plink datasets which contain only their overlapping SNPs. Then those datasets
# are merged including only SNPs with a maf of 0.30 using common SNPs which are likely to not vary much 
# and a high threshold of 0.90 for minimum identity by descent ('minimum_ibd' measured as PI_HAT). 
# Only twins or duplicates should be found related and since 1958BC datasets do not contain twins I know 
# they must be duplicates.
#
# names of the plink datasets
files <- c("cng","metabochip","rahi","t1dgc","wtccc1_aff","wtccc1_inf","wtccc2_ill","wtccc1_15k","wtccc2_aff")
size <- length(files)

# path to input files
path0 = "/home/ag13748/1958BC/Merge.31.8.14/plink04/"

# path to store output files
path1 = "/home/ag13748/1958BC/Merge.31.8.14/checksResults/"

for(i in 1:(size-1)){
  if(i == size){ break }
  for(j in (i+1):size){
    cat(files[i],"-", files[j], "...\n")

    # call the function that gets the files to merge ready
    source("/home/ag13748/1958BC/Merge.31.8.14/scripts/align.R")
    align(files[i], files[j], path0, path1)

    # merge the files
    cat("   Merging the two datasets\n")
    newfile1 <- paste0(path1, files[i])
    newfile2 <- paste0(path1, files[j])
    mergedfile <- paste0(path1,files[i], "_", files[j])
    system(paste0("p-link --silent --bfile ", newfile1," --bmerge ",  newfile2,".bed ", newfile2,".bim ", newfile2,".fam --make-bed --out ", mergedfile)) 
    
    # delete input files to spare some space
    system(paste0("rm ", newfile1, ".bed ", newfile2, ".bed"))
    system(paste0("rm ", newfile1, ".bim ", newfile2, ".bim"))
    system(paste0("rm ", newfile1, ".fam ", newfile2, ".fam"))
  }
}

# use the merged files to check for duplicates
for(i in 1:(size-1)){
  if(i == size){ break }
  j <- i
  for(j in (j+1):size){
    cat(files[i],"-", files[j], "...\n")
    cat("   Checking for duplicates\n")
    # now check for duplicates
    mergedfile <- paste0(path1,files[i], "_", files[j])
    summaryfile <- paste0(path1,files[i], "_", files[j])
    system(paste0("p-link --silent --bfile ", mergedfile," --maf 0.30 --genome --min 0.90 --allow-no-sex --out ",  summaryfile))   
  }
}




