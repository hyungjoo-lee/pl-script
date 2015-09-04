#!/usr/bin/perl -w
# genome_feature_dmr.pl disects genomic features of DMRs identified by M and M.
# August 13, 2012
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> <M and M DMR file>\n";

die $usage unless @ARGV;

my ($genome, $dmr_f, ) = @ARGV;
my ($size_f, $feature_f, );

if ($genome eq "danRer7") {
#	$size_f = "/home/hyungjoo/genomes/danRer7_database/chr.size";
	$feature_f = "/home/hyungjoo/genomes/danRer7_database/genome_feature.bed";
} else {
	die "Cannot find database. Now only danRer7\n";
}

my $tmp_f = "tmp.$$";
system "bedSort $dmr_f $tmp_f";

#my %chr_size;
#get_chr_size (\%chr_size, $size_f);

my %cnt;

open DMR, $tmp_f or die "Cannot open $tmp_f file.\n";
open FEAT, $feature_f or die "Cannot open genome_feature.bed file.\n";
my $feat_line = undef;
while (<DMR>) {
	next if /^Zv9/;
	last if /^chrM/;
	chomp;
	my @dmr_line = split;
	my $dmr_coord = ($dmr_line[1] + $dmr_line[2]) / 2 ;
	my $done = 0;
	while (!$done) {
		$feat_line = <FEAT> if !defined($feat_line);
		chomp $feat_line;
		if ($feat_line =~ /^chrM/) {
			$cnt{"intergenic"}++;
			last;
		}
		my @feat_line = split /\t/, $feat_line;
		if ( ( $dmr_line[0] eq $feat_line[0] ) &&
		     ( $dmr_coord >= $feat_line[1] ) &&
		     ( $dmr_coord < $feat_line[2] ) ) {
			$cnt{$feat_line[3]}++;
			$done = 1;
		} elsif ( ( $dmr_line[0] lt $feat_line[0] ) ||
			  ( $dmr_line[0] eq $feat_line[0] && $dmr_coord < $feat_line[1]) ) {
			$cnt{"intergenic"}++;
			$done = 1;
		} else {
			$feat_line = undef;
			next;
		}
	}
	$cnt{"dmr"}++;
}
close FEAT;
close DMR;
unlink $tmp_f;

print "\n===From $dmr_f file, the result is:===\n";
printf "%-20s %8d\n", "Total DMRs", $cnt{"dmr"};
printf "%-20s %8d\n", "Promoter", $cnt{"promoter"};
printf "%-20s %8d\n", "Exon", $cnt{"exon"};
printf "%-20s %8d\n", "Intron", $cnt{"intron"};
printf "%-20s %8d\n", "Intergenic", $cnt{"intergenic"};
exit;
