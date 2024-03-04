*! version 20.04 April 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org

*********************************************************************************
//RESHAPE  COMMAND
*********************************************************************************

capture program drop sursol_reshape
program sursol_reshape 
syntax anything,  ID(varlist) ROSTER(varlist) [SUBstitut(string)]
local currdir `c(pwd)'

//GO THROUGH ALL VALUES OF THE `Roster' VARIABLE 
//AND PICK UP THE VALUE LABELS
levelsof `roster', loc(levels)
foreach lev of loc levels {
loc lbl`lev': label (`roster') `lev'
}

//COMPILE THE FULL VARLIST. E.g. IF USER SPECIFIED q1_* GET ALL VARIABLES THAT ARE CALLED LIKE THAT. q1_1 & q1_2 AS AN EXAMPLE.
loc newvarlist ""
foreach var of var `anything' {
//GET THE VARIABLE LABEL WHICH WILL BE USED LATER AGAIN
loc varlbl`var': var label `var'
local newvarlist  `"`newvarlist' "`var'" "'
}

if length("`id'")==0 loc id "interview__id"  //IF "ID" NOT SPECIFIED TAKE "interview__id" WHICH IS SURSOL DEFAULT

reshape wide `anything', i(`id') j(`roster') //RESHAPE WIDE WITH THE RESPECTIVE SPECIFIED VARIABLES

//GO THROUGH THE VALUES OF ALL VARIABLES AGAIN
foreach lev of loc levels {
foreach var in `newvarlist' {

rename `var'`lev' `var'__`lev' //RENAME 


//CREATE FINAL LABEL WHICH REPLACES "SUBSTITUT" WITH SPECIFIED STRING. E.g. '%rostertitle' WITH "XXXX" specified through substitut("XXXX")
if "`substitut'"!="" {		
	loc finlbl`var'= subinstr("`varlbl`var''","`substitut'","`lbl`lev''",.)

		//CHECK IF THE FINAL VARIABLE LABEL IS LONGER TAN 80 STRINGS
		//IF SO, REDUCE THE STRING SO THAT THE VALUE LABEL IS FULLY DISPLAYED
		if length("`finlbl`var''" )>80 {
		loc `var'lbl_nosub=subinstr("`varlbl`var''","`substitut'","",.) 
		loc hold`var'=substr("``var'lbl_nosub'",1,81-length("`lbl`lev''")-2) + ": `substitut'"
		loc finlbl`var'= subinstr("`hold`var''","`substitut'","`lbl`lev''",.) 
		}
 
	lab var `var'__`lev' "`finlbl`var''"
	}

//IF SUBSTITUTION NOT SPECIFIED 

if "`substitut'"=="" {
loc finlbl`var'= "`lbl`lev'': "  +"`varlbl`var''" 
lab var `var'__`lev' "`finlbl`var''"
	}

}
}
cd "`currdir'"		
end


