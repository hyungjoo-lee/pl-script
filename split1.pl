#!/usr/bin/perl
##
## Mingchao's code to process MRE raw data. It parses the raw data and output 
## reads into different groups based on indexes. 
## 111011
##
## Indexes: GGTTATC
##

my ($in_f, $out_f1) = @ARGV;
my $seq;
my $score;
my $n =0;
open (IN, $in_f) || die "cannot inf\n";
open (OUT1, "> $out_f1") || die "cannot out_f1\n";

while (my $line1=<IN>)
{
	chomp $line1;
	my @temp=split /\:/,$line1;
        my $id=join ":","@",@temp[0..4];
        my $line=$temp[5];
	my $len = length($line) - 7;
        my $value=$temp[6];
	if ($line =~ /GGTTATC$/)
	{
		$seq = substr($line, 0, $len);		
		$score = substr($value, 0, $len);
		print OUT1 "$id\n$seq\n+\n$score\n";
		next;
	}
}

close IN;
close OUT1;

