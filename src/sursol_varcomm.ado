program sursol_varcomm

syntax anything [if],  SERver(string) USER(string) PASSword(string) COMMent(string) [Rpath(string)]   [ID(varlist str min=1 max =1)]


qui {
foreach x in ".mysurvey.solutions" "//" ":" "https" { 
loc server=subinstr("`server'","`x'","",.)
}

if length("`id'")==0 {
capt confirm var interview__id
if !_rc==0 {
noi dis as error "Attention. interview__id not found. Specify option id()"
ex 111
}
loc id "interview__id"
}

if length("`id'")>0 {
tempvar lengthid
g `lengthid'=length(`id')
sum `lengthid'
if `r(min)'!=32 | `r(max)'!=32 {
noi dis as error "Attention. Variable `id' specified in option id(varlist) is not a unique 32-character long identifier"
ex 198
}
}
if length("`rpath'")==0 {
if strpos(lower("`c(os)'"),"window")==0 {
noi dis as error _n "Attention.  You are not using Windows as an operating system."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_approveHQ##sursol_approveHQ_rpath:rpath(string)}"
ex
}

if length("`comment'")==0 loc comment "Approved%20by%20HQ%20through%20API%20User:%20`user'"
else if length("`comment'")>0 loc comment=subinstr("`comment'"," ","%20",.)

if strpos("`c(machine_type)'","64")>0 loc bit="x64" 
if strpos("`c(machine_type)'","32")>0 loc bit="x32" 

mata : st_numscalar("OK", direxists("C:\Program Files\R"))
if scalar(OK)==0 {
noi dis as error _n "Attention. No R folder in ""C:\Program Files\"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_approveHQ##sursol_approveHQ_rpath:rpath(string)}"
ex
}



	local folderstructure: dir "C:\Program Files\R" dirs "*", respectcase 
	local folderstructure : list sort folderstructure
	local length : word count `folderstructure'

	if `length'>1 {
	noi dis as error _n "Attention, two versions of R have been found:"
	loc i=1
	foreach x of loc folderstructure {
	noi dis as error "`x'" 
	if `length'==`i' {
	noi dis as result _n "Version `x' of R will be used to export the data"
	loc version="`x'"
	} 
	loc ++i
	} 
} 	

else if `length'==1 {
	foreach x of loc folderstructure {
	loc version="`x'"
	}
}



capt mata : st_numscalar("OK", direxists("C:\Program Files\R\\`version'\bin\"))
if _rc==3000 {
noi dis as error _n "The command has problems identifying your R version."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_approveHQ##sursol_approveHQ_rpath:rpath(string)}"
ex
}

if scalar(OK)==0 {
noi dis as error _n "Attention. No bin folder in ""C:\Program Files\R\\`version'\"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_approveHQ##sursol_approveHQ_rpath:rpath(string)}"
ex
}

mata : st_numscalar("OK", direxists("C:\Program Files\R\\`version'\bin\\`bit'\"))
if scalar(OK)==0 {
noi dis as error _n "Attention. No `bit' folder in ""C:\Program Files\R\\`version'\bin"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_approveHQ##sursol_approveHQ_rpath:rpath(string)}"
ex
}

capt confirm file "C:\Program Files\R\\`version'\bin\\`bit'\R.exe"
if _rc {
no dis as error _n "Attention. No R.exe in ""C:\Program Files\R\\`version'\bin\\`bit'\"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_approveHQ##sursol_approveHQ_rpath:rpath(string)}"
ex
}
loc rpath="C:\Program Files\R\\`version'\bin\\`bit'\"

} 


if length("`rpath'")>0 {
if strpos(lower(strreverse("`rpath'")),"r")==1 {
loc rpath=strreverse(subinstr(strreverse("`rpath'"),"R","",1))
}

if strpos(lower(strreverse("`rpath'")),"exe.r") {
loc rpath=strreverse(subinstr(strreverse("`rpath'"),"exe.R","",1))
}


capt confirm file "`rpath'\R.exe"
if _rc {
no dis as error _n "Attention. No R.exe in ""`rpath'"" was found."
noi dis as error  "Please correctly specify the path of your R.exe using the option {help sursol_approveHQ##sursol_approveHQ_rpath:rpath(string)}"
ex
}
}

if length(`"`if'"')>0 {
preserve
keep `if'
if `c(N)'>0{ 
replace `id'=`"""'+`id'+`"""'
levelsof `id', loc(levels) clean sep(,)

}
restore
}
else if length(`"`if'"')==0 {
replace `id'=`"""'+`id'+`"""'
levelsof `id', loc(levels) clean sep(,)
}

qui capt rm "`c(pwd)'\varcomm.R"
qui capt rm "`c(pwd)'\.Rhistory" 
 quietly: file open rcode using  "`c(pwd)'\varcomm.R", write replace 							
 quietly: file write rcode  /// 
 `"server <- "`server'" "' _newline ///
`"user= "`user'"  "' _newline ///
`"password="`password'" "' _newline ///
`"`id' <- c(`levels')"' _newline /// 
`"Sys.setlocale("LC_TIME", "English")"' _newline ///
`"packages<- c("tidyverse", "stringr","lubridate", "jsonlite","httr","dplyr","date")	 "'  _newline ///
`"for (newpack in packages) { "'  _newline ///
`" if(newpack %in% rownames(installed.packages()) == FALSE) {install.packages(newpack, repos = 'https://cloud.r-project.org/', dep = TRUE)} "'  _newline ///
`"} "'  _newline ///
`"library(stringr) "'  _newline			  ///
`"library(jsonlite) "'  _newline  ///
`"library(httr) "'  _newline  ///
`"library(dplyr) "'  _newline  ///
`"library(lubridate) "'  _newline		  ///								                
`"library(date)"'  _newline				  ///	
 `"server_url<-sprintf("https://%s.mysurvey.solutions", server)  "'    _newline																				  ///										
                `"  "'    _newline  ///
                `"serverCheck <- try(http_error(server_url), silent = TRUE)  "'    _newline  ///
                `"if (class(serverCheck) == "try-error") {  "'    _newline  ///
                `"  message("The following server does not exist. Check internet connection or the server name:",  "'    _newline  ///
                `"       "\n", server_url)  "'    _newline  ///
                `"  Sys.sleep(5)  "'    _newline  ///
                `"  stop()  "'    _newline  ///
                `"    "'    _newline  ///
                `"}  "'    _newline  ///																																	  ///
 `"for (x in c("user", "password", "server")) {  "'    _newline ///
                `"  if (!is.character(get(x))) {  "'    _newline ///
                `"    message(paste("Check that the parameters in the data are the correct data type (e.g. String?). Look at:",x))  "'    _newline ///
                `"    Sys.sleep(5)  "'    _newline ///
                `"    stop()  "'    _newline	  ///
                `"      "'    _newline  ///
                `"  }  "'    _newline  ///
                `"    "'    _newline			  ///
                `"  if (nchar(get(x)) == 0) {  "'    _newline ///
                `"    message(paste("The following parameter is not specified in the program:", x))  "'    _newline  ///
                `"    Sys.sleep(5)  "'    _newline ///
                `"    stop()  "'    _newline ///
                `"  }  "'    _newline ///
                `"}  "'    _newline ///
`"command <- "/comment-by-variable/`anything'?comment=`comment'""' _newline ///
`"counter=0"' _newline ///
`"count406=0"' _newline ///
`"count404=0"' _newline ///
`"for (val in `id'){"' _newline ///
`"approve_query<-paste(c(server_url,"/api/v1/interviews/",val,command), collapse = "")"' _newline ///
`"approve <- POST(approve_query, authenticate(user, password))"' _newline ///
  `"if (status_code(approve)==404) {  "' _newline ///
  `"message(paste("Target interview", val," was not found")) "' _newline ///  
 `"  count404= count404+1 "' _newline ///
 `"}  "' _newline ///
 `"if (status_code(approve)==406) {  "' _newline ///
 `"message(paste("Target interview", val," is in status that was not ready to comment on variable")) "' _newline ///  
 `"  count406= count406+1 "' _newline ///
 `"}  "' _newline ///
`" counter= counter+1 "' _newline ///
`"if (counter==length(`id')) { "' _newline ///
`" count200= length(`id')-count406-count404"' _newline ///
`"message(paste(count200,"interviews have been successfully commented on")) "' _newline ///  
`"message(paste(count406,"interviews have been in status that was not ready to be commented on")) "' _newline ///  
`"message(paste(count404,"interviews have been not found")) "' _newline ///  
`"  Sys.sleep(5) "' _newline ///
`"}"' _newline ///
`"}"'	_newline
 file close rcode 


shell "`rpath'\R" --vanilla <"`c(pwd)'\varcomm.R"
qui capt rm "`c(pwd)'\varcomm.R"
qui capt rm "`c(pwd)'\.Rhistory" 

}
 end
