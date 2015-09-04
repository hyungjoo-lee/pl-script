#!/usr/bin/perl -w
# This generates AUC profiles (chromatin marks or any other data) of certain coordinates (DMRs).
# November 6, 2012 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed file> <score bedGraph> <number of reads> <out file>\n";

die $usage unless @ARGV;

my ($in_f, $data_f, $reads, $out_f ) = @ARGV;

$reads /= 1000000;

open IN, $in_f or die "Cannot open $in_f.\n";
open DATA, $data_f or die "Cannot open $data_f.\n";
open OUT, ">$out_f" or die "Cannot oepn $out_f.\n";

my $data_line = undef;
while (<IN>) {
	chomp;
	my @in_line = split;
	for (my $i = 0; $i < 200; $i++) {
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
		my $rpkm = $area / (50*$reads*50/1000);
		print OUT "$rpkm";
		print OUT "\t" unless ($i == 199);
	}
	print OUT "\n";
}

close OUT;
close DATA;
close IN;

exit;
