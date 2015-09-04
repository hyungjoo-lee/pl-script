#!/usr/bin/perl -w
# This merges all rpkm values from different iteres.stat files into one file. 
# August 21, 2012
# Author: Hyung Joo Lee

use strict;

my $usage = "perl $0 <rpkm_1k_bin input files> <merged rpkm output file>\n";

die $usage unless @ARGV;

my $out_f = pop @ARGV;
my @in_f = @ARGV;
my @tmp_f;
my $tmp_f = "tmp.$$";
my @lib_name = @in_f;

my $paste = "paste $tmp_f ";
my $header = "#chr\t";

system "cut -f 1 $in_f[0] > $tmp_f";
for (my $i = 0; $i < @in_f; $i++) {
	$tmp_f[$i] = "tmp$i.$$";
	system "cut -f 4 $in_f[$i] > $tmp_f[$i]";
	$paste .= "$tmp_f[$i] ";
	$lib_name[$i] =~ s/rpkm_1k_bin_//;
	$lib_name[$i] =~ s/\.bed//;
	$header .= $lib_name[$i];
	$header .= "\t" if ( $i != @in_f-1 );
}

$header .= "\n";
$paste .= ">$out_f";

print "$paste\n";
system $paste;

system "mv $out_f $tmp_f";

my $tmp2_f = "tmp_h.$$";
open HEAD, ">$tmp2_f" or die "Cannot open $tmp2_f\n";
print HEAD $header;
close HEAD;

system "cat $tmp2_f $tmp_f >$out_f";
unlink $tmp_f;
unlink $tmp2_f;
for (my $i = 0; $i < @tmp_f; $i++) {
	unlink $tmp_f[$i];
}
exit;
