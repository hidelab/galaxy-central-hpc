<%inherit file="/webapps/galaxy/base_panels.mako"/>

<%def name="init()">
<%
    self.has_left_panel=False
    self.has_right_panel=False
    self.message_box_visible=False
%>
</%def>

<%def name="center_panel()">
  <iframe name="galaxy_main" id="galaxy_main" frameborder="0"
          style="position: absolute; width: 100%; height: 100%;"
          src="${start_url}">
  </iframe>
</%def>
