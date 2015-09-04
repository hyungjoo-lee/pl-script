#!/usr/bin/perl -w
use strict;

die "\n Usage:perl $0 <MeDIP bed file> <output.bed>\n" unless @ARGV;

my ($in_f, $out_f) =@ARGV;

open IN, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
while (<IN>) {
	my @line = split;
	my $length = $line[2] - $line[1];
	next if ($length > 500);
	print OUT;
}
close IN;
close OUT;

exit;
