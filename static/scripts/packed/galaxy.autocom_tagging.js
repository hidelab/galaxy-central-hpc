function init_tag_click_function(b,a){$(b).find(".tag-name").each(function(){$(this).click(function(){var d=$(this).text();var c=d.split(":");a(c[0],c[1]);return true})})}jQuery.fn.autocomplete_tagging=function(m){var f={get_toggle_link_text_fn:function(n){var p="";var o=obj_length(n);if(o>0){p=o+(o>1?" Tags":" Tag")}else{p="Add tags"}return p},tag_click_fn:function(n,o){},editable:true,input_size:20,in_form:false,tags:{},use_toggle_link:true,item_id:"",add_tag_img:"",add_tag_img_rollover:"",delete_tag_img:"",ajax_autocomplete_tag_url:"",ajax_retag_url:"",ajax_delete_tag_url:"",ajax_add_tag_url:""};var d=jQuery.extend(f,m);var g=$(this);var b=g.find(".tag-area");var e=g.find(".toggle-link");var a=g.find(".tag-input");var l=g.find(".add-tag-button");e.click(function(){var n;if(b.is(":hidden")){n=function(){var o=$(this).find(".tag-button").length;if(o===0){b.click()}}}else{n=function(){b.blur()}}b.slideToggle("fast",n);return $(this)});if(d.editable){a.hide()}a.keyup(function(t){if(t.keyCode===27){$(this).trigger("blur")}else{if((t.keyCode===13)||(t.keyCode===188)||(t.keyCode===32)){var s=this.value;if(s.indexOf(": ",s.length-2)!==-1){this.value=s.substring(0,s.length-1);return false}if((t.keyCode===188)||(t.keyCode===32)){s=s.substring(0,s.length-1)}s=$.trim(s);if(s.length<2){return false}this.value="";var q=j(s);var p=b.children(".tag-button");if(p.length!==0){var u=p.slice(p.length-1);u.after(q)}else{b.prepend(q)}var o=s.split(":");d.tags[o[0]]=o[1];var r=d.get_toggle_link_text_fn(d.tags);e.text(r);var n=$(this);$.ajax({url:d.ajax_add_tag_url,data:{new_tag:s},error:function(){q.remove();delete d.tags[o[0]];var v=d.get_toggle_link_text_fn(d.tags);e.text(v);alert("Add tag failed")},success:function(){n.data("autocompleter").cacheFlush()}});return false}}});var i=function(q,p,o,s,r){var n=s.split(":");return(n.length===1?n[0]:n[1])};var h={selectFirst:false,formatItem:i,autoFill:false,highlight:false};a.autocomplete(d.ajax_autocomplete_tag_url,h);g.find(".delete-tag-img").each(function(){c($(this))});init_tag_click_function($(this),d.tag_click_fn);l.click(function(){$(this).hide();b.click();return false});if(d.editable){b.bind("blur",function(n){if(obj_length(d.tags)>0){l.show();a.hide();b.removeClass("active-tag-area")}else{}});b.click(function(p){var o=$(this).hasClass("active-tag-area");if($(p.target).hasClass("delete-tag-img")&&!o){return false}if($(p.target).hasClass("tag-name")&&!o){return false}$(this).addClass("active-tag-area");l.hide();a.show();a.focus();var n=function(r){var q=function(s,u){var t=s.attr("id");if(u!==s){s.blur();$(window).unbind("click.tagging_blur");$(this).addClass("tooltip")}};q(b,$(r.target))};$(window).bind("click.tagging_blur",n);return false})}if(d.use_toggle_link){b.hide()}function k(o,n){return o+(n?":"+n:"")}function c(n){$(n).mouseenter(function(){$(this).attr("src",d.delete_tag_img_rollover)});$(n).mouseleave(function(){$(this).attr("src",d.delete_tag_img)});$(n).click(function(){var t=$(this).parent();var s=t.find(".tag-name").eq(0);var r=s.text();var p=r.split(":");var v=p[0];var o=p[1];var u=t.prev();t.remove();delete d.tags[v];var q=d.get_toggle_link_text_fn(d.tags);e.text(q);$.ajax({url:d.ajax_delete_tag_url,data:{tag_name:v},error:function(){d.tags[v]=o;if(u.hasClass("tag-button")){u.after(t)}else{b.prepend(t)}alert("Remove tag failed");e.text(d.get_toggle_link_text_fn(d.tags));n.mouseenter(function(){$(this).attr("src",d.delete_tag_img_rollover)});n.mouseleave(function(){$(this).attr("src",d.delete_tag_img)})},success:function(){}});return true})}function j(n){var o=$("<img/>").attr("src",d.delete_tag_img).addClass("delete-tag-img");c(o);var p=$("<span>").text(n).addClass("tag-name");p.click(function(){var r=n.split(":");d.tag_click_fn(r[0],r[1]);return true});var q=$("<span></span>").addClass("tag-button");q.append(p);if(d.editable){q.append(o)}return q}};