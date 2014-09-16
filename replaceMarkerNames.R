# 
# Amadou Gaye - 04 September 2014
# This script takes the .bim files of the metabochip and wtcccc2_aff datasets and turn 
# the markersnames into their corresponding rsnames. This will facilitate further 
# steps such as looking for markers overlap by both rsname and position. It will also 
# help when merging the datasets.
#
# get a subset of the .bim files that holds the marker names and positions and load them
path0 <- "/home/ag13748/1958BC/Merge.31.8.14/plink03/"
path1 <- "/home/ag13748/1958BC/Merge.31.8.14/plink03/rsnames/"
files <- c("metabochip","wtccc2_aff")
size <- length(files)

# load the light version of the lookup file I downloaded from UCSC Genome Browser
rs37 <- read.table("/home/ag13748/1958BC/Merge.31.8.14/build37/build37_light.txt", header=T, sep="\t")
colnames(rs37) <- c("chrom","chromEnd","name")

for(i in 1:length(files)){
  # print name of file just to monitor progress
  cat(files[i],"...\n")
  
  # generate the subset file to load
  infile <- paste0(path0, files[i], ".bim")
  subfile <- paste0(path1, files[i], "_temp")
  system(paste0("cut -f1,2,4 ", infile, " > ",  subfile))
  
  # load the subset file
  t <- read.table(subfile, header=FALSE, sep='\t')
  colnames(t) <- c("chrom","name","chromEnd")
  t[,1] <- paste0("chr", t[,1])

  # merge the two files by position and generate a table where the chromosome and position match
  mpos <- as.matrix(merge(t,rs37,by="chromEnd"))
  mreal <- mpos[which(mpos[,2] == mpos[,4]),]
  
  # save the file that I am going to use as argument to replace marker IDs
  argfile <- mreal[,c(3,5)]
  argfilename <- paste0(path1, files[i], "_arg")
  write.table(argfile, file=argfilename, quote=F, row.names=F, col.names=F, sep=" ")
  
  # replace whatever marker IDs by rsnames 
  file0 <- paste0(path0, files[i])
  file1 <- paste0(path1, files[i])
  system(paste0("p-link --bfile ", file0, " --update-map ", argfilename, " --update-name --make-bed --out ", file1))

  # remove the subset file which is not reuqired anymore
  system(paste0("rm ", subfile))
}


