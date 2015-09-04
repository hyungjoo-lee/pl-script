#!/usr/bin/perl -w
use strict;

die "\n Usage:perl $0 <CCGG.bed file> <MRE bedGraph file>\n" unless @ARGV;

my ($cg_f, $in_f, $mre_c) = @ARGV;

my %cpg;
open CG, $cg_f or die "Cannot open $cg_f file.\n";
while (<CG>) {
#	next if /^(Zv9)|(chrM)/;
	my @line = split;
#	my $coord = $line[0].":".$line[1];
	my $coord = $line[0].":".($line[1]+1);
	$cpg{$coord} = 0;
}
close CG;

my %mre;
open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
#	next if /^(Zv9)|(chrM)/;
	chomp;
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$mre{$coord} = $line[3];
}
close IN;

my ($cnt_cg, $cnt_mre, $cnt_mecg) = (0, 0, 0);
#my $mre_c = 20;
print "=DNA methylation criteria for CCGG sites=\n";
printf "  0 DNA methylation: MRE score > %3d\n", $mre_c;
printf "100 DNA methylation: MRE score <   0\n";

for my $coord (keys %cpg) {
	my $meth;
	if (exists $mre{$coord}) {
		$meth = 1 - ($mre{$coord} / $mre_c);
		$meth = 0 if ($meth < 0);
		$cnt_mre++;
	} else {
		$meth = 1;
	}
	$cnt_mecg += $meth;
	$cnt_cg++;
}

printf "$in_f\t%.2f\n", ($cnt_mecg * 100 / $cnt_cg);
exit;
