#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <probe bwt file> <NimbleScan value file> <bed file>\n";

die $usage unless @ARGV;

my ($bwt_f, $val_f, $bed_f) = @ARGV;
my $tmp_f = "tmp.$$";
my $bigwig_f = $bed_f;
$bigwig_f =~ s/bed$/bigWig/;

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

open IN, $bed_f or die "Cannot open $bed_f file.\n";
open OUT, ">$tmp_f" or die "Cannot open $tmp_f file.\n";
my @prev = ("Zv9_0", 0, 0, 0);
while (<IN>) {
	chomp;
	my @line = split;
	if ( ($line[0] eq $prev[0]) && ($line[1] < $prev[2]) ) {
		if ($line[2] <= $prev[2]) {
			next;
		} elsif ($line[2] > $prev[2]) {
			print OUT "$prev[0]\t$prev[1]\t$prev[2]\t$prev[3]\n";
			($prev[1], $prev[2], $prev[3]) = ($prev[2], $line[2], $line[3]);
		}
	} else {
		print OUT "$prev[0]\t$prev[1]\t$prev[2]\t$prev[3]\n" unless ($prev[0] eq "Zv9_0");
		@prev = @line;
	}
}
print OUT "$prev[0]\t$prev[1]\t$prev[2]\t$prev[3]\n";
close OUT;
close IN;

system "bedSort $tmp_f $tmp_f";
system "bedGraphToBigWig $tmp_f /data/genomes/danRer7/chr.size $bigwig_f";
unlink $tmp_f;
exit;

