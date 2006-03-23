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

require("guiconfig.inc");

$pgtitle = "CoreGUIBuilder";

$closehead = false;

include("head.inc");

?>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link href="/styles/script.aculo.us.css" media="screen" rel="Stylesheet" type="text/css" />
	<style type="text/css">
		div.about_screen {
		  background-color:#990000;
		  padding:8px;
		  width:98%;
		}			
		div.toolboxborder {
			position: absolute;
			top: 69px;
			left: 460px;
		  border:1px solid #eeeeee;
		  background-color:white;
		  padding:8px;
		  width:200px;
		}		
		div.formcanvas {
		  border:1px solid #990000;
		  background-color:white;
		  padding:8px;
		  width:420px;
		  height:900px;
		}		
		span.title {
		  margin:0;
		  padding:0;
		  padding-top:10px;
		  font-size: 12px;
		  color: #444;
		  font-weight:normal;
		}	
		div.auto_complete {
		  position:absolute;
		  width:250px;
		  background-color:white;
		  border:1px solid #888;
		  margin:0px;
		  padding:0px;
		}
		ul.contacts  {
		  list-style-type: none;
		  margin:0px;
		  padding:0px;
		}
		ul.contacts li.selected { background-color: #ffb; }
		li.contact {
		  list-style-type: none;
		  display:block;
		  margin:0;
		  padding:2px;
		  height:32px;
		}
		li.contact div.image {
		  float:left;
		  width:32px;
		  height:32px;
		  margin-right:8px;
		}
		li.contact div.name {
		  font-weight:bold;
		  font-size:12px;
		  line-height:1.2em;
		}
		li.contact div.email {
		  font-size:10px;
		  color:#888;
		}
		#list {
		  margin:0;
		  margin-top:10px;
		  padding:0;
		  list-style-type: none;
		  width:250px;
		}
		#list li {
		  margin:0;
		  margin-bottom:4px;
		  padding:5px;
		  border:1px solid #888;
		  cursor:move;
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
	<script src="/javascript/scriptaculous/prototype.js" type="text/javascript"></script>
	<script src="/javascript/scriptaculous/effects.js" type="text/javascript"></script>
	<script src="/javascript/scriptaculous/dragdrop.js" type="text/javascript"></script>
	<script src="/javascript/scriptaculous/controls.js" type="text/javascript"></script>
	<script src="/javascript/scriptaculous/scriptaculous.js" type="text/javascript"></script>
</head>

<body link="#000000" vlink="#000000" alink="#000000">

<?php include("fbegin.inc"); ?>

<p class="pgtitle"><?=$pgtitle?></font></p>

<form action="index.php" method="post" name="iform">

<div id="about_screen" name="about_screen" class="about_screen" onClick="closeAboutScreen();">
	<table width="100%">
	  <tr><td>
	    <center>
		<font color="white">
		<a href="#" style="color:white" onClick="closeAboutScreen()">
		<h2>Welcome to CoreGUIBuilder!</h2>
		<p>
		CoreGUIBuilder aides you in rapidly designing a CoreGUIBuilder XML based form.
		</a>
		</font>
	  </td></tr>
	</table>
</div>

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
	<div onDblClick="OnDropForm('textarea',  0)" class="toolbox" name="textarea" id="textarea">Textarea<br><textarea name="textarea_control"></textarea></div>
	<br>
	<div onDblClick="OnDropForm('input',     0)" class="toolbox" name="input" id="input">Input<br><input name="input_control"></div>
	<br>
	<div onDblClick="OnDropForm('password',  0)" class="toolbox" name="password" id="password">Password<br><input name="password"></div>
	<br>
	<div onDblClick="OnDropForm('checkbox',  0)" class="toolbox" name="checkbox" id="checkbox">Checkbox<br><input type="checkbox" name="checkbox"></div>
	<br>
	<div onDblClick="OnDropForm('select',    0)" class="toolbox" name="select" id="select">Select box<br><select><option>OPTION1</option></select></div>
	<br>
	<div onDblClick="OnDropForm('interfaces_select', 0)" class="toolbox" name="interfaces_select" id="interfaces_select">Interfaces selection<br><select><option>WAN</option><option>LAN</option></select></div>
	<br>
	<div onDblClick="OnDropForm('headerbar', 0)" class="toolbox" name="headerbar" id="headerbar" style="background-color:#990000"><font color="white">Header</div>
	<br>
</div>

<script type="text/javascript">
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
</script>

<script type="text/javascript">
	/* how many items have been added to the form canvas? */
	var form_elements = 0;

	/*  properties holds each "element" in the forms
     *  variables, such as field name, caption,
     *  etc.
     */
	function FORM_ELEMENTS(field_name, left_caption, right_caption, element_id) {
		this.field_name = field_name;
		this.element_id = element_id;
		this.left_caption = left_caption;
		this.right_caption = right_caption;
		
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
			row.setAttribute("bgcolor", "#990000");
			cell1.innerHTML = '<div style="color:white" name="' + form_elements + '_headerbar" id="' + form_elements + '_headerbar">Click me to edit...</div>';
			row.appendChild(cell1);
			tbody.appendChild(row);
			new Ajax.InPlaceEditor(form_elements + '_headerbar', 'index.php', { callback: function(form, value) { updateHeaderCaption(form.id, value); return '&myparam=' + escape(value) }});
		} else {
			var row = document.createElement('tr');
			row.setAttribute("id", "formcanvas_row_" + form_elements);
			var cell1 = document.createElement('td');
			var cell2 = document.createElement('td');
			cell1.innerHTML = '<p name="' + form_elements + '_left_caption" id="' + form_elements + '_left_caption">Click me to edit...</p>';
			cell1.setAttribute("class", "vncellreq");
			cell2.innerHTML = newCanvasItem('Test', field, element_id) + '<p><p name="' + form_elements + '_right_caption" id="' + form_elements + '_right_caption">Click me to edit...</p>';
			cell2.setAttribute("class", "vtable");
			row.appendChild(cell1);
			row.appendChild(cell2);
			tbody.appendChild(row);
			new Ajax.InPlaceEditor(form_elements + '_left_caption', 'index.php', { callback: function(form, value) { updateLeftCaption(form.id, value); return '&myparam=' + escape(value) }});
			new Ajax.InPlaceEditor(form_elements + '_right_caption', 'index.php', { callback: function(form, value) { updateRightCaption(form.id, value); return '&myparam=' + escape(value) }});	
		}
		/* create a new javascript object on our form element tracking array */
		form_elements_properties[form_elements] = new FORM_ELEMENTS( 'field_name', 'Click me to edit...', 'Click me to edit...' , element_id);
		/* make the new element draggable in its container */
		new Draggable('formcanvas_row_' + form_elements, {revert:false})
		/* we now have another control.  ++ our controller count */
		form_elements++;		
		/* allow the form canvas area to be resortable */
		Sortable.create('formcanvas_tbody',{dropOnEmpty:true,tag:'tr'});
	}
	
	/* convert a field type to beginning html */
	function newCanvasItem(text, field, element_id) {
		switch(element_id) {
			case "textarea":
				return "<textarea></textarea>";
			case "input":
				return "<input></input>";
			case "password":
				return "<input type=\"password\"></input>";
			case "checkbox":
				return "<input type='checkbox'></input>";
			case "select":
				return "<select><option>OPTION1</option></select>";
			case "interfaces_select":
				return "<select><option>WAN</option><option>LAN</option></select>";
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
		new Effect.SlideDown('about_screen', {duration:.5});
	}
	
	function show_main_form() {
		$('formcanvas').style.visibility = 'visible';
		$('toolbox').style.visibility = 'visible';	
	}
	
	function closeAboutScreen() {
		new Effect.SlideUp('about_screen', {duration:.5});		
		//$('about_screen').style.visibility="hidden";
        window.setTimeout('show_main_form()', 700);
		return false;
	}	

	/* callback used after in place editing for the left caption area */
	function updateHeaderCaption(formid, value) {
		var formid_split = formid.split("_");
		var id = formid_split[0];
		form_elements_properties[id].left_caption = value;
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
	
	/* expand about screen on bootup */
	expandAboutScreen();
	
</script>

<br>

<b>NOTE:</b> "Click me to edit..." will be stripped out when the form is exported to XML.

<?php include("fend.inc"); ?>

</body>
</html>



