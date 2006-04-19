
	function EditArea(){
		this.error= false;	// to know if load is interrrupt
		this.loadedFiles = new Array();
		this.baseURL="";
		this.file_name="edit_area.js";
		this.suffix="";
		this.scriptsToLoad= new Array("area_template", "manage_area", "resize_area", "edit_area_functions", "elements_functions", "reg_syntax", "regexp", "highlight", "keyboard", "search_replace");
		this.cssToLoad= new Array("edit_area.css");
		this.inlinePopup= new Array({popup_id: "area_search_replace", icon_id: "search_icon"},
									{popup_id: "edit_area_help", icon_id: "help_icon"});
		
		this.previous_content= new Array();
		this.previous_text="";
		this.last_highlight_line_selected= -1;
		this.tab_text_operator= new Array("=","+","-","/","*",";","->");
		this.is_updating=false;
		this.is_waiting_for_update=false;
		this.last_line_selected= -1;		
		this.last_selection_range= -1;
		this.last_selection=new Array();		
		this.textareaFocused= false;
		//this.loaded= false;
		this.doSmartTab=true;		// must use it
		this.assocBracket=new Array();
		this.revertAssocBracket= new Array();		
		this.textarea="";	
		this.previous= new Array();
		this.next= new Array();
		this.state="declare";
		// font datas
		this.lineHeight= 16;
		this.charWidth=8;
		this.default_font_family= "monospace";
		this.default_font_size= 10;
		this.tab_nb_char= 8;	//nb of white spaces corresponding to a tabulation
		this.is_tabbing= false;
		
		// navigator identification
		ua= navigator.userAgent;
		this.isIE = (navigator.appName == "Microsoft Internet Explorer");
		this.isNS = ua.indexOf('Netscape/') != -1;
		if(this.isNS){	// work only on netescape > 8 with render mode IE
			this.NSvers= ua.substr(ua.indexOf('Netscape/')+9);
			if(this.NSvers<8 || !this.isIE)
				this.error=true;			
		}
		this.isOpera = (ua.indexOf('Opera') != -1);
		if(this.isOpera==true){	
			this.OperaVers= ua.substr(ua.indexOf('Opera ')+6);
			if(this.OperaVers<9)
					this.error=true;
			this.isIE=false;			
		}
		this.isGecko = (ua.indexOf('Gecko') != -1);
		this.isFirefox = (ua.indexOf('Firefox') != -1);
		this.isSafari = (ua.indexOf('Safari') != -1);
		this.back_compat_mode=(document.compatMode=="BackCompat");
		//alert(this.back_compat_mode);
		//alert(navigator.appName+"\n"+ua+"\n: IE: "+this.isIE+" opera: "+this.isOpera+" v:"+this.OperaVers+"\nFirefox: "+this.isFirefox+"\nGecko: "+this.isGecko+"\nSafari: "+this.isSafari);
		//alert(ua+"\n"+this.isGecko);
		// resize var
		this.isResizing=false;
		this.resize_start_mouse_x=0;
		this.resize_start_mouse_y=0;
		this.resize_start_width=0;
		this.resize_start_height=0;
		this.resize_new_width=0;
		this.resize_new_height=0;
		this.resize_start_inner_height=0;	
		this.min_width= 375;
		this.min_height= 50;
		this.resize_mouse_x=0;
		this.resize_mouse_y=0;
		// available options
		this.do_highlight=false;
		this.phpLevel="simple";
		this.debug=false; 
		this.id="";
		this.font_family= "monospace";
		this.font_size= 10;
		this.line_selection= true;
		this.max_undo= 15;
		this.save_callback="";
		this.load_callback="";
		this.toolbar= "new_document, |, search, go_to_line, |, undo, redo, |, select_font, change_line_selection, highlight, reset_highlight, |, help";
		this.allow_resize= "both"; // "no", "x", "y", "both"
		this.allow_toogle=true;
		this.language="en";
		
		this.setBaseURL();
		//load needed files
		if(this.file_name!="edit_area_gzip.php"){	// don't load files if they were loaded in php		
			for(var script in this.scriptsToLoad){
				this.loadScript(this.baseURL + this.scriptsToLoad[script]+ this.suffix +".js");
			}
		}
		
		for(var css in this.cssToLoad){
			this.loadCSS(this.baseURL + this.cssToLoad[css]);
		}
		
	};
	
	EditArea.prototype.initArea= function(settings){
		//alert("init");		
		//alert(document.compatMode);
		if(this.error)
			return;
		// init settings
		this.settings = settings;
		for(var i in this.settings){
			if( this.settings[i]===false ||  this.settings[i]===true)
				eval("this."+ i +"="+ this.settings[i]+";");
			else
				eval("this."+ i +"=\""+ this.settings[i]+"\";");
		}
		if(this.begin_toolbar)
			this.toolbar= this.begin_toolbar +","+ this.toolbar;
		if(this.end_toolbar)
			this.toolbar= this.toolbar +","+ this.end_toolbar;
		this.tab_toolbar= this.toolbar.replace(/ /g,"").split(",");
		
		//alert(this.tab_toolbar.length+"\n"+this.tab_toolbar.join("\n =>"));
		if(this.isIE || this.isNS){	// IE work well only with those settings
			this.font_familly= this.default_font_family;
			this.font_size= this.default_font_size;		
		}
		if(this.isOpera){
			this.tab_nb_char=6;
		}
		
		// bracket selection init 
		this.assocBracket["("]=")";
		this.assocBracket["{"]="}";
		this.assocBracket["["]="]";		
		for(var index in this.assocBracket){
			this.revertAssocBracket[this.assocBracket[index]]=index;
		}		
		// laod language file
		this.loadScript(this.baseURL + "langs/"+ this.language + ".js");
			
		this.addEvent(window, "load", EditArea.prototype.startArea);
		this.state="init";
	};
	
	EditArea.prototype.first_display= function(){
		//reg exp initialisation
		this.initRegExp();
		if(editArea.phpLevel=="middle"){
			editArea.php_functions_reg= new RegExp(editArea.getRegExp(editArea.php_functions_middle),"g");
		}else if(editArea.phpLevel=="simple"){
			editArea.php_functions_reg= new RegExp(editArea.getRegExp(editArea.php_functions_simple),"g");
		}	
		
		// get toolbar content
		var html_toolbar_content="";
		for(var i=0; i<this.tab_toolbar.length; i++){
		//	alert(this.tab_toolbar[i]+"\n"+ this.get_control_html(this.tab_toolbar[i]));
			html_toolbar_content+= this.get_control_html(this.tab_toolbar[i]);
		}
		
		// create template
		this.template= this.get_template().replace("[__TOOLBAR__]",html_toolbar_content);
		var div_line_number="";
		for(i=1; i<10000; i++)
			div_line_number+=i+"<br>";
		this.template= this.template.replace("[__LINE_NUMBER__]", div_line_number);
		
		if(this.debug)
			this.template="<textarea id='line' style='z-index: 20; width: 100%; height: 120px;overflow: auto; border: solid black 1px;'></textarea><br>"+ this.template;
		if(this.allow_toogle==true)
			this.template+="<div id='edit_area_toogle'><input id='edit_area_toogle_checkbox' type='checkbox' onclick='editArea.toogle();' accesskey='e' checked /><label for='edit_area_toogle_checkbox'>{$toogle}</label></div>";	
		
			
		// fill template with good language sentences
		this.template=this.template.replace(/\{\$([^\}]+)\}/gm, this.traduc_template);
		
		// insert template in the document after the textarea
		var father= this.textarea.parentNode;
		var content= document.createElement("span");
		var next= this.textarea.nextSibling;
		if(next==null)
			father.appendChild(content);
		else
			father.insertBefore(content, next) ;
		content.innerHTML=this.template;
	

		
	

	/*	
		content=document.getElementById("edit_area_template");
		alert("nb child"+count_children(content, 5)+"\n direct: "+ count_children(content, 0));
		var test= count_child_type(content, 2);
		var res="";
		for(var i in test){
			res+=i+": "+test[i]+"\n";
		}
		alert(res);
		//content.normalize();
		alert("nb child"+count_children(content, 4)+"\n direct: "+ count_children(content, 0));
		
		// add toggle button
		if(this.allow_toogle==true){			
			var next=this.textarea.nextSibling;
			if(next!= null)
				father.insertBefore(document.getElementById("edit_area_toogle"), next) ;
			else
				father.appendChild(document.getElementById("edit_area_toogle"));
		}*/
		
		// init to good size
		this.toolbars_height= this.get_all_toolbar_height();
		var edit_area= document.getElementById("edit_area");					
		var width= (this.textarea.style.width || getAttribute(this.textarea, "width"));
		var height= (this.textarea.style.height || getAttribute(this.textarea, "height"));						
		
		edit_area.style.width= width;
		edit_area.style.height= height;
		
		// check min size
		if(edit_area.offsetWidth < this.min_width)
			edit_area.style.width=this.min_width+"px";
		if(edit_area.offsetHeight < this.min_height)
			edit_area.style.height=this.min_height+"px";
		
		// get effective size
		width=edit_area.offsetWidth;
		height= edit_area.offsetHeight;
		if(this.isIE)	// with height=100% for result we must withdraw again toolbar height
			height-= editArea.toolbars_height;
	//	if(!this.isFirefox)
			height-=4;
		
						
		var result_height= height - this.toolbars_height;				
		document.getElementById("edit_area_template").style.visibility= "visible";			
		if(this.isIE){ 
			document.getElementById("result").style.width=(edit_area.offsetWidth -2 )+"px";
			document.getElementById("result").style.height= (result_height+2)+"px";
		}else{
			/*if(this.back_compat_mode)
				result_height+=2;
			else
				result_height-=9;*/
			document.getElementById("result").style.height= result_height+"px";
		}
		
				
	};
	
	EditArea.prototype.startArea= function(){
		editArea.textarea= document.getElementById(editArea.id);
		if(editArea.textarea==null){
			document.getElementById("edit_area_template").style.display="none";
			return;
		}
		
		if(editArea.state=="init"){
			editArea.first_display();
		}			
		//alert("start");
	
		var template_area= document.getElementById("editArea_textarea");

		// insert template datas in the place of the textarea
		template_area.value=editArea.textarea.value;	
		// invert the two textarea		
		setAttribute(template_area, "name", getAttribute(editArea.textarea, "name") );
		setAttribute(template_area, "id", getAttribute(editArea.textarea, "id") );
		//setAttribute(editArea.textarea, "name",  getAttribute(editArea.textarea, "name")+"_replaced");
		editArea.textarea.removeAttribute("name") ;
		setAttribute(editArea.textarea, "id",  getAttribute(editArea.textarea, "id")+"_replaced");
				
		if(editArea.state!="init"){			
			document.getElementById("edit_area_template").style.display= "block";
		}
		
		// hide old textarea
		editArea.textarea.style.display="none";
		editArea.textarea= template_area;
		if(document.getElementById("redo_icon") != null)
			editArea.switchClassSticky(document.getElementById("redo_icon"), 'editAreaButtonDisabled', true);
		
		// get font size datas		
		editArea.set_font(editArea.font_family, editArea.font_size);
		
		// highlight
		if(editArea.do_highlight===true){
			editArea.disableHighlight();	// init with correct values			
			editArea.enableHighlight();
		}else
			editArea.disableHighlight();
		
		// line selection init
		editArea.change_line_selection_mode(editArea.line_selection);
		editArea.textarea.focus();

		
		// init key events
		editArea.textarea.onkeydown= keyDown;
		if(editArea.isIE || editArea.isFirefox)
			editArea.textarea.onkeydown= keyDown;
		else
			editArea.textarea.onkeypress= keyDown;
		for(var i in editArea.inlinePopup){
			if(editArea.isIE || editArea.isFirefox)
				document.getElementById(editArea.inlinePopup[i]["popup_id"]).onkeydown= keyDown;
			else
				document.getElementById(editArea.inlinePopup[i]["popup_id"]).onkeypress= keyDown;
			//document.getElementById(editArea.inlinePopup[i]["popup_id"]).onkeydown= keyDown;
		}
		
		// allow resize area
		if(editArea.allow_resize!="no")
			document.getElementById("resize_area").onmousedown= editArea.startResizeArea;
		
		if(!this.isIE && !this.isOpera)	// force a refresh of the result area
			document.getElementById("result").style.right="0";
		
		editArea.state="loaded";		
		
		//start checkup routine
		editArea.check_undo();
		editArea.startMajArea(true);
		editArea.checkLineSelection();
		editArea.formatArea();		
	};
	
	
	
	EditArea.prototype.setBaseURL= function(){
		//this.baseURL="";
		if (!this.baseURL) {
			var elements = document.getElementsByTagName('script');
	
			for (var i=0; i<elements.length; i++) {
				if (elements[i].src && (elements[i].src.indexOf("edit_area.js") != -1  || elements[i].src.indexOf("edit_area_src.js") != -1 || elements[i].src.indexOf("edit_area_gzip.php") != -1 )) {
					var src = elements[i].src;
					src = src.substring(0, src.lastIndexOf('/'));
					this.baseURL = src;
					this.file_name= elements[i].src.substr(elements[i].src.lastIndexOf("/")+1);
					break;
				}
			}
		}
		
		var documentBasePath = document.location.href;
		if (documentBasePath.indexOf('?') != -1)
			documentBasePath = documentBasePath.substring(0, documentBasePath.indexOf('?'));
		var documentURL = documentBasePath;
		documentBasePath = documentBasePath.substring(0, documentBasePath.lastIndexOf('/'));
	
		// If not HTTP absolute
		if (this.baseURL.indexOf('://') == -1 && this.baseURL.charAt(0) != '/') {
			// If site absolute
			this.baseURL = documentBasePath + "/" + this.baseURL;
		}
		this.baseURL+="/";	
	};

	EditArea.prototype.loadScript= function(url){
		for (var i=0; i<this.loadedFiles.length; i++) {
			if (this.loadedFiles[i] == url)
				return;
		}	
	//	alert("laod: "+url);
		document.write('<sc'+'ript language="javascript" type="text/javascript" src="' + url + '"></script>');
		this.loadedFiles[this.loadedFiles.length] = url;
	};

	EditArea.prototype.loadCSS= function(url) {
		for (var i=0; i<this.loadedFiles.length; i++) {
			if (this.loadedFiles[i] == url)
				return;
		}	
		document.write('<link href="' + url + '" rel="stylesheet" type="text/css" />');
		this.loadedFiles[this.loadedFiles.length] = url;
	};
	
	EditArea.prototype.execCommand= function(cmd){
		switch(cmd){
			case "save":
				if(this.save_callback!="")
					eval(this.save_callback+"(editArea.textarea.value);");
				break;
			case "load":
				if(this.load_callback!="")
					eval(this.load_callback+"(editArea.textarea);");
				break;			
			default:
				eval("editArea."+cmd+"();");	
		}
	};
	
	
	/*
	EditArea.prototype.importCSS = function(doc, css_file) {
		if (css_file == '')
			return;	
		if (typeof(doc.createStyleSheet) == "undefined") {
			var elm = doc.createElement("link");
	
			elm.rel = "stylesheet";
			elm.href = css_file;
	
			if ((headArr = doc.getElementsByTagName("head")) != null && headArr.length > 0)
				headArr[0].appendChild(elm);
		} else
			var styleSheet = doc.createStyleSheet(css_file);
	};*/
	
	
	EditArea.prototype.startMajArea= function(reload_all, waitingUpdate){
		if(this.do_highlight==false){
			
		}else if(this.is_waiting_for_update==false || waitingUpdate==true){
			// don't enqueue call to majArea is area is currently upadating
			if(!reload_all)
				reload_all=false;
			if(this.is_updating==false){
				//disableHighlight(true);
				this.is_waiting_for_update=false;
				this.majArea(reload_all);
				//enableHighlight(true);
			}else{
				this.is_waiting_for_update=true;
				setTimeout("editArea.startMajArea("+reload_all+", true);", 50);
			}			
		}
		return true;
	};


	EditArea.prototype.addEvent = function(obj, name, handler) {
		if (this.isIE) {
			obj.attachEvent("on" + name, handler);
		} else{
			obj.addEventListener(name, handler, false);
		}
	};
	
	EditArea.prototype.toogle= function(toogle_to){
		if(this.state=="loaded" || toogle_to=="off"){
			this.toogle_off();
		}else{
			this.toogle_on();
		}
		return false;
	};
	
	EditArea.prototype.toogle_off= function(){
		if(!this.state=="loaded")
			return;
		// give back good name and id to the textarea	
		var previous_area= document.getElementById(this.id+"_replaced");
		setAttribute(previous_area, "name", getAttribute(editArea.textarea, "name") );
		setAttribute(previous_area, "id", this.id);
		
	//	setAttribute(editArea.textarea, "name",  "");
		editArea.textarea.removeAttribute('name');
		setAttribute(editArea.textarea, "id",  "editArea_textarea");
		// init to good size
		var edit_area= document.getElementById("edit_area");
	
		previous_area.style.width= edit_area.offsetWidth+"px";
		previous_area.style.height= edit_area.offsetHeight+"px";
		previous_area.value= this.textarea.value;
		document.getElementById("edit_area_toogle_checkbox").checked=false;
		// disaply the previous textarea
		document.getElementById("edit_area_template").style.display= "none";
		previous_area.style.display= "block";
		//alert("h: "+previous_area.offsetHeight+" w: "+previous_area.offsetWidth+"\n"+getAttribute(previous_area, "style"))
		this.state="hidden";
	};		
	
	EditArea.prototype.toogle_on= function(){
		document.getElementById("edit_area_toogle_checkbox").checked=true;
		this.startArea();
	};
	
	EditArea.prototype.traduc_template= function(){
		return editArea.getLang(EditArea.prototype.traduc_template.arguments[1]);
	};
	
	EditArea.prototype.getLang= function(val){
		
		for(var i in EditArea_lang){
			if(i == val)
				return EditArea_lang[i];
		}
		return "_"+val;
	};
		
	// Global instances
	var editArea = new EditArea();
	var isIE= (navigator.appName == "Microsoft Internet Explorer");
