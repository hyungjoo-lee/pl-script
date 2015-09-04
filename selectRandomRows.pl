#!/usr/bin/perl -w
use strict;

die "\n Usage:perl $0 <number of selection> <input data file> STD OUT > output\n" unless @ARGV;

my ($selection, $in_f) =@ARGV;
my %data;
my $row = 0;

open IN, $in_f or die "Cannot open $in_f file.\n";
while (<IN>) {
	$data{$row} = $_;
	$row++;
}
close IN;

my %done;
my $rand_row = int(rand($row));
for (my $i=0; $i<$selection; $i++) {
	$rand_row = int(rand($row)) while (exists $done{$rand_row});
	print $data{$rand_row};
	$done{$rand_row}=1;
}
exit;
