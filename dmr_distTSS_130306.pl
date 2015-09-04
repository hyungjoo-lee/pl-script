#!/usr/bin/perl -w
# This scripts generates DMR distribution of distance from TSS.
# Author: Hyung Joo Lee


use strict;

die "Usage: perl $0 <DMR dist TSS bed file> <DMR distribution data file> \n" unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my @cnt;
my $max = 0;

open IN, "$in_f" or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	$max = $line[4] if ($max < $line[4]);
	my $bin = sprintf "%d", ($line[4] / 500);
	$bin = -2000 if ($bin < -2000);
	$bin = 2000 if ($bin > 2000);
	$cnt[$bin+2000]++;
}
close IN;

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
for (my $i = 0; $i < 4000; $i++) {
	$cnt[$i] = 0 unless ( defined $cnt[$i]);
	my $distance = ($i-2000) * 500;
	print OUT "$distance\t$cnt[$i]\n";
}
close OUT;
print "max is $max\n";
exit;
