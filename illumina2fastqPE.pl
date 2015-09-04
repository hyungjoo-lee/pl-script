#!/usr/bin/perl -w

## This code converts raw sequencing reads with index from GTAC into fastq file.
## This code was modified by Hyung Joo from Mingchao's illumina2fastq.pl.
## You can add more indexes. Here 6 indexes are shown.

if (@ARGV != 2) {
	die "\n Usage: perl $0 <PEreads1.txt> <PEreads2.txt> \n";
} 

my ($in_f1, $in_f2) = @ARGV;
my %index;

my @out;

## PE reads 1 file
#for (my $i = 0; $i < 7; $i++) {
#        $out[$i] = substr($in_f1, 29, 5)."_ind".$i;
#}
open (IN, $in_f1) || die "Cannot open $in_f1";
#open (OUT1, ">$out[1]") || die "Cannot open $out[1]";
#open (OUT2, ">$out[2]") || die "Cannot open $out[2]";
#open (OUT3, ">$out[3]") || die "Cannot open $out[3]";
#open (OUT4, ">$out[4]") || die "Cannot open $out[4]";
#open (OUT5, ">$out[5]") || die "Cannot open $out[5]";
#open (OUT6, ">$out[6]") || die "Cannot open $out[6]";
#open (OUT0, ">$out[0]") || die "Cannot open $out[0]";

while (<IN>) {
	chomp;
	my @temp = split /\:/;
	my $id = join ":","@",@temp[0..4];
	my $index = substr ($id, 0, -1);
	my $length = length($temp[5]) - 7;
	my $seq = substr($temp[5], 0, $length);
	my $score = substr($temp[6], 0, $length);
	if ($temp[5] =~ /TGAGGTT$/) {
#		print OUT1 "$id\n$seq\n+\n$score\n";
		$index{$index} = 1;
	} elsif ($temp[5] =~ /GCTTAGA$/) {
#               print OUT2 "$id\n$seq\n+\n$score\n";
                $index{$index} = 2;
        } elsif ($temp[5] =~ /ATGACAG$/) {
#                print OUT3 "$id\n$seq\n+\n$score\n";
                $index{$index} = 3;
        } elsif ($temp[5] =~ /CACCTCC$/) {
#                print OUT4 "$id\n$seq\n+\n$score\n";
                $index{$index} = 4;
        } elsif ($temp[5] =~ /ATCGAGC$/) {
#                print OUT5 "$id\n$seq\n+\n$score\n";
                $index{$index} = 5;
        } elsif ($temp[5] =~ /TACTCTA$/) {
#                print OUT6 "$id\n$seq\n+\n$score\n";
                $index{$index} = 6;
        } else {
#		print OUT0 "$id\n$seq\n+\n$score\n";
                $index{$index} = 0;
	}
}
close IN;
#close OUT1;
#close OUT2;
#close OUT3;
#close OUT4;
#close OUT5;
#close OUT6;
#close OUT0;

##PE reads2 file
for (my $i = 0; $i < 7; $i++) {
        $out[$i] = substr($in_f2, 29, 5)."_ind".$i;
}
open (IN, $in_f2) || die "Cannot open $in_f2";
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
	my $index = substr ($id, 0, -1);
        my $seq = $temp[5];
        my $score = $temp[6];
        if ($index{$index} == 1) {
                print OUT1 "$id\n$seq\n+\n$score\n";
	} elsif ($index{$index} == 2) {
                print OUT2 "$id\n$seq\n+\n$score\n";
        } elsif ($index{$index} == 3) {
                print OUT3 "$id\n$seq\n+\n$score\n";
        } elsif ($index{$index} == 4) {
                print OUT4 "$id\n$seq\n+\n$score\n";
        } elsif ($index{$index} == 5) {
                print OUT5 "$id\n$seq\n+\n$score\n";
        } elsif ($index{$index} == 6) {
                print OUT6 "$id\n$seq\n+\n$score\n";
        } elsif ($index{$index} == 0) {
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
