#!/usr/bin/perl -w
# This script generates bed file from refGene.txt file
# Author: Hyung Joo Lee
# June 20, 2012

use strict;

my $usage = "Usage: perl $0 <GSE32898 Schier transcripts.bed> <output bed file>\n";
die $usage unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my $tmp_f = "tmp.$$";

open GENE, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f.\n";
while (<GENE>) {
	chomp;
	my @line = split;
	my ($chrom, $txStart, $txEnd, $name, $exonCount ) = ($line[0], $line[1], $line[2], $line[3], $line[9] );
	my @exonSizes = split ",", $line[10];
	my $mRNAlength = 0;
	for (my $i = 0; $i < $exonCount; $i++) {
		$mRNAlength += $exonSizes[$i];
	}
	print OUT "$chrom\t$txStart\t$txEnd\t$name\t$mRNAlength\n";
}
close OUT;
close GENE;
system "bedSort $tmp_f $out_f";
unlink $tmp_f;
