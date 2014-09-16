#
# Amadou Gaye - 04 September 2014
# This script produces a summary tables with counts of overlaping markers between the
# PLINKed datasets. The script generates, from the .bim file, a file that contains the 
# chromosome number, the snp name and the position. These files are loaded and stored in 
# a list. I then loop through that list and merge the tables two by two to find matching, 
# chromosomes and positions (i.e. if both files hold the same position at the same
# same chromosome, I consider that as an overlapping position. The rational for using SNP 
# positions for marker overlap count and not SNP names is because more than one rs name 
# can match one position due the way the genome was assembled; those different names are then 
# 'merged' to the shorter rs name but in our files all the rsnames might be present and not just 
# the 'merged' name. For the same reason after merging the files by positions some position might 
# be found more than once so I count each position only once to not incorretly inflate the number 
# of overlapping markers. Whilst counting number of overlapping positions, I also save the rsnames 
# corresponding to those positions to use them later when merging datasets (as I use only overlapping 
# SNPs when merging). 
#
# file names
files <- c("cng","metabochip","rahi","t1dgc","wtccc1_aff","wtccc1_inf","wtccc2_ill","wtccc1_15k","wtccc2_aff")
size <- length(files)

# a list to store the tables to compare
mylist <- vector('list', length(files))
names(mylist) <- files

cat("Generating and uploading the required files\n")
for(i in 1:length(files)){
  # print name of file just to monitor progress
  cat(files[i],"...\n")
  
  # use the plink files with rsnames for metabochip and wtccc2_aff
  if(files[i] == "metabochip" | files[i] == "wtccc2_aff"){
    path <- "/home/ag13748/1958BC/Merge.31.8.14/plink03/rsnames/"
  }else{
    path <- "/home/ag13748/1958BC/Merge.31.8.14/plink03/"
  }
  
  # generate the subset file to load
  infile <- paste0(path, files[i], ".bim")
  subfile <- paste0(path, files[i], "_temp")
  system(paste0("cut -f1,2,4 ", infile, " > ",  subfile))
  
  # load the subset file
  t <- read.table(subfile, header=FALSE, sep='\t')
  t[,1] <- paste0("chr", t[,1])
  
  mylist[[i]] <- t 
  
  # remove the subset file which is not required anymore
  system(paste0("rm ", subfile))
}

cat("\nGenerating the overlap counts table\n")
# count overlaping markers, by comparing their positions, and store numbers in a matrix. 
counts <- matrix(data=NA, nrow=size, ncol=size, dimnames=list(files,files))
for(i in 1:(size)){
  if(i == size){ break }
  for(j in (i+1):size){
    cat(files[i],"-", files[j], "...\n")
    chrtable1 <- mylist[[i]]
    chrtable2 <- mylist[[j]]
    colnames(chrtable1) <- c("chr", "name", "position")
    colnames(chrtable2) <- c("chr", "name", "position")
    
    # merge by position
    mergedtable <- as.matrix(merge(chrtable1,chrtable2,by="position"))
    
    # get a table of markers that match by position and chromosome
    mpos <- mergedtable[which(mergedtable[,2] == mergedtable[,4]),]

    # remove duplicated rows 
    mreal <- unique(mpos)
        
    # store the number of overlapping markers (i.e. the number of rows in the above table)
    counts[i,j] <- dim(mreal)[1]
    
    # save the names of the overlaping SNPs to use later when merging files
    path2argfiles <- "/home/ag13748/1958BC/Merge.31.8.14/plinkArgFiles/arg4checkdups/"
    filename <- paste0(path2argfiles, "/", paste0(files[i], "_", files[j], ".txt")) 
    write.table(mreal[,c(3,5)], file=filename, quote=FALSE, row.names=FALSE, col.names=c(files[i],files[j]))
  }
}
# the count in the diagonal are irrelevant
diag(counts) <- NA

# store the matrix of counts
filename <- "/home/ag13748/1958BC/Merge.31.8.14/overlaps/markersOverlapCount.csv"
write.table(counts, file=filename, quote=FALSE, row.names=TRUE, col.names=TRUE, sep=',')



