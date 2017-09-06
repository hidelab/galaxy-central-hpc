// Combobox from JqueryUI demos
// http://www.learningjquery.com/2010/06/a-jquery-ui-combobox-under-the-hood
// Modified to:
//   - Not pass on button presses
//   - Ignore return keypreses
//   - Revert to previous value when bad entry passed
//   - Also handle freetext entry
(function( $ ) {
  $.widget( "ui.combobox", {
    options: {
  freetext: false
    },
    _create: function() {
  var self = this,
    select = this.element.hide(),
    selected = select.children( ":selected" ),
    value = selected.val() ? selected.text() : "";
  var input = this.input = $( "<input>" )
    .insertAfter( select )
    .val( value )
    .autocomplete({
      delay: 0,
      minLength: 0,
      source: function( request, response ) {
        var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
        response( select.children( "option" ).map(function() {
      var text = $( this ).text();
      if ( this.value && ( !request.term || matcher.test(text) ) )
        return {
          label: text.replace(
            new RegExp(
          "(?![^&;]+;)(?!<[^<>]*)(" +
          $.ui.autocomplete.escapeRegex(request.term) +
          ")(?![^<>]*>)(?![^&;]+;)", "gi"
            ), "<strong>$1</strong>" ),
          value: text,
          option: this
        };
        }) );
      },
      select: function( event, ui ) {
        ui.item.option.selected = true;
        self._trigger( "selected", event, {
      item: ui.item.option
        });
      },
      change: function( event, ui ) {
        if ( !ui.item ) {
      var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
        valid = false;
      select.children( "option" ).each(function() {
        if ( $( this ).text().match( matcher ) ) {
          this.selected = valid = true;
          return false;
        }
      });
      if ( !valid ) {
        // remove invalid value, as it didn't match anything
        // revert to the last selected value, or nothing
        if (!self.options.freetext) {
          var prev_val = select.children(":selected").val() ? selected.text() : "";
          $( this ).val( prev_val );
          select.val( prev_val );
          input.data( "autocomplete" ).term = prev_val;
        // If freetext allowed, add our new entry and set it as selected
        } else {
          var val = $(this).val(),
          new_item = $("<option></option>").attr("value", val).html(val);
          new_item.appendTo(select);
          select.children("option").each(function() {
            if ($(this).text() === val) {
          this.selected = true;
          return false;
            }
          });
        }
        return false;
      }
        }
      }
    })
    .addClass( "ui-widget ui-widget-content ui-corner-left" );
  
  input.data( "autocomplete" )._renderItem = function( ul, item ) {
    return $( "<li></li>" )
      .data( "item.autocomplete", item )
      .append( "<a>" + item.label + "</a>" )
      .appendTo( ul );
  };
  // Ignore return being pressed, which raises up the first combobox
  // if multiple are present
  this.input.bind('keypress', function(e) {
    if ((e.keyCode || e.which) == 13) return false;
  });
  this.button = $( "<button>&nbsp;</button>" )
    .attr( "tabIndex", -1 )
    .attr( "title", "Show All Items" )
    .insertAfter( input )
    .button({
      icons: {
        primary: "ui-icon-triangle-1-s"
      },
      text: false
    })
    .removeClass( "ui-corner-all" )
    .addClass( "ui-corner-right ui-button-icon" )
    // Return false on click to prevent event from being propagated if in a form
    .click(function() {
      // close if already visible
      if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
        input.autocomplete( "close" );
        return false;
      }

      // pass empty string as value to search for, displaying all results
      input.autocomplete( "search", "" );
      input.focus();
      return false;
    });
    },

    destroy: function() {
  this.input.remove();
  this.button.remove();
  this.element.show();
  $.Widget.prototype.destroy.call( this );
    }
  });
})( jQuery );
