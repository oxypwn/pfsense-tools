
	EditArea.prototype.formatArea= function(){		
		var text=this.textarea.value;
		
		
		if(this.do_highlight){
			/*
			document.getElementById("line").value="content_offset_w: "+document.getElementById("content_highlight").offsetWidth;
			document.getElementById("line").value+="result_offset_w: "+document.getElementById("result").offsetWidth;
			document.getElementById("line").value+="area_client_w: "+this.textarea.scrollWidth;
			*/
			var new_width=Math.max(document.getElementById("content_highlight").offsetWidth, document.getElementById("result").offsetWidth);
			if(this.isGecko || ( this.isNS && !this.isIE ) ){
				new_width= Math.max(new_width, this.textarea.scrollWidth+50);
			}
			//if(document.compatMode!="BackCompat")
			if(!this.back_compat_mode)
				new_width-=45;
			if(this.isGecko && !this.isFirefox)
				new_width-=45;
				/*
			if(document.doctype!=null)
				new_width-=45;
			else if(this.isIE && document.compatMode!="BackCompat"){	// equals to a doctype is present for IE
				new_width-=45;			
			}*/
			
			this.textarea.style.width=new_width+"px";
			
			new_height=Math.max(document.getElementById("content_highlight").offsetHeight+15, document.getElementById("result").offsetHeight-15);			
			this.textarea.style.height=new_height+"px";			
			if(this.isGecko || ( this.isNS && !this.isIE ) ){
				this.textarea.style.height=(new_height+this.lineHeight + 5)+"px";		
			}
			document.getElementById("line_number").style.height=new_height+"px";
			document.getElementById("container").style.height=new_height+"px";			
		}else{
			// modify textarea size to content size
			var tab=text.split("\n");					
			var new_height=tab.length*this.lineHeight;
			var new_width=this.textarea.scrollWidth;
			if(!this.back_compat_mode )
				new_width-=45;
			
			
			
			
				/*
			if(document.doctype!=null)
				new_width-=45;
			else if(this.isIE && document.compatMode!="BackCompat"){	// equals to a doctype is present for IE
				new_width-=45;			
			}*/
			date= new Date();
			if(this.debug)
				document.getElementById("line").value="new height: "+new_height+" new width: "+new_width+ " scroll_w: "+document.getElementById("result").scrollWidth+ " "+date.getTime();

			this.textarea.style.height=new_height+"px";
			if(this.isGecko || ( this.isNS && !this.isIE ) ){
				this.textarea.style.height=(new_height+this.lineHeight + 5)+"px";		
			}
			
			document.getElementById("line_number").style.height=new_height+"px";		
			
			//document.getElementById("container").style.height=new_height+"px";
		/*	if(this.isOpera){
				new_width= document.getElementById("result").scrollWidth - 50;
				//new_height= document.getElementById("result").scrollHeight;
				var style=getAttribute(this.textarea, "style");
				if(new_width != this.textarea.style.width.replace("px","")){
				//	var new_style= style.replace(/ +;?width:[^;]*;/gmi, "")+";width: "+ new_width+"px; height: "+new_height+"px;";
				//	setAttribute(this.textarea, "style",  new_style);
					this.textarea.style.width= new_width+"px";
				}
				if(this.debug)
					document.getElementById("line").value="new w: "+new_width+" curr_width: "+this.textarea.style.width+" contain "+document.getElementById("result").scrollWidth+"\n"+style;
				
			}else if(this.isIE){
				this.textarea.style.width=new_width+"px";	
			}else{ // for padding
				this.textarea.style.width=new_width+45+"px";	
			}*/
			if(this.isOpera){
				new_width= document.getElementById("result").scrollWidth - 50;
				var style=getAttribute(this.textarea, "style");
				if(new_width != this.textarea.style.width.replace("px","")){
					var new_style= style.replace(/ +;?width:[^;]*;/gmi, "")+";width: "+ new_width+"px; height: "+new_height+"px;";
					setAttribute(this.textarea, "style",  new_style);
				}
				if(this.debug)
					document.getElementById("line").value="new w: "+new_width+" curr_width: "+this.textarea.style.width+" contain "+document.getElementById("result").scrollWidth+"\n scroll_l: "+this.textarea.scrollLeft+"\n"+style;			
			}else if(!this.isIE){// for padding
				new_width+=45;	
			}
			if(this.textarea.style.width.replace("px","") < new_width){
				new_width+=50;
			}
			/*if(this.isGecko && !this.isFirefox)
				document.getElementById*/
			this.textarea.style.width=new_width+"px";
			//}
			if(this.isGecko && !this.isFirefox){
				/*document.getElementById("result").style.width="500px";
				document.getElementById("container").style.width="500px";
				document.getElementById("src").style.width="500px";
				document.getElementById("selection_field").style.width="500px";*/
			}
			
			if(this.state=="loaded")
				setTimeout("editArea.formatArea();", 500);
		}		
	};
	
	EditArea.prototype.checkLineSelection= function(){
		//if(do_highlight==false){
		/*if(this.once!=1){
			alert("ONCE a"+ this.isResizing);
			this.once=1;
		}*/
		if(!this.line_selection && !this.do_highlight){
			//formatArea();
		}else if(this.textareaFocused && this.isResizing==false){
			infos= this.getSelectionInfos();
				
			if(infos["line_start"]<1)
				infos["line_start"]=1;
		
			if(this.last_line_selected != infos["line_start"] || this.last_selection_range != infos["line_nb"] || infos["full_text"] != this.last_selection["full_text"]){
			// if selection change
				new_top=this.lineHeight * (infos["line_start"]-1);
			//	if(this.isIE)
					//new_top++;
				new_height=Math.max(0, this.lineHeight * infos["line_nb"]);
				//new_width=Math.max(document.getElementById("content_highlight").offsetWidth, document.getElementById("result").offsetWidth, this.textarea.offsetWidth);
				new_width=Math.max(this.textarea.scrollWidth, document.getElementById("container").clientWidth -50);
				//document.getElementByIf("line").value
				//alert("new_geigh: "+ new_height);
				document.getElementById("selection_field").style.top=new_top+"px";	
				document.getElementById("selection_field").style.width=new_width+"px";
				document.getElementById("selection_field").style.height=new_height+"px";	
				document.getElementById("cursor_pos").style.top=new_top+"px";	
				
				if(this.do_highlight==true){
					var curr_text=infos["full_text"].split("\n");
					var content="";
					//alert("length: "+curr_text.length+ " i: "+ Math.max(0,infos["line_start"]-1)+ " end: "+Math.min(curr_text.length, infos["line_start"]+infos["line_nb"]-1)+ " line: "+infos["line_start"]+" [0]: "+curr_text[0]+" [1]: "+curr_text[1]);
					
					for(i=Math.max(0,infos["line_start"]-1); i<Math.min(curr_text.length, infos["line_start"]+infos["line_nb"]-1); i++){
						//content+= previous_content[i]+"<br>";					
						new_line= curr_text[i];
						if(this.doSmartTab)
							new_line= new_line.replace(/((\n?)([^\t\n]*)\t)/gi, this.smartTab);		// slower than simple replace...
						else
							new_line= new_line.replace(/\t/gi,"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
						new_line= new_line.replace(/&/g,"&amp;");
						new_line= new_line.replace(/</g,"&lt;");
						new_line= new_line.replace(/>/g,"&gt;");
						
						new_line= new_line.replace(/ /g,"&nbsp;");
						content+=new_line+"<br>";
					}
					document.getElementById("selection_field").innerHTML=content;
					this.startMajArea();
				}
				//document.getElementById("line").value="Curseur: "+infos["line_start"]+" nb_line: "+ infos["line_nb"]+ " new_top: "+new_top+" new_width: "+new_width+" new_height: "+new_height+" this.lineHeight: "+document.getElementById("content_highlight").style.lineHeight;
				/*document.getElementById("line").value+="\n container: "+document.getElementById("container").offsetWidth;
				document.getElementById("line").value+="\n result: "+document.getElementById("result").offsetWidth;
				document.getElementById("line").value+="\n src: "+this.textarea.offsetWidth;*/
					
			}
			
			if(infos["line_start"] != this.last_selection["line_start"] || infos["curr_pos"] != this.last_selection["curr_pos"]){
				// move _cursor_pos
				var selec_char= infos["curr_line"].charAt(infos["curr_pos"]-1);
				var no_real_move=true;
				if(infos["line_nb"]==1 && (this.assocBracket[selec_char] || this.revertAssocBracket[selec_char]) ){
					
					no_real_move=false;					
					//findEndBracket(infos["line_start"], infos["curr_pos"], selec_char);
					if(this.findEndBracket(infos, selec_char) === true){
						document.getElementById("end_bracket").style.visibility="visible";
						document.getElementById("cursor_pos").style.visibility="visible";
					}else{
						document.getElementById("end_bracket").style.visibility="hidden";
						document.getElementById("cursor_pos").style.visibility="hidden";
					}
				}else{
					document.getElementById("cursor_pos").style.visibility="hidden";
					document.getElementById("end_bracket").style.visibility="hidden";
				}
				this.displayToCursorPosition("cursor_pos", infos["line_start"], infos["curr_pos"]-1, infos["curr_line"], no_real_move);
				if(infos["line_nb"]==1)
					this.scroll_to_view();
			}
			//document.getElementById("line").value="end";
			//posLeft=infos["curr_line"].substr(0, infos["curr_pos"] -1).replace(/\t/g,"        ").length*8 + 45;
			//document.getElementById("line").value="Len: "+infos["curr_line"].substr(0, infos["curr_pos"]).replace(/\t/g,"        ").length +" cur: "+infos["curr_pos"]+ " char: "+selec_char;
			//document.getElementById("cursor_pos").style.left= posLeft+"px";		
			
			this.last_line_selected= infos["line_start"];
			this.last_selection_range= infos["line_nb"];
			this.last_selection=infos;
		}
		if(this.state=="loaded"){
			if(this.do_highlight==true)	//can slow down check speed when highlight mode is on
				setTimeout("editArea.checkLineSelection()", 100);
			else
				setTimeout("editArea.checkLineSelection()", 50);
		}
	}

	EditArea.prototype.getSelectionInfos= function(){
		var selections=new Array();
		selections["line_start"]=1;
		selections["line_nb"]=1;
		selections["full_text"]= this.textarea.value;
		selections["curr_pos"]=0;
		selections["curr_line"]="";
		selections["indexOfCursor"]=0;
		//return selections;	
		
		var splitTab=selections["full_text"].split("\n");
		var nbLine=Math.max(0, splitTab.length);		
		var nbChar=Math.max(0, selections["full_text"].length - (nbLine - 1));	// (remove \n caracters from the count)
		if(this.isIE)
			nbChar= nbChar - (nbLine -1);		// (remove \r caracters from the count)
		//if (this.textarea.createTextRange){
	/*	if(this.isIE){
			nbChar= nbChar - nbLine;
			if(!this.textareaFocused){
				this.textarea.focus();
				this.textareaFocused= true;
			}
			caretPos = document.selection.createRange();
			scrollTop=document.getElementById("result").scrollTop + document.body.scrollTop;
			var relative_top= caretPos.offsetTop - calculeOffsetTop(this.textarea) + scrollTop;
			if(!this.back_compat_mode)
				relative_top+= document.documentElement.scrollTop;
			selections["line_start"] = Math.round((relative_top / this.lineHeight) +1);
		
			selections["line_nb"]=Math.round(caretPos.boundingHeight / this.lineHeight);
			if(selections["line_start"]<0){
				selections["line_start"]=this.last_line_selected;
				selections["line_nb"]=this.last_selection_range;
			}
			
			var stored_range = caretPos.duplicate();			
			stored_range.moveToElementText( this.textarea );			
			stored_range.setEndPoint( 'EndToStart', caretPos );
			
			// text range correction in case of a selection was made and the new seleciton is inside the previous selection
			if(stored_range.parentElement().tagName=="BODY")
				stored_range.moveToElementText( this.textarea );
						
			var tab=selections["full_text"].substr(0, stored_range.text.length).split("\n");					
			var lastIndex=selections["full_text"].substr(0, stored_range.text.length+ (selections["line_start"] - tab.length)*2).lastIndexOf("\n");
			if(lastIndex==-1)
				selections["curr_pos"]=0;
			
		
			selections["curr_pos"]=stored_range.text.length - lastIndex + (selections["line_start"] - tab.length)*2;
			selections["indexOfCursor"]= stored_range.text.length;
		}else{
			start=this.textarea.selectionStart;
			end=this.textarea.selectionEnd;		
			if(start>0){
				var str=selections["full_text"].substr(0,start);
				selections["curr_pos"]=str.length - str.lastIndexOf("\n");
				selections["line_start"]=str.split("\n").length;
			}
			if(end>start){
				selections["line_nb"]=selections["full_text"].substring(start,end).split("\n").length;
			}
			selections["indexOfCursor"]=this.textarea.selectionStart;
		}*/
		if(this.isIE)
			this.getIESelection();
		start=this.textarea.selectionStart;
		end=this.textarea.selectionEnd;		
		if(start>0){
			var str=selections["full_text"].substr(0,start);
			selections["curr_pos"]=str.length - str.lastIndexOf("\n");
			selections["line_start"]=str.split("\n").length;
		}
		if(end>start){
			selections["line_nb"]=selections["full_text"].substring(start,end).split("\n").length;
		}
		selections["indexOfCursor"]=this.textarea.selectionStart;		
		selections["curr_line"]=splitTab[Math.max(0,selections["line_start"]-1)];
		
		document.getElementById("nbLine").innerHTML= nbLine;		
		document.getElementById("nbChar").innerHTML= nbChar;		
		document.getElementById("linePos").innerHTML=selections["line_start"];
		document.getElementById("currPos").innerHTML=selections["curr_pos"];
		
		return selections;
	};
	
	// set IE position in Firfox mode (textarea.selectionStart and textarea.selectionEnd)
	EditArea.prototype.getIESelection= function(){	
		var range = document.selection.createRange();
		
		var stored_range = range.duplicate();
		stored_range.moveToElementText( this.textarea );
		stored_range.setEndPoint( 'EndToEnd', range );
		if(stored_range.parentElement() !=this.textarea)
			return;
	
		// the range don't take care of empty lines in the end of the selection
		var scrollTop=document.getElementById("result").scrollTop + document.body.scrollTop;
		
		var relative_top= range.offsetTop - calculeOffsetTop(this.textarea) + scrollTop;
		if(!this.back_compat_mode)
			relative_top+= document.documentElement.scrollTop;
		var line_start = Math.round((relative_top / this.lineHeight) +1);
		
		var line_nb=Math.round(range.boundingHeight / this.lineHeight);
					
		var range_start=stored_range.text.length - range.text.length;
		var tab=this.textarea.value.substr(0, range_start).split("\n");			
		range_start+= (line_start - tab.length)*2;		// add missing empty lines to the selection
		this.textarea.selectionStart = range_start;
		
		var range_end=this.textarea.selectionStart + range.text.length;
		tab=this.textarea.value.substr(0, range_start + range.text.length).split("\n");			
		range_end+= (line_start + line_nb - 1 - tab.length)*2;
		
		this.textarea.selectionEnd = range_end;
	};
	
	// select the text for IE (and take care of \r caracters)
	EditArea.prototype.setIESelection= function(){
		var nbLineStart=this.textarea.value.substr(0, this.textarea.selectionStart).split("\n").length - 1;
		var nbLineEnd=this.textarea.value.substr(0, this.textarea.selectionEnd).split("\n").length - 1;
		var range = document.selection.createRange();
		range.moveToElementText( this.textarea );
		range.setEndPoint( 'EndToStart', range );
		
		range.moveStart('character', this.textarea.selectionStart - nbLineStart);
		range.moveEnd('character', this.textarea.selectionEnd - nbLineEnd - (this.textarea.selectionStart - nbLineStart)  );
		range.select();
	};
	
	EditArea.prototype.tabSelection= function(){
		if(this.is_tabbing)
			return;
		this.is_tabbing=true;
		//infos=getSelectionInfos();
		//if( document.selection ){
		if( this.isIE )
			this.getIESelection();
		
		/* Insertion du code de formatage */
		var start = this.textarea.selectionStart;
		var end = this.textarea.selectionEnd;
		var insText = this.textarea.value.substring(start, end);
		
		/* Insert tabulation and ajust cursor position */
		var pos_start=0;
		var pos_end=0;
		if (insText.length == 0) {
			// if only one line selected
			this.textarea.value = this.textarea.value.substr(0, start) + "\t" + insText + this.textarea.value.substr(end);
			pos_start = start + 1;
			pos_end=pos_start;
		} else {
			start= Math.max(0, this.textarea.value.substr(0, start).lastIndexOf("\n")+1);
			endText=this.textarea.value.substr(end);
			startText=this.textarea.value.substr(0, start);
			tmp= this.textarea.value.substring(start, end).split("\n");
			insText= "\t"+tmp.join("\n\t");
			this.textarea.value = startText + insText + endText;
			pos_start = start;
			pos_end= this.textarea.value.indexOf("\n", startText.length + insText.length);
			if(pos_end==-1)
				pos_end=this.textarea.value.length;
			//pos = start + repdeb.length + insText.length + ;
		}
		this.textarea.selectionStart = pos_start;
		this.textarea.selectionEnd = pos_end;
		
		//if( document.selection ){
		if(this.isIE){
			this.setIESelection();
			setTimeout("editArea.is_tabbing=false;", 100);	// IE can accept to make 2 tabulation without a little break between both
		}else
			this.is_tabbing=false;	
		
  	};
	
	EditArea.prototype.invertTabSelection= function(){
		if(this.is_tabbing)
			return;
		this.is_tabbing=true;
		//infos=getSelectionInfos();
		//if( document.selection ){
		if(this.isIE)
			this.getIESelection();
		
		var start = this.textarea.selectionStart;
		var end = this.textarea.selectionEnd;
		var insText = this.textarea.value.substring(start, end);
		
		/* Tab remove and sorsor selecitona djust */
		var pos_start=0;
		var pos_end=0;
		if (insText.length == 0) {
			this.textarea.value = this.textarea.value.substr(0, start) + "\t" + insText + this.textarea.value.substr(end);
			pos_start = start + 1;
			pos_end=pos_start;
		} else {
			start= this.textarea.value.substr(0, start).lastIndexOf("\n")+1;
			endText=this.textarea.value.substr(end);
			startText=this.textarea.value.substr(0, start);
			tmp= this.textarea.value.substring(start, end).split("\n");
			insText="";
			for(i=0; i<tmp.length; i++){				
				for(j=0; j<this.tab_nb_char; j++){
					if(tmp[i].charAt(0)=="\t"){
						tmp[i]=tmp[i].substr(1);
						j=this.tab_nb_char;
					}else if(tmp[i].charAt(0)==" ")
						tmp[i]=tmp[i].substr(1);
				}		
				insText+=tmp[i];
				if(i<tmp.length-1)
					insText+="\n";
			}
			//insText+="_";
			this.textarea.value = startText + insText + endText;
			pos_start = start;
			pos_end= this.textarea.value.indexOf("\n", startText.length + insText.length);
			if(pos_end==-1)
				pos_end=this.textarea.value.length;
			//pos = start + repdeb.length + insText.length + ;
		}
		this.textarea.selectionStart = pos_start;
		this.textarea.selectionEnd = pos_end;
		
		//if( document.selection ){
		if(this.isIE){
			// select the text for IE
			this.setIESelection();
			setTimeout("editArea.is_tabbing=false;", 100);	// IE can accept to make 2 tabulation without a little break between both
		}else
			this.is_tabbing=false;
  	};
	
	EditArea.prototype.pressEnter= function(){	
		if(!this.line_selection)
			return false;
		if(this.isIE)
			this.getIESelection();
		var start=this.textarea.selectionStart;
		var end= this.textarea.selectionEnd;
		var start_last_line= Math.max(0 , this.textarea.value.substring(0, start-1).lastIndexOf("\n") + 1 );
		var begin_line= this.textarea.value.substring(start_last_line, start).replace(/^([ \t]*).*/gm, "$1");
		if(begin_line=="\n" || begin_line.length==0)
			return false;
			//begin_line="";
		if(this.isIE)
			begin_line="\r\n"+ begin_line;
		else
			begin_line="\n"+ begin_line;
	
		//alert(start_last_line+" strat: "+start +"\n"+this.textarea.value.substring(start_last_line, start)+"\n_"+begin_line+"_")
		this.textarea.value= this.textarea.value.substring(0, start) + begin_line + this.textarea.value.substring(end);
		//put the cursor after the last postion
		this.textarea.selectionStart= start + begin_line.length;
	//	if(this.isIE)	// for \r
	//		this.textarea.selectionStart++;
		this.textarea.selectionEnd= this.textarea.selectionStart;
		
		if(this.isIE)
			this.setIESelection();
		return true;
		
	};
	
	
	EditArea.prototype.findEndBracket= function(infos, bracket){
			
		var start=infos["indexOfCursor"];
		var normal_order=true;
		//curr_text=infos["full_text"].split("\n");
		if(this.assocBracket[bracket])
			endBracket=this.assocBracket[bracket];
		else if(this.revertAssocBracket[bracket]){
			endBracket=this.revertAssocBracket[bracket];
			normal_order=false;
		}	
		var end=-1;
		var nbBracketOpen=0;
		
		for(var i=start; i<infos["full_text"].length && i>=0; ){
			if(infos["full_text"].charAt(i)==endBracket){				
				nbBracketOpen--;
				if(nbBracketOpen<=0){
					//i=infos["full_text"].length;
					end=i;
					break;
				}
			}else if(infos["full_text"].charAt(i)==bracket)
				nbBracketOpen++;
			if(normal_order)
				i++;
			else
				i--;
		}
		
		//end=infos["full_text"].indexOf("}", start);
		if(end==-1)
			return false;	
		var endLastLine=infos["full_text"].substr(0, end).lastIndexOf("\n");		
		var line= infos["full_text"].substr(0, endLastLine).split("\n").length + 1;			
		var curPos= end - endLastLine;
		
		this.displayToCursorPosition("end_bracket", line, curPos, infos["full_text"].substring(endLastLine +1, end));
		return true;
	};
	
	EditArea.prototype.displayToCursorPosition= function(id, start_line, cur_pos, lineContent, no_real_move){
	
		var elem=document.getElementById(id);
		var begin_line= lineContent.substr(0, cur_pos).replace(/((\n?)([^\t\n]*)\t)/gi, this.smartTab);
		var posLeft= 45 + begin_line.length* this.charWidth;
		var posTop=this.lineHeight * (start_line-1);
		if(isIE)
			posTop++;
		if(this.debug){
		/*	document.getElementById("line").value="line: "+start_line+ " carPos: "+cur_pos+" top: "+posTop+" left: "+posLeft+" \nlineStart: "+ lineContent;
			document.getElementById("line").value+="\n  area_scrollTop: "+document.getElementById("result").scrollTop+"  area_scrollLeft: "+document.getElementById("result").scrollLeft+""
													+"\n offset_w: "+document.getElementById("result").offsetWidth+" offset_h: "+document.getElementById("result").offsetHeight
													+"\n client_w: "+document.getElementById("result").clientWidth+" client_h: "+document.getElementById("result").clientHeight;
			
		*/}
		if(no_real_move!=true){	// when the cursor is hidden no need to move him
			document.getElementById(id).style.top=posTop+"px";
			document.getElementById(id).style.left=posLeft+"px";		
		}
		// usefull for smarter scroll
		document.getElementById(id).cursor_top=posTop;
		document.getElementById(id).cursor_left=posLeft;
		
	//	document.getElementById(id).style.marginLeft=posLeft+"px";
		
	};
	
	
	EditArea.prototype.area_select= function(start, length){
		this.textarea.focus();
		
		start= Math.max(0, Math.min(this.textarea.value.length, start));
		length= Math.max(0, Math.min(this.textarea.value.length-start, length));
		if(this.isOpera)	// Opera can't select 0 caracters...
			length= Math.max(1, length);
		if(this.isOpera && start > this.textarea.selectionEnd){	// Opera can't set selectionEnd before selectionStart
			this.textarea.selectionEnd = start + length;	
			this.textarea.selectionStart = start;				
		}else{
			this.textarea.selectionStart = start;
			this.textarea.selectionEnd = start+ length;		
		}
		//if( document.selection ){
		if(this.isIE){
			// select the text for IE (and take care of \r caracters)			
			nbLineStart= this.textarea.value.substr(0, this.textarea.selectionStart).split("\n").length - 1;
			nbLineEnd= this.textarea.value.substr(0, this.textarea.selectionEnd).split("\n").length - 1;
			var range = document.selection.createRange();
			range.moveToElementText( this.textarea );
			range.setEndPoint( 'EndToStart', range );
			
			range.moveStart('character', this.textarea.selectionStart - nbLineStart);
			range.moveEnd('character', this.textarea.selectionEnd - nbLineEnd - (this.textarea.selectionStart - nbLineStart)  );
			range.select();
		}	
	};
	
	
	EditArea.prototype.area_getSelection= function(){
		var text="";
		if( document.selection ){
			var range = document.selection.createRange();
			text=range.text;
		}else{
			text= this.textarea.value.substring(this.textarea.selectionStart, this.textarea.selectionEnd);
		}
		return text;			
	};
	
	