#!/usr/bin/perl -w
# This perl script generates bed6 file from cpgIslandExt.txt file
# Author: Hyung Joo Lee
# March 26, 2013

use strict;

my $usage = "Usage: perl $0 <cpgIslandExt.txt> <output bed6 file>";
die $usage unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my $tmp_f = "tmp.$$";

open CGI, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f file.\n";
while (<CGI>) {
	next if /Zv9_/;
	chomp;
	my @line = split /\t/;
	my ($chrom, $chromStart, $chromEnd, $name) = @line[1..4];
	print OUT "$chrom\t$chromStart\t$chromEnd\t$name\t0\t+\n";
}
close OUT;
close CGI;
system "bedSort $tmp_f $out_f";
unlink $tmp_f;
