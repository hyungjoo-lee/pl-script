#!/usr/bin/perl -w
# This calculates distance of DMRs from the closest TSS (ensGene).
# March 5, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <ensGeneTSS.bed> <bedSorted DMR file> <output DMR file>\n";

die $usage unless @ARGV;

my ($tss_f, $dmr_f, $out_f) = @ARGV;

my %cnt;

open DMR, $dmr_f or die "Cannot open $dmr_f file.\n";
open TSS, $tss_f or die "Cannot open $tss_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
my $tss_line = undef;
while (<DMR>) {
	next if /DMR/;
	chomp;
	my @dmr_line = split;
	my $dmr_coord = ($dmr_line[1] + $dmr_line[2]) / 2 ;
	my $distance = 77276063;		## maximum chromosome length
	my $name;
	my $done = 0;
	while (!$done) {
		$tss_line = <TSS> if !defined($tss_line);
		chomp $tss_line;
		my @tss_line = split /\t/, $tss_line;
		$done = 1 if ( eof(TSS) );
 		if ( $dmr_line[0] eq $tss_line[0] ) {
			my $cur_dist = ($tss_line[5] eq "+") ? ($dmr_coord - $tss_line[1]) : ($tss_line[1] - $dmr_coord) ;
			if ( abs($distance) >= abs($cur_dist) ) {
				$distance = $cur_dist;
				$name = $tss_line[3];
				$tss_line = undef;
			} else {
				$done = 1;
			}
		} elsif ( $dmr_line[0] gt $tss_line[0] ) {
			$tss_line = undef;
		} elsif ( $dmr_line[0] lt $tss_line[0] ) {
			$done = 1;
		}
	}
	print OUT "$_\t$distance\t$name\n";
}
close TSS;
close DMR;
close OUT;
exit;
