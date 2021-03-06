#! /usr/bin/perl -w

######################################################################################
# This script takes alignment sequence fasta file and converts it to phylip file
# Author: Wenjie Deng
# Date: 2007-01-29
# Usage: perl Fasta2Phylip.pl inputFastaFile outputPhilipFile
######################################################################################
use strict;

my $usage = "Usage: perl Fasta2Phylip.pl inputFastaFile outputPhilipFile\n";
my $infile = shift or die $usage;	# input fasta file
my $outFile = shift or die $usage;	# output phylip file
my $unixFile = $infile.".unix";

ConvertToUnix($infile, $unixFile);
ChangetoPhylip($unixFile, $outFile);
unlink $unixFile;
print "All done!\n";

exit 0;


######################################################################################
sub ConvertToUnix {
	my ($infile, $unixFile) = @_;
	open (IN, $infile) or die "Couldn't open $infile: $!\n";
	open (OUT, ">$unixFile") or die "Couldn't open $unixFile: $!\n";
	my @buffer = <IN>;
	close IN;
	my $line = "";
	foreach my $element (@buffer) {
		$line .= $element;
	}
	if ($line =~ /\r\n/) {
		$line =~ s/\r//g;
	}elsif ($line =~ /\r/) {
		$line =~ s/\r/\n/g;
	}
	print OUT $line;	
	close OUT;	
}


######################################################################################
sub ChangetoPhylip {
	my ($unixFile, $phylipFile) = @_;
	my $seqCount = 0;
	my $seq = my $seqName = "";
	open IN, $unixFile or die "Couldn't open $unixFile: $!\n";
	while (my $line = <IN>) {
		chomp $line;
		next if $line =~ /^\s*$/;
		if ($line =~ /^>/) {
			$seqCount++;
		}elsif ($seqCount == 1) {
			$seq .= $line;
		}
	}
	close IN;
	my $seqLen = length $seq;
	
	open IN, $unixFile or die "couldn't open $unixFile: $!\n";
	open OUT, ">", $phylipFile or die "couldn't open $phylipFile: $!\n";
	print OUT $seqCount," ",$seqLen,"\n";
	$seqCount = 0;
	$seq = "";
	while(my $line = <IN>) {
		chomp $line;	
		next if($line =~ /^\s*$/);
		if($line =~ /^>(\S+)/) {
			if ($seqCount) {
				my $len = length $seq;
				if ($len == $seqLen) {
					print OUT "$seqName\n$seq\n";
					$seq = $seqName = "";
				}else {
					unlink $unixFile;
					unlink $phylipFile;
					die "Error: the sequence length of $seqName is not same as others, sequences are not alignned.\n";
				}
			}	
			$seqName = $1;
			$seqCount++;
		}else {
			$seq .= $line;		
		}		
	}
	close IN;
	# check the length of last sequence
	my $len = length $seq;
	if ($len == $seqLen) {
		print OUT "$seqName\n$seq\n";
	}else {
		unlink $unixFile;
		unlink $phylipFile;
		die "Error: the sequence length of $seqName is not same as others, sequences are not alignned.\n";
	}	
	close IN;
	close OUT;
}

