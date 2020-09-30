*! version 20.05 May 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org


capture program drop sursol_userreport

program sursol_userreport 

syntax, DIRectory(string)  SERver(string) HQUSER(string) HQPASSword(string) [Rpath(string)]  [XLSX] [TAB] [CSV] [archived]



**SAVE CURRENT WORKING DIRECTORY
local currdir `c(pwd)'		


//CHECK OPTIONS CORRECTLY SPECIFIED 
************************************************************************************************

**GIVE WARNING IF PROTOCOL OF URL NOT GIVEN 
if strpos("`server'","http")==0 {
noi dis as error _n "Attention. There is no protocol specified in {help sursol_userreport##server:server({it:url})}"
noi dis as error "The command will not work if the URL is not specified correctly. Let's give it a try nevertheless..."
}


**DIRECTORY
mata : st_numscalar("OK", direxists("`directory'"))
if scalar(OK)==0 {
noi dis as error _n "Attention. Directory: ""`directory'"" not found."
noi dis as error  "Please correctly specify {help sursol_userreport##sursol_userreport_directory:directory(string)}"
ex 601
}

foreach x in "//" "\\\" "\\" "\\" "\" {
loc directory=subinstr("`directory'","`x'","/",.)
}






	//CHECK IN WHICH TYPE IT SHALL BE FORMATTED & EXPORTED
	loc datasets ""
	foreach x in xlsx tab csv {
	if "``x''"!="" 	local datasets `"`datasets' "," "`x'" "'
	}
	loc datasets=subinstr(`"`datasets'"',`"",""',"",1)
	loc datasets=subinstr(`"`datasets'"',  `"",""', ",",.)
	if length(`"`datasets'"')==0 {
		noi dis as error "Attention. You have not specified in which format you want to download the Interviewer Report."
		noi dis as error "Please specify as option any of the following:"
		noi dis as error "'xlsx', 'csv', 'tab'"
		noi dis as error "For more information see {help sursol_userreport##sursol_userreport_options: sursol userreport options}."
		ex 198
		}

if length("`rpath'")==0 {
if strpos(lower("`c(os)'"),"window")==0 {
noi dis as error _n "Attention.  You are not using Windows as an operating system."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_userreport##sursol_userreport_rpath:rpath(string)}"
ex 198
}


if strpos("`c(machine_type)'","64")>0 loc bit="x64" 
if strpos("`c(machine_type)'","32")>0 loc bit="x32" 

mata : st_numscalar("OK", direxists("C:/Program Files/R"))
if scalar(OK)==0 {
noi dis as error _n "Attention. No R folder in ""C:/Program Files/"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_userreport##sursol_userreport_rpath:rpath(string)}"
ex 601
}



	local folderstructure: dir "C:/Program Files/R" dirs "*", respectcase 
	local folderstructure : list sort folderstructure
	local length : word count `folderstructure'

	if `length'>1 {
	noi dis as error _n "Attention, two versions of R have been found:"
	loc i=1
	foreach x of loc folderstructure {
	noi dis as error "`x'" 
	if `length'==`i' {
	noi dis as result _n "Version `x' of R will be used to download interviewers report."
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
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_userreport##sursol_userreport_rpath:rpath(string)}"
ex 601
}

if scalar(OK)==0 {
noi dis as error _n "Attention. No bin folder in ""C:/Program Files/R//`version'/"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_userreport##sursol_userreport_rpath:rpath(string)}"
ex 601
}

mata : st_numscalar("OK", direxists("C:/Program Files/R//`version'/bin//`bit'/"))
if scalar(OK)==0 {
noi dis as error _n "Attention. No `bit' folder in ""C:/Program Files/R//`version'/bin"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_userreport##sursol_userreport_rpath:rpath(string)}"
ex 601
}

capt confirm file "C:/Program Files/R//`version'/bin//`bit'/R.exe"
if _rc {
no dis as error _n "Attention. No R.exe in ""C:/Program Files/R//`version'/bin//`bit'/"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_userreport##sursol_userreport_rpath:rpath(string)}"
ex 601
}
loc rpath="C:/Program Files/R//`version'/bin//`bit'/"

} 


if length("`rpath'")>0 & strpos(lower("`c(os)'"),"window")>0 {
if strpos(lower(strreverse("`rpath'")),"r")==1 {
loc rpath=strreverse(subinstr(strreverse("`rpath'"),"R","",1))
}

if strpos(lower(strreverse("`rpath'")),"exe.r") {
loc rpath=strreverse(subinstr(strreverse("`rpath'"),"exe.R","",1))
}


capt confirm file "`rpath'/R.exe"
if _rc {
no dis as error _n "Attention. No R.exe in ""`rpath'"" was found."
noi dis as error  "Please correctly specify the path of your R.exe using the option {help sursol_userreport##sursol_userreport_rpath:rpath(string)}"
ex 601
}
}


//USE CURRENT DIRECTORY TO CREATE R FILE 
qui capt rm "`currdir'/getreport.R"
qui capt rm "`currdir'/.Rhistory" 



quietly: file open rcode using "`currdir'/getreport.R", write replace 
#d ;
quietly: file write rcode  

`"##GET THE PACKAGES																																															 "'  _newline
`"packages<- c("httr", "openxlsx","stringr")   "'  _newline
`"       "'  _newline
`"for (newpack in packages) {     "'  _newline
`"  if(newpack %in% rownames(installed.packages()) == FALSE) {install.packages(newpack, repos = 'https://cloud.r-project.org/', dep = TRUE)}     "'  _newline
`"  if(newpack %in% rownames(installed.packages()) == FALSE) {      "'  _newline
`"    stop(paste0("Attention. Problems installing package: ",newpack, "Try to install it manually"))           "'  _newline
`"  }     "'  _newline
`"}  "'  _newline
`" "'  _newline
`"suppressMessages(suppressWarnings(library(httr))) "'  _newline
`"suppressMessages(suppressWarnings(library(openxlsx))) "'  _newline
`"suppressMessages(suppressWarnings(library(stringr))) "'  _newline
`" "'  _newline
`" "'  _newline
`"##USER SETTINGS "'  _newline
`"directory <-  "`directory'"   "'  _newline
`"server <- "`server'"  "'  _newline
 `"   ##REPLACE TRAILING SLASH "' _newline 
 `"   if   (str_sub(server,-1,-1) %in% c("/","\"") ) server <-   str_sub(server, end=-2) "' _newline 
`"user= "`hquser'"                                                          "'  _newline
`"password="`hqpassword'"  "'  _newline
`" "'  _newline
`"##ARCHIVED STATUS  "'  _newline
`"if (nchar("`archived'")>0) archived_status <- "true" else archived_status <- "false" "'  _newline
`" "'  _newline 
`"##SERVER CHECK "'  _newline
`"serverCheck <- try(http_error(server), silent = TRUE)      "'  _newline
`"if (class(serverCheck) == "try-error") {      "'  _newline
`"  stop(paste0("The following server does not exist. Check internet connection or the server name:", server))      "'  _newline
`"   "'  _newline
`"}      "'  _newline
`" "'  _newline
`"##URL "'  _newline
`"api_URL <- sprintf("%s/UsersApi/AllInterviewers?draw=2&order[0][column]=1&order[0][dir]=asc&order[0][name]=UserName&start=0&length=20&search[value]=&search[regex]=false&supervisorName=&archived=%s&facet=None&exportType=tab", "'  _newline
`"                   server,archived_status)   "'  _newline
`"##SEND THE REQUEST "'  _newline
`"print("Requesting the Interviewer Report. This can take some seconds.") "'  _newline
`"interviewer_rep_request <-  GET(api_URL,  authenticate(user, password) ) "'  _newline
`" "'  _newline
`"##CHECK ERROR CODES "'  _newline
`" if (status_code(interviewer_rep_request) %in% c(401)) {      "'  _newline
`"  stop(paste0("Authentication not successfull. Check User Name and Password. \n Remember to use a Headquarter user account. NOT API User credentials!")) "'  _newline
`"} else if (status_code(interviewer_rep_request) %in% c(403)) {      "'  _newline
`"  stop(paste0("Authentication not successfull. Check User Name and Password. \n You used the API User credentials! You need to specify Headquarter user account credentials!")) "'  _newline
`"} else if (status_code(interviewer_rep_request) %in% c(404)) {      "'  _newline
`"stop(paste0("Can't access the server:",server,"\n Check server URL")) "'  _newline
`"} else if (status_code(interviewer_rep_request) == 200) {      "'  _newline
`" suppressMessages(interviewer_report <- as.data.frame(content(interviewer_rep_request, as="parsed", type="text/tab-separated-values"))) "'  _newline
`" "'  _newline
`" "'  _newline
`" "'  _newline
`"  #WRITE THE FILES, BASED ON OPTION SPECIFIED "'  _newline
`"  if (nchar("`xlsx'")>0) { "'  _newline
`"     write.xlsx(list("Data"=interviewer_report), file = paste0(directory,"/Interviewers.xlsx")  "'  _newline
`"             ) "'  _newline
`"  }  "'  _newline
`"  if (nchar("`csv'")>0) { "'  _newline
`"          write.csv(interviewer_report, file =  paste0(directory,"/Interviewers.csv"), "'  _newline
`"                    na = "") "'  _newline
`"  }   "'  _newline
`"  if (nchar("`tab'")>0) { "'  _newline
`"    write.table(interviewer_report, file = paste0(directory,"/Interviewers.tab"), sep="\t", "'  _newline
`"                row.names=FALSE,  quote = FALSE, na = "") "'  _newline
`"  } "'  _newline
`" "'  _newline
`"} else {  "'  _newline
`"stop(paste0("Something strange is going on. Server is sending an unusal response code: ", status_code(interviewer_rep_request)))  "'  _newline
`"  } "'  _newline ;




            
                
                #d cr
                  
                file close rcode 
		//EXECUTE THE COMMAND

		tempfile error_message //ERROR MESSAGES FROM R WILL BE STORED HERE

		timer clear
		timer on 1
                shell "`rpath'/R" --vanilla <"`currdir'/getreport.R" 2>`error_message' 
		timer off 1	
		qui timer list 1
		if `r(t1)'<=3 {
		dis as error "Whoopsa! That was surprisingly fast."
		dis as error "Please check if the interviewers report was downloaded correctly." 
		dis as error "If not, have a look at {help sursol_userreport##debugging:debugging information} in the help file."
		dis as error "You might need to install some R packages manually since Stata has no administrator rights to install them."
		}
		
		//DISPLAY ANY ERRORS PRODUCED IN THE R SCRIPT
		di as result _n
		di as result "{ul:Warnings & Error messages displayed by R:}"
		type `error_message'
		
                qui capt rm "`currdir'/getreport.R"
                qui capt rm "`currdir'/.Rhistory" 
                qui  cd "`currdir'"


                end	
                
                
