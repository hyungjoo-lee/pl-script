#!/usr/bin/perl -w
# This generates average CpG methylation percentage over certain coordinates (DMRs).
# June 13, 2013 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed file> <score bed file> <sample point number> STDOUT > average score file\n";

die $usage unless @ARGV;

my ($in_f, $data_f, $sp) = @ARGV;

my %CpG;
open DATA, $data_f or die "Cannot open $data_f.\n";
while (<DATA>) {
	chomp;
	my @line = split;
	$CpG{"$line[0]|$line[1]"} = $line[4];
}
close DATA;

# number of sample points
# my $sp = 30;

my @score = ();
my @cnt_line = ();
for (my $i = 0; $i < $sp; $i++) { $score[$i] = 0; $cnt_line[$i] = 0 }
open IN, $in_f or die "Cannot open $in_f.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $strand = $line[5];
	my $length = $line[2]-$line[1];
	my $inc = $length / $sp;
	my @score_line = ();
	for (my $i = 0; $i < $sp; $i++) { $score_line[$i] = 0 }
	my $base = 0;
	for (my $i = 0; $i < $sp; $i++) {
		my ($score, $cpg) = ( 0, 0 );
		my $j;
		for ($j = 0; $j < $inc ; $j++) {
			my $coord = $line[1] + $base + $j;
			my $id = "$line[0]|$coord";
			if (exists $CpG{$id}) {
				$score += $CpG{$id};
				$cpg++;
			}
		}
		$base += $j;
		$base-- if ($inc < 1 && $base > $inc*($i+1));
		if ($cpg != 0) {
			$score /= $cpg;
			if ($strand eq "+") {
				$score_line[$i] = $score;
				$cnt_line[$i]++;
			} else {
				$score_line[$sp-$i-1] = $score;
				$cnt_line[$sp-$i-1]++;
			}
		}
	}
	for (my $i = 0; $i < $sp; $i++) { $score[$i]+= $score_line[$i] }
}
close IN;

for (my $i=0; $i<$sp; $i++) {
	my $avg = $score[$i] / $cnt_line[$i];
	print "$avg\n";
}
exit;
