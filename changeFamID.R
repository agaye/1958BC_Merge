#
# Amadou Gaye - 08 September 2014
# In this script I replace the family IDs by the dataset/chip name and keep the individuals
# as GIDs. This will ensure duplicates will not be merge when I merge the datasets.

# path to store output files storage
path1 = "/home/ag13748/1958BC/Merge.31.8.14/plink04";

files <- c("cng","metabochip","rahi","t1dgc","wtccc1_aff","wtccc1_inf","wtccc2_ill","wtccc1_15k","wtccc2_aff")

for(i in 1:length(files)){
   cat(files[i],"...\n")
   
   # path to input files
   if(files[i] == "metabochip" | files[i] == "wtccc2_aff"){
     path0 <- "/home/ag13748/1958BC/Merge.31.8.14/plink03/rsnames/"
   }else{
     path0 <- "/home/ag13748/1958BC/Merge.31.8.14/plink03/"
   }
   
   # load the .fam files and create the argument file used to change the family IDs
   infile0 <- paste0(path0,"/",files[i],".fam")
   t <- read.table(infile0, header=F, sep=" ")
   arg <- cbind(as.character(t[,1]), as.character(t[,2]), rep(files[i], dim(t)[1]), as.character(t[,2]))
   argfile <- paste0(path1,"/", files[i], "_argfile.txt")
   write.table(arg, file=argfile, quote=FALSE, row.names=FALSE, col.names=FALSE, sep=" ")
   
   # replace the family ID by the dataset name
   infile2 <- paste0(path0,"/",files[i])  
   outfile <- paste0(path1,"/",files[i]) 
   system(paste0("p-link --bfile ", infile2," --update-ids ",  argfile, " --make-bed --out ", outfile))   
}


