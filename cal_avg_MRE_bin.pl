#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# Usage: ./cal_avg_MRE_bin.pl $MRE_scores_all_samples

use strict;

my $usage = '
Usage: ./cal_avg_MRE_bin.pl $MRE_scores_all_samples | sort-bed - | STDOUT>[avg MRE scores per bin]

';

die $usage unless @ARGV;
my ($in_f, ) = @ARGV;

my $binSize = 500;
my %bin_mre;
my %bin_cnt;

open IN, $in_f or die "Cannot open the file $in_f.\n";
while (<IN>) {
  chomp;
  my @line = split "\t";
  my $bin = int($line[1] / $binSize);
  $bin = "$line[0]:$bin";
  $bin_cnt{$bin}++;
  if (exists $bin_mre{$bin}) {
    for (my $i=0; $i<@{$bin_mre{$bin}}; $i++) {
      $bin_mre{$bin}[$i] += $line[$i+3];
    }
  } else {
    push @{ $bin_mre{$bin} }, @line[3..@line-1];
  }
}
close IN;

for (keys %bin_cnt) {
  my @bin = split ":";
  $bin[1] *= $binSize;
  $bin[2] = $bin[1] + $binSize;
  my $bin = int($bin[1] / $binSize);
  $bin = "$bin[0]:$bin";
  my @mre_avg;
  for (my $i=0; $i<@{$bin_mre{$bin}}; $i++) {
    $mre_avg[$i] = ($bin_mre{$bin}[$i] == 0)?  0 : sprintf "%.4f", $bin_mre{$bin}[$i] / $bin_cnt{$bin};
  }
  print join "\t", @bin, @mre_avg;
  print "\n";
}
exit;
