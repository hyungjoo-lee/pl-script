#!/usr/bin/perl -w
# This generates AUC profiles (chromatin marks or any other data) of certain coordinates (DMRs).
# May 17, 2013 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed file> <conservation score bedGraph> <out file>\n";

die $usage unless @ARGV;

my ($in_f, $data_f, $out_f ) = @ARGV;

open IN, $in_f or die "Cannot open $in_f.\n";
open DATA, $data_f or die "Cannot open $data_f.\n";
open OUT, ">$out_f" or die "Cannot oepn $out_f.\n";

my $data_line = undef;
my @pre_rpkm;
my @cur_rpkm;
my $pre_chr = "chr0";
my $pre_start = 0;
while (<IN>) {
	chomp;
	my @in_line = split;
	my $diff = 100;
	if ( ($in_line[0] eq $pre_chr) && ($in_line[1] < $pre_start + 10000) ) {
		$diff = ($in_line[1] - $pre_start) / 100;
		for (my $i = 0; $i < 100-$diff; $i++) {
			$cur_rpkm[$i] = $pre_rpkm[$i+$diff];
			print OUT "$cur_rpkm[$i]\t";
		}
	}
	for (my $i = 100-$diff; $i < 100; $i++) {
		my $area = 0;
		for (my $j = 0; $j < 100; $j++) {
			my $coord  = $in_line[1] + ($i * 100) + $j;
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
		$cur_rpkm[$i] = $area / 100;
		print OUT "$cur_rpkm[$i]";
		print OUT "\t" unless ($i == 99);
	}
	print OUT "\n";
	@pre_rpkm = @cur_rpkm;
	$pre_chr = $in_line[0];
	$pre_start = $in_line[1];
}

close OUT;
close DATA;
close IN;

exit;
