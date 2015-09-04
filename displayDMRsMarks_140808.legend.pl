#! /usr/bin/perl -w
use strict;
use GD;

my $usage = '
displayDMRsMarks.pl

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

my $X = 150;
my $Y = 300;
my $legend = GD::Image->new($X, $Y);
my $white = $legend->colorAllocate(255,255,255);

$legend->transparent($white);
$legend->interlaced('true');
$legend->filledRectangle( 0, 0, $X, $Y, $white );

my %blue;
$blue{0} = $white;
$blue{1} = $legend->colorAllocate(229,229,255);
$blue{2} = $legend->colorAllocate(204,204,255);
$blue{3} = $legend->colorAllocate( 51, 51,255);
$blue{4} = $legend->colorAllocate( 25, 25,255);
$blue{5} = $legend->colorAllocate(  0,  0,255);

my %red;
$red{0}  = $white;
$red{1}  = $legend->colorAllocate(255,229,229);
$red{2}  = $legend->colorAllocate(255,204,204);
$red{3}  = $legend->colorAllocate(255, 51, 51);
$red{4}  = $legend->colorAllocate(255, 25, 25);
$red{5}  = $legend->colorAllocate(255,  0,  0);

my %green;
$green{0}= $white;
$green{1}= $legend->colorAllocate(229,255,229);
$green{2}= $legend->colorAllocate(204,255,204);
$green{3}= $legend->colorAllocate( 51,255, 51);
$green{4}= $legend->colorAllocate( 25,255, 25);
$green{5}= $legend->colorAllocate(  0,255,  0);

$cur_y = 0;
for ( my $i=0; $i<6; $i++ ) {
  $cur_y = 50 * $i;
  $legend->filledRectangle( 0, $cur_y, 50, $cur_y+50, $blue{$i} );
  $legend->filledRectangle( 50, $cur_y, 100, $cur_y+50, $red{$i} );
  $legend->filledRectangle( 100, $cur_y, 150, $cur_y+50, $green{$i} );
}

my $jpeg_data = $legend->jpeg([50]);
my $jpg = "legend.jpg";
open DISPLAY, ">$jpg" or die "Cannot open $jpg.\n";
binmode DISPLAY;
print DISPLAY $jpeg_data;
close DISPLAY;

exit;

