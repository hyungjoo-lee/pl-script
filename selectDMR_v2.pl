#!/usr/bin/perl -w
# This excerpts given DMR data from selected DMR bed file. 
# June 5, 2013
# Author: Hyung Joo Lee

# example:
# awk '{OFS="\t"; if ($5==1) {print}}' | selectDMR.pl - DMR_5kb_phastCons.data > DMR_subset_5kb_phastCons.data

use strict;

my $usage = "perl $0 <subset DMR bed files> <DMRs data file>  > STOUT selected data file\n";

die $usage unless @ARGV;

my ($sub_f, $data_f) = @ARGV;

my %sub;
open IN, $sub_f or die "Cannot open $sub_f file.\n";
while (<IN>) {
	my @line = split;
	$sub{$line[3]} = 1;
}
close IN;

open IN, $data_f or die "Cannot open $data_f file.\n";
my $cnt = 0;
while (<IN>) {
	my @line = split;
	print if exists $sub{$line[0]};
}
close IN;
exit;
