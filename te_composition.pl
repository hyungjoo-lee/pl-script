#!/usr/bin/perl -w
use strict;

if (@ARGV != 1) {
	die "\n Usage: perl $0 rmsk.txt\n";
}

open IN, "<", $ARGV[0];
my %te_class;
my %te_family;
my %cnt_class;
my %cnt_family;
my $total_length;
my $total_cnt;
while ( <IN>) {
	my @line = split;
	$cnt_class{$line[11]}++;
	$cnt_family{$line[12]}++;
	my $length = $line[7] - $line[6];
	$te_class{$line[11]} += $length;
	$te_family{$line[12]} += $length;
	$total_length += $length;
	$total_cnt++;
}
close IN;

my $out_f = "out_rmsk.txt";
open OUT, ">$out_f";
print OUT "name\ttotal length (percentage in the genome)\t(number of elements)\n";
print OUT "===TE class===\n";
for my $key (sort keys %te_class) {
	my $percent = $te_class{$key} / 1412464843 * 100;
	print OUT "$key\t$te_class{$key} ($percent%)\t($cnt_class{$key})\n";
}
print OUT "\n===TE family===\n";
for my $key (sort keys %te_family) {
	my $percent = $te_class{$key} / 1412464843 * 100;
	print OUT "$key\t$te_family{$key} ($percent%)\t($cnt_family{$key}\n";
}
close OUT;
my $percent = $total_length / 1412464843 * 100;
print OUT "total:\t $total_length ($percent%)\t($total_cnt)\n";
