#!/usr/bin/perl -w

my ($file, $out_f) = @ARGV;
my @temp;
my @score;

open (IN,$file) || die "Cannot open $file";
open (OUT, ">$out_f") || die "Cannot open $out_f";
while (<IN>){
    chomp;
    @temp=split /\:/,$_;
    my $id=join ":","@",@temp[0..4];
    my $seq=$temp[5];
    my $score=$temp[6];
    print OUT "$id\n$seq\n+\n$score\n";
}
close IN;
close OUT;
