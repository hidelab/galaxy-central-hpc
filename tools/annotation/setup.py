from distutils.core import setup

setup(name='Annotation',
	version = '1.0.1',
	description = "Tools for gene list annotation",
	author = "Jason Evans, Oliver Hofmann",
	author_email = "jjevans@hsph.harvard.edu",
	url = "hsph",
	packages = ['anno_lib'],
	scripts = [		
		'GOstats.py',
		'GOstats_Heatmap.py',
		'ReviGO.py',
		'create_csweb.py',
		'gPro_GO_termlist.py',
		'gPro_by_term.py',
		'gPro_convert.py',
		'gPro_profile.py',
		'is_dual.py',
		'is_pval.py',
		'is_run.py',
		'is_run_dual.py',
		'pc_by_ids.py',
		'pc_common_gene.py',
		'pc_gene_cohort.py',
		'pc_get_path.py' ]
	)

namespace_packages = ["annotation"]
