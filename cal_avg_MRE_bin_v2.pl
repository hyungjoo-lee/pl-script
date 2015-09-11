#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# Usage: ./cal_avg_MRE_bin_v2.pl $BED_bin $MRE_scores_all_samples
# v2 for heterogeneous bin sizes. This takes longer time.

use strict;

my $usage = '
Usage: ./cal_avg_MRE_bin_v2.pl $BED_bin $MRE_scores_all_samples STDOUT>[avg MRE scores per bin]

';

die $usage unless @ARGV;
my ($bin_f, $in_f ) = @ARGV;

my $cnt_sample;
my %mre;
my %mre_cnt;

open IN, $in_f or die "Cannot open the file $in_f.\n";
while (<IN>) {
  chomp;
  my @line = split "\t";
  my $mre_cpg = "$line[0]:$line[1]";
  $cnt_sample = @line-3;
  push @{ $mre{$mre_cpg} }, @line[3..@line-1];
}
close IN;

open BIN, $bin_f or die "Cannot open the file $bin_f.\n";
while (<BIN>) {
  chomp;
  my @line = split "\t";
  my $bin = "$line[0]:$line[1]";
  my @avg_mre = 0;
  my $mre_cnt = 0;
  for (my $i=$line[1]; $i<=$line[2]; $i++) {
    my $coord = "$line[0]:$i";
    if (exists $mre{$coord}) {
      $mre_cnt++;
      for (my $j=0; $j<$cnt_sample; $j++) {
        $avg_mre[$j] += $mre{$coord}[$j];
      }
    }
  }
  for (my $j=0; $j<$cnt_sample; $j++) {
    $avg_mre[$j] = ( ($mre_cnt==0) || ($avg_mre[$j]==0) ) ? 0 : sprintf("%.4f", $avg_mre[$j]/$mre_cnt);
  }
  print join "\t", @line[0..2], $mre_cnt, @avg_mre;
  print "\n";
}
close BIN;
exit;
