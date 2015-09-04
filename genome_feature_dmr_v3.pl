#!/usr/bin/perl -w
# genome_feature_dmr.pl disects genomic features of DMRs identified by M and M.
# August 13, 2012
# Modified on May 2, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> <bedSorted DMR file> <output DMR bed file>\n";

die $usage unless @ARGV;

my ($genome, $dmr_f, $out_f) = @ARGV;
my $feature_f;

if ($genome eq "danRer7") {
	$feature_f = "/data/genomes/danRer7/genome_feature_nonoverlap.bed";
} else {
	die "Cannot find database. Now only danRer7\n";
}

my %cnt;

open DMR, $dmr_f or die "Cannot open $dmr_f file.\n";
open FEAT, $feature_f or die "Cannot open $feature_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
my $feat_line = undef;
while (<DMR>) {
	next if /chrSt/;
	chomp;
	my @dmr_line = split;
	my $dmr_coord = ($dmr_line[1] + $dmr_line[2]) / 2 ;
	my $done = 0;
	while (!$done) {
		$feat_line = <FEAT> if !defined($feat_line);
		if (eof(FEAT)) {
			$cnt{"intergenic"}++;
			print OUT $_."\tintergenic\n";
			$done = 1;
		}
		chomp $feat_line;
		my @feat_line = split /\t/, $feat_line;
		if ( ( $dmr_line[0] eq $feat_line[0] ) &&
		     ( $dmr_coord >= $feat_line[1] ) &&
		     ( $dmr_coord < $feat_line[2] ) ) {
			$cnt{$feat_line[3]}++;
			print OUT $_."\t$feat_line[3]\n";
			$done = 1;
		} elsif ( ( $dmr_line[0] lt $feat_line[0] ) ||
			  ( $dmr_line[0] eq $feat_line[0] && $dmr_coord < $feat_line[1]) ) {
			$cnt{"intergenic"}++;
			print OUT $_."\tintergenic\n";
			$done = 1;
		} else {
			$feat_line = undef;
			next;
		}
	}
	$cnt{"dmr"}++;
}
close OUT;
close FEAT;
close DMR;

print "\n===From $dmr_f file, the result is:===\n";
printf "%-20s %8d\n", "Total DMRs", $cnt{"dmr"};
printf "%-20s %8d\n", "Promoter", $cnt{"promoter"};
printf "%-20s %8d\n", "Exon", $cnt{"exon"};
printf "%-20s %8d\n", "Intron", $cnt{"intron"};
printf "%-20s %8d\n", "Intergenic", $cnt{"intergenic"};
exit;
