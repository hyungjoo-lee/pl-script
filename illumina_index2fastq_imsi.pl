#!/usr/bin/perl -w

my ($file, $out_f) = @ARGV;
my @out;
for (my $i = 1; $i < 13; $i++) {
	$out[$i] = $out_f."ind".$i;
}

open (IN, $file) || die "Cannot open $file";
open (OUT1, ">$out[1]") || die "Cannot open $out[1]";
open (OUT2, ">$out[2]") || die "Cannot open $out[2]";
open (OUT3, ">$out[3]") || die "Cannot open $out[3]";
open (OUT4, ">$out[4]") || die "Cannot open $out[4]";
open (OUT5, ">$out[5]") || die "Cannot open $out[5]";
open (OUT6, ">$out[6]") || die "Cannot open $out[6]";

while (<IN>) {
	chomp;
	my @temp = split /\:/;
	my $id = join ":","@",@temp[0..4];
	my $seq = $temp[5];
	my $score = $temp[6];
	if ($seq =~ /TGAGGTT$/) {
		print OUT1 "$id\n$seq\n+\n$score\n";
#	} elsif ($seq =~ /GCTTAGA$/) {
#                print OUT2 "$id\n$seq\n+\n$score\n";
#        } elsif ($seq =~ /ATGACAG$/) {
#                print OUT3 "$id\n$seq\n+\n$score\n";
#        } elsif ($seq =~ /CACCTCC$/) {
#                print OUT4 "$id\n$seq\n+\n$score\n";
#        } elsif ($seq =~ /ATCGAGC$/) {
#                print OUT5 "$id\n$seq\n+\n$score\n";
#        } elsif ($seq =~ /TACTCTA$/) {
#                print OUT6 "$id\n$seq\n+\n$score\n";
        }
}
close IN;
close OUT1;
close OUT2;
close OUT3;
close OUT4;
close OUT5;
close OUT6;

