#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# June 13, 2013

use strict;

my $usage = "Usage: perl $0 <ensGene file> STDOUT > exon intron bed format";
die $usage unless @ARGV;

my ($in_f, ) = @ARGV;

open GENE, $in_f or die "Cannot open $in_f file.\n";
while (<GENE>) {
	chomp;
	my @line = split;
	my ($chr, $strand, $exonCount) = ( $line[2], $line[3], $line[8]);
	my @exonStarts = split ",", $line[9];
	my @exonEnds = split ",", $line[10];
	for (my $i = 0; $i < $exonCount; $i++) {
		print "$chr\t$exonStarts[$i]\t$exonEnds[$i]\texon\t0\t$strand\n";
		print "$chr\t$exonEnds[$i]\t$exonStarts[$i+1]\tintron\t0\t$strand\n" unless ($i==$exonCount-1);
	}
}
close GENE;
exit;
