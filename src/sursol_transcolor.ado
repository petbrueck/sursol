*! version 20.01 January 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org

capture program drop sursol_transcolor

program sursol_transcolor 
syntax anything [using/], [sheet(string)] [SUBstitution(string)]  [clear] [color(string)] [only(string)]


qui {

gettoken vars 0: 0,parse(",")


//Checks
if "`using'"=="" & "`sheet'"!="" {
noi dis as error "Option sheet can not be specified if no excel file is loaded through 'using'"
ex 198
}
if "`using'"=="" & "`clear'"!="" {
noi dis as error "Option clear can not be specified if no excel file is loaded through 'using'"
ex 198
}

loc cnt: word count `anything'
if `cnt'>1 {
noi dis as error"Too many variables specified"
ex 103
}

if "`sheet'"=="" loc sheet "Translations"
local currdir `c(pwd)'

if "`using'"!="" import excel "`using'", sheet("`sheet'") firstrow allstring `clear'

capt confirm str var `vars'
if !_rc==0 {
noi display as error"Variable '`vars'' needs to be string variable. Check {help sursol_transcolor:sursol transcolor}"
ex 109 
}

if "`substitution'"=="" loc substitution `"%"'

//Check color option
if "`color'"=="" loc color = "maroon"
else if "`color'"!="" {
//1. Check if in list color name or correct RGB Value 
if !inlist(lower("`color'"),"white","silver","gray","black","red","maroon","yellow","olive","lime") ///
& !inlist(lower("`color'"),"green","aqua","teal","blue","navy","fuchsia","purple") ///
& strpos("`color'","#")!=1 | (strpos("`color'","#")==1 & length("`color'")!=7) {
noi dis as error "Color '`color'' specified in option {help sursol_transcolor##option_color:color(string)} is not supported."
if  strpos("`color'","#")>0 noi dis as error `"If you tried to use RGB value, start with # and enter 6 characters as described {browse "https://support.mysurvey.solutions/questionnaire-designer/techniques/formatting-text/":here.}"'
ex 198 
}
loc color = "`color'"

}


replace `vars'="" if `vars'=="."

//Run the regular text substitution coloring (e.g. %rostertitle%).
if "`only'"=="" {
tempvar orig1 
gen `orig1'=substr(`vars' ,strpos(`vars' ,`"`substitution'"'),.)

qui {
foreach b in orig {
	d ``b'1' 
	loc sub_`b'count=0
	if `r(N)'>0 {
		forv x=1/100 {
		tempvar full`b'`x'
		gen `full`b'`x''=substr(``b'1' ,1,strpos(subinstr(``b'1' , `"`substitution'"', " ", 1),`"`substitution'"'))
		 count if `full`b'`x''!=""
			if `r(N)'==0 {
			drop `full`b'`x''
			continue, break
			}
		replace ``b'1' =subinstr(``b'1' ,`"`substitution'"',"",2)
		replace ``b'1' =substr(``b'1' ,strpos(``b'1' ,`"`substitution'"'),.)
		loc ++sub_`b'count
		}
	}
}
}

// If nothing to color, end the command
if  `sub_origcount'==0 {
noi dis as result _n "There are 0 rows in which text items where found to be colored for variable: `vars' "
}

else {

loc total_masterreplace=0

ds
loc lastvar: word `c(k)' of `r(varlist)'

foreach var of var `fullorig1' - `lastvar' {
g `var'_colored="<font color=`color'>"+`var'+"</font>"

//Just to count # of replacements of the first color replacement
gen tot_rc_`var'=(length(`vars') - length(subinstr(`vars', `var'_colored, "", .)))/length(`var'_colored)
egen tot_rc_`var'_sum=total(tot_rc_`var')
sum tot_rc_`var'_sum
loc tot_replacecolour=`r(max)'

//First replacement (Makes sure that the same substitution is not coloured twice
replace `vars'=subinstr(`vars',`var'_colored,`var',.)

//Just to count # of the final replacements
gen tot_r_`var'=(length(`vars') - length(subinstr(`vars', `var', "", .)))/length(`var')
egen tot_r_`var'_sum=total(tot_r_`var')
sum tot_r_`var'_sum
loc total_masterreplace=`total_masterreplace'+(`r(max)'-`tot_replacecolour')


//Final replacement
replace `vars'=subinstr(`vars',`var',`var'_colored,.)
capt drop tot_rc_`var' tot_r_`var' tot_r_`var'_sum tot_rc_`var'_sum
}



//Display Results
tab `fullorig1'
noi dis as result _n "The color of `total_masterreplace' text items has been changed in `r(N)' rows."



}
} // End of if "`only'=="" condition



if "`only'"!="" {
tempvar trans_copy help1 help2 help3 help4
g `trans_copy'=lower(`vars')

//JUST TO COUNT # OF REPLACEMENTS
gen `help1' =(length(`vars') - length(subinstr(`vars', "`only'", "", .)))/length("`only'")
egen `help2'_sum=total(`help1')
sum `help2'_sum
loc tot_replacecolour=`r(max)'
gen `help3'=`help1' >0
egen `help4'=total(`help3')
sum `help4'
loc tot_replacerows=`r(max)'


noi replace `vars'=subinstr(`vars',"`only'","<font color=`color'>"+"`only'"+"</font>",.)

noi dis as result _n "The color of `tot_replacecolour' text items of '`only'' has been changed in `tot_replacerows' rows."

}


}


end 

