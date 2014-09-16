#!/usr/bin/perl

# development settings
use strict;
use warnings;

# Amadou Gaye - 01 September 2014
# This script removes samples that were mentioned as genotyped but were missing.
# Details about these samples are in J. Johnson's email of the 21 March 2012. 
# A copy of this exchange with Neil Walker is stored under the name 'aboutRemovedIDs.txt'
# I loop through the names of the plink files concerned and run a command to remove the samples
# using the arguments stored in the directory '/plinkArgFiles/args4removal'. The original plink 
# files are in directory 'plinks00' and the output files are in the directory 'plink01'. 
# The datasets not concerned by this change are just copied to 'plink01'.

# path to original plink files
my $path1 = "/home/ag13748/1958BC/Merge.31.8.14/plink00";

# path to plink argument files
my $path2 = "/home/ag13748/1958BC/Merge.31.8.14/plinkArgFiles/args4removal";

# path to amended plink files
my $path3 = "/home/ag13748/1958BC/Merge.31.8.14/plink01";

# file names
my @files = ("metabochip","t1dgc","wtccc1_inf","wtccc2_ill");

# loop and remove unwanted files
for (my $i = 0; $i <= @files-1; $i++){
  # paths to the files required
	my $infile = "$path1/$files[$i]";
	my $argfile = "$path2/$files[$i].txt";
	my $outfile = "$path3/$files[$i]";
	
	# print input file name just to monitor progress
  print($files[$i],"\n");
  
  # run the plink command that removes the unwanted entries
	`p-link --bfile $infile --remove $argfile --make-bed --out $outfile`;
}




