#
# Amadou Gaye - 17 September 2014
# This function counts the number of expected duplicates found, not found and unexpected within a dataset.
# It takes as arguments the 't', the file that contains the results of the plink IBD check, 'f' a file
# that holds the family and invidual GIDs and p the path to store output files
#
countwithin <- function (t, f, n, p){
  
  # path to store output files 
  system(paste0("mkdir ", paste0(path1, n, "_", n)))
  path <- paste0(path1, n, "_", n)
  
	# within a dataset attempt to count only if the there is indication of duplicates in the initial .fam file
	if(length(f[,3]) != length(unique(f[,3]))){
		 df <- as.matrix(t[which(t$FID1 == n & t$FID2==as.character(t$IID1)  & t$IID1==as.character(t$IID2) ), c(1,2,3,4)])
		 exdf <- df[,3]
		 dd <- f[duplicated(f[,3]),3]
		 exdnf <- dd[which(!(dd %in% df[,3]))]   
		 write.table(exdf, file=paste0(path, "/expectedfound.txt"), quote=F, row.names=F, col.names="GID")  
     write.table(exdnf, file=paste0(path, "/expectedNOTfound.txt"), quote=F, row.names=F, col.names="GID")		 
	}else{
		 exdf <- c()
		 exdnf <- c()
	}
  
  # unexpected duplicates
	uexdf <- t[which(t$FID1 == n & t$FID2== n & t$IID1 != as.character(t$IID2)), c(2,4)]	
	if(class(uexdf) == 'character'){ uexdf <- as.matrix(t(uexdf)) } # to prevent one row matrix going as vector
  write.table(uexdf, file=paste0(path, "/unexpected.txt"), quote=F, row.names=F, col.names=c("GID", "GID"), sep=";")
  if(length(c(uexdf[,1],uexdf[,2])) > 2*(dim(uexdf)[1])){
    # check if there are no inverted links: GIDXXX-GIDYYY in one row and GIDYYY-GIDXXX in another
    warning("   Some unexpected duplicates might have been counted twice!")
  }
  
	return(list(exdf, exdnf, uexdf))
}

