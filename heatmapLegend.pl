#! /usr/bin/perl -w
use strict;
use GD;

my $usage = '
displayDMRsMarks.pl <DMR rpkm value file> 

';

die $usage unless @ARGV;

###############
# Creat Image #
###############

#Background

my $cur_x;
my $cur_y;
my $color;


#legend

my $X = 50;
my $Y = 250;
my $legend = GD::Image->new($X, $Y);
my $white = $legend->colorAllocate(255,255,255);
my %blue;

$legend->transparent($white);
$legend->interlaced('true');
$legend->filledRectangle( 0, 0, $X, $Y, $white );

$blue{0} = $white;
$blue{1} = $legend->colorAllocate(204,204,255);
$blue{2} = $legend->colorAllocate(153,153,255);
$blue{3} = $legend->colorAllocate( 51, 51,255);
$blue{4} = $legend->colorAllocate(  0,  0,255);

$cur_y = 0;
for ( my $i=0; $i<5; $i++ ) {
  $cur_y = 50 * $i;
  $color = $blue{$i};
  $legend->filledRectangle( 0, $cur_y, 50, $cur_y+50, $color );
}

my $jpeg_data = $legend->jpeg([50]);
my $jpg = "legend.jpg";
open DISPLAY, ">$jpg" or die "Cannot open $jpg.\n";
binmode DISPLAY;
print DISPLAY $jpeg_data;
close DISPLAY;

exit;

