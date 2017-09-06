## Provide a simple table summary of selected parameters
<style type="text/css">
.summary_list { list-style-type: none; margin: 0; padding: 0.2em;}
</style>

<table class="grid">
  <tbody>
    %for name, val in table_vals:
      <tr class="libraryRow libraryOrFolderRow draggable">
        <td><b>${name}</b></td>
        <td>${val}</td>
      </tr>
    %endfor
  </tbody>
</table>

<input type="hidden" id="out_date" name="out_date" value="${out_date}"/>
<input type="hidden" id="out_ext" name="out_ext" value="${out_ext}"/>

<br/>
<p>
Results will be available as a folder in the Shared Data Libraries,
${username}/${out_date}_${out_ext}.
</p>
