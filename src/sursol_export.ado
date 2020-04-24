capture program drop sursol_export

program sursol_export 

syntax anything, DIRectory(string) SERver(string) USER(string) PASSword(string) [Rpath(string)]  [LASTVersion] [VERSIONS(string)] [FORMAT(string)] [PARAdata] [BINary] [DDI] [NOZIP]  [STATus(string)] [STARTdate(string)] [ENDdate(string)] [ZIPDIR(string)]


local currdir `c(pwd)'		


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


if length("`zipdir'")>0 & length("`nozip'")>0 {
noi disp as error _n "Attention. Zip directory was specified but option ""NOZIP"" enforced. Please check." 
ex 601
}


  
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

*loc directory=subinstr("`directory'","/","//",.)
*loc zipdir=subinstr("`zipdir'","/","//",.)



if length("`paradata'")>0 {
loc paradata="yes"
} 
else if length("`paradata'")==0 loc paradata="no"
if length("`binary'")>0 {
loc binary="yes"
}  
else if length("`binary'")==0 loc binary="no"

if length("`ddi'")>0 {
loc ddi="yes"
}  
else if length("`ddi'")==0 loc ddi="no"

if length("`format'")>0 {
loc  format=itrim(subinstr("`format'",","," ",.)) 
loc newformat ""
foreach x of loc format {
if !inlist(lower("`x'"),"spss","stata","tabular") {
display as error _n "Option ""format(`format')"" incorrectly specified. Can be only one or combination of the following: ""spss"", ""stata"" or ""tabular"". "
ex 198
} 
local newformat `"`newformat' "," "`x'" "'
}

loc newformat=subinstr(`"`newformat'"',`"",""',"",1)
loc newformat=subinstr(`"`newformat'"',  `"",""', ",",.)

} 
 
else if length("`format'")==0 loc  newformat=`""stata""'


if length("`nozip'")==0 loc zip="yes"
else if length("`nozip'")>0 loc zip="no"

foreach x in ".mysurvey.solutions" "//" ":" "https" { 
loc server=subinstr("`server'","`x'","",.)
}


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


                qui capt rm "`directory'/export.R"
                qui capt rm "`directory'/.Rhistory" 



quietly: file open rcode using "`directory'/export.R", write replace 
#d ;
quietly: file write rcode  

`"server <- "`server'" "' _newline
`"user= "`user'"							 "' _newline
`"password="`password'" "' _newline
`"questionnaire_name="`1'" "' _newline
`"versions<- c(`newversions') "' _newline
                `"directory <-  "`directory'"  "' _newline
                `"export_type <- c(`newformat')   "' _newline
                `"paradata="`paradata'" "' _newline
                `"binary="`binary'" "' _newline
		`"ddi="`ddi'" "' _newline
                `"interview_status="`status'" "' _newline
                `"start_date="`startdate'" "' _newline
                `"end_date="`enddate'" "' _newline
                `"unzip<-"`zip'" "' _newline
                `"zip_directory <- "`zipdir'"   "' _newline
                _newline
		
		`"packages<- c("tidyverse", "stringr","lubridate", "jsonlite","httr","dplyr","date")	 "'  _newline
		`"for (newpack in packages) { "'  _newline
		`" if(newpack %in% rownames(installed.packages()) == FALSE) {install.packages(newpack, repos = 'https://cloud.r-project.org/', dep = TRUE)} "'  _newline
		`" if(newpack %in% rownames(installed.packages()) == FALSE) {  "'  _newline
      		`" message("Attention. Problems installing package: ",newpack,"\n", "Try to install it manually")   "'  _newline       
     		 `" Sys.sleep(5)       "'  _newline  
      		`" stop()       "'  _newline
    		`" } "'  _newline
		`"} "'  _newline
		`"library(stringr) "'  _newline
		`"library(jsonlite) "'  _newline
		`"library(httr) "'  _newline
		`"library(dplyr) "'  _newline
		`"library(lubridate) "'  _newline								                
		`"library(date)"'  _newline	
		
		`"Sys.setlocale("LC_TIME", "English")"' _newline

                `" if (((tolower(unzip) %in% c("no")) == TRUE) & nchar(zip_directory)>0) {  	"' _newline
                `"  message("Attention. Zip Directory has been specified but UNZIP was not requested.")  	"' _newline
                `"  Sys.sleep(5)  	"' _newline
                `"  stop()  	"' _newline
                `"}   	"' _newline
                
                
                `"server_url<-sprintf("https://%s.mysurvey.solutions", server)  "'    _newline
                `"  "'    _newline
                `"serverCheck <- try(http_error(server_url), silent = TRUE)  "'    _newline
                `"if (class(serverCheck) == "try-error") {  "'    _newline
                `"  message("The following server does not exist. Check internet connection or the server name:",  "'    _newline
                `"       "\n", server_url)  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"    "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline 
                `"for (x in c("user", "password", "server", "export_type", "directory", "questionnaire_name")) {  "'    _newline
                `"  if (!is.character(get(x))) {  "'    _newline
                `"    message(paste("Check that the parameters in the data are the correct data type (e.g. String?). Look at:",x))  "'    _newline
                `"    Sys.sleep(5)  "'    _newline
                `"    stop()  "'    _newline
                `"      "'    _newline
                `"  }  "'    _newline
                `"    "'    _newline
                `"  if (nchar(get(x)) == 0) {  "'    _newline
                `"    message(paste("The following parameter is not specified in the program:", x))  "'    _newline
                `"    Sys.sleep(5)  "'    _newline
                `"    stop()  "'    _newline
                `"  }  "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"if (((interview_status %in% c("Deleted", "Restored" , "Created", "SupervsiorAssigned","InterviewerAssigned",  "'    _newline
                `"                                      "ReadyForInterview" , "SentToCapi", "Restarted" , "Completed", "RejectedBySupervisor" ,  "'    _newline
                `""ApprovedBySupervisor", "RejectedByHeadquarters" , "ApprovedByHeadquarters")) == FALSE) && interview_status!="") {  "'    _newline
                `"  message(paste("Interview status has been not correctly specified:", interview_status,". Please adjust! Attention: Case sensitive"))  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"    "'    _newline
                `"  }  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"if (!dir.exists(directory)) {  "'    _newline
                `"  message("Data folder does not exist in the expected location: ", directory)  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"}  "'    _newline
                `"if (!dir.exists(zip_directory) && zip_directory!="") {  "'    _newline
                `"  message("ZIP folder does not exist in the expected location: ", directory)  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"api_URL <- sprintf("https://%s.mysurvey.solutions/api/v1", server)  "'    _newline
                `"  "'    _newline 
                `"query <- paste0(api_URL, "/questionnaires")  "'    _newline
                `"  "'    _newline
                `"data <- GET(query, authenticate(user, password),  "'    _newline
                `"            query = list(limit = 40, offset = 1))  "'    _newline
                `"  "'    _newline
                `"if (status_code(data) == 200) {  "'    _newline
                `"    "'    _newline
                `"  qnrList <- fromJSON(content(data, as = "text"), flatten = TRUE)  "'    _newline
                `"    "'    _newline
                `"  if (qnrList\$TotalCount <= 40) {  "'    _newline
                `"    qnrList_all <- as.data.frame(qnrList\$Questionnaires) %>% arrange(Title, Version)  "'    _newline
                `"      "'    _newline
                `"  } "' _newline



`"   if (qnrList\$TotalCount <= 80) {																				 "' _newline	
`"     qnrList_all <- as.data.frame(qnrList\$Questionnaires) "' _newline
`"       data2 <- GET(query, authenticate(user, password), "' _newline
`"                  query = list(limit = 40, offset = 2))    "' _newline
`"     qnrList2 <- fromJSON(content(data2, as = "text"), flatten = TRUE) "' _newline
`"        qnrList_all <- bind_rows(qnrList_all, "' _newline
`"                              as.data.frame(qnrList2\$Questionnaires)) %>% arrange(Title, Version) "' _newline
`"    "' _newline
`"   } else { "' _newline
`"     qnrList_all <- as.data.frame(qnrList\$Questionnaires) "' _newline
`"         data2 <- GET(query, authenticate(user, password), "' _newline
`"                  query = list(limit = 40, offset = 2)) "' _newline
`"         qnrList2 <- fromJSON(content(data2, as = "text"), flatten = TRUE) "' _newline
`"      "' _newline
`"     qnrList_all <- bind_rows(qnrList_all, "' _newline
`"                              as.data.frame(qnrList2\$Questionnaires)) %>% arrange(Title, Version) "' _newline
`"      "' _newline
`"    data3 <- GET(query, authenticate(user, password), "' _newline
`"                query = list(limit = 40, offset = 3)) "' _newline
`"    "' _newline
`"   qnrList3 <- fromJSON(content(data3, as = "text"), flatten = TRUE) "' _newline
`"    "' _newline
`"   qnrList_all <- bind_rows(qnrList_all, "' _newline
`"                            as.data.frame(qnrList3\$Questionnaires)) %>% arrange(Title, Version) "' _newline
`" }		 "' _newline




                `"} else if (status_code(data) == 401) {   "'    _newline
                `"  message("Incorrect username or password. Check login credentials for API user")  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"} else {  "'    _newline
                `"  message("Encountered issue with status code ", status_code(data))  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"}  "'    _newline 
                `"  "'    _newline
                `"  "'    _newline
                `"  "'    _newline
                `"  questionnaire_name_up <- str_to_upper(gsub("\\s", "", questionnaire_name)) "'    _newline
                `"  qnrList_all\$Title <- str_to_upper(gsub("\\s", "", qnrList_all\$Title))  "'    _newline
                `"  "'    _newline
                `"if (questionnaire_name_up %in% qnrList_all\$Title) {  "'    _newline
                `"  qxid<-(unique(qnrList_all\$QuestionnaireId[qnrList_all\$Title == questionnaire_name_up]))  "'    _newline
		`"  qxvar<-(unique(qnrList_all\$Variable[qnrList_all\$Title == questionnaire_name_up]))  "'    _newline
                `"} else if (questionnaire_name_up == "") {  "'    _newline
                `"  message("Error: Please provide the name of the questionnaire.")  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"    "'    _newline
                `"} else {  "'    _newline
                `"  message("Error: Please check the questionnaire name.")  "'    _newline
                `"  Sys.sleep(5)  "'    _newline
                `"  stop()  "'    _newline
                `"    "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
                `"questionnaire_identity <-gsub("-", "", qxid)  "'    _newline
                `"datasets=export_type  "'    _newline
                `"  "'    _newline
                `"if ("yes" %in%  as.list(tolower(paradata))) {  "'    _newline
                `"  datasets <- append(datasets,"paradata")  "'    _newline
                `"}   "'    _newline
                `"  "'    _newline
                `"if ("yes" %in%  as.list(tolower(binary))) {  "'    _newline
                `"  datasets <- append(datasets,"binary")  "'    _newline
                `"}   "'    _newline
             
		`"if ("yes" %in%  as.list(tolower(ddi))) { "' _newline
		`"datasets <- append(datasets,"DDI") "' _newline
		`"} "' _newline
                `"if (interview_status=="") {  "'    _newline
                `"  int_status=""  "'    _newline
                `"}else{  "'    _newline
                `"  int_status=paste("status=", interview_status, "&", sep = "")  "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
                `"if (start_date=="") {  "'    _newline
                `"  start_code=""  "'    _newline
                `"} else {  "'    _newline
                `"  start_code=paste("from=", start_date, "&",sep = "")  "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
                `"if (end_date=="")  {  "'    _newline
                `"  end_code=""  "'    _newline
                `"} else {  "'    _newline
                `"  end_code=paste("to=", end_date, sep = "")  "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
                `" versions_server<-(unique(qnrList_all\$Version[qnrList_all\$Title == questionnaire_name_up]))  "'    _newline
                `"if ("all" %in% str_to_lower(versions)) {  "'    _newline
                `"versions_download<-versions_server    "'    _newline
                `"} else if ("last" %in% str_to_lower(versions)) {  "'    _newline
                `"versions_download <- max(versions_server)  "'    _newline
		`" }  else {  "' _newline
		`" versions_download <- versions  "' _newline
                `"}  "'    _newline
                `"i <- 1  "'    _newline
                `"for (datatype in datasets) {  "'    _newline
                `"  for (val in versions_download) {  "'    _newline
                 `" if (val %in% versions_server ==FALSE) {  "' _newline
      		 `"  message("Error: Version ", val," of ",questionnaire_name," was not found on the server.")  "' _newline
		 `"  message("Check your versions specified in versions(numlist)")  "' _newline      		 
		`"  Sys.sleep(5)  "' _newline
    		 `"  stop()  "' _newline
   		 `"  } "'  _newline
                `"    questionnaire_version<-paste(c(questionnaire_identity,"\$",val), collapse = "")  "'    _newline
                `"    if (datatype %in% c("stata", "DDI")) dataname <- paste("_",toupper(datasets[i]), collapse ="",sep="") else dataname <- paste("_",str_to_title(datasets[i]), collapse ="",sep="")   "'    _newline
                `"     Filename <-paste(c(qxvar,"_", val, dataname, "_All.zip"), collapse = "")  "'    _newline
                `"      "'    _newline
                `"    fn<- paste(c(directory, "//", Filename), collapse = "")  "'    _newline
                `"    if (file.exists(fn)) file.remove(fn)  "'    _newline
                `"      "'    _newline
                `"    start_query <- sprintf("%s/export/%s/%s/start?%s%s%s",   "'    _newline
                `"                            api_URL, datatype, questionnaire_version,int_status, start_code, end_code)  "'    _newline
                `"      "'    _newline
                `"    details_query <-  sprintf("%s/export/%s/%s/details?%s%s%s",   "'    _newline
                `"                              api_URL,datatype, questionnaire_version,int_status, start_code, end_code)     "'    _newline
                `"      "'    _newline
                `"    download_query <- sprintf("%s/export/%s/%s/?%s%s%s",   "'    _newline
                `"                               api_URL,datatype, questionnaire_version,int_status, start_code, end_code)    "'    _newline
                `"      "'    _newline
                `"      "'    _newline
                `"    gen_data <- POST(start_query, authenticate(user, password))  "'    _newline
                `"    if (status_code(gen_data) == 200) {    "'    _newline
                `"    if (datatype=="paradata")  dat<-"Para"  else dat<- toupper(datatype)  "'    _newline
                `"    "'    _newline
                `"        "'    _newline
                `"    message("Requesting ",dat, " data for ",  "'    _newline
                `"            questionnaire_name, " VERSION ", val,  "'    _newline
                `"            " to be compiled on server.")  "'    _newline
                `"    }  "'    _newline
                `"      "'    _newline
                `"      "'    _newline
                `"    if (is.na(headers(gen_data)\$date)) {  "'    _newline
                `"      start_time <- as.POSIXct(gen_data\$date,  "'    _newline
                `"                               format = "%d %b %Y %H:%M:%S", tz = "GMT")  "'    _newline
                `"    } else {  "'    _newline
                `"      start_time <- as.POSIXct(headers(gen_data)\$date,  "'    _newline
                `"                               format = "%a, %d %b %Y %H:%M:%S", tz = "GMT")  "'    _newline
                `"    }  "'    _newline
                `"      "'    _newline
                `"    start_time <- with_tz(start_time, "UTC")  "'    _newline
                `"      "'    _newline
                `"      "'    _newline
                `"      "'    _newline
                `"      "'    _newline
                `"      "'    _newline
                `"  "'    _newline
                `"    repeat {  "'    _newline
                `"      check_ready <- GET(details_query, authenticate(user, password))  "'    _newline
                `"      content<-content(check_ready)  "'    _newline
                `"      Status <- content\$ExportStatus  "'    _newline
                `"      last_update <- content\$LastUpdateDate  "'    _newline
                `"        "'    _newline
                `"      if (is.na(headers(check_ready)\$date)) {  "'    _newline
                `"        last_update <- as.POSIXct(check_ready\$date,  "'    _newline
                `"                                 format = "%d %b %Y %H:%M:%S", tz = "GMT")  "'    _newline
                `"        } else {  "'    _newline
                `"        last_update <- as.POSIXct(headers(check_ready)\$date,  "'    _newline
                `"                                 format = "%a, %d %b %Y %H:%M:%S", tz = "GMT")  "'    _newline
                `"       }  "'    _newline
                `"      "'    _newline
                `"      last_update <- with_tz(last_update, "UTC")  "'    _newline
                `"        "'    _newline
                `"        "'    _newline
                `"      if (content\$ExportStatus == "Queued") {  "'    _newline
                `"        message("Waiting for export files to be generated...")  "'    _newline
                `"        Sys.sleep(3)     "'    _newline
                `"      }  "'    _newline
                `"        "'    _newline
                `"      if (identical(Status,"FinishedWithErrors")) {  "'    _newline
                `"        message("THERE IS SOMETHING WRONG WITH THE SERVER! PLEASE TRY AGAIN")  "'    _newline
                `"        Sys.sleep(5)  "'    _newline
                `"        stop()  "'    _newline
                `"          "'    _newline
                `"      }  "'    _newline
                `"        "'    _newline
                `"        "'    _newline
                `"      if (content\$ExportStatus == "NotStarted") {  "'    _newline
                `"        if (content\$HasExportedFile == TRUE) {  "'    _newline
                `"          if (is.null(last_update) == TRUE | last_update >= start_time) {  "'    _newline
                `"              content\$ExportStatus <- "Finished"  "'    _newline
                `"          }  "'    _newline
                `"        }  "'    _newline
                `"      }  "'    _newline
                `"        "'    _newline
                `"      if (content\$ExportStatus == "Running") {  "'    _newline
                `"        message(paste0("Data is currently being generated. Percent: ",  "'    _newline
                `"                       content\$RunningProcess['ProgressInPercents'], '%'))  "'    _newline
                `"        Sys.sleep(4)  "'    _newline
                `"      }  "'    _newline
                `"        "'    _newline
                `"        "'    _newline
                `"        "'    _newline
                `"      if (content\$ExportStatus=="Finished")  {  "'    _newline
                `"        message("Data is currently being downloaded..")  "'    _newline
                `"          "'    _newline
                `"        download_data <- GET(download_query, authenticate(user, password))  "'    _newline
                `"        redirectURL <- download_data\$url   "'    _newline
                `"        RawData <- GET(redirectURL) "'    _newline
                `"  "'    _newline
                `"        filecon <- file(file.path(directory, Filename), "wb")   "'    _newline
                `"          "'    _newline
                `"        writeBin(RawData\$content, filecon)   "'    _newline
                `"        Sys.sleep(1)     "'    _newline
                `"          "'    _newline
                `"        close(filecon)  "'    _newline
                `"          "'    _newline
                `"        if ("yes" %in% str_to_lower(unzip)) {  "' _newline
                `"        if (zip_directory=="") {  "'    _newline
                `"         zip_path<- paste0(directory,"//",  "'    _newline
                `"                              qxvar,"_",val)    "'    _newline
                `"          if (datatype=="binary") zip_path<- paste0(directory, qxvar, "_",  val,"//Binary")    "'    _newline
 		`"          if (datatype=="ddi") zip_path<- paste0(directory, qxvar, "_",  val,"//DDI")    "'    _newline
                `"        } else  {  "'    _newline
                `"        zip_path<- paste0(zip_directory,"//",  "'    _newline
                `"                           qxvar,"_",val)    "'    _newline
           	`"	if (datatype=="binary") zip_path<- paste0(zip_directory,"//", qxvar, "_",  val,"//Binary")  "'    _newline
		`"	if (datatype=="ddi") zip_path<- paste0(zip_directory,"//", qxvar, "_",  val,"//DDI")  "'    _newline
                `"        }  "'    _newline
          	`"	if (datatype=="binary") {  "'    _newline
         	`"	   unlink(zip_path, recursive = TRUE)  "'    _newline
          	`"		  dir.create(zip_path)  "'    _newline
         	`"			 }  "'    _newline
                `"        zip_name<- paste0(directory,"//",  "'    _newline
                `"                          Filename)  "'    _newline
                `"        unzip(zip_name,exdir = zip_path)  "'    _newline
                `"        message("Data files successfully unzipped into folder: ", "\n", zip_path)  "'    _newline
                `"        }  "'    _newline
                `"        break  "'    _newline
                `"      }  "'    _newline
                `"        "'    _newline
                `"        "'    _newline
                `"    }  "'    _newline
                `"      "'    _newline
                `"  }  "'    _newline
                `"  i <- i + 1  "'    _newline 
                `" } "' _newline ;
                
                
                #d cr
                
                file close rcode 

                shell "`rpath'/R" --vanilla <"`directory'/export.R" 

                qui capt rm "`directory'/export.R"
                qui capt rm "`directory'/.Rhistory" 
                qui  cd "`currdir'"
                
                end	
                
                