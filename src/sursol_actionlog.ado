*! version 20.05.2  May 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org

capture program drop sursol_actionlog

program sursol_actionlog 

syntax , DIRectory(string) SERver(string) USER(string) PASSword(string) [append] [process] [Rpath(string)] 


local currdir `c(pwd)'		

tempfile error_message //ERROR MESSAGES FROM R WILL BE STORED HERE


*************************************************************************************
**CHECKS
************************************************************************************
  
//CHECK DIRECTORY
mata : st_numscalar("OK", direxists("`directory'"))
if scalar(OK)==0 {
noi dis as error _n "Attention. Directory: ""`directory'"" not found."
noi dis as error  "Please correctly specify {help sursol_actionlog##sursol_actionlog_directory:directory(string)}"
ex 601
}

//ALIGN MAC APPROACH
foreach x in "//" "\\\" "\\" "\\" "\" {
loc directory=subinstr("`directory'","`x'","/",.)
}


**GIVE WARNING IF PROTOCOL OF URL NOT GIVEN 
if strpos("`server'","http")==0 {
noi dis as error _n "Attention. There is no protocol specified in {help sursol_actionlog##server:server({it:url})}"
noi dis as error "The command will not work if the URL is not specified correctly. Let's give it a try nevertheless..."
}


//RPATH? 
if length("`rpath'")==0 {
if strpos(lower("`c(os)'"),"window")==0 {
noi dis as error _n "Attention.  You are not using Windows as an operating system."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_actionlog##sursol_actionlog_rpath:rpath(string)}"
ex 198
}

//CHECK RPATH FOR WINDOWS USERS
if strpos("`c(machine_type)'","64")>0 loc bit="x64" 
if strpos("`c(machine_type)'","32")>0 loc bit="x32" 

//R FOLDER IN PROGRAM FILES? 
mata : st_numscalar("OK", direxists("C:/Program Files/R"))
if scalar(OK)==0 {
noi dis as error _n "Attention. No R folder in ""C:/Program Files/"" was found."
noi dis as error  "Please specify the path of your R.exe using the option {help sursol_actionlog##sursol_actionlog_rpath:rpath(string)}"
ex 601
}
	//R FOLDER IN PROGRAM FILES/R? 
	local folderstructure: dir "C:/Program Files/R" dirs "*", respectcase 
	local folderstructure : list sort folderstructure
	local length : word count `folderstructure'

	if `length'>1 {
	noi dis as error _n "Attention, two versions of R have been found:"
	loc i=1
	foreach x of loc folderstructure {
		noi dis as result "`x'" 
		if `length'==`i' {
		noi dis as result _n "Version `x' of R will be used to download the action logs"
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
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_actionlog##sursol_actionlog_rpath:rpath(string)}"
	ex 601
	}

	if scalar(OK)==0 {
	noi dis as error _n "Attention. No bin folder in ""C:/Program Files/R//`version'/"" was found."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_actionlog##sursol_actionlog_rpath:rpath(string)}"
	ex 601
	}
	
	mata : st_numscalar("OK", direxists("C:/Program Files/R//`version'/bin//`bit'/"))
	if scalar(OK)==0 {
	noi dis as error _n "Attention. No `bit' folder in ""C:/Program Files/R//`version'/bin"" was found."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_actionlog##sursol_actionlog_rpath:rpath(string)}"
	ex 601
	}

	capt confirm file "C:/Program Files/R//`version'/bin//`bit'/R.exe"
	if _rc {
	no dis as error _n "Attention. No R.exe in ""C:/Program Files/R//`version'/bin//`bit'/"" was found."
	noi dis as error  "Please specify the path of your R.exe using the option {help sursol_actionlog##sursol_actionlog_rpath:rpath(string)}"
	ex 601
	}
	//FINAL CLEAN RPATH
	loc rpath="C:/Program Files/R//`version'/bin//`bit'/"
	} 

//IF RPATH WAS SPECIFIED
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
	noi dis as error  "Please correctly specify the path of your R.exe using the option {help sursol_actionlog##sursol_actionlog_rpath:rpath(string)}"
	ex 601
	}
}



//START WRITING THE R SCRIPT

//REMOVE OLD SCRIPTS
qui capt rm "`directory'/action_log.R"
qui capt rm "`directory'/.Rhistory" 



quietly: file open rcode using "`directory'/action_log.R", write replace 
#d ;
quietly: file write rcode  
`"server <- "`server'" "' _newline 
`"user= "`user'"  "' _newline
`"password="`password'" "' _newline
`"directory <-  "`directory'"  "' _newline
`"start_date="`startdate'" "' _newline
`"end_date="`enddate'" "' _newline
`"append<-"`append'" "' _newline
`"process<-"`process'"   "' _newline           
		`"packages<- c("stringr", "jsonlite","httr","date","data.table") "'  _newline
		`"for (newpack in packages) { "'  _newline
		`" if(newpack %in% rownames(installed.packages()) == FALSE) {install.packages(newpack, repos = 'https://cloud.r-project.org/', dep = TRUE)} "'  _newline
		`" if(newpack %in% rownames(installed.packages()) == FALSE) {  "'  _newline
       		`" stop(paste0("Attention. Problems installing package: ",newpack, "Try to install it manually"))       "'  _newline
    		`" } "'  _newline
		`"} "'  _newline
		`"suppressMessages(suppressWarnings(library(stringr))) "'  _newline
		`"suppressMessages(suppressWarnings(library(jsonlite))) "'  _newline
		`"suppressMessages(suppressWarnings(library(httr))) "'  _newline
		`"suppressMessages(suppressWarnings(library(data.table))) "'  _newline								                
		`"suppressMessages(suppressWarnings(library(date)))"'  _newline	
		
		`"##DATE PACKAGE, SET LOCAL TIME TO ENGLISH"' _newline
		`"Sys.setlocale("LC_TIME", "English")"' _newline                       
                `"server_url<-sprintf("%s", server)  "'    _newline
                `"  "'    _newline
                `"serverCheck <- try(http_error(server_url), silent = TRUE)  "'    _newline
                `"if (class(serverCheck) == "try-error") {  "'    _newline
               `"  stop(paste0("The following server does not exist. Check internet connection or the server name:", server_url))  "'    _newline
                `"    "'    _newline
                `"}  "'    _newline
                `"  "'    _newline
`" ##START GETTING THE LOGS      "' _newline
`"       "' _newline
`" ##GENERAL API_URL      "' _newline
`" api_URL <- sprintf("%s/api/v1", server)        "' _newline
`"       "' _newline
`"       "' _newline
`" ##FIRST GET LIST OF SUPERVISORS      "' _newline
`" supervisor_query <-paste0(api_URL, "/supervisors?limit=100&offset=1")       "' _newline
`" get_supervisor <- GET(supervisor_query, authenticate(user, password))        "' _newline
`"       "' _newline
`"    if (status_code(get_supervisor) == 401) {         "' _newline
`"                  stop("Incorrect username or password. Check login credentials for API user")        "' _newline
`"              } else if  (status_code(get_supervisor) != 200){       "' _newline
`"                  stop(paste0("Encountered issue with status code ", status_code(data)))        "' _newline
`"               }        "' _newline
`"       "' _newline
                 
`" ##GET LIST OF SUPERVISORS INTO DATAFRAME      "' _newline
`" list_supervisors <- as.data.frame(fromJSON(content(get_supervisor, as = "text"), flatten = TRUE)      "' _newline
`"                                   \$User)       "' _newline
`" #1      "' _newline
`" ##NOW GO THROUGH EACH SUPERVISORS      "' _newline
`"   for(sup_id in list_supervisors\$UserId ) {      "' _newline
`"           "' _newline
`"     #GET LIST OF ALL INTERVIEWERS FOR CURRENT SUPERVISOR       "' _newline
`"       interviewer_query <-paste0(api_URL, "/supervisors/",sup_id,"/interviewers?limit=100&offset=1")       "' _newline
`"       get_interviewer <- GET(interviewer_query, authenticate(user, password))        "' _newline
`"             "' _newline
`"       if (status_code(get_interviewer) != 200)  {      "' _newline
`"         stop( paste0("Attention. Request to receive list of interviewers was not successfull. Status code: ",status_code(get_interviewer) ) )      "' _newline
`"       }      "' _newline
`"             "' _newline
`"             "' _newline
`"       list_all_interviewers_sups <- as.data.frame(fromJSON(content(get_interviewer, as = "text"), flatten = TRUE)\$User)       "' _newline
`"            "' _newline
`"       "' _newline
`"        ##NOW GO THROUGH EACH INTERVIEWER       "' _newline
`"         for(int_id in list_all_interviewers_sups\$UserId ) {      "' _newline
`"                 "' _newline
`"           ##GET DETAILS OF THE INTERVIEWER      "' _newline
`"           interviewer_details_query <-paste0(api_URL, "/interviewers/",int_id)       "' _newline
`"           get_interviewer_detail <- GET(interviewer_details_query, authenticate(user, password))       "' _newline
`"                 "' _newline
`"           if (status_code(get_interviewer) != 200)  {      "' _newline
`"             stop( paste0("Attention. Request to receive detailes of interviewer was not successfull. Status code: ",status_code(get_interviewer_detail), " for interviewer: ",       "' _newline
`"                          (unique(list_all_interviewers_sups\$UserName[list_all_interviewers_sups\$UserId == int_id])) ) )      "' _newline
`"           }      "' _newline
`"                 "' _newline
`"                 "' _newline
`"           ##GET THE CREATION DATE      "' _newline
`"           int_info<- fromJSON(content(get_interviewer_detail, as = "text"), flatten = TRUE)      "' _newline
`"           int_creatdate <- as.Date(as.POSIXct(int_info\$CreationDate  , format = "%Y-%m-%dT%H:%M:%OS", tz = "UCT")       "' _newline  
`"                                    , "UCT")         "' _newline
`"                 "' _newline
`"           ##GET THE NAME OF CURRENT INTERVIEWER       "' _newline
`"           int_name<-(unique(list_all_interviewers_sups\$UserName[list_all_interviewers_sups\$UserId == int_id]))        "' _newline
`"                 "' _newline
`"                 "' _newline
`"           ##NOW GET THE ACTION LOG      "' _newline
`"           action_log_query <- paste0(api_URL, "/interviewers/",int_id,"/actions-log?start=",int_creatdate,"&end=",Sys.Date())        "' _newline
`"           download_actionlog <- GET(action_log_query, authenticate(user, password))        "' _newline
`"                 "' _newline
`"           if (status_code(get_interviewer) != 200)  {      "' _newline
`"             stop( paste0("Attention. Request to download action log was not successfull. Status code: ",status_code(get_interviewer_detail), " for interviewer: ",       "' _newline
`"                          (unique(list_all_interviewers_sups\$UserName[list_all_interviewers_sups\$UserId == int_id])) ) )      "' _newline
`"           }      "' _newline
`"                 "' _newline
`"                 "' _newline
`"           ##THE LOG AS DATA TABLE      "' _newline
`"           list_log <- data.table(fromJSON(content(download_actionlog, as = "text"), flatten = TRUE) )      "' _newline
`"                 "' _newline
`"           ##IF THERE HAS BEEN ANY TABLET SET UP      "' _newline
`"           if (!length(list_log)==FALSE) {      "' _newline
`"             #DISPLAY INFO      "' _newline 
`"             print(paste0(int_name, ": Action log now being downloaded"))  "' _newline 
`"                   "' _newline 
`"             ##RENAME TABLE HEADER      "' _newline
`"             names(list_log) <- c("Timestamp", "Action")      "' _newline
`"                   "' _newline
`" 		##IF NOT PROCESSED BUT APPENDED, WE SHOULD AT LEAST GET THE USER NAME FOR IDENTIFIYNG IN THERE "' _newline
`"              if (nchar(process)==0 & nchar(append)>0 ) list_log\$user_name <- int_name      "' _newline
`"             ##PROCESS THE FILE A BIT IF PROCESS HAS BEEN SPECIFIED BY USER      "' _newline
`"             if (nchar(process)>0) {      "' _newline
`"                     "' _newline
`"               ##CREATE DATE & TIME VARIABLE      "' _newline
`"               list_log\$date <- as.Date(as.POSIXct(list_log\$Timestamp  , format = "%Y-%m-%dT%H:%M:%OS", tz = "UCT")        "' _newline
`"                                        , "UCT")      "' _newline 
`"               list_log\$time  <- as.ITime(as.POSIXct(list_log\$Timestamp  , format = "%Y-%m-%dT%H:%M:%OS", tz = "UCT")   "' _newline     
`"                                            , "UCT") "' _newline
`"                     "' _newline
`"               ##CREATE DUMMIES      "' _newline
`"                     "' _newline
`"               #USER       "' _newline
`"               list_log\$user_name <- int_name      "' _newline
`"               list_log\$user_loggedin <- str_detect(list_log\$Action, regex("logged in", ignore_case = TRUE))      "' _newline

`"               #SYNC      "' _newline
`"               list_log\$sync_started <- str_detect(list_log\$Action, regex("sync started", ignore_case = TRUE))      "' _newline
`"               list_log\$sync_completed <- str_detect(list_log\$Action, regex("sync completed", ignore_case = TRUE))      "' _newline
`"               list_log\$sync_failed <- str_detect(list_log\$Action, regex("sync failed", ignore_case = TRUE))      "' _newline
`"                     "' _newline
`"               #INTERVIEW      "' _newline
`"               list_log\$int_created <- str_detect(list_log\$Action, regex("created from", ignore_case = TRUE))      "' _newline
`"               list_log\$int_opened <- str_detect(list_log\$Action, regex("opened", ignore_case = TRUE))      "' _newline
`"               list_log\$int_closed <- str_detect(list_log\$Action, regex("closed", ignore_case = TRUE))      "' _newline
`"               list_log\$int_completed <- str_detect(list_log\$Action, regex("completed", ignore_case = TRUE))      "' _newline
`"               list_log\$int_deleted <- str_detect(list_log\$Action, regex("deleted", ignore_case = TRUE))      "' _newline
`"                     "' _newline
`"                     "' _newline
`"               ##INTERVIEW KEY      "' _newline
`"               list_log[, interview__key :=str_extract_all(Action, "\\d{2}-\\d{2}-\\d{2}-\\d{2}", simplify = TRUE)]      "' _newline
`"                     "' _newline
`"               ##ASSIGNMENT ID       "' _newline
`"               list_log[, assignment__id :=str_remove(str_extract_all(Action, "created from assignment \\d+", simplify = TRUE),"created from assignment")]      "' _newline
`"                     "' _newline
`"                     "' _newline
`"               ##REPLACE LOGICAL COLUMNS WITH 1/0      "' _newline
`"               (to.replace <- names(which(sapply(list_log, is.logical))))      "' _newline
`"               for (var in to.replace) list_log[, (var):= as.numeric(get(var))]      "' _newline
`"                   "' _newline
`"             }      "' _newline
`"                   "' _newline
`"             ##WRITE FINAL       "' _newline
`"             write.table(list_log,file.path(directory, paste0("actions_log_",int_name,".tab") ),sep="\t",row.names=FALSE, quote=FALSE, col.names=TRUE )      "' _newline
`"                "' _newline
`"                   "' _newline
`"              }      "' _newline
`"           else if (!length(list_log)==TRUE) print(paste0(int_name,": Tablet has not been set up yet. No download."))      "' _newline
`"                 "' _newline
`"         }      "' _newline
`"            "' _newline
`"   }      "' _newline
`"       "' _newline
`" ##APPEND THEM ALL IN ONE BIG FILE   IF SPECIFIED   "' _newline
`" if (nchar(append)>0) {      "' _newline
`"       "' _newline
`"       "' _newline
`" if (file.exists(paste0(directory,"/all_actions_log.tab")))       "' _newline
`"         "' _newline
`" #Delete file if it exists      "' _newline
`" file.remove(paste0(directory,"/all_actions_log.tab"))      "' _newline
`"         "' _newline
`" #LIST ALL FILES IN FOLDER        "' _newline
`" tab_files <- list.files(path=directory, pattern="*.tab")       "' _newline
`"       "' _newline
`" #FAST READ ALL FILES      "' _newline
`" txt_files_df <- lapply(paste0(directory,"/",tab_files), function(x) {fread(file = x, header = T, sep ="\t")})      "' _newline
`"       "' _newline
`" ##BIND THEM TO ONE BIG FILE      "' _newline
`" combined_dt <- do.call("rbind", lapply(txt_files_df, as.data.table))       "' _newline
`"       "' _newline
`" ##WRITE THE TABLE      "' _newline
`" write.table(combined_dt,file.path(directory, paste0("all_actions_log.tab") ),sep="\t",row.names=FALSE, quote=FALSE, col.names=TRUE, na="" )      "' _newline
`" }      "' _newline ;

#d cr
file close rcode 


		//EXECUTE THE COMMAND
		timer clear
		timer on 1
                shell "`rpath'/R" --vanilla <"`directory'/action_log.R" 2>`error_message' 
		timer off 1	
		qui timer list 1
		if `r(t1)'<=2 {
		dis as error "Whoopsa! That was surprisingly fast."
		dis as error "Please check if the action logs have been downloaded correctly." 
		dis as error "If not, have a look at {help sursol_actionlog##debugging:debugging information} in the help file."
		dis as error "You might need to install some R packages manually since Stata has no administrator rights to install them."
		}

		//DISPLAY ANY ERRORS PRODUCED IN THE R SCRIPT
		di as result _n
		di as  result "{ul:Warnings & Error messages displayed by R:}"
		type `error_message'

		
                qui capt rm "`directory'/action_log.R"
                qui capt rm "`directory'/.Rhistory" 
                qui  cd "`currdir'"
                
                end	
                
                