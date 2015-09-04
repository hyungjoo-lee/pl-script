#!/usr/bin/perl -w
# This calculates mCRF score difference between two stages in DMRs. 
# June 25, 2013
# Author: Hyung Joo Lee

use strict;

my $usage = "perl $0 <DMRs_ID_mCRFscore.bed> STDOUT > differences values \n";

die $usage unless @ARGV;

my ($data_f, ) = @ARGV;

open IN, $data_f or die "Cannot open $data_f file.\n";
while (<IN>) {
	chomp;
	my @line = split;
	my @mCRF = @line[9..14];
	my $dmr = join "", @line[4..8];
	my @dmr = split "", $dmr;
	for (my $i=0; $i<15; $i++) {
		next unless ($dmr[$i] =~ /[+-]/);
		my ($stage1, $stage2);
		$stage1 = $mCRF[0] if ($i == 0||$i==5||$i==9||$i==12||$i==14);
		$stage1 = $mCRF[1] if ($i == 1||$i==6||$i==10||$i==13);
		$stage1 = $mCRF[2] if ($i == 2||$i==7||$i==11);
		$stage1 = $mCRF[3] if ($i == 3||$i==8);
		$stage1 = $mCRF[4] if ($i == 4);

		$stage2 = $mCRF[1] if ($i == 0);
		$stage2 = $mCRF[2] if ($i == 1||$i==5);
		$stage2 = $mCRF[3] if ($i == 2||$i==6||$i==9);
		$stage2 = $mCRF[4] if ($i == 3||$i==7||$i==10||$i==12);
		$stage2 = $mCRF[5] if ($i == 4||$i==8||$i==11||$i==13||$i==14);

		my $diff = $stage2 - $stage1;
		$diff = -$diff if ($dmr[$i] eq "-");
		print "$diff\n";
	}
}
close IN;
exit;
