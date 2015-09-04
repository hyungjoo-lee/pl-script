#!/usr/bin/perl -w
# dmr_genome_feature.pl disects genomic features of DMRs identified by M and M.
# August 9, 2012 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> <M and M DMR file>\n";

die $usage unless @ARGV;

my ($genome, $in_f, ) = @ARGV;
my $tmp_f = "tmp.$$";
# my $out_f = $name.".R";
my ($size_f, $gene_f);

if ($genome eq "hg19") {
	$size_f = "/home/hyungjoo/genomes/hg19/hg19_chrom_sizes";
	$gene_f = "/home/hyungjoo/genomes/hg19/refFlat.txt";
} elsif ($genome eq "danRer7") {
	$size_f = "/home/hyungjoo/genomes/danRer7_database/chr.size";
	$gene_f = "/home/hyungjoo/genomes/danRer7/database/refFlat.txt";
} else {
	die "Cannot find database. Now only hg19 or danRer7\n";
}

my %chr_size;
my $genome_size = get_chr_size (\%chr_size, $size_f);

open GENE, $gene_f or die "Cannot open refFlat.txt.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f.\n";
while (<GENE>) {
        next if /WITHDRAWN/;
	next if /Zv9/;
        chomp;
        my @line = split;
        print OUT "$line[2]\t$line[4]\t$line[5]\t$line[0]\t0\t$line[3]\t$line[8]\t$line[9]\t$line[10]\n";
}
close OUT;
close GENE;
system "bedSort $tmp_f $tmp_f";

open GENE, $tmp_f or die "Cannot open $tmp_f.\n";
# open IN, $in_f or die "Cannot open $in_f.\n";
my @size = (0, 0, 0, );
my $cnt_skip = 0;
my @prev_line = ("Zv9_NA1", "0", "0", "example", "0", "+", "0", "0,", "0,");
while (<GENE>) {
	chomp;
	my @gene_line = split;
	if ( ($prev_line[0] eq $gene_line[0]) && ($prev_line[2] > $gene_line[1]) ) { #&& ($prev_line[2] == $gene_line[2]) );
		$cnt_skip++;
		next;
	}
	my $promoter;
	my @exon_start = split /,/, $gene_line[7];
	my @intron_start = split /,/, $gene_line[8];
	my ($size_promoter, $size_exon, $size_intron) = (0, 0, 0);
	for (my $i = 0; $i < $gene_line[6]; $i++) {
		$size_exon += ($intron_start[$i] - $exon_start[$i]);
	}
	$size_intron = $gene_line[2] - $gene_line[1] - $size_exon;
	$size[1] += $size_exon;
	$size[2] += $size_intron;
	my $promoter_done = 0;
	if ($prev_line[5] eq "-") {
		$promoter = $prev_line[2] + 2000;
		$promoter = $chr_size{$prev_line[0]} if ($promoter > $chr_size{$prev_line[0]});
		if ($prev_line[0] eq $gene_line[0]) {
			if ($gene_line[5] eq "+") {
				if ($promoter > ($gene_line[1]-2000)) {
					$promoter = $gene_line[1];
					$promoter_done = 1;
				}
			} elsif ($promoter > $gene_line[1]) {
				$promoter = $gene_line[1];
			}
		}
		$size_promoter = $promoter - $prev_line[2];
#		print "$prev_line[0]\t$prev_line[1]\t$prev_line[2]\t$prev_line[3]\n$_\n" if ($size_promoter < 0);
		$size[0] += $size_promoter;
	}
	if ( ($gene_line[5] eq "+") && !$promoter_done) {
		$promoter = $gene_line[1] - 2000;
		$promoter = 0 if ($promoter < 0);
		$promoter = $prev_line[2] if ( ($prev_line[0] eq $gene_line[0]) && ($promoter < $prev_line[2]) );
		$size_promoter = $gene_line[1] - $promoter;
#		print if ($size_promoter < 0);
		$size[0] += $size_promoter;
	}
	@prev_line = @gene_line;
}
close GENE;
unlink $tmp_f;
if ($prev_line[5] eq "-") {
	my $promoter = $prev_line[2] + 2000;
	$promoter = $chr_size{$prev_line[0]} if ($promoter > $chr_size{$prev_line[0]});
	my $size_promoter = $promoter - $prev_line[2];
	$size[0] += $size_promoter;
}
$size[3] = $genome_size - ($size[0] + $size[1] + $size[2]);
print "Total 15782 genes were went through and among them $cnt_skip genes were skipped due to the overlap.\n";
printf "%-15s Size (bp)\n", "Genomic Feature";
printf "%-15s %10d\n", "Promoters", $size[0];
printf "%-15s %10d\n", "Exons", $size[1];
printf "%-15s %10d\n", "Introns", $size[2];
printf "%-15s %10d\n", "Intergenic", $size[3];
printf "%-15s %10d\n", "Total Genome", $genome_size;
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
