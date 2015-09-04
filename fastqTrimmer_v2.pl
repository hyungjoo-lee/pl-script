#!/usr/bin/perl -w

## This code trims the last $length base callings in fastq files.
## 

use strict;

die "\n Usage: perl $0 <reads.fastq>" unless @ARGV;

my ($in_f) = @ARGV;
my $out_f = "tmp.$$";

my $cnt = 0;
my $line;
my $length;
open (IN, $in_f) or die "Cannot open $in_f file.\n";
open (OUT, ">$out_f") or die "Cannot open $out_f file.\n";
while (<IN>) {
	$cnt++;
	if ($cnt % 4 == 1) {
		$line = $_;
	} elsif ($cnt % 4 == 2) {
		chomp;
		$line .= $_;
	} elsif ($cnt % 4 == 0) {
		chomp;
		$length = length;
		if (s/#+$//) {
			$length -= length;
			$line = substr $line, 0, -$length;
		}
		$line .= "\n+\n$_\n";
		print OUT $line;
		$line = "";
		$cnt = 0;
	}
}
close OUT;;
close IN;
system "mv $out_f $in_f";
exit;
