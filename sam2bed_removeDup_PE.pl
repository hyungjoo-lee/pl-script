#! /usr/bin/perl -w
#----------------------------------------------------------#
# Copyright (C) 2009 UC Santa Cruz, Santa Cruz CA          #
# All Rights Reserved.                                     #
#                                                          #
# Author: Ting Wang                                        #
# Send all comments to tingwang@soe.ucsc.edu               #
#                                                          #
# DISCLAIMER: THIS SOFTWARE IS PROVIDED "AS IS"            #
#             WITHOUT WARRANTY OF ANY KIND.                #
#----------------------------------------------------------#

use strict;

my $usage = '
sam2bed_PE.pl <database> <mapped file>

<database>: hg19, danRer7

This script convert the bwa mapped bam file into a bed file.
Then the reads are sorted.

';

die $usage unless @ARGV;

my ( $database, $sam_f, $out_f ) = @ARGV;

my $chromSize_f;
my %chr_size;

my $tmp_f = "tmp.$$";

if ($database eq "hg19") {
	$chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/hg19_chrom_sizes";
} elsif ($database eq "danRer7") {
	$chromSize_f = "/home/comp/twlab/mxie/Zebrafish/danRer7/danRer7_chrom_sizes";
}

my $genome_size = get_chr_sizes(\%chr_size, $chromSize_f);

sam_2_bed ($sam_f, $tmp_f);

system "bedSort $tmp_f $tmp_f";

remove_dup ($tmp_f, $out_f);

system "bedSort $out_f $out_f";

unlink $tmp_f;


###############
# Subroutines #
###############

sub sam_2_bed
{
  my ($in_f, $out_f) =  @_;
  my @line;
  my $cnt = 0;
  my @cnt = (0,0,0,0);
  my $strand;
  my $name;
  my $chrend;
  my $chr;
  my $mapQ;
  
  open (IN, $in_f) or die "cannot open the input file $in_f\n";
  open (OUT,">$out_f") or die "cannot open the output file $out_f\n";
  
  while (<IN>) {
	next if /^@/;
	$cnt++;
	chomp;
	@line = split /\t/;
	if ($cnt % 2 == 1) {
		$mapQ = $line[4];
		next;
	}
#	next if ($line[1] >= 128);	## second in pair
	$cnt[0]++;			## total reads

	$chr = $line[2];
	my $start;
	my $length = $line[8];
	next if ( $length == 0 );
	$cnt[1]++;			## mapped paried reads

	next if (abs($length) > 700);	# 
	$cnt[2]++;

	next if ( ($line[4] < 10) && ($mapQ < 10) );
	$cnt[3]++;			## reads with mapQ >= 10

	if ( $length < 0 ) {
		$strand = "-";
		$start = $line[7] - 1;
		$length = abs $length;
	} else {
		$strand = "+";
		$start = $line[3] - 1;
	}
	my $end = $start + $length;

#	unless ($length < 20) {
		my $new_length = int ($length * 0.7 + 0.5);
		$start = $start + int (($length - $new_length)/2 +0.5);
		$end = $start + $new_length;
#	}
	next if ($new_length == 0);
	$cnt[4]++;

	if ( $end <= $chr_size{$chr}-1 ) {   # end
		$chrend = $end;
	} else {
		$chrend = $chr_size{$chr}-1;
	}
	my $seq = $line[0];

	print OUT "$chr\t$start\t$chrend\t$seq\t0\t$strand\t0\t0\t";
	if ( $strand eq "+") {
		print OUT "255,0,0\n";
	} else {
		print OUT "0,0,255\n";
	}
  }
  printf "total paired reads:\t%10d\nmapped paired reads:\t%10d (including long reads)\nmapped paird reads:\t%10d (length <= 700bp)\nreliable paired reads (mapQ >= 10):\t%10d\nreliabale paired reads (0<length<=490bp)\t%10d\n", @cnt;
  close OUT;
  close IN;
}

sub remove_dup
{
  my ( $in_f, $out_f ) = @_;
  my @pos = ("", "", "");
  my $cnt = 0;
  my @line;
  open ( IN, $in_f ) or die "Cannot open $in_f";
  open ( OUT, ">$out_f" ) or die "Cannot open $out_f";
  
  while ( <IN> ) {
	#chomp;
	@line = split /\t/;
	if ( ($line[0] eq $pos[0]) && ($line[1] eq $pos[1]) && ($line[2] eq $pos[2]) ) {
		next;
	} else {
		print OUT $_;
		$cnt ++;
		$pos[0] = $line[0];
		$pos[1] = $line[1];
		$pos[2] = $line[2];
	}
  }
  printf "unique reads:\t%10d\n", $cnt;
  close OUT;
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

