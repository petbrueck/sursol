capture program drop sursol_getcomm

program sursol_getcomm 
syntax  [using/], [DIRectory(string)]  QXVAR(string) [ID(varlist  min=1 max =1)] [STATHistory] [ROSTERID(varlist  min=1 max =3)] [clear]

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


//GET THE FILE STRUCTURE
capt g roster="" //Given old comment files the roster variable might not have been created.
replace roster="`qxvar'" if roster=="" | roster=="Unknown"
levelsof roster, loc(files)
//CHECK IF FILES EXIST
foreach file of loc files  {
capt confirm file "`dir'//`file'.dta"
	if !_rc==0 {
		if length("`directory'")==0  {
		noi dis as error "`file'.dta not found in current directory (`dir')"
		noi dis as error "Check current working directory or specify option {help sursol_getcomm##directory:directory(string)}"
		ex 601
		}
		else if length("`directory'")>0  {
		noi dis as error "`file'.dta not found in directory specified in {help sursol_getcomm##directory:directory(string)}"
		ex 601

		}
	}
}

//FILE LOOP
tempfile mastercomment
save `mastercomment'

foreach file of loc files  {

//GET THE ROSTER ID'S
use "`dir'//`file'.dta" , clear 

if "`file'"!="`qxvar'" {
ds *__id
noi dis as result "Roster ID's in `file'.dta to be used: `r(varlist)'"
loc rosterids `r(varlist)'
}


if "`file'"=="`qxvar'" {
loc rosterids "`id'"
noi display as result "`id' will be used to identify variables at the interview level"
}

use `mastercomment', clear
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
			bys `rosterids' : gen help=_n
			
			reshape wide cmt_sursol order role variable, i(`rosterids') j(help)
		
		
			g `currvar'_comm=""
				foreach var of var cmt_sursol* {
				loc comment_id=substr("`var'",11,.)
				replace `currvar'_comm=`currvar'_comm + "`comment_id'." +role`comment_id' +": "  + `var' + ". " if `var'!="" 
				}
			
			lab var `currvar'_comm "Comment(s) left at question: `currvar'"

			tempfile `currvar'_file
			save ``currvar'_file'
	
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

			merge 1:1 `rosterids' using ``currvar'_file', nogen keep (1 3) keepusing (`currvar'_comm) replace update
			order `currvar'_comm , a(`lastvar')
			sleep 30

			save "`dir'//`file'.dta", replace				
		}
			
						

}

//OPTION INTcomments

if length("`stathistory'")>0 {
noi display as result _n "Interview status history comments will be merged to the `qxvar'.dta"
			use `mastercomment', clear
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
