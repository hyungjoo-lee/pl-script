#!/usr/bin/perl -w
# This converts homer location information txt file into bed file. 
# September 11, 2014
# Author: Hyung Joo Lee

use strict;

my $usage = "perl $0 <DMR bed file with ID || peak file> <homer location information txt file>  > STOUT moitf bed file\n";

die $usage unless @ARGV;

my ($bed_f, $homer_f) = @ARGV;

my %bed;
open IN, $bed_f or die "Cannot open $bed_f file.\n";
while (<IN>) {
	my @line = split;
	$bed{$line[3]} = join ":", @line[0..1];
}
close IN;

open IN, $homer_f or die "Cannot open $homer_f file.\n";
while (<IN>) {
	next if !/^[0-9]/;
	chomp;
	my @line = split "\t";
	my ($chrom, $coord) = split ":", $bed{$line[0]};
	my $chromStart = $coord + $line[1];
	my $chromEnd = $chromStart + length($line[2]);
	my ($name, $strand, $score) = @line[3..5];
	$name .= "_$line[2]_$score";
	$score = ($score-5)*200;
	$score = 1000 if ($score > 1000);
	$score = 0 if ($score < 0);
	$score = sprintf("%d", $score);
	print join "\t", $chrom, $chromStart, $chromEnd, $name, $score, $strand;
	print "\n";
}
close IN;
exit;
