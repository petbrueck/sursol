capture program drop sursol_transcheck

program sursol_transcheck 
syntax anything [using/], [sheet(string)] [SUBstitution(string)] [MISSing] [clear]


qui {
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
if `cnt'<2 {
noi dis as error"Too few variables specified"
ex 102
}
if `cnt'>2 {
noi dis as error"Too many variables specified"
ex 103
}

loc 2=subinstr("`2'",",","",.)

if "`sheet'"=="" loc sheet "Translations"
local currdir `c(pwd)'

if "`using'"!="" import excel "`using'", sheet("`sheet'") firstrow allstring `clear'

gen problem=0
if length("`missing'")>0 {
g str no_translation="No translation found" if `2'==""
replace problem=1  if `2'==""
count if problem==1
loc missingtext "`r(N)' row(s) of `1' have no translation"
}
if length("`missing'")==0 loc missing=`"& `2'!="""' 
else loc missing ""
foreach vars in `anything' {
confirm str var `vars'
}

if "`substitution'"=="" loc substitution "%"
foreach x of var `1' `2' {
replace `x'="" if `x'=="."
}

tempvar orig1 trans1 norig ntrans
gen `orig1' =substr(`1' ,strpos(`1' ,"`substitution'"),.)
gen `trans1'=substr(`2',strpos(`2',"`substitution'"),.)
qui {
foreach b in orig trans {
	 d ``b'1' 
	loc sub_`b'count=0
	if `r(N)'>0 {
		forv x=1/100 {
		gen full`b'`x'=substr(``b'1' ,1,strpos(subinstr(``b'1' , "`substitution'", " ", 1),"`substitution'"))
		 distinct full`b'`x'
			if `r(N)'==0 {
			drop full`b'`x'
			continue, break
			}
		replace ``b'1' =subinstr(``b'1' ,"`substitution'","",2)
		replace ``b'1' =substr(``b'1' ,strpos(``b'1' ,"`substitution'"),.)
		loc ++sub_`b'count
		}
	}
}
}

if `sub_transcount'>0 & `sub_origcount'==0 g fullorig1=""
if `sub_transcount'==0 & `sub_origcount'>0 g fulltrans1=""

if `sub_transcount'>0 | `sub_origcount'>0 {
qui ds fulltrans*
loc transvarlist ""
loc transcount=0
foreach x in `r(varlist)' {
local transvarlist `"`transvarlist'`x' ,"'	
loc ++transcount	
}
qui ds fullorig*
loc origvarlist ""
loc origcount=0
foreach x in `r(varlist)' {
local origvarlist `"`origvarlist'`x' ,"'	
loc ++origcount	
}
loc transvarlist=strreverse(subinstr(strreverse("`transvarlist'"),",","",1))
loc origvarlist=strreverse(subinstr(strreverse("`origvarlist'"),",","",1))
g `norig'=0
g `ntrans'=0
loc looplength=max(`transcount',`origcount')

g str missing_trans=""
g str missing_orig=""

forv x=1/`looplength' {
 replace problem=1 if !inlist(fullorig`x',`transvarlist') & fullorig`x'!="" `missing'
capt replace missing_trans=missing_trans+" "+ fullorig`x'+"," if !inlist(fullorig`x',`transvarlist') & fullorig`x'!="" `missing'
capt replace problem=1 if !inlist(fulltrans`x', `origvarlist') & fulltrans`x'!="" `missing'
capt replace missing_orig=missing_orig+" "+ fulltrans`x'+"," if !inlist(fulltrans`x', `origvarlist') & fulltrans`x'!="" `missing'
capt replace `norig'=`norig'+1 if fullorig`x'!="" `missing'
capt replace `ntrans'=`ntrans'+1 if fulltrans`x'!="" `missing'
}

replace missing_trans=strreverse(subinstr(strreverse(missing_trans),",","",1)) + " not found in `2'" if missing_trans!=""
replace missing_orig=strreverse(subinstr(strreverse(missing_orig),",","",1)) + " not found in `1'" if missing_orig!=""

replace problem=1 if `ntrans'!=`norig'
g str nsubstitution="The number of text substitutions differs between `1' and `2'" if `ntrans'!=`norig' & missing_trans=="" & missing_orig==""
}

qui count if problem==1
if `r(N)'>0 noi dis as result _n "`r(N)' row(s) of translation need to be checked"
if `r(N)'==0 noi dis as result "No mismatches have been identified. Congratulations!"
capt drop fullorig* fulltrans* 

foreach x in missing_trans missing_orig nsubstitution {
capt confirm var `x' 
if !_rc {
if "`missing'"=="" replace `x'="" if no_translation!=""
loc ex_`x'="1"
count if `x'!=""
loc `x'_count=`r(N)'
if `r(N)'==0 drop `x'
}
}
capt confirm n `missing_trans_count'
if !_rc {
if `missing_trans_count'>0 noi dis as result "`missing_trans_count' row(s) contain substitutions in `1' but not in `2'"
}
capt confirm n `missing_orig_count'
if !_rc {
if `missing_orig_count'>0 noi dis as result "`missing_orig_count' row(s) contain substitutions in `2' but not in `1'"
}
noi dis as res "`missingtext'"

capt gsort -problem 
capt order no_translation, last
capt lab var problem "1 if translation item needs to be checked, 0 if no problem identified"
capt lab var missing_orig_count "Indicates if a substitution has been identified in `2' that could not been found in `1'"
capt lab var missing_trans_count "Indicates if a substitution has been identified in `1' that could not been found in `2'"
capt lab var nsubstitution "Indicates if the number of substitutions used in `1' and `2' differs"

}
end 

