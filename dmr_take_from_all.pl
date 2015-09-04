#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <MnM DMR ID bed file> <calculated enhancer RPKM file (+-5kb) for all DMRs> <new rpkm file>\n" unless @ARGV;

my ($id_f, $in_f, $out_f) = @ARGV;
my %id;

open ID, $id_f or die "Cannot open $id_f file.\n";
while (<ID>) {
	chomp;
	my @line = split;
	$id{$line[3]} = 1;
	}
close ID;

open IN, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
my $cnt = 0;
while (<IN>) {
	$cnt++;
	print OUT if (exists $id{$cnt});
}
close IN;
close OUT;
exit;
