#!/usr/bin/perl -w
use strict;

## Cacluate average fragment size of MeDIP-seq from PE bed file 

die "\nUsage: perl $0 <bed file>\n" unless (@ARGV == 1) ;

my $in_f = shift @ARGV;
my $out_f = $in_f;
$out_f =~ s/\.bed$/.length/;
my $rep_f = $out_f.".log";

my ( $total, $cnt ) = ( 0, 0 );
my %hist;

open (IN, $in_f) or die "Cannot open $in_f.\n";
open (OUT, ">$out_f") or die "Cannot open $out_f.\n";
while ( <IN> )
{
	my @line = split;
        my $length = $line[2] - $line[1];
	print OUT "$length\n";
	$total += $length;
	$cnt++;
	my $index = int ($length / 5);
	$hist{$index}++;
}
close OUT;
close IN;

my $average = $total / $cnt;
open (REPORT, ">$rep_f") or die "Cannot open $rep_f.\n";
print REPORT "\nThe total length of MeDIP fragment is $total.\n";
print REPORT "The average size of MeDIP fragment from $in_f is $average.\n";
print REPORT "fragment size distribution:\nFrom\tTo\tSize\tCount\tPercent\n";
for my $key (sort { $a <=> $b } keys %hist) {
	my $percent = $hist{$key} / $cnt * 100;
	printf REPORT "%3d\t%3d\t%3d\t%10d\t%4.2f%%\n", 5*$key, 5*$key+4, 5*$key+2, $hist{$key}, $percent;
}
close REPORT;
exit;
