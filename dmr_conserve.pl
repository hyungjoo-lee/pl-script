#!/usr/bin/perl -w
# This merges conserved elements overlapping bed files into one bed file. 
# June 4, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "perl $0 <conserved bed files> <DMRs all file>  > STOUT merge bed file\n";

die $usage unless @ARGV;

my ($con_f, $dmr_f) = @ARGV;

my %conserve;
open IN, $con_f or die "Cannot open $con_f file.\n";
while (<IN>) {
	my @line = split;
	$conserve{$line[3]} = 1;
}
close IN;

open IN, $dmr_f or die "Cannot open $dmr_f file.\n";
my $cnt = 1;
while (<IN>) {
	chomp;
	my @line = split;
	print;
	my $val = (exists $conserve{$line[3]})? 1:0;
	print "\t$val\n";
}
close IN;
exit;
