#!/usr/bin/perl -w
# This excerpts given DMR data from selected DMR bed file. 
# June 17, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "perl $0 <subset ensGene list file> <ensGene info file>  STDOUT > ensGene list + info \n";

die $usage unless @ARGV;

my ($sub_f, $data_f) = @ARGV;

my %sub;
open IN, $sub_f or die "Cannot open $sub_f file.\n";
while (<IN>) {
	chomp;
	$sub{$_} = 1;
}
close IN;

open IN, $data_f or die "Cannot open $data_f file.\n";
my $cnt = 0;
while (<IN>) {
	my @line = split;
	print if exists $sub{$line[3]};
}
close IN;
exit;
