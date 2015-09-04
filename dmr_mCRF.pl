#!/usr/bin/perl -w
# This generates average CpG methylation percentage for each DMRs.
# June 25, 2013 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed file> <score bed file> STDOUT > bed file with score \n";

die $usage unless @ARGV;

my ($in_f, $data_f, ) = @ARGV;

my %CpG;
open DATA, $data_f or die "Cannot open $data_f.\n";
while (<DATA>) {
	chomp;
	my @line = split;
	$CpG{"$line[0]|$line[1]"} = $line[4];
}
close DATA;

open IN, $in_f or die "Cannot open $in_f.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my ($chr, $start, $end) = @line[0..2];
	my $base;
	my ($score, $cpg) = (0, 0);
	for (my $i = $start; $i < $end; $i++) {
		my $id = "$chr|$i";
		if (exists $CpG{$id}) {
			$score += $CpG{$id};
			$cpg++;
		}
	}
	if ($cpg == 0) { $score = 0 }
	else { $score /= $cpg }
	print "$chr\t$start\t$end\t$score\n";
}
close IN;

