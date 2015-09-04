#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# May 2, 2013

use strict;

my $usage = "Usage: perl $0 <Ensembl gtf file> <Gene Sort output file>";
die $usage unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my %gene_id;
my %gene_name;
my %gene_biotype;

open GENE, $in_f or die "Cannot open ensGene.txt.\n";
while (<GENE>) {
	chomp;
	my @line = split /\t/;
	my @annotation = split /; /, $line[8];
	my $transcript_id = substr $annotation[1], 15, -1;
	$gene_id{$transcript_id} = substr $annotation[0], 10, -1;
	for (@annotation) {
		my ($annot_type, $annot_content) = split;
		$annot_content =~ s/\"//g;
		$gene_name{$transcript_id} = $annot_content if ($annot_type eq "gene_name");
		$gene_biotype{$transcript_id} = $annot_content if ($annot_type eq "gene_biotype");
	}
}
close GENE;

open OUT, ">$out_f" or die "Cannot open $out_f.\n";
for (sort keys %gene_id) {
	$gene_name{$_} = "." unless (exists $gene_name{$_});
	$gene_biotype{$_} = "." unless (exists $gene_biotype{$_});
	print OUT "$_\t$gene_id{$_}\t$gene_name{$_}\t$gene_biotype{$_}\n";
}
close OUT;
exit;
