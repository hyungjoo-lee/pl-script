#!/usr/bin/perl -w
# genome_feature.pl disects genomic features of certain genome and generate bed file.
# May 3, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> <bed file>\n";

die $usage unless @ARGV;

my ($genome, $out_f) = @ARGV;
my $tmp_f = "tmp.$$";
my ($promoter_f, $exon_f) = ("promoter_tmp.$$", "exon_tmp.$$");
my ($size_f, $gene_f);

if ($genome eq "hg19") {
	$size_f = "/home/hyungjoo/genomes/hg19/hg19_chrom_sizes";
	$gene_f = "/home/hyungjoo/genomes/hg19/refFlat.txt";
} elsif ($genome eq "danRer7") {
	$size_f = "/data/genomes/danRer7/chr.size";
	$gene_f = "/data/genomes/danRer7/gtf/ensFlat.71.txt";
} else {
	die "Cannot find database. Now only hg19 or danRer7\n";
}

my %chr_size;
my $genome_size = get_chr_size (\%chr_size, $size_f);

open GENE, $gene_f or die "Cannot open $gene_f file.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f file.\n";
while (<GENE>) {
	next if /Zv9/;
        chomp;
        my @line = split;
	my ($geneName, $chr, $strand, $start, $end, $numExon) = ($line[0], @line[2..5], $line[8]);
	my @exonStarts = split /,/, $line[9];
	my @exonEnds = split/,/, $line[10];
	my ($promoterStart, $promoterEnd);
	if ($strand eq "+") {
		$promoterStart = ($start < 1500)? 0 : $start - 1500;
		$promoterEnd = ($start > $chr_size{$chr} + 500)? $chr_size{$chr} : $start + 500;
	} else {
		$promoterEnd = ($end > $chr_size{$chr} + 1500)? $chr_size{$chr} : $end + 1500;
		$promoterStart = ($end < 500)? 0 : $end - 500;
	}
	print OUT "$chr\t$promoterStart\t$promoterEnd\tpromoter\n";
	for (my $i = 0; $i < $numExon; $i++) {
		print OUT "$chr\t$exonStarts[$i]\t$exonEnds[$i]\texon\n";
		print OUT "$chr\t$exonEnds[$i]\t$exonStarts[$i+1]\tintron\n" unless ($i == $numExon-1);
	}	
}
close OUT;
close GENE;
system "bedSort $tmp_f $tmp_f";
system "grep 'promoter' $tmp_f | bedops -m - > $promoter_f";

exit;

#############
#Subroutines#
#############

sub get_chr_size {
	my ( $chr_r, $file ) = @_;
	my $size = 0;
	open ( IN, $file ) || die "Cannot open $file.";
	while ( <IN> ) {
	    next if /^Zv9/;
		chomp;
		my @line = split;
		$chr_r -> {$line[0]} = $line[1];
		$size += $line[1];
	}
	close IN;
	return $size;
}
