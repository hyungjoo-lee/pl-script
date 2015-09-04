#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <DMR bed file> \n" unless @ARGV;

my $in_f = shift @ARGV;

my $out1_f = $in_f;
my $out2_f = $in_f;
$out1_f =~ s/\.bed$/+.bed/;
$out2_f =~ s/\.bed$/-.bed/;

open IN, $in_f or die "Cannot open $in_f file.\n";
open OUT1, ">$out1_f" or die "Cannot open $out1_f file.\n";
open OUT2, ">$out2_f" or die "Cannot open $out2_f file.\n";
while (<IN>) {
	next if /chrSt/;
	next if /chrM/;
	my @line = split;
	print OUT1 if ($line[10] < 0);	## de novo methylation (lower methylation level on sample 1)
	print OUT2 if ($line[10] > 0);	## demethylation (higher methylation level on sample 2)
}
close IN;
close OUT1;
close OUT2;
exit;
