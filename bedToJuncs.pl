#! /usr/bin/perl -w
# Author: Hyung Joo Lee

use strict;

my $usage = '
bedToJuncs.pl <bed file> <juncs file>
';

die $usage unless @ARGV;

my ( $in_f, $out_f ) = @ARGV;

open IN, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";

while (<IN>) {
	my @line = split;
	my $chrom = $line[0];
	my $strand = $line[5];
	my $blockCount = $line[9];
	my @blockSizes = split /,/, $line[10];
	my @blockStarts = split /,/, $line[11];
	for (my $i = 0; $i < $blockCount-1; $i++) {
		my $leftPos = $line[1] + $blockStarts[$i] + $blockSizes[$i] -1;
		my $rightPos = $line[1] + $blockStarts[$i+1];
		print OUT "$chrom\t$leftPos\t$rightPos\t$strand\n";
	}
}
exit;
