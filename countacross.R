#
# Amadou Gaye - 17 September 2014
# This function counts the number of expected duplicates found, not found and unexpected across two datasets.
# It takes as arguments the 't', the file that contains the results of the plink IBD check, 'f1' and 'f2' the
# files that holds respectively the family and invidual GIDs in the two datasets and 'n1' and 'n2' the names
# of respectively the first and second dataset
#
countacross <- function (t, f1, f2, n1, n2){

	# get all GID in the 1st dataset that are present in the 2nd dataset
	# these are the total of duplicates between the two files 
	df <- as.matrix(t[which(t$FID1 == n1 & t$FID2== n2), c(1,2,3,4)])

	# expected duplicates found (i.e. have the same GID and were hence expected to be duplicates)
  exdf <- unique(df[which(df[,2] == df[,4]),c(2,4)])

	# expected duplicates not found
	intrsct <- unique(intersect(f1[,3], f2[,3]))
	exdnf <- intrsct[which(!(intrsct %in% exdf[,1]))]
		  
  # unexpected duplicates
	uexdf <- unique(df[which(df[,2] != df[,4]),c(2,4)])
  if(class(uexdf) == 'character'){ uexdf <- as.matrix(t(uexdf)) } # to prevent one row matrix going as vector
  if(length(c(uexdf[,1],uexdf[,2])) > 2*(dim(uexdf)[1])){
  	# check if there are no inverted links: GIDXXX-GIDYYY in one row and GIDYYY-GIDXXX in another
  	warning("   Some unexpected duplicates might have been counted twice!")
  }
  
	return(list(exdf, exdnf, uexdf))
}
