#!/usr/bin/perl -w
use strict; 
die "perl $0 <genome> <input bed file> <extend bp> STDOUT > output bed \n" unless @ARGV;

my ( $database, $in_f, $base ) = @ARGV;
my $cnt = 0;
my @line;
my %chr_size;
my $size_f;
if ( $database eq "hg18" )
  {
    $size_f = "/hive/groups/remc/data/hg/hg18_chrom_sizes";
  }
elsif ( $database eq "mm9" )
  {
    $size_f = "/hive/groups/remc/data/mm/mm9/mm9_chrom_sizes";
  }
elsif ( $database eq "danRer7" )
  {
    $size_f = "/data/genomes/danRer7/chr.size";
  }

my $genome_size = get_chr_sizes( \%chr_size, $size_f );
  
open ( IN, $in_f ) || die "Cannot open $in_f";
  
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
		  print $line[$i], "\t";
	  }
	  print 0, "\t", 0, "\t";
      if ( $line[5] eq "+" )
      {
        print "255,0,0\n";
      }
      else
      {
        print "0,0,255\n";
      }
  }
close IN;
exit;

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

