#!/usr/bin/env perl
use strict;

die "usage: sort_uniq.pl infile outfile\n" unless @ARGV == 2;

my %entities;
open(IN,$ARGV[0]) || die "cannot open input file\n";
while(<IN>){
	chomp;
	$entities{$_}++;
}
close(IN);

open(OUT,">$ARGV[1]") || die "cannot open output file.\n";
foreach my $key (keys(%entities)){
	print OUT $key."\n";
}
close(OUT);
