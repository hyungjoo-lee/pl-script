#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <transcriptome bed file> <new coordinate bed file (promoter TSS+-2kb)> \n" unless @ARGV;

my ($in_f, $out_f) = @ARGV;
my $tmp_f = "tmp.$$";

open IN, "$in_f" or die "Cannot open $in_f file.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f file.\n";
while (<IN>) {
	next if /^Zv9/;
	chomp;
	my @line = split;
	my ($chr, $start, $end, ) = @line;
	my $strand = $line[5];
	if ($strand eq "+") {
		$end = $start + 2000;
		$start -= 2000;
	} elsif ($strand eq "-") {
		$start = $end - 2000;
		$end += 2000;
	}
	$start = 0 if ($start < 0);
	print OUT "$chr\t$start\t$end\t0\t0\t$strand\n";
}
close IN;
close OUT;
system "bedSort $tmp_f $tmp_f";

open IN, "$tmp_f" or die "Cannot open $tmp_f file.\n";
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
my @pre_line = ("", "", "");
while (<IN>) {
	my @line = split;
	if ( ($line[0] eq $pre_line[0]) && ($line[1] == $pre_line[1]) ) {
		if ($line[2] == $pre_line[2]) {
			next;
		} elsif ($line[2] > $pre_line[2]) {
			$pre_line[2] = $line[2];
			next;
		}
	} elsif ( ($line[0] eq $pre_line[0]) && ($line[1] < $pre_line[2]) ) {
		$pre_line[2] = $line[2];
		next;
	} else {
		print OUT "$pre_line[0]\t$pre_line[1]\t$pre_line[2]\t0\t0\t+\n" unless ($pre_line[0] eq "");
		@pre_line = @line;
	}
}
close IN;
print OUT "$pre_line[0]\t$pre_line[1]\t$pre_line[2]\t0\t0\t+\n";
close OUT;
unlink $tmp_f;
exit;

