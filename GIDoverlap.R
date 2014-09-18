# 
# Amadou Gaye - 02 September 2014
# This script produces a summary table with counts of overlaping GIDs between the
# PLINked datasets and a large table that list the GIDs and their corresponding 
# initial ID in each of the original PLINKed dataset. The script uses the link files
# that link the IDs in the original 1958BC PLINKed files to the GIDs.

# load the link files and store them in a list
path <- "/home/ag13748/1958BC/Merge.31.8.14/plinkArgFiles/args4conversion/"
files <- c("cng","metabochip","rahi","t1dgc","wtccc1_aff","wtccc1_inf","wtccc2_aff","wtccc2_ill","wtccc1_15k")
size <- length(files)
mylist <- vector("list", size)
for(i in 1:size){
  mylist[[i]] <- read.table(paste0(path,files[i],".txt"), header=F, sep=' ')
}
names(mylist) <- files

# count overlaping GIDs and store numbers in a matrix
# only unique GID overlap are counted so the count is not necessary equal to the number of rows
counts <- matrix(data=NA, nrow=size, ncol=size, dimnames=list(files,files))
allGIDs <- c()
for(i in 1:size){
  cat(files[i],"\n")
  for(j in 1:size){
    t1 <- mylist[[i]]
    t2 <- mylist[[j]]
    if(i == j){ 
      counts[i,j] <- length (t2[,3]) - length(unique(t2[,3]))
    }else{
      x <- length(intersect(t1[,3],t2[,3]))
      counts[i,j] <- x 
    }
  }
  allGIDs <- append(allGIDs, as.character(mylist[[i]][,3]))
}

# store the matrix of counts
path2store <- "/home/ag13748/1958BC/Merge.31.8.14/overlaps/GIDoverlapCount.csv"
write.table(counts, file=path2store, quote=FALSE, row.names=TRUE, col.names=TRUE, sep=',')

# get the names of duplicated GIDs (GIDs that exist more than once within one dataset or across all datasets)
dups <- sort(unique(allGIDs[duplicated(allGIDs)]))
path2store <- "/home/ag13748/1958BC/Merge.31.8.14/overlaps/duplicatedGIDs.csv"
write.table(dups, file=path2store, quote=FALSE, row.names=FALSE, col.names=FALSE)

# get the names of non-duplicated GIDs by removing all duplicated ones from the whole list of GIDs
nondups <- allGIDs[-which(allGIDs %in% dups)]
path2store <- "/home/ag13748/1958BC/Merge.31.8.14/overlaps/nonduplicatedGIDs.csv"
write.table(nondups, file=path2store, quote=FALSE, row.names=FALSE, col.names=FALSE)

# make a table that lists the IDs that corresponds to each GID in each dataset
uniqueGIDs <- sort(unique(allGIDs))
linkmatrix <- matrix(data=NA, nrow=length(uniqueGIDs), ncol=size+1, dimnames=list(NULL,c("GID",files)))
linkmatrix[,1] <- uniqueGIDs
for(i in 1:length(uniqueGIDs)){
   cat(i," of 7361\n")
   for(j in 2:10){
     r <- as.character(mylist[[j-1]][,2])
     s <- as.character(mylist[[j-1]][,3])
     x <- which(s == linkmatrix[i,1])
     if(length(x) > 0){
       linkmatrix[i,j] <- paste(r[x], collapse=', ')
     }else{
      linkmatrix[i,j] <- '---'
     }
   }
}

# store the matrix that links GIDs to initial IDs in all 9 datasets
path2store <- "/home/ag13748/1958BC/Merge.31.8.14/overlaps/GID2ID.csv"
write.table(linkmatrix, file=path2store, quote=FALSE, row.names=FALSE, col.names=TRUE, sep=';')
