#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <GREAT gene txt file> <all gene RNA RPKM file> <new RNA rpkm file>\n" unless @ARGV;

my ($gene_f, $in_f, $out_f) = @ARGV;
my %gene;

open GENE, $gene_f or die "Cannot open $gene_f file.\n";
while (<GENE>) {
	next if /^#/;
	chomp;
	my @line = split;
	$gene{$line[0]} = 1;
	}
close GENE;

open IN, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
while (<IN>) {
	my @line = split;
	my $gene_id = $line[0];
	print OUT if (exists $gene{$gene_id});
}
close IN;
close OUT;
exit;
