	var EditArea_advanced_buttons = [
		// Control id, button img, button title, command
		['new_document', 'newdocument.gif', 'new_document'],
		['search', 'search.gif', 'show_search'],
		['go_to_line', 'go_to_line.gif', 'go_to_line'],
		['undo', 'undo.gif', 'undo'],
		['redo', 'redo.gif', 'redo'],
		['change_line_selection', 'line_selection.gif', 'change_line_selection_mode'],
		['reset_highlight', 'reset_highlight.gif', 'reSync'],
		['highlight', 'highlight.gif','changeHighlight'],
		['help', 'help.gif', 'show_help'],
		['save', 'save.gif', 'save'],
		['load', 'load.gif', 'load']
	];

	EditArea.prototype.get_control_html= function(button_name) {		
		
		for (var i=0; i<EditArea_advanced_buttons.length; i++)
		{
			var but = EditArea_advanced_buttons[i];			
			if (but[0] == button_name)
			{
				var cmd = 'editArea.execCommand(\'' + but[2] + '\')';
				html= '<a href="javascript:' + cmd + '" onclick="' + cmd + ';return false;" onmousedown="return false;" target="_self">';
				html+= '<img id="' + but[0] + '_icon" src="'+ this.baseURL +'images/' + but[1] + '" title="' + this.getLang(but[0]) + '" width="20" height="20" class="editAreaButtonNormal" onmouseover="editArea.switchClass(this,\'editAreaButtonOver\');" onmouseout="editArea.restoreClass(this);" onmousedown="editArea.restoreAndSwitchClass(this,\'editAreaButtonDown\');" /></a>';
				return html;
			}	
		}		
				
		switch (button_name){
			case "|":
		  	case "separator":
				return '<img src="'+ this.baseURL +'images/spacer.gif" width="1" height="15" class="editAreaSeparatorLine">';
			case "select_font":
				if(!editArea.isIE && !editArea.isNS){
					html= "<select id='area_font_size' onchange='javascript:editArea.change_font_size()'>"
						+"			<option value='-1'>--Font size--</option>"
						+"			<option value='8'>8 pt</option>"
						+"			<option value='9'>9 pt</option>"
						+"			<option value='10'>10 pt</option>"
						+"			<option value='11'>11 pt</option>"
						+"			<option value='12'>12 pt</option>"
						+"			<option value='14'>14 pt</option>"
						+"		</select>";
					return html + this.get_control_html("|");
				}
		}
		
		return "";		
	};
	
	
	EditArea.prototype.get_template= function() {
		return "<div id='edit_area_template' style='visibility: hidden;'>"
+"<div id='resize_hidden_field'></div>"
+"<div id='edit_area' class='edit_area' style='border: solid 1px #888888;'>"
+"	<div class='area_toolbar' id='toolbar_1'>[__TOOLBAR__]</div>"
+"	"
+"  <div id='result' class='result' style='position: relative; z-index: 4; overflow: scroll;border-top: solid #888888 1px;border-bottom: solid #888888 1px;'> "
+"    <div id='container' style=' '> "
+"      <div id='cursor_pos' class='edit_area_cursor'>&nbsp;</div>"
+"      <div id='end_bracket' class='edit_area_cursor'>&nbsp;</div>"
+"      <div id='selection_field' class='edit_area_selection_field' style=''></div>"
+"      <div id='line_number' class='line_number' style='position: absolute;overflow: hidden;border-right: solid black 1px;z-index:8'>[__LINE_NUMBER__]</div>"
+"      <div id='content_highlight' style='padding: 0px 0 0 45px; position : absolute; z-index: 4; overflow: visible; white-space: nowrap;'></div>"
+"      <textarea id='editArea_textarea' style='padding: 0 0px 0 45px; width: 100%; position: absolute; overflow: hidden;  z-index: 7; border: solid red 0px;background-color: transparent;' "
+"			class='area hidden' wrap='off' onfocus='javascript:editArea.textareaFocused=true;' onblur='javascript:editArea.textareaFocused=false;'>"
+"		</textarea>"
+"		<span id='edit_area_test_font_size' style='padding: 0; margin: 0; visibility: hidden; border: solid red 0px;'></span>"
+"    </div>"
+"  </div>"
+"	"
+"	<table class='area_toolbar' style='' cellspacing='0' cellpadding='0'>"
+"		<tr>"
+"			<td class='total'>{$position}:</td>"
+"			<td class='infos'>"
+"				{$line_abbr} <span  id='linePos'>0</span>, {$char_abbr} <span id='currPos'>0</span>"
+"			</td>"
+"			<td class='total'>{$total}:</td>"
+"			<td class='infos'>"
+"				{$line_abbr} <span id='nbLine'>0</span>, {$char_abbr} <span id='nbChar'>0</span>"
+"			</td>"
+"			"
+"			"
+"			<td align='right'><span id='resize_area' style='cursor: nw-resize;'><img src='"+ editArea.baseURL +"images/statusbar_resize.gif'></span></td>"
+"		</tr>"
+"	</table>"
+"</div>"
+"<div id='area_search_replace' class='editarea_popup'>"
+"	<table cellspacing='2' cellpadding='0' style='width: 100%'>"
+"		<tr>"
+"			<td>{$search}</td>"
+"			<td><input type='text' id='area_search' /></td>"
+"			<td rowspan='2' style='text-align: right; vertical-align: top; white-space: nowrap;'>"
+"				<a href='Javascript:editArea.hidden_search()'><img src='"+ editArea.baseURL +"images/close.gif' alt='close' title='{$close_popup}' /></a><br>"
+"				<div id='move_area_search_replace' style='cursor: move; padding: 3px 3px; margin-top: 3px; border: solid 1px #888888;' onmousedown='start_move_element(event,\"area_search_replace\")'  />move</div>			"
+"		</tr><tr>"
+"			<td>{$replace}</td>"
+"			<td><input type='text' id='area_replace' /></td>"
+"		</tr>"
+"	</table>"
+"	<div class='button'>"
+"		<input type='checkbox' id='area_search_match_case' /><label for='area_search_match_case'>{$match_case}</label>"
+"		<input type='checkbox' id='area_search_reg_exp' /><label for='area_search_reg_exp'>{$reg_exp}</label>"
+"		<br />"
+"		<a href='Javascript:editArea.area_search()'>{$find_next}</a>"
+"		<a href='Javascript:editArea.area_replace()'>{$replace}</a>"
+"		<a href='Javascript:editArea.area_replace_all()'>{$replace_all}</a><br />"
+"	</div>"
+"	<div id='area_search_msg' style='height: 18px; overflow: hidden; border-top: solid 1px #888888; margin-top: 3px;'></div>"
+"</div>"
+"<div id='edit_area_help' class='editarea_popup'>"
+"	<div class='close_popup' style='float: right'>"
+"		<a href='Javascript:editArea.close_all_inline_popup()'><img src='"+ editArea.baseURL +"images/close.gif' alt='close' title='{$close}' /></a>"
+"	</div> "
+"	<div><h2>Editarea</h2><br>"
+"		<h3>{$shortcuts}:</h3>"
+"			Tab: {$add_tab}<br>"
+"			Shift+Tab: {$remove_tab}<br>"
+"			Ctrl+f: {$search_command}<br>"
+"			Ctrl+r: {$replace_command}<br>"
+"			Ctrl+h: {$highlight}<br>"
+"			Ctrl+g: {$go_to_line}<br>"			
+"			Ctrl+q: {$close_popup}<br>"
+"			Ctrl+e: {$help}<br>"
+"			Accesskey E: {$toogle}<br>"
+"		<br>"
+"		<em>{$about_notice}</em>"
+"		<br><div class='copyright'>&copy; Christophe Dolivet - 2006</div>"
+"	</div>"
+"</div>"
+"</div>";
	};
	
