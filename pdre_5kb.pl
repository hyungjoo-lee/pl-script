#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <MnM DMR bed file> <new coordinate bed file (+5kb)> \n" unless @ARGV;

my ($in_f, $out_f) = @ARGV;

open IN, "$in_f" or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
my $cnt = 0;
while (<IN>) {
	chomp;
	$cnt++;
	my @line = split;
	my ($chr, $start, $end) = @line;
	my $mid = int (($start + $end) / 2);
	$start = $mid - 5000;
	$end = $mid + 5000;
	print OUT "$chr\t$start\t$end\t$cnt\t0\t+\n";
}
close IN;
close OUT;
exit;
