#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <MnM generated bed file>\n" unless @ARGV;
my ($in_f) = @ARGV;
my $name = $in_f;
$name =~ s/.bed$//;

open OUT, ">$name.bedGraph" or die "Cannot open $name.bedGraph file.\n";
open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
	my @line = split;
	next if /qvalue/;
	my ($Ts, $qvalue) = @line[10,11];
	$qvalue = 1e-99 if ($qvalue == 0);
	my $log_qval = 0 - log($qvalue)/log(10);
	$log_qval = 0 - $log_qval if ($Ts > 0);
	print OUT "$line[0]\t$line[1]\t$line[2]\t$log_qval\n" unless ($log_qval == 0) ;
}
close IN;
close OUT;

system "bedGraphToBigWig $name.bedGraph /data/genomes/danRer7/chr.size $name.bigWig";
exit;
