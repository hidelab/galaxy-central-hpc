#!/usr/bin/env perl
use strict;

####
#	form a query for linking to g:Profiler
#
#	Jason Evans
#	Oliver Hofmann
#	Bioinformatics Core
#	Harvard School of Public Health
####

#http://biit.cs.ut.ee/gprofiler/gconvert.cgi?organism=hsapiens&query=BRCA1+BRCA2&output=mini&target=ENSG"


my $idfile = $ARGV[0];#path to file
my $outfile = $ARGV[1];#output filename
my $site = $ARGV[2];# http://biit.cs.ut.ee...

my %atts;
$atts{organism} = $ARGV[3];
$atts{output} = $ARGV[4];
$atts{sort_by_structure} = $ARGV[5];
$atts{significant} = $ARGV[6];
$atts{user_thr} = $ARGV[7];
$atts{prefix} = $ARGV[8];
$atts{threshold_algo} = $ARGV[9];
$atts{domain_size_type} = $ARGV[10];
$atts{ordered_query} = $ARGV[11];
$atts{no_iea} = $ARGV[12];
$atts{region_query} = $ARGV[13];
$atts{term} = $ARGV[14];#query for GO term

# create ids ("query")
my $ids = "query=";
open(ID,$idfile) || die "Cannot open idfile: ".$idfile." .\n";
while(<ID>){
	chomp;
	$ids .= $_."+";
}
close(ID);

$ids =~ s/\+$//;

my $add = $site."?".$ids."&";
foreach my $key (keys(%atts)){
	if($atts{$key}){
		$add .= $key."=".$atts{$key}."&"
	}
}
$add =~ s/\&$//;

my $html = &wrap_html($add);

open(OUT,">$outfile") || die "Cannot open outfile: ".$outfile." .\n";
print OUT $html."\n";
close(OUT);

exit;

sub wrap_html{
	my $add = $_[0];
	
	my $link = '<a href="'.$add.'" target=_blank>Query g:Profiler</a>';
	my $html = "<html>".$link."</html>";
	
	return $html;
}
