#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <fasta file> \n";

die $usage unless @ARGV;

my ($fa_f, ) = @ARGV;
open IN, $fa_f or die "Cannto open $fa_f file.\n";
my ($a, $c, $g, $t, $n) = (0, 0, 0, 0, 0);
while (<IN>) {
	chomp;
	next if /chr/;
	my $seq = $_;
	$seq =~ s/^\\//;
	$seq =~ s/\\$//;
	$a += $seq =~ s/[Aa]/A/g;
	$c += $seq =~ s/[Cc]/C/g;
	$g += $seq =~ s/[Gg]/G/g;
	$t += $seq =~ s/[Tt]/T/g;
	$n += length($seq);
}
close IN;
printf "The number of A nucleotide is %d (%.4f).\n", $a, $a/$n;
printf "The number of C nucleotide is %d (%.4f).\n", $c, $c/$n;
printf "The number of G nucleotide is %d (%.4f).\n", $g, $g/$n;
printf "The number of T nucleotide is %d (%.4f).\n", $t, $t/$n;
printf "The number of total nucleotide is %d.\n", $n;
exit;
