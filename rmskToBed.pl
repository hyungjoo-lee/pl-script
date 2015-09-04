#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <rmsk file> <bed file>\n";

die $usage unless @ARGV;

my ($in_f, $out_f) = @ARGV;
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
open IN, $in_f or die "Cannto open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split /\t/;
	my ($chrom, $chromStart, $chromEnd, $name, $strand, $class) = ($line[5], $line[6], $line[7], $line[10], $line[9], $line[11]);
	next unless ($class =~ /(DNA)|(LINE)|(LTR)|(Satellite)|(SINE)/);
	print OUT "$chrom\t$chromStart\t$chromEnd\t$name\t0\t$strand\n";
}
close IN;
close OUT;
exit;
