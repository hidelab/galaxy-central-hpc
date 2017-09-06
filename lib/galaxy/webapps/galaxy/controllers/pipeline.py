"""Interface to run pipelined next-gen sequencing analyses.

Provides a high level way to run custom analysis pipelines such
as exome variant calling or ChIP-seq.
"""
import os
import time
import string
import datetime

from galaxy import web, util
from galaxy.web.base.controller import BaseUIController

try:
    import yaml
except ImportError:
    yaml = False

try:
    from bcbio import utils
    from bcbio.distributed import messaging
    has_bcbio = True
except ImportError:
    has_bcbio = False

WEB_NAME = "pipeline"

# ## Convenience functions for Galaxy data access

def _datasets_from_params(trans, params):
    """Get selected datasets from passed keyword parameters.
    """
    datasets = []
    for d_id in (x for x in params["datasets"].split(",") if x):
        if d_id not in [None, "None", ""]:
            ds = trans.sa_session.query(trans.app.model.HistoryDatasetAssociation).get(
                     trans.security.decode_id(d_id))
            datasets.append(ds)
    return datasets

class NextGenRunner:
    """Run next gen sequencing pipelines, preparing inputs and kicking off program.
    """
    def __init__(self, process_config_file):
        self._analysis_map = {"Alignment": "Standard",
                              "Variant calling": "SNP calling"}
        self._process_config_file = process_config_file

    def run(self, trans, tmp_dir, kwd):
        tmp_dir = os.path.abspath(tmp_dir)
        lane = 1
        fastq_dir, fastq_files, qual_format = self._prepare_fastq(trans, lane,
                                                                  tmp_dir, kwd)
        config_file, config = self._prepare_config(trans, lane, fastq_files,
                                                   qual_format, tmp_dir, kwd)
        dirs = {"work": tmp_dir,
                "config": os.path.dirname(self._process_config_file)}
        send_data = {"fc_dir": fastq_dir,
                     "run_yaml": config_file,
                     "directory": "%s_%s" % (config["fc_date"], config["fc_name"])}
        with open(self._process_config_file) as in_handle:
            config = yaml.load(in_handle)
        with utils.chdir(tmp_dir):
            runner = messaging.runner("bcbio.distributed.tasks",
                                      dirs, config, self._process_config_file, wait=False)
            runner("analyze_and_upload", [[send_data]])

    def _prepare_config(self, trans, lane, fastq_files, qual_format,
                        tmp_dir, kwd):
        config_dir = os.path.join(tmp_dir, "config")
        if not os.path.exists(config_dir):
            os.makedirs(config_dir)
        config_file = os.path.join(config_dir, "run_info.yaml")
        params = util.json.from_json_string(kwd["params"])
        details = {"lane": lane,
                   "files": fastq_files,
                   "genome_build": str(params["genome_build"]),
                   "analysis": self._analysis_map[kwd["pipeline"]],
                   "algorithm" : self._get_algorithm_tweaks(trans, qual_format,
                                                            params, tmp_dir),
                   "galaxy_role": self._get_upload_role(trans),
                   "galaxy_library": str(trans.user.email)}
        barcodes = self._get_barcodes(params["barcodes_entered"])
        if len(barcodes) > 0:
            details["multiplex"] = barcodes
        out = {"details": [details],
               "fc_date": str(kwd["out_date"]),
               "fc_name": str(kwd["out_ext"])}
        with open(config_file, "w") as out_handle:
            yaml.dump(out, out_handle, allow_unicode=False, default_flow_style=False)
        return config_file, out

    def _get_upload_role(self, trans):
        """Retrieve appropriate Galaxy role ID for current user.
        """
        upload_roles = dict([(r.name, r.id) for r in trans.user.all_roles()])
        if upload_roles.has_key(trans.user.email):
            upload_role = upload_roles[trans.user.email]
        else:
            upload_role = upload_roles.values()[0]
        return upload_role

    def _get_algorithm_tweaks(self, trans, qual_format, params, tmp_dir):
        """Retrieve dictionary of algorithm details specific in keywords.
        """
        ignore_params = ["genome_build", "barcodes_entered"]
        out = {"quality_format": qual_format}
        sup_dir = os.path.join(tmp_dir, "supplemental")
        for param in ["hybrid_bait", "hybrid_target"]:
            if params.has_key(param):
                if not os.path.exists(sup_dir):
                    os.makedirs(sup_dir)
                dsets = _datasets_from_params(trans, {"datasets": params[param]})
                if len(dsets) > 0:
                    cur_fname = str(os.path.join(sup_dir, "%s.bed" % param))
                    os.symlink(dsets[0].file_name, cur_fname)
                    out[param] = cur_fname
                del params[param]
        if params.has_key("multiple_mappers"):
            out["multiple_mappers"] = False if params["multiple_mappers"].lower() == "no" else True
            del params["multiple_mappers"]
        for k, v in params.iteritems():
            if k not in ignore_params:
                out[k] = v
        return out

    def _get_barcodes(self, kwd):
        bcs = []
        for sample_name, bc_info in kwd.get("barcodes", []):
            sample_name = sample_name.replace("NEW^^", "")
            bc_id, bc_seq = bc_info.split(" : ")
            bcs.append({"barcode_type": str(kwd["barcode_type"]),
                        "barcode_id": str(bc_id),
                        "name": str(sample_name),
                        "sequence": str(bc_seq)})
        return bcs

    def _prepare_fastq(self, trans, lane, tmp_dir, kwd):
        fastq_dir = os.path.join(tmp_dir, "fastq")
        if not os.path.exists(fastq_dir):
            os.makedirs(fastq_dir)
        fnames = []
        qual_format = None
        for i, dset in enumerate(_datasets_from_params(trans, kwd)):
            if qual_format is None:
                if dset.extension.find("illumina") >= 0:
                    qual_format = "Illumina"
                else:
                    qual_format = "Standard"
            cur_fname = os.path.join(fastq_dir, "%s_%s-fastq.txt" % (lane, i+1))
            fnames.append(str(os.path.basename(cur_fname)))
            os.symlink(dset.file_name, cur_fname)
        assert qual_format is not None
        return fastq_dir, fnames, qual_format

class PipelineController(BaseUIController):
    def __init__(self, app):
        BaseUIController.__init__(self, app)
        self._config_file = os.path.join("tool-data", "pipeline.yaml")
        self._process_config_file = os.path.abspath("post_process.yaml")
        self._load_config()
        self._bc_item_id = "barcodes_entered"
        self._runners = {"nextgen": NextGenRunner(self._process_config_file)}

    def _load_config(self):
        if yaml and os.path.exists(self._config_file):
            with open(self._config_file) as in_handle:
                self._config = yaml.load(in_handle)
        else:
            self._config = None

    @web.expose
    def index(self, trans, **kwd):
        self._load_config()
        if self._config is None or not has_bcbio:
            return "Pipeline not configured: requires bcbio.nextgen and %s" % self._config_file
        start_url = web.url_for(controller=WEB_NAME, action="selection")
        return trans.fill_template("pipeline/index.mako", start_url=start_url)

    @web.expose
    def selection(self, trans, **kwd):
        """Select pipeline, parameters and datasets with interactive wizard.
        """
        urls = ["form_url", "type_url", "dset_url",
                "param_url", "summary_url", "barcode_url", "org_url"]
        actions = ["submit", "available_pipelines", "available_datasets",
                   "pipeline_parameters", "summary", "barcodes", "genome_builds"]
        url_info = dict(zip(urls, [web.url_for(controller=WEB_NAME, action=a)
                                   for a in actions]))
        return trans.fill_template("/pipeline/selection.mako", **url_info)

    @web.expose
    def submit(self, trans, **kwd):
        """Start analysis pipeline for a particular type and set of parameters.
        """
        tmp_dir = os.path.join(os.path.abspath(trans.app.config.new_file_path),
                               trans.user.email,
                               "%s_%s" % (kwd["out_date"], kwd["out_ext"]))
        runner = None
        for pipeline in self._config["pipelines"]:
            if pipeline["name"] == kwd["pipeline"]:
                runner = self._runners[pipeline["type"]]
                break
        assert runner is not None
        runner.run(trans, tmp_dir, kwd)
        trans.response.send_redirect(web.url_for(controller=WEB_NAME, action="selection"))

    @web.expose
    @web.json
    def available_pipelines(self, trans, **kwd):
        """Retrieve available analysis pipelines.
        """
        attrs = ["name", "description"]
        pipelines = [dict(zip(attrs, [p[a] for a in attrs]))
                     for p in self._config["pipelines"]]
        return {"pipelines": pipelines}

    @web.expose
    @web.json
    def available_datasets(self, trans, **kwd):
        """Retrieve a set of available datasets for a given pipeline or format.
        """
        dsets, formats = self._datasets_from_kwd(trans, **kwd)
        out_dsets = []
        for dset in dsets:
            out_dsets.append({"id": trans.security.encode_id(dset.id),
                              "name": dset.name})
        return {"datasets": out_dsets, "formats": formats}

    def _datasets_from_kwd(self, trans, **kwd):
        if kwd.get("formats", None):
            formats = tuple(kwd["formats"])
        else:
            pipeline = kwd["pipeline"]
            formats = tuple([p["formats"] for p in self._config["pipelines"]
                             if p["name"] == pipeline][0])
        dsets = []
        for dset in (d for d in trans.history.datasets
                     if not d.deleted and d.extension.startswith(formats)):
            dsets.append(dset)
        return dsets, formats

    @web.expose
    @web.json
    def pipeline_parameters(self, trans, **kwd):
        """Retrieve parameters associated with a pipeline.
        """
        pipeline = kwd["pipeline"]
        out_params = []
        for param in [p["params"] for p in self._config["pipelines"]
                      if p["name"] == pipeline][0]:
            ptype = param.get("type", "combo")
            name = param["name"]
            if ptype == "file":
                ptype = "combo"
                formats = param["formats"]
                (choice_dsets, _) = self._datasets_from_kwd(trans, formats=formats)
                choices = [(trans.security.encode_id(d.id), d.name)
                           for d in choice_dsets] + [(None, "None")]
                if len(formats) > 1:
                    name += " (from history; allowed formats: %s)" % ", ".join(formats)
                else:
                    name += " (from history; %s format)" % formats[0]
            else:
                c = param.get("choices", [])
                choices = zip(c, c)
            out_params.append({"name": name, "type": ptype, "choices": choices,
                               "id": param.get("id", "")})
        return {"params": out_params}

    @web.expose
    def summary(self, trans, **kwd):
        """Provide summary HTML of parameters specified for a run.
        """
        out = []
        out.append(("Pipeline", kwd["pipeline"]))
        datasets = [d.name for d in _datasets_from_params(trans, kwd)]
        out.append(("Data", ", ".join(datasets)))
        param_info = self._friendly_param_info(kwd["pipeline"])
        params = util.json.from_json_string(kwd["params"])
        for key in sorted(params.keys()):
            name, val_remap_fn = param_info[key]
            val = val_remap_fn(trans, params[key]) if val_remap_fn else params[key]
            out.append((name, val))
        out_ext, out_date = self._unique_output_folder()
        return trans.fill_template("/pipeline/summary.mako", table_vals=out,
                                   username=trans.user.email, out_ext=out_ext,
                                   out_date=out_date)

    def _unique_output_folder(self):
        """Generate date and unique identifier for processing output folder.

        String encoding from:
        http://stackoverflow.com/questions/561486/
        how-to-convert-an-integer-to-the-shortest-url-safe-string-in-python
        """
        alphabet = string.ascii_uppercase + string.digits
        fc_date = datetime.datetime.now().strftime("%y%m%d")
        n = int(time.time())
        s = []
        while True:
            n, r = divmod(n, len(alphabet))
            s.append(alphabet[r])
            if n == 0: break
        return ''.join(reversed(s)), fc_date

    def _barcode_display(self, trans, bc_info):
        out = "%s" % bc_info["barcode_type"]
        items = []
        for name, barcode in bc_info["barcodes"]:
            items.append("<li>%s -- %s</li>" % (name.replace("NEW^^", ""), barcode))
        out += "<ul class='summary_list'>%s</ul>" % "".join(items)
        return out

    def _dataset_name(self, trans, string_id):
        """Retrieve name of dataset for display purposes.
        """
        dsets = _datasets_from_params(trans, {"datasets": string_id})
        if len(dsets) > 0:
            return dsets[0].name
        else:
            return ""

    def _friendly_param_info(self, pipeline):
        names = {}
        for param in [p["params"] for p in self._config["pipelines"]
                      if p["name"] == pipeline][0]:
            if param.get("type", "") == "file":
                remap_fn = self._dataset_name
            elif param.get("type", "") == "barcode":
                param["id"] = self._bc_item_id
                remap_fn = self._barcode_display
            else:
                remap_fn = None
            names[param["id"]] = (param["name"], remap_fn)
        return names

    @web.expose
    def barcodes(self, trans, **kwd):
        # XXX Turn off barcodes for now since not widely used here
        return ""
        # barcodes = [b["name"] for b in self._config["barcodes"]]
        # out = {"barcode_details": web.url_for(controller=WEB_NAME,
        #                                       action="barcodes_by_type"),
        #        "data_store_id": self._bc_item_id,
        #        "sample_title": "Samples",
        #        "barcodes": barcodes,
        #        "default_barcode_type": barcodes[0],
        #        "editable_samples": [],
        #        "samples": [],
        #        "parent_id": "",
        #        "callback_url": ""}
        # return trans.fill_template("nglims/barcodes.mako", **out)

    @web.expose
    @web.json
    def barcodes_by_type(self, trans, **kwd):
        """Retrieve JSON string of barcodes available for a particular type.
        """
        cur_type = kwd.get("barcode_type", "")
        barcodes = {}
        for choice in self._config["barcodes"]:
            if choice["name"] == cur_type:
                barcodes["names"] = []
                for item in choice["data"]:
                    barcodes["names"].append("%s : %s" % (item.items()[0]))
        return barcodes

    @web.expose
    @web.json
    def genome_builds(self, trans, **kwd):
        """Retrieve available genome builds, defaulting at set organism in inputs.
        """
        ref_builds = set(filter(lambda x: x is not None,
                                [d.metadata.get("dbkey")
                                 for d in _datasets_from_params(trans, kwd)]))
        ref_build = ref_builds.pop() if len(ref_builds) > 0 else ""
        out = {"selected": ref_build, "choices": []}
        for val, name in util.dbnames:
            out["choices"].append((val, name))
        return out
