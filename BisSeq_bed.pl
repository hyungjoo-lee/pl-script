#!/usr/bin/perl -w
# May 20, 2013
# Author: Hyung Joo Lee

use strict;
my $usage = "Usage: $0 <CpG bed file> <BisSeq bed file> <output file base>\n";
die $usage unless @ARGV;

my ($cpg_f, $in_f, $out_f) = @ARGV;
my $tmp_f = "tmp.$$";

my %cpg;
my $cpg = 0;
open CPG, $cpg_f or die "Cannot open $cpg_f file.\n";
my $chr = "";
while (<CPG>) {
	my @line = split;
	my $coord = $line[0].":".$line[1];
	if ($line[0] ne $chr) { $cpg = 0; $chr = $line[0] }
	$cpg++;
	$cpg{$coord} = "$chr.$cpg";
}
close CPG;

my %methylC;
open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my ($chr, $start, $end, $strand, $val) = @line;
	my $coord = ($strand eq "+")? "$chr:$start" : $chr.":".($start-1);
	next unless (exists $cpg{$coord});
	if (!exists $methylC{$coord}) {
		$methylC{$coord} = $val;
	} else {
		$methylC{$coord} += $val;
		$methylC{$coord} /= 2;
	}
}
close IN;

open OUT, ">$tmp_f" or die "Cannot open $tmp_f.\n";
for (keys %methylC) {
	my @line = split ":";
	$line[2] = $line[1] + 2 ;
	$line[3] = $cpg{$_};
	$line[4] = $methylC{$_};
	print OUT join("\t", @line), "\n";
}
close OUT;

system "bedSort $tmp_f $out_f";
unlink $tmp_f;
exit;
