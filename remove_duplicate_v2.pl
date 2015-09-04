#!/usr/bin/perl -w
use strict;

my ( $in_f, $out_f ) = @ARGV;
my $line = "";
my $cnt = 0;
open ( IN, $in_f ) || die "Cannot open $in_f";
open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
while ( <IN> ) {
        if ( $line eq $_ )
        {
          next;
        }
        else
        {
          print OUT $_;
          $cnt ++;
          $line = $_;
        }
  }
  print "unique reads:\t", $cnt, "\n";
  close OUT;
  close IN;

