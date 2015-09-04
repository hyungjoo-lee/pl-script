#!/usr/bin/perl -w
# genome_feature_cpg.pl disects genomic features of CpGs.
# August 13, 2012
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> <M and M DMR file>\n";

die $usage unless @ARGV;

my ($genome, $in_f, ) = @ARGV;
my ($size_f, $feature_f, $cpg_f);

if ($genome eq "danRer7") {
	$size_f = "/home/hyungjoo/genomes/danRer7_database/chr.size";
	$feature_f = "/home/hyungjoo/genomes/danRer7_database/genome_feature.bed";
	$cpg_f = "/home/hyungjoo/genomes/danRer7_database/MRE/CpG_sites.bed";
} else {
	die "Cannot find database. Now only danRer7\n";
}

#my %chr_size;
#get_chr_size (\%chr_size, $size_f);

my %cnt;

open CPG, $cpg_f or die "Cannot open CpG_sites.bed file.\n";
open FEAT, $feature_f or die "Cannot open genome_feature.bed file.\n";
my $feat_line = undef;
while (<CPG>) {
	next if /^Zv9/;
#	last if /^chrM/;
	chomp;
	my @cpg_line = split;
	my $done = 0;
	while (!$done) {
		if (eof(FEAT)) {
			$cnt{"intergenic"}++;
			last;
		}
		$feat_line = <FEAT> if !defined($feat_line);
		chomp $feat_line;
		my @feat_line = split /\t/, $feat_line;
		if ( ( $cpg_line[0] eq $feat_line[0] ) &&
		     ( $cpg_line[1] >= $feat_line[1] ) &&
		     ( $cpg_line[1] < $feat_line[2] ) ) {
			$cnt{$feat_line[3]}++;
			$done = 1;
		} elsif ( ( $cpg_line[0] lt $feat_line[0] ) ||
			  ( $cpg_line[0] eq $feat_line[0] && $cpg_line[1] < $feat_line[1]) ) {
			$cnt{"intergenic"}++;
			$done = 1;
		} else {
			$feat_line = undef;
			next;
		}
	}
	$cnt{"cpg"}++;
}
close FEAT;
close CPG;

printf "%-20s %8d\n", "Total CpG sites", $cnt{"cpg"};
printf "%-20s %8d\n", "Promoter", $cnt{"promoter"};
printf "%-20s %8d\n", "Exon", $cnt{"exon"};
printf "%-20s %8d\n", "Intron", $cnt{"intron"};
printf "%-20s %8d\n", "Intergenic", $cnt{"intergenic"};
exit;
