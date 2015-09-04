#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <MnM DMR ID bed TSS file> <all gene RNA RPKM file> <new RNA rpkm file>\n" unless @ARGV;

my ($id_f, $in_f, $out_f) = @ARGV;
my %id;

open ID, $id_f or die "Cannot open $id_f file.\n";
while (<ID>) {
	chomp;
	my @line = split;
	$id{$line[5]} = 1;
	}
close ID;

open IN, $in_f or die "Cannot open $in_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
while (<IN>) {
	my @line = split;
	my $name = $line[0];
	print OUT if (exists $id{$name});
}
close IN;
close OUT;
exit;
