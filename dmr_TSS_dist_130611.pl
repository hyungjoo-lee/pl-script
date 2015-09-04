#!/usr/bin/perl -w
# This calculates distribution of DMRs over the given TSS set.
# June 11, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <TSS set (sorted) bed file> <DMR (sorted) bed file> STDOUT > DMR distribution over TSS\n";

die $usage unless @ARGV;

my ($tss_f, $dmr_f,) = @ARGV;

my %dmr;

open DMR, $dmr_f or die "Cannot oepn $dmr_f file.\n";
while (<DMR>) {
  chomp;
  my @line = split /\t/;
  my $coord = ($line[1] + $line[2]) / 2 ;
  $dmr{"$line[0]:$coord"} = 1;
}
close DMR;

my %cnt_dmr;

open TSS, $tss_f or die "Cannot open $tss_f file.\n";
my $cnt_tss = 0;
while (<TSS>) {
  next if /^Zv/;
  $cnt_tss++;
  chomp;
  my @tss_line = split;
  my ($tss_chr, $tss, $strand) = ($tss_line[0], $tss_line[1], $tss_line[5]);
  for my $key (keys %dmr) {
    my ($dmr_chr, $dmr_coord) = split ":", $key;
    next unless ($dmr_chr eq $tss_chr);
    my $distance = ($strand eq "+") ? ($dmr_coord - $tss)/10000 : ($tss - $dmr_coord)/10000;
    my $index = int ($distance + $distance/abs($distance*2));
    $cnt_dmr{$index}++;
  }
}
close TSS;

for (my $i = -100; $i <= 100; $i++) {
  $cnt_dmr{$i} = 0 unless (exists $cnt_dmr{$i});
  $cnt_dmr{$i} /= $cnt_tss;
  print "$cnt_dmr{$i}\n";
}

exit;
