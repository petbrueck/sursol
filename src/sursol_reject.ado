*! version 20.10.1  October 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org


program sursol_reject

syntax if,  SERver(string) USER(string) PASSword(string) [Rpath(string)] ///
 [COMMent(string)] [ID(varlist str min=1 max =1)] [newresponsible(string)]


qui {


**GIVE WARNING IF PROTOCOL OF URL NOT GIVEN 
if strpos("`server'","http")==0 {
noi dis as error _n "Attention. There is no protocol specified in {help sursol_reject##server:server({it:url})}"
noi dis as error "The command will not work if the URL is not specified correctly. Let's give it a try nevertheless..."
}

if length("`id'")==0 {
capt confirm var interview__id
if !_rc==0 {
noi dis as error "Attention. interview__id not found. Specify option id()"
ex 111
}
loc idvar "interview__id"
}

if length("`id'")>0 {
tempvar lengthid
g `lengthid'=length(`id')
sum `lengthid'
if `r(min)'!=32 | `r(max)'!=32 {
noi dis as error "Attention. Variable `id' specified in option id(varlist) is not a unique 32-character long identifier"
ex 198
}
loc idvar "`id'"
}


//CHECK IF NEW RESPONSIBLE IS ADDED, THAT ID IS 36 
if length("`newresponsible'")>0 & length("`newresponsible'")!=36 {
	noi dis as error _n "You specified newresponsible(string) but the ID is not 36 character long."
	noi dis as error "Please check"
	ex 198
} 

********************************************************************************	
***IDENTIFY R PATH
********************************************************************************

//IF NOT SPECIFIED, LOOK FOR IT
********************************************************************************
if length("`rpath'")==0 {

//IF WINDOWS, LOOK AT DEFAULT FOLDER
********************************************************************************
if "`c(os)'" == "Windows" {
	**STILL VERY MESSY. SIMPLIFY AT SOME POINT WITH RECURSIVE FOLDER 
	if strpos("`c(machine_type)'","64")>0 loc bit="x64" 
	if strpos("`c(machine_type)'","32")>0 loc bit="x32" 

	mata : st_numscalar("OK", direxists("C:/Program Files/R"))
	if scalar(OK)==0 {
	noi dis as error _n "Attention. No R folder in ""C:/Program Files/"" was found."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
	ex 601
	}
		local folderstructure: dir "C:/Program Files/R" dirs "*", respectcase 
		local folderstructure : list sort folderstructure
		local length : word count `folderstructure'

		if `length'>1 {
		noi dis as error _n "Attention, multiple versions of R have been found:"
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


	capt mata : st_numscalar("OK", direxists("C:/Program Files/R//`version'/bin/"))
	if _rc==3000 {
	noi dis as error _n "The command has problems identifying your R version."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
	ex 601
	}

	if scalar(OK)==0 {
	noi dis as error _n "Attention. No bin folder in ""C:/Program Files/R//`version'/"" was found."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
	ex 601
	}

	mata : st_numscalar("OK", direxists("C:/Program Files/R//`version'/bin//`bit'/"))
	if scalar(OK)==0 {
	noi dis as error _n "Attention. No `bit' folder in ""C:/Program Files/R//`version'/bin"" was found."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
	ex 601
	}

	capt confirm file "C:/Program Files/R//`version'/bin//`bit'/R.exe"
	if _rc {
	no dis as error _n "Attention. No R.exe in ""C:/Program Files/R//`version'/bin//`bit'/"" was found."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
	ex 601
	}
	loc rpath="C:/Program Files/R//`version'/bin//`bit'/"
}

//IF LINUX/MAC, TRY "usr/bin/R"
********************************************************************************
else {
capture confirm file "/usr/bin/R"
	if _rc != 0 {
		noi dis as error _n "Attention.  No R application found in  'usr/bin/R'."
		noi dis as error  "Please specify the path of your R application  using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
		ex 198
	}
	else loc rpath= "/usr/bin/R"
}

} 

//IF SPECIFIED,OR IF FOUND BY CODE ABOVE, CLEAN IT AND CONFIRM IT EXISTS
********************************************************************************
if length("`rpath'")>0 {

	if strpos(lower(strreverse("`rpath'")),"r")==1 {
		loc rpath=strreverse(subinstr(strreverse("`rpath'"),"R","",1))
	}

	if strpos(lower(strreverse("`rpath'")),"exe.r") {
		loc rpath=strreverse(subinstr(strreverse("`rpath'"),"exe.R","",1))
	}

	//LAST CONFIRMATION IF IT EXISTS
	********************************************************************************
	if "`c(os)'" == "Windows"  capt confirm file "`rpath'/R.exe"
	else if "`c(os)'" != "Windows" capt confirm file "`rpath'/R"
	if _rc {
		no dis as error _n "Attention. No R application in folder '`rpath'' was found."
		noi dis as error  "Please correctly specify the path of your R app using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
		ex 601
	}

}


preserve
keep `if'
if `c(N)'>0{ 
replace `idvar'=`"""'+`idvar'+`"""'
levelsof `idvar', loc(levels) clean sep(,)
}
restore

if length(`"`levels'"')==0 {
noi dis as result _n "No interview fulfills the {help if:if} expression."
noi dis as result "0 interviews will be rejected by Headquarter."
}
else if length(`"`levels'"')>0  {

qui capt rm "`c(pwd)'/reject.R"
qui capt rm "`c(pwd)'/.Rhistory" 

 quietly: file open rcode using  "`c(pwd)'\reject.R", write replace 							
 quietly: file write rcode  /// 
 `"server <- "`server'" "' _newline ///
`"user= "`user'"  "' _newline ///
`"password="`password'" "' _newline ///
`"interview__id <- c(`levels')"' _newline /// 
`"Sys.setlocale("LC_TIME", "English")"' _newline ///
`"packages<- c("stringr", "jsonlite","httr")	 "'  _newline ///
`"for (newpack in packages) { "'  _newline ///
`" if(newpack %in% rownames(installed.packages()) == FALSE) {install.packages(newpack, repos = 'https://cloud.r-project.org/', dep = TRUE)} "'  _newline ///
`"} "'  _newline ///
`"library(stringr) "'  _newline			  ///
`"library(jsonlite) "'  _newline  ///
`"library(httr) "'  _newline  ///
 `"   ##REPLACE TRAILING SLASH "' _newline ///
 `"   if   (str_sub(server,-1,-1) %in% c("/","\"") ) server <-   str_sub(server, end=-2) "' _newline ///
 `"server_url<-sprintf("%s", server)  "'    _newline																				  ///										
                `"  "'    _newline  ///
                `"serverCheck <- try(http_error(server_url), silent = TRUE)  "'    _newline  ///
                `"if (class(serverCheck) == "try-error") {  "'    _newline  ///
              `"	  stop(paste0("The following server does not exist. Check internet connection or the server name:", server_url))     "'  _newline  ///
                `"    "'    _newline  ///
                `"}  "'    _newline  ///																																	  ///
 `"for (x in c("user", "password", "server")) {  "'    _newline ///
                `"  if (!is.character(get(x))) {  "'    _newline ///
                `"    stop(paste("Check that the parameters in the data are the correct data type (e.g. String?). Look at:",x))  "'    _newline	  ///
                `"      "'    _newline  ///
                `"  }  "'    _newline  ///
                `"    "'    _newline			  ///
                `"  if (nchar(get(x)) == 0) {  "'    _newline ///
                `"    stop(paste("The following parameter is not specified in the program:", x))  "'    _newline ///
                `"  }  "'    _newline ///
                `"}  "'    _newline ///
`"command <- "/reject?comment=`comment'&responsibleId=`newresponsible'" "' _newline ///
`"counter=0"' _newline ///
`"count406=0"' _newline ///
`"count404=0"' _newline ///
`"for (val in interview__id){"' _newline ///
`"reject_query<-URLencode(paste(c(server_url,"/api/v1/interviews/",val,command), collapse = "")) "' _newline ///
`"reject <- PATCH(reject_query, authenticate(user, password))"' _newline ///
`" if (status_code(reject) == 401) {     "' _newline ///
`"   stop("Incorrect username or password. Check login credentials for API user")   "' _newline ///
`" 	}  "' _newline ///
  `"if (status_code(reject)==404) {  "' _newline ///
  `"message(paste("Target interview", val," was not found")) "' _newline ///  
 `"  count404= count404+1 "' _newline ///
 `"}  "' _newline ///
 `"if (status_code(reject)==406) {  "' _newline ///
 `"print(paste("Target interview", val," was in status that was not ready to be rejected")) "' _newline ///  
 `"  count406= count406+1 "' _newline ///
 `"}  "' _newline ///
`" counter= counter+1 "' _newline ///
`"if (counter==length(interview__id)) { "' _newline ///
`" count200= length(interview__id)-count406-count404"' _newline ///
`"print(paste(count200,"interviews have been successfully rejected")) "' _newline ///  
`"print(paste(count406,"interviews have been in status that was not ready to be rejected")) "' _newline ///  
`"print(paste(count404,"interviews have been not found")) "' _newline ///  
`"  Sys.sleep(5) "' _newline ///
`"}"' _newline ///
`"}"'	_newline
 file close rcode 

		tempfile error_message //ERROR MESSAGES FROM R WILL BE STORED HERE
		timer clear
		timer on 1
		shell "`rpath'/R" --vanilla <"`c(pwd)'/reject.R" 2>`error_message' 

		timer off 1	
		qui timer list 1
		if `r(t1)'<=3 {
		noi dis as error "Whoopsa! That was surprisingly fast."
		noi dis as error "Please check if the interviews were rejected correctly." 
		noi dis as error "If not, have a look at {help sursol_reject##debugging:debugging information} in the help file."
		dis as error "You might need to install some R packages manually since Stata has no administrator rights to install them."
		}


		//DISPLAY ANY ERRORS PRODUCED IN THE R SCRIPT
		noi di as result _n
		noi di as result "{ul:Warnings & Error messages displayed by R:}"
		noi type `error_message'
}
}
qui capt rm "`c(pwd)'/reject.R"
qui capt rm "`c(pwd)'/.Rhistory" 

 end

