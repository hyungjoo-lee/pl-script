#!/usr/bin/perl -w
use strict;

die "\n Usage:perl $0 <genome> <MeDIP bed file> <output.bed>\n" unless @ARGV;

my ($genome, $in_f, $out_f) =@ARGV;
my $cpg_f;

if ($genome eq "danRer7") {
	$cpg_f = "/data/genomes/danRer7/MRE/CpG_sites.bed";
} else {
	die "Cannot find genome. Now only danRer7 available.\n";
}

my %cpg;
open CPG, $cpg_f or die "Cannot open CpG_sites.bed file.\n";
while (<CPG>) {
#	next if /^(Zv9)|(chrM)/;
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$cpg{$coord} = 1;
}
close CPG;

my $cpg_cnt = 0;
my $total_bp_cnt = 0;
open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $length = $line[2] - $line[1];
	$total_bp_cnt += $length;
	my $end;
	my $coord;
	for (my $i=0; $i<$length; $i++) {
		$end = $line[1] + $i;
		$coord = $line[0].":".$end;
		$cpg_cnt++ if ( exists $cpg{$coord} );
	}
}
close IN;

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
print OUT "Result from $in_f\n";
printf OUT "CpG content:\t%15d\n", $cpg_cnt;
printf OUT "total bp:\t%15d\n", $total_bp_cnt;
printf OUT "CpG content/bp:\t%15f\n", $cpg_cnt/$total_bp_cnt;
close OUT;

exit;
