#!/usr/bin/perl -w
# This generates AUC profiles (chromatin marks or any other data) of certain coordinates (DMRs).
# June 17, 2012 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed file> <score bedGraph> <number of reads> <out file>\n";

die $usage unless @ARGV;

my ($in_f, $data_f, $reads, $out_f ) = @ARGV;
my $tmp_f = "tmp.$$";

$reads /= 1000000;

open IN, $in_f or die "Cannot open $in_f.\n";
open DATA, $data_f or die "Cannot open $data_f.\n";
open OUT, ">$tmp_f" or die "Cannot oepn $tmp_f.\n";

my $data_line = undef;
my @pre_rpkm;
my @cur_rpkm;
my $pre_chr = "chr0";
my $pre_start = 0;
while (<IN>) {
	chomp;
	my @in_line = split;
	my $diff = 200;
	if ( ($in_line[0] eq $pre_chr) && ($in_line[1] < $pre_start + 5000) ) {
		$diff = ($in_line[1] - $pre_start) / 50;
		for (my $i = 0; $i < 200-$diff; $i++) {
			$cur_rpkm[$i] = $pre_rpkm[$i+$diff];
			print OUT "$cur_rpkm[$i]\t";
		}
	}
	for (my $i = 200-$diff; $i < 200; $i++) {
		my $area = 0;
		for (my $j = 0; $j < 50; $j++) {
			my $coord  = $in_line[1] + ($i * 50) + $j;
			my $done = 0;
			while ( !$done ) {
				last if eof(IN);
				$data_line = <DATA> if !defined($data_line) ;
				my @data_line = split "\t", $data_line;
				last if $data_line =~ /^chrM/;
				if ( ( $in_line[0] eq $data_line[0] ) &&
				     ( $coord  >= $data_line[1] ) &&
				     ( $coord  < $data_line[2] ) )
				{	$area += $data_line[3];
                       			$done = 1;
				} elsif ( ( $in_line[0] lt $data_line[0] ) ||
				          ( $in_line[0] eq $data_line[0] && $coord < $data_line[1]) )
				{       $done = 1;
				} else {
					$data_line = undef;
					next;
				}
			}
		}
		$cur_rpkm[$i] = $area / (50*$reads*50/1000);
		print OUT "$cur_rpkm[$i]";
		print OUT "\t" unless ($i == 199);
	}
	print OUT "\n";
	@pre_rpkm = @cur_rpkm;
	$pre_chr = $in_line[0];
	$pre_start = $in_line[1];
}

close OUT;
close DATA;
close IN;

open IN, $in_f or die "Cannot open $in_f.\n";
open DATA, $tmp_f or die "Cannot open $tmp_f.\n";
open OUT, ">$out_f" or die "Cannot oepn $out_f.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $strand = $line[5];
	my $data = <DATA>;
	chomp $data;
	my @data = split "\t", $data;
	if ($strand eq "+") {
		print OUT "$data\n";
	} else {
		for (my $i = @data-1; $i>0; $i--) {
			print OUT "$data[$i]\t";
		}
		print OUT "$data[0]\n";
	}
}
close OUT;
close DATA;
close IN;

#unlink $tmp_f;

exit;
