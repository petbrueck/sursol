*! version 20.06.1  June 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org

capture program drop sursol_getcomm

program sursol_getcomm 
syntax  [using/], QXVAR(string)  [DIRectory(string)]  [ID(varlist  min=1 max =1)] [STATHistory] /// 
[ROSTERID(varlist  min=1 max =3)] [clear] [ONLYVar(string)]

if length("`directory'")==0 local dir `c(pwd)'
else if length("`directory'")>0 local dir `directory'


qui {

if "`using'"=="" & "`clear'"!="" {
noi dis as error "Option clear can not be specified if no file is loaded through {help using:using}."
ex 198
}


gettoken vars 0: 0,parse(",")

//Load commfile if specified
if "`using'"!="" use "`using'",  `clear'
loc commfile=subinstr("`using'", ".dta", "", .)


// Check existence of directory 
mata : st_numscalar("OK", direxists("`dir'"))
if scalar(OK)==0 {
noi dis as error _n "Attention. Folder specified in {help sursol_getcomm##directory:directory(string)} not found."
ex 601
}


// Check ID question			
	if length("`id'")==0 {
	capt confirm var interview__id
	if !_rc==0 {
	noi dis as error "Attention. interview__id not found. Specify interview GUID in option {help sursol_getcomm##id:id(varlist)}"
	ex 111
	}
	loc id="interview__id"
	}

	else if length("`id'")>0 {
	capt confirm var `id'
	if !_rc==0 {
	noi dis as error "Attention. `id' not found. Correctly specify interview GUID in option {help sursol_getcomm##id:id(varlist)}"
	ex 111
	}
	}	

if `c(N)'==0 & "`using'"!=""  noi dis as result _n "No comments to be found in `using'." 
if `c(N)'==0 & "`using'"==""  noi dis as result _n "No comments to be found in currently loaded dataset." 
//GET THE FILE STRUCTURE
capt g roster="" //Given old comment files the roster variable might not have been created.
replace roster="`qxvar'" if roster=="" | roster=="Unknown"
tempfile comm_fullmaster
save `comm_fullmaster'
//IF "onlyvar" SPECIFIED
if "`onlyvar'"!="" {
	*GET LIST OF VARS THAT ACTUALLY EXIST
	levelsof variable, loc(vars)
	foreach v1 of loc vars {
		capt g `v1'=. 
	}
		loc keepvarlist ""
		foreach onlyv in `onlyvar' {
			capt ds `onlyv'
			if _rc==111 {
				noi dis as error "Comments left at variable(s) `onlyv' not found"
				continue
			}
			loc keepvarlist "`keepvarlist' `r(varlist)'"			
		}
	foreach v2 of loc vars {
		capt drop `v2'
	}
	*GET RID OF ALL OTHER VARS
	if length("`keepvarlist'")>0 {
	g keepvar=.
	foreach v in `keepvarlist'  {
		replace keepvar=1 if variable=="`v'"
	}
	keep if keepvar==1
	noi dis as result _n "Comments will be merged to dataset for variables: `keepvarlist'"
	noi dis as result "" 
	}
	if length("`keepvarlist'")==0 noi dis as result "No comments have been merged."	
}
if ((length("`keepvarlist'")==0 & "`onlyvar'"!="") |  "`onlyvar'"=="") use `comm_fullmaster', clear

//START OF getcoom LOOP
if ((length("`keepvarlist'")>0 & "`onlyvar'"!="") |  "`onlyvar'"=="") {

levelsof roster, loc(files)
//CHECK IF FILES EXIST
foreach file of loc files  {
capt confirm file "`dir'//`file'.dta"
	if !_rc==0 {
		if length("`directory'")==0  {
		noi dis as error "`file'.dta not found in current directory (`dir')"
		noi dis as error "Check current working directory, specify option {help sursol_getcomm##directory:directory(string)} or see {help sursol_getcomm##attention1:Attention 1}."
		ex 601
		}
		else if length("`directory'")>0  {
		noi dis as error "`file'.dta not found in directory specified in {help sursol_getcomm##directory:directory(string)}"
		ex 601

		}
	}
}

//FILE LOOP
	tempfile process_master
	save `process_master'

foreach file of loc files  {

//GET THE ROSTER ID'S
use "`dir'//`file'.dta" , clear 

if "`file'"!="`qxvar'" {
ds *__id
noi dis as text "Roster ID's in `file'.dta to be used: " as result  "`r(varlist)'"
loc rosterids `r(varlist)'
}


if "`file'"=="`qxvar'" {
loc rosterids "`id'"
noi display as result "`id' will be used to identify variables at the interview level (`qxvar'.dta)"
}

use `process_master', clear
keep if roster=="`file'"

if "`file'"=="`qxvar'" drop if strpos(variable,"@@")>0

tempfile masterroster
save `masterroster'


	levelsof variable, loc(vars)

		foreach currvar of loc vars {
			use `masterroster', clear

			keep if variable=="`currvar'"
			
			//Rename the correct ID's
			local ignoreme "`id'"
			local renameid: list rosterids-ignoreme
			loc renamecount=1
			foreach rename of loc renameid {
			rename id`renamecount' `rename'
			loc ++renamecount
			}


			sort `id'  order 

			levelsof role, loc(rolelevels)
			g role_str=""
			foreach lev of loc rolelevels {
			loc lbl: label (role) `lev'
			replace role_str= "`lbl'" if role==`lev'
			}

			drop role 
			rename role_str role
			rename comment cmt_sursol //to reduce likelihood that there is a comment to a SurSol variable containing *comment*


			collapse (firstnm) interview__key order role variable, by(`rosterids' cmt_sursol) 
			sort `rosterids' order 
			by `rosterids' : gen help=_n
			
			replace role="Int." if role=="Interviewer"
			replace role="Sup." if role=="Supervisor"
			replace role="HQ" if role=="Headquarter"
			replace role="Admin" if role=="Administrator"
			replace role="API" if role=="Api User"

			reshape wide cmt_sursol order role variable, i(`rosterids') j(help)
					
			
		
			g `currvar'_comm=""
				foreach var of var cmt_sursol* {
				loc comment_id=substr("`var'",11,.)
				replace `currvar'_comm=`currvar'_comm + "`comment_id') " +role`comment_id' +": "  + `var' + ". " if `var'!="" 
				}
			
 

			lab var `currvar'_comm "Comment(s) left at question: `currvar'"

			//DOUBLE CHECK IF VARIABLE NAME NOT TOO LONG. LAZY CHECK.
			if  length(	"`currvar'f")>=32 {
				noi dis as error _n "Name of variable '`currvar'' is too long to process."
				noi dis as error "Can you rename it before running the command both in interview__comments and '`file'.dta'?"
				ex 198
			}
			tempfile `currvar'f
			save ``currvar'f'

			//MERGE TO THE ROSTER FILE
			use "`dir'//`file'.dta" , clear 
			//GET THE ORDERING RIGHT
			capt confirm var `currvar'
			if !_rc==0 {
			ds `currvar'__*
			loc countvar: word count `r(varlist)'
			loc lastvar: word `countvar'  of `r(varlist)'
			}
			else loc lastvar "`currvar'"
			capt confirm var `currvar'_comm
			if !_rc {
			noi dis as error "Attention, `currvar'_comm already exists in `file'.dta. Old variable will be replaced"
			continue
			}

			merge 1:1 `rosterids' using ``currvar'f', nogen keep (1 3) keepusing (`currvar'_comm) replace update
			order `currvar'_comm , a(`lastvar')
			sleep 30

			save "`dir'//`file'.dta", replace				
		}
			
						

}
use `comm_fullmaster'
} 
//END OF REGULAR getcomm SYNTAX

//OPTION INTcomments

if length("`stathistory'")>0 {
noi display as result _n "Interview status history comments will be merged to the `qxvar'.dta file"
			use `comm_fullmaster', clear
			 keep if strpos(variable,"@@")>0 & comment!=""
			

			if `c(N)'>0 {
				levelsof variable, loc(statuses)
				tempfile masterintfile
				save `masterintfile'
				
					foreach currvar of loc statuses {
					loc cleanstatus=substr("`currvar'",3,.)
					
					use `masterintfile', clear
					keep if variable=="`currvar'"

					collapse (firstnm) interview__key, by(`id' comment variable)

					bys `id' : gen help=_n
					reshape wide comment, i(`id') j(help)
					if "`cleanstatus '"=="ApprovedByHeadquarter" loc newvar "approve_hq_comm"
					if "`cleanstatus '"=="ApprovedBySupervisor" loc newvar "approve_sup_comm"
					if "`cleanstatus '"=="RejectedByHeadquarter" loc newvar "reject_hq_comm"
					if "`cleanstatus '"=="RejectedBySupervisor" loc newvar "reject_sup_comm"
					if "`cleanstatus '"=="UnapprovedByHeadquarter" loc newvar "unapprove_hq_comm"
					if "`cleanstatus '"=="Completed" loc newvar "completed_comm"
					g `newvar'=""


						foreach var of var comment* {
						loc varid=substr("`var'",8,.)
						replace `newvar'=`newvar' + "`varid'. `cleanstatus': " + `var' + ". " if `var'!="" 
						}
					lab var `newvar' "Comment left at action: `cleanstatus'"
					tempfile finalcomment
					save `finalcomment' 
					use "`dir'//`qxvar'.dta"
					merge 1:1 `id' using `finalcomment', nogen assert(1 3) keepusing(`newvar') replace update
					order `newvar', last
					save "`dir'//`qxvar'.dta" , replace
					}

		}

use "`dir'//`qxvar'.dta", clear
}
}

end

