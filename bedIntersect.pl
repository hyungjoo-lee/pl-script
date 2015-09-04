#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <bedIntersect log file> \n";

die $usage unless @ARGV;

my ($in_f) = @ARGV;
open IN, $in_f or die "Cannot open $in_f file.\n";
my @pre = ("", "");
my $overlap = 0;
my $done = 0;
while (<IN>) {
	chomp;
	my @line = split /\s/;
	if ( ($pre[0] eq $line[2]) && ($pre[1] == $line[3]) ) {
		$overlap += $line[11];
		$done = 1 if ($overlap >= 0.5);
	} else {
		print "$line[2]\t$line[3]\t$line[4]\n" if ($done == 1);
		@pre = ($line[2], $line[3]);
		$overlap = 0;
		$done = 0;
	}
}
close IN;
exit;
