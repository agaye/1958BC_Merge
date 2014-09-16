#
# Amadou Gaye - 13 September 2014
# This function processes two file prior to merging: it ensure the two files have only their overlapping SNPs
# included and aligns the alleles information using the alleles information of the first file.
# The arguments to the functions are the names of the input files, the path that indicates their location
# and the output of the ouptu files.
#
align <- function(file1, file2, indir, outdir){

  # load the .bim files of the datasets
  cat("   Loading .bim files\n")
  t1 <- read.table(paste0(indir,file1,".bim"), header=F, sep="\t")
  t2 <- read.table(paste0(indir,file2,".bim"), header=F, sep="\t")

  # merge the 2 files by and chromosome, rsname and position
  # I do not want rsnames with different chromosomal or physical position
  colnames(t1) <- c("chr", "name", "gd", "pos", "allele1", "allele2")
  colnames(t2) <- c("chr", "name", "gd", "pos", "allele1", "allele2")
  mergedtable <- as.matrix(merge(t1,t2,by=c("name","chr","pos")))
  
  # get the common rsnames and save it as a file
  argfile1 <- paste0(outdir, file1, "_", file2, ".arg.txt")
  write.table(mergedtable[,1], file=argfile1, quote=F, row.names=F, col.names=F)
  
  # generate a plink file from the second file which contains only the overlapping rsnames
  infile1 <- paste0(indir,file1)
  infile2 <- paste0(indir,file2)
  outfile1 <- paste0(outdir, file1)
  tempfile2 <- paste0(outdir, file2,"_temp")
  cat("   Generating the subset plink files with common markers only\n")
  system(paste0("p-link --silent --bfile ", infile1," --extract ",  argfile1, " --make-bed --out ", outfile1))
  system(paste0("p-link --silent --bfile ", infile2," --extract ",  argfile1, " --make-bed --out ", tempfile2))
  
  # now get the allele coding of the merged file and update the allele information in the 2nd dataset
  argfile2 <- paste0(outdir, file2,"_arg.txt")
  mm <- cbind(mergedtable[,1], mergedtable[,c(8,9)], mergedtable[,c(5,6)])
  
  # check for duplicated rsnames and keep only one, otherwise the aliging step will fail
  mm <- unique(mm)
  
  # now remove eventual duplicated rsname with differering allele coding (those will not be caught by the above 'unique' command)
  duprs <- as.character(mm[duplicated(mm[,1]),1])
  if(length(duprs) > 0){
    for(i in 1:length(duprs)){
       xx <- which(mm[,1] %in% duprs[i])
       mm <- mm[-xx[2:length(xx)],]
    }
  }
  write.table(mm, file=argfile2, quote=F, row.names=F, col.names=F, sep=" ")
  
  # align second dataset allele info to those of the first dataset
  outfile2 <- paste0(outdir,file2)
  cat("   Aligning the allele information\n")
  system(paste0("p-link --silent --bfile ", tempfile2," --update-alleles ",  argfile2, " --make-bed --out ", outfile2))
 
  # delete the temprorary file to spare space
  system(paste0("rm ", tempfile2, ".*"))

}
