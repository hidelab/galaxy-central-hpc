## Provide wizard to select pipelines, samples and associated data.
<%inherit file="/base.mako"/>

<%def name="stylesheets()">
  ${parent.stylesheets()}
  ${h.css("base")}
  ${h.stylesheet_link_tag("/static/jquery_css/jquery-ui-humanity.css")}
  ${h.stylesheet_link_tag("/static/jquery_css/jWizard.base.css")}
  ${h.stylesheet_link_tag("/static/jquery_css/chosen.css")}
  ${h.stylesheet_link_tag("/static/pipeline/selection.css")}
</%def>

<%def name="javascripts()">
  ${h.js("libs/jquery/jquery", "libs/jquery/jquery.tipsy", "jquery-ui", "libs/json2")}
  ${h.js("jquery.jWizard", "jquery.validate", "jquery.chosen")}
  ${h.javascript_include_tag("/static/pipeline/combobox.js")}
  ${h.javascript_include_tag("/static/pipeline/selection.js")}
</%def>

<%
  form_id="pipeline_selection"
%>
<form class="jWizard_form" name="${form_id}" id="${form_id}" action="${form_url}" method="post">
  <div id="pipeline_panel" title="Analysis type">
    <ul id="available_analyses" class="selectable selectable-limit">
    </ul>
    <input type="hidden" id="pipeline" name="pipeline" value=""/>
  </div>
  <div id="datasets_panel" title="Datasets">
    <div id="datasets-panel-available">
      <h4 class="ui-widget-header">Available</h4>
      <ul id="available_datasets" class="sortable valid_target ui-widget-content">
      </ul>
    </div>
    <div id="datasets-panel-target">
      <h4 class="ui-widget-header">To process</h4>
      <h4>Read</h4>
      <ul class="ui-widget-content sortable valid_target ready_target">
      </ul>
      <h4>Read pair (optional)</h4>
      <ul class="ui-widget-content sortable valid_target ready_target">
      </ul>
      <input type="hidden" id="datasets" name="datasets" class="required" value=""/>
    </div>
  </div>
  <div id="parameters_panel" title="Parameters">
    <div id="parameters_form">
    </div>
    <input type="hidden" id="params" name="params" value=""/>
  </div>
  <div id="summary_panel" title="Summary">
  </div>
</form>

<!-- Useful URLs for callbacks to avoid harcoding -->
<div id="type_url" value="${type_url}"/>
<div id="dset_url" value="${dset_url}"/>
<div id="param_url" value="${param_url}"/>
<div id="summary_url" value="${summary_url}"/>
<div id="barcode_url" value="${barcode_url}"/>
<div id="org_url" value="${org_url}"/>
