#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <fasta file> <patser input format output file>\n";

die $usage unless @ARGV;

my ($fa_f, $out_f) = @ARGV;
open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
open IN, $fa_f or die "Cannto open $fa_f file.\n";
my $seq = "";
my $cnt = 0;
while (<IN>) {
	chomp;
	if (/^>/) {
		print OUT "\n\\$seq\\\n" unless ($cnt == 0);
		$seq = "";
		$_ =~ s/>//;
		print OUT;
		$cnt++;
	} else {
		$seq .= $_;
	}
}
print OUT "\\$seq\\\n";
close IN;
close OUT;
exit;
