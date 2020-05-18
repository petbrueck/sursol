capture program drop sursol_export

program sursol_export 

syntax anything, SERver(string) USER(string) PASSword(string) [Rpath(string)]  [LASTVersion] ///
[VERSIONS(string)] [FORMAT(string)] [STATA] [TABULAR] [SPSS] [PARAdata] [BINary] [DDI] [NOZIP]  [STATus(string)] [STARTdate(string)] [ENDdate(string)] [ZIPDIR(string)] ///
[DIRectory(string)]  [dropbox(string)]


**SAVE CURRENT WORKING DIRECTORY
local currdir `c(pwd)'		


//CHECK OPTIONS CORRECTLY SPECIFIED 
************************************************************************************************
**VERSIONS
if length("`versions'")>0 & length("`lastversion'")>0 {
noi dis as error _n "Attention. You specified both {help sursol_export##versions:versions(numlist)} and {help sursol_export##lastversion:lastversion}.
noi dis as error "These two options exclude each other. Please check."
ex 601
}


if length("`versions'")>0 {
  loc versions=subinstr("`versions'",","," ",.)
  loc versions=itrim("`versions'")
  loc versions=subinstr("`versions'"," ",",",.)
  loc newversions `versions'
}
else if length("`versions'")==0 & length("`lastversion'")==0 loc newversions ""all""
else if length("`versions'")==0 & length("`lastversion'")>0 loc newversions ""last""


**ZIP DIR
if length("`zipdir'")>0 & length("`nozip'")>0 {
noi disp as error _n "Attention. Zip directory was specified but option ""NOZIP"" enforced. Please check." 
ex 601
}

**GIVE WARNING IF PROTOCOL OF URL NOT GIVEN 
if strpos("`server'","http")==0 {
noi dis as error _n "Attention. There is no protocol specified in {help sursol_export##server:server({it:url})}"
noi dis as error "The command will not work if the URL is not specified correctly. Let's give it a try nevertheless..."
}


**CHECK START & END-DATE 
foreach x in startdate enddate {
if missing( date("``x''", "YMD")) & length("``x''")>0 {
noi dis as error "Option {help sursol_export##`x':`x'(string)} needs to be specified in UTC format YYYY-MM-DD. "
noi dis as error "Please check."
ex 198
}
}

**DIRECTORY
if length("`directory'")>0 {
mata : st_numscalar("OK", direxists("`directory'"))
if scalar(OK)==0 {
noi dis as error _n "Attention. Directory: ""`directory'"" not found."
noi dis as error  "Please correctly specify {help sursol_export##sursol_export_directory:directory(string)}"
ex 601
}

foreach x in "//" "\\\" "\\" "\\" "\" {
loc directory=subinstr("`directory'","`x'","/",.)
loc zipdir=subinstr("`zipdir'","`x'","/",.)
}

}


**DROPBOX & DIRECTORY
if length("`directory'")>0 & length("`dropbox'")>0 {
noi dis as error _n "Attention. You specified both {help sursol_export##sursol_export_directory:directory({it:string})} and {help sursol_export##dropbox:dropbox({it:access_token})}.
noi dis as error "These two options exclude each other. Please check."
ex 601
}


**DROPBOX
if length("`dropbox'")>0 & length("`dropbox'")<64 {
noi dis as error _n "Attention. Your Dropbox Access Token has not 64 characters. It might be wrong."
noi dis as error "But let's try it nevertheless... "
}



	//CREATE A LOCAL THAT CONTAINS ALL DATASETS THAT SHOULD BE DOWNLOADED 
	loc datasets ""
	foreach x in tabular spss stata paradata ddi binary {
	
	if "``x''"!="" {
		local datasets `"`datasets' "," "`x'" "'
		}
	}
	loc datasets=subinstr(`"`datasets'"',`"",""',"",1)
	loc datasets=subinstr(`"`datasets'"',  `"",""', ",",.)
	if length(`"`datasets'"')==0 {
		noi dis as error "Attention. You have not specified any dataset that you want to export"
		noi dis as error "Please specify as option any of the following:"
		noi dis as error "'spss', 'stata', 'tabular', 'paradata', 'ddi' and/or 'binary'."
		noi dis as error "For more information see {help sursol_export##sursol_export_options:sursol export options}."
		ex 198
		}





if length("`nozip'")==0 loc zip="yes"
else if length("`nozip'")>0 loc zip="no"


if length("`rpath'")==0 {
if strpos(lower("`c(os)'"),"window")==0 {
noi dis as error _n "Attention.  You are not using Windows as an operating system."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
ex 198
}


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
noi dis as error  "Please correctly specify the path of your R.exe using the option {help sursol_export##sursol_export_rpath:rpath(string)}"
ex 601
}
}


//USE CURRENT DIRECTORY TO CREATE R FILE 
qui capt rm "`currdir'/export.R"
qui capt rm "`currdir'/.Rhistory" 



quietly: file open rcode using "`currdir'/export.R", write replace 
#d ;
quietly: file write rcode  

`" server <- "`server'" "' _newline
`"user= "`user'"							 "' _newline
`"password="`password'" "' _newline
`"questionnaire_name="`1'" "' _newline
`"versions<- c(`newversions') "' _newline
                `"directory <-  "`directory'"  "' _newline
                `"datasets <- c(`datasets')   "' _newline
                `"interview_status <- "`status'" "' _newline
                `"start_date <- "`startdate'" "' _newline
                `"end_date <-"`enddate'" "' _newline
                `"unzip<-"`zip'" "' _newline
                `"zip_directory <- "`zipdir'"   "' _newline
                `"dropbox_token <- "`dropbox'"   "' _newline
                _newline
		`"	packages<- c("tidyverse", "stringr","lubridate", "jsonlite","httr","dplyr","date")        "'  _newline
`"	for (newpack in packages) {    "'  _newline
`"	 if(newpack %in% rownames(installed.packages()) == FALSE) {install.packages(newpack, repos = 'https://cloud.r-project.org/', dep = TRUE)}    "'  _newline
`"	 if(newpack %in% rownames(installed.packages()) == FALSE) {     "'  _newline
`"	 stop(paste0("Attention. Problems installing package: ",newpack, "Try to install it manually"))          "'  _newline
`"	 }    "'  _newline
`"	}    "'  _newline
`"	suppressMessages(suppressWarnings(library(stringr)))    "'  _newline
`"	suppressMessages(suppressWarnings(library(jsonlite)))    "'  _newline
`"	suppressMessages(suppressWarnings(library(httr)))    "'  _newline
`"	suppressMessages(suppressWarnings(library(dplyr)))    "'  _newline
`"	suppressMessages(suppressWarnings(library(lubridate)))    "'  _newline
`"	suppressMessages(suppressWarnings(library(date)))   "'  _newline
`"	Sys.setlocale("LC_TIME", "English")   "'  _newline
`"	server_url<-server     "'  _newline
`"	     "'  _newline
`"	serverCheck <- try(http_error(server_url), silent = TRUE)     "'  _newline
`"	if (class(serverCheck) == "try-error") {     "'  _newline
`"	  stop(paste0("The following server does not exist. Check internet connection or the server name:", server_url))     "'  _newline
`"	       "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	for (x in c("user", "password", "server", "datasets", "directory", "questionnaire_name")) {     "'  _newline
`"	  if (!is.character(get(x))) {     "'  _newline
`"	    stop(paste("Check that the parameters in the data are the correct data type (e.g. String?). Look at:",x))     "'  _newline
`"	         "'  _newline
`"	  }     "'  _newline
`"	       "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`" ##STORAGE TYPE "'  _newline
`" if (nchar(dropbox_token)>0) {  "'  _newline
`" access_token <- dropbox_token  "'  _newline
`" storage_type <- "Dropbox"  "'  _newline
`" } else {  "'  _newline
`"   access_token <- ""  "'  _newline
`"   storage_type <- ""  "'  _newline
`" }  "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	if (((interview_status %in% c("Deleted", "Restored" , "Created", "SupervsiorAssigned","InterviewerAssigned",     "'  _newline
`"	                                      "ReadyForInterview" , "SentToCapi", "Restarted" , "Completed", "RejectedBySupervisor" ,     "'  _newline
`"	                              "ApprovedBySupervisor", "RejectedByHeadquarters" , "ApprovedByHeadquarters")) == FALSE) && interview_status!="") {     "'  _newline
`"	  stop(paste("Interview status has been not correctly specified:", interview_status,". Please adjust! Attention: Case sensitive"))     "'  _newline
`"	       "'  _newline
`"	  }     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	if (nchar(directory)>0 & !dir.exists(directory) ) {     "'  _newline
`"	  stop(paste0("Data folder does not exist in the expected location: ",directory))     "'  _newline
`"	}     "'  _newline
`"	if (!dir.exists(zip_directory) && zip_directory!="") {     "'  _newline
`"	  stop(paste("ZIP folder does not exist in the expected location: ", directory))     "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	api_URL <- sprintf("%s/api/v1", server)     "'  _newline
`"	     "'  _newline
`"	query <- paste0(api_URL, "/questionnaires")     "'  _newline
`"	     "'  _newline
`"	data <- GET(query, authenticate(user, password),     "'  _newline
`"	            query = list(limit = 40, offset = 1))     "'  _newline
`"	     "'  _newline
`"	if (status_code(data) == 200) {     "'  _newline
`"	       "'  _newline
`"	  qnrList <- fromJSON(content(data, as = "text"), flatten = TRUE)     "'  _newline
`"	       "'  _newline
`"	  if (qnrList\$TotalCount <= 40) {     "'  _newline
`"	    qnrList_all <- as.data.frame(qnrList\$Questionnaires) %>% arrange(Title, Version)     "'  _newline
`"	         "'  _newline
`"	  }    "'  _newline
`"	   if (qnrList\$TotalCount <= 80) {                                                                                                                                                               "'  _newline
`"	     qnrList_all <- as.data.frame(qnrList\$Questionnaires)    "'  _newline
`"	       data2 <- GET(query, authenticate(user, password),    "'  _newline
`"	                  query = list(limit = 40, offset = 2))       "'  _newline
`"	     qnrList2 <- fromJSON(content(data2, as = "text"), flatten = TRUE)    "'  _newline
`"	        qnrList_all <- bind_rows(qnrList_all,    "'  _newline
`"	                              as.data.frame(qnrList2\$Questionnaires)) %>% arrange(Title, Version)    "'  _newline
`"	       "'  _newline
`"	   } else {    "'  _newline
`"	     qnrList_all <- as.data.frame(qnrList\$Questionnaires)    "'  _newline
`"	         data2 <- GET(query, authenticate(user, password),    "'  _newline
`"	                  query = list(limit = 40, offset = 2))    "'  _newline
`"	         qnrList2 <- fromJSON(content(data2, as = "text"), flatten = TRUE)    "'  _newline
`"	         "'  _newline
`"	     qnrList_all <- bind_rows(qnrList_all,    "'  _newline
`"	                              as.data.frame(qnrList2\$Questionnaires)) %>% arrange(Title, Version)    "'  _newline
`"	         "'  _newline
`"	    data3 <- GET(query, authenticate(user, password),    "'  _newline
`"	                query = list(limit = 40, offset = 3))    "'  _newline
`"	       "'  _newline
`"	   qnrList3 <- fromJSON(content(data3, as = "text"), flatten = TRUE)    "'  _newline
`"	       "'  _newline
`"	   qnrList_all <- bind_rows(qnrList_all,    "'  _newline
`"	                            as.data.frame(qnrList3\$Questionnaires)) %>% arrange(Title, Version)    "'  _newline
`"	 }                "'  _newline
`"	} else if (status_code(data) == 401) {      "'  _newline
`"	  stop("Incorrect username or password. Check login credentials for API user")     "'  _newline
`"	} else {     "'  _newline
`"	  stop(paste0("Encountered issue with status code ", status_code(data)))     "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	     "'  _newline
`"	  questionnaire_name_up <- str_to_upper(gsub("\\s", "", questionnaire_name))    "'  _newline
`"	  qnrList_all\$Title <- str_to_upper(gsub("\\s", "", qnrList_all\$Title))     "'  _newline
`"	     "'  _newline
`"	if (questionnaire_name_up %in% qnrList_all\$Title) {     "'  _newline
`"	  qxid<-(unique(qnrList_all\$QuestionnaireId[qnrList_all\$Title == questionnaire_name_up]))     "'  _newline
`"	  qxvar<-(unique(qnrList_all\$Variable[qnrList_all\$Title == questionnaire_name_up]))     "'  _newline
`"	} else if (questionnaire_name_up == "") {     "'  _newline
`"	  stop("Please provide the name of the questionnaire.")     "'  _newline
`"	       "'  _newline
`"	} else {     "'  _newline
`"	  stop("Please check the questionnaire name.")     "'  _newline
`"	       "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	questionnaire_identity <-gsub("-", "", qxid)     "'  _newline
`"	     "'  _newline
`"	if (interview_status=="") {     "'  _newline
`"	  int_status="All"     "'  _newline
`"	}else{     "'  _newline
`"	  int_status=interview_status   "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	if (start_date=="") {     "'  _newline
`"	  start_code=""     "'  _newline
`"	} else {     "'  _newline
`"	  start_code=paste("from=", start_date, "&",sep = "")     "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	if (end_date=="")  {     "'  _newline
`"	  end_code=""     "'  _newline
`"	} else {     "'  _newline
`"	  end_code=paste("to=", end_date, sep = "")     "'  _newline
`"	}     "'  _newline
`"	     "'  _newline
`"	 versions_server<-(unique(qnrList_all\$Version[qnrList_all\$Title == questionnaire_name_up]))     "'  _newline
`"	if ("all" %in% str_to_lower(versions)) {     "'  _newline
`"	versions_download<-versions_server       "'  _newline
`"	} else if ("last" %in% str_to_lower(versions)) {     "'  _newline
`"	versions_download <- max(versions_server)     "'  _newline
`"	 }  else {     "'  _newline
`"	 versions_download <- versions     "'  _newline
`"	 }     "'  _newline
`"	    "'  _newline
`"	    "'  _newline
`"	##THE BIG LOOP   "'  _newline
`"	i <- 1     "'  _newline
`"	for (datatype in datasets) {     "'  _newline
`"	  for (val in versions_download) {     "'  _newline
`"	       "'  _newline
`"	    if (val %in% versions_server ==FALSE) stop(paste0("Version ",val," of ",questionnaire_name," was not found on the server.", "Check your versions specified in versions(numlist)"))     "'  _newline
`"	     "'  _newline
`"	    questionnaire_version<-paste(c(questionnaire_identity,"\$",val), collapse = "")     "'  _newline
`"	       "'  _newline
`"	    ##CREATE FILENAME & PATH   "'  _newline
`"	    if (datatype %in% c("stata", "ddi","spss")) dataname <- paste("_",toupper(datasets[i]), collapse ="",sep="")  else dataname <- paste("_",str_to_title(datasets[i]), collapse ="",sep="")      "'  _newline
`"	   "'  _newline
`"	    Filename <-paste(c(qxvar,"_", val, dataname,"_", int_status,".zip"), collapse = "")     "'  _newline
`"	         "'  _newline
`"	    fn<- paste(c(directory, "//", Filename), collapse = "")     "'  _newline
`"	    if (file.exists(fn)) file.remove(fn)     "'  _newline
`"	         "'  _newline
`"	       "'  _newline
`"	       "'  _newline
`"	    ##QUERIES TO DOWNLOAD   "'  _newline
`"	    exportapi_url <- sprintf("%s/api/v2/export", server)     "'  _newline
`"	       "'  _newline
`"	    ##START    "'  _newline
`"	    #CREATE THE BODY   "'  _newline
`"	    body_request <- list(ExportType=datatype,    "'  _newline
`"	                         QuestionnaireId=questionnaire_version,   "'  _newline
`"	                         InterviewStatus=int_status,  "'  _newline
`"				From=start_date,	 "'  _newline
`"				To=end_date, 	 "'  _newline
`"				AccessToken=access_token, 	 "'  _newline
`"				StorageType=storage_type	 "'  _newline
`" 				)   "'  _newline
`"	       "'  _newline
`"	    ##START EXPORT IS SIMPLY API URL V2/EXPORT   "'  _newline
`"	    ##START DATA GENERATION    "'  _newline
`"	    gen_data <- POST(exportapi_url, authenticate(user, password), body=body_request, encode = "json")     "'  _newline
`"	       "'  _newline
`"	    ##IF SUCCESSFULL GET JOB ID & PRINT TO USER   "'  _newline
`"	    if (status_code(gen_data) %in% c(200,201))  {       "'  _newline
`"	      if (datatype=="paradata")  dat <-"Para"  else dat<- toupper(datatype)     "'  _newline
`"	           "'  _newline
`"	    print(paste0("Requesting ",dat, " data for ",     "'  _newline
`"	            questionnaire_name, " VERSION ", val,     "'  _newline
`"	            " to be compiled on server."))     "'  _newline
`"	       "'  _newline
`"	    ##URL FOR ALL EXPORT PROCESSES AS IT CONTAINS THE JOB ID   "'  _newline
`"	    exportjobid_url <- headers(gen_data)\$location   "'  _newline
`"	   "'  _newline
`"	    }  else if (status_code(gen_data)==400) {   "'  _newline
`"	      stop(paste0("Questionnaire ID is malformed.", "Request to compile ",dat, " data for ",     "'  _newline
`"	                  questionnaire_name, " VERSION ", val,     "'  _newline
`"	                  "has been not successfull."))     "'  _newline
`"	      }     else if  (status_code(gen_data)==404) {   "'  _newline
`"	           "'  _newline
`"	        stop(paste0("Questionnaire was not found.", "Request to compile ",dat, " data for ",     "'  _newline
`"	                    questionnaire_name, " VERSION ", val,     "'  _newline
`"	                    "has been not successfull."))     "'  _newline
`"	           "'  _newline
`"	      } else {     "'  _newline
`"	        "'  _newline
`"	      stop(paste0("The request to compile ",dat, " data for ",     "'  _newline
`"	                  questionnaire_name, " VERSION ", val,     "'  _newline
`"	                  "has been not successfull."))     "'  _newline
`"	         "'  _newline
`"	    }   "'  _newline
`"	         "'  _newline
`"	       "'  _newline
`"	       "'  _newline
`"	         "'  _newline
`"	         "'  _newline
`"	         "'  _newline
`"	    ##NOW WAIT TILL IT IS SUCCESFULL   "'  _newline
`"	    repeat {     "'  _newline
`"	         "'  _newline
`"	      ##CHECK DETAILS OF EXPORT PROCESS    "'  _newline
`"	      check_ready <- GET(exportjobid_url, authenticate(user, password))      "'  _newline
`"	      content<-content(check_ready)     "'  _newline
 `"			Sys.sleep(2)      "'  _newline
`"	   "'  _newline
`"	   "'  _newline
`"	      #CHECK THE STATUS    "'  _newline
`"	         "'  _newline
`"	      if (content\$ExportStatus == "Created") {     "'  _newline
`"	        print(paste0("Export files have been created"))     "'  _newline
`"	        Sys.sleep(2)        "'  _newline
`"	      }     "'  _newline
`"	           "'  _newline
`"	      if (content\$ExportStatus == "Fail") {     "'  _newline
`"             if (nchar(dropbox_token)>0) stop("The export process has failed. Try again or check the server or Dropbox Access.")      "'  _newline
`"	        stop("The export process has failed. Try again or check the server.")     "'  _newline
`"	             "'  _newline
`"	      }     "'  _newline
`"	           "'  _newline
`"	      if (content\$ExportStatus == "Canceled") {     "'  _newline
`"	        stop("The export process has been canceled by a user. Try again or check the server.")     "'  _newline
`"	      }    "'  _newline
`"	         "'  _newline
`"	      if (content\$ExportStatus == "Running") {     "'  _newline
`"	        print(paste0("Data is currently being generated. Progress: ",     "'  _newline
`"	                     content\$Progress, '%'))     "'  _newline
`"	        Sys.sleep(2)     "'  _newline
`"	      }    "'  _newline
`"	       "'  _newline
`"	         "'  _newline
`"	      if (content\$ExportStatus=="Completed")  {     "'  _newline
`"            ##STOP THE LOOP IF STORAGE TYPE NOT DOWNLOAD  "'  _newline
`"            if (nchar(dropbox_token)>0) { "'  _newline
`"              print(paste0("Request successfull!")) "'  _newline
`"              print(paste0("Data files are now being pushed to the Dropbox")) "'  _newline
`"              Sys.sleep(1) "'  _newline
`"             break "'  _newline
`"            } "'  _newline
`"	        print("Data is currently being downloaded..")     "'  _newline
`"	        ##THE DOWNLOAD REQUEST, WHICH IS SAVED IN DETAIL REQUEST   "'  _newline
`"	        download_data <- GET(content\$Links\$Download, authenticate(user, password))     "'  _newline
 `"			Sys.sleep(1)      "'  _newline
`"	           "'  _newline
`"	        #IF REDIRECT NECESSARY   "'  _newline
`"	        if (download_data\$url!=content\$Links\$Download) {   "'  _newline
`"	        download_data <- GET(download_data\$url)    "'  _newline
`"	        }   "'  _newline
`"	           "'  _newline
`"              if (status_code(download_data) %in% c(400,404)) {   "'  _newline
`"                      stop("Downloading the data has failed. Try again or check the server.")      "'  _newline
`"                    }  "'  _newline
`"	        #START WRITING THE DATA IN BINARY MODE TO DIRECTORY   "'  _newline
`"	        filecon <- file(file.path(directory, Filename), "wb")    "'  _newline
`"	        writeBin(download_data\$content, filecon)      "'  _newline
`"	        Sys.sleep(1)   "'  _newline
`"	        close(filecon)     "'  _newline
`"	             "'  _newline
`"	        if ("yes" %in% str_to_lower(unzip)) {     "'  _newline
`"	        if (zip_directory=="") {     "'  _newline
`"	         zip_path<- paste0(directory,"//",     "'  _newline
`"	                              qxvar,"_",val)       "'  _newline
`"	          if (datatype=="binary") zip_path<- paste0(directory, qxvar, "_",  val,"//Binary")       "'  _newline
`"	          if (datatype=="ddi") zip_path<- paste0(directory, qxvar, "_",  val,"//DDI")       "'  _newline
`"	        } else  {     "'  _newline
`"	        zip_path<- paste0(zip_directory,"//",     "'  _newline
`"	                           qxvar,"_",val)       "'  _newline
`"	      if (datatype=="binary") zip_path<- paste0(zip_directory,"//", qxvar, "_",  val,"//Binary")     "'  _newline
`"	      if (datatype=="ddi") zip_path<- paste0(zip_directory,"/", qxvar, "_",  val,"//DDI")     "'  _newline
`"	        }     "'  _newline
`"	      if (datatype=="binary") {     "'  _newline
`"	         unlink(zip_path, recursive = TRUE)     "'  _newline
`"	                dir.create(zip_path)     "'  _newline
`"	                       }     "'  _newline
`"	        zip_name<- paste0(directory,"//",     "'  _newline
`"	                          Filename)     "'  _newline
`"	        unzip(zip_name,exdir = zip_path)     "'  _newline
`"	        print(paste0("Data files successfully unzipped into folder: ", zip_path))     "'  _newline
`"	        }     "'  _newline
`"	        break     "'  _newline
`"	      }     "'  _newline
`"	           "'  _newline
`"	           "'  _newline
`"	    }     "'  _newline
`"	         "'  _newline
`"	  }     "'  _newline
`"	  i <- i + 1     "'  _newline
`"	 }    "'  _newline ;
                
                
                #d cr
                
                file close rcode 

		//EXECUTE THE COMMAND

		tempfile error_message //ERROR MESSAGES FROM R WILL BE STORED HERE

		timer clear
		timer on 1
                shell "`rpath'/R" --vanilla <"`currdir'/export.R" 2>`error_message' 
		timer off 1	
		qui timer list 1
		if `r(t1)'<=3 {
		dis as error "Whoopsa! That was surprisingly fast."
		dis as error "Please check if the data was downloaded correctly." 
		dis as error "If not, have a look at {help sursol_export##sursol_export_debugging:debugging information} in the help file."
		dis as error "You might need to install some R packages manually since Stata has no administrator rights to install them."
		}
		
		//DISPLAY ANY ERRORS PRODUCED IN THE R SCRIPT
		di as result _n
		di as  result "{ul:Warnings & Error messages displayed by R:}"
		type `error_message'
		
                qui capt rm "`currdir'/export.R"
                qui capt rm "`currdir'/.Rhistory" 
                qui  cd "`currdir'"
                
                end	
                
                
