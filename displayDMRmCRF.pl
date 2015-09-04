#! /usr/bin/perl -w
#----------------------------------------------------------#
# Copyright (C) 2008 UC Santa Cruz, Santa Cruz CA          #
# All Rights Reserved.                                     #
#                                                          #
# Author: Ting Wang                                        #
# Send all comments to tingwang@soe.ucsc.edu               #
#                                                          #
# DISCLAIMER: THIS SOFTWARE IS PROVIDED "AS IS"            #
#             WITHOUT WARRANTY OF ANY KIND.                #
#----------------------------------------------------------#

use strict;
use GD;

my $usage = '
displayDMRmCRF.pl <DMR mCRF value file> <output jpg file> 

';

die $usage unless @ARGV;

my ( $val_f, $fig_f, ) = @ARGV;
my $numVal = 7;

# Cutoff values
my $c1 = 0.25;
my $c2 = 0.5;
my $c3 = 0.75;

# get status calls
my @status;
my @line;
open ( IN, $val_f ) || die "Cannot open $val_f";
while ( <IN> )
{
  chomp;
  @line = split;
  push @status, [ @line ];
    
  for ( my $i=0; $i<@line; $i++)
  {
# call
    if ( $status[$#status][$i] < $c1 )
    {
      $status[$#status][$i] = 0;
    }
    elsif ( ( $status[$#status][$i] >= $c1 ) && ( $status[$#status][$i] < $c2 ) )
    {
      $status[$#status][$i] = 1;
    }
    elsif ( ( $status[$#status][$i] >= $c2 ) && ( $status[$#status][$i] < $c3 ) )
    {
      $status[$#status][$i] = 2;
    }
    elsif ( ( $status[$#status][$i] >= $c3 ) )
    {
      $status[$#status][$i] = 3;
    }
  }
}
close IN;



###############
# Creat Image #
###############
my $jpg = $fig_f;
my $wid = 10* $numVal;
my $X = $wid;
my $Y = $#status+1;

my $image = GD::Image->new($X, $Y);

my $white = $image->colorAllocate(255,255,255);
my $black = $image->colorAllocate(  0,  0,  0);

my %red;
$red{0}  = $black;
$red{1}  = $image->colorAllocate( 85,  0,  0);
$red{2}  = $image->colorAllocate(170,  0,  0);
$red{3}  = $image->colorAllocate(255,  0,  0);

$image->transparent($white);
$image->interlaced('true');

#Background
$image->filledRectangle( 0, 0, $X, $Y, $white );

#Frame
#$image->rectangle( 2, 2, $X-2, $Y-2, $blue );

my $cur_x;
my $cur_y;
my $color;

for ( my $i=0; $i<=$#status; $i++ )
{
  $cur_y = $i;
  for ( my $j=0; $j< $numVal; $j++ )
  {
    $cur_x = $j*10;
    $color = $red{$status[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+10, $cur_y+1, $color );
  }
}

#JPEG output
my $jpeg_data = $image->jpeg([50]);
open ( DISPLAY, ">$jpg" ) || die "Cannot open $jpg.";
binmode DISPLAY;
print DISPLAY $jpeg_data;
close DISPLAY;
exit;
