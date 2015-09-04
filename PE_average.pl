#!/usr/bin/perl -w
use strict;

## Cacluate average fragment size of MeDIP-seq from PE bed file 

die "\nUsage: perl $0 <bed file>\n" if (@ARGV != 1) ;

my $in_f = $ARGV[0];
my $out_f = $in_f;
my $report_f;
$out_f =~ s/\.bed$/.length/;
$report_f = $out_f.".report";

my ( $total, $cnt ) = ( 0, 0 );
my %hist;

open (IN, $in_f) || die "Cannot open $in_f.\n";
open (OUT, ">$out_f") || die "Cannot open $out_f.\n";
while ( <IN> )
{
	my @line = split;
        my $length = $line[2] - $line[1];
	print OUT "$length\n";
	$total += $length;
	$cnt++;
	my $index = int ($length / 20);
	$hist{$index}++;
}

my $average = $total / $cnt;
open (REPORT, ">$report_f") || die "Cannot open $report_f.\n";
print REPORT "The average size of MeDIP fragement from $in_f is $average.\n";
print REPORT "fragment size distribution:\nScale\tCount\tPercent\n";
for my $key (sort { $a <=> $b } keys %hist) {
	my $percent = $hist{$key} / $cnt * 100;
	printf REPORT "%s-%s\t%10d\t%4.2f%%\n", 20*$key, 20*($key+1), $hist{$key}, $percent;
}

