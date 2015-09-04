#!/usr/bin/perl -w
use strict;

unless (@ARGV) {
	die "\n Usage:perl $0 <rpkm files> \n";
}

my @in_f = @ARGV;
my @R_f = @in_f;
my @pdf_f = @in_f;
for (my $i = 0; $i < @in_f; $i++) {
	$R_f[$i] =~ s/rpkm$/R/;
	$pdf_f[$i] =~ s/rpkm$/pdf/;
	my $rows = `wc -l < $in_f[$i]`;
	open OUT, ">$R_f[$i]" or die "Cannot open $R_f[$i] file.\n";
	print OUT "library(gplots)\n";
	print OUT "rpkm <- read.table(\"$in_f[$i]\", header=F)\n";
	print OUT "rpkmMatrix <- as.matrix(rpkm[,1:360])\nindex <- rpkmMatrix[,1]\n";
	print OUT "for (i in 1:$rows) { index[i] <- sum(rpkmMatrix[i, 56:65]) }\n";
	print OUT "orderedMatrix <- rpkmMatrix[order(index),]\n";
	print OUT "pdf(\"$pdf_f[$i]\")\n";
	print OUT "heatmap.2(orderedMatrix, Rowv=FALSE, Colv=FALSE, scale = 'none', trace = 'none', dendrogram='none', col = bluered, breaks = c(-2,-0.5, 0.0000000001, 1))\n";
	print OUT "dev.off()\nq()\n";
	close OUT;
	system "R CMD BATCH $R_f[$i]\n";
}
exit;
