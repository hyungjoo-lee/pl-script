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
# displayCpGClasses.pl <cpg value> <type>
#
# CpG island values are in the following format:
# chr	start	end	cpg	type	dist	gene	CAGE	H3K4	MeDIP	MRE
# chr1	1579936	1580805	CpG:83	type2	77	CDC2L1	0	2.94706559263521	1.15075	8.95000
#
# cutoff values for CAGE, H3K4, MeDIP and MRE are provided to call if an island is 
# active or inactive with respect to each type. 
# for MeDIP, 2 cutoffs are used to define methylated, partially methylated and completely methylated
# Bar graph is generated to provide a clinical heatmap view of all CGI
# 
#-----------------------------------------------------------



my $usage = '
displayCpGClasses.pl <cpg value> <fig> <type>

CpG island values are in the following format:
chr	start	end	cpg	type	dist	gene	CAGE	H3K4	MeDIP	MRE
chr1	1579936	1580805	CpG:83	type2	77	CDC2L1	0	2.94706559263521	1.15075	8.95000

cutoff values for CAGE, H3K4, MeDIP and MRE are provided to call if an island is 
active or inactive with respect to each type. 
for MeDIP, 2 cutoffs are used to define methylated, partially methylated and completely methylated
Bar graph is generated to provide a clinical heatmap view of all CGI

';

die $usage unless @ARGV;

my ( $val_f, $fig_f, $type ) = @ARGV;

# Order of sorting: sort CAGE first, etc.
my @order = ( 2, 3, 1, 0 );

# which type -- by default compute all types.
if ( !$type )
{
  $type = "type";
}
else
{
  $type = "type".$type;
}

# Cutoff values
my $cage_c = 1;
my $h3_c = 1;
my $medip_c_1 = 20;
my $medip_c_2 = 50;
my $mre_c = 5;

# get status calls
my @status;
my @line;
open ( IN, $val_f ) || die "Cannot open $val_f";
while ( <IN> )
{
  chomp;
  @line = split;
  if ( $line[4] =~ /$type/ )
  {
    push @status, [ ( $line[7], $line[8], $line[9], $line[10] ) ];
    
    # CAGE call
    if ( $status[$#status][0] < $cage_c )
    {
      $status[$#status][0] = -1;
    }
    else
    {
      $status[$#status][0] = 1;
    }
    
    # H3K4 call
    if ( $status[$#status][1] < $h3_c )
    {
      $status[$#status][1] = -1;
    }
    else
    {
      $status[$#status][1] = 1;
    }
    
    # MeDIP call
    if ( $status[$#status][2] >= $medip_c_2 )
    {
      $status[$#status][2] = -1;
    }
    elsif ( ( $status[$#status][2] < $medip_c_2 ) && ( $status[$#status][2] >= $medip_c_1 ) )
    {
      $status[$#status][2] = 0;
    }
    else
    {
      $status[$#status][2] = 1;
    }
    
    # MRE call
    if ( $status[$#status][3] < $mre_c )
    {
      $status[$#status][3] = -1;
    }
    else
    {
      $status[$#status][3] = 1;
    }
  }
}

# move columns
my @ordered;
my %h_0;
my %h_1;
my %h_2;
my %h_3;
for ( my $i=0; $i<=$#status; $i++ )
{
  $ordered[$i][0] = $status[$i][ $order[0] ];
  $ordered[$i][1] = $status[$i][ $order[1] ];
  $ordered[$i][2] = $status[$i][ $order[2] ];
  $ordered[$i][3] = $status[$i][ $order[3] ];
  
  $h_0{ $ordered[$i] } = $ordered[$i][0];
  $h_1{ $ordered[$i] } = $ordered[$i][1];
  $h_2{ $ordered[$i] } = $ordered[$i][2];
  $h_3{ $ordered[$i] } = $ordered[$i][3];
}

# sort
my @sorted;

@sorted = reverse ( sort { $h_0{$a}<=>$h_0{$b} or $h_1{$a}<=>$h_1{$b} or $h_2{$a}<=>$h_2{$b} or $h_3{$a}<=>$h_3{$b} } @ordered );


#for ( my $i=0; $i<=$#sorted; $i++ )
#{
#  for ( my $j=0; $j<=3; $j++ )
#  {
#    print $sorted[$i][$j], " | ";
#  }
#  print "\n";
#}

###############
# Creat Image #
###############
my $jpg = $fig_f;
my $wid = 100;
my $X = 4*$wid + 50;
my $Y = $#status+1+20;

my $image = GD::Image->new($X, $Y);

my $black = $image->colorAllocate(0,0,0);
my $gray  = $image->colorAllocate(190,190,190);
my $white = $image->colorAllocate(255,255,255); 
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

my @column;
my $block;
for ( my $i=0; $i<=3; $i++ )
{
  @column = ();
  $block = 0;
  $column[$block][0] = $sorted[0][$i];
  $column[$block][1] = 1;
  for ( my $j=1; $j<=$#sorted; $j++ )
  {
    if ( $column[$block][0] eq $sorted[$j][$i] )
    {
      $column[$block][1]++;
    }
    else
    {
      $block++;
      $column[$block][0] = $sorted[$j][$i];
      $column[$block][1] = 1;
    }
  }
  #print $block, "\n";
  #for ( my $j=0; $j<=$#column; $j++ )
  #{
  #  print $column[$j][0], " : ", $column[$j][1], " | ";
  #}
  #print "\n";
  
  draw_column ( \@column, 10+$i*(10+$wid) );
  
}


#JPEG output
my $jpeg_data = $image->jpeg([50]);
open ( DISPLAY, ">$jpg" ) || die "Cannot open $jpg.";
binmode DISPLAY;
print DISPLAY $jpeg_data;
close DISPLAY;

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
  
  




                                                                                                                                                                                             