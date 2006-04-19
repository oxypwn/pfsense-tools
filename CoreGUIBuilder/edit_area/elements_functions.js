	// need to redifine this functiondue to IE problem
	function getAttribute( elm, aname ) {
		try{
			var avalue = elm.getAttribute( aname );
		}catch(exept){
		
		}
		if ( ! avalue ) {
			for ( var i = 0; i < elm.attributes.length; i ++ ) {
				var taName = elm.attributes [i] .name.toLowerCase();
				if ( taName == aname ) {
					avalue = elm.attributes [i] .value;
					return avalue;
				}
			}
		}
		return avalue;
	}
	
	// need to redifine this functiondue to IE problem
	function setAttribute( elm, attr, val ) {
		if(attr=="class"){
			elm.setAttribute("className", val);
			elm.setAttribute("class", val);
		}else{
			elm.setAttribute(attr, val);
		}
	}
	
	/* return a child element
		elem: element we are searching in
		elem_type: type of the eleemnt we are searching (DIV, A, etc...)
		elem_attribute: attribute of the searched element that must match
		elem_attribute_match: value that elem_attribute must match
		option: "all" if must return an array of all children, otherwise return the first match element
		depth: depth of search (-1 or no set => unlimited)
	*/
	function getChildren(elem, elem_type, elem_attribute, elem_attribute_match, option, depth){
		
		if(!option)
			var option="single";
		if(depth ==null)
			var depth=-1;
	//	alert("depth:"+depth);
		if(elem){
			var children= elem.childNodes;
			var result=null;
			var results= new Array();
		//	alert("level: "+level+" elem: "+elem+" nb_child: "+children.length);
			for (var x=0;x<children.length;x++) {
		//		alert("level: "+level+" "+x+"/"+children.length+": elem: "+children[x]+" nb_child: "+children.length);
				strTagName = new String(children[x].tagName);
				children_class="?";
				if(strTagName!= "undefined"){
					children_class= getAttribute(children[x],elem_attribute);
				//	alert("tag: "+strTagName+" chidl: "+children[x]);
					if(strTagName.toLowerCase()==elem_type.toLowerCase() && (elem_attribute=="" ||children_class==elem_attribute_match)){
				//		alert("level: "+level+" "+"found "+children[x]);
						if(option=="all"){
							results.push(children[x]);
						}else{
							return children[x];
						}
					}
					if(option=="all" && depth!=0){
						//alert("search Child For: "+strTagName+ " class: "+children_class+" depth: "+depth);
						result=getChildren(children[x], elem_type, elem_attribute, elem_attribute_match, option, depth-1);
						if(option=="all"){
							if(result.length>0){
							//	alert("found2 "+result);							
								results= results.concat(result);
							}
						}else if(result!=null){												
							return result;
						}
					}
				}
				//alert("not match tag: "+strTagName+ " class: "+children_class);
			}
			if(option=="all")
				return results;
		}
	//	alert("level: "+level+" "+" not found in : "+elem+" nb_child: "+children.length);					
		return null;
	}	
	
	function isChildOf(elem, parent){
		if(elem){
			if(elem==parent)
				return true;
			while(elem.parentNode != 'undefined'){
				return isChildOf(elem.parentNode, parent);
			}
		}
		return false;
	}
	
	function getMouseX(e){
		/*if(document.all)
			return event.x + document.body.scrollLeft;
		else
			return e.pageX;*/
		return (navigator.appName=="Netscape") ? e.pageX : event.x + document.body.scrollLeft;
	}
	
	function getMouseY(e){
		/*if(document.all)
			return event.y + document.body.scrollTop;
		else
			return e.pageY;*/
		return (navigator.appName=="Netscape") ? e.pageY : event.y + document.body.scrollTop;
	}
	
	function calculeOffsetLeft(r){
	  return calculeOffset(r,"offsetLeft")
	}
	
	function calculeOffsetTop(r){
	  return calculeOffset(r,"offsetTop")
	}
	
	function calculeOffset(element,attr){
	  var offset=0;
	  while(element){
		offset+=element[attr];
		element=element.offsetParent
	  }
	  return offset;
	}
	
	
	var move_current_element="";
	function start_move_element(e, id){
		var elem_id=(e.target || e.srcElement).id;
		if(id)
			elem_id=id;		
		//alert(e.toString()+ (e.target || e.srcElement).id);
		move_current_element= document.getElementById(elem_id);
		move_current_element.onmousemove= move_element;
		move_current_element.onmouseup= end_move_element;
		
		mouse_x= getMouseX(e);
		mouse_y= getMouseY(e);
		move_current_element.start_pos_x = mouse_x - (move_current_element.style.left.replace("px","") || calculeOffsetLeft(move_current_element));
		move_current_element.start_pos_y = mouse_y - (move_current_element.style.top.replace("px","") || calculeOffsetTop(move_current_element));
		//alert("startmove" +move_current_element.style.top.replace("px",""));
	}
	
	function end_move_element(e){
		move_current_element.onmousemove= "";
		move_current_element.onmouseup= "";
		move_current_element="";
	}
	
	function move_element(e){
		var mouse_x=getMouseX(e);
		var mouse_y=getMouseY(e);
		var new_top= mouse_y - move_current_element.start_pos_y;
		var new_left= mouse_x - move_current_element.start_pos_x;
		move_current_element.style.top= new_top+"px";
		move_current_element.style.left= new_left+"px";		
		return false;
	}
	
	
	/* for debug purpose*/
	
	function count_children(elem, level){
		//elem.normalize();
		children= elem.childNodes;
		if(!level)
			level=0;
		if(level==0)		
			return children.length;
		else{
			var count= children.length;
			for(i in children)
				count+= count_children(elem, level-1);
			return count;
		}
	}
	
	function count_child_type(elem, level){

		var new_node= elem.cloneNode(false);
		var types= new Array();
		children= elem.childNodes;
	//	var error="\nerror for "+elem;
		if(children){
			error+="\n\t nb child before:"+ elem.childNodes.length;
			for(i=0; i< children.length; i++){
				if(children[i].nodeType && children[i].nodeType>=1 && children[i].nodeType <= 12 ){
					//if(children[i].nodeType>0)
					
					if(types[children[i].nodeType])
						types[children[i].nodeType]++;	
					else
						types[children[i].nodeType]=1;
					//new_node.appendChild(children[i]);
					// clone the "hiddenContent" element and assign it to the "newContent" variable
					newContent = children[i].cloneNode(true);
					// clear the contents of your destination element.
					//so_clearInnerHTML(document.getElementById("mContainer"));
					// append the cloned element to the destination element
					new_node.appendChild(newContent);
				}else{
					error+="\nbad children: ";
					new_node.removeChild(children[i]);			
				}
				
					//elem.removeChild(children[i]);
			}
			error+= "  nb child after :"+ new_node.childNodes.length+ " level: "+level;
			if(!level)
				level=0;
			if(level!=0){
				
				for(var i=0; i<new_node.childNodes.length; i++){
					count_child_type(new_node.childNodes[i], level-1);
				//	if(new_node.childNodes[i].nodeType>0){
					//	types= types.concat(count_child_type(new_node.childNodes[i], level-1));
							
				//	}
				}
			}			
		}
	//	elem= new_node;
		document.getElementById("src").value+=error;
		
		
		// insert the cloned object into the DOM before the original one
		elem.parentNode.insertBefore(new_node,elem);
		// remove the original object
		//elem.parentNode.removeChild(elem);
		
		//new_node.parentNode= elem.parentNode;
		//elem.parentNode.replaceChild(new_node, elem);
		//alert(error);
		return types;
	}
	
	
	/*isMSIE = (navigator.appName == "Microsoft Internet Explorer");
		isMSIE5 = this.isMSIE && (ua.indexOf('MSIE 5') != -1);
		this.isMSIE5_0 = this.isMSIE && (ua.indexOf('MSIE 5.0') != -1);
		this.isGecko = ua.indexOf('Gecko') != -1;
		this.isSafari = ua.indexOf('Safari') != -1;
		this.isOpera = ua.indexOf('Opera') != -1;
	//	this.isMac = ua.indexOf('Mac') != -1;
		this.isNS7 = ua.indexOf('Netscape/7') != -1;
		this.isNS71 = ua.indexOf('Netscape/7.1') != -1;
		
		var date= new Date();
		var dend= date.getTime();
		if(dend-d1 >100)
			document.getElementById("line").value="end "+ (dend - d1)+ " middle a "+ (dmiddle- d1)+ " middle b "+ (dend-dmiddle);
		
		
		
		
		*/