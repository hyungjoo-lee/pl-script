#!/usr/bin/perl -w

## This code generates separate fastq files according to index fastq file.
## 

use strict;

die "\n Usage: perl $0 <index.fastq> <read.fastq> <fastq file name>\n" unless @ARGV;

my ($index_f, $in_f, $name) = @ARGV;
my @out_f;
for (my $i = 0; $i < 7; $i++) {
	$out_f[$i] = $name.".ind".$i.".fastq";
}

my $line_cnt = 0;
my $index;
my @cnt = (0, 0, 0, 0, 0, 0, 0, 0);
my $in_line = "";
open (INDEX, $index_f) or die "Cannot open $index_f file.\n";
open (IN, $in_f) or die "Cannot open $in_f file.\n";
open (OUT2, ">$out_f[2]") or die "Cannot open $out_f[2]\n";
open (OUT6, ">$out_f[6]") or die "Cannot open $out_f[6]\n";
open (OUT0, ">$out_f[0]") or die "Cannot open $out_f[0]\n";
while (<INDEX>) {
	$line_cnt++;
	$in_line .= <IN>;
	if ( $line_cnt % 4 == 2) {
		if (/GCTTAGA/) {
			$cnt[2]++;
			$index = 2;
		} elsif (/TACTCTA/) {
			$cnt[6]++;
			$index = 6;
		} else {
			$cnt[7]++;
			$index = 0;
		}
	} elsif ( $line_cnt % 4 == 0) {
		print OUT2 $in_line if ($index == 2);
		print OUT6 $in_line if ($index == 6);
		print OUT0 $in_line if ($index == 0);
		$in_line = "";
		$cnt[0]++;
	}
}
close OUT2;
close OUT6;
close OUT0;
close IN;
close INDEX;
printf "\nTotal Raw Reads:\t%10d\n", $cnt[0];
printf "Index 2:GCTTAGA Reads:\t%10d\n", $cnt[2];
printf "Index 6:TACTCTA Reads:\t%10d\n", $cnt[6];
printf "Unknown Index Reads:\t%10d\n", $cnt[7];
exit;
