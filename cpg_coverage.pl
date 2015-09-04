#!/usr/bin/perl -w
# cpg_coverage.pl generates coverage of MeDIP-seq data on each CpG site.
# July 19, 2012 
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> <MeDIP bedGraph file>\n";

die $usage unless @ARGV;

my ($genome, $in_f, ) = @ARGV;
my $name = $in_f;
$name =~ s/.bedGraph$//;
my $out_f = $name.".CpG.bedGraph";
my $rep_f = $name.".CpG.report";
my $r_f = $name.".CpG.R";
my ($size_f, $cpg_f, );

if ($genome eq "hg19") {
	$size_f = "/home/hyungjoo/genomes/hg19/hg19_chrom_sizes";
	$cpg_f = "/home/hyungjoo/genomes/hg19/CpG/CpG_sites.bed";
} elsif ($genome eq "danRer7") {
	$size_f = "/home/hyungjoo/genomes/danRer7_database/chr.size";
	$cpg_f = "/home/hyungjoo/genomes/danRer7_database/MRE/CpG_sites.bed";
} else {
	die "Cannot find database. Now only hg19 or danRer7\n";
}

my %chr_size;
get_chr_size (\%chr_size, $size_f);

open IN, $in_f or die "Cannot open $in_f.\n";
open CPG, $cpg_f or die "Cannot open $cpg_f.\n";
open OUT, ">$out_f" or die "Cannot open $out_f.\n";

my @cover = () ;
my $max = 0;
my $line = undef;
while (<CPG>) {
	chomp;
	my @cpg_line = split;
	my $done = 0;
	next if $cpg_line[0] =~ /^Zv9/;
	while ( !$done ) {
		last if eof(CPG);
		$line = <IN> if !defined($line) ;
		my @line = split "\t", $line;
		last if $line =~ /^chrM/;
		if ( ( $cpg_line[0] eq $line[0] ) && ( $cpg_line[1] < $line[2] ) && ( $cpg_line[2] > $line[1] ) ) {
			print OUT "$cpg_line[0]\t$cpg_line[1]\t$cpg_line[2]\tCpG\t$line[3]";
			$cover[$line[3]]++;
			$max = $line[3] if ($max < $line[3]);
			$done = 1;
		} elsif ( ( $cpg_line[0] lt $line[0] ) || ( $cpg_line[0] eq $line[0] && $cpg_line[2] <= $line[1]) ) {
			print OUT "$cpg_line[0]\t$cpg_line[1]\t$cpg_line[2]\tCpG\t0\n";
			$cover[0]++;
			$done = 1;
		} else {
			$line = undef;
			next;
		}
	}
}
close OUT;
close CPG;
close IN;

my @cover_cum = @cover;
my $total = $max * $cover[$max];
for (my $i=$max-1; $i>0; $i--) {
	$cover[$i] = 0 unless defined $cover[$i];
	$cover_cum[$i] = 0 unless defined $cover_cum[$i];
	$total += $i * $cover[$i];
	$cover_cum[$i] += $cover_cum[$i+1];
}

my $cpg_cnt = `wc -l $out_f`;
$cpg_cnt =~ s/^(\d*)\s*.*$/$1/;
my $avg = $total / $cpg_cnt;
open REP, ">$rep_f" or die "Cannot open $rep_f.\n";
printf REP "Total number of CpGs tested:\t%10d\n", $cpg_cnt;
printf REP "Number of uncovered CpGs:\t%10d\n", $cover_cum[0];
printf REP "min 1-fold covered CpGs:\t%10d\n", $cover_cum[1];
printf REP "min 2-fold covered CpGs:\t%10d\n", $cover_cum[2];
printf REP "min 3-fold covered CpGs:\t%10d\n", $cover_cum[3];
printf REP "min 4-fold covered CpGs:\t%10d\n", $cover_cum[4];
printf REP "min 5-fold covered CpGs:\t%10d\n", $cover_cum[5];
printf REP "min 10-fold covered CpGs:\t%10d\n", $cover_cum[10];
printf REP "Average CpG coverage:\t%3.1f-fold\n", $avg;
close REP;

#open RFILE, ">$r_f" or die "Cannot open $r_f.\n";
#print RFILE "png(\"$name.CpG.png\", res=72)\n";
#print RFILE "plot(c(1:$max), c(";
#for (my $i = 1; $i <= $max; $i++) {
#	print RFILE "$cover_cum[$i]";
#	print RFILE "," unless ($i == $max);
#}
#print RFILE "), type='l', lwd=4, col='#004080', xlab='Minimum Fold Coverage', ylab='Number of Covered CpGs', xlim=c(0, $max))\n";
#print RFILE "dev.off()\n";
#close RFILE;

#system "R CMD BATCH $r_f";


#############
#Subroutines#
#############

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
