#!/usr/bin/env perl
use strict;
use Bio::EnsEMBL::Compara::Homology;
use Bio::EnsEMBL::Compara::Member;
use Bio::EnsEMBL::Registry;

die "usage: ortholog.pl gene_id_file taxonid_to output_file\n" unless @ARGV == 3;

# human to mouse orthology for now
# much of the implementation of the Ensembl API was ripped from Ensembl helppage

Bio::EnsEMBL::Registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous',
    -port => 5306);

open(ID,$ARGV[0]) || die "cannot open file of ids\n";
open(OUT,">$ARGV[2]") || die "cannot open output file\n";

# adaptors
my $member_adaptor = Bio::EnsEMBL::Registry->get_adaptor('Multi', 'compara', 'Member');
my $homology_adaptor = Bio::EnsEMBL::Registry->get_adaptor('Multi', 'compara', 'Homology');

while(<ID>){
	chomp;
	
	my $member = $member_adaptor->fetch_by_source_stable_id('ENSEMBLGENE',$_);
	
	if(defined($member)){
		my $homologies = $homology_adaptor->fetch_all_by_Member($member);

		# That will return a reference to an array with all homologies (orthologues 
		# in other species and paralogues in the same one)
		# Then for each homology, you can get all the Members implicated
		
		foreach my $homology (@{$homologies}) {
			# see ensembl-compara/docs/docs/schema_doc.html for more details
			my $homologue_genes = $homology->gene_list();
			
			if($homologue_genes->[1]->taxon_id eq $ARGV[1]){
				print OUT  $_."\t".$homologue_genes->[1]->stable_id."\n";
			}
  		}
	}
}

close(IN);
close(OUT);
exit;
