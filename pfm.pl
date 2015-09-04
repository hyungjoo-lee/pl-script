#!/usr/bin/perl -w
use strict;

my $usage = "Usage: perl $0 <pfm files> \n";

die $usage unless @ARGV;

my @in_f = @ARGV;
for (@in_f) {
	my $out_f = $_;
	$out_f =~ s/(w*\/)*//;
	open IN, $_ or die "Cannot open $_ file.\n";
	open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
	my $cnt = 0;
	my @nt = ("A", "C", "G", "T") ;
	while (<IN>) {
		print OUT "$nt[$cnt] $_";
		$cnt++;
	}
	close IN;
	close OUT;
}
exit;
