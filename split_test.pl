#!/usr/bin/perl
##
## Mingchao's code to process MRE raw data. It parses the raw data and output 
## reads into different groups based on indexes. 
## 111014
##
## Indexes: TAGAATC, CTCCATC,GGTTATC
## This code is to test if this new code can give me more Control raw reads from
## the s_6 raw data. let's see if it works. I only care GGTTATC indexed reads.
##

my ($in_f, $out_f1, $out_f2, $out_f3, $out_f4) = @ARGV;
my $seq;
my $score;
my $n =0;
open (IN, $in_f) || die "cannot inf\n";
open (OUT1, "> $out_f1") || die "cannot out_f1\n";
open (OUT2, "> $out_f2") || die "cannot out_f2\n";
open (OUT3, "> $out_f3") || die "cannot out_f3\n";
open (OUT4, "> $out_f4") || die "cannot out_f4\n";

while (my $line1=<IN>)
{
	chomp $line1;
	my @temp=split /\:/,$line1;
        my $id=join ":","@",@temp[0..4];
        my $line=$temp[5];
	my $len = length($line) - 7;
        my $value=$temp[6];
	if ($line =~ /TAGAATC$/)
	{
		$seq = substr($line, 0, $len);		
		$score = substr($value, 0, $len);
		print OUT1 "$id\n$seq\n+\n$score\n";
		next;
	}
	elsif ($line =~ /ACAGATC$/) 
        {	
			$seq = substr ($line, 0, $len);
            $score = substr($value, 0, $len);
            print OUT2 "$id\n$seq\n+\n$score\n";
			next;
        }
        elsif ($line =~ /GGTTATC$/)
        {
                $seq = substr ($line, 0, $len);
                $score = substr($value, 0, $len);
                print OUT3 "$id\n$seq\n+\n$score\n";
                next;
        }
        else
        {
	        	print OUT4 "$line1\n";
	}
}

