#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <DMR_ID bed file> <DMR bed files by stage> \n" unless @ARGV;

my $dmr_f = shift @ARGV;
my @in_f = @ARGV;

my %dmr_id;
open DMR, $dmr_f or die "Canot open $dmr_f file.\n";
while (<DMR>) {
	next if /DMR/;
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$dmr_id{$coord} = $line[3];
}
close DMR;

my @out_f = @in_f;
for (my $i = 0; $i < @in_f; $i++) {
	open IN, $in_f[$i] or die "Cannot open $in_f[$i] file.\n";
	$out_f[$i] =~ s/.bed$/_ID.bed/;					## out file name
	open OUT, ">$out_f[$i]" or die "Cannot open $out_f[$i] file.\n";
	while (<IN>) {
		chomp;
		my @line = split;
		my $coord = $line[0].":".$line[1];
		die "Something worng: $coord not found\n" unless (defined $dmr_id{$coord});
		print OUT "$line[0]\t$line[1]\t$line[2]\t$dmr_id{$coord}\n";
	}
	close IN;
	close OUT;
}
exit;
