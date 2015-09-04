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
# ChipSeq_handler.pl <database> <mapped file> <mapper option> <name of chip-seq bed file>
#-----------------------------------------------------------

my $usage = '
ChipSeq_handler.pl <database> <mapped file> <mapper option> <name of chip-seq bed file>

<database> is hg18, hg19 or mm9

driver script, does the following:
1) convert mapped file to a bed file
   mapper options: 1: ubc export file
                   2: MAQ generate .map file
                   3: eland output file
                   4: a format (bowtie?) from Brian --> this is for the Dicer data
                   5: sam output format (not implemented yet)
                   6: bam output format (not implemented yet) 
		   0: bed 5 (get from EDACC)
		   7: bed9
2) sort
3) remove_dup, genereate .bed
4) extend, generate .extended.bed
5) bedItemOverlap, generate .extended.bedGraph

';

die $usage unless @ARGV;

my ( $database, $map_f, $map_option, $name,) = @ARGV;

my $tmp_f = "tmp.$$";
my $extend = 150;
my $q = 0;
my $report_f = $name.".report";
my $total;
my $bam_f = $name.".bam";
my $sam_f = $name.".sam";

open ( REPORT, ">$report_f" ) || die "Cannot open $report_f";

# get chromosome sizes
my %chr_size;
my $size_f;
if ( $database eq "hg18" )
{
  $size_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg18/hg18_chrom_sizes";
}
elsif ( $database eq "hg19" )
{
  $size_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/hg19_chrom_sizes_tab";
}
elsif ( $database eq "mm9" )
{
  $size_f = "/home/comp/twlab/twang/twlab-shared/genomes/mm9/mm9_chrom_sizes";
}
elsif ( $database eq "danRer7" )
{
  $size_f = "/home/comp/twlab/mxie/Zebrafish/danRer7/danRer7_chrom_sizes";
}
elsif ( $database eq "rn4" )
{
  $size_f = "/home/comp/twlab/mxie/Rat/seq/Rat_chrom_sizes";
}
my $genome_size = get_chr_sizes( \%chr_size, $size_f );

# choose aligners 
print "convert mapped file to bed format\n";
if ( $map_option == 1 )
{
  export_2_bed( $map_f, $tmp_f );
}
elsif ( $map_option == 2 )
{
  maq_2_bed ( $map_f, $tmp_f, $q );
}
elsif ( $map_option == 3 )
{
  eland_2_bed ( $map_f, $tmp_f ); 
}
elsif ( $map_option == 4 )
{ 
  bwt_2_bed ( $map_f, $tmp_f );
}
elsif ( $map_option == 5 )
{
    sam_2_bed ( $map_f, $tmp_f );
}
elsif ( $map_option == 6 )
{
    system ("samtools view $map_f > $sam_f");
    sam_2_bed ($sam_f, $tmp_f)
}
elsif ( $map_option == 0)
{
   bed5_2_bed9 ($map_f, $tmp_f);
}
elsif ($map_option == 7)
{
	$tmp_f = $map_f;
}
print "bedSort $tmp_f $tmp_f\n";
system ( "bedSort $tmp_f $tmp_f" );

print "remove duplicate reads, generate $name.bed\n";
remove_dup ( $tmp_f, $name.".bed" );

print "extend reads to $extend bases\n";
extend_reads( $name.".bed", $name.".extended.bed", $extend );

print "bedSort $name.extended.bed $name.extended.bed\n";
system ( "bedSort $name.extended.bed $name.extended.bed" );

print "bedItemOverlapCount null chromSize=$size_f $name.bed > $name.bedGraph\n";
system ( "bedItemOverlapCount null chromSize=$size_f $name.bed > $name.bedGraph" );

unlink $tmp_f;

###############
# Subroutines #
###############

sub export_2_bed
{
  my ( $in_f, $out_f ) = @_;
  my @cnt = (0, 0);
  my @line;
  open ( IN, $in_f ) || die "Cannot open $in_f";
  open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
  while ( <IN> )
  {
    chomp;
    @line = split /\t/;
    $cnt[0]++;
  
    #if ( ( $line[21] eq "Y" ) && ( $line[10] =~ "ch" ) && ( $line[12]>=1 ) )
    if ( ( $line[10] =~ "ch" ) && ( $line[12]>=1 ) )
    {
      $cnt[1]++;
      if ( $line[10] =~ "MT" )
      { 
        print OUT "chrM", "\t";
      }
      else
      {
        if ( $line[10] =~ "chr" )
        {
          $line[10] =~ s/\.fa//g;
          print OUT $line[10], "\t";
        }
        else
        {
          $line[10] =~ s/ch/chr/;
          print OUT $line[10], "\t";
        }
      }
      print OUT $line[12] -1, "\t";
      print OUT $line[12] -1+ length($line[8]), "\t";
      print OUT $line[8], "\t";
      print OUT $line[15], "\t";
      if ( $line[13] eq "F" )
      {
        print OUT "+", "\t";
      }
      else
      {
        print OUT "-", "\t";
      }
      print OUT 0, "\t", 0, "\t";
      if ( $line[13] eq "F" )
      {
        print OUT "255,0,0\n";
      }
      else
      {
        print OUT "0,0,255\n";
      }
    }
  }
  print REPORT "total reads:\t", $cnt[0], "\n";
  print REPORT "quality filtered: \t", $cnt[1], "\n";
  close OUT;
  close IN;
}

sub maq_2_bed
{
  my ( $in_f, $out_f, $q ) = @_;
  my @cnt = (0, 0);
  my @line;
  my $tmp = "maq_tmp.$$";
  system ( "~/MAQ/maq mapview $in_f > $tmp" );

  #my %chr_size;
  #my $size_f;
  #if ( $database eq "hg18" )
  #{
  #  $size_f = "/hive/groups/remc/data/hg/hg18_chrom_sizes";
  #}
  #elsif ( $database eq "mm9" )
  #{
 #   $size_f = "/hive/groups/remc/data/mm/mm9/mm9_chrom_sizes";
  #}
  #my $genome_size = get_chr_sizes( \%chr_size, $size_f );

  open ( IN, $tmp ) || die "Cannot open $tmp";
  open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
  
  while ( <IN> )
  {
    chomp;
    @line = split /\t/;
    $cnt[0]++;
    if ( $line[7]>=$q )
    {
      $cnt[1]++;
      
      if ( $line[1] !~ "chr" )
      {
        $line[1] = "chr".$line[1];
      }
      if ( $line[1] eq "chrMT" )
      {
        $line[1] = "chrM";
      }
      print OUT $line[1], "\t"; #"chr", $line[1], "\t";
      print OUT $line[2], "\t";
      if ( $line[2]+$line[13] <= $chr_size{$line[1]}-1 )
      {
        print OUT $line[2]+$line[13], "\t";
      }
      else
      {  
        print OUT $chr_size{$line[1]}-1, "\t";
      }
      print OUT $line[14], "\t";
      print OUT $line[7], "\t";
      print OUT $line[3], "\t";
      print OUT 0, "\t", 0, "\t";
      if ( $line[3] eq "+" )
      {
        print OUT "255,0,0\n";
      }
      else
      {
        print OUT "0,0,255\n";
      }
    }
  }
  close OUT;
  close IN;
  unlink $tmp;
  print REPORT "MAQ mapped reads: $cnt[0]\n";
  print REPORT "reads quality >= $q: $cnt[1]\n";
}

sub bwt_2_bed
{
  my ( $in_f, $out_f ) = @_;
  my @cnt = (0, 0);
  my @line;
  my $chrend;
  my $chr;

  open ( IN, $in_f ) || die "Cannot open $in_f";
  open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
  
  while ( <IN> )
  {
    chomp;
    @line = split /\s+/;
    $cnt[0]++;
    if($line[2] =~/random|Un/)
    {
	next;
    } 
    elsif ($line[2] eq "chrMT")
    {
        $chr = "chrM";
        print OUT "$chr\t";
    }
    elsif (($line[2] =~ m/(chr)\d+/) or ($line[2] eq "chrX") or ($line[2] eq "chrY") or ($line[2] eq "chrM"))
    {
        $chr = $line[2];
        print OUT "$chr\t";
    }
    else 
    {
         next;
    }
    $cnt[1]++;
    my $start = $line[3];
    my $len_seq = length($line[4]);
    my $end = $line[3] + $len_seq;
    if ( $end <= $chr_size{$chr}-1 )	# end
    {
	$chrend = $end;
    }
    else
    {
	$chrend = $chr_size{$chr}-1;
    }
    my $name = $line[4];
    my $score = 0;
    my $strand = $line[1];
    print OUT "$start\t$chrend\t$name\t$score\t$strand\t0\t0\t";
    if ( $line[1] eq "+" )
    {
       print OUT "255,0,0\n";
    }
    else
    {
      print OUT "0,0,255\n";
    }
  }
  close OUT;
  close IN;

  print REPORT "mapped reads: $cnt[0]\n";
print REPORT "filtered reads: $cnt[1]\n";
}


sub sam_2_bed
{
my ($in_f, $out_f) =  @_;
my @line;
my @cnt = (0,0,0);
my $strand;
my $name;
my $chrend;
my $chr;

open (IN, $in_f) || die "cannot open the input file $in_f\n";
open (OUT,">$out_f") || die "cannot open the output file $out_f\n";

while (<IN>)
{
	next if /^@/;
	chomp;
	@line = split /\t/;
	$cnt[0]++;		# total reads

	next if ($line[1] == 4);
	$cnt[1]++;		# mapped reads

	if ($line[4] >= 10)
	{
	    $cnt[2] ++;		# reliable reads (mapQ >= 10)
	    $chr = $line[2];

        my $start = $line[3] - 1;
        my $length = length ($line[9]); 
        my $end = $start + $length;
		 if ( $end <= $chr_size{$chr}-1 )    # end
         	{
       			 $chrend = $end;
    		}
    		else
   		 {
       			 $chrend = $chr_size{$chr}-1;
   		 }	
        my $seq = $line[9];
        print OUT "$chr\t$start\t$chrend\t$seq\t0\t";
        my $flag = $line[1];
        my $bin = sprintf("%b", $flag) + 0;
        $bin = sprintf("%08d", $bin);
        my @temp =  split"", $bin;
        if ($temp[-5] eq 0)
        {
                $strand = "+";
                print OUT "$strand\t0\t0\t255,0,0\n";
        }
        else
        {
                $strand = "-";
                print OUT "$strand\t0\t0\t0,0,255\n";
        }
	}
}
printf REPORT "total reads:\t%12d\nmapped reads:\t%12d\nreliable reads(mapQ>=10):\t%12d\n", @cnt;
}

sub bed5_2_bed9
{
        my ($in_f, $out_f) = @_;
        my @line;
	my $start;
	my $end;
	my $chr;
        my $cnt = 0;
        open (IN, $in_f) || die "Cannot open $in_f";
        open (OUT, ">$out_f") || die "Cannot open $out_f";

        while (<IN>)
        {
                chomp;
                @line = split/\t/;
                $cnt ++;
		$chr = $line[0];
		$start = $line[1] -1;
#		$end = $line[2] - 1;
		if ($line[2]-1 <= $chr_size{$chr}-1)
		{
			$end = $line[2] -1;
		}
		else
		{
			$end = $chr_size{$chr}-1;
		}
                print OUT "$line[0]\t$start\t$end\t$line[3]\t0\t$line[4]\t0\t0\t";
                if ($line[4] eq "+")
                { 
                       print OUT "255,0,0\n";
                }
                else
                {
                        print OUT "0,0,255\n";
                }
        }
        print REPORT "mapped reads:\t$cnt\n";
        close IN;
        close OUT;
}

sub remove_dup
{
  my ( $in_f, $out_f ) = @_;
  my @pos = ("", "", "");
  my $cnt = 0;
  my @line;
  open ( IN, $in_f ) || die "Cannot open $in_f";
  open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
  
  while ( <IN> )
  {
	#chomp;
	@line = split /\t/;
	if ( ($line[0] eq $pos[0]) && ($line[1] eq $pos[1]) && ($line[5] eq $pos[2]) )
	{
	  next;
	}
	else
	{
	  print OUT $_;
	  $cnt ++;
	  $pos[0] = $line[0];
	  $pos[1] = $line[1];
	  $pos[2] = $line[5];
	}
  }
  print REPORT "unique reads:\t", $cnt, "\n";
  close OUT;
  close IN;
  
}


sub extend_reads
{
  my ( $in_f, $out_f, $base ) = @_;
  my $cnt = 0;
  my @line;
  #my %chr_size;
  #my $size_f;
  #if ( $database eq "hg18" )
  #{
  #  $size_f = "/hive/groups/remc/data/hg/hg18_chrom_sizes";
  #}
  #elsif ( $database eq "mm9" )
  #{
  #  $size_f = "/hive/groups/remc/data/mm/mm9/mm9_chrom_sizes";
 # }
  #my $genome_size = get_chr_sizes( \%chr_size, $size_f );
  
  open ( IN, $in_f ) || die "Cannot open $in_f";
  open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
  
  while ( <IN> )
  {
	  chomp;
	  @line = split /\t/;
	  if ($line[1] >= $chr_size{$line[0]}-1 )
	  {
		next;
          }
	  if ($line[5] eq "+" )	
          {

		$line[2] = ($line[1]+$base) <= $chr_size{$line[0]}-1 ? 
	               ($line[1]+$base) : ($chr_size{$line[0]}-1) ;
	  }
	  else
	  {
	  	$line[1] = ($line[2]-$base) >= 0 ? ( $line[2]-$base ) : 0 ;
          }  
	  for ( my $i=0; $i<=5; $i++ )
	  {
		  print OUT $line[$i], "\t";
	  }
	  print OUT 0, "\t", 0, "\t";
      if ( $line[5] eq "+" )
      {
        print OUT "255,0,0\n";
      }
      else
      {
        print OUT "0,0,255\n";
      }
  }
  close IN;
  close OUT;
}


sub get_chr_sizes
{
	my ( $chr_r, $file ) = @_;
	my $size = 0;
	my @line;
	open ( IN, $file ) || die "Cannot open $file.";
  while ( <IN> )
  {
  	chomp;
    @line = split /\t/;
    $chr_r->{$line[0]} = $line[1];
    $size += $line[1];
  }
  close IN;
  return $size;
}

