#!/usr/bin/perl -w

## This code converts raw sequencing reads with index from GTAC into fastq file.
## This code was modified by Hyung Joo from Mingchao's illumina2fastq.pl.
## You can add more indexes. Here 6 indexes are shown.

if (@ARGV != 2) {
	die "\n Usage: perl $0 <raw sequencing reads.txt> <fastq file>\n";
} 

my ($file, $out_f) = @ARGV;
my @out;
for (my $i = 0; $i < 7; $i++) {
	$out[$i] = $out_f."_ind".$i;
}

open (IN, $file) || die "Cannot open $file";
open (OUT1, ">$out[1]") || die "Cannot open $out[1]";
open (OUT2, ">$out[2]") || die "Cannot open $out[2]";
open (OUT3, ">$out[3]") || die "Cannot open $out[3]";
open (OUT4, ">$out[4]") || die "Cannot open $out[4]";
open (OUT5, ">$out[5]") || die "Cannot open $out[5]";
open (OUT6, ">$out[6]") || die "Cannot open $out[6]";
open (OUT0, ">$out[0]") || die "Cannot open $out[0]";

while (<IN>) {
	chomp;
	my @temp = split /\:/;
	my $id = join ":","@",@temp[0..4];
	my $length = length($temp[5]) - 7;
	my $seq = substr($temp[5], 0, $length);
	my $score = substr($temp[6], 0, $length);
	if ($temp[5] =~ /TGAGGTT$/) {
		print OUT1 "$id\n$seq\n+\n$score\n";
	} elsif ($temp[5] =~ /GCTTAGA$/) {
                print OUT2 "$id\n$seq\n+\n$score\n";
        } elsif ($temp[5] =~ /ATGACAG$/) {
                print OUT3 "$id\n$seq\n+\n$score\n";
        } elsif ($temp[5] =~ /CACCTCC$/) {
                print OUT4 "$id\n$seq\n+\n$score\n";
        } elsif ($temp[5] =~ /ATCGAGC$/) {
                print OUT5 "$id\n$seq\n+\n$score\n";
        } elsif ($temp[5] =~ /TACTCTA$/) {
                print OUT6 "$id\n$seq\n+\n$score\n";
        } else {
		print OUT0 "$id\n$seq\n+\n$score\n";
	}
}
close IN;
close OUT1;
close OUT2;
close OUT3;
close OUT4;
close OUT5;
close OUT6;
close OUT0;
