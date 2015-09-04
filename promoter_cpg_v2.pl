#!/usr/bin/perl -w
# promoter_cpg.pl identifies HCP and LCP from the sequences upstream 1 kb of TSS.
# August 06, 2012 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> \n";

die $usage unless @ARGV;

my ($genome, $in_f, $name) = @ARGV;
my $hcp_f = "ensGene_hcp.bed";
my $lcp_f = "ensGene_lcp.bed";
my ($gene_f, $seq_f);

if ($genome eq "hg19") {
	$gene_f = "/home/comp/twlab/hlee/expr/paleale/genomes/hg19/ensGene.txt";
	$seq_f = "/home/comp/twlab/hlee/expr/paleale/genomes/hg19/upstream1000.fa";
} elsif ($genome eq "danRer7") {
	$gene_f = "/home/hyungjoo/genomes/danRer7/database/ensGene.txt";
	$seq_f = "/home/hyungjoo/genomes/danRer7/bigZips/upstream1000.fa";
} else {
	die "Cannot find database. Now only hg19 or danRer7\n";
}

my %promoters;
my %oe_ratio;
my %cg_pcnt;
open SEQ, $seq_f or die "Cannot open upstream1000.fa file.\n";
my ($gene, $seq);
my @cnt = (0, 0, 0, 0);
while (<SEQ>) {
	chomp;
	if (/^>(\w+\d+)_up/) {
		($oe_ratio{$gene}, $cg_pcnt{$gene}) = id_promoter ($gene, $seq) if ($cnt[0]!=0);
		$gene = $1;
		$seq = "";
		$cnt[0]++;
	} else {
		$seq .= $_;
	}
}
($oe_ratio{$gene}, $cg_pcnt{$gene}) = id_promoter ($gene, $seq);
close SEQ;

open GENE, $gene_f or die "Cannot open ensGene.txt file.\n";
open OUT1, ">$hcp_f" or die "Cannot open $hcp_f.\n";
open OUT2, ">$lcp_f" or die "Cannot open $lcp_f.\n";
while (<GENE>) {
	next if /^WITHDRAWN/;
	my @line = split;
	my $gene = $line[1];
	unless (exists $promoters{$gene}) {
		$cnt[3]++;
		print "$gene\n";
		next;
	}
	if ($promoters{$gene} eq "h") {
		print OUT1 "$line[2]\t$line[4]\t$line[5]\t$gene\t0\t$line[3]\t$oe_ratio{$gene}\t$cg_pcnt{$gene}\n";
		$cnt[1]++;
	} elsif ($promoters{$gene} eq "l") {
		print OUT2 "$line[2]\t$line[4]\t$line[5]\t$gene\t0\t$line[3]\t$oe_ratio{$gene}\t$cg_pcnt{$gene}\n";
		$cnt[2]++;
	}
}
close OUT1;
close OUT2;
close GENE;

print "Of $cnt[0] gene promoters, $cnt[1] were identified as HCP and $cnt[2] were identified as LCP.\n";
print "$cnt[3] gene promoters have unmatched coordinates.\n";

exit;

#############
#Subroutines#
#############

sub id_promoter {
	my ( $gene, $seq ) = @_;
	$seq = lc $seq;
	for (my $i = 0; $i <= 500 ; $i = $i+10) {
		my $subseq = substr $seq, $i, $i+500;
		my $c = $subseq =~ s/c/c/g;
		my $g = $subseq =~ s/g/g/g;
		my $cg = $subseq =~ s/cg/cg/g;
		my $oe_ratio = ( $c*$g !=0 ) ? ($cg * 500) / ($c * $g) : 1;
		my $cg_pcnt = ($c + $g) / 500;
		if ( ($oe_ratio >= 0.65) && ($cg_pcnt > 0.30) ) {
			$promoters{$gene} = "h";
			last;
		} else {
			$promoters{$gene} = "l";
		}
	}
	my $c = $seq =~ s/c/c/g;
	my $g = $seq =~ s/g/g/g;
	my $cg = $seq =~ s/cg/cg/g;
	my $oe_ratio = ( $c*$g != 0) ? ($cg * 1000) / ($c * $g) : 1;
	my $cg_pcnt = ($c + $g) / 1000;
	return ($oe_ratio, $cg_pcnt);
}
