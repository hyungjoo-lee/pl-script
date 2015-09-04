#!/usr/bin/perl -w
use strict;

die "Usage: perl $0 <data files> <normalization file> <output R flie>\n" unless @ARGV;

my $out_f = pop @ARGV;
my $norm_f = pop @ARGV;
my @data_f = @ARGV;
die "Too many data files: upto 6 data files\n" if (@ARGV > 6);

open IN, $norm_f or die "Cannot open $norm_f file.\n";
my @norm_num;
while (<IN>) {
	



my @color = ("black", "red", "green3", "blue", "cyan", "magenta");
my @Rcodes;
my @uniq_reads = (17903194, 2904486, 18781804, 16751791, 19291519); ## chages needed every time
my @norm_num;
for (my $i = 0; $i < @uniq_reads; $i++) {
	$norm_num[$i] = $uniq_reads[$i] / $uniq_reads[0];
}
my @ylim;






for (my $i = 0; $i < @ARGV; $i++) {
	push @Rcodes, rewrite_Rcode($ARGV[$i], $i);
}

@ylim = sort { $b <=> $a } @ylim;

$Rcodes[0] =~ s/lines\(1:30/plot(c(1:30)/;
$Rcodes[0] =~ s/\)$/, xaxt='n', xlab='', ylab='Average Score', xlim=c(1, 154), ylim=c(0, $ylim[0]) ) /;

## Write new R file which has upto 6 different samples' genePlot data

open OUT, ">$out_f" or die "Cannot open $out_f file.\n";
print OUT "png('$out_f.png', 850,600)\n";
print OUT @Rcodes;
print OUT "abline(v=31, lty=2)\nabline(v=62, lty=2)\nabline(v=93, lty=2)\nabline(v=124, lty=2)\n";
print OUT "axis(side=1, at=c(15,46,77,108,139), labels=c('Promoter','5\\'UTR','Exon','Intron','3\\'UTR'))\n";
print OUT "legend('topleft', c(";
for (my $i = 0; $i < @ARGV; $i++) {
	my $name = $ARGV[$i];
	$name =~ s/\.data$//;
	print OUT "'$name'";
	print OUT ", " if ($i != @ARGV-1);
}
print OUT "), lwd=4, col=c('black', 'red', 'green3', 'blue', 'cyan', 'magenta'))\n";
close OUT;

sub rewrite_Rcode {
  my ($in_f, $i) = @_;
  my @Rcodes;
  my $cnt = 0;
  open IN, "$in_f" || die "Cannot open $in_f file.\n";
  while (<IN>) {
	next unless (/^plot/ || /^lines/) ;
        my @line = split ", ";
	if (/^plot/) {
		$line[11] =~ s/\)//g;
		$ylim[$i] = $line[11];
	}
	$line[0] =~ s/^plot\(c\(1:30\)/lines(1:30/;
	my @value = split ",", $line[1];
	$value[0] =~ s/c\(//;
	$value[@value-1] =~ s/\)//;
	for (my $j = 0; $j < @value; $j++) {
		$value[$j] = $value[$j] / $norm_num[$i];
	}
	$line[1] = join ",", @value;
	$Rcodes[$cnt] = "$line[0], c($line[1]), type='l', lwd=4, col='$color[$i]')\n";
	$cnt++;
  }
  close IN;
  $Rcodes[$cnt] = "\n";
  return @Rcodes;
}
system "R CMD BATCH $out_f.R";


