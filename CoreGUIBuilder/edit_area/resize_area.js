	
	EditArea.prototype.startResizeArea= function(e){
		editArea.before_resize_infos= editArea.getSelectionInfos();
		
		document.onmouseup= editArea.endResizeArea;
		document.onmousemove= editArea.resizeArea;
		editArea.isResizing=true;
		editArea.resize_start_mouse_x= getMouseX(e);
		editArea.resize_start_mouse_y= getMouseY(e);
		editArea.resize_start_width=document.getElementById("edit_area").offsetWidth;
		editArea.resize_start_height=document.getElementById("edit_area").offsetHeight;
		//editArea.resize_start_inner_height= document.getElementById("result").offsetHeight +2;
		
		if(!editArea.isIE){	// remove border width
			editArea.resize_start_height-=2;
			editArea.resize_start_width-=2;	
		}else if(!editArea.back_compat_mode){
			editArea.resize_start_height-=2;
			editArea.resize_start_width-=2;
		}
				
		editArea.resize_new_width= editArea.resize_start_width;
		editArea.resize_new_height= editArea.resize_start_height;
		//alert(resize_start_width);
		document.getElementById("edit_area").style.display="none";
		document.getElementById("cursor_pos").style.display="none";
		document.getElementById("end_bracket").style.display="none";
		
		document.getElementById("resize_hidden_field").style.width= editArea.resize_start_width+"px";
		document.getElementById("resize_hidden_field").style.height= editArea.resize_start_height+"px";
		document.getElementById("resize_hidden_field").style.display="block";
		setTimeout("editArea.scrollBody()", 50);
		return false;
	};
	
	EditArea.prototype.endResizeArea= function(e){
		editArea.isResizing=false;
		document.onmouseup="";
		document.onmousemove="";		
		document.getElementById("resize_hidden_field").style.display="none";
		
		document.getElementById("edit_area").style.display="block";
		editArea.resize_new_width= Math.max(editArea.min_width, editArea.resize_new_width);
		
		var w= editArea.resize_new_width;
		if(editArea.isIE && editArea.back_compat_mode)
			w=w-2;
			
		document.getElementById("result").style.width= w+"px";
		document.getElementById("edit_area").style.width= w+"px";
		resize_new_height= Math.max(editArea.min_height, editArea.resize_new_height);
		
	//	var h =editArea.resize_new_height  - (editArea.resize_start_height - editArea.resize_start_inner_height) ;
		var h =editArea.resize_new_height  - editArea.toolbars_height -2;
		/*if(editArea.isGecko)
			editArea.resize_new_height-=4;*/
	/*	if(editArea.isFirefox)
			h+=4;*/
			
		document.getElementById("result").style.height= h+"px";
		document.getElementById("edit_area").style.height= editArea.resize_new_height+"px";
			
		document.getElementById("cursor_pos").style.display="block";
		document.getElementById("end_bracket").style.display="block";
		editArea.textarea.focus();
		editArea.area_select( editArea.before_resize_infos["indexOfCursor"], 0);
		editArea.before_resize_infos["indexOfCursor"]= new Array();
		return false;
	};
	
	// can take an event or direct mouse coordinates
	EditArea.prototype.resizeArea= function(e, new_x, new_y){
		if(new_x && new_y){
			editArea.resize_mouse_x= new_x;
			editArea.resize_mouse_y= new_y;
		}else{
			editArea.resize_mouse_x= getMouseX(e);
			editArea.resize_mouse_y= getMouseY(e);
		}	
		if(editArea.allow_resize=="both" || editArea.allow_resize=="x"){
			editArea.resize_new_width= Math.max(editArea.min_width, editArea.resize_start_width + editArea.resize_mouse_x - editArea.resize_start_mouse_x);
			document.getElementById("resize_hidden_field").style.width= editArea.resize_new_width+"px";
		}
		if(editArea.allow_resize=="both" || editArea.allow_resize=="y"){
			editArea.resize_new_height= Math.max(editArea.min_height, editArea.resize_start_height + editArea.resize_mouse_y - editArea.resize_start_mouse_y);
			document.getElementById("resize_hidden_field").style.height= editArea.resize_new_height+"px";
		}
		return false;
	};
	
	EditArea.prototype.scrollBody= function(){	// don't work for IE with back_compat_mode == false (if there is a doctype)
		if(!editArea.isResizing)
			return;
		var scroll_top=0;
		var scroll_left=0;
		var new_x=editArea.resize_mouse_x;
		var new_y=editArea.resize_mouse_y;
		var diff_top= 500;
		if(this.isIE){
			if(this.back_compat_mode){
				scroll_top= document.body.scrollTop;
				scroll_left= document.body.scrollLeft;
				
			}else{
				scroll_top= document.documentElement.scrollTop;
				scroll_left= document.documentElement.scrollLeft;
			}
			diff_top= document.body.clientHeight + scroll_top - editArea.resize_mouse_y;
		}else{
			scroll_top=window.pageYOffset;
			scroll_left=window.pageXOffset;
			diff_top= window.innerHeight + scroll_top - editArea.resize_mouse_y;
		}
		
		
		if(diff_top < 25){
			var add_top=Math.ceil((25- diff_top)/2);
			if(this.back_compat_mode)
				document.body.scrollTop=scroll_top+ add_top;
			else
				document.documentElement.scrollTop=scroll_top+ add_top;
			new_y=editArea.resize_mouse_y+ add_top;
		}
		
		var diff_left= document.body.clientWidth + scroll_left - editArea.resize_mouse_x;
		if(diff_left < 25){
			var add_left=Math.ceil((25- diff_left)/2);
			if(this.back_compat_mode)
				document.body.scrollLeft=scroll_left+ add_left;
			else
				document.documentElement.scrollLeft=scroll_left+ add_left;
			new_x=editArea.resize_mouse_x+ add_left;
		}
		
		/*window.status="x: "+editArea.resize_mouse_x+" y: "+editArea.resize_mouse_y+" b_h: "+document.body.clientHeight+" s_t: "+scroll_top+ " rest: "+(document.body.clientHeight + scroll_top -editArea.resize_mouse_y)+""
					 +" ("+window.innerHeight +"+"+ scroll_top +"-"+editArea.resize_mouse_y+")"+""+ " rest left: "+(document.body.clientWidth + scroll_left -editArea.resize_mouse_x)+""
					 +" ("+document.body.clientWidth +"+"+ scroll_left +"-"+editArea.resize_mouse_x+")"+""
					 +" d_h: "+document.body.scrollHeight+ " diff_top: "+diff_top+""
					 +" new_y: "+new_y+" prev_y "+editArea.resize_mouse_y+ "scrool_h: "+document.body.scrollHeight;
		*/
		if(new_x!=editArea.resize_mouse_x || new_y!=editArea.resize_mouse_y){
			editArea.resizeArea("", new_x, new_y);			
		}
		
		setTimeout("editArea.scrollBody()", 30);
	};

	
	