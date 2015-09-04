#!/usr/bin/perl -w
# This generates AUC profiles (chromatin marks or any other data) of certain coordinates (DMRs).
# September 26, 2012 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed file> <score bedGraph> <out file>\n";

die $usage unless @ARGV;

my ($in_f, $data_f, $out_f ) = @ARGV;

open IN, $in_f or die "Cannot open $in_f.\n";
open DATA, $data_f or die "Cannot open $data_f.\n";
open OUT, ">$out_f" or die "Cannot oepn $out_f.\n";

my $data_line = undef;
while (<IN>) {
	chomp;
	my @in_line = split;
	my $area = 0;
	my @coord;
	for (my $i = 0; $i < 500; $i++) {
		$coord[$i] = $in_line[1] + $i;
		my $done = 0;
		while ( !$done ) {
			last if eof(IN);
			$data_line = <IN> if !defined($data_line) ;
			my @data_line = split "\t", $data_line;
			last if $data_line =~ /^chrM/;
			if ( ( $in_line[0] eq $data_line[0] ) &&
			     ( $coord[$i] >= $data_line[1] ) &&
			     ( $coord[$i] < $data_line[2] ) )
			{	$area += $data_line[3];
                                $done = 1;
                        } elsif ( ( $in_line[0] lt $data_line[0] ) ||
                                  ( $in_line[0] eq $data_line[0] && $coord[$i] < $data_line[1]) )
			{       $done = 1;
			} else {
				$data_line = undef;
				next;
			}
		}
	}
	print OUT "$_\t$area\n";
}

close OUT;
close DATA;
close IN;

exit;

##############
##Subroutines#
##############

sub get_chr_size {
        my ( $chr_r, $file ) = @_;
        my $size = 0;
        open ( IN, $file ) || die "Cannot open $file.";
        while ( <IN> ) {
                chomp;
                my @line = split;
                $chr_r -> {$line[0]} = $line[1];
                $size += $line[1];
        }
        close IN;
        return $size;
}

