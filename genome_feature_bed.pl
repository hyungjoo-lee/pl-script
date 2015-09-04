#!/usr/bin/perl -w
# genome_feature_bed.pl disects genomic features of sequencing reads (bed file).
# August 22, 2012
# Author: Hyung Joo Lee

use strict;

my $usage = "Usage: perl $0 <database> <processed seqeuncing reads bed file>\n";

die $usage unless @ARGV;

my ($genome, $bed_f, ) = @ARGV;
my ($size_f, $promoter_f, $exon_f, $intron_f, );

if ($genome eq "danRer7") {
#	$size_f = "/home/hyungjoo/genomes/danRer7_database/chr.size";
	$promoter_f = "/home/hyungjoo/genomes/danRer7_database/promoter.bed";
	$exon_f = "/home/hyungjoo/genomes/danRer7_database/exon.bed";
	$intron_f = "/home/hyungjoo/genomes/danRer7_database/intron.bed";
} else {
	die "Cannot find database. Now only danRer7\n";
}

my %tmp_f;
my %cnt;
$tmp_f{"bed"} = "bed.$$";
$tmp_f{"promoter"} = "promoter.$$";
$tmp_f{"exon"} = "exon.$$";
$tmp_f{"intron"} = "intron.$$";
$tmp_f{"p_e"} = "p_e.$$";
$tmp_f{"p_i"} = "p_i.$$";
$tmp_f{"e_i"} = "e_i.$$";
$tmp_f{"p_e_i"} = "p_e_i.$$";

system "bedSort $bed_f $tmp_f{\"bed\"}";
$cnt{"bed"} = `wc -l <$tmp_f{"bed"}`;

system "bedIntersect -aHitAny $tmp_f{\"bed\"} $promoter_f $tmp_f{\"promoter\"}";
$cnt{"promoter"} = `wc -l <$tmp_f{"promoter"}`;

$cnt{"scaffolds"} = `grep 'Zv9' $tmp_f{"bed"} | wc -l`;

$cnt{"chrM"} = `grep 'chrM' $tmp_f{"bed"} | wc -l`;

system "bedIntersect -aHitAny $tmp_f{\"bed\"} $exon_f $tmp_f{\"exon\"}";
$cnt{"exon"} = `wc -l <$tmp_f{"exon"}`;
system "bedIntersect -aHitAny $tmp_f{\"exon\"} $tmp_f{\"promoter\"} $tmp_f{\"p_e\"}";
$cnt{"p_e"} = `wc -l <$tmp_f{"p_e"}`;
$cnt{"exon"} -= $cnt{"p_e"};

system "bedIntersect -aHitAny $tmp_f{\"bed\"} $intron_f $tmp_f{\"intron\"}";
$cnt{"intron"} = `wc -l <$tmp_f{"intron"}`;
system "bedIntersect -aHitAny $tmp_f{\"intron\"} $tmp_f{\"promoter\"} $tmp_f{\"p_i\"}";
$cnt{"p_i"} = `wc -l <$tmp_f{"p_i"}`;
$cnt{"intron"} -= $cnt{"p_i"};
system "bedIntersect -aHitAny $tmp_f{\"intron\"} $tmp_f{\"exon\"} $tmp_f{\"e_i\"}";
$cnt{"e_i"} = `wc -l <$tmp_f{"e_i"}`;
$cnt{"intron"} -= $cnt{"e_i"};
system "bedIntersect -aHitAny $tmp_f{\"p_i\"} $tmp_f{\"p_e\"} $tmp_f{\"p_e_i\"}";
$cnt{"p_e_i"} = `wc -l <$tmp_f{"p_e_i"}`;
$cnt{"intron"} += $cnt{"p_e_i"};

$cnt{"intergenic"} = $cnt{"bed"} - $cnt{"promoter"} - $cnt{"exon"} - $cnt{"intron"} - $cnt{"scaffolds"} - $cnt{"chrM"};

unlink %tmp_f;

print "\n===From $bed_f file, the result is:===\n";
printf "%-20s %8d\n", "Total reads", $cnt{"bed"};
printf "%-20s %8d\n", "Scaffolds", $cnt{"scaffolds"};
printf "%-20s %8d\n", "Mitochodria", $cnt{"chrM"};
printf "%-20s %8d (%8d, %8d, %8d)\n", "Promoter", $cnt{"promoter"}, $cnt{"p_i"}, $cnt{"p_e"}, $cnt{"p_e_i"};
printf "%-20s %8d (%8d)\n", "Exon", $cnt{"exon"}, $cnt{"e_i"};
printf "%-20s %8d\n", "Intron", $cnt{"intron"};
printf "%-20s %8d\n", "Intergenic", $cnt{"intergenic"};
exit;

