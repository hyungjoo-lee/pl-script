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
#my %id;
my @name = @in_f;
for (my $i = 0; $i < @in_f; $i++) {
	open IN, $in_f[$i] or die "Cannot open $in_f[$i] file.\n";
	$name[$i] =~ s/^DMR_//;					## DMR from which comparison
	$name[$i] =~ s/.bed$//;
	my $id;
	while (<IN>) {
		next if /chrSt/;
		chomp;
		my @line = split;
		my $coord = $line[0].":".$line[1];
		$id = "-$name[$i]" if ( $line[10] > 0 );	## demethylated DMR with - signal
		$id = "+$name[$i]" if ( $line[10] < 0 );
		if (defined $dmr_which{$coord}) {
			$dmr_which{$coord} .= ":$id";
#			$id{$coord}++;				## DMRs identified more than once
		} else {
			$dmr_which{$coord} = $id;
		}
	}
	close IN;
}

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
