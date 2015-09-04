#!/usr/bin/perl -w
# This scripts generates DMR distribution of mCRF differences.
# Author: Hyung Joo Lee
# Edited on June 25, 2013

use strict;

die "Usage: perl $0 <DMR mCRF diff score txt file> STDOUT > distribution \n" unless @ARGV;

my ($in_f, ) = @ARGV;
my @cnt;
my $cnt = 0;
my @c;
for (my $i = 0; $i < 101; $i++) {
	$c[$i] = ($i-50)*0.02;
}

open IN, "$in_f" or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	$cnt++;
	for (my $i = 0; $i < @c-1; $i++) {
		if ( ($_ >= $c[$i]) && ($_ < $c[$i+1]) ) {
			$cnt[$i]++;
			last;
		}
	}
}
close IN;

for (my $i = 0; $i < @c-1; $i++) {
	$cnt[$i] = 0 unless ( defined $cnt[$i]);
	printf "$cnt[$i]\t%.5f\n", $cnt[$i]/$cnt;
}
exit;
