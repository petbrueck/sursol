*! version 20.06.1  June 2020
*! Author: Andreas Kutka, andreas.kutka@gmail.com & Peter Brueckmann, p.brueckmann@mailbox.org

capture program drop sursol_append

program sursol_append 
syntax anything,  DIRectory(string) [QXVAR(string)] [EXport(string)]  [COpy(string)] [NOACtions] [NODIAGnostics] [SERver(string)] [NOSkip] [sortdesc]

local currdir `c(pwd)'
loc qxname=lower("`1'")
loc notworked "" 



qui { 

mata : st_numscalar("OK", direxists("`directory'"))
if scalar(OK)==0 {
noi dis as error _n "Attention. Directory: ""`directory'"" not found."
noi dis as error  "Please correctly specify {help sursol_append##sursol_append_directory:directory(string)}"
ex 601
}


if length("`export'")>0{
	mata : st_numscalar("OK", direxists("`export'"))
	if scalar(OK)==0 {
	noi di as error "Attention, directory specified in {help sursol_append##sursol_append_export:export(string)} does not exist."
	ex 601
	}
}

foreach package in distinct {
capture which `package'
if _rc==111 {
noi dis as error "Attention. This command makes use of the stata package 'distinct'"
noi dis as error "The package will now be installed."
noi ssc install distinct
}
}


if length("`export'")==0 loc export="`directory'"


if length("`qxvar'")==0 loc master="`1'"
else if length("`qxvar'")>0 loc master="`qxvar'"

//IDENTIFY FOLDER STRUCTURE
	local folderstructure: dir "`directory'" dirs "`1'*", respectcase 
	local folderstructure : list sort folderstructure
	local length : word count `folderstructure'

	if  regexm(`"`folderstructure'"',"STATA")==1 & regexm(`"`folderstructure'"',"Tabular")==1  {
	noi di as error _n "Attention, both STATA and Tabular Export files identified in `directory' for files `master'" 
	noi di as error  "This can not be handled. Please remove and use only one export type file.'" 
	ex 198
	}

	// IDENTIFY NOW IF STATA OR TABULAR 
	if  regexm(`"`folderstructure'"',"STATA")==1 loc export_type="STATA"
	if  regexm(`"`folderstructure'"',"Tabular")==1 loc export_type="Tabular"

	
	if `length'==0 {
	noi di as error _n "Attention, no folder found named:  ""`1'"" 
	noi di as error "Check questionnaire name specified or directory!" 
	ex 601
	}


	//SORT NUMERICALLY ASCENDING
	loc init_vnum=subinstr(subinstr(`"`folderstructure'"',"`1'_","",.), char(34),  "", .)

	*NEED TO GET THE ACTUAL VERSIONS - PAINFUL WITH STATA
	loc vnumtructure=""
	foreach object of loc init_vnum {
	*HOPING IT IS JUST BY "_" OR WHITESPACE
		if ustrregexm("`object'","^\d+_")==1 	loc object=substr("`object'",1,strpos("`object'","_")-1)
		if ustrregexm("`object'","^\d+ ")==1 	loc object=substr("`object'",1,strpos("`object'"," ")-1)
		loc vnumtructure "`vnumtructure' `object'"
	}

	capt numlist `"`vnumtructure'"', integer sort
	if !_rc==0 {
	noi di as error _n "Attention, it seems that you specified the wrong {help sursol_append:{it:folder_uniqueid}}" 
	noi di as error "Folders have been identified but it was not possible to identify the version number(s)." 
	noi di as error "Make sure to only specify the name of the folders and no version numbers or underscore signs." 
	ex 601
	}
	loc sortstructure ""
	if "`sortdesc'"=="" {
	foreach version in  `r(numlist)' {
		*For each version have to find again the folder 
		foreach object of loc folderstructure {
			if  ustrregexm("`object'","`version'")==1  loc takeobj= "`object'"
			else if ustrregexm("`object'","`version'")==0 continue
		}
		loc sortstructure `"`sortstructure' `takeobj' "'		
	}
	}

	//DESCENDING ORDER
	if "`sortdesc'"!="" {
	loc length_nums: word count `r(numlist)'
	loc sortstructure ""
	forvalue folder=`length_nums'(-1)1 {
	loc ver: word `folder' of `r(numlist)'
		*For each version have to find again the folder 
		foreach object of loc folderstructure {
			if  ustrregexm("`object'","`ver'")==1  loc takeobj= "`object'"
			else if ustrregexm("`object'","`ver'")==0 continue
		}
		loc sortstructure `"`sortstructure' `takeobj' "'		
	}
	}



noi dis _n ""
	if length("`nodiagnostics'")==0 | length("`noactions'")==0 | length("`copy'")>0 {
	foreach folder of loc sortstructure  {

		capt confirm file "`directory'/`folder'/`master'.dta"
			if _rc!=0 {

				if length("`qxvar'")==0 {
				noi dis as error "No Questionnaire Level file found named `master'.dta in `folder'"
				noi dis as error  "Specify option {help sursol_append##sursol_append_qxvar:qxvar(string)}"
				}
				else if length("`qxvar'")>0 {
				noi dis as error "No Questionnaire Level file found named `master'.dta in folder `folder'."
				noi dis as error "Check name specified in option {help sursol_append##sursol_append_qxvar:qxvar(string)}"
				}
			ex 601
			}
	
	} 
	} 

	//ERASE PREVIOUS DATA 
	foreach folder of loc sortstructure {
	local filestructure: dir "`directory'/`folder'" file "*.dta", respectcase 
	local filestructure : list sort filestructure 
		foreach file of loc filestructure {
		capt erase "`export'/`file'"
		}
	}


	loc i=0
	foreach folder of loc sortstructure {
	loc version= subinstr("`folder'", "`1'_","",.) 
	local filestructure: dir "`directory'/`folder'" file "*.dta", respectcase 
	local filestructure : list sort filestructure 
	if length(`"`filestructure'"')==0 {
	noi di as error _n "Attention, no files found in folder: `folder'" 
	local notworked `" `notworked'  "`folder'" " " "'
	continue
	}
	noi di as text  "Version `version' of `1' found. Will be appended..."

	foreach file of loc filestructure {
	sleep 50
	use "`directory'/`folder'/`file'", clear
	loc filepure=subinstr("`file'",".dta","",.)

	//STORE THE QXNAME IN SHORT VERSION TO AVOID LENGTH>=32 
	loc filepure=substr("`filepure'",1,25)

	if  `c(N)'==0 & length("`noskip'")==0 {
	noi di as result "`file' from Version `version' contains no observation, will be skipped"
	continue
	}

	if regexm("`file'","`master'.dta")==1 {
	loc data_version = "`version'"
	if ustrregexm("`version'","^\d+_")==1 	loc data_version=substr("`data_version'",1,strpos("`version'","_")-1)
	if ustrregexm("`data_version'","^\d+ ")==1 	loc data_version=substr("`data_version'",1,strpos("`data_version'"," ")-1)
	*local data_version = substr("`data_version'",1,strpos("`version'","_")-1)
	gen version="`data_version'"
	label var version "Version of Survey Solutions questionnaire"
	order version
	local file="`master'.dta" 

	}
	

	
	capture confirm file "`export'/`file'"
	if _rc!=0 {
		save "`export'/`file'"
	}

	else if _rc==0 & `c(N)'>0 {
					qui ds, has(type numeric)
					local masternum `r(varlist)'
					local tostringvars: list masternum & ustr`filepure'
					foreach var of local tostringvars {
						noi di as err  "`var' from Version `version' converted to string"
						tostring `var', replace u force
						replace `var'="" if `var'=="." 
					}
					
					qui ds, has(type string)
					local masterstr `r(varlist)'
					local tostringvars: list masterstr & unum`filepure'
					if length(`"`tostringvars'"')>0{
					preserve
						use "`export'//`file'", clear
						foreach var of local tostringvars {
							noi di as err "`var' is string in Version `version'. `var' in master file converted to string" 
							tostring `var', replace u force
							replace `var'="" if `var'=="." 
						}
						save "`export'//`file'", replace
					restore
					}
					append using "`export'//`file'"
					sleep 20
					save  "`export'//`file'", replace
	}
	
	qui ds, has(type string) 
	local ustr`filepure'  `r(varlist)'
	qui ds, has(type numeric)
	local unum`filepure' `r(varlist)'
	
	}
	loc ++i
	}

capt confirm file "`export'/`master'.dta"
if length("`server'")>0 & !_rc {
	use "`export'/`master'.dta", clear 
	gen intlink ="`server'/Interview/Review/"+interview__id
	label var intlink "link to access interview file on server"
	gen inthist ="`server'/Interview/InterviewHistory/"+substr(interview__id,1,8)+"-"+substr(interview__id,9,4)+"-"+substr(interview__id,13,4)+"-"+substr(interview__id,17,4)+"-"+substr(interview__id,21,12)
	label var inthist "link to access interview history on server"
	format intlink inthist %-5s
	save  "`export'/`master'.dta", replace 
}




local worked: list sortstructure- notworked

	if `i'==1 & length("`notworked'")==0 {
		noi di as result _n(2) "Only 1 version found and successfully appended: "
		foreach folder of loc worked {
		noi di as result "`folder'"
}

	} 
	else if `i'>1 {
noi di as text _n "The following data has been successfully appended: "
foreach folder of loc worked {
noi di as result "`folder'"
	}
}

if length("`notworked'")>0 {
noi di as error _n "The following versions were found but no .dta files in folder: "
foreach fail of loc notworked {
noi di as error "`fail'"
}
}


//MERGING SPECIFIED VARIABLES
capt confirm file "`export'/`master'.dta"
if length("`copy'")>0 & !_rc {
	no di as text _n "The following variables are merged to all datasets: `copy'"
	local files: dir "`export'" file "*.dta", respectcase 
	loc not "f" "`master'.dta" "interview__comments.dta" "assignment__actions.dta" "interview__diagnostics.dta" "interview__actions.dta" "interview__errors.dta" "paradata_all.dta" "paradata_overview.dta"
	local mergefiles: list files-not
	use "`export'/`master'.dta", clear 
	
	loc break=0
	foreach x of loc copy {
	capt confirm v `x'
	if _rc!=0 {
	noi dis as error "Attention. Variable `x' specified in copy does not exist in `master'.dta"
	loc ++break
	continue, break
		} 
	}

       if `break'>0 exit 111

	foreach file of loc mergefiles { 
		use "`export'/`file'", clear
		if `c(N)'==0 continue
		qui distinct interview__id
		if `r(N)'==`r(ndistinct)' {
		merge 1:1 interview__id using "`export'/`master'.dta", nogen keepusing(`copy') keep(1 3)
		} 
		else {
		merge m:1 interview__id using "`export'/`master'.dta", nogen keepusing(`copy') keep(1 3)
		}
		order `copy', after(interview__id)
		sleep 50
		save  "`export'/`file'", replace 
		}
	}

//MERGE INTERVIEW DIAGNOSTICS IF SPECIFIED
capt confirm file "`export'/`master'.dta"
if length("`noactions'")==0 & !_rc {
		no di as text _n "Interview action statistics are merged to `master'.dta"
		use "`export'/interview__actions.dta", clear

		if `c(N)'>0 {
		levelsof action, loc(levels)
		foreach lev of loc levels {
		loc lbl:  label (action) `lev'
		loc lbl_short=substr(lower("`lbl'"),1,4)
		if `lev'==1 loc lbl_short "assigINT"
		if `lev'==5 loc lbl_short "apprSUP"
		if `lev'==6 loc lbl_short "apprHQ"
		if `lev'==7 loc lbl_short "rejeSUP"
		if `lev'==8 loc lbl_short "rejeHQ"
		if `lev'==19 loc lbl_short "swCAWI"
		if `lev'==20 loc lbl_short "swCAPI"

		bys interview__id: egen byte n_`lbl_short'=total(action==`lev')
		lab var n_`lbl_short' "Number of times  interview: `lbl'"
		}
	

		g enum_strt=originator if action==12
		label var enum_strt "enumerator: interview starting"
		
		sort interview__id action date time
		by interview__id action: gen  enum_fcmp=originator if _n==1 & action==3
		gsort interview__id - enum_fcmp
		by interview__id: replace enum_fcmp = enum_fcmp[_n-1] if enum_fcmp=="" & _n !=1
		label var enum_fcmp "enumerator: first interview completion"
		
		sort interview__id action date time
		by interview__id action: gen enum_lacmp=originator if _n==_N & action==3
		gsort interview__id - enum_lacmp
		by interview__id: replace enum_lacmp = enum_lacmp[_n-1] if enum_lacmp=="" & _n !=1
		label var enum_lacmp "enumerator: last interview completion"
		
		sort interview__id date time
		by interview__id: gen  sprvsr=responsible__name if action==0
		gsort interview__id - sprvsr
		by interview__id: replace sprvsr = sprvsr[_n-1] if _n !=1
		label var sprvsr "supervisor: responsible at first assignment"	

		* last action 
		sort interview__id date time
		by interview__id: gen lstact=action if _n==_N
		gsort interview__id -lstact
		by interview__id: replace lstact = lstact[_n-1] if missing(lstact) & _n !=1	
		label var lstact "last action"
		tostring lstact, replace force
	
		levelsof lstact, loc(levels)
		foreach lev of loc levels {
		loc lbl:  label (action) `lev'
		replace lstact="`lbl'" if lstact=="`lev'"
		}
		
		gen ap=(inlist(action,5,6))
		by interview__id:egen byte approved=total(ap)
		drop ap
		label var approved "# of times interview approved"

		* make Stata date 
		replace date=date + " " + time
		gen double dateTime=Clock(date,"YMD hms")
		format dateTime %tC 
		
		* interviewing times
		sort interview__id role dateTime 
		by interview__id role: gen sT=dateTime if _n==1 & role==1
		
		by interview__id: egen double tmstrt=max(sT)
		drop sT
		label var tmstrt "datetime: interview starting"

		sort interview__id action dateTime 
		by interview__id action: gen eT=dateTime if _n==1  & action==3
		by interview__id: egen double tmfcmp=max(eT)
		drop eT	
		label var tmfcmp "datetime: first interview completion"
		
		by interview__id action: gen sT=dateTime if _n==_N & action==3
		by interview__id: egen double tmlcmp=max(sT)
		drop sT	
		label var tmlcmp "datetime: last interview completion"

		sort interview__id dateTime 
		bys interview__id: gen eW=dateTime if _n==_N 
		by interview__id: egen double tmlstact=max(eW)
		drop eW	
		label var tmlstact "datetime: last  action"



		format tmstrt tmfcmp tmlcmp tmlstact  %tC 


	 foreach v of var n_* enum_* sprvsr lstact approved tmstrt tmfcmp tmlcmp tmlstact    {
		 local l`v' : variable label `v'
		 if `"`l`v''"' == "" {
			local l`v' "`v'"
			}
		 }
		 
	collapse (firstnm)  n_* enum_* sprvsr lstact approved tmstrt tmfcmp tmlcmp tmlstact   , by(interview__id)


		foreach v of var  n_* enum_* sprvsr lstact approved  tmstrt tmfcmp tmlcmp tmlstact    {
		 label var `v' "`l`v''"
		  } 


tempfile actioncollaps
save `actioncollaps'
use "`export'/`master'.dta", clear

merge 1:1 interview__id using `actioncollaps', nogen
sleep 30
save "`export'/`master'.dta", replace

capt confirm file "`export'/interview__comments.dta"
	if _rc==0 {
		use "`export'/interview__comments.dta", clear
		if `c(N)'>0 {
			gen double tmestp=clock(date+" "+time,"MDYhms")
			format tmestp %tc
			save "`export'/interview__comments.dta", replace

		gen byte n_cmt_int=1 if role==1
		gen byte n_cmt_sup=1 if role==2
		gen byte n_cmt_hq=1 if role==3
		collapse (sum) n_cmt*, by(interview__id)
		label var n_cmt_int "number of comments set by interviewer"
		label var  n_cmt_sup "number of comments set by supervisor"
		label var  n_cmt_hq  "number of comments set by headquarters"
		recode n_cmt* (.=0)
		tempfile commentcollaps
		save `commentcollaps' 
		use "`export'/`master'.dta", clear
		merge 1:1 interview__id using `commentcollaps' , nogen
		save "`export'/`master'.dta", replace
			}
		}
	}
}

//INTERVIEW DIAGNOSTICS
capt confirm file "`export'/`master'.dta"
if length("`nodiagnostics'")==0 & !_rc {
noi di as text "Interview diagnostics are merged to `master'.dta"

	//IDENTIFY VARIABLES IN DIAGNOSTICS. DIFFER BY SURVEY SOLUTIONS VERSION. 
	use  "`export'/interview__diagnostics.dta", clear
	qui ds
	loc lastvar: word `c(k)' of `r(varlist)'

use "`export'/`master'.dta", clear
merge 1:1 interview__id using "`export'/interview__diagnostics.dta", nogen keepusing (interview__status-`lastvar')
lab var interview__duration "Active time it took to complete the interview according to Survey Solutions"
sleep 30
save "`export'/`master'.dta", replace
	}

cd "`currdir'"		



} 

end



