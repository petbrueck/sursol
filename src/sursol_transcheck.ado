capture program drop sursol_transcheck

program sursol_transcheck 
syntax anything [using/], [sheet(string)] [SUBstitution(string)] [MISSing] [clear] [sort] [html]


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

  	foreach x in problem sub_missing_trans sub_missing_orig sub_n_difference {
	capt confirm var `x' 
	if !_rc {
	noi dis as error "Variable '`x'' must not exist when using {help sursol_transcheck:transcheck}."
	ex 110
	}
		}


gen problem=0
//Check if missing is specified
if length("`missing'")>0 {
g str no_translation="No translation found" if `2'==""
replace problem=1  if `2'==""
count if problem==1
loc missingtext "`r(N)' row(s) of `2' have no translation"
}
if length("`missing'")==0 loc missing=`"& `2'!="""' 
else loc missing ""
//Get identifier if we found missing issues
tab problem if problem==1
loc n_missing_problem= `r(N)'

foreach vars in `anything' {
capt confirm str var `vars'
if !_rc==0 {
noi display as error"Variable '`vars'' needs to be string variable. Check {help sursol_transcheck:sursol transcheck}"
ex 109 
}
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
		 count if full`b'`x'!=""
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

g str sub_missing_trans=""
g str sub_missing_orig=""


egen fulltrans_comb=concat(fulltrans*), p(,)
egen fullorig_comb=concat(fullorig*), p(,)

forv x=1/`origcount' {
replace problem=1 if strpos(fulltrans_comb,fullorig`x')==0 & fullorig`x'!="" `missing'
replace sub_missing_trans=sub_missing_trans+" "+ fullorig`x'+"," if strpos(fulltrans_comb,fullorig`x')==0 & fullorig`x'!="" `missing'
replace `norig'=`norig'+1 if fullorig`x'!="" `missing'
}

forv x=1/`transcount'{
replace problem=1 if strpos(fullorig_comb,fulltrans`x')==0 & fulltrans`x'!="" `missing'
replace sub_missing_orig=sub_missing_orig+" "+ fulltrans`x'+"," if strpos(fullorig_comb,fulltrans`x')==0 & fulltrans`x'!="" `missing'
replace `ntrans'=`ntrans'+1 if fulltrans`x'!="" `missing'
}

replace sub_missing_trans=strreverse(subinstr(strreverse(sub_missing_trans),",","",1)) + " not found in `2'" if sub_missing_trans!=""
replace sub_missing_orig=strreverse(subinstr(strreverse(sub_missing_orig),",","",1)) + " not found in `1'" if sub_missing_orig!=""

replace problem=1 if `ntrans'!=`norig'
g str sub_n_difference="The number of text substitutions differs between `1' and `2'" if `ntrans'!=`norig' & sub_missing_trans=="" & sub_missing_orig==""
}




//HTML PART
if "`html'"!=""{

g str html_missing_trans=""
g str html_missing_orig=""
g str html_n_difference=""


foreach htmlcode in <u> <br> <i> <tt> <big> <small> <sub> <sup>  <blockquote>  <cite>  <dfn>  <em> <p> <strong> "<fontcolor" {
tempvar n_htmlorig n_htmltrans
loc length_html=length("`htmlcode'")
*display `length_html'
gen `n_htmlorig'= (length(subinstr(`1'," ","",.)) - length(subinstr(subinstr(`1'," ","",.), "`htmlcode'", "", .))) / `length_html'
gen `n_htmltrans' = (length(subinstr(`2'," ","",.)) - length(subinstr(subinstr(`2'," ","",.), "`htmlcode'", "", .))) / `length_html'

replace problem=1 if `n_htmltrans'!=`n_htmlorig'
replace html_missing_trans=html_missing_trans+ " `htmlcode'," if `n_htmltrans'==0 & `n_htmlorig'>0
replace html_missing_orig=html_missing_orig+ " `htmlcode'," if `n_htmltrans'>0 & `n_htmlorig'==0

tostring `n_htmltrans', g(`n_htmltrans'_string)
tostring `n_htmlorig', g(`n_htmlorig'_string)

replace html_n_difference=html_n_difference + " `htmlcode' - (Original: " + `n_htmlorig'_string +", `2': " + `n_htmltrans'_string +");" if `n_htmltrans'!=`n_htmlorig' & (`n_htmltrans'>0 & `n_htmlorig'>0)
}

replace html_missing_trans=html_missing_trans + " not found in `2'" if html_missing_trans!=""
replace html_missing_orig=html_missing_orig + " not found in `1'" if html_missing_orig!=""
replace html_missing_trans=subinstr(html_missing_trans,", not found"," not found",.)
replace html_missing_orig=subinstr(html_missing_orig,", not found"," not found",.)
replace html_n_difference=strreverse(subinstr(strreverse(html_n_difference),";","",1))

replace html_missing_trans=subinstr(html_missing_trans,"<fontcolor","<font color=...>",.)
replace html_missing_orig=subinstr(html_missing_orig,"<fontcolor","<font color=...>",.)


capt lab var html_n_difference "Indicates if # of htlm tags differs between `1' and `2'" 
capt lab var html_missing_orig "HTML tag has been identified in `2' but not in `1'"
capt lab var html_missing_trans "HTML tag has been identified in `1' but not in `2'"
count if html_n_difference !="" | html_missing_orig !="" | html_missing_trans !=""
loc n_html_probs=`r(N)'
}

//Display Results
qui count if problem==1
if `r(N)'>0 {
noi dis as result _n "`r(N)' row(s) of translation need to be checked"
noi dis as result ""
}
if `r(N)'==0 noi dis as result "No mismatches have been identified. Congratulations!"
capt drop fullorig* fulltrans* 

foreach x in sub_missing_trans sub_missing_orig sub_n_difference html_missing_orig  html_missing_trans html_n_difference  {
capt confirm var `x' 
if !_rc {
if "`missing'"=="" replace `x'="" if no_translation!=""
loc ex_`x'="1"
count if `x'!=""
loc `x'_count=`r(N)'
if `r(N)'==0 drop `x'
}
}

capt confirm n `sub_missing_trans_count'
if !_rc {
if `sub_missing_trans_count'>0 noi dis as result "`sub_missing_trans_count' row(s) contain substitutions in `1' but not in `2'"
}
capt confirm n `sub_missing_orig_count'
if !_rc {
if `sub_missing_orig_count'>0 noi dis as result "`sub_missing_orig_count' row(s) contain substitutions in `2' but not in `1'"
}
capt confirm var sub_n_difference
if !_rc {
qui tab sub_n_difference
noi dis as result "`r(N)' row(s) have different number of substitutions between `1' and `2'"
}
capt confirm n `n_html_probs' 
if !_rc noi dis as result ""

capt confirm n `html_missing_trans_count'
if !_rc {
if `html_missing_trans_count'>0 noi dis as result "`html_missing_trans_count' row(s) contain html tag in `1' but not in `2'"
}
capt confirm n `html_missing_orig_count'
if !_rc {
if `html_missing_orig_count'>0 noi dis as result "`html_missing_orig_count' row(s) contain html tag in `2' but not in `1'"
}
capt confirm var html_n_difference
if !_rc {
qui tab html_n_difference
noi dis as result "`r(N)' row(s) have different number of html tags between `1' and `2'"
}

noi dis as res _n "`missingtext'"

if "`sort'"!="" capt gsort -problem 
capt order no_translation, last
capt lab var problem "1 if translation item needs to be checked, 0 if no problem identified"
capt lab var sub_missing_orig "Substitution has been identified in `2' but not in `1'"
capt lab var sub_missing_trans "Substitution has been identified in `1' but not in `2'"
capt lab var sub_n_difference "Indicates if # of substitutions used in `1' and `2' differs"
}




end 

