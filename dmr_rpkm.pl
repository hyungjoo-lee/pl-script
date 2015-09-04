#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <DMR bed file> <MnM bed RPKM file> <output file> \n" unless @ARGV;

my ($dmr_f, $in_f, $out_f) = @ARGV;

my @dmr;
my $cnt = 0;
open DMR, $dmr_f or die "Canot open $dmr_f file.\n";
while (<DMR>) {
	my @line = split;
	$dmr[$cnt] = $line[0].":".$line[1];
	$cnt++;
}
close DMR;

open IN, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
$cnt = 0;
while (<IN>) {
	next if /^#/;
	chomp;
	my @line = split;
	my $coord = $line[0].":".$line[1];
	if ($coord eq $dmr[$cnt]) {
		$cnt++;
		my $line = join "\t", @line[3..8];
		print OUT "$line[0]\t$line[1]\t$line[2]\t$cnt\t$line\n";
	}
}
close IN;
close OUT;
exit;
