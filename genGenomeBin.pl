#!/usr/bin/perl -w
use strict;

my $usage = '
Usage: perl genGenomeBin.pl <genome> <size>
	genome: hg19, danRer7
	size: in bp
';

die $usage unless @ARGV;

my ($genome, $binSize) = @ARGV;
my $out_f = $genome."_$binSize.bed";
my $chrSize_f;
my %chr_size;

if ( $genome eq "hg19" ) {
	$chrSize_f = "/data/genomes/hg19/chr.size";
} elsif ( $genome eq "danRer7" ) {
	$chrSize_f = "/data/genomes/danRer7/chr.size";
} else {
	die "$genome: The genome is not supproted yet.\n";
}

open IN, "<$chrSize_f" or die "Cannot open $chrSize_f file.\n";
while (<IN>) {
	chomp;
	next if /Zv9/;
	next if /chrM/;
	my @line = split;
	$chr_size{$line[0]} = $line[1];
}
close IN;

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
for my $key (sort keys %chr_size) {
	my $bin = $chr_size{$key} / $binSize;
	$bin = int $bin;
	for (my $i=0; $i <= $bin; $i++) {
		my $start = $i * $binSize;
		my $end = ($i == $bin) ? $chr_size{$key} : $start + $binSize;
		print OUT "$key\t$start\t$end\n";
	}
}	
close OUT;
system "bedSort $out_f $out_f";
exit;
