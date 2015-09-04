#!/usr/bin/perl -w
# This script generates bed file from refGene.txt file
# Author: Hyung Joo Lee
# June 20, 2012

use strict;

my $usage = "Usage: perl $0 <refGene.txt>\n";
die $usage unless @ARGV;

my ($in_f) = @ARGV;
my $tmp_f = "tmp.$$";

open GENE, $in_f or die "Cannot open refFlat.txt.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f.\n";
while (<GENE>) {
	next if /^WITHDRAWN/;
	chomp;
	my @line = split;
	my ($chrom, $txStart, $txEnd, $name, $name2, $exonCount ) = ($line[2], $line[4], $line[5], $line[1], $line[12], $line[8]);
	my @exonStarts = split ",", $line[9];
	my @exonEnds = split ",", $line[10];
	my $mRNAlength = 0;
	for (my $i = 0; $i < $exonCount; $i++) {
		$mRNAlength += ($exonEnds[$i] - $exonStarts[$i]);
	}
	print OUT "$chrom\t$txStart\t$txEnd\t$name\t$mRNAlength\t$name2\n";
}
close OUT;
close GENE;
system "bedSort $tmp_f refFlat.bed";
unlink $tmp_f;
