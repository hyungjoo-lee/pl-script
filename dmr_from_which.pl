#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <DMR bed file> <MnM DMR bed files> <output file> \n" unless @ARGV;

my $dmr_f = shift @ARGV;
my $out_f = pop @ARGV;
my @in_f = @ARGV;

my @dmr;
my $cnt = 0;
open DMR, $dmr_f or die "Canot open $dmr_f file.\n";
while (<DMR>) {
	my @line = split;
	my $coord = $line[0].":".$line[1];
	$dmr[$cnt] = $coord;
	$cnt++;
}
close DMR;

my %dmr_which;
my %id;
for (my $i = 0; $i < @in_f; $i++) {
	open IN, $in_f[$i] or die "Cannot open $in_f[$i] file.\n";
	my $number = $i+1;					## DMR from which comparison (1~N)
	while (<IN>) {
		next if /chrSt/;
		chomp;
		my @line = split;
		my $coord = $line[0].":".$line[1];
		$number = -$number if ( $line[10] > 0 );	## demethylated DMR with - signal
		if (defined $dmr_which{$coord}) {
			$dmr_which{$coord} .= ", $number";
			$id{$coord}++;				## DMRs identified more than once
		} else {
			$dmr_which{$coord} = $number;
		}
	}
	close IN;
}

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
print OUT "#DMR\tchr\tstart\tend\tID_stage\tIDs(>1)\n";
for (my $i = 0; $i < @dmr; $i++) {
	my $dmr_cnt = $i + 1;
	my ($chr, $start) = split ":", $dmr[$i];
	my $end = $start + 500;
	my $id = $dmr_which{$dmr[$i]};
	print OUT "$dmr_cnt\t$chr\t$start\t$end\t$id";
        if (exists $id{$dmr[$i]}) {
		my $ids = $id{$dmr[$i]} + 1;
		print OUT "\t$ids";
	}
	print OUT "\n";
}
close OUT;
exit;
