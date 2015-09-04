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

open TSS, $tss_f or die "Cannot open $tss_f file.\n";
while (<TSS>) {
  next if /^Zv/;
  chomp;
  my @tss_line = split;
  my ($tss_chr, $tss, $strand) = ($tss_line[0], $tss_line[1], $tss_line[5]);
  my $cnt_dmr = 0;
  for my $key (keys %dmr) {
    my ($dmr_chr, $dmr_coord) = split ":", $key;
    next unless ($dmr_chr eq $tss_chr);
    my $distance = ($strand eq "+") ? ($dmr_coord - $tss) : ($tss - $dmr_coord);
    $cnt_dmr++ if ( abs($distance) <= 50000);
  }
  print "$cnt_dmr\n";
}
close TSS;

exit;
