#!/usr/bin/perl -w
# This perl script generates TSS bed6 file from ensGene.txt file
# Author: Hyung Joo Lee
# June 10, 2013

use strict;

my $usage = "Usage: perl $0 <ensGene.txt> <gene group txt> STDOUT >output bed6 file";
die $usage unless @ARGV;

my ($in_f, $gene_f) = @ARGV;
my %gene;

open GENE, $gene_f or die "Cannot open $gene_f file.\n";
while (<GENE>) {
	chomp;
	$gene{$_} = 1;
}
close GENE;

open IN, "$in_f" or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $name = $line[0];
	next unless (exists $gene{$name});
	my ($chr, $strand) = @line[2..3];
	my $tss = ($strand eq "+") ? $line[4] : $line[5];
	my $end = $tss + 1;
	print "$chr\t$tss\t$end\t$name\t0\t$strand\n";
}
close IN;
exit;
