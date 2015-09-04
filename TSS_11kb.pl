#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <genome> <ensGene bed file> <new coordinate bed file> \n" unless @ARGV;

my ($genome, $in_f, $out_f) = @ARGV;

my $size_f;
if ($genome eq "hg19") {
        $size_f = "/home/comp/twlab/hlee/expr/paleale/genomes/hg19/hg19_chrom_sizes";
#       $gene_f = "/home/hyungjoo/genomes/hg19/refFlat.txt";
} elsif ( $genome eq "mm9" ) {
	$size_f = "/home/comp/twlab/twang/twlab-shared/genomes/mm9/mm9_chrom_sizes";
} elsif ($genome eq "danRer7") {
        $size_f = "/home/comp/twlab/hlee/expr/paleale/genomes/danRer7_database/chr.size";
} else {
        die "Cannot find database. Now only hg19 or danRer7\n";
}

my %chr_size;
get_chr_size (\%chr_size, $size_f);

open IN, "$in_f" or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
while (<IN>) {
	next if /^Zv9/;
	chomp;
	my @line = split;
	my ($chr, $start, $end, $id, $score, $strand) = @line;
	if ($strand eq "+") {
		$start -= 8000;
		next if ($start < 0);
		$end = $start + 11000;
		next if ($end > $chr_size{$chr});
	} elsif ($strand eq "-") {
		$end += 8000;
		next if ($end > $chr_size{$chr});
		$start = $end - 11000;
		next if ($start < 0);
	}
	print OUT "$chr\t$start\t$end\t$id\t$score\t$strand\n";
}
close IN;
close OUT;
exit;



sub get_chr_size {
	my ( $chr_r, $file ) = @_;
	my $size = 0;
	open ( IN, $file ) or die "Cannot open $file.";
	while ( <IN> ) {
		chomp;
		my @line = split;
		$chr_r -> {$line[0]} = $line[1];
		$size += $line[1];
	}
	close IN;
	return $size;
}

