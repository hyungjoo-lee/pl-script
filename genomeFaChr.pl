#!/usr/bin/perl -w

use strict;
die unless @ARGV;
my ($fa_f) = @ARGV;
open FA, $fa_f or die "Cannot open $fa_f file.\n";
my $start = 0;
while (<FA>) {
	if (/>(\w+)/) {
		close OUT unless ($start == 0);
		my $out_f = $1.".fa";
		open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
		print OUT;
		$start = 1;
	} else {
		print OUT;
	}
}
close OUT;
close FA;

