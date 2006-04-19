	EditArea.prototype.comment_or_quotes= function(v0, v1, v2, v3, v4,v5,v6,v7,v8,v9, v10){
		new_class="quote";
		if(v6 && v6 != undefined && v6!="")
			new_class="comment";
		return "[__"+ new_class +"__]"+v0+"[_END_]";

	};
	
/*	EditArea.prototype.htmlTag= function(v0, v1, v2, v3, v4,v5,v6,v7,v8,v9, v10){
		res="<span class=htmlTag>"+v2;
		alert("v2: "+v2+" v3: "+v3);
		tab=v3.split("=");
		attributes="";
		if(tab.length>1){
			attributes="<span class=attribute>"+tab[0]+"</span>=";
			for(i=1; i<tab.length-1; i++){
				cut=tab[i].lastIndexOf("&nbsp;");				
				attributes+="<span class=attributeVal>"+tab[i].substr(0,cut)+"</span>";
				attributes+="<span class=attribute>"+tab[i].substr(cut)+"</span>=";
			}
			attributes+="<span class=attributeVal>"+tab[tab.length-1]+"</span>";
		}		
		res+=attributes+v5+"</span>";
		return res;		
	};*/
	
	EditArea.prototype.highlightKeywords= function(){
		res= EditArea.prototype.highlightKeywords.arguments[1]+"[__keyword__]"+ EditArea.prototype.highlightKeywords.arguments[2]+"[_END_]";
		if(EditArea.prototype.highlightKeywords.arguments.length>5)
			res+=EditArea.prototype.highlightKeywords.arguments[ EditArea.prototype.highlightKeywords.arguments.length-3 ];
		/*tmp="";
		for(i=0; i<highlightKeywords.arguments.length; i++)
			tmp+=i+": "+highlightKeywords.arguments[i]+"\n";
		alert(tmp);*/
		return res;
	};

	EditArea.prototype.highlightFunctions= function(){
		res= EditArea.prototype.highlightFunctions.arguments[1]+"[__function__]" + EditArea.prototype.highlightFunctions.arguments[2]+"[_END_]";
		if(EditArea.prototype.highlightFunctions.arguments.length>5)
			res+= EditArea.prototype.highlightFunctions.arguments[ EditArea.prototype.highlightFunctions.arguments.length-3 ];
		/*tmp="";
		for(i=0; i<highlightFunctions.arguments.length; i++)
			tmp+=i+": "+highlightFunctions.arguments[i]+"\n";
		alert(tmp);*/
		return res;
	};
	
	//php_reg= new RegExp(/( |\n)((function)|(echo))( |\(|"|")/g);
	/*php_keywords["function"]=1;
	php_keywords["echo"]=1;*/
	
	EditArea.prototype.smartTab= function(){
		val="                   ";
		return EditArea.prototype.smartTab.arguments[2] + EditArea.prototype.smartTab.arguments[3] + val.substr(0, editArea.tab_nb_char - (EditArea.prototype.smartTab.arguments[3].length)%editArea.tab_nb_char);
	};
	
	
	EditArea.prototype.colorizeText= function(text){
		//text="<div id='result' class='area' style='position: relative; z-index: 4; height: 500px; overflow: scroll;border: solid black 1px;'> ";
	  	if(this.doSmartTab)
			text= text.replace(/((\n?)([^\t\n]*)\t)/gi, this.smartTab);		// slower than simple replace...
		else
			text= text.replace(/\t/gi,"        ");
		text= " "+text; // for easier regExp
		
		text= text.replace(/(("(\\"|[^"])*"?)|('(\\'|[^'])*'?)|(\/\*((\*[^\/])|[^\*])*(\*+\/)?))/gi, this.comment_or_quotes);
		text= text.replace(/(\/\/[^\n]*)(\n)?/g, "[__comment__]$1[_END_]$2");

		text= text.replace(/(<[a-z]+ [^>]*>)/gi, '[__htmlTag__]$1[_END_]');
		//text= text.replace(/(<[^?][^>]*>)/gi, '[__htmlTag__]$1[_END_]');
		if(this.phpLevel!="no"){
			text= text.replace(/((<\?((php)|=)?)|(\?>))/g, '[__phpTag__]$1[_END_]');
			text= text.replace(this.php_keywords_reg, this.highlightKeywords);
			text= text.replace(this.php_functions_reg, this.highlightFunctions);
		}		
		
		//text= text.replace(/( |\n)((function)|(echo))( |\(|"|")/g, '$1[__keywords__]$2[_END_]$5');
		//text= text.replace(php_reg, '$1[__function__]$2[_END_]');
	//	text= text.replace(php_keywords_reg, highlightKeywords);
	//	text= text.replace(php_functions_reg, highlightFunctions);
	//	text= text.replace(/([+-/*=<>%])/g, '[__operator__]$1[_END_]');
		var reg=new RegExp("([+-/*=<>%])", "g");
		text= text.replace(reg, '[__operator__]$1[_END_]');
		text= text.replace(/(\(|\)|\{|\})/g,'[__delimiter__]$1[_END_]');
		
		text= text.replace(/&/g,"&amp;");
		text= text.replace(/</g,"&lt;");
		text= text.replace(/>/g,"&gt;");		
		text= text.substr(1);	// remove the first space added
		text= text.replace(/ /g,"&nbsp;");
		text= text.replace(/(\[__([a-zA-Z]+)__\])/g,"<span class='$2'>");
		text= text.replace(/\[_END_\]/g,"</span>");
		
		//text= text.replace(//gi, "<span class='quote'>$1</span>");
		//alert("text: \n"+text);
		
		return text;
	};
