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
# MRE_handler.pl <database> <enzyme_num> <mapped file> <mapper option> <name of new file>
#-----------------------------------------------------------

my $usage = '
MRE_handler.pl <database> <enzyme_num> <mapped file> <mapper option> <name of new file>

<database>: hg18, hg19, mm9
<mapper option>: 1: bed file ready to go
                 2: ubc export format
                 3: eland
                 4: maq
                 5: bowtie                 
		 6: sam
An all-included MRE script, does the following:
1) convert the mapped read file into a quality-filtered bed file (for raw reads).
   currently it supports UBC export files. 
   more work necessary for other mapping format
   these reads are sorted by bedSort, a .bed file is generated
   
2) choose the appropriate enzyme fragment file, prepare a few hash files
   currently it support TriMRE. 
   need to work on FiveMRE.

3) filter the reads. 
   for those that map to correct site, record CpG count, type of enzyme count,
   and fragment count

4) generate a .filtered.bed file for MRE-site filtered reads

5) for each CpG site, generate a score: read per site per million mapped per enzyme
   generate a .CpG.bedGraph for CpG scores

6) generate additional statitics in .report file, including:
   No of total reads;
   No of reads passed quality filter (.bed file)
   No of reads passed MRE filter (.filtered.bed file)
   No of solo reads (no paired reads from expected fragments)
   Distribution of size of all fragments with both ends mapped
   How unbalancing are the reads: No of reads mapped to one end (more) vs mapped to the other end (fewer)

';

die $usage unless @ARGV;

my ( $database, $enzyme_num, $exp_f, $mapper, $name) = @ARGV;

# Globals
#my $mre;	# 3: Tri; 5: Five;
my $call;	# number of bases to skip before calling
my $MRE_f;
my $chromSize_f;
my $total;
my $unique;
my $q;

#$mre  = 3;
$call = 3;   
$q    = 0;

my $sam_f = $name.".sam";
my $bed_f = $name.".bed";
my $filtered_f = $name.".filtered.bed";
my $cg_f = $name.".CpG.bedGraph";
my $report_f = $name.".report";

open ( REPORT, ">$report_f" ) || die "Cannot open $report_f";

my %chr_size;

if($enzyme_num == 3)
{
if ( $database eq "hg18" )
{
  $chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg18/hg18_chrom_sizes";
  $MRE_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg18/MRE/TriMRE_frags.bed";
}
elsif ( $database eq "hg19" )
{
  $chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/hg19_chrom_sizes";
  $MRE_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/MRE/TriMRE_frags.bed";
  print "Choose TRiMRE_frags\n ";
}
elsif ( $database eq "mm9" )
{
  $chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/mm9/mm9_chrom_sizes";
  $MRE_f = "/home/comp/twlab/twang/twlab-shared/genomes/mm9/MRE/TriMRE_frags.bed";
}

}
else
{
  if ( $database eq "hg18" )
{
  $chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg18/hg18_chrom_sizes";
  $MRE_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg18/MRE/FiveMRE_frags.bed";
}
elsif ( $database eq "hg19" )
{
  $chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/hg19_chrom_sizes";
  $MRE_f = "/home/comp/twlab/twlab-shared/genomes/hg19/MRE/FiveMRE_frags.bed";
  print "Choose FIVEMRE_frags\n";
}
elsif ( $database eq "mm9" )
{
  $chromSize_f = "/home/comp/twlab/twang/twlab-shared/genomes/mm9/mm9_chrom_sizes";
  $MRE_f = "/home/comp/twlab/twang/twlab-shared/genomes/mm9/MRE/FiveMRE_frags.bed";
}
elsif ( $database eq "pig" )
{
  $chromSize_f = "/home/comp/twlab/mxie/pig/pig_chrom_sizes";
  $MRE_f = "/home/comp/twlab/mxie/pig/MRE/FiveMRE_frags.bed";
}
elsif ( $database eq "dog" )
{
  $chromSize_f = "/home/comp/twlab/mxie/dog/dog_chrom_sizes";
  $MRE_f = "/home/comp/twlab/mxie/dog/MRE/FiveMRE_frags.bed";
}
elsif ( $database eq "zebrafish" )
{
  $chromSize_f = "/home/comp/twlab/mxie/Zebrafish/danRer7/danRer7_chrom_sizes";
  $MRE_f = "/home/comp/twlab/mxie/Zebrafish/danRer7/MRE/FiveMRE_frags.bed";
}
elsif ( $database eq "rat" )
{
  $chromSize_f = "/home/comp/twlab/mxie/Rat/seq/Rat_chrom_sizes";
  $MRE_f = "/home/comp/twlab/mxie/Rat/MRE/FiveMRE_frags.bed";
}
  
}
my $genome_size = get_chr_sizes (\%chr_size, $chromSize_f);
print "convert mapped file to bed format\n";
# step 1
my $tmp_f = "tmp.$$";
if ( $mapper == 1 )
{
#  $tmp_f = $exp_f;
my $total = `wc -l < $exp_f`;
print REPORT "total reads:\t$total\n";
system ("bedSort $exp_f $bed_f");
}
elsif ( $mapper == 2 )
{
  export_2_bed( $exp_f, $tmp_f, $call );
  system ( "bedSort $tmp_f $bed_f" );
}
elsif ( $mapper == 3 )
{
  system ( "~/bin/elandToBed12.pl $exp_f $tmp_f $call" );
  system ( "bedSort $tmp_f $bed_f" );
  $total = `wc -l < $exp_f`;
  $unique = `wc -l < $bed_f`;
  print REPORT "total reads:\t", $total, "\n";
  print REPORT "unique reads:\t", $unique, "\n";
}
elsif ( $mapper == 4 )
{
  maq_2_bed ( $exp_f, $tmp_f, $q, $call );
  system ( "bedSort $tmp_f $bed_f" );
}
elsif ($mapper == 5)
{
    bwt_2_bed ($exp_f, $tmp_f, $call );
    system ( "bedSort $tmp_f $bed_f");
	$total = `wc -l < $exp_f`;
    $unique = `wc -l < $bed_f`;
 
}
elsif ($mapper == 6)
{
    sam_2_bed ($exp_f, $tmp_f, $call);
    system ("bedSort $tmp_f $bed_f");
}
elsif ($mapper == 7)
{
    system ("samtools view $exp_f > $sam_f");
    $total = `wc -l < $sam_f`;
    print REPORT "total reads:\t", $total, "\n";
    sam_2_bed ($sam_f, $tmp_f, $call);
    system ("bedSort $tmp_f $bed_f");
}


# step 2
#if ( $mre == 3 )
#{
#  $MRE_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/MRE/TriMRE_frags.bed";
#}
#elsif ( $mre == 5 )
#{
#  $MRE_f = "/home/comp/twlab/twang/twlab-shared/genomes/hg19/MRE/FiveMRE_frags.bed";
#}

# hash that keys in paired ends $PET{chr|start|strand} = chr|start|strand where start is where the read maps to
my %CCGG_PE;	     # hash for paired RE sites
my %CCGG_cnt;	     # count for reads at end of a fragment
my %CCGG_CpG;	     # count for CpG by CCGG reads (may include reads of two directions)
my $CCGG_reads = 0;	 # number of reads from CCGG site, sum of %CCGG_cnt
my %CCGC_PE;
my %CCGC_cnt;
my %CCGC_CpG;
my $CCGC_reads = 0;
my %GCGC_PE;
my %GCGC_cnt;
my %GCGC_CpG;
my $GCGC_reads = 0;
my %ACGT_PE;
my %ACGT_cnt;
my %ACGT_CpG;
my $ACGT_reads = 0;
my %CGCG_PE;
my %CGCG_cnt;
my %CGCG_CpG;
my $CGCG_reads = 0;



print "build_PE_hash\n";
build_PE_hash();

print "filter reads by mre sies\n";
filter_reads_by_mre_sites ( $bed_f, $filtered_f );
system ( "bedSort $filtered_f $filtered_f" );

print "calculate CpG score\n";
calculate_CpG_score( $cg_f );
system ( "bedSort $cg_f $cg_f" );

#print "fragment stats\n";
#fragment_stats();

unlink $tmp_f;

###############
# Subroutines #
###############

sub bwt_2_bed
{
    my ($in_f, $out_f, $call) = @_;
    my @line;
    my $chrend;
    my $chr;
    my @cnt = (0, 0);
    my $start;
    my $end;
    open (IN, $in_f) || die "Cannot open $in_f";
    open (OUT, ">$out_f") || die "Cannot open $out_f";
 
   while (<IN>)
   {
       chomp;
       @line = split /\s+/, $_;
       $cnt[0] ++;
       my $chr_name = $line[2];
       my $len_seq = length($line[4]);
   if ($chr_name =~ /random|Un/)
  {
    next;
  }
  
       $cnt[1] ++;
       $chr = $chr_name;
  if ($line[1] eq "+")
  {
      $start = $line[3]-$call;
      $end = $line[3] + $len_seq ;
      if ($end <= $chr_size{$chr} -1)
      {
	  $chrend = $end;
      }
      else
      {
	  $chrend = $chr_size{$chr} -1;
      }
  }
  else
  {
      $start = $line[3];
      $end = $line[3] + $len_seq + $call;
       if ($end <= $chr_size{$chr}-1)
       {
	   $chrend = $end;
       }
       else
       {
	   $chrend = $chr_size{$chr}-1;
       }
  }
my $name = $line[4];
my $score = $line[6];
my $strand = $line[1];
print OUT "$chr\t$start\t$chrend\t$name\t$score\t$strand\t0\t0\t";
if ($line[1] eq "+")
{
print OUT "255,0,0\n";
}
else
{
print OUT "0,0,255\n";
}
}

print REPORT "total reads:\t$cnt[0]\n";
print REPORT "reads quality\t$cnt[1]\n";
close OUT;
close IN; 
}


sub sam_2_bed
{
my ($in_f, $out_f, $call) =  @_;
my @line;
my @cnt = (0,0);
my $chrend;
my $chrstart;
my $strand;
my $name;

open (IN, $in_f) || die "cannot open the input file $in_f\n";
open (OUT,">$out_f") || die "cannot open the output file $out_f\n";

while (<IN>)
{
        chomp;
if ($_ =~ m/^@/)
{
        next;
}
else
{
        @line = split /\t/;
        $cnt[0] ++;
if ($line[4] >= 10)
{
    $cnt[1] ++;

        if ($line[2] eq "MT")
        {
                $name = "M";
                print OUT "chr$name\t";
        }
        elsif (($line[2] =~ m/\d+/) or ($line[2] eq "X") or ($line[2] eq "Y") or ($line[2] eq "M"))
        {
                $name = $line[2];
                print OUT "chr$name\t";
        }
        else 
        {
                next;
        }
        my $start = $line[3] - 1;
        my $length = length ($line[9]); 
        my $end = $start + $length;
        my $seq = $line[9];
#       print OUT "chr$ID\t$start\t$end\t$seq\t0\t";
        my $flag = $line[1];
        my $bin = sprintf("%b", $flag) + 0;
        $bin = sprintf("%08d", $bin);
        my @temp =  split"", $bin;
        if ($temp[-5] eq 0)
        {
                $strand = "+";
                $chrstart = $start -$call;
                $chrend = $end;
                print OUT "$chrstart\t$chrend\t$seq\t0\t$strand\t0\t0\t255,0,0\n";
        }
        else
        {
                $strand = "-";
                $chrstart = $start;
                $chrend = $end + $call;
                print OUT "$chrstart\t$chrend\t$seq\t0\t$strand\t0\t0\t0,0,255\n";
        }
}
}
}
print REPORT "mapped reads:\t $cnt[0]\nhigh quality reads(mapQ>=10):\t$cnt[1]\n";
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


sub build_PE_hash
{
  open ( IN, $MRE_f ) || die "Cannot open $MRE_f";
  my @line;
  my $site;
  my $pe_site;
  
  my $count = 0;
  if( $enzyme_num == 5 )
  {
    while ( <IN> )
    {
    @line = split /\t/;
    if ( $line[3] eq "CCGG" )
    {
      $site    = $line[0]."|".($line[1]+1)."|"."+";
      $pe_site = $line[0]."|".($line[2]-1)."|"."-";
      $CCGG_PE{ $site } = $pe_site;
      $CCGG_PE{ $pe_site } = $site;
    }
    elsif ( $line[3] eq "CCGC" || $line[3] eq "GCGG" )
    {
      $site    = $line[0]."|".($line[1]+1)."|"."+";
      $pe_site = $line[0]."|".($line[2]-1)."|"."-";
      $CCGC_PE{ $site } = $pe_site;
      $CCGC_PE{ $pe_site } = $site;
    }
    elsif ( $line[3] eq "GCGC" || $line[3] eq "GCGC" )
    {
      $site    = $line[0]."|".($line[1]+1)."|"."+";
      $pe_site = $line[0]."|".($line[2]-1)."|"."-";
      $GCGC_PE{ $site } = $pe_site;
      $GCGC_PE{ $pe_site } = $site;
    }
    elsif( $line[3] eq "ACGT" || $line[3] eq "ACGT" )
    {
      $site    = $line[0]."|".($line[1]+1)."|"."+";
      $pe_site = $line[0]."|".($line[2]-1)."|"."-";
      $ACGT_PE{ $site } = $pe_site;
      $ACGT_PE{ $pe_site } = $site;
    }
    elsif($line[3] eq "CGCG" || $line[3] eq "CGCG" )
    {
      $site    = $line[0]."|".($line[1]+2)."|"."+";
      $pe_site = $line[0]."|".($line[2]-2)."|"."-";
      $CGCG_PE{ $site } = $pe_site;
      $CGCG_PE{ $pe_site } = $site;
    }
  }# end while loop
  
  close IN;
  }#end of if statement
  
  else
  {
    while ( <IN> )
    {
    @line = split /\t/;
    if ( $line[3] eq "CCGG" )
    {
      $site    = $line[0]."|".($line[1]+1)."|"."+";
      $pe_site = $line[0]."|".($line[2]-1)."|"."-";
      $CCGG_PE{ $site } = $pe_site;
      $CCGG_PE{ $pe_site } = $site;
    }
    elsif ( $line[3] eq "CCGC" || $line[3] eq "GCGG" )
    {
      $site    = $line[0]."|".($line[1]+1)."|"."+";
      $pe_site = $line[0]."|".($line[2]-1)."|"."-";
      $CCGC_PE{ $site } = $pe_site;
      $CCGC_PE{ $pe_site } = $site;
    }
    elsif ( $line[3] eq "GCGC" || $line[3] eq "GCGC" )
    {
      $site    = $line[0]."|".($line[1]+1)."|"."+";
      $pe_site = $line[0]."|".($line[2]-1)."|"."-";
      $GCGC_PE{ $site } = $pe_site;
      $GCGC_PE{ $pe_site } = $site;
    } 
  }# end while loop
  close IN;
  }#close else loop

}#close subroutine

sub filter_reads_by_mre_sites
{
  my ( $in_f, $out_f ) = @_;
  
  #my $cnt = 0;
  my @line;
  my $site;
  my $pe_site;
  my $CpG;
  my $pe_CpG;
  
  

  
  open ( IN, $in_f ) || die "Cannot open $in_f";
  open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
  open(F1,'>CCGG_fullindex.txt');
  open(F2,'>CCGC_fullindex.txt');
  open(F3,'>GCGC_fullindex.txt');
  open(F4,'>ACGT_fullindex.txt');
  open(F5,'>CGCG_fullindex.txt');
  open(F6,'>Unknown_fullindex.txt');

  if( $enzyme_num == 5)
  {
  while ( <IN> )
  {
    @line = split /\t/;

    $site = $line[0]."|".$line[1]."|"."+";
    $pe_site = $line[0]."|".$line[2]."|"."-";
    $CpG = $line[0]."|".$line[1];
    $pe_CpG = $line[0]."|".($line[2]-2);

#    elsif ( $line[5] eq "-" )
#    {
#      $site = $line[0]."|".$line[2]."|"."-";
#      $CpG  = $line[0]."|".($line[2]-2);
      
#    }
    
    if ( defined( $CCGG_PE{$site} ) && defined( $CCGG_PE{$pe_site} ) )   # this read falls on a CCGG site
    {
      $CCGG_cnt{ $site }++;
      $CCGG_cnt{ $pe_site }++;
      $CCGG_reads++;
      print OUT;
      $CCGG_CpG{ $CpG }++;
      $CCGG_CpG{ $pe_CpG }++;
      print F1 "$line[0] \t $line[1] \t $line[2] \t $line[3] \t $line[5] \n";
    }      
    elsif ( defined( $CCGC_PE{$site} ) && defined( $CCGC_PE{$pe_site} ) )   # this read falls on a CCGC site
    {
      $CCGC_cnt{ $site }++;
      $CCGC_cnt{ $pe_site }++;
      $CCGC_reads++;
      print OUT;
      $CCGC_CpG{ $CpG }++;
      $CCGC_CpG{ $pe_CpG }++;
      print F2 "$line[0] \t $line[1] \t $line[2] \t $line[3] \t $line[5] \n";
    }
    elsif ( defined( $GCGC_PE{$site} ) && defined( $GCGC_PE{$pe_site} ) )   # this read falls on a CCGG site
    {
      $GCGC_cnt{ $site }++;
      $GCGC_cnt{ $pe_site }++;
      $GCGC_reads++;
      print OUT;
      $GCGC_CpG{ $CpG }++;
      $GCGC_CpG{ $pe_CpG }++;
      print F3 "$line[0] \t $line[1] \t $line[2] \t $line[3] \t $line[5] \n";
    }
    elsif ( defined( $ACGT_PE{$site} ) && defined( $ACGT_PE{$pe_site} ) )   # this read falls on a ACGT site
    {
      $ACGT_cnt{ $site }++;
      $ACGT_cnt{ $pe_site }++;
      $ACGT_reads++;
      print OUT;
      $ACGT_CpG{ $CpG }++;
      $ACGT_CpG{ $pe_CpG }++;
      print F4 "$line[0] \t $line[1] \t $line[2] \t $line[3] \t $line[5] \n";
    }
    elsif ( defined( $CGCG_PE{$site} ) && defined( $CGCG_PE{$pe_site} ) )   # this read falls on a CGCG site [but count for CpG would be doubled due to 2 CpG's]
    {
	    $CGCG_cnt{ $site }++;
	    $CGCG_cnt{ $pe_site }++;
            $CGCG_reads++;
	    print OUT;
            $CGCG_CpG{ $CpG }++;
	    $CGCG_CpG{ $pe_CpG }++;
	    print F5 "$line[0] \t $line[1] \t $line[2] \t $line[3] \t $line[5] \n";
	     
    }
    else 
    {
      print F6 "$line[0] \t $line[1] \t $line[2] \t $line[3] \t $line[5] \n";
    }
  }#close while loop
  }#close if loop
  
  else
  {
    while ( <IN> )
  {
    @line = split /\t/;
    if ( $line[5] eq "+" )
    {
      $site = $line[0]."|".$line[1]."|"."+";
      $CpG  = $line[0]."|".$line[1];
    }
    elsif ( $line[5] eq "-" )
    {
      $site = $line[0]."|".$line[2]."|"."-";
      $CpG  = $line[0]."|".($line[2]-2);
    }
    
    # Currently handles only three non-overlapping enzyme.
    # Need more work to add ACGT and CGCG sites
    if ( defined( $CCGG_PE{$site} ) )   # this read falls on a CCGG site
    {
      $CCGG_cnt{ $site }++;
      $CCGG_reads++;
      print OUT;
      $CCGG_CpG{ $CpG }++;
    }
    elsif ( defined( $CCGC_PE{$site} ) )   # this read falls on a CCGC site
    {
      $CCGC_cnt{ $site }++;
      $CCGC_reads++;
      print OUT;
      $CCGC_CpG{ $CpG }++;
    }
    elsif ( defined( $GCGC_PE{$site} ) )   # this read falls on a CCGG site
    {
      $GCGC_cnt{ $site }++;
      $GCGC_reads++;
      print OUT;
      $GCGC_CpG{ $CpG }++;
    }
  }#close while loop
  }#close else loop
  print REPORT "mre filtered reads:\t", $CCGG_reads+$CCGC_reads+$GCGC_reads+$ACGT_reads+$CGCG_reads, "\n";
  print REPORT "    CCGG reads:\t", $CCGG_reads, "\n";
  print REPORT "    CCGC reads:\t", $CCGC_reads, "\n";
  print REPORT "    GCGC reads:\t", $GCGC_reads, "\n";
  print REPORT "    ACGT reads:\t", $ACGT_reads, "\n";
  print REPORT "    CGCG reads:\t", $CGCG_reads, "\n";
  close IN;
  close OUT;  
  close F1;
  close F2;
  close F3;
  close F4;
  close F5;
  close F6
  
}

sub calculate_CpG_score
{
  my ( $out_f ) = @_;
  my $CCGG_mil = $CCGG_reads/1000000;
  my $CCGC_mil = $CCGC_reads/1000000;
  my $GCGC_mil = $GCGC_reads/1000000;
  my $ACGT_mil = $ACGT_reads/1000000;
  my $CGCG_mil = $CGCG_reads/1000000;
  
  my $cnt;
  
  my @CpG;
  push @CpG, (keys %CCGG_CpG);
  push @CpG, (keys %CCGC_CpG);
  push @CpG, (keys %GCGC_CpG);
  push @CpG, (keys %ACGT_CpG);
  push @CpG, (keys %CGCG_CpG);
  
  #foreach my $key ( keys %CCGG_CpG )
  #{
  #  add_item_to_array( $key, \@CpG );
  #}
  #print REPORT "Sampled CpG sites:\t", $#CpG+1, "\n";
  #foreach my $key ( keys %CCGC_CpG )
  #{
  #  add_item_to_array( $key, \@CpG );
  #}
  #print REPORT "Sampled CpG sites:\t", $#CpG+1, "\n";
  #foreach my $key ( keys %GCGC_CpG )
  #{
  #  add_item_to_array( $key, \@CpG );
  #}
  @CpG = sort @CpG;
  print REPORT "Sampled CpG sites:\t", $#CpG+1, "\n";
  
  open ( OUT, ">$out_f" ) || die "Cannot open $out_f";
  my $rcme;
  my @line;
  for ( my $i=0; $i<=$#CpG; $i++ )
  {
    $rcme = 0;
    @line = split /\||\n/, $CpG[$i];
    if ( defined( $CCGG_CpG{ $CpG[$i] } ) )
    {
      $rcme += $CCGG_CpG{ $CpG[$i] }/$CCGG_mil;
    }
    if ( defined( $CCGC_CpG{ $CpG[$i] } ) )
    {
      $rcme += $CCGC_CpG{ $CpG[$i] }/$CCGC_mil;
    }
    if ( defined( $GCGC_CpG{ $CpG[$i] } ) )
    {
      $rcme += $GCGC_CpG{ $CpG[$i] }/$GCGC_mil;
    }
    if ( defined( $ACGT_CpG{ $CpG[$i] } ) )
    {
      $rcme += $ACGT_CpG{ $CpG[$i] }/$ACGT_mil;
    }
    if ( defined( $CGCG_CpG{ $CpG[$i] } ) )
    {
      $rcme += $CGCG_CpG{ $CpG[$i] }/$CGCG_mil;
    }
    print OUT $line[0], "\t", $line[1], "\t", $line[1]+2, "\t";
    printf OUT "%.4f\n", $rcme;
  }
  close OUT;
} 

sub add_item_to_array
{
  my ( $item, $a_r ) = @_;
  if ( !array_has( $a_r, $item ) )
  {
    push @$a_r, $item;
  }
}

sub array_has
{
  my ( $a_r, $item ) = @_;
  for ( my $i=0; $i<=$#$a_r; $i++ )
  {
    if ( $item eq $a_r->[$i] )
    {
      return 1;
    }
  }
  return 0;
}

sub fragment_stats
{
  my $high_end = 0;
  my $low_end = 0;
  my $solo_site = 0;
  my $solo_reads = 0;
  my $pair_site = 0;
  my @frags;
  my $pe;
  my %paired; # keep a record of ends that got paired
  my @left;
  my @right;
  
  foreach my $key ( keys %CCGG_cnt )
  {
    $pe = $CCGG_PE{$key};
    
    if ( !defined( $paired{$key} ) )
    {
      if ( defined( $CCGG_cnt{$pe} ) )
      {
        # a valid fragment
        $pair_site++;
        @left = split /\|/, $key;
        @right = split /\|/, $pe;
        push @frags, abs($right[1]-$left[1]);
        $paired{ $pe } = 1;
        if ( $CCGG_cnt{$key} >= $CCGG_cnt{$pe} )
        {
          $high_end += $CCGG_cnt{$key};
          $low_end += $CCGG_cnt{$pe};
        }
        else
        {
          $high_end += $CCGG_cnt{$pe};
          $low_end += $CCGG_cnt{$key};
        }
      }
      else
      {
        $solo_reads += $CCGG_cnt{$key};
        $solo_site ++;
      }
    }
  }
  
 foreach my $key ( keys %CCGC_cnt )
  {
    $pe = $CCGC_PE{$key};
    
    if ( !defined( $paired{$key} ) )
    {
      if ( defined( $CCGC_cnt{$pe} ) )
      {
        # a valid fragment
        $pair_site++;
        @left = split /\|/, $key;
        @right = split /\|/, $pe;
        push @frags, abs($right[1]-$left[1]);
        #if ( $right[1]-$left[1]<50 )
        #{
        #  print $key, "\t", $pe, "\n";
        #}
        $paired{ $pe } = 1;
        if ( $CCGC_cnt{$key} >= $CCGC_cnt{$pe} )
        {
          $high_end += $CCGC_cnt{$key};
          $low_end += $CCGC_cnt{$pe};
        }
        else
        {
          $high_end += $CCGC_cnt{$pe};
          $low_end += $CCGC_cnt{$key};
        }
      }
      else
      {
        $solo_reads += $CCGC_cnt{$key};
        $solo_site ++;
      }
    }
  }
  
  foreach my $key ( keys %GCGC_cnt )
  {
    $pe = $GCGC_PE{$key};
    
    if ( !defined( $paired{$key} ) )
    {
      if ( defined( $GCGC_cnt{$pe} ) )
      {
        # a valid fragment
        $pair_site++;
        @left = split /\|/, $key;
        @right = split /\|/, $pe;
        push @frags, abs($right[1]-$left[1]);
        $paired{ $pe } = 1;
        if ( $GCGC_cnt{$key} >= $GCGC_cnt{$pe} )
        {
          $high_end += $GCGC_cnt{$key};
          $low_end += $GCGC_cnt{$pe};
        }
        else
        {
          $high_end += $GCGC_cnt{$pe};
          $low_end += $GCGC_cnt{$key};
        }
      }
      else
      {
        $solo_reads += $GCGC_cnt{$key};
        $solo_site ++;
      }
    }
  }
  foreach my $key ( keys %ACGT_cnt )
  {
    $pe = $ACGT_PE{$key};
    
    if ( !defined( $paired{$key} ) )
    {
      if ( defined( $ACGT_cnt{$pe} ) )
      {
        # a valid fragment
        $pair_site++;
        @left = split /\|/, $key;
        @right = split /\|/, $pe;
        push @frags, abs($right[1]-$left[1]);
        $paired{ $pe } = 1;
        if ( $ACGT_cnt{$key} >= $ACGT_cnt{$pe} )
        {
          $high_end += $ACGT_cnt{$key};
          $low_end += $ACGT_cnt{$pe};
        }
        else
        {
          $high_end += $ACGT_cnt{$pe};
          $low_end += $ACGT_cnt{$key};
        }
      }
      else
      {
        $solo_reads += $ACGT_cnt{$key};
        $solo_site ++;
      }
    }
  }
   foreach my $key ( keys %CGCG_cnt )
  {
    $pe = $CGCG_PE{$key};
    
    if ( !defined( $paired{$key} ) )
    {
      if ( defined( $CGCG_cnt{$pe} ) )
      {
        # a valid fragment
        $pair_site++;
        @left = split /\|/, $key;
        @right = split /\|/, $pe;
        push @frags, abs($right[1]-$left[1]);
        $paired{ $pe } = 1;
        if ( $CGCG_cnt{$key} >= $CGCG_cnt{$pe} )
        {
          $high_end += $CGCG_cnt{$key};
          $low_end += $CGCG_cnt{$pe};
        }
        else
        {
          $high_end += $CGCG_cnt{$pe};
          $low_end += $CGCG_cnt{$key};
        }
      }
      else
      {
        $solo_reads += $CGCG_cnt{$key};
        $solo_site ++;
      }
    }
  }
  
  
  print REPORT "solo ends:\t", $solo_site, "\n";
  print REPORT "    reads on solo ends:\t", $solo_reads, "\n";
  print REPORT "fragments:\t", $pair_site, "\n";
  print REPORT "    reads on higher end of fragments:\t", $high_end, "\n";
  print REPORT "    reads on lower end of fragments:\t", $low_end, "\n";
  print REPORT "fragment size distribution:\n";
  
  histograph( \@frags, 20, 40, 400 );
  
}

sub histograph
{
  my ( $data_r, $win, $min, $max ) = @_;
  
  my @histo;
  my @scale;
  my $total = 0;
  my $histo_min = 0;
  my $histo_max = 0;

  for ( my $i=$min, my $j=0; $i<=$max; $i+=$win, $j++ )
  {
    $scale[$j][0] = $i;
    $scale[$j][1] = $i+$win;
    $histo[$j] = 0;
  }
  $scale[$#scale][1] = $max;
  
  for ( my $i=0; $i<=$#$data_r; $i++ )
  {
    $total++;
    if ( $data_r->[$i] <= $min )
    {
      $histo_min++;
    }
    elsif ( $data_r->[$i] > $max )
    {
      $histo_max++;
    }
    else
    {
      for ( my $j=0; $j<=$#scale; $j++ )
      {
        if ( $data_r->[$i]>$scale[$j][0] && $data_r->[$i]<=$scale[$j][1] )
        {
          $histo[$j]++;
          last;
        }
      }
    }
  }
  
  printf REPORT "%s\t%10s\t%10s\t|\n", "Scale", "Count", "Percent";
  printf REPORT "%s\t%10d\t%10.2f\t|", "<=$min", $histo_min, $histo_min/$total*100;
  print_bar ( int($histo_min/$total*100) );
  for ( my $i=0; $i<=$#histo; $i++ )
  {
    printf REPORT "%s\t%10d\t%10.2f\t|", $scale[$i][1], $histo[$i], $histo[$i]/$total*100;
    print_bar ( int($histo[$i]/$total*100) );
  }
  printf REPORT "%s\t%10d\t%10.2f\t|", ">$max", $histo_max, $histo_max/$total*100;
  print_bar ( int($histo_max/$total*100) );
}
  
sub print_bar
{
  my ( $cnt ) = @_;
  for ( my $i=0; $i<$cnt; $i++ )
  {
    print REPORT "*";
  }
  print REPORT "\n";
}
  
  
  
  
  
  
  
