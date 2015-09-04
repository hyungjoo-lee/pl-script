#!/usr/bin/perl -w
# This generates average CpG methylation percentage over certain coordinates (DMRs).
# May 15, 2013 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed file> <score bed file> <out average score file>\n";

die $usage unless @ARGV;

my ($in_f, $data_f, $avg_f) = @ARGV;

my %CpG;
open DATA, $data_f or die "Cannot open $data_f.\n";
while (<DATA>) {
	chomp;
	my @line = split;
	$CpG{"$line[0]|$line[1]"} = $line[4];
}
close DATA;

my @score = ();
my @cnt_line = ();
for (my $i = 0; $i < 110; $i++) { $score[$i] = 0; $cnt_line[$i] = 0 }
open IN, $in_f or die "Cannot open $in_f.\n";
#open OUT, ">$out_f" or die "Cannot open $out_f.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $strand = $line[5];
	my @score_line = ();
	for (my $i = 0; $i < 110; $i++) { $score_line[$i] = 0 }
	for (my $i = 0; $i < 110; $i++) {
		my ($score, $cpg) = ( 0, 0 );
		for (my $j = 0; $j < 100; $j++) {
			my $coord = $line[1] + ($i * 100) + $j;
			$coord  = "$line[0]|$coord";
			if (exists $CpG{$coord}) {
				$score += $CpG{$coord};
				$cpg++;
			}
		}
		if ($cpg != 0) {
			$score /= $cpg;
			if ($strand eq "+") {
				$score_line[$i] = $score;
				$cnt_line[$i]++;
			} else {
				$score_line[109-$i] = $score;
				$cnt_line[109-$i]++;
			}
		}
	}
#	print OUT join ("\t", @score_line), "\n";
	for (my $i = 0; $i < 110; $i++) { $score[$i]+= $score_line[$i] }
}
close IN;
#close OUT;

open OUT, ">$avg_f" or die "Cannot oepn $avg_f.\n";
for (my $i=0; $i<110; $i++) {
	my $avg = $score[$i] / $cnt_line[$i];
	print OUT "$avg\n";
}
exit;
