#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <probe bwt file> <NimbleScan value file> <bed file>\n";

die $usage unless @ARGV;

my ($bwt_f, $val_f, $bed_f) = @ARGV;
my $bedGraph_f = $bed_f."Graph";
open IN, $bwt_f or die "Cannot open $bwt_f file.\n";
my %probe_id;
while (<IN>) {
	chomp;
	my @line = split;
	my $probe_id = $line[0];
	my $chr = $line[2];
	my $start = $line[3];
	my $end = $start + length($line[4]);
	$probe_id{$probe_id} = "$chr\t$start\t$end";
}
close IN;

open OUT, ">$bed_f" or die "Cannot open $bed_f file.\n";
open IN, $val_f or die "Cannot open $val_f file.\n";
while (<IN>) {
	chomp;
	next unless /^CHR/;
	my @line = split;
	my ($probe_id, $val) = @line;
	next unless (exists $probe_id{$probe_id});
	print OUT "$probe_id{$probe_id}\t$val\n";
}
close IN;
close OUT;

system "bedSort $bed_f $bed_f";



exit;
