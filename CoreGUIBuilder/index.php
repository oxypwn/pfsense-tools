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

require("guiconfig.inc");

$pgtitle = "CoreGUIBuilder";

$closehead = false;

include("head.inc");

?>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link href="/styles/script.aculo.us.css" media="screen" rel="Stylesheet" type="text/css" />
	<style type="text/css">
		div.toolboxborder {
		  clear:both;
		  border:1px solid #eeeeee;
		  background-color:white;
		  padding:8px;
		  width:500px;
		}		
		div.formcanvas {
		  clear:both;
		  border:1px solid #990000;
		  background-color:white;
		  padding:8px;
		  width:500px;
		  height:500px;
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

<form action="" method="post" name="iform">

<div>
	<div id="indicator" style="display:none;margin-top:0px;">
	<img alt="Indicator" src="/themes/metallic/images/misc/loader.gif" /> Updating form ...
	</div>
</div>

Drag items to create form:
<div id="formcanvas" class="formcanvas" style="clear:left; height:500px;margin-top:10px;">
	<table width="100%" border="0" id="formcanvas_table">
		<tbody id="formcanvas_tbody"></tbody>
	</table>
</div>

<p>

Toolbox
<div id="toolbox" class="toolboxborder">
	<div class="toolbox" name="textarea" id="textarea">Textarea<br><textarea name="textarea_control"></textarea></div>
	<br>
	<div class="toolbox" name="input" id="input">Input<br><input name="input_control"></div>
	<br>
	<div class="toolbox" name="checkbox" id="checkbox">Checkbox<br><input name="checkbox"></div>
</div>

<script type="text/javascript">
	/* init the draggables */
	new Draggable('textarea', {revert:true})
	new Draggable('input', 	  {revert:true})
	new Draggable('checkbox', {revert:true})
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
	function OnDropForm(element_id, positionY, field) {
		var table = document.getElementById("formcanvas_table");
		var tbody = document.getElementById('formcanvas_table').getElementsByTagName('tbody')[0];
		var row = document.createElement('TR');
		var cell1 = document.createElement('TD');
		var cell2 = document.createElement('TD');
		cell1.innerHTML = 'Testing';
		cell1.setAttribute("class", "vncellreq");
		cell2.innerHTML = newCanvasItem('Test', field, element_id);
		cell2.setAttribute("class", "vtable");
		row.appendChild(cell1);
		row.appendChild(cell2);
		tbody.appendChild(row); 
	}
	function newCanvasItem(text, field, element_id) {
		switch(element_id) {
			case "textarea":
				return "<textarea rows='2' cols='2'></textarea>";
			break;
			case "input":
				return "<input>";
			break;
			case "checkbox":
				return "<input type='checkbox'>";
			break;
		}
	}
</script>

<br>

<?php include("fend.inc"); ?>

</body>
</html>
