#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# This excerpts given DMR data from selected DMR bed file. 

use strict;

my $usage = '
selectBins.pl $FILE.BED_DMRs $FILE.DMRs_data >STOUT selected data

';

die $usage unless @ARGV;

my ($bed_f, $data_f) = @ARGV;

my %bin;
open BIN, $bed_f or die "Cannot open $bed_f file.\n";
while (<BIN>) {
  my @line = split "\t";
  $bin{"$line[0]:$line[1]"} = 1;
}
close BIN;

open DATA, $data_f or die "Cannot open $data_f file.\n";
while (<DATA>) {
  my @line = split "\t";
  print if exists $bin{"$line[0]:$line[1]"};
}
close DATA;
exit;
