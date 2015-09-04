#! /usr/bin/perl -w
#----------------------------------------------------------#
# Copyright (C) 2009 UC Santa Cruz, Santa Cruz CA          #
# All Rights Reserved.                                     #
#                                                          #
# Author: Ting Wang                                        #
# Send all comments to tingwang@soe.ucsc.edu               #
#                                                          #
# DISCLAIMER: THIS SOFTWARE IS PROVIDED "AS IS"            #
#             WITHOUT WARRANTY OF ANY KIND.                #
#----------------------------------------------------------#

use strict;
#-----------------------------------------------------------
# bed_reads_RKPM.pl
# 
# this script takes one bed file for locations (bed 3), another bed file
# for reads, and calculate RKPM score for each bed location item
# 
#-----------------------------------------------------------

my $usage = '
bed_reads_RKPM.pl
 
 this script takes one bed file for locations (bed 3), another bed file
 for reads, and calculate RKPM score for each bed location item

';

die $usage unless @ARGV;

my ( $bed_f, $read_f, $total_reads ) = @ARGV;

if ( !$total_reads )
{
  $total_reads = `wc -l < $read_f`;
}

my $mil = $total_reads/1000000;

my @pre_bag;
my @cur_bag;
my @bed_line;
my @read_line;
my $read_line;
my $read_cnt;

open ( BED, $bed_f ) || die "Cannot open $bed_f";
open ( READ, $read_f ) || die "Cannot open $read_f";

while ( <BED> )
{
  chomp;
  @bed_line = split /\t/;
  $read_cnt = 0;
  @cur_bag = @pre_bag;
  @pre_bag = ();
  $read_line = undef;
  my $done = 0;
  
  while ( !$done )
  {
    if ( @cur_bag > 0 )
    {
      $read_line = shift @cur_bag;
    }
    else
    {
      while ( !defined($read_line) && !eof(READ) )
      {
		$read_line = <READ>;
		
	  }
	}
	if ( defined($read_line) )
	{
	  @read_line = split /\t/, $read_line;
	  if ( ( $bed_line[0] eq $read_line[0] ) && 
	       ( $bed_line[1] <= $read_line[2] ) && 
	       ( $bed_line[2] >= $read_line[1] ) )
	  {
	    $read_cnt++;
	    push @pre_bag, $read_line;
	  }
	  elsif ( ( $read_line[0] gt $bed_line[0] ) || 
	          ( $read_line[0] eq $bed_line[0] && $read_line[1] > $bed_line[2] ) )
	  {
	    print_RKPM ( \@bed_line, \@pre_bag );
	    push @pre_bag, $read_line;
	    $done = 1;
	  }
	  $read_line = undef;
	}
	else
	{
	  print_RKPM ( \@bed_line, \@pre_bag );
	  $done = 1;
	} 
  }
}

close BED;
close READ;
	    

###############
# Subroutines #
###############

sub print_RKPM
{
  my ( $bed_r, $read_r ) = @_;
  my $read_cnt = $#{$read_r} + 1;
  my $kb = ( $bed_r->[2]-$bed_r->[1] )/1000;
  my $rkpm = $read_cnt/$kb/$mil;
  print $bed_r->[0], "\t", $bed_r->[1], "\t", $bed_r->[2], "\t";
  #printf "%d\t%.4f\n", $read_cnt, $rkpm;
  printf "%.4f\t", $read_cnt/$kb;
  printf "%.4f\n", $rkpm;
  #print $read_cnt, "\n";
} 

sub log2
{
  my ( $n ) = @_;
  return ( log($n)/log(2) );
}
