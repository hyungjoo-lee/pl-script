#!/usr/bin/perl -w
use strict;

die "Usage:perl $0 <10kb rpkm file> <output average rpkm file>\n" unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my @avg;
my $cnt;

open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
	my @line = split;
	for (my $i = 0; $i < @line; $i++) {
		$avg[$i] += $line[$i];
	}
	$cnt++;
}
close IN;

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
for (my $i = 0; $i < @avg; $i++) {
	$avg[$i] /= $cnt;
	print OUT "$avg[$i]\n";
}	
close OUT;
exit;
