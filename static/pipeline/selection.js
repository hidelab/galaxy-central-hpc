(function() {
  var add_parameter, cur_form_vals, fill_analysis_types, fill_available_datasets, fill_parameters, prepare_summary, step_manager, update_parameters, validate_form, _add_barcodes, _add_combobox, _add_genome_build, _update_picked_datasets;
  step_manager = function(wiz) {
    return function(event, ui) {
      if (ui.type !== "manual" && ui.nextStepIndex > ui.currentStepIndex) {
        if (!validate_form(wiz, ui)) {
          return false;
        }
      }
      if (ui.currentStepIndex === 0) {
        $("div#parameters_form").empty();
      }
      if (ui.nextStepIndex === 1 && ui.currentStepIndex === 0) {
        return fill_available_datasets();
      } else if (ui.nextStepIndex === 2 && ui.currentStepIndex === 1) {
        return fill_parameters();
      } else if (ui.nextStepIndex === 3 && ui.currentStepIndex === 2) {
        $("input#barcodes_entered").change(function() {
          update_parameters();
          return prepare_summary();
        });
        return $("#parameters_form").find("#submit-button").click();
      }
    };
  };
  validate_form = function(wiz, ui) {
    var cur_step, error_pos, inputs, offset;
    cur_step = wiz.find(".jw-step:eq(" + ui.currentStepIndex + ")");
    inputs = cur_step.find("input");
    if (inputs.length > 0 && !inputs.valid()) {
      error_pos = cur_step.find("input.ui-state-error-text");
      offset = error_pos.parent("div").offset().top;
      $("div.jw-steps-wrap").animate({
        scrollTop: offset - 10
      }, "slow");
      error_pos.parent("div").find("label.ui-state-error-text").effect("highlight", {}, "slow");
      return false;
    }
    return true;
  };
  fill_analysis_types = function() {
    var target;
    target = $("ul#available_analyses");
    return $.getJSON($("div#type_url").attr("value"), function(data) {
      var add_pipeline, p, _i, _len, _ref;
      target.children("li").remove();
      add_pipeline = function(pipeline) {
        return $("<li>" + pipeline.name + "</li>").addClass("ui-widget-content").addClass("tooltip").attr("title", pipeline.description).appendTo(target).hover(function() {
          return $(this).addClass("ui-selecting");
        }, function() {
          return $(this).removeClass("ui-selecting");
        }).click(function() {
          $(this).addClass("ui-selected").siblings().removeClass("ui-selected");
          return $("input#pipeline").attr("value", $(this).text());
        });
      };
      _ref = data.pipelines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        add_pipeline(p);
      }
      $(target.children("li")[0]).click();
      return $(".tooltip").tipsy({
        gravity: "w"
      });
    });
  };
  _update_picked_datasets = function() {
    var li, selected, ul, _i, _j, _len, _len2, _ref, _ref2;
    selected = [];
    _ref = $("ul.ready_target");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ul = _ref[_i];
      $(ul).toggleClass("valid_target", $(ul).children().length === 0);
      _ref2 = $(ul).children("li");
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        li = _ref2[_j];
        selected.push($(li).attr("id"));
      }
    }
    return $("input#datasets").attr("value", selected.join(","));
  };
  fill_available_datasets = function() {
    var pipeline, target;
    target = $("ul#available_datasets");
    pipeline = $("input#pipeline").attr("value");
    $("ul.ready_target").toggleClass("valid_target", true).children("li").remove();
    $("input#datasets").attr("value", "");
    return $.getJSON($("div#dset_url").attr("value"), {
      pipeline: pipeline
    }, function(data) {
      var add_dataset, d, _i, _len, _ref;
      target.children("li").remove();
      add_dataset = function(dataset) {
        return $("<li>" + dataset.name + "</li>").addClass("ui-widget-content").addClass("ui-state-default").attr("id", dataset.id).appendTo(target);
      };
      _ref = data.datasets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        d = _ref[_i];
        add_dataset(d);
      }
      if (data.datasets.length === 0) {
        $("<div></div").html("<p>No data sets found in Galaxy history.</p>" + "<p>Accepted formats: " + data.formats.join(", ") + "</p>").dialog({
          modal: true,
          resizable: false
        });
      }
      target.sortable({
        placeholder: "ui-state-highlight",
        forcePlaceholderSize: true,
        revert: "invalid",
        helper: "clone",
        receive: _update_picked_datasets,
        connectWith: ".valid_target"
      });
      return $(".ready_target").sortable({
        placeholder: "ui-state-highlight",
        forcePlaceholderSize: true,
        revert: "invalid",
        helper: "clone",
        receive: _update_picked_datasets,
        connectWith: ".valid_target,ul#available_datasets"
      });
    });
  };
  _add_combobox = function(target, param) {
    var combo, info, val, _i, _len, _ref, _ref2;
    combo = $("<select></select>").attr("class", "combobox").attr("name", param.id).appendTo(target);
    _ref = param.choices;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref2 = _ref[_i], val = _ref2[0], info = _ref2[1];
      $("<option></option>").attr("value", val).text(info).appendTo(combo);
    }
    return $(combo).combobox();
  };
  _add_barcodes = function(param) {
    var bc_div;
    bc_div = $("div#barcode_entry");
    return bc_div.load($("div#barcode_url").attr("value"), {}, function() {
      return $("form#barcode_choice_form").validate();
    });
  };
  _add_genome_build = function(target, param) {
    var combo;
    combo = $("<select></select>").attr("class", "combobox").attr("name", param.id).appendTo(target);
    return $.getJSON($("div#org_url").attr("value"), cur_form_vals(), function(data) {
      var name, val, _i, _len, _ref, _ref2;
      console.info(data);
      _ref = data.choices;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref2 = _ref[_i], val = _ref2[0], name = _ref2[1];
        $("<option></option>").attr("value", val).text(name).appendTo(combo);
      }
      if (data.selected !== "") {
        $(combo).val(data.selected);
      }
      return combo.chosen();
    });
  };
  add_parameter = function(target, param) {
    var cur_target, _ref;
    if ((_ref = param.type) === "combo" || _ref === "genome_build") {
      cur_target = $("<div></div>").attr("class", "form-row").appendTo(target);
      $("<label></label>").text(param.name).appendTo(cur_target);
      if (param.type === "genome_build") {
        return _add_genome_build(cur_target, param);
      } else {
        return _add_combobox(cur_target, param);
      }
    } else if (param.type === "barcode") {
      return _add_barcodes(param);
    }
  };
  fill_parameters = function() {
    var bc_div, pipeline, std_div, target, target_form;
    target = $("div#parameters_form");
    if (target.find("form").length > 0) {
      return;
    }
    target_form = $("<form></form>").appendTo(target);
    std_div = $("<div></div>").appendTo(target_form);
    bc_div = $("<div id='barcode_entry'></div>").appendTo(target_form);
    $("<input type='hidden'></input").attr({
      id: "barcodes_entered",
      name: "barcodes_entered",
      value: ""
    }).appendTo(target_form);
    pipeline = $("input#pipeline").attr("value");
    return $.getJSON($("div#param_url").attr("value"), {
      pipeline: pipeline
    }, function(data) {
      var p, _i, _len, _ref;
      _ref = data.params;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        add_parameter(std_div, p);
      }
      return target_form.validate();
    });
  };
  update_parameters = function() {
    var bc, child, out, out_dom, target, _i, _len, _ref;
    target = $("div#parameters_form").children("form")[0];
    out_dom = $("input#params");
    out = {};
    _ref = $(target).find("select");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      out[$(child).attr("name")] = $(child).val();
    }
    bc = $("input#barcodes_entered");
    if ($(bc).val()) {
      out[$(bc).attr("name")] = JSON.parse($(bc).val());
    }
    return out_dom.attr("value", JSON.stringify(out));
  };
  cur_form_vals = function() {
    var form_vals, input, _i, _len, _ref;
    form_vals = {};
    _ref = $("form.jWizard_form").find("input:hidden");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      input = _ref[_i];
      form_vals[$(input).attr("name")] = $(input).attr("value");
    }
    return form_vals;
  };
  prepare_summary = function() {
    return $("div#summary_panel").load($("div#summary_url").attr("value"), cur_form_vals());
  };
  $(function() {
    var wiz;
    fill_analysis_types();
    wiz = $(".jWizard_form");
    wiz.validate({
      errorClass: "ui-state-error-text",
      messages: {
        datasets: "Please choose at least one dataset to run in the pipeline"
      }
    });
    return wiz.jWizard({
      hideTitle: true,
      menuEnable: true,
      buttons: {
        cancelHide: true,
        finishType: "submit",
        finishText: "Process"
      }
    }).bind("jwizardchangestep", step_manager(wiz));
  });
}).call(this);
