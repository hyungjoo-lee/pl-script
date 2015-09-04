#!/usr/bin/perl -w
# May 15, 2013
# Author: Hyung Joo Lee

use strict;
my $usage = "Usage: $0 <BisSeq bed file> <mCRF bed file> <output file base>\n";
die $usage unless @ARGV;

my ($bs_f, $mcrf_f, $name) = @ARGV;

my %cpg;
my $cpg = 0;
my @hist;
open CPG, $bs_f or die "Cannot open $bs_f file.\n";
while (<CPG>) {
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$cpg{$coord} = $line[4];
}
close CPG;

open IN, $mcrf_f or die "Cannot open $mcrf_f file.\n";
open OUT, ">$name.bed" or die "Cannot open $name.bed file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $coord = $line[0].":".$line[1];
	next unless (exists $cpg{$coord});
	$cpg++;
	my $diff = $cpg{$coord} - $line[4];
	print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$diff\n";
	$diff = sprintf "%d", 50*abs($diff);
	$hist[$diff]++;
}
close IN;
close OUT;

open OUT, ">$name.report" or die "Cannot open $name.report file.\n";
for (my $i = 0; $i < 50; $i++) {
	$hist[$i] = 0 if (!defined $hist[$i]);
	printf OUT "%.3f\t%.5f\n", ($i+0.5)/50, $hist[$i]/$cpg;
}
close OUT;
exit;
