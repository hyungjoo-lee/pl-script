#!/usr/bin/perl -w
use strict;

if (@ARGV != 3) {
	die "\n Usage:perl $0 <cpg.bed file1> <cpg.bed file2> <output.bed>\n";
}

my %cpg;
open CPG, "</home/hyungjoo/genomes/hg19/CpG/CpG_sites.bed" || die "Cannot open CpG_sites.bed file.\n";
while (<CPG>) {
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$cpg{$coord} = 1;
}
close CPG;

open IN, "<$ARGV[0]";
my %mre1;
while (<IN>) {
	chomp;
	my @line = split;
	next if ($line[0] eq "chrM");
	my $coord = $line[0].":".$line[1];
	$mre1{$coord} = $line[3];
}
close IN;

open IN, "<$ARGV[1]";
my %mre2;
while (<IN>) {
	chomp;
        my @line = split;
        next if ($line[0] eq "chrM");
        my $coord = $line[0].":".$line[1];
        $mre2{$coord} = $line[3];
}
close IN;

open OUT, ">$ARGV[2]";
for my $key (sort keys %cpg) {
	my @line = split /:/, $key;
	next if ($line[0] eq "chrM");
	next unless ((exists $mre1{$key}) || (exists $mre2{$key}));
	$line[2] = (exists $mre1{$key}) ? $mre1{$key} : 0;
	$line[3] = (exists $mre2{$key}) ? $mre2{$key} : 0;
	print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\n";
#	if (exists $mre1{$key}) {
#		if (exists $mre2{$key}) {
#			print OUT "$line[0]\t$line[1]\t$mre1{$key}\t$mre2{$key}\n";
#		} else {
#			print OUT "$line[0]\t$line[1]\t$mre1{$key}\t0\n";
#		}
#	} elsif (exists $mre2{$key}) {
#		print OUT "$line[0]\t$line[1]\t0\t$mre2{$key}\n";
#	}
}	
close OUT;

