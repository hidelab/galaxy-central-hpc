#!/usr/bin/env python

from anno_lib import gPro
import sys

##
# Runs the GOst profiler from g:Profiler
####
# jje 10152011
# Oliver Hofmann
# Bioinformatics Core
# Harvard School of Public Health
####

#term = "GO:0007050"
#gost_loc = "http://biit.cs.ut.ee/gprofiler/"

try:
	idfile = sys.argv[1]
	outfile = sys.argv[2]
	loc = sys.argv[3]
	spec = sys.argv[4]
	pcut = sys.argv[5]
	
except IOError as (errno, strerror):
	print "usage: gPro_profile.py infile outfile gPro_URL p-value_cutoff"

''' open and read in ids '''
with open(idfile) as ids:
	id_raw = ids.read()

# convert ids from a list to space delim string
id_form = id_raw.replace("\n"," ")

gpro_obj = gPro.Profiler(loc,spec)
content = gpro_obj.ask_pcut(id_form,pcut)

# filter out any lines other than those from GO and get GO: term ids
content = gpro_obj.justGO(content)

output = open(outfile,"w")
output.write(content)	
output.close()

