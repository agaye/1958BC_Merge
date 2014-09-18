#
# Amadou Gaye - 17 September 2014
# This script summarizes the results of the plink IBD checks. It counts and records the names of GIDs that 
# were expected to be duplicates (i.e. those GIDs that wre present two or more times in within or across
# datasets) and found as so, the GIDs expected to be found as duplicates but not found and the unexpected 
# duplicates (i.e. where two different GID have an IBD proportion > 0.9. 
#
# names of the plink datasets
files <- c("cng","metabochip","rahi","t1dgc","wtccc1_aff","wtccc1_inf","wtccc2_ill","wtccc1_15k","wtccc2_aff")
size <- length(files)

# path to input files
path0 = "/home/ag13748/1958BC/Merge.31.8.14/checksResults/"

# path to output files
path1 = "/home/ag13748/1958BC/Merge.31.8.14/summaries/"

# load the functions required 
source("/home/ag13748/1958BC/Merge.31.8.14/scripts/countwithin.R")
source("/home/ag13748/1958BC/Merge.31.8.14/scripts/countacross.R")

# count expected duplicates found, expected duplicates not found and unexpected duplicates found
# the 1st matrix hold the counts of expected found and not found and the 2nd the counts of unexpected
count1 <- matrix(data=NA, nrow=size, ncol=size, dimnames=list(files,files))
count2 <- matrix(data=NA, nrow=size, ncol=size, dimnames=list(files,files))

for(i in 1:1){#(size-1)){
  if(i == size){ break }
  for(j in (i+1):size){
    # print file names to monitor progress
    cat(files[i],"-", files[j], "...\n")
    
    # load input file
    infile <- paste0(path0,files[i], "_", files[j])
    t <- read.table(paste0(infile,".genome"), header=T)
    
    # get the overlapping GID names between the two dataset using the link files 
    path <- "/home/ag13748/1958BC/Merge.31.8.14/plinkArgFiles/args4conversion/"
    f1 <- read.table(paste0(path,files[i], ".txt"))
    f2 <- read.table(paste0(path,files[j], ".txt"))
    
    # output file
    system(paste0("mkdir ", paste0(path1, files[i], "_", files[j])))
    outpath <- paste0(path1, files[i], "_", files[j],"/")
    
    # get counts depending on if I am counting duplicates within a dataset or across datasets
    if(j < 3){
      out1 <- countwithin(t, f1, files[i], outpath)
      count1[i,j-1] <- paste0(as.character(length(out1[[1]])), "-", length(out1[[2]]))   
      count2[i,j-1] <- dim(out1[[3]])[1]
    }
    out2 <- countacross(t, f1, f2, files[i], files[j])
    
    # save the GIDs in each of the categories (found, not found and unexpected
    write.table(out2[[1]][,1], file=paste0(outpath,"expectedfound.txt"), quote=F, row.names=F, col.names="GID")  
    write.table(out2[[2]], file=paste0(outpath,"expectedNOTfound.txt"), quote=F, row.names=F, col.names="GID")
    write.table(out2[[3]], file=paste0(outpath,"unexpected.txt"), quote=F, row.names=F, col.names=c(files[i], files[j]), sep=";")  
    
    # store the counts of expected found, not found in the cell in the 1st count matrix
    count1[i,j] <- paste0(as.character(dim(out2[[1]])[1]), " [", length(out2[[2]]),"]")
    
    # store the counts of unexpected duplicates in the 2nd matrix
    count2[i,j] <- dim(out2[[3]])[1]
  }
}

# save the count tables
write.table(count1, file=paste0(path1,"countsofexpected.csv"), quote=FALSE, row.names=TRUE, col.names=TRUE, sep=';')
write.table(count2, file=paste0(path1,"countsofUNexpected.csv"), quote=FALSE, row.names=TRUE, col.names=TRUE, sep=';')
