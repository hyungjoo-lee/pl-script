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
displayDMRsRPKM.pl <DMR MeDIP and MRE rpkm value file> 

';

die $usage unless @ARGV;

my ( $val_f, ) = @ARGV;
my $fig_f = $val_f;
$fig_f =~ s/rpkm$/jpg/;

# Order of sorting: sort H3K4me1 first, etc.
my @order = ( 0, 1, 2, 3, 4, 5 );

# Cutoff values
my @medip_c = (0, 0.3, 0.6, 0.9, 1.2, 1.5, 1.8, 2.1, 2.4, 2.7, 3);
my @mre_c = (0,1,2,3,4,5,6,7,8,9,10);

# get status calls
my @status;
my @line;
open ( IN, $val_f ) || die "Cannot open $val_f";
while ( <IN> )
{
  chomp;
  @line = split;
  push @status, [ @line ];
    
  for ( my $i=0; $i<6; $i++)
  {
    # call
    for (my $j=0; $j<10; $j++) {
	if ( ( $status[$#status][$i] >= $medip_c[$j] ) && ( $status[$#status][$i] < $medip_c[$j+1] ) )
	{
	      $status[$#status][$i] = $j;
	}
	elsif ( $status[$#status][$i] >= $medip_c[10] )
	{
	$status[$#status][$i] = 10;
	}
    }
  }
  for ( my $i=6; $i<12; $i++)
  {
    for (my $j=0; $j<10; $j++) {
        if ( ( $status[$#status][$i] >= $mre_c[$j] ) && ( $status[$#status][$i] < $mre_c[$j+1] ) )   
        {
              $status[$#status][$i] = $j;
        }
        elsif ( $status[$#status][$i] >= $mre_c[10] )
        {
        $status[$#status][$i] = 10;
        }
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
my %h_8;
my %h_9;
my %h_10;
my %h_11;
my %d_0;
my %d_1;
my %d_2;
my %d_3;
my %d_4;
my %d_5;

for ( my $i=0; $i<=$#status; $i++ )
{
  $h_0{ $status[$i] } = $status[$i][0];
  $h_1{ $status[$i] } = $status[$i][1];
  $h_2{ $status[$i] } = $status[$i][2];
  $h_3{ $status[$i] } = $status[$i][3];
  $h_4{ $status[$i] } = $status[$i][4];
  $h_5{ $status[$i] } = $status[$i][5];
  $h_6{ $status[$i] } = $status[$i][6];
  $h_7{ $status[$i] } = $status[$i][7];
  $h_8{ $status[$i] } = $status[$i][8];
  $h_9{ $status[$i] } = $status[$i][9];
  $h_10{ $status[$i] } = $status[$i][10];
  $h_11{ $status[$i] } = $status[$i][11];
  $d_0{ $status[$i] } = $status[$i][0] - $status[$i][6];
  $d_1{ $status[$i] } = $status[$i][1] - $status[$i][7];
  $d_2{ $status[$i] } = $status[$i][2] - $status[$i][8];
  $d_3{ $status[$i] } = $status[$i][3] - $status[$i][9];
  $d_4{ $status[$i] } = $status[$i][4] - $status[$i][10];
  $d_5{ $status[$i] } = $status[$i][5] - $status[$i][11];
}

# sort
my @sorted;

#@sorted = @status ;
#@sorted = sort { $d_5{$a}<=>$d_5{$b} or $d_4{$a}<=>$d_4{$b} or $d_3{$a}<=>$d_3{$b} or $d_2{$a}<=>$d_2{$b} or $d_1{$a}<=>$d_1{$b} or $d_0{$a}<=>$d_0{$b} or $h_11{$b}<=>$h_11{$a} or $h_5{$a}<=>$h_5{$b} or $h_10{$b}<=>$h_10{$a} or $h_4{$a}<=>$h_4{$b} or $h_9{$b}<=>$h_9{$a} or $h_3{$a}<=>$h_3{$b} or $h_8{$b}<=>$h_8{$a} or $h_2{$a}<=>$h_2{$b} or $h_7{$b}<=>$h_7{$a} or $h_1{$a}<=>$h_1{$b} or $h_6{$b}<=>$h_6{$a} or $h_0{$a}<=>$h_0{$b}} @status ;
@sorted = sort { $h_11{$b}<=>$h_11{$a} or $h_5{$a}<=>$h_5{$b} or $h_10{$b}<=>$h_10{$a} or $h_4{$a}<=>$h_4{$b} or $h_9{$b}<=>$h_9{$a} or $h_3{$a}<=>$h_3{$b} or $h_8{$b}<=>$h_8{$a} or $h_2{$a}<=>$h_2{$b} or $h_7{$b}<=>$h_7{$a} or $h_1{$a}<=>$h_1{$b} or $h_6{$b}<=>$h_6{$a} or $h_0{$a}<=>$h_0{$b}} @status ;

###############
# Creat Image #
###############
my $jpg = $fig_f;
my $wid = 50;
my $X = 12*$wid + 30;
my $Y = $#status+1+20;

my $image = GD::Image->new($X, $Y);

my $white = $image->colorAllocate(255,255,255);
my $black = $image->colorAllocate(0,0,0);

my %red;
$red{0}  = $black;
$red{1}  = $image->colorAllocate( 12,0,0);
$red{2}  = $image->colorAllocate( 25,0,0);
$red{3}  = $image->colorAllocate( 38,0,0);
$red{4}  = $image->colorAllocate( 51,0,0);
$red{5}  = $image->colorAllocate(127,0,0);
$red{6}  = $image->colorAllocate(204,0,0);
$red{7}  = $image->colorAllocate(216,0,0);
$red{8}  = $image->colorAllocate(229,0,0);
$red{9}  = $image->colorAllocate(242,0,0);
$red{10} = $image->colorAllocate(255,0,0);

my %green;
$green{0}= $black;
$green{1}= $image->colorAllocate(0, 12,0);
$green{2}= $image->colorAllocate(0, 25,0);
$green{3}= $image->colorAllocate(0, 38,0);
$green{4}= $image->colorAllocate(0, 51,0);
$green{5}= $image->colorAllocate(0,127,0);
$green{6}= $image->colorAllocate(0,204,0);
$green{7}= $image->colorAllocate(0,216,0);
$green{8}= $image->colorAllocate(0,229,0);
$green{9}= $image->colorAllocate(0,242,0);
$green{10}=$image->colorAllocate(0,255,0);

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
  for ( my $j=0; $j<6; $j++ )
  {
    $cur_x = 10+50*$j;
    $color = $red{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+50, $cur_y+1, $color );
  }
  for ( my $j=6; $j<12; $j++ )
  {
    $cur_x = 20+50*$j;
    $color = $green{$sorted[$i][$j]};
    $image->filledRectangle( $cur_x, $cur_y, $cur_x+50, $cur_y+1, $color );
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
