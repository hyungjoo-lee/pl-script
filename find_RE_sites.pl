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
#-----------------------------------------------------------
# find_RE_sites.pl <RE.fa> <genome> <name>
#
# find all RE sites in a genome (default human)
#
#-----------------------------------------------------------

my $usage = '
find_RE_sites.pl <RE.fa> <genome> <name>

find all RE sites in a genome. Name is the prefix of site file.

';

die $usage unless @ARGV;

my ( $fa_f, $genome, $name ) = @ARGV;

#my $genome = "~/remc/data/hg/hg18.2bit";
my $tmp_f = "tmp.$$.bed";
my $site_f = $name."_sites.bed";

system ( "oligoMatch $fa_f $genome $tmp_f" );

my @sites;
open ( IN, $tmp_f ) || die "Cannot open $tmp_f";
open ( OUT, ">$site_f" ) || die "Cannot open $site_f";
while ( <IN> )
{
  chomp;
  @sites = split /\t/;
  if ( $sites[0] =~ /random|hap|Un|Zv8/ )
  {
    next;
  }
  print OUT $sites[0], "\t", $sites[1], "\t", $sites[2], "\t";
  if ( $sites[5] eq "+" )
  {
    print OUT $name, "\t";
  }
  elsif ( $sites[5] eq "-" )
  {
    print OUT rev_comp( $name ), "\t";
  }
  print OUT "1000\t", $sites[5], "\n";
}
close OUT;
close IN;

system ( "bedSort $site_f $site_f" );
unlink $tmp_f;

###############
# Subroutines #
###############

sub rev_comp
{
  my ( $site ) = @_;
  my %comp = ( "A", "T",
             "C", "G",
             "G", "C",
             "T", "A",
             "a", "t",
             "c", "g",
             "g", "c",
             "t", "a",
             "N", "N",
             "n", "n" );
  my $rev_comp = "";
  for ( my $i=0; $i<length($site); $i++ )
  {
    $rev_comp = $comp{ substr( $site, $i, 1 ) }.$rev_comp;
  }
  return $rev_comp; 
}
    
  


