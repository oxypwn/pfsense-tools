<?php
/* $Id$ */
/*
	index.php - CoreGUIBuilder Application
	Copyright (C) 2006 Scott Ullrich
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	1. Redistributions of source code must retain the above copyright notice,
	   this list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/

if($_POST['myparam']) {
	echo $_POST['myparam'];
	exit;
}

/* paths to used libraries */
$path_to_scriptaculous = "/javascript/scriptaculous";
$path_to_prototype     = "/javascript/prototype";
$path_to_tabber 	   = "";
$path_to_css           = "";

//$path_to_scriptaculous = "http://www.pfsense.com/~sullrich/javascript/scriptaculous";
//$path_to_prototype     = "http://www.pfsense.com/~sullrich/javascript/prototype";
//$path_to_css           = "http://www.pfsense.com/~sullrich/";

$pgtitle = "CoreGUIBuilder alpha1";

$closehead = false;

?>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link rel="stylesheet" href="example.css" media="all" />
  <link rel="stylesheet" href="<?=$path_to_css?>/gui.css" media="all" />
  <link href="/styles/script.aculo.us.css" media="screen" rel="Stylesheet" type="text/css" />
	<style type="text/css">
		div.about_screen {
		  padding:8px;
		  width:98%;
		}			
		div.toolboxborder {
		  position: absolute;
		  top: 83px;
		  left: 570px;
		  border:1px solid #eeeeee;
		  background-color:white;
		  padding:8px;
		  width:260px;
		}
		div.propertiesbox {
		  position: absolute;
		  top: 445px;
		  left: 570px;
		  visibility:hidden;
		  border:1px #eeeeee;
		  background-color:white;
		  padding:8px;
		  width:200px;
		}				
		div.formcanvas {
		  border:1px solid #0088cc;
		  background-color:white;
		  padding:8px;
		  width:530px;
		  height:930px;
		}
		div.formcanvas-active {
		  background-color: #FFF4D8;
		}
		.vncellreqCore {
			float:left;
			background-color: #DDDDDD;
			padding-right: 20px;
			padding-left: 8px;
			font-weight: bold;
			border-bottom: 1px solid #999999;
		}
		.vtableCore {
			float:right;
			border-bottom: 1px solid #999999;
		}		
	</style>
	
	
	<script src="<?=$path_to_scriptaculous?>/prototype.js" type="text/javascript"></script>
	<script src="<?=$path_to_scriptaculous?>/effects.js" type="text/javascript"></script>
	<script src="<?=$path_to_scriptaculous?>/dragdrop.js" type="text/javascript"></script>
	<script src="<?=$path_to_scriptaculous?>/controls.js" type="text/javascript"></script>
	<script src="<?=$path_to_scriptaculous?>/scriptaculous.js" type="text/javascript"></script>
	<script src="tabber.js" type="text/javascript"></script>

</head>

<body link="#000000" vlink="#000000" alink="#000000">

<p class="pgtitle" id="pgtitle" name="pgtitle" style="visibility:hidden"><?=$pgtitle?></font></p>

<form action="index.php" method="post" name="iform">

<div id="about_screen" name="about_screen" class="about_screen" onClick="closeAboutScreen();">
	<center><img src="images/coreguilogo.gif"></center><br>&nbsp;
	<table width="100%" bgcolor="#0088cc">
	  <tr><td>
	    <center>
		<font color="white">
		<a href="#" style="color:white" onClick="closeAboutScreen()">		
		<h1>Welcome to CoreGUIBuilder!</h1>
		<p><b>
		<table width="400">
		  <tr><td>
			<font color="white">
			  <center>
				CoreGUIBuilder aides you in rapidly designing a CoreGUI XML based form.  With CoreGUIBUilder you can
				drag and drop interface elements onto a virtual canvas.  Set their properties and CoreGUIBuilder will
				automatically generate XML that can be used in your CoreGUI application/form.
				<p>
				To use CoreGUIBuilder, simply drag the Toolbox elements onto the form, edit any areas that say
				Click here to edit and then click Show XML to show the generated XML.  This XML can then be used
				by the pfSense CoreGUI engine.
				<p>
				<b>Click here to begin.</b>
			  </center>
			</font>	
			</td>
		  </tr>
		</table>
		</a>
		</font>
	  </td></tr>
	</table>
	<div><center><br>&nbsp;<a href="http://www.spreadfirefox.com/?q=affiliates&id=0&t=57"><img border="0" alt="Get Firefox!" title="Get Firefox!" src="http://sfx-images.mozilla.org/affiliates/Buttons/180x60/blank.gif"/></a></div>
</div>

<div id="tabber" name="tabber" class="tabber">

<div id="tab1" class="tabbertab" title="Canvas">

<div>
	<div id="indicator" style="display:none;margin-top:0px;">
	<img alt="Indicator" src="/themes/metallic/images/misc/loader.gif" /> Updating form ...
	</div>
</div>

<div id="formcanvas" class="formcanvas" style="clear:left; height:500px;margin-top:10px;">
	<b>Drag items to create form:</b><p>
	<table width="100%" border="0" name="formcanvas_table" id="formcanvas_table">
		<tbody name="formcanvas_tbody" id="formcanvas_tbody">
		</tbody>
	</table>
</div>

<p>

<div id="toolbox" name="toolbox" class="toolboxborder">
	<font color="black">
	<b>Toolbox</b><p>
	<div onDblClick="OnDropForm('headerbar', 0)" class="toolbox" name="headerbar" id="headerbar"><img src='images/header.gif'></div>
	<div onDblClick="OnDropForm('textarea',  0)" class="toolbox" name="textarea" id="textarea"><img src='images/textarea.gif'></div>
	<div onDblClick="OnDropForm('input',     0)" class="toolbox" name="input" id="input"><img src='images/inputfield.gif'></div>
	<div onDblClick="OnDropForm('password',  0)" class="toolbox" name="password" id="password"><img src='images/passwordfield.gif'></div>
	<div onDblClick="OnDropForm('checkbox',  0)" class="toolbox" name="checkbox" id="checkbox"><img src='images/checkbox.gif'></div>
	<div onDblClick="OnDropForm('select',    0)" class="toolbox" name="select" id="select"><img src='images/optiondropdown.gif'></div>
	<div onDblClick="OnDropForm('interfaces_select', 0)" class="toolbox" name="interfaces_select" id="interfaces_select"><img src='images/interfacedropdown.gif'></div>
</div>

<div id="propertiesbox" name="propertiesbox" class="propertiesbox">
	<font color="black">
	<b>Properties</b><p>
	<div id="propbox" name="propbox">
		<table width="100%" height="100">
			<tr><td>
				<!-- properties box here -->
			</td></tr>
		</table>
	</div>
</div>

<br>

<font color="black">

<div id="infofooter" name="infofooter" style="visibility:hidden">
	<b>NOTE:</b> "Click me to edit..." will be stripped out when the form is exported to XML.
</div>

<p>&nbsp;

</div>

<div id="tab2" class="tabbertab" title="Source">
	<textarea id="sourceviewta" name="sourceviewta" id="src" rows="35" cols="95"></textarea>	
</div>

</div>
<script type="text/javascript">
	var field_order = new Array();
	/* init the draggables */
	new Draggable('textarea',			{revert:true})
	new Draggable('input',				{revert:true})
	new Draggable('password',			{revert:true})
	new Draggable('checkbox',			{revert:true})
	new Draggable('select',   			{revert:true})
	new Draggable('headerbar', 			{revert:true})
	new Draggable('interfaces_select',	{revert:true})
	/* init the droppable */
	Droppables.add('formcanvas', {
									accept:'toolbox',
									hoverclass:'formcanvas-active',
									onDrop:function(element, ethelist, ev){
									OnDropForm(element.id, Event.pointerY(ev))
								 }
				   });

	/* how many items have been added to the form canvas? */
	var form_elements = 0;

	/*   properties holds each "element" in the forms
     *   variables, such as field name, caption,
     *   etc.  Clever use of javascript to create
     *   an object.
     */
	function FORM_ELEMENTS(field_name, left_caption, right_caption, element_id, size) {
		this.field_name     = field_name;
		this.element_id     = element_id;
		this.left_caption   = left_caption;
		this.right_caption  = right_caption;
		this.size           = size;
	}

	/* setup an array that holds the item info such as text description, etc */
	var form_elements_properties = Array();
	
	function OnDropForm(element_id, positionY, field) {
		var table = document.getElementById("formcanvas_table");
		var tbody = document.getElementById('formcanvas_table').getElementsByTagName('tbody')[0];
		if(element_id == 'headerbar') {
			var row = document.createElement('tr');
			row.setAttribute("height", "40");
			row.setAttribute("id", "formcanvas_row_" + form_elements);
			var cell1 = document.createElement('td');
			cell1.setAttribute("colspan", "2");
			row.setAttribute("bgcolor", "#0088cc");
			cell1.innerHTML = '<div style="color:white" name="' + form_elements + '_headerbar" id="' + form_elements + '_headerbar">Click me to edit header...</div>';
			row.appendChild(cell1);
			tbody.appendChild(row);
			new Ajax.InPlaceEditor(form_elements + '_headerbar', 'index.php', { callback: function(form, value) { updateHeaderCaption(form.id, value); return '&myparam=' + escape(value) }});
		} else {
			var row = document.createElement('tr');
			row.setAttribute("id", "formcanvas_row_" + form_elements);
			var cell1 = document.createElement('td');
			var cell2 = document.createElement('td');
			cell1.innerHTML = '<p name="' + form_elements + '_left_caption" id="' + form_elements + '_left_caption">Click me to edit fieldname...</p>';
			cell1.setAttribute("class", "vncellreq");
			cell2.innerHTML = newCanvasItem('Click me to edit Description...', field, element_id) + '<p><p name="' + form_elements + '_right_caption" id="' + form_elements + '_right_caption">Click me to edit Description...</p>';
			cell2.setAttribute("class", "vtable");
			row.appendChild(cell1);
			row.appendChild(cell2);
			tbody.appendChild(row);
			new Ajax.InPlaceEditor(form_elements + '_left_caption', 'index.php', { callback: function(form, value) { updateLeftCaption(form.id, value); return '&myparam=' + escape(value) }});
			new Ajax.InPlaceEditor(form_elements + '_right_caption', 'index.php', { callback: function(form, value) { updateRightCaption(form.id, value); return '&myparam=' + escape(value) }});
		}
		/* create a new javascript object on our form element tracking array */
		form_elements_properties[form_elements] = new FORM_ELEMENTS( 'field_name', 'Click me to edit fieldname...', 'Click me to edit description...' , element_id);
		/* make the new element draggable in its container */
		new Draggable('formcanvas_row_' + form_elements, {revert:false})
		/* we now have another control.  ++ our controller count */
		form_elements++;		
		/* allow the form canvas area to be resortable */
        
		Sortable.create('formcanvas_tbody',{"onUpdate":function(){ updateOrder(); update_source(); }, dropOnEmpty:true,tag:'tr'});
		/* resize formcanvas */
		resize_formcanvas();
		/* update canvas order */
		updateOrder();
		/* sync current xml source with text editor window */
		update_source();
	}
	
	function updateOrder() {
		if(form_elements == 0)
			return;
		var seq = Sortable.serialize('formcanvas_tbody');
		for(x=0; x< form_elements; x++) {
			seq = seq.replace("formcanvas_tbody[]=","");
			seq = seq.replace("row_","");
			seq = seq.replace("&","|");
		}
		field_order = seq.split("|");
		update_source();
	}
	
	function resize_formcanvas() {
		/* resize main area to fit all of the elements */
        if(form_elements > 5) 
			$('formcanvas').style.height = 485 + (90 * (form_elements-5));
		else
			$('formcanvas').style.height = 485;
	}
	
	/* convert a field type to beginning html */
	function newCanvasItem(text, field, element_id) {
		switch(element_id) {
			case "textarea":
				fieldname = form_elements + '_textarea';
				return "<textarea id='" + fieldname + "' name='" + fieldname + "'></textarea>";
			case "input":
				fieldname = form_elements + '_input';
				return "<input id='" + fieldname + "' name='" + fieldname + "'></input>";
			case "password":
				fieldname = form_elements + '_password';
				return "<input id='" + fieldname + "' name='" + fieldname + "' type=\"password\"></input>";
			case "checkbox":
				fieldname = form_elements + '_checkbox';
				return "<input id='" + fieldname + "' name='" + fieldname + "' type='checkbox'></input>";
			case "select":
				fieldname = form_elements + '_select';
				return "<select name='" + fieldname + "'><option>OPTION1</option></select>";
			case "interfaces_select":
				fieldname = form_elements + '_interfaces_select';
				return "<select id='" + fieldname + "' name='" + fieldname + "'><option>WAN</option><option>LAN</option></select>";
			case "headerbar":
				return "";
			/* default fallback case */
			return "";
		}
	}

	/* delete a form canvas element (aka row) */
	function deleterow(rowid) {
		var table = document.getElementById("formcanvas_table");
		var tr = document.getElementById(rowid);
		table.deleteRow();
		form_elements--;
	}
	
	function expandAboutScreen() {
		$('formcanvas').style.visibility = 'hidden';
		$('toolbox').style.visibility = 'hidden';
		$('about_screen').style.visibility = 'visible';
		$('about_screen').style.display = 'none';
		$('tabber').style.visibility = 'hidden';
		new Effect.SlideDown('about_screen', {duration:1});
	}

	function update_source() {
		if(form_elements == 0) {
			return;
		}
		$('sourceviewta').value = formCanvas2XML();
	}
	
	function show_main_form() {
		$('formcanvas').style.visibility = 'visible';
		$('toolbox').style.visibility = 'visible';
		$('infofooter').style.visibility = 'visible';
		$('pgtitle').style.visibility = 'visible';
		$('propertiesbox').style.visibility = 'hidden';
	}
	
	function closeAboutScreen() {
		$('tabber').style.visibility = 'visible';
		new Effect.SlideUp('about_screen', {duration:.5});		
        window.setTimeout('show_main_form()', 700);
		return false;
	}	

	/* callback used after in place editing for the left caption area */
	function updateHeaderCaption(formid, value) {
		var formid_split = formid.split("_");
		var id = formid_split[0];
		form_elements_properties[id].left_caption = value;
		form_elements_properties[id].right_caption = value;
	}
	
	/* callback used after in place editing for the left caption area */
	function updateLeftCaption(formid, value) {
		var formid_split = formid.split("_");
		var id = formid_split[0];
		form_elements_properties[id].left_caption = value;
	}

	/* callback used after in place editing for the right caption area */
	function updateRightCaption(formid, value) {
		var formid_split = formid.split("_");
		var id = formid_split[0];
		form_elements_properties[id].right_caption = value;
	}
	
	function formCanvas2XML() {
		var x;
		var newXML;
		var form_name;
		var form_version;
		var form_title;
		var field_size;
		var field_type;
		newXML = '';
		newXML = newXML + '<packagegui>\n';
		newXML = newXML + '\t<name>' + form_name + '</name>\n';
		newXML = newXML + '\t<version>' + form_version + '</version>\n';
		newXML = newXML + '\t<title>' + form_title + '</title>\n';
		newXML = newXML + "\t<configpath>['installedpackages']['" + form_name + "']['config']</configpath>\n";
		newXML = newXML + '\t<fields>\n';
		/* enumerate all items on formcanvas */
		for(x=0; x<form_elements; x++) {

			var field_name  = form_elements_properties[field_order[x]].left_caption;
			var field_descr = form_elements_properties[field_order[x]].right_caption;
			var field_size  = form_elements_properties[field_order[x]].size;
			var element_id  = form_elements_properties[field_order[x]].element_id;			
			/* replace default strings with '' */
			field_name = field_name.replace("Click me to edit fieldname...", "");			
			field_name = stripspecialchars(field_name);
			field_descr = field_descr.replace("Click me to edit description...", "");
			newXML = newXML + '\t<field>\n';
			newXML = newXML + '\t\t<fielddescr>' + field_descr + '</fielddescr>\n';
			newXML = newXML + '\t\t<fieldname>' + field_name + '</fieldname>\n';
			newXML = newXML + '\t\t<description>' + field_descr + '</description>\n';
			newXML = newXML + '\t\t<type>' + element_id + '</type>\n';
			if(field_size) 
				newXML = newXML + '\t\t<size>' + field_size + '</size>\n';
			newXML = newXML + '\t</field>\n';
		}
		newXML = newXML + '\t</fields>\n';
		newXML = newXML + '\t<!-- php hooks -->\n';
		newXML = newXML + '\t<include_file></include_file>\n';
		newXML = newXML + '\t<custom_delete_php_command>\n';
		newXML = newXML + '\t</custom_delete_php_command>\n';
		newXML = newXML + '\t<custom_php_resync_config_command>\n';
		newXML = newXML + '\t</custom_php_resync_config_command>\n';
		newXML = newXML + '\t<custom_php_install_command>\n';
		newXML = newXML + '\t</custom_php_install_command>\n';
		newXML = newXML + '\t<custom_php_deinstall_command>\n';
		newXML = newXML + '\t</custom_php_deinstall_command>\n';
		newXML = newXML + '</packagegui>\n';
		return newXML;
	}
	
	function stripspecialchars(field) {
		var strip_array = new Array();
		strip_array[0] = " ";
		for (var tostrip in strip_array) {
			var newfield = field.replace(" ", "");
		}
		return newfield;
	}
	
	/* expand about screen on bootup */
	expandAboutScreen();
	
	resize_formcanvas();

	if(navigator.appName == "Microsoft Internet Explorer") {
		alert("Warning!!\n\nIE does not work very well with this app.\n\nUse FireFox for a better experience!\n\nhttp://www.getfirefox.com");	
	}
	
</script>

</body>
</html>



