#!/usr/bin/env perl
use strict;

####
#	form a query for linking to GeneMANIA
#
#	Jason Evans
#	Oliver Hofmann
#	Bioinformatics Core
#	Harvard School of Public Health
####

#http://genemania.org/link?o=9606&g=PHYB|ELF3|COP1|SPA1|FUS9


my $idfile = $ARGV[0];#path to file
my $outfile = $ARGV[1];#output filename
my $site = $ARGV[2];# http://genemania.org/link

# species
my $spec = "o=9606"; #human

# gene ids ("g")
my $ids = "g=";
open(ID,$idfile) || die "Cannot open idfile: ".$idfile." .\n";
while(<ID>){
	chomp;
	$ids .= $_."|";
}
close(ID);

$ids =~ s/\|$//;

my $add = $site."?".$spec."&".$ids;

my $html = &wrap_html($add);

open(OUT,">$outfile") || die "Cannot open outfile: ".$outfile." .\n";
print OUT $html."\n";
close(OUT);

exit;

sub wrap_html{
	my $add = $_[0];
	
	my $link = '<a href="'.$add.'" target=_blank>Query GeneMANIA</a>';
	my $html = "<html>".$link."</html>";
	
	return $html;
}
