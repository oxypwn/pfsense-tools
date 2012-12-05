
	
	EditArea.prototype.set_font= function(family, size){
	//	document.getElementById("test_area").style.font="10pt courier";
	//	document.getElementById("test_area").style.backgroundColor="#987654";
		//setAttribute(document.getElementById("test_area"), "style", "font: 10pt courier;");
		var elems= new Array(this.id, "content_highlight", "edit_area_test_font_size", "cursor_pos", "end_bracket", "selection_field", "line_number");
		if(family && family!="")
			this.font_family= family;
		if(size && size>0)
			this.font_size=size;
		if(!this.isIE && !this.isNS){	
			var elem_font=document.getElementById("area_font_size");		
			for(var i=0; i < elem_font.length; i++){
				if(elem_font.options[i].value && elem_font.options[i].value == this.font_size)
						elem_font.options[i].selected=true;
			}
		}
				
		//this.lineHeight= Math.floor(this.font_size*1.6);
		/*if(this.isNS && !this.isIE)
			this.lineHeight= Math.floor((this.font_size)*1.5)-1;*/
		/*else*/
		if(this.isOpera || this.isSafari){	// bad solution!!!!
			this.lineHeight= Math.floor(this.font_size*1.6);
			this.charWidth=Math.ceil(this.lineHeight/2);
			if(size==8)
				this.charWidth++;		
		}
		for( var i in elems){
			var elem=	document.getElementById(elems[i]);	
			if(this.isOpera || this.isSafari){	// opera doesn't support style modification for textarea by elem.style...= value;
				//alert("set");
				setAttribute(elem, "style", getAttribute(elem, "style") +";font-size: "+this.font_size+"pt;font-family: "+this.font_family+";line-height: "+this.lineHeight+"px;");	
				//setAttribute(elem, "style", getAttribute(elem, "style") +";font-size: "+this.font_size+"pt;font-family: "+this.font_family+"; ");	
			}else{
				document.getElementById(elems[i]).style.fontFamily= ""+this.font_family;
				document.getElementById(elems[i]).style.fontSize= this.font_size+"pt";
				//document.getElementById(elems[i]).style.lineHeight= this.lineHeight+"px";
				//document.getElementById(elems[i]).style.lineHeight= "14pt";
			}
		}
		
		//alert(	getAttribute(document.getElementById("edit_area_test_font_size"), "style"));
		if(!this.isOpera){
			document.getElementById("edit_area_test_font_size").innerHTML="0";	
			this.charWidth= document.getElementById('edit_area_test_font_size').offsetWidth;
			this.lineHeight= document.getElementById("edit_area_test_font_size").offsetHeight;
		}
		if(this.isIE){
			// IE have a fixed size for tabulation and not a given number of caracters
		/*	document.getElementById("edit_area_test_font_size").innerHTML="\t0";		
			this.charWidth= (document.getElementById("edit_area_test_font_size").offsetWidth / this.charWidth) -1;*/
		}
		//alert("font "+this.textarea.style.font);
		// force update of selection field
		this.last_line_selected=-1;
		if(this.state=="loaded"){
			this.textarea.focus();
			this.textareaFocused=true;
		}
		this.last_selection["indexOfCursor"]=-1;
		this.last_selection["curr_pos"]=-1;					
		//alert("line_h"+ this.lineHeight + " char width: "+this.charWidth+ " this.id: "+this.id+ "(size: "+size+")");
	};
	
	EditArea.prototype.change_font_size= function(){
		var size=document.getElementById("area_font_size").value;
		if(size>0)
			this.set_font("", size);
			
	};
	
	
	EditArea.prototype.open_inline_popup= function(popup_id){
		this.close_all_inline_popup();
		var popup= document.getElementById(popup_id);		
		var area= document.getElementById("edit_area");
		
		// search matching icon
		for(var i in this.inlinePopup){
			if(this.inlinePopup[i]["popup_id"]==popup_id){
				var icon= document.getElementById(this.inlinePopup[i]["icon_id"]);
				if(icon){
					this.switchClassSticky(icon, 'editAreaButtonSelected', true);			
					break;
				}
			}
		}
		if(!popup.postionned){
			var new_left= calculeOffsetLeft(area) + area.offsetWidth /2 - popup.offsetWidth /2;
			var new_top= calculeOffsetTop(area) + area.offsetHeight /2 - popup.offsetHeight /2;
			//var new_top= area.offsetHeight /2 - popup.offsetHeight /2;
			//var new_left= area.offsetWidth /2 - popup.offsetWidth /2;
			//alert("new_top: ("+new_top+") = calculeOffsetTop(area) ("+calculeOffsetTop(area)+") + area.offsetHeight /2("+ area.offsetHeight /2+") - popup.offsetHeight /2("+popup.offsetHeight /2+") - scrollTop: "+document.body.scrollTop);
			popup.style.left= new_left+"px";
			popup.style.top= new_top+"px";
			popup.postionned=true;
		}
		popup.style.visibility="visible";
		
		//popup.style.display="block";
	}

	EditArea.prototype.close_inline_popup= function(popup_id){
		var popup= document.getElementById(popup_id);		

		// search matching icon
		for(var i in this.inlinePopup){
			if(this.inlinePopup[i]["popup_id"]==popup_id){
				var icon= document.getElementById(this.inlinePopup[i]["icon_id"]);
				if(icon){
					this.switchClassSticky(icon, 'editAreaButtonNormal', false);			
					break;
				}
			}
		}
		
		popup.style.visibility="hidden";	
	}
	
	EditArea.prototype.close_all_inline_popup= function(e){
		for(var i in this.inlinePopup){
			this.close_inline_popup(this.inlinePopup[i]["popup_id"]);		
		}
		this.textarea.focus();
	};
	
	EditArea.prototype.show_help= function(){
		this.open_inline_popup("edit_area_help");
	};
			
	EditArea.prototype.new_document= function(){
		this.textarea.value="";
		this.area_select(0,0);
	};
	
	EditArea.prototype.get_all_toolbar_height= function(){
		var area= document.getElementById("edit_area");
		var results=getChildren(area, "div", "class", "area_toolbar", "all", "0");	// search only direct children
		results= results.concat(getChildren(area, "table", "class", "area_toolbar", "all", "0"));
		var height=0;
		for(var i in results){			
			height+= results[i].offsetHeight;
		}
		//alert("toolbar height: "+height);
		return height;
	};
	
	EditArea.prototype.go_to_line= function(){		
		var icon= document.getElementById("go_to_line_icon");
		if(icon != null){
			this.restoreClass(icon);
			this.switchClassSticky(icon, 'editAreaButtonSelected', true);
		}
		
		var line= prompt(this.getLang("go_to_line_prompt"), "");
		if(line && line!=null && line.search(/^[0-9]+$/)!=-1){
			var start=0;
			var lines= this.textarea.value.split("\n");
			if(line > lines.length)
				start= this.textarea.value.length;
			else{
				for(var i=0; i< Math.min(line-1, lines.length); i++)
					start+= lines[i].length + 1;
			}
			this.area_select(start, 0);
		}
		if(icon != null)
			this.switchClassSticky(icon, 'editAreaButtonNormal', false);
		
	};
	
	
	EditArea.prototype.change_line_selection_mode= function(setTo){
		//alert("setTo: "+setTo);
		if(setTo != null){
			if(setTo === false)
				this.line_selection=true;
			else
				this.line_selection=false;
		}
		var icon= document.getElementById("change_line_selection_icon");
		this.textarea.focus();
		if(this.line_selection===true){
			//setAttribute(icon, "class", getAttribute(icon, "class").replace(/ selected/g, "") );
			/*setAttribute(icon, "oldClassName", "editAreaButtonNormal" );
			setAttribute(icon, "className", "editAreaButtonNormal" );*/
			//this.restoreClass(icon);
			//this.restoreAndSwitchClass(icon,'editAreaButtonNormal');
			this.switchClassSticky(icon, 'editAreaButtonNormal', false);
			
			this.line_selection=false;
			document.getElementById("selection_field").style.display= "none";
			document.getElementById("cursor_pos").style.display= "none";
			document.getElementById("end_bracket").style.display= "none";
		}else{
			//setAttribute(icon, "class", getAttribute(icon, "class") + " selected");
			//this.switchClass(icon,'editAreaButtonSelected');
			this.switchClassSticky(icon, 'editAreaButtonSelected', false);
			this.line_selection=true;
			document.getElementById("selection_field").style.display= "block";
			document.getElementById("cursor_pos").style.display= "block";
			document.getElementById("end_bracket").style.display= "block";
		}	
	};
	
	// the auto scroll of the textarea has some lacks when it have to show cursor in the visible area when the textarea size change
	EditArea.prototype.scroll_to_view= function(){
		if(!this.line_selection)
			return;
		if(this.isOpera){
			//alert(this.textarea.scrollLeft);
			/*res=document.getElementById("result");
			document.getElementById("line").value="offsetLeft: "+calculeOffsetLeft(this.textarea)+" scroll"+this.textarea.scrollLeft+ " width: "+ this.textarea.offsetWidth;
			res.scrollLeft=0;
			this.textarea.scrollTop=0;
			this.textarea.scrollLeft=0;
			this.textarea.style.left="0px";*/
		}
	/*	if(this.isIE){
			
			this.textarea.scrollTop=0;
			this.textarea.scrollLeft=0;
		}*/
		var zone= document.getElementById("result");
		
		//var cursor_pos_top= parseInt(document.getElementById("cursor_pos").style.top.replace("px",""));
		var cursor_pos_top= document.getElementById("cursor_pos").cursor_top;
		var max_height_visible= zone.clientHeight + zone.scrollTop;
		var miss_top= cursor_pos_top + this.lineHeight - max_height_visible;
		if(miss_top>0){
			zone.scrollTop= zone.scrollTop + miss_top;
		}else if( zone.scrollTop > cursor_pos_top){
			// when erase all the content -> does'nt scroll back to the top
			zone.scrollTop= cursor_pos_top;	 
		}
		//var cursor_pos_left= parseInt(document.getElementById("cursor_pos").style.left.replace("px",""));
		var cursor_pos_left= document.getElementById("cursor_pos").cursor_left;
		var max_width_visible= zone.clientWidth + zone.scrollLeft;
		var miss_left= cursor_pos_left + this.charWidth - max_width_visible;
		if(miss_left>0){			
			zone.scrollLeft= zone.scrollLeft + miss_left+ 50;
		}else if( zone.scrollLeft > cursor_pos_left){
			zone.scrollLeft= cursor_pos_left;
		}else if( zone.scrollLeft == 45){
			// show the line numbers if textarea align to it's left
			zone.scrollLeft=0;
		}
		//if(miss_top> 0 || miss_left >0)
			//alert("miss top: "+miss_top+" miss left: "+miss_left);
	};
	
	EditArea.prototype.check_undo= function(){
		if(this.textareaFocused){
			var text=this.textarea.value;
			if(this.previous.length<1)
				this.switchClassSticky(document.getElementById("undo_icon"), 'editAreaButtonDisabled', true);
			/*var last= 0;
			for( var i in this.previous){
				last=i;
			}*/
			if(this.previous[this.previous.length-1] != text){
				this.previous.push(text);
				if(this.previous.length > this.max_undo+1)
					this.previous.shift();
			}
			if(this.previous.length == 2)
				this.switchClassSticky(document.getElementById("undo_icon"), 'editAreaButtonNormal', false);
		}
			//if(this.previous[0] == text)	
		if(this.state=="loaded")		
			setTimeout("editArea.check_undo()", 1000);
	};
	
	EditArea.prototype.undo= function(){
		//alert("undo"+this.previous.length);
		if(this.previous.length > 0){
			var pos_cursor=this.getSelectionInfos()["indexOfCursor"];
			this.next.push(this.textarea.value);
			var text= this.previous.pop();
			if(text==this.textarea.value && this.previous.length > 0)
				text=this.previous.pop();						
			this.textarea.value= text;
			this.area_select(pos_cursor, 0);
			this.switchClassSticky(document.getElementById("redo_icon"), 'editAreaButtonNormal', false);
			//alert("undo"+this.previous.length);
		}
	};
	
	EditArea.prototype.redo= function(){
		if(this.next.length > 0){
			var pos_cursor=this.getSelectionInfos()["indexOfCursor"];
			var text= this.next.pop();
			this.previous.push(this.textarea.value);
			this.textarea.value= text;
			this.area_select(pos_cursor, 0);
			this.switchClassSticky(document.getElementById("undo_icon"), 'editAreaButtonNormal', false);
			
		}
		if(	this.next.length == 0)
			this.switchClassSticky(document.getElementById("redo_icon"), 'editAreaButtonDisabled', true);
	};
	
	EditArea.prototype.switchClass = function(element, class_name, lock_state) {
		var lockChanged = false;
	
		if (typeof(lock_state) != "undefined" && element != null) {
			element.classLock = lock_state;
			lockChanged = true;
		}
	
		if (element != null && (lockChanged || !element.classLock)) {
			element.oldClassName = element.className;
			element.className = class_name;
		}
	};
	
	EditArea.prototype.restoreAndSwitchClass = function(element, class_name) {
		if (element != null && !element.classLock) {
			this.restoreClass(element);
			this.switchClass(element, class_name);
		}
	};
	
	EditArea.prototype.restoreClass = function(element) {
		if (element != null && element.oldClassName && !element.classLock) {
			element.className = element.oldClassName;
			element.oldClassName = null;
		}
	};
	
	EditArea.prototype.setClassLock = function(element, lock_state) {
		if (element != null)
			element.classLock = lock_state;
	};
	
	EditArea.prototype.switchClassSticky = function(element, class_name, lock_state) {
		var lockChanged = false;
	
	/*	// Performance issue
		if (!this.stickyClassesLookup[element_name])
			this.stickyClassesLookup[element_name] = document.getElementById(element_name);
	
	//	element = document.getElementById(element_name);
		element = this.stickyClassesLookup[element_name];*/
	
		if (typeof(lock_state) != "undefined" && element != null) {
			element.classLock = lock_state;
			lockChanged = true;
		}
	
		if (element != null && (lockChanged || !element.classLock)) {
			element.className = class_name;
			element.oldClassName = class_name;
	
			// Fix opacity in Opera
			if (this.isOpera) {
				if (class_name == "mceButtonDisabled") {
					var suffix = "";
	
					if (!element.mceOldSrc)
						element.mceOldSrc = element.src;
	
					if (this.operaOpacityCounter > -1)
						suffix = '?rnd=' + this.operaOpacityCounter++;
	
					element.src = this.baseURL + "/images/opacity.png" ;
					element.style.backgroundImage = "url('" + element.mceOldSrc + "')";
				} else {
					if (element.mceOldSrc) {
						element.src = element.mceOldSrc;
						element.parentNode.style.backgroundImage = "";
						element.mceOldSrc = null;
					}
				}
			}
		}
	};