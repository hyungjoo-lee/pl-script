#!/usr/bin/perl -w
use strict;

my ( $in_f, $out_f ) = @ARGV;
my @pos = ("", "", "");
my $cnt = 0;
my @line;
open ( IN, $in_f ) || die "Cannot open $in_f";
open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
while ( <IN> ) {
        @line = split;
        if ( ($line[0] eq $pos[0]) && ($line[1] eq $pos[1]) )#&& ($line[3] eq $pos[2]) )
        {
          next;
        }
        else
        {
          print OUT $_;
          $cnt ++;
          $pos[0] = $line[0];
          $pos[1] = $line[1];
          $pos[2] = $line[5];
        }
  }
  print "unique reads:\t", $cnt, "\n";
  close OUT;
  close IN;

