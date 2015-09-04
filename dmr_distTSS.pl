#!/usr/bin/perl -w
# This scripts generates DMR distribution of distance from TSS.
# Author: Hyung Joo Lee
# Edited on June 11, 2013

use strict;

die "Usage: perl $0 <DMR dist TSS bed file> <DMR distribution data file> \n" unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my @cnt;
my @c;
#@c = ( -100000, -50000, -10000, -5000, -2000, -1000, 0, 1000, 2000, 5000, 10000, 50000, 100000);
for (my $i = 0; $i <= 400; $i ++) {
	$c[$i] = ($i-200) * 5000;
}

open IN, "$in_f" or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	if ($line[3] < $c[0]) {
		$cnt[0]++;
		next;
	}
	for (my $i = 0; $i < @c-1; $i++) {
		if ( ($line[3] >= $c[$i]) && ($line[3] < $c[$i+1]) ) {
			$cnt[$i+1]++;
			last;
		}
	}
	if ($line[3] > $c[@c-1]) {
		$cnt[@c]++;
	}
}
close IN;

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
print OUT "<$c[0]\t$cnt[0]\n";
for (my $i = 1; $i < @c; $i++) {
	$cnt[$i] = 0 unless ( defined $cnt[$i]);
	print OUT "$c[$i-1]-$c[$i]\t$cnt[$i]\n";
}
print OUT ">$c[@c-1]\t$cnt[@cnt-1]\n";
close OUT;
exit;
