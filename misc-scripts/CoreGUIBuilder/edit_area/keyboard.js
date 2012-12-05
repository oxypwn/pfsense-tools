var clavier_cds=new Array(146);
	clavier_cds[8]="Retour arriere";
	clavier_cds[9]="Tabulation";
	clavier_cds[12]="Milieu (pave numerique)";
	clavier_cds[13]="Entrer";
	clavier_cds[16]="Shift";
	clavier_cds[17]="Ctrl";
	clavier_cds[18]="Alt";
	clavier_cds[19]="Pause";
	clavier_cds[20]="Verr Maj";
	clavier_cds[27]="Echap";
	clavier_cds[32]="Espace";
	clavier_cds[33]="Page precedente";
	clavier_cds[34]="Page suivante";
	clavier_cds[35]="Fin";
	clavier_cds[36]="Debut";
	clavier_cds[37]="Fleche gauche";
	clavier_cds[38]="Fleche haut";
	clavier_cds[39]="Fleche droite";
	clavier_cds[40]="Fleche bas";
	clavier_cds[44]="Impr ecran";
	clavier_cds[45]="Inser";
	clavier_cds[46]="Suppr";
	clavier_cds[91]="Menu Demarrer Windows / touche pomme Mac";
	clavier_cds[92]="Menu Demarrer Windows";
	clavier_cds[93]="Menu contextuel Windows";
	clavier_cds[112]="F1";
	clavier_cds[113]="F2";
	clavier_cds[114]="F3";
	clavier_cds[115]="F4";
	clavier_cds[116]="F5";
	clavier_cds[117]="F6";
	clavier_cds[118]="F7";
	clavier_cds[119]="F8";
	clavier_cds[120]="F9";
	clavier_cds[121]="F10";
	clavier_cds[122]="F11";
	clavier_cds[123]="F12";
	clavier_cds[144]="Verr Num";
	clavier_cds[145]="Arret defil";



	function keyDown(e){
		//alert("keydown");
		if(!e){	// if IE
			e=event;
		}
		var target_id=(e.target || e.srcElement).id;
		var use=false;
		/*if((e.keyCode<=40 && e.keyCode!=32) || (e.keyCode>90 && e.keyCode!=113))
			return true;*/
		if (clavier_cds[e.keyCode])
			letter=clavier_cds[e.keyCode];
		else
			letter=String.fromCharCode(e.keyCode);
		var low_letter= letter.toLowerCase();
				
		if(letter=="Tabulation" && target_id==editArea.id){			
			if(ShiftPressed(e))
				editArea.invertTabSelection();
			else
				editArea.tabSelection();
			
			use=true;
			if(editArea.isOpera)	// opera can't cancel keydown events...
				setTimeout("editArea.textarea.focus()", 1);
		}else if(letter=="Entrer" && target_id==editArea.id){
			//alert("enter");
			if(editArea.pressEnter())
				use=true;
		}else if(CtrlPressed(e)){
			//alert(letter+" | "+low_letter);
			switch(low_letter){
				case "f":				
					editArea.area_search();
					use=true;
					break;
				case "r":
					editArea.area_replace();
					use=true;
					break;
				case "q":
					editArea.close_all_inline_popup(e);
					use=true;
					break;
				case "h":
					if(editArea.isOpera){ // opera fire 2 times this event o_O
						date= new Date();
						if(!editArea.opera_last_fire_highlight)
							editArea.opera_last_fire_highlight=0;
						if(editArea.opera_last_fire_highlight < date.getTime() - 1000){							
							editArea.opera_last_fire_highlight= date.getTime();
							editArea.changeHighlight();							
						}				
					}else
						editArea.changeHighlight();
					use=true;
					break;
				case "g":
					setTimeout("editArea.go_to_line();", 5);	// the prompt stop the return false otherwise
					use=true;
					break;
				case "e":
					editArea.show_help();
					use=true;
					break;
				default:
					break;			
			}		
		}		
		
		if(use){
			//alert(letter);
			// in case of a control that sould'nt be used by IE but that is used => THROW a javascript error that will stop key action
			if(editArea.isIE)
				e.keyCode=0;
			/*if(e.preventDefault)
				e.preventDefault();*/
			return false;
		}
		if(editArea.next.length > 0){
			editArea.next= new Array();	// undo the ability to use "redo" button
			editArea.switchClassSticky(document.getElementById("redo_icon"), 'editAreaButtonDisabled', true);
		}
		//alert("Test: "+ letter + " ("+e.keyCode+") ALT: "+ AltPressed(e) + " CTRL "+ CtrlPressed(e) + " SHIFT "+ ShiftPressed(e));
		
		return true;
		
	}


	// return true if Alt key is pressed
	function AltPressed(e) {
	  if (window.event) {
	    return (window.event.altKey);
	  } else {
	  	if(e.modifiers)
	    	return (e.altKey || (e.modifiers % 2));
	    else
	    	return e.altKey;
	  }
	} 

	// return true if Ctrl key is pressed
	function CtrlPressed(e) {
	  if (window.event) {
	    return (window.event.ctrlKey);
	  } else {
	    return (e.ctrlKey || (e.modifiers==2) || (e.modifiers==3) || (e.modifiers>5));
	  }
	}

	// return true if Shift key is pressed
	function ShiftPressed(e) {
	  if (window.event) {
	    return (window.event.shiftKey);
	  } else {
	    return (e.shiftKey || (e.modifiers>3));
	  }
	} 

	