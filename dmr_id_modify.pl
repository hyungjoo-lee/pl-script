#!/usr/bin/perl -w
use strict;

die "perl $0 <input DMR_ID.bed> <output DMR_ID.bed>\n" unless @ARGV;

my ($in_f, $out_f) = @ARGV;

open IN, $in_f or die "Cannot open $in_f\n";
open OUT, ">$out_f" or die "Cannot open $out_f\n";
while (<IN>) {
	my @line = split;
	next if ( ($line[4] == 0) && ($line[5] == 0) && ($line[6] == 0) && ($line[7] == 0) );
	print OUT;
}
close OUT;
close IN;
exit;
