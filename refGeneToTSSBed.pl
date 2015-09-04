#!/usr/bin/perl -w
# This perl script generates TSS bed6 file from ensGene.txt file
# Author: Hyung Joo Lee
# March 5, 2013

use strict;

my $usage = "Usage: perl $0 <ensGene.txt> <output bed6 file>";
die $usage unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my $tmp_f = "tmp.$$";

open GENE, $in_f or die "Cannot open ensGene.txt.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f.\n";
while (<GENE>) {
	next if /WITHDRAWN/;
	next if /Zv9_/;
	chomp;
	my @line = split;
	my ($chr, $strand) = @line[2..3];
	my $name = $line[1];
	my $tss = ($strand eq "+") ? $line[4] : $line[5];
	my $end = $tss + 1;
	print OUT "$chr\t$tss\t$end\t$name\t0\t$strand\n";
}
close OUT;
close GENE;
system "bedSort $tmp_f $out_f";
unlink $tmp_f;
