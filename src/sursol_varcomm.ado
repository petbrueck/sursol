*! version 20.10.1  October 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org


program sursol_varcomm

syntax anything [if],  SERver(string) USER(string) PASSword(string) COMMent(string) [Rpath(string)]   [ID(varlist str min=1 max =1)] [roster1(numlist min=1 max=1)] [roster2(numlist min=1 max=1)] [roster3(numlist min=1 max=1)] [roster4(numlist min=1 max=1)]


qui {


**GIVE WARNING IF PROTOCOL OF URL NOT GIVEN 
if strpos("`server'","http")==0 {
noi dis as error _n "Attention. There is no protocol specified in {help sursol_varcomm##server:server({it:url})}"
noi dis as error "The command will not work if the URL is not specified correctly. Let's give it a try nevertheless..."
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

//CHECK IF ROSTER VARIABLES SPECIFIED.
forvalues row=4(-1)2 {
loc value_below=`row'-1
if length("`roster`row''")==0 continue 

else if length("`roster`row''")>0 {
	if length("`roster`value_below''")==0 {
		noi dis as error "You specified option {help sursol_varcomm##rostervars:roster`row'(numlist)}. You need to also specify the parent-roster roster`value_below'(numlist)."
		ex 198 
		}	
	}
}

//CLEAN UP COMMENT VARIABLE
loc comment=subinstr("`comment'"," ","%20",.)


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


if length(`"`if'"')>0 {
preserve
keep `if'
if `c(N)'>0 { 
replace `id'=`"""'+`id'+`"""'
levelsof `id', loc(levels) clean sep(,)

}
restore
}
else if length(`"`if'"')==0 {
replace `id'=`"""'+`id'+`"""'
levelsof `id', loc(levels) clean sep(,)
}



********************************************************************************
//WRITE R SCRIPT
qui capt rm "`c(pwd)'/varcomm.R"
qui capt rm "`c(pwd)'/.Rhistory" 



 quietly: file open rcode using  "`c(pwd)'/varcomm.R", write replace 		
 
 #d ;
 quietly: file write rcode   
`"server <- "`server'" "' _newline 
`"user= "`user'"  "' _newline 
`"password="`password'" "' _newline 
`"`id' <- c(`levels')"' _newline  

`"roster_vec1 <- "`roster1'"   "'  _newline
`"roster_vec2 <- "`roster2'"   "'  _newline
`"roster_vec3 <- "`roster3'"   "'  _newline
`"roster_vec4 <- "`roster4'"   "'  _newline
`" ##PACKAGES																																		 "' _newline
`"packages<- c("stringr", "jsonlite","httr")    "' _newline
`"for (newpack in packages) {  "' _newline
`"  if(newpack %in% rownames(installed.packages()) == FALSE) {install.packages(newpack, repos = 'https://cloud.r-project.org/', dep = TRUE)}  "' _newline
`"  if(newpack %in% rownames(installed.packages()) == FALSE) {   "' _newline
`"    stop(paste0("Attention. Problems installing package: ",newpack, "Try to install it manually"))        "' _newline
`"  }  "' _newline
`"}  "' _newline
`"suppressMessages(suppressWarnings(library(stringr)))  "' _newline
`"suppressMessages(suppressWarnings(library(jsonlite)))  "' _newline
`"suppressMessages(suppressWarnings(library(httr)))  "' _newline

																																		
 `"   ##REPLACE TRAILING SLASH "' _newline 
 `"   if   (str_sub(server,-1,-1) %in% c("/","\"") ) server <-   str_sub(server, end=-2) "' _newline 
 `"server_url<-sprintf("%s", server)  "'    _newline																				  										
`"	serverCheck <- try(http_error(server_url), silent = TRUE)     "'  _newline
`"	if (class(serverCheck) == "try-error") {     "'  _newline
`"	  stop(paste0("The following server does not exist. Check internet connection or the server name:", server_url))     "'  _newline
`"	       "'  _newline
`"	}     "'  _newline
`" "'  _newline
 `"for (x in c("user", "password", "server")) {  "'    _newline 
                `"  if (!is.character(get(x))) {  "'    _newline 
                `"    stop(paste("Check that the parameters in the data are the correct data type (e.g. String?). Look at:",x))  "'    _newline	  
                `"      "'    _newline  
                `"  }  "'    _newline  
                `"    "'    _newline			  
                `"  if (nchar(get(x)) == 0) {  "'    _newline 
                `"    stop(paste("The following parameter is not specified in the program:", x))  "'    _newline 
                `"  }  "'    _newline 
                `"}  "'    _newline 
				
				
`"if (nchar(roster_vec1) > 0) roster_vec1<- paste0("rosterVector=",roster_vec1)"' _newline
`"if (nchar(roster_vec2) > 0) roster_vec2<- paste0("&rosterVector=",roster_vec2)"' _newline
`"if (nchar(roster_vec3) > 0) roster_vec3<- paste0("&rosterVector=",roster_vec3)"' _newline
`"if (nchar(roster_vec4) > 0) roster_vec4<- paste0("&rosterVector=",roster_vec4)"' _newline

`"command <- paste0("/comment-by-variable/`anything'?",roster_vec1,  roster_vec2, roster_vec3, roster_vec4, "&comment=`comment'")"' _newline 

`"counter=0"' _newline 
`"count406=0"' _newline 
`"count404=0"' _newline 
`"for (val in `id'){"' _newline 
`"comment_query<-URLencode(paste(c(server_url,"/api/v1/interviews/",val,command), collapse = "")) "' _newline 
`"comment_post <- POST(comment_query, authenticate(user, password))"' _newline 
  `"if (status_code(comment_post)==404) {  "' _newline 
  `"print(paste("Target interview", val," was not found")) "' _newline   
 `"  count404= count404+1 "' _newline 
 `"}  "' _newline 
 `"if (status_code(comment_post)==406) {  "' _newline 
 `"print(paste("Target interview", val," is in status that was not ready to comment on variable or question was not found"))  "' _newline   
 `"  count406= count406+1 "' _newline 
 `"}  "' _newline 
`" counter= counter+1 "' _newline 
`"if (counter==length(`id')) { "' _newline 
`" count200= length(`id')-count406-count404"' _newline 
`"print(paste(count200,"interviews have been successfully commented on")) "' _newline   
`"print(paste(count406,"interviews have been in status that was not ready to be commented on or question was not found")) "' _newline   
`"print(paste(count404,"interviews have been not found")) "' _newline   
`"  Sys.sleep(5) "' _newline 
`"}"' _newline 
`"}"'	_newline;
                
 #d cr
 file close rcode 



tempfile error_message //ERROR MESSAGES FROM R WILL BE STORED HERE
timer clear
timer on 1
shell "`rpath'/R" --vanilla <"`c(pwd)'/varcomm.R" 2>`error_message' 
timer off 1	
		qui timer list 1
		if `r(t1)'<=2 {
		noi dis as error "Whoopsa! That was surprisingly fast."
		noi dis as error "Please check if the variables have been commented on." 
		noi dis as error "If not, have a look at {help sursol_varcomm##debugging:debugging information} in the help file."
		noi dis as error "You might need to install some R packages manually since Stata has no administrator rights to install them."
		}

//DISPLAY ANY ERRORS PRODUCED IN THE R SCRIPT
		noi di as result _n
		noi di as  result "{ul:Warnings & Error messages displayed by R:}"
		noi type `error_message'
}

qui capt rm "`c(pwd)'/varcomm.R"
qui capt rm "`c(pwd)'/.Rhistory" 


 end

