#!/usr/bin/perl

# development settings
use strict;
use warnings;

# Amadou Gaye - 01 September 2014
# This script replaces the initial IDs of the plink datasets by the corresponding 'universal'GIDs. 
# The link files, linking initial IDs to GIDs) were provided by Jon Johnson.
# I loop through the plink datasets where unwanted IDs were removed and run a plink command that get 
# that updates the family and individual IDs which are both set to the be GID.
#
# path to original plink files
my $path1 = "/home/ag13748/1958BC/Merge.31.8.14/plink01";

# path to plink argument files
my $path2 = "/home/ag13748/1958BC/Merge.31.8.14/plinkArgFiles/args4conversion";

# path to amended plink files
my $path3 = "/home/ag13748/1958BC/Merge.31.8.14/plink02";

# file names
my @files = ("cng","metabochip","rahi","t1dgc","wtccc1_aff","wtccc1_inf","wtccc2_aff","wtccc2_ill","wtccc1_15k");

for (my $i = 0; $i <= @files-1; $i++){
  # paths to the files required
  my $infile = "$path1/$files[$i]";
  my $argfile = "$path2/$files[$i].txt";
  my $outfile = "$path3/$files[$i]";
  
  # print input file name just to monitor progress
  print($files[$i],"\n");
  
  # run the plink command that replaces the intial IDs by GIDs
  `p-link --bfile $infile --update-ids $argfile --make-bed --out $outfile`;
}  

