#!/usr/bin/perl -w
use strict;

die "\n Usage:perl $0 <MeDIP bedGraph file>\n" unless @ARGV;

my ($in_f) = @ARGV;

my ($cnt_cg, $cnt_mecg) = (0, 0);
my ($medip_c1, $medip_c2) = (1, 25);

open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $meth = ($line[3]- $medip_c1) / ($medip_c2 - $medip_c1);
	$meth = 1 if ($meth > 1);
	$meth = 0 if ($meth < 0);
	$cnt_cg++;
	$cnt_mecg += $meth;
}
close IN;

printf "Total number of MRE sites from $in_f\t%10d\n", $cnt_cg;
printf "Global DNA methylation level from $in_f\t%.2f\n", ($cnt_mecg * 100 / $cnt_cg);
exit;
