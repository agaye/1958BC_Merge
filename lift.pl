#!/usr/bin/perl

# development settings
use strict;
use warnings;

# Amadou Gaye - 03 September 2014
# This script carries out a lift over (i.e. converting genome position from one genome assembly 
# to another genome assembly) from genome build 35 to 37 for the datasets on genome
# build 35 (wtccc1_15k, wtccc1_aff and wtccc1_inf) and from genome build 36 to 37 for the 
# the other 6 files. It uses the .map and .ped plink format to generate the .bed format required
# by the binary 'liftOver' tool of UCSC called within G. Abecasis group script 'LiftMap.py' which 
# I modified slightly to fit the purposes here. Once the lift over is completed for all the files 
# I re-create the binary plink formt files and store them in the directory 'plink03'.


# path to the files to convert to map format  
my $path0 = "/home/ag13748/1958BC/Merge.31.8.14/plink02";

# path to BED format files
my $path1 = "/home/ag13748/1958BC/Merge.31.8.14/plink03/mapFormat";

# path to genome build 36 files
my $path2 = "/home/ag13748/1958BC/Merge.31.8.14/plink03/build37";

# path to lift over tools 
my $path3 = "/home/ag13748/1958BC/Merge.31.8.14/liftTools";

# path to final files (genome build 37)
my $path4 = "/home/ag13748/1958BC/Merge.31.8.14/plink03";

# file names
my @build35files = ("wtccc1_15k","wtccc1_aff","wtccc1_inf");
my @build36files= ("cng","metabochip","rahi","t1dgc","wtccc2_aff","wtccc2_ill")

# paths to liftover tools
my $lift35to36 = "$path3/liftMap_35to36.py";
my $lift36to37 = "$path3/liftMap_36to37.py";

# get the right format and lift over wtccc1_15k, wtccc1_aff and wtccc1_inf to build 36 and then to build 37
for (my $i = 0; $i <= @build35files-1; $i++){
  print($build35files[$i],"\n");
  my $infile = "$path1/$build35files[$i]";
  my $outfile1 = "$path2/$build35files[$i]_36";
  my $outfile2 = "$path2/$build35files[$i]";
  my $outfile3 = "$path4/$build35files[$i]";
  my $unlifted1 = "$path2/unlifted35to36_$build35files[$i].txt";
  my $unlifted2 = "$path2/unlifted36to37_$build35files[$i].txt";
  
  # lift to 36 and then to 37
  `python $lift35to36 -m $infile.map -p $infile.ped -o  $outfile1`;
  `python $lift36to37 -m $outfile1.map -p $outfile1.ped -o  $outfile2`;
  
  # generate the binary plink (i.e. .bed, .bim, .fam) from the build 37 map and ped files
  `p-link --file $outfile2 --make-bed --out $outfile3`;
  
  # delete the files not required any more (just to free up space)
  `rm $path1/*.map.bed`;
  `rm $path2/*.bed`;
  `rm $path2/*.map`;
  `rm $path2/*.ped`;  
}

# get the right format and lift over the remaining files to build 37
for (my $i = 0; $i <= @build36files-1; $i++){
  print($build36files[$i],"\n");
  my $file0 = "$path0/$build36files[$i]";
  my $infile = "$path1/$build36files[$i]";
  my $outfile1 = "$path2/$build36files[$i]";
  my $unlifted = "$path2/unlifted36to37_$build36files[$i].txt";
  my $outfile2 = "$path4/$build36files[$i]";
  
  # convert to map/ped format
  `p-link --bfile $file0 --recode --out $infile`;
  
  # lift to genome buildd 37
  `python $lift36to37 -m $infile.map -p $infile.ped -o  $outfile1`;
  
  # delete the files not required anymore (not part of the code - just to free out space)  
  `rm $infile.map.bed`;
  `rm $infile.map`;  
  `rm $infile.ped`; 
  
  # generate the binary plink (i.e. .bed, .bim, .fam) from the build 37 map and ped files
  `p-link --file $outfile1 --make-bed --out $outfile2`;
  
  # delete the files not required anymore (not part of the code - just to free out space)
  `rm $outfile1.bed`;
  `rm $outfile1.map`;
  `rm $outfile1.ped`; 
}


