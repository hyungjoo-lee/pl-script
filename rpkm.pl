#!/usr/bin/perl -w
use strict;

if (@ARGV != 1) {
	die "\n Usage:perl $0 <<bed file>\n";
}

my %chr_size;
open CHR, "</home/hyungjoo/zebrafish/Zv9_data/chr.size" || die "Cannot open chr.size.\n";
while (<CHR>) {
	chomp;
	my @line = split;
	$chr_size{$line[0]} = $line[1];
}
close CHR;

open IN, "<$ARGV[0]";
my %cnt;
while (<IN>) {
	my @line = split;
	next if ($line[0] eq "chrM");
	my $coord = ($line[1] + $line[2]) / 2000;
	$coord =~ s/\.\d*$//;
	$coord = $line[0].$coord;
	$cnt{$coord}++;
}
close IN;

my $reads = 28883584; ## change
$reads = $reads / 1000000;
my $out_f = "rpkm_".$ARGV[0];
open OUT, ">$out_f";

for my $key (sort keys %chr_size) {
	next if ($key eq "chrM");
	my $window = $chr_size{$key} / 1000;
	$window =~ s/\.\d*$//;
	for (my $i=0; $i <= $window; $i++) {
		my $start = $i * 1000;
		my $end = ($i == $window) ? $chr_size{$key} : $start + 1000;
		my $current_wndw = $key.$i;
		my $rpkm = (exists $cnt{$current_wndw}) ? ($cnt{$current_wndw} / $reads) : 0;
		print OUT "$key\t$start\t$end\t$rpkm\n";
	}
}	
close OUT;

