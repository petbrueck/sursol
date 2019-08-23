capture program drop sursol_import

program sursol_import 
syntax anything,  DIRectory(string) [EXport(string)]  [version(string)]

local currdir `c(pwd)'
loc currversion=c(version)

loc notworked "" 
qui {

if  length("`version'")>0 & `currversion'<`version' {
noi dis as error "You are using Stata `currversion'. One can not save datasets for a more recent Stata version. "
noi dis as error "If you have a more recent Stata version installed, check if you have specified {help version: version} in your syntax."
ex 0
}

mata : st_numscalar("OK", direxists("`directory'"))
if scalar(OK)==0 {
noi dis as error _n "Attention. Directory: ""`directory'"" not found."
noi dis as error  "Please correctly specify {help ssimport##ssimport_directory:directory(string)}"
ex 601
}


if length("`export'")>0{
	mata : st_numscalar("OK", direxists("`export'"))
	if scalar(OK)==0 {
	noi di as error "Attention, directory specified in {help ssimport##ssimport_export:export(string)} does not exist."
	ex 601
	}
}





if length("`export'")==0 loc export="`directory'"

local folderstructure: dir "`directory'" dirs "`1'*", respectcase 
local folderstructure : list sort folderstructure
local length : word count `folderstructure'
		
	if `length'==0 {
	noi di as error _n "Attention, no folder found named:  ""`1'"" 
	noi di as error "Check folder name specified or directory!" 
	ex 601
	}

	
	foreach folder of loc folderstructure {
	capt mkdir "`export'/`folder'/" 
	local filestructure: dir "`directory'/`folder'" file "*.dta", respectcase 
	local filestructure : list sort filestructure  	
		foreach file of loc filestructure {
		capt erase "`export'/`folder'/`file'"
		}
	}

	
	loc i=0
	foreach folder of loc folderstructure {
	cd "`directory'/`folder'"
	loc ssversion= subinstr("`folder'", "`1'_","",.) 
	
	loc filecount=0
	local filestructure: dir "`directory'/`folder'" file "*.do", respectcase 
	local ignoreme "paradata.do"
	local filestructure : list filestructure-ignoreme 
	local filestructure : list sort filestructure 
	if length(`"`filestructure'"')==0 {
	noi di as error _n "Attention, no files found in folder: `folder'" 
	local notworked `" `notworked'  "`folder'" " " "'
	loc ++i
	continue
	}
	noi di as text _n "`ssversion' found. Tabular data will be imported..."

	foreach file of loc filestructure {
	include "`directory'/`folder'/`file'"
	loc filepure=subinstr("`file'",".do","",.)
	if length("`version'")==0  save "`export'/`folder'/filepure'", replace
	else if length("`version'")>0 {
		if (`currversion'>13 & `version'>13) save "`export'/`folder'/filepure'", replace
		if `currversion'==`version' save "`export'/`folder'/`filepure'", replace
		if (`currversion'>13 & inrange(`version',11,13)) saveold "`export'/`folder'/`filepure'", replace  version(`version')
		if (`currversion'<13 & inrange(`version',7,12)) saveold "`export'/`folder'/`filepure'", replace 

	}
	
	if  `c(N)'==0  	noi di as text "`filepure'.tab from `ssversion' contains no observation"
	clear
	loc ++filecount
	}
	noi display as text "`filecount' files from `ssversion' imported"
	loc ++i
	}
	
local worked: list folderstructure- notworked

	if `i'==1 & length("`notworked'")==0 {
		noi di as result _n(2) "Only 1 version found and successfully imported: "
		foreach folder of loc worked {
		noi di as result "`folder'"
}

	} 
	
else if `i'>1 {
noi di as text _n "The following data has been successfully imported: "
foreach folder of loc worked {
noi di as result "`folder'"
}
}

if length("`notworked'")>0 {
noi di as error _n(2)"The following versions were found but no .do & .tab files in folder: "
foreach fail of loc notworked {
noi di as error "`fail'"
}
}	
	

	}
	
	end 