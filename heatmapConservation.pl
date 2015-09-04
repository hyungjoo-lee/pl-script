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

#-----------------------------------------------------------
# displayDMRsMarks.pl <DMR rpkm value file>
#
# DMR values are in the following format:
# chr	start	end	cpg	type	dist	gene	CAGE	H3K4	MeDIP	MRE
# chr1	1579936	1580805	CpG:83	type2	77	CDC2L1	0	2.94706559263521	1.15075	8.95000
#
# cutoff values for RPKM are provided to call if an island is 
# active or inactive with respect to each type. 
# for MeDIP, 2 cutoffs are used to define methylated, partially methylated and completely methylated
# Bar graph is generated to provide a clinical heatmap view of all CGI
# 
#-----------------------------------------------------------



my $usage = '
displayDMRsMarks.pl <DMR rpkm value file> 

';

die $usage unless @ARGV;

my ( $val_f, ) = @ARGV;
my $fig_f = $val_f.".jpg";

my @order = ( 0, 1, 2 );

# Cutoff values
my $c1 = 0.01;
my $c2 = 0.13;
my $c3 = 0.3;
my $c4 = 0.5;

# get status calls
my @status;
my @line;
open ( IN, $val_f ) or die "Cannot open $val_f";
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
    else
    {
      $status[$#status][$i] = 4;
    }
  }
}
close IN;

# calculated DMR status which will be used for sorting

my %h;
for ( my $i=0; $i<=$#status; $i++ )
{
  for ( my $j=47; $j<53; $j++ )
  {
    $h{ $status[$i] } += $status[$i][$j];
  }
}

# sort
my @sorted;

@sorted = @status;
#@sorted = sort { $h{$b}<=>$h{$a} } @status ;

###############
# Creat Image #
###############
my $jpg = $fig_f;
my $wid = 100;
my $X = $wid;
my $Y = $#status+1;

my $image = GD::Image->new($X, $Y);

my $white = $image->colorAllocate(255,255,255);

my %blue;
$blue{0} = $white;
$blue{1} = $image->colorAllocate(204,204,255);
$blue{2} = $image->colorAllocate(153,153,255);
$blue{3} = $image->colorAllocate( 51, 51,255);
$blue{4} = $image->colorAllocate( 0, 0,255);

my %red;
$red{0}  = $white;
$red{1}  = $image->colorAllocate(255,229,229);
$red{2}  = $image->colorAllocate(255,204,204);
$red{3}  = $image->colorAllocate(255, 51, 51);
$red{4}  = $image->colorAllocate(255, 25, 25);
$red{5}  = $image->colorAllocate(255,  0,  0);

my %green;
$green{0}= $white;
$green{1}= $image->colorAllocate(229,255,229);
$green{2}= $image->colorAllocate(204,255,204);
$green{3}= $image->colorAllocate( 51,255, 51);
$green{4}= $image->colorAllocate( 25,255, 25);
$green{5}= $image->colorAllocate(  0,255,  0);

my $black = $image->colorAllocate(0,0,0);
my $gray  = $image->colorAllocate(190,190,190);

my $red   = $image->colorAllocate(255,0,0);   
my $green = $image->colorAllocate(0,255,0);    
my $blue  = $image->colorAllocate(0,0,255);   
my $yellow= $image->colorAllocate(255,255,0);
my $orange= $image->colorAllocate(255,165,0); 
my $cyan  = $image->colorAllocate(0,255,255);
my $navy  = $image->colorAllocate(0,0,128);
my $brown = $image->colorAllocate(165,42,42);
my $pink  = $image->colorAllocate(255,192,203);
my $purple= $image->colorAllocate(160,32,240);
 my $dgreen= $image->colorAllocate(0,100,0);

$image->transparent($white);
$image->interlaced('true');

#Background
$image->filledRectangle( 0, 0, $X, $Y, $white );

#Frame
#$image->rectangle( 2, 2, $X-2, $Y-2, $blue );

my $cur_x;
my $cur_y;
my $color;

for ( my $i=0; $i<=$#sorted; $i++ )
{
  $cur_y = $i;
  for ( my $j=0; $j<100; $j++ )
  {
    $cur_x = $j;
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

