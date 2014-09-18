#
# Amadou Gaye - 17 September 2014
# This function counts the number of expected duplicates found, not found and unexpected within a dataset.
# It takes as arguments the 't', the file that contains the results of the plink IBD check, 'f' a file
# that holds the family and invidual GIDs and p the path to store output files
#
countwithin <- function (t, f, n, p){
	# within a dataset attempt to count only if the there is indication of duplicates in the initial .fam file
	if(length(f[,3]) != length(unique(f[,3]))){
		 df <- as.matrix(t[which(t$FID1 == n & t$FID2==as.character(t$IID1)  & t$IID1==as.character(t$IID2) ), c(1,2,3,4)])
		 exdf <- df
		 dd <- f[duplicated(f[,3]),3]
		 exdnf <- dd[which(!(dd %in% df[,3]))]   
		 write.table(exdf, file=paste0(p, n, "_expectedfound.txt"), quote=F, row.names=F, col.names="GID")  
     write.table(exdnf, file=paste0(p, n, "_expectedNOTfound.txt"), quote=F, row.names=F, col.names="GID")		 
	}else{
		 exdf <- c()
		 exdnf <- c()
	}
	uexdf <- t[which(t$FID1 == n & t$FID2== n & t$IID1 != as.character(t$IID2)), c(2,4)]	
	if(length(c(uexdf[,1],uexdf[,2])) > 2*(dim(uexdf)[1])){
	  # check if there are no inverted links: GIDXXX-GIDYYY in one row and GIDYYY-GIDXXX in another
		warning("   Some unexpected duplicates might have been counted twice!")
  }
  if(dim(uexdf)[1] > 0){
    write.table(uexdf, file=paste0(p, n,"_unexpected.txt"), quote=F, row.names=F, col.names=c("GID", "GID"), sep=";")
  }
  
	return(list(exdf, exdnf, uexdf))
}

