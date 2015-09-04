#!/usr/bin/perl -w
# This generates RPKM profiles of certain coordinates from bedGraph data (RNA in this case).
# June 21, 2013 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <coordinate bed> <data bedGraph> <optional: total signal of data (sum of bedGraph values) STDOUT> bedformat \n";

die $usage unless @ARGV;

my ($bed_f, $data_f, $reads, ) = @ARGV;

unless (defined $reads) {
  $reads = `awk '{sum+=\$4} END{printf("%15d", sum)}'  <$data_f`;
}

open BED, $bed_f or die "Cannot open $bed_f.\n";
open DATA, $data_f or die "Cannot open $data_f.\n";

my $data_line = undef;

my @pre_val = ();
my @val = ();

my $pre_bed_chr = "chr0";
my ($pre_bed_start, $pre_bed_end) = (0, 0);

while (<BED>) {
  chomp;
  my @bed_line = split;
  my ($bed_chr, $bed_start, $bed_end) = @bed_line[0..2];

  if ( ($bed_chr eq $pre_bed_chr) && ($bed_start < $pre_bed_end ) ) {
    my $diff = $bed_start - $pre_bed_start;
    for (my $i = $diff; $i < @pre_val; $i++) {
      $val[$i-$diff] = 0 if !defined ($pre_val[$i]);
      $val[$i-$diff] = $pre_val[$i];
    }
  }

  my $exonCount = $bed_line[9];
  my @exonSizes = split ",", $bed_line[10];
  my @exonStarts = split ",", $bed_line[11];

  my $length = 0;
  my $area = 0;

  for (my $coord = $bed_start; $coord < $bed_end; $coord++) {

    my $inExon = 0;
    for (my $i = 0; $i < $exonCount; $i++) {
      if ( ( $coord >= $bed_start+$exonStarts[$i] ) && ( $coord < $bed_start+$exonStarts[$i]+$exonSizes[$i] ) ) {
        $inExon = 1;
        last;
      }
    }
    $length++ if ($inExon == 1);

    if (defined ($val[$coord-$bed_start])) {
      $area += $val[$coord-$bed_start];
      next;
    }

    my $done = 0;
    while ( !$done ) {
      last if eof(BED);
      last if eof(DATA);
      $data_line = <DATA> if !defined($data_line) ;
      my @data_line = split "\t", $data_line;
      my ($data_chr, $data_start, $data_end, $val) = @data_line[0..3];

      if ( ( $bed_chr eq $data_chr ) &&
           ( $coord >= $data_start ) &&
           ( $coord < $data_end ) )
      {
        $val[$coord-$bed_start] = $val;
        $area += $val if ($inExon == 1);
        $done = 1;
      }
      elsif ( ( $bed_chr lt $data_chr ) ||
              ( $bed_chr eq $data_chr && $coord < $data_start ) )
      {
        $done = 1;
      }
      else
      {
        $data_line = undef;
        next;
      }
    }
  }
  my $rpkm = ($area/$length) / ( $length/1000 * $reads/1000000 );
  @pre_val = @val;
  @val = ();
  ($pre_bed_chr, $pre_bed_start, $pre_bed_end) = ($bed_chr, $bed_start, $bed_end);

  $bed_line[4] = $rpkm;
  @bed_line[6..8] = @bed_line[12..14];
  print join ("\t", @bed_line[0..5]), "\n";
}

close DATA;
close BED;
exit;
