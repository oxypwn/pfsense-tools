		
	EditArea.prototype.changeHighlight= function(){
		//var icon= document.getElementById("highlight_icon");
		//if(document.getElementById("enableHighlight").checked)
		//if(getAttribute(icon, "class").indexOf("selected") != -1)
		if(this.do_highlight===true)
			this.disableHighlight();
		else
			this.enableHighlight();
	};
	
	EditArea.prototype.disableHighlight= function(displayOnly){		
		document.getElementById("selection_field").innerHTML="";
		var contain=document.getElementById("content_highlight");
		contain.style.visibility="hidden";
		contain.innerHTML="";
		var new_class=getAttribute(this.textarea,"class").replace(/hidden/,"");
		this.textarea.setAttribute("className", new_class);
		this.textarea.setAttribute("class", new_class);
		
		//var icon= document.getElementById("highlight_icon");
		//setAttribute(icon, "class", getAttribute(icon, "class").replace(/ selected/g, "") );
		//this.restoreClass(icon);
		//this.switchClass(icon,'editAreaButtonNormal');
		this.switchClassSticky(document.getElementById("highlight_icon"), 'editAreaButtonNormal', false);
		this.switchClassSticky(document.getElementById("reset_highlight_icon"), 'editAreaButtonDisabled', true);
		//area.onkeyup = formatArea;
		if(!displayOnly){
			this.do_highlight=false;
			this.formatArea();
			if(this.state=="loaded")
				this.textarea.focus();
		}
	};

	EditArea.prototype.enableHighlight= function(displayOnly){		
		
		var selec=document.getElementById("selection_field");
		selec.style.visibility="visible";		
		var contain=document.getElementById("content_highlight");
		contain.style.visibility="visible";
		var new_class=getAttribute(this.textarea,"class")+" hidden";
		this.textarea.setAttribute("className", new_class);
		this.textarea.setAttribute("class", new_class);
		
		//var icon= document.getElementById("highlight_icon");
		//setAttribute(icon, "class", getAttribute(icon, "class") + " selected");
		//this.switchClass(icon,'editAreaButtonSelected');
		this.switchClassSticky(document.getElementById("highlight_icon"), 'editAreaButtonSelected', false);
		this.switchClassSticky(document.getElementById("reset_highlight_icon"), 'editAreaButtonNormal', false);
		
		//area.onkeyup="";
		if(!displayOnly){
			this.do_highlight=true;
			this.reSync();
			if(this.state=="loaded")
				this.textarea.focus();
		}
	};
	
	
	EditArea.prototype.majArea= function(reload_all){
		if(!reload_all)
			reload_all=false;
		this.is_updating=true;
		var infos= this.getSelectionInfos();
		text= infos["full_text"];
		start_line_pb=-1;	// for optimisation process
		end_line_pb=-1;		// for optimisation process
		stay_begin_text="";	// for optimisation process
		stay_end_text="";	// for optimisation process
		update_text=text;
		
		date= new Date();
		tps1=date.getTime();
		date= new Date();
		tps_middle_opti=date.getTime();
			
		if(text==""){
			text="\n ";
	//		document.getElementById("src").value=" ";
		}

	//	document.getElementById("result").innerHTML="Bouh";
		//window.status="MAJ";
		
		/***  optmisation ***/
		if(reload_all){
			this.previous_content= new Array();
			this.previous_text="";
		}else{
			if(text== this.previous_text || this.last_highlight_line_selected== infos["line_start"]){
			//	document.getElementById("line").value="Save time - no update " + tps1;
			//	setTimeout("majArea();", 200);
				this.is_updating=false;
				return;
			}
			
	
			tab_text=text.split("\n");
			previous_tab_text= this.previous_text.split("\n");
			i=0;
			for(; i< tab_text.length && i<previous_tab_text.length && start_line_pb == -1; i++){
				if(previous_tab_text[i] != tab_text[i]){
					start_line_pb=i;
				}
			}
			//nb_line_pb= - start_line_pb ;
			nb_end_line_ok=0;
			if(start_line_pb==-1){
				start_line_pb=i;
			}else{
				j=previous_tab_text.length-1;
				i=tab_text.length-1;
				while(i>=0 && j>=0 && previous_tab_text[j] == tab_text[i]){
					i--;
					j--;
					nb_end_line_ok++;
				}
				//end_line_pb=tab_text.length - nb_end_line_ok + start_line_pb;
				//if(end_line_pb==-1)
				//	end_line_pb=j;
			}
			//+ tab_text.length - previous_tab_text.length;
			//nb_line_pb= tab_text.length- nb_end_line_ok - start_line_pb;
			//if(end_line_pb!=-1){
	
			date= new Date();
			tps_middle_opti=date.getTime();
	
			update_text="";

			//update_start=Math.max(0, start_line_pb);
			stop_modif=start_line_pb;
			if(previous_tab_text.length<=tab_text.length)
				stop_modif=tab_text.length - nb_end_line_ok - (previous_tab_text.length - (start_line_pb+1 + nb_end_line_ok));
			else if(previous_tab_text.length>tab_text.length)
				stop_modif=tab_text.length - nb_end_line_ok - (tab_text.length - (start_line_pb+1 + nb_end_line_ok));
			
			// new text
			for(i=start_line_pb; i< Math.min(tab_text.length, stop_modif);  i++){
				if(i>start_line_pb)
					update_text+="\n";
				update_text+=tab_text[i];
				//if(update_text.indexOf('"')!=-1 || update_text.indexOf("'")!=-1 || update_text.indexOf("/*")!=-1 || update_text.indexOf("*/")!=-1)
				//	majArea(true);
			}
			
			// begin text (don't change)
			for(i=0;i<start_line_pb; i++)
				stay_begin_text+= this.previous_content[i]+"\n";
			
			//end text (don't change)
			end_line_pb=this.previous_content.length - (tab_text.length - stop_modif);
			for(i=end_line_pb; i< this.previous_content.length; i++){
				//if(i<previous_content.length-1)
					//stay_end_text+="\n";
				stay_end_text+="\n"+ this.previous_content[i];

			}
			
			//}
			//nb_line_pb=tab_text.length-previous_tab_text.length;
			nb_line_pb= this.previous_content.length - nb_end_line_ok;
			if(this.debug)
				document.getElementById("line").value="previous_nb_line: "+this.previous_content.length+" nb_end_line_unchanged: "+nb_end_line_ok+" Line pb: "+ start_line_pb+ "fin pb: "+ end_line_pb+ " nbLine: "+nb_line_pb+"\n";
	
			/*** END optmisation ***/
		}
		date= new Date();
		tps_end_opti=date.getTime();

		this.previous_text=text;
		//text=document.getElementById("src").value;
		new_text=stay_begin_text +""+ this.colorizeText(update_text) +""+ stay_end_text;

		date= new Date();
		tps2=date.getTime();
		
		tab_text=new_text.split("\n");

		td1="";
		var hightlight_content=tab_text.join("<br>");
		
		date= new Date();
		inner1=date.getTime();

		this.previous_content= tab_text;
		
		date= new Date();
		inner2=date.getTime();
		document.getElementById("content_highlight").innerHTML= hightlight_content;
		date= new Date();
		tps3=date.getTime();
		tot1=tps_end_opti-tps1;
		tot_middle=tps_end_opti- tps_middle_opti;
		tot2=tps2-tps_end_opti;
		tps_split=inner1-tps2;
		tps_td1=inner2-inner1;
		tps_td2=tps3-inner2;
		if(this.debug){
			//lineNumber=tab_text.length;
			//document.getElementById("line").value+=" \nNB char: "+document.getElementById("src").value.length+" Nb line: "+ lineNumber;
			document.getElementById("line").value+=" \nTps optimisation "+tot1+" (second part: "+tot_middle+") | tps reg exp: "+tot2+" | tps split: "+tps_split;
			document.getElementById("line").value+=" | tps update highlight content: "+tps_td2+"\n"+ update_text;
		}
		this.last_highlight_line_selected= infos["line_start"];
		
	//	borderTop=document.getElementById("src").style.borderTopWidth.replace(/px/,"");
	//	borderLeft=document.getElementById("src").style.borderLeftWidth.replace(/px/,"");
	//	document.getElementById("src").style.top=-document.getElementById("content_highlight").offsetHeight-borderTop;
	//	document.getElementById("src").style.left=-document.getElementById("content_highlight").offsetLeft-borderLeft;
		//formatArea(tab_text);
		this.formatArea();
		/*this.textarea.width=Math.max(document.getElementById("content_highlight").offsetWidth, document.getElementById("result").offsetWidth)+"px";
		new_height=Math.max(document.getElementById("content_highlight").offsetHeight+15, document.getElementById("result").offsetHeight-15);
		this.textarea.style.height=new_height+"px";
		document.getElementById("line_number").style.height=new_height+"px";
		document.getElementById("container").style.height=new_height+"px";*/
		//document.getElementById("result").style.height=(document.getElementById("content_highlight").offsetHeight+25)+"px";
		//h=Math.min(document.getElementById("result").offsetHeight, document.getElementById("content_highlight").offsetHeight+25);
		this.is_updating=false;
		//setTimeout("majArea();", 10);
	};
	
	EditArea.prototype.reSync= function(){
		this.previous_content= new Array();
		this.previous_text="";
		this.textarea.scrollLeft=0;
		this.textarea.scrollTop=0;
		this.startMajArea(true);
	}
	
	