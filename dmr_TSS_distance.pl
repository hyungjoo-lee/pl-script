#!/usr/bin/perl -w
# This calculates distance of DMRs from the closest TSS (ensGene).
# March 5, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <ensGeneTSS.bed> <bedSorted DMR file> <output DMR file>\n";

die $usage unless @ARGV;

my ($tss_f, $dmr_f, $out_f) = @ARGV;

my %tss;

open TSS, $tss_f or die "Cannot open $tss_f file.\n";
while (<TSS>) {
	chomp;
	my @line = split;
	$tss{"$line[0]".":"."$line[1]"} = "$line[5]".":"."$line[3]";
}
close TSS;

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
open DMR, $dmr_f or die "Cannot open $dmr_f file.\n";
while (<DMR>) {
	next if /DMR/;
	chomp;
	my @dmr_line = split;
	my $dmr_coord = ($dmr_line[1] + $dmr_line[2]) / 2 ;
	my $distance = 77276063;		## maximum chromosome length
	my $ensgene;
	for my $key (keys %tss) {
		my ($tss_chr, $tss) = split ":", $key;
		my ($strand, $name) = split ":", $tss{$key};
		if ($tss_chr eq $dmr_line[0]) {
			my $cur_dist = ($strand eq "+") ? ($dmr_coord - $tss) : ($tss - $dmr_coord) ;
			if ( abs($distance) >= abs($cur_dist) ) {
				$distance = $cur_dist;
				$ensgene = $name;
			}
		}
	}
	print OUT "$_\t$distance\t$ensgene\n";
}
close DMR;
close OUT;
exit;
