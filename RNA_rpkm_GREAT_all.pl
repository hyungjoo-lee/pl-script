#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <GREAT output file> <all gene RNA RPKM file> <new RNA rpkm file>\n" unless @ARGV;

my ($great_f, $in_f, $out_f) = @ARGV;
my %gene;

open GREAT, $great_f or die "Cannot open $great_f file.\n";
while (<GREAT>) {
	next if /^#/;
	chomp;
	my @line = split /\t/;
	my ($binomP, $foldEnrich, $hyperQ) = ($line[4], $line[7], $line[15] );
	next if ( ($foldEnrich < 2) || ($binomP > 0.05) || ($hyperQ > 0.05));
	my @genes = split /,/, $line[23];
	for (@genes) {
		$gene{$_} = 1;
		}
	}
close GREAT;

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
