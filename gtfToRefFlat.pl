#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# May 2, 2013

use strict;

my $usage = "Usage: perl $0 <gtf gene sort ext file> <output file refFlat format>";
die $usage unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my %nonredundantGene;
my %geneLength;

open GENE, $in_f or die "Cannot open $in_f file.\n";
while (<GENE>) {
	chomp;
	my @line = split;
	my @flat_line = @line[1..9];
	$flat_line[0] = "chr".$flat_line[0] if ($flat_line[0] =~ /^\d+/);
	$flat_line[0] = "chrM" if ($flat_line[0] eq "MT");
	my ($gene_id, $gene_name, $gene_bioType, ) = ($line[11], $line[15], $line[16]);
#	next unless ($gene_bioType =~ /^protein_coding/);
	my $length = $line[4] - $line[3];
	if ( (!exists $geneLength{$gene_id}) || 
	     (exists $geneLength{$gene_id}) && ($geneLength{$gene_id} < $length) ) {
		$geneLength{$gene_id} = $length;
		$nonredundantGene{$gene_id} = $gene_id."\t.\t".join("\t", @flat_line)."\t$gene_bioType\n";
	}
}
close GENE;
open OUT, ">$out_f" or die "Cannot open $out_f.\n";
for (sort keys %geneLength) {
	print OUT $nonredundantGene{$_};
}
close OUT;

