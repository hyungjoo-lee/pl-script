#!/usr/bin/perl -w
# refFlat2bed6.pl generates bed6 file from refFlat.txt file
# Author: Hyung Joo Lee
# June 20, 2012

use strict;

my $usage = "Usage: perl $0 <refFlat.txt>";
die "$usage" unless @ARGV;

my ($in_f) = @ARGV;
my $tmp_f = "tmp.$$";

open GENE, $in_f or die "Cannot open refFlat.txt.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f.\n";
while (<GENE>) {
	next if /^WITHDRAWN/;
	chomp;
	my @line = split;
#	my $start = ($line[3] eq "+") ? $line[4]-8000 : $line[5]-3000;
#	my $end = ($line[3] eq "+") ? $line[4]+3000 : $line[5]+8000;
#	next if ($start <0) ;
	print OUT "$line[2]\t$line[4]\t$line[5]\t$line[1]\t0\t$line[3]\n";
}
close OUT;
close GENE;
system "bedSort $tmp_f refFlat.bed";
unlink $tmp_f;
