#!/usr/bin/perl -w
# Author: Hyung Joo Lee
# Date: July 5, 2012
# This code plots the number DMRs which has p-values less than a certain value. p-values can be generated by either  MEDIPS or M and M analysis.

use strict;
my $usage = '
Usage: perl $0 <genome> <method of DMR analysis> <input file> <output name>
genome: hg19 or danRer7 available now
method of DMR analysis: 1 MEDIPS / 2 M and M
input file: diff.txt for MEDIPS or pval.bed for MM
';

die $usage unless @ARGV;

my ($genome, $method, $in_f, $name) = @ARGV;
my $size_f;
my %chr_size;

if ($genome eq "hg19") {
	$size_f = "/home/hyungjoo/genomes/hg19/hg19_chrom_sizes";
} elsif ($genome eq "danRer7") {
	$size_f = "/home/hyungjoo/genomes/danRer7_database/chr.size";
} else {
	die "Cannot find genome. Now only hg19 or danRer7 available.\n";
}
get_chr_size (\%chr_size, $size_f);

my %cnt = ();
my $cnt = -1;
open IN, "$in_f" or die "Cannot open $in_f file.\n";
while (<IN>) {
	if ($cnt == -1) {
		$cnt++;
		next;
	}
	my $pval = get_pval ($_, $method);
	if ($pval == 0) {
		$cnt++;
		next;
	}
	my $log_p = - ( (log $pval) / (log 10) );
	$log_p = int $log_p;
	$cnt{$log_p}++;
}
close IN;

my $max = 0;
for my $key (sort keys %cnt) {
	$max = $key if ($max < $key);
}

open REP, ">$name.rep" or die "Cannot open $name.rep file.\n";
print REP "-Log10(pvalue)\tNumber of DMRs\n";
my @cnt;
$cnt[$max] = $cnt{$max};
printf REP "%2d\t%10d\n", $max, $cnt[$max];
for (my $i = $max-1; $i >= 0; $i--) {
	$cnt[$i] = (exists $cnt{$i}) ? $cnt{$i} : 0;
	$cnt[$i] += $cnt[$i+1];
	$cnt[$i] += $cnt if ($i ==0);
	printf REP "%2d\t%10d\n", $i, $cnt[$i];
}
close REP;

open OUT, ">$name.R" or die "Cannot open $name.R file.\n";
print OUT "png(\"$name.png\", res=72)\n";
print OUT "plot(c(0:$max), c(";
for (my $i = 0; $i <= $max; $i++) {
	my $y = $cnt[$i] + 1 ;
	$y = (log $y) / (log 10);
	print OUT "$y";
	print OUT "," unless ($i == $max);
}
print OUT "), type='l', lwd=4, xaxt='n', col='#004080', xlab='-log10(pvalue)', ylab='Number of DMRs', xlim=c(0, $max))\n";
print OUT "dev.off()\n";
close OUT;

system "R CMD BATCH $name.R";



#-----------#
#Subroutines#
#-----------#

sub get_chr_size {
  my ( $chr_r, $file ) = @_;
  my $size = 0;
  open ( IN, $file ) || die "Cannot open $file.";
  while ( <IN> ) {
	chomp;
	my @line = split;
	$chr_r -> {$line[0]} = $line[1];
	$size += $line[1];
  }
  close IN;
  return $size;
}

sub get_pval {
  my ( $line, $method ) = @_;
  if ($method == 1) {
	my @line = split "\t", $line;
	return pop @line;
  } elsif ($method == 2) {
	my @line = split ",", $line;
	return $line[9];
  } else {
	die "\ninvalid method of analysis option\n";
  }
}
