# Wizard style interface to selecting detailed information on a pipeline.
# This javascript supports the markup in /templates/pipeline/selection.mako

# ## Wizard management

# Handle individual steps in the wizard querying the server for details
step_manager = (wiz) ->
  (event, ui) ->
    if ui.type isnt "manual" and ui.nextStepIndex > ui.currentStepIndex
      if not validate_form(wiz, ui)
        return false
    if ui.currentStepIndex is 0
      $("div#parameters_form").empty()
    if ui.nextStepIndex is 1 and ui.currentStepIndex is 0
      fill_available_datasets()
    else if ui.nextStepIndex is 2 and ui.currentStepIndex is 1
      fill_parameters()
    else if ui.nextStepIndex is 3 and ui.currentStepIndex is 2
      $("input#barcodes_entered").change () ->
        update_parameters()
        prepare_summary()
      $("#parameters_form").find("#submit-button").click()

# Check current step in the form for missing required attributes
validate_form = (wiz, ui) ->
  cur_step = wiz.find(".jw-step:eq(" + ui.currentStepIndex + ")")
  inputs = cur_step.find("input")
  if inputs.length > 0 and not inputs.valid()
    error_pos = cur_step.find("input.ui-state-error-text")
    offset = error_pos.parent("div").offset().top
    $("div.jw-steps-wrap").animate
      scrollTop: offset - 10,
      "slow"
    error_pos.parent("div").find("label.ui-state-error-text").effect("highlight", {}, "slow")
    return false
  return true

# ## Analyses

# Fill selector of available analysis types
fill_analysis_types = () ->
  target = $("ul#available_analyses")
  $.getJSON $("div#type_url").attr("value"), (data) ->
    target.children("li").remove()

    add_pipeline = (pipeline) ->
      $("<li>" + pipeline.name + "</li>")
      .addClass("ui-widget-content").addClass("tooltip")
      .attr("title", pipeline.description)
      .appendTo(target)
      .hover(
        -> $(this).addClass "ui-selecting"
        -> $(this).removeClass "ui-selecting")
      .click ->
        $(this).addClass("ui-selected").siblings().removeClass("ui-selected")
        $("input#pipeline").attr("value", $(this).text())
    add_pipeline p for p in data.pipelines

    $(target.children("li")[0]).click()
    $(".tooltip").tipsy
      gravity: "w"

# ## Datasets

# Update the list of currently selected datasets
_update_picked_datasets = () ->
  selected = []
  for ul in $("ul.ready_target")
    $(ul).toggleClass("valid_target", $(ul).children().length is 0)
    for li in $(ul).children("li")
      selected.push $(li).attr("id")
  $("input#datasets").attr("value", selected.join(","))

# Fill selector of available datasets for the analysis type
fill_available_datasets = () ->
  target = $("ul#available_datasets")
  pipeline = $("input#pipeline").attr("value")
  $("ul.ready_target")
  .toggleClass("valid_target", true)
  .children("li").remove()
  $("input#datasets").attr("value", "")

  $.getJSON $("div#dset_url").attr("value"), {pipeline: pipeline}, (data) ->
    target.children("li").remove()
    add_dataset = (dataset) ->
      $("<li>" + dataset.name + "</li>")
      .addClass("ui-widget-content").addClass("ui-state-default")
      .attr("id", dataset.id)
      .appendTo(target)
    add_dataset d for d in data.datasets
    if data.datasets.length is 0
      $("<div></div").html("<p>No data sets found in Galaxy history.</p>" +
                           "<p>Accepted formats: " + data.formats.join(", ") + "</p>")
      .dialog
        modal: true
        resizable: false
    target.sortable
      placeholder: "ui-state-highlight"
      forcePlaceholderSize: true
      revert: "invalid"
      helper: "clone"
      receive: _update_picked_datasets
      connectWith: ".valid_target"
    $(".ready_target").sortable
      placeholder: "ui-state-highlight"
      forcePlaceholderSize: true
      revert: "invalid"
      helper: "clone"
      receive: _update_picked_datasets
      connectWith: ".valid_target,ul#available_datasets"

# ## Parameters

# Add selection parameter widgets to panel

_add_combobox = (target, param) ->
  combo = $("<select></select>").attr("class", "combobox")
          .attr("name", param.id).appendTo(target)
  for [val, info] in param.choices
    $("<option></option>").attr("value", val).text(info).appendTo(combo)
  $(combo).combobox()

_add_barcodes = (param) ->
  bc_div = $("div#barcode_entry")
  bc_div.load($("div#barcode_url").attr("value"), {}, () ->
    $("form#barcode_choice_form").validate())

_add_genome_build = (target, param) ->
  combo = $("<select></select>").attr("class", "combobox")
          .attr("name", param.id).appendTo(target)
  $.getJSON $("div#org_url").attr("value"), cur_form_vals(), (data) ->
    console.info data
    for [val, name] in data.choices
      $("<option></option>").attr("value", val).text(name).appendTo(combo)
    if data.selected != ""
      $(combo).val(data.selected)
    combo.chosen()

add_parameter = (target, param) ->
  if param.type in ["combo", "genome_build"]
    cur_target = $("<div></div>").attr("class", "form-row").appendTo(target)
    $("<label></label>").text(param.name).appendTo(cur_target)
    if param.type == "genome_build"
      _add_genome_build(cur_target, param)
    else
      _add_combobox(cur_target, param)
  else if param.type is "barcode"
    _add_barcodes(param)

# Fill parameters to configure the current pipeline
fill_parameters = () ->
  target = $("div#parameters_form")
  # if we've already added this, do not do it again
  if target.find("form").length > 0
    return
  target_form = $("<form></form>").appendTo(target);
  std_div = $("<div></div>").appendTo(target_form)
  bc_div = $("<div id='barcode_entry'></div>").appendTo(target_form)
  $("<input type='hidden'></input").attr
    id: "barcodes_entered"
    name: "barcodes_entered"
    value: ""
  .appendTo(target_form)
  pipeline = $("input#pipeline").attr("value")
  $.getJSON $("div#param_url").attr("value"), {pipeline: pipeline}, (data) ->
    add_parameter(std_div, p) for p in data.params
    target_form.validate()

# Update selected form parameters
update_parameters = () ->
  target = $("div#parameters_form").children("form")[0]
  out_dom = $("input#params")
  out = {}
  for child in $(target).find("select")
    out[$(child).attr("name")] = $(child).val()
  bc = $("input#barcodes_entered")
  if $(bc).val()
    out[$(bc).attr("name")] = JSON.parse($(bc).val())
  out_dom.attr("value", JSON.stringify(out))

# ## Summary panel

cur_form_vals = () ->
  form_vals = {}
  for input in $("form.jWizard_form").find("input:hidden")
    form_vals[$(input).attr("name")] = $(input).attr("value")
  return form_vals

prepare_summary = () ->
  $("div#summary_panel").load($("div#summary_url").attr("value"), cur_form_vals())

# ## Main document
$ ->
  fill_analysis_types()

  wiz = $(".jWizard_form")
  wiz.validate
    errorClass: "ui-state-error-text"
    messages:
      datasets: "Please choose at least one dataset to run in the pipeline"
  wiz.jWizard
    hideTitle: true
    menuEnable: true
    buttons:
      cancelHide: true
      finishType: "submit"
      finishText: "Process"
  .bind "jwizardchangestep", step_manager(wiz)
