#!/usr/bin/perl -w
# This identifies HCP and LCP from the sequences upstream 1 kb of TSS.
# August 06, 2012 
# Modified June 18, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <ensGene bed file> <up1k.fa file> <output base name> \n";
# example: ~/scripts_pl/IdPromoterCpGs.pl /data/genomes/danRer7/gtf/ensGene.71.protein_coding.bed /expr/hlee/zebrafish/embryogenesis/promoters/ensGene.71.protein_coding.up1k.fa ensGene.71.protein_coding

die $usage unless @ARGV;

my ($bed_f, $fa_f, $name) = @ARGV;
my $hcp_f = $name.".hcp.bed";
my $lcp_f = $name.".lcp.bed";

my %promoters;
my %oe_ratio;
my %cg_pcnt;
open FA, $fa_f or die "Cannot open $fa_f file.\n";
my ($coord, $seq);
my @cnt = (0, 0, 0, 0);
while (<FA>) {
	chomp;
	if (/^>/) {
		($oe_ratio{$coord}, $cg_pcnt{$coord}) = id_promoter ($coord, $seq) if ($cnt[0]!=0);
		chomp;
		$coord = $_;
		$coord =~ s/>//;
		$seq = "";
		$cnt[0]++;
	} else {
		$seq .= $_;
	}
}
($oe_ratio{$coord}, $cg_pcnt{$coord}) = id_promoter ($coord, $seq);
close FA;

open BED, $bed_f or die "Cannot open $bed_f file.\n";
open OUT1, ">$hcp_f" or die "Cannot open $hcp_f.\n";
open OUT2, ">$lcp_f" or die "Cannot open $lcp_f.\n";
while (<BED>) {
	chomp;
	my @line = split;
	my $coord = $line[3];
	unless (exists $promoters{$coord}) {
		$cnt[3]++;
		next;
	}
	$_ .="\t$oe_ratio{$coord}\t$cg_pcnt{$coord}\n";
	if ($promoters{$coord} eq "h") {
		print OUT1;
		$cnt[1]++;
	} elsif ($promoters{$coord} eq "l") {
		print OUT2;
		$cnt[2]++;
	}
}
close OUT1;
close OUT2;
close BED;

print "Of $cnt[0] gene promoters, $cnt[1] were identified as HCP and $cnt[2] were identified as LCP.\n";
print "$cnt[3] missed.\n";

exit;

#############
#Subroutines#
#############

sub id_promoter {
	my ( $coord, $seq ) = @_;
	$seq = lc $seq;
	for (my $i = 0; $i <= 500 ; $i = $i+10) {
		my $subseq = substr $seq, $i, $i+500;
		my $c = $subseq =~ s/c/c/g;
		my $g = $subseq =~ s/g/g/g;
		my $cg = $subseq =~ s/cg/cg/g;
		my $oe_ratio = ( $c*$g !=0 ) ? ($cg * 500) / ($c * $g) : 1;
		my $cg_pcnt = ($c + $g) / 500;
		if ( ($oe_ratio >= 0.65) && ($cg_pcnt > 0.30) ) {
			$promoters{$coord} = "h";
			last;
		} else {
			$promoters{$coord} = "l";
		}
	}
	my $c = $seq =~ s/c/c/g;
	my $g = $seq =~ s/g/g/g;
	my $cg = $seq =~ s/cg/cg/g;
	my $oe_ratio = ( $c*$g != 0) ? ($cg * 1000) / ($c * $g) : 1;
	my $cg_pcnt = ($c + $g) / 1000;
	return ($oe_ratio, $cg_pcnt);
}
