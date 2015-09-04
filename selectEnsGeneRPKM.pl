#!/usr/bin/perl -w
# This excerpts RPKM data of certain stages from given ensGene list. 
# June 24, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "perl $0 <ensGene RPKM file> <promoterDMR ensGene file> STDOUT > 2 RPKM values \n";

die $usage unless @ARGV;

my ($data_f, $sub_f) = @ARGV;

my %rpkm1;
my %rpkm2;
my %rpkm3;
my %rpkm4;
open IN, $data_f or die "Cannot open $data_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my $gene = $line[0];
	$rpkm1{$gene} = $line[4];
	$rpkm2{$gene} = $line[5];
	$rpkm3{$gene} = $line[6];
	$rpkm4{$gene} = $line[8];
}
close IN;

open IN, $sub_f or die "Cannot open $sub_f file.\n";
my %done;
my $pre_line ="";
my $pre_dmr ="";
while (<IN>) {
	chomp;
	my @line = split;
	my $gene = $line[15];
	my $dmr = join "", @line[4..7];
	my @dmr = split "", $dmr;
	for (my $i=2; $i<14; $i++) {
		next if ($i == 5 || $i== 6 || $i==9 || $i==10 || $i==12 || $i==13);
		next unless ($dmr[$i] =~ /[+-]/);
		my ($stage1, $stage2);
		$stage1 = $rpkm1{$gene} if ($i == 2 || $i== 7 || $i==11);
		$stage1 = $rpkm2{$gene} if ($i == 3 || $i== 8 );
		$stage1 = $rpkm3{$gene} if ($i == 4);
		$stage2 = $rpkm2{$gene} if ($i == 2);
		$stage2 = $rpkm3{$gene} if ($i == 3 || $i==7);
		$stage2 = $rpkm4{$gene} if ($i == 4 || $i==8 || $i==11);
		print "$gene\t";
		print "$stage1\t$stage2\n" if ($dmr[$i] eq "+");
		print "$stage2\t$stage1\n" if ($dmr[$i] eq "-");
		print STDERR "$pre_line\n$_\n" if (exists $done{$gene} && $pre_dmr eq $dmr );
	}
	$done{$gene} = 1;
	$pre_line = $_;
	$pre_dmr = $dmr;
}
close IN;
exit;
