#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# June 10, 2013
# June 14, 2013 Edited to include all redundant genes

use strict;

my $usage = "Usage: perl $0 <gtf gene sort ext file> STDOUT > ensGene refFlat format with geneName2";
die $usage unless @ARGV;

my ($in_f, ) = @ARGV;
#my %nonredundantGene;
#my %geneLength;

open GENE, $in_f or die "Cannot open $in_f file.\n";
while (<GENE>) {
	chomp;
	my @line = split;
	my @flat_line = @line[1..9];
	$flat_line[0] = "chr".$flat_line[0] if ($flat_line[0] =~ /^\d+/);
	$flat_line[0] = "chrM" if ($flat_line[0] eq "MT");
	my ($gene_id, $gene_name, $gene_bioType, ) = ($line[11], $line[15], $line[16]);
	next unless ($gene_bioType =~ /RNA$/);
	my $line = join("\t", @flat_line);
	print "$gene_name\t$gene_id\t$line\t$gene_bioType\n";

}
close GENE;
#open OUT, ">$out_f" or die "Cannot open $out_f.\n";
#for (sort keys %geneLength) {
#	print $nonredundantGene{$_};
#}
#close OUT;
exit;
