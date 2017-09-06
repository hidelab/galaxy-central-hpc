#!/usr/bin/env python

''' get common genes within the same pathways '''

from anno_lib import pathcom
import sys

loc = "http://www.pathwaycommons.org/pc/webservice.do"
spec = "9606"
# can it run without a organism specified
'''
mm 10090
arabidopsis 3702
ce 6239
rat rn 10116
Danio rerio 7955 zebrafish
dmelan 7227

'''

try:
	idfile = sys.argv[1]
	type = sys.argv[2]
	outfile = sys.argv[3]
except IOError:
	print "usage pc_common_gene.py ids_file output_file"
	
# fix ids, ids separated by comma, input should be "\n"
with open(idfile) as handle:
	ids = handle.read().replace("\n",",").rstrip(",")

# query pathway commons
pc_obj = pathcom.Genes(loc,spec)
common = pc_obj.common_path(ids,type)

# write answer
with open(outfile,'w') as handle:
	for desc in common:
		source = common[desc].pop(0)
		
		# if at least two genes from gene list in a common pathway
		if len(common[desc]) > 1:
			genes = "\t".join(common[desc])
		
			handle.write(desc+"\t"+source+"\t"+genes+"\n")
