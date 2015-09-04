#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <ndf file> <bed file>\n";

die $usage unless @ARGV;

my ($ndf_f, $bed_f) = @ARGV;
open OUT, ">$bed_f" or die "Cannot open $bed_f file.\n";
open IN, $ndf_f or die "Cannto open $ndf_f file.\n";
while (<IN>) {
	chomp;
	next if /^PROBE/;
	my @line = split /\t/;
	my $probe_class = $line[11];
	next if ($probe_class ne "experimental");
	my $seq_id = $line[4];
	my $probe_sequence = $line[5];
	my $probe_id = $line[12];
	my ($chr, $start, $end) = split /[:-]/, $seq_id;
	print OUT "$chr\t$start\t$end\t$probe_id\t$probe_sequence\n";
}
close IN;
close OUT;
exit;
