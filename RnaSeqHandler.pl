#! /usr/bin/perl -w
# Author: Hyung Joo Lee

use strict;

my $usage = '
RnaSeqHandler.pl <database> <mapped file> <out bed file>

<database>: hg19, danRer7

This script converts the TopHat mapped sam file into a bed file.
Then the reads are sorted.

';

die $usage unless @ARGV;

my ( $database, $sam_f, $name ) = @ARGV;

my $chromSize_f;
my %chr_size;

my $tmp1_f = "tmp1.$$";
my $tmp2_f = "tmp2.$$";

if ($database eq "hg19") {
	$chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/hg19_chrom_sizes";
} elsif ($database eq "danRer7") {
	$chromSize_f = "/data/genomes/danRer7/chr.size";
}

my $genome_size = get_chr_sizes(\%chr_size, $chromSize_f);

sam_2_bed ($sam_f, $tmp1_f, $tmp2_f);

system "bedSort $tmp1_f ${name}_pos.bed";
system "bedSort $tmp2_f ${name}_neg.bed";

system "bedItemOverlapCount null chromSize=$chromSize_f ${name}_pos.bed > ${name}_pos.bedGraph";
system "bedItemOverlapCount null chromSize=$chromSize_f ${name}_neg.bed > ${name}_neg.bedGraph";

unlink $tmp1_f;
unlink $tmp2_f;

###############
# Subroutines #
###############

sub sam_2_bed
{
  my ($in_f, $out1_f, $out2_f) =  @_;
  my @line;
  my @cnt = (0,0);
  my ($chr, $start, $end, $strand, $seq);
  my $chrend;
  my @cigar;
  
  open (IN, $in_f) or die "cannot open the input file $in_f\n";
  open (OUT1,">$out1_f") or die "cannot open the output file $out1_f\n";
  open (OUT2,">$out2_f") or die "cannot open the output file $out2_f\n";
  
  while (<IN>) {
	next if /^@/;
	$cnt[0]++;			## mapeed reads
	chomp;
	@line = split /\t/;

	$chr = $line[2];
	$start = $line[3] - 1;

	my $flag = $line[1];
	my $bin = sprintf("%b", $flag) + 0;
	$bin = sprintf("%08d", $bin);
	my @temp =  split "", $bin;	
	if ($temp[-5] eq 0) {
		$strand = "+";
	} else {
		$strand = "-";
	}

	@cigar = split /[A-Z]/, $line[5];
	my $substr_i = 0;
	for (my $i = 0; $i < @cigar; $i++) {
		if ( $i % 2 == 0 ) {
			$end = $start + $cigar[$i];
			if ( $end <= $chr_size{$chr}-1 ) {   # end
				$chrend = $end;
			} else {
				$chrend = $chr_size{$chr}-1;
			}
			my $seq = substr ($line[9], $substr_i, $cigar[$i]);
			if ( $strand eq "+") {
				print OUT1 "$chr\t$start\t$chrend\t$seq\t0\t$strand\t0\t0\t255,0,0\n";
			} else {
				print OUT2 "$chr\t$start\t$chrend\t$seq\t0\t$strand\t0\t0\t0,0,255\n";
			}
			$substr_i += $cigar[$i];
			$cnt[1]++;
		} else {
			$start = $end + $cigar[$i];
		}
	}	
  }
  printf "total mapped reads:\t%10d\ntotal bed lines:\t%10d\naverage junctions per reads:\t%10d\n", @cnt, $cnt[1]/$cnt[0];
  close OUT1;
  close OUT2;
  close IN;
}

sub get_chr_sizes
{
  my ( $chr_r, $file ) = @_;
  my $size = 0;
  my @line;
  open ( IN, $file ) or die "Cannot open $file.";
  while ( <IN> )
  {
	chomp;
	@line = split;
	$chr_r->{$line[0]} = $line[1];
	$size += $line[1];
  }
  close IN;
  return $size;
}

