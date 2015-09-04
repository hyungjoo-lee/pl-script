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
	$dmr{$coord} = $line[3];
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
		die "Something worng\n" unless (defined $dmr_id{$coord});
		print OUT "$line[0]\t$line[1]\t$line[2]\t$dmr_id{$coord}\n";
		}
	}
	close IN;
	close OUT;
}
exit;

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
# Header
print OUT "chr\tstart\tend\tDMR#\t";
for (my $i = 0; $i < @name; $i++) {
	print OUT "$name[$i]\t";
}
print OUT "\n";

# DMRs
for (my $i = 0; $i < @dmr; $i++) {
	my $dmr_cnt = $i + 1;
	my ($chr, $start) = split ":", $dmr[$i];
	my $end = $start + 500;
	printf OUT "$chr\t$start\t$end\t%d\t", $i+1;
	my @id = split ":", $dmr_which{$dmr[$i]};
	my %id;
	for (my $j = 0; $j < @id; $j++) {
		$id{$id[$j]} = 1;
	}
	for (my $j = 0; $j < @name; $j++) {
		if ( exists $id{"+$name[$j]"} ) {
			print OUT "1\t";
		} elsif ( exists $id{"-$name[$j]"}) {
			print OUT "-1\t";
		} else {
			print OUT "0\t";
		}
	}
	print OUT "\n";
}
close OUT;
exit;
