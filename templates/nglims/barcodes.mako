## HTML and javascript for associating samples with barcodes when building
## multiplexed flowcells.
<%def name="stylesheets()">
${h.css( "base" )}
<link href="${h.url_for('/static/jquery_css/jquery-ui-humanity.css')}" rel="stylesheet" type="text/css" />
<style type="text/css">
  #barcode_pane {width: 30%; float:left; margin-right: 20px;}
  #sample_pane {width: 50%; float:left;}
  .sample_pane_header {margin-bottom: 24px}
  #barcode_choice {margin: 5px 5px 5px 5px;}
  #add-button {margin-top: 10px;}
  #submit-button {margin-top: 10px;}
  .sample_to_barcode {height: 20px;}
  .sample_barcode_target {width: 48%; float: left; margin: 2px 2px 2px 2px;}
  ul.sample_sort { list-style-type: none; margin: 0; padding: 0.5em;}
  li.sample_sort {margin: 0 2px 2px 2px; padding: 0.2em; height: 14px;}
  li.sample_sort span.ui-icon { position: absolute; margin-left: -1.3em; }
  h4 {margin-bottom:1px; margin-top: 4px;}
  .tipsy {font-size: 14px;}
  .tipsy-inner {max-width: 300px;}
  </style>
</%def>

<%def name="javascripts()">
  ${h.js("jquery", "jquery-ui", "jquery.jeditable")}
  ${h.js("jquery.validate")}
  <script type="text/javascript">
    /*global $ document console window*/
    /*jslint indent:2 */
    $(document).ready(function () {
      // Update the list of available barcodes based on the current selection
      var update_avail_barcodes = function () {
    $("#barcode_choice input:checked").each(function () {
      var choice_data = {barcode_type: this.id};
      $.getJSON("${barcode_details}", choice_data, function (data) {
        var targets = $("#avail_barcodes");
        targets.children("li").remove();
        $(".sample_to_barcode").children("li").remove();
        $(".sample_to_barcode").toggleClass('valid_target', true);
        $.each(data.names, function (index, value) {
          $("<li id='draggable' class='ui-state-default sample_sort'>" + value + "</li>")
          .appendTo(targets);
        });
      });
    });
      };
      $("#barcode_choice").buttonset();
      $("#barcode_choice").change(update_avail_barcodes);
      update_avail_barcodes();
      // Modify samples as potential targets for barcodes based on whether
      // they have a barcode assigned or not. Remove close buttons from items
      // with assigned barcodes.
      var update_available = function () {
    $(".sample_to_barcode").each(function () {
      $(this).toggleClass('valid_target',
          (this.children.length === 0));
      if (this.children.length === 0) {
        $(this).parent().find(".close-button").show();
      } else {
        $(this).parent().find(".close-button").hide();
      }
    });
      };
      // Lists to provide barcodes and mappings between samples and barcodes
      // These allow barcodes to be dragged to samples for association.
      var make_samples_sortable = function () {
    $(".sample_to_barcode").sortable({
      placeholder: "ui-state-highlight",
      forcePlaceholderSize: true,
      revert: "invalid",
      helper: 'clone',
      receive: update_available,
      connectWith: "#avail_barcodes,.valid_target"
    });
      };
      // Sample names that are editable in place. Store the update on each edit.
      var make_samples_editable = function () {
    $('.editable').editable(function (value, settings) {
      $(this).parent().parent().find("ul").each(function () {
        if (value) {
          $(this).attr("id", "NEW^^" + value);
          $(this).attr("name", value);
        } else {
          $(this).attr("id", "");
          $(this).attr("name", "");
        }
      });
      return value;
    }, {
      onblur: 'submit',
      placeholder: 'Click to edit name'
    }).bind("click", function() {
      $(this).find("form").validate({ignore: ".valid"});
    });
      };
      // Allow removal of samples
      var make_samples_closeable = function () {
    $(".close-button").button({
      text: false,
      icons: {primary: "ui-icon-close"}
    }).click(function () {
      var holder = $(this).parent().parent();
      $(holder).remove();
    });
      };
      // Provide a callback function for submitting barcode data
      // This can either write to a local store item keyed by ID
      // or pass directly to the server
      % if data_store_id:
    var submit_fn_wrapper = function(bc_data) {
      return function () {
        $("#${data_store_id}").attr("value", JSON.stringify(bc_data));
        $("#${data_store_id}").change();
      };
    };
      % else:
      var submit_fn_wrapper = function(bc_data) {
        return function () {
          $.ajax({
        type: "POST",
        dataType: "json",
        url: "${h.url_for(assoc_barcodes)}",
        data: "data=" + JSON.stringify(bc_data),
        success: function (msg) {
          window.location = $("#callback_url").attr("value");
        }
          });
        };
      };
      % endif
      // Summarize barcoded data associations, including missing data.
      var get_barcode_data = function () {
    var sample_barcodes = [],
        not_filled = [],
        not_named = false,
        barcode_type = $("#barcode_choice input:checked").attr("id"),
            parent_id = $("#parent_id").attr("value");
    // Collect the details from each sample
    $(".sample_to_barcode").each(function () {
      var cur_barcode = $(this).find("li").first().html();
      if (!$(this).attr("id")) {
        not_named = true; 
      } else if (cur_barcode) {
        sample_barcodes.push([$(this).attr("id"), cur_barcode]);
      } else {
        not_filled.push($(this).attr("name"));
      }
    });
    return {barcodes: sample_barcodes, barcode_type: barcode_type,
                parent_id: parent_id,
        not_filled: not_filled, not_named: not_named};
      };
      // Retrieve barcode information, check for errors and submit if fine
      var check_and_submit = function(submit_fn_wrap) {
    var bc_data = get_barcode_data(),
        submit_fn = submit_fn_wrap(bc_data);
    // Send barcode information to backend and redirect
    // If we haven't filled in all the samples
    if (bc_data.not_filled.length > 0 || bc_data.not_named) {
      if (bc_data.not_filled.length > 0) {
        $("#missing-barcode-text").html("Some sub-samples do not have barcodes:");
        $("#missing-barcodes").html(bc_data.not_filled.join("<br/>"));
      } else {
        $("#missing-barcode-text").html("");
        $("#missing-barcodes").html("");
      }
      if (bc_data.not_named) {
        $("#unnamed-text").html("Samples were added without names.");
      } else {
        $("#unnamed-text").html("");
      }
      $("#dialog-confirm").data('submit_fn', submit_fn).dialog("open");
    } else {
      submit_fn();
    }
    return false;
      };
      make_samples_sortable();
      make_samples_editable();
      make_samples_closeable();
      $("#avail_barcodes").sortable({
    placeholder: "ui-state-highlight",
    forcePlaceholderSize: true,
    revert: "invalid",
    helper: 'clone',
    receive: update_available,
    connectWith: ".valid_target"
      });
      $("ul, li").disableSelection();
      // Confirmation dialog when samples do not have barcodes
      $("#dialog-confirm").dialog({
    autoOpen: false,
    modal: true,
    buttons: {
      % if data_store_id:
          "OK": function () {
        $(this).dialog("close");
           }
      % else:
          "Keep editing": function () {
        $(this).dialog("close");
          },
          "Submit barcodes": function () {
        $(this).dialog("close");
        $(this).data('submit_fn')();
          }
      % endif
    }
      });
      // Button to handle submission of barcodes
      $("#submit-button").button().click(function () {
    return check_and_submit(submit_fn_wrapper);
      });
      % if not parent_id and len(samples) == 0:
      $("#submit-button").hide();
      % endif
      // Add a new sub-sample item, allowing it to be sorted, edited and closed.
      $("#add-button").button().click(function () {
    var new_target = "<div class='sample_barcode_target'>" +
      "<div><h4 style='float: left' class='editable'></h4>" +
      "<span style='float:right' class='close-button'/></div>" +
          "<ul style='clear: both' class='sample_to_barcode valid_target sample_sort ui-widget-content'>" +
      "</ul></div>";
    $(new_target).appendTo($("#target_samples"));
    make_samples_sortable();
    make_samples_editable();
    make_samples_closeable();
    return false;
      });
    });
  </script>
</%def>

${self.stylesheets()}
${self.javascripts()}

  <div id="barcode_pane">
    <h4 class="ui-widget-header">Barcodes</h4>
    <div id="barcode_choice">
      % for barcode in barcodes:
        <input type="radio" name="radio" id="${barcode}"
         ${('checked="checked"' if barcode == default_barcode_type else '')} />
        <label for="${barcode}">${barcode}</label>
      % endfor
    </div>
    <ul id="avail_barcodes" class="ui-widget-content sample_sort">
    </ul>
  </div>

  <div id="sample_pane">
    <h4 class="ui-widget-header sample_pane_header">${sample_title}</h4>
    <div id="target_samples">
      % for (sid, sname) in samples:
    <div class="sample_barcode_target">
      <h4>${sname}</h4>
      <ul id="${sid}" name="${sname}" class="sample_to_barcode valid_target sample_sort ui-widget-content">
      </ul>
    </div>
      % endfor
      % for sname in editable_samples:
    <div class="sample_barcode_target">
      <div>
        <h4 style="float: left" class="editable">${sname}</h4>
        <span style="float:right" class="close-button"/>
      </div>
      <ul style="clear: both" id="NEW^^${sname}" name="${sname}" class="sample_to_barcode valid_target sample_sort ui-widget-content">
      </ul>
    </div>
      % endfor
    </div>
  <input type="hidden" id="parent_id" value="${parent_id}"/>
  <input type="hidden" id="callback_url" value="${callback_url}"/>

  <div style="clear: both"></div>
  % if len(editable_samples) > 0 or (len(samples) == 0 and len(editable_samples) == 0):
      <button id="add-button">Add new sub-sample</button>
  % endif
  <button id="submit-button">Save barcodes</button>
  <div id="dialog-confirm" title="Missing data">
  <span class="ui-icon ui-icon-alert" style="float:left; margin:0 5px 0px 0;"></span>
  <p id="unnamed-text"></p>
  <p id="missing-barcode-text"></p>
  <div id="missing-barcodes"></div>
  </div>
  </div>

<div class="form-row">
</div>
<div style="clear: both"></div>
