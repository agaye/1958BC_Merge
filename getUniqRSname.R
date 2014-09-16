
# Amadou Gaye - 04 September 2014
# A script to strip out merged names in the genome build 37 table.
# I first identify all positions where there are two rsnames and 
# keep the shorter rsname (i.e. delete the longer name) according 
# to explanation by G. Abecasis group: "when different rs number are 
# found to refer to the same SNP, then higher rs number will be merged 
# to lower rs number". This will be kind of my lookup file if to decide
# for what rsname to keep if to rsnames match the same physical position.
#
# load the table with both rs names
rs37 <- read.table("/home/ag13748/1958BC/Merge.31.8.14/build37/build37", header=F, sep="\t")

# identify positions where there are 2 rs names
xx <- rs37[,c(1,2)]
ss <- xx[duplicated(xx),2]
idx <- which(rs37[,2] %in% ss)

# remove the duplicated rows
uniqrs37 <- rs37[-idx,]
filename1 <- "/home/ag13748/1958BC/Merge.31.8.14/build37/uniqrs37pos.txt"
write.table(uniqrs37, file=filename1, quote=F, row.names=F, col.names=F, sep="\t")

# now generate the table which contains the duplicated positions but with the 'merged' rsname 
zz <- as.character(rs37[,3])
aa <- strsplit(zz, split='rs')
col <- as.numeric(sapply(aa, "[[", 2))
temp1 <- cbind(rs37, col)
temp2 <- temp1[order(temp1[,4]), ]  
filename2 <- "/home/ag13748/1958BC/Merge.31.8.14/build37/temp1.txt"
write.table(temp2[,c(1,2,3)], file=filename2, quote=FALSE, row.names=FALSE, col.names=F, sep="\t")

# loop through the positions and delete rows with the longer rsnames, i.e. keeping the short rsname
filename3 <- "/home/ag13748/1958BC/Merge.31.8.14/build37/temp2.txt"
for(i in 1:length(ss)){
  system(paste0("grep -w -m 1 ", ss[i], " ", filename2, " >> ", filename3)) 
  cat(i, " of ", length(ss), "\n")  
}

# now load the file 'temp2.txt', remove any eventual duplicates and save the file with unique rows
a <- read.table(filename3, header=FALSE, sep="\t")
prefinal <- unique(a)

# verify and save
length(prefinal[duplicated(prefinal[,2]),2])
length(prefinal[duplicated(prefinal[,3]),2])
filename4 <- "/home/ag13748/1958BC/Merge.31.8.14/build37/mergedrsnames.txt"
write.table(prefinal, file=filename4, quote=FALSE, row.names=FALSE, col.names=FALSE, sep="\t")

# now concatenate the file 'uniqrs37pos.txt' and the file 'mergedrsnames.txt' to obtain a file 
# where each position matches only one rsname. In the file 'build37.txt' some positions have 
# more than one rsnames; in our final file the only rsname('merged' rsname) is kept
finalfile <- "/home/ag13748/1958BC/Merge.31.8.14/build37/build37_light.txt"
system(paste0("cat ", filename1, " ", filename4, " > ", finalfile)) 

