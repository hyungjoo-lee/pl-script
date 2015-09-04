#!/usr/bin/perl -w
use strict;

die "\n Usage:perl $0 <genome> <cpg.bed files> <output.bed>\n" unless @ARGV;

my $genome = shift @ARGV;
my $out_f = pop @ARGV;
my @in_f = @ARGV;
my @tmp_f;
my @lib_name;
my $cpg_f;

if ($genome eq "danRer7") {
	$cpg_f = "/data/genomes/danRer7/MRE/all_sites-scaffolds.bed";
} else {
	die "Cannot find genome. Now only danRer7 available.\n";
}

my %cpg;
open CPG, $cpg_f or die "Cannot open CpG_sites.bed file.\n";
while (<CPG>) {
	next if /^(Zv9)|(chrM)/;
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$cpg{$coord} = 1;
}
close CPG;

my $paste = "paste ";
for (my $i = 0; $i < @in_f; $i++) {
	$tmp_f[$i] = "tmp$i.$$";
	$lib_name[$i] = $in_f[$i];
	$lib_name[$i] =~ s/\.CpG\.bedGraph$//;
	open IN, $in_f[$i] or die "Cannot open $in_f[$i] file.\n";
	my %mre;
	while (<IN>) {
		next if /^(Zv9)|(chrM)/;
		chomp;
		my @line = split;
		my $coord = $line[0].":".$line[1];
		$mre{$coord} = $line[3];
	}
	close IN;
	open OUT, ">$tmp_f[$i]" or die "Cannot open $tmp_f[$i] file.\n";
#	print OUT "#chr\t" if ($i == 0);
	print OUT "$lib_name[$i]\n";
	for my $key (sort keys %cpg) {
		my @line = split /:/, $key;
#		print OUT "$line[0]\t" if ($i == 0);
		print OUT (exists $mre{$key})? "$mre{$key}\n" : "0\n";
	}
	close OUT;
	$paste .= "$tmp_f[$i] ";
}

$paste .= ">$out_f";
system $paste;
unlink @tmp_f;
exit;
