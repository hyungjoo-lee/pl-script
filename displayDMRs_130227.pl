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
displayDMRsMarks.pl <DMR ID bed file> 

';

die $usage unless @ARGV;

my ( $bed_f, ) = @ARGV;
my $fig_f = $bed_f;
$fig_f =~ s/bed$/jpg/;

# Order of sorting: sort H3K4me1 first, etc.
my @order = ( 0, 1, 2, 3 );

# get status calls
my @status;
my @line;
open ( IN, $bed_f ) or die "Cannot open $bed_f";
while ( <IN> )
{
  next if /end/;
  chomp;
  @line = split;
  push @status, [ @line[4..18] ];
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
my %h_8;
my %h_9;
my %h_10;
my %h_11;
my %h_12;
my %h_13;
my %h_14;

for ( my $i=0; $i<=$#status; $i++ )
{
  $h_0{ $status[$i] } = $status[$i][0];
  $h_1{ $status[$i] } = $status[$i][1];
  $h_2{ $status[$i] } = $status[$i][2];
  $h_3{ $status[$i] } = $status[$i][3];
  $h_4{ $status[$i] } = $status[$i][4];
#  $h_5{ $status[$i] } = $status[$i][5];
#  $h_6{ $status[$i] } = $status[$i][6];
#  $h_7{ $status[$i] } = $status[$i][7];
#  $h_8{ $status[$i] } = $status[$i][8];
#  $h_9{ $status[$i] } = $status[$i][9];
#  $h_10{ $status[$i] } = $status[$i][10];
#  $h_11{ $status[$i] } = $status[$i][11];
#  $h_12{ $status[$i] } = $status[$i][12];
#  $h_13{ $status[$i] } = $status[$i][13];
#  $h_14{ $status[$i] } = $status[$i][14];
}

# sort
my @sorted;

#@sorted = @status;
@sorted = sort { $h_0{$a}<=>$h_0{$b} or $h_1{$a}<=>$h_1{$b} or $h_2{$a}<=>$h_2{$b} or $h_3{$a}<=>$h_3{$b} or $h_4{$a}<=>$h_4{$b} } @status;

#or $h_5{$a}<=>$h_5{$b} or $h_6{$a}<=>$h_6{$b} or $h_7{$a}<=>$h_7{$b} or $h_8{$a}<=>$h_8{$b} or $h_9{$a}<=>$h_9{$b} or $h_10{$a}<=>$h_10{$b} or $h_11{$a}<=>$h_11{$b} or $h_12{$a}<=>$h_12{$b} or $h_13{$a}<=>$h_13{$b} or $h_14{$a}<=>$h_14{$b} } @status ;

###############
# Creat Image #
###############
my $jpg = $fig_f;
my $wid = 50;
my $X = 15*$wid + 20;
my $Y = $#status+1+20;

my $image = GD::Image->new($X, $Y);

my $white = $image->colorAllocate(255,255,255);

my %blue;
$blue{0} = $white;
$blue{1} = $image->colorAllocate(204,204,255);
$blue{2} = $image->colorAllocate(153,153,255);
$blue{3} = $image->colorAllocate(102,102,255);
$blue{4} = $image->colorAllocate( 51, 51,255);
$blue{5} = $image->colorAllocate(  0,  0,255);

my %red;
$red{0}  = $white;
$red{1}  = $image->colorAllocate(255,204,204);
$red{2}  = $image->colorAllocate(255,153,153);
$red{3}  = $image->colorAllocate(255,102,102);
$red{4}  = $image->colorAllocate(255, 51, 51);
$red{5}  = $image->colorAllocate(255,  0,  0);

my %green;
$green{0}= $white;
$green{1}= $image->colorAllocate(204,255,204);
$green{2}= $image->colorAllocate(153,255,153);
$green{3}= $image->colorAllocate(102,255,102);
$green{4}= $image->colorAllocate( 51,255, 51);
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
  $cur_y = 10+$i;
  for ( my $j=0; $j<15; $j++ )
  {
    $cur_x = 10+$j*$wid;
    $color = $red if ($sorted[$i][$j] == +1);  
    $color = $green if ($sorted[$i][$j] == -1);
    $color = $black if ($sorted[$i][$j] == 0);
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+$wid, $cur_y+1, $color );
  }
}

#JPEG output
my $jpeg_data = $image->jpeg([50]);
open ( DISPLAY, ">$jpg" ) || die "Cannot open $jpg.";
binmode DISPLAY;
print DISPLAY $jpeg_data;
close DISPLAY;
exit;

###############
# SUBROUTINES #
###############
sub draw_column
{
  my ( $col_r, $x_start ) = @_;
  my $cur_x = $x_start;
  my $cur_y = 10;
  my $color;
  
  for ( my $i=0; $i<=$#$col_r; $i++ )
  {
    if ( $col_r->[$i][0] == -1 )
    {
      $color = $red;
    }
    elsif ( $col_r->[$i][0] == 0 )
    {
      $color = $brown;
    }
    elsif ( $col_r->[$i][0] == 1 )
    {
      $color = $green;
    }
    
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+$wid, $cur_y+$col_r->[$i][1], $color );
    
    $cur_y += $col_r->[$i][1];
  }
  
}
