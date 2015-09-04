#!/usr/bin/perl -w
# July 14, 2014
# Author: Hyung Joo Lee

use strict;
my $usage = "Usage: $0 <mCRF difference txt file> STDOUT> discodance region list \n";
die $usage unless @ARGV;

my ($in_f, ) = @ARGV;

my $prev_chr = "chr1";
my $prev_coord = 0;
my $sum_diff = 0;
my $cpg_cnt = 0;
my $end_coord;

open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $cur_chr = $line[0];
	my $cur_coord = $line[1];
	my $diff = $line[6];
	if (($cur_chr ne $prev_chr) || ($diff < 0.25 )) {
		my $mean_diff = $sum_diff / $cpg_cnt unless ($cpg_cnt ==0);
		if (($cpg_cnt >= 5) && ($mean_diff >= 0.25)) {
			my $length = $end_coord-$prev_coord;
			my $density = $cpg_cnt / $length * 100;
			print "$cur_chr\t$prev_coord\t$end_coord\t$length\t$cpg_cnt\t";
			printf "%.2f\t%.5f\n", $density, $mean_diff;
		}
		$sum_diff = 0;
		$cpg_cnt = 0;
		$prev_chr = $cur_chr;
	} else {
		$prev_coord = $cur_coord if ($cpg_cnt == 0);
		$end_coord = $line[2];
		$sum_diff += $diff;
		$cpg_cnt++;
	}
}
close IN;
exit;
