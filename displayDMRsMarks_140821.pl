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
displayDMRsMarks.pl <DMR rpkm value file> 

';

die $usage unless @ARGV;

my ( $val_f, ) = @ARGV;
my $fig_f = $val_f;
$fig_f =~ s/rpkm$/jpg/;

# Order of sorting: sort H3K4me1 first, etc.
my @order = ( 0, 1, 2 );

# Cutoff values
my $c1 = 3;
my $c2 = 10;
my $c3 = 30;
my $c4 = 100;
my $c5 = 300;

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
    elsif ( ( $status[$#status][$i] >= $c3 ) && ( $status[$#status][$i] < $c4 ) )
    {
      $status[$#status][$i] = 3;
    }
    elsif ( ( $status[$#status][$i] >= $c4 ) && ( $status[$#status][$i] < $c5 ) )
    {
      $status[$#status][$i] = 4;
    }
    else
    {
      $status[$#status][$i] = 5;
    }
  }
}
close IN;

# calculated DMR status which will be used for sorting

my %h_0;
my %h_1;
my %h_2;
my %h_3;
my %h_4;
my %h_5;
my %h_6;
my %h_7;

for ( my $i=0; $i<=$#status; $i++ )
{
  for ( my $j=95; $j<105; $j++ )
  {
    $h_0{ $status[$i] } += $status[$i][$j];
  }
  for ( my $j=295; $j<305; $j++ )
  {
    $h_1{ $status[$i] } += $status[$i][$j];
  }
  for ( my $j=495; $j<505; $j++ )
  {
    $h_2{ $status[$i] } += $status[$i][$j];
  }
  for ( my $j=695; $j<705; $j++ )
  {
    $h_3{ $status[$i] } += $status[$i][$j];
  }
  for ( my $j=895; $j<905; $j++ )
  {
    $h_4{ $status[$i] } += $status[$i][$j];
  }
  for ( my $j=1095; $j<1105; $j++ )
  {
    $h_5{ $status[$i] } += $status[$i][$j];
  }
  for ( my $j=1295; $j<1305; $j++ )
  {
    $h_6{ $status[$i] } += $status[$i][$j];
  }
  for ( my $j=1495; $j<1505; $j++ )
  {
    $h_7{ $status[$i] } += $status[$i][$j];
  }
}

# sort
my @sorted;

@sorted = @status;
#@sorted = sort { $h_1{$a}<=>$h_1{$b} } @status ;
#@sorted = sort { $h_0{$a}<=>$h_0{$b} or $h_1{$a}<=>$h_1{$b} or $h_2{$a}<=>$h_2{$b} } @status ;

###############
# Creat Image #
###############
my $jpg = $fig_f;
my $wid = 200;
my $X = 8*$wid+90;
my $Y = $#status+1;

my $image = GD::Image->new($X, $Y);

my $white = $image->colorAllocate(255,255,255);

my %blue;
$blue{0} = $white;
$blue{1} = $image->colorAllocate(229,229,255);
$blue{2} = $image->colorAllocate(204,204,255);
$blue{3} = $image->colorAllocate( 51, 51,255);
$blue{4} = $image->colorAllocate( 25, 25,255);
$blue{5} = $image->colorAllocate(  0,  0,255);

my %red;
$red{0}  = $white;
$red{1}  = $image->colorAllocate(255,229,229);
$red{2}  = $image->colorAllocate(255,204,204);
$red{3}  = $image->colorAllocate(255, 51, 51);
$red{4}  = $image->colorAllocate(255, 25, 25);
$red{5}  = $image->colorAllocate(255,  0,  0);

$image->transparent($white);
$image->interlaced('true');

#Background
$image->filledRectangle( 0, 0, $X, $Y, $white );

my $cur_x;
my $cur_y;
my $color;

for ( my $i=0; $i<=$#sorted; $i++ )
{
  $cur_y = $i;
  for ( my $j=0; $j<200; $j++ )
  {
    $cur_x = 10+$j;
    $color = $red{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  }
  for ( my $j=200; $j<400; $j++ )
  {
    $cur_x = 20+$j;
    $color = $red{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  }
  for ( my $j=400; $j<600; $j++ )
  {
    $cur_x = 30+$j;
    $color = $red{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  }
  for ( my $j=600; $j<800; $j++ )
  {
    $cur_x = 40+$j;
    $color = $red{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  } 
  for ( my $j=800; $j<1000; $j++ )
  {
    $cur_x = 50+$j;
    $color = $blue{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  }
  for ( my $j=1000; $j<1200; $j++ )
  {
    $cur_x = 60+$j;
    $color = $blue{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  }
 for ( my $j=1200; $j<1400; $j++ )
  {
    $cur_x = 70+$j;
    $color = $blue{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  }
  for ( my $j=1400; $j<1600; $j++ )
  {
    $cur_x = 80+$j;
    $color = $blue{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+1, $cur_y+1, $color );
  }
}

#JPEG output
my $jpeg_data = $image->jpeg([50]);
open ( DISPLAY, ">$jpg" ) || die "Cannot open $jpg.";
binmode DISPLAY;
print DISPLAY $jpeg_data;
close DISPLAY;
exit;
