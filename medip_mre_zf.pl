#!/usr/bin/perl -w
use strict;

if (@ARGV != 3) {
	die "\n Usage:perl $0 <MeDIP-seq bedGraph file> <MRE-seq CpG.bedGraph file> <output flie>\n";
}

my %cpg;
open CPG, "/data/genomes/danRer7/MRE/CpG_sites.bed" || die "Cannot open CpG_sites.bed file.\n";
while (<CPG>) {
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$cpg{$coord} = 1;
}
close CPG;

open MRE, "<$ARGV[1]";
my %mre;
while (<MRE>) {
        chomp;
        my @line = split;
        next if ($line[0] eq "chrM");
        my $coord = $line[0].":".$line[1];
        $mre{$coord} = $line[3];
}
close MRE;

open MEDIP, "<$ARGV[0]";
my %medip;
while (<MEDIP>) {
	chomp;
	my @line = split;
	next if ($line[0] eq "chrM");
	for ($line[1]..$line[2]-1) {
		my $coord = $line[0].":".$_;
		$medip{$coord} = $line[3] if (exists $cpg{$coord});
	}
}
close MEDIP;

open OUT, ">$ARGV[2]";
for my $key (sort keys %cpg) {
	my @line = split /:/, $key;
	next if ($line[0] eq "chrM");
	$line[2] = (exists $medip{$key}) ? $medip{$key} : 0;
	$line[3] = (exists $mre{$key}) ? $mre{$key} : 0;
	next unless ($line[2] || $line[3]);
	print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\n";
#	if (exists $medip{$key}) {
#		if (exists $mre{$key}) {
#			print OUT "$line[0]\t$line[1]\t$medip{$key}\t$mre{$key}\n";
#		} else {
#			print OUT "$line[0]\t$line[1]\t$medip{$key}\t0\n";
#		}
#	} elsif (exists $mre{$key}) {
#		print OUT "$line[0]\t$line[1]\t0\t$mre{$key}\n";
#	}
}	
close OUT;

