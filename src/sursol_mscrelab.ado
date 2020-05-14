capture program drop sursol_mscrelab

program sursol_mscrelab 
syntax anything using/ , [sheet(string)] [catvalue(string)] [CATVARiable(string)]  [NOskip] 


qui {


*CHECKS OF INPUT
*********************************************************************************
// NUMBER OF VARIABLES SPECIFIED
	loc cnt: word count `anything'
	if `cnt'<1 {
	noi dis as error"Too few variables specified"
	ex 102
	}
	if `cnt'>1 {
	noi dis as error"Too many variables specified"
	ex 103
	}


//USING FILE EXISTS? 
capt confirm file "`file'"

if !_rc {
	File specified in {help using: using} not found
}

	
*DEFAULT SETTINGS
*********************************************************************************
if "`sheet'"=="" loc sheet "Translations"
if "`catvalue'"=="" loc catvalue "Index"
if "`catvariable'"=="" loc catvariable "Variable"



*********************************************************************************
*START THE PROGRAM
*********************************************************************************

*1) GET A LIST OF MSC VARIABLES IN CURRENT DATASET
*********************************************************************************

		
	//FULL LIST OF ALL NON-STRING  VARIABLES WITH "__". INDICATES MSC IN SURVEY SOLUTIONS
	capt ds *__*, not(type string)
	
	//LOCAL varlist_msc WILL CONTAIN ALL VARIABLES FOR WHICH IT CAN BE ASSUMED THAT THEY ARE TRUE MSC
	loc varlist_msc="`r(varlist)'"
	
	//IF THERE IS ANY VARIABLE WITH "__" 
	if length("`r(varlist)'")>0 {
		
			//GO THROUGH ALL THE VARS AND CHECK IF WE NEED TO WORK WITH IT 
			foreach var of var `r(varlist)' {
				
				//CHECK IF THE VARIABLE LABEL IS LONGER THAN 80. IF NOT WE DON'T NEED TO WORK ON IT
				loc `var'lbl:  variable label  `var'
				if length("``var'lbl'")<80 {
						loc varlist_msc: list varlist_msc - var
						continue
							}
				
				//CHECK IF IT IS JUST 1 & 0. IF NOT MOST LIKELY NOT A MSC
				sum `var', meanonly
					//IF NO OBSERVATION: 
					if `r(N)'==0 {
						noi dis "`var' has no observations. Will still be included in search in translation file"
					}
					
					//IF NOT REMOVE IT FROM LIST OF MSC 
					else if  `r(N)'>0 {
						if (`r(min)'<0 |`r(max)'>1) & "`noskip'"=="" {
						noi dis as result "`var' has values different to 0 and 1. Will be skipped " 
						loc varlist_msc: list varlist_msc - var
						continue
						}
						else if (`r(min)'<0 |`r(max)'>1) & "`noskip'"!="" {
						noi dis as result "`var' has values different to 0 and 1. Will be included in search in translation file" 
						}
					}
			}
	
			
	}
	
	//IF THERE ARE ANY MSC VARIABLES LEFT THAT NEED TO BE RELABELED	
	if length("`varlist_msc'")>0 {

	*2) LOOKUP THE VALUE LABELS IN TRANSLATION FILE 
	*********************************************************************************
	preserve

	//IMPORT EXCEL
	import excel "`using'", sheet("`sheet'") firstrow allstring clear
	
	//CHECK IF SPECIFIED VARIABLE EXISTS
	capt confirm var `anything' 
	if !_rc==0 {
		noi dis as error "Variable {it:`anything'} does not exist in specified translation file."
		ex 198
	}
	
	capt confirm var `catvalue' 
	if !_rc==0 {
		noi dis as error "Variable {it:`catvalue'} does not exist in specified translation file."
		noi dis as error "See command option:{help sursol_mscrelab##sursol_mscrelab_catvalue: catvalue(string)}"
		ex 198
	}

	capt confirm var `catvariable' 
	if !_rc==0 {
		noi dis as error "Variable {it:`catvariable'} does not exist in specified translation file."
		noi dis as error "See command option:{help sursol_mscrelab##sursol_mscrelab_catvariable: catvariable(string)}"
		ex 198
	}
	
	//ENSURE THAT NEGATIVE VALUES ARE CHANGED TO "nXXX"
	replace `catvalue'=subinstr(`catvalue',"-","n",1)
	
	//THE VARIABLE AS IT WOULD BE IN EXPORT FILE
	gen export_var= `catvariable' + "__"+ `catvalue'
	
	//KEEP ONLY RELEVANT INFO
	keep `anything'  export_var
	
	//HELP VAR TO RETRIEVE THE VALUE LABEL FROM  INDEX
	gen long obsn = _n 
	levelsof export_var, loc(list_vars_translation)
	
				g keep=0
				foreach var of loc varlist_msc {
					
					local  pos_`var' : list posof "`var'" in list_vars_translation
					if `pos_`var''==0 {
						noi dis as error "Variable {it:`var'} not found in translation file."
						loc varlist_msc: list varlist_msc - var
						continue
					}
					
				//RETRIEVE THE VALUE LABEL 
				su obsn if export_var == "`var'", meanonly 
				local `var'vlbl = Originaltext[r(min)] 
				//CLEAN IT UP A BIT 
				local `var'vlbl= ustrfix(ustrtrim("``var'vlbl'" ))
				}
				
restore
				
	*3) GO BACK TO THE MASTER FILE 
	*********************************************************************************


				foreach var of loc varlist_msc {
					
					//CLEAN UP THE OLD VARIABLE LABEL A BIT
					local `var'lbl=subinstr(ustrfix(ustrtrim("``var'lbl''")),"  "," ",.)
					
					//IF THE OPTION LABEL IS SHORTER THEN 80 THEN FINAL LABEL:  THEN JUST PLACE THE OPTION LABEL 
					
					if length("``var'vlbl'")<80 loc `var'nlb=substr("``var'lbl''",1,81-length("``var'vlbl'")-2) + ":``var'vlbl'"
					//ELSE WE JUST TAKE THE OPTION LABEL
					else if length("``var'vlbl'")>=80 loc `var'nlb="``var'vlbl'"
					lab var `var' "``var'nlb'"

			
				}
	} // END OF if length("`varlist_msc'")>0 CONDITION 


	*RESULTS
	*********************************************************************************
	if length("`varlist_msc'")>0 {
		noi dis as result _n "The following variable have been relabeled:"
		noi dis "`varlist_msc'"
	}
	else if length("`varlist_msc'")==0 noi dis as result _n "No MSC Variables have been relabeled" 

	
} //QUIET BRACKET
end

