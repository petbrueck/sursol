{smcl}
{cmd:help sursol export}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol export} {hline 2} downloads survey data of a questionnaire from a Survey Solutions Server. R software is required. 



{title:Syntax}

{p 8 17 2}
{cmd:sursol export}
{it:questionnaire_name}
{cmd:,} {opt dir:ectory(string)} {opt serv:er(string)}  {opt user(string)} {opt password(string)} [{it:{help sursol export##sursol export_options:sursol export options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{it:questionnaire_name}}name of the questionnaire as found on the server. Case and space insensitive {p_end}
{marker sursol_export_directory}{...}
{synopt:{opt dir:ectory(string)}}path in which exported data will be stored {p_end}
{synopt:{opt serv:er(string)}}prefix of server domain name {p_end}
{synopt:{opt user(string)}}API user name{p_end}
{synopt:{opt password(string)}}password of API user{p_end}
{synoptline}


{marker sursol_export_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:sursol export options }
{synoptline}
{synopt:{opt format(string)}}format in which main survey data will be exported{p_end}
{synopt:{opt versions(numlist)}}export only specified versions{p_end}
{synopt:{opt lastv:ersion}}exports only the last version{p_end}
{synopt:{opt para:data}}export paradata{p_end}
{synopt:{opt bin:ary}}export binary data{p_end}
{synopt:{opt status(string)}}status of exported interviews{p_end}
{synopt:{opt nozip}}exported data will not be unzipped{p_end}
{synopt:{opt zipdir(string)}}path in which exported data will be unzipped to{p_end}
{synopt:{opt start:date(string)}}starting date for time frame of exported interviews. 
Must be in {it: YYYY-MM-DD} date format{p_end}
{synopt:{opt end:date(string)}}end date for time frame of exported interviews. Must be in {it: YYYY-MM-DD} date format{p_end}
{synopt:{opt r:path(string)}}path of R.exe. If OS non-Windows, this option is required{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt sursol export} performs data export of survey data from a Survey Solutions server using your locally installed R.exe through the Windows Command Shell.

{pstd}
The command identifies data on the server corresponding to {it:questionnaire_name} and requests the data to be generated on the server. 
If successful, the data will be exported to the path specified in {opt dir:ectory(string)} in ZIP format. Unless not requested, all files will be unzipped. 
An installed version of R Statistical Software is required. Each Survey Solutions version of {it:questionnaire_name} will be treated seperately.


{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}

{phang}
{it: questionnaire_name} requests a list of all questionnaire versions available on the server corresponding to {it: questionnaire_name}. Case insensitive. Error message is displayed if no questionnaire is found. 

{marker directory}{...}
{phang}
{opt dir:ectory(string)} specifies the path in which the exported ZIP files will be saved. By default all exported ZIP files will be unzipped into this path unless {opt nozip} or {opt zipdir(string)} is specified.

{phang}
{opt serv:er(string)} specifies the server on which the survey is hosted. Only prefix of domain name required: PREFIX.mysurvey.solutions. Full domain name, protocol and other URL information will be added automatically. 

{phang}
{opt user(string)} specifies the login name of an API account created on the server itself. 

{phang}
{opt password(string)} the corresponding password of the API account specified in {opt user(string)}. 


{marker optiona}{...}
{dlgtab:Optional}

{phang}
{opt format(string)} can be used to specify the format of the main survey data to be exported. Can be one or combination of any of the following: "stata", "spss" or "tabular". By default, only stata format (.dta files) will be exported.

{marker versions}{...}
{phang}
{opt versions(numlist)} by default, {opt sursol export} requests all versions that are found on the server to be exported.
If {opt versions(numlist)} is specified, only respective versions of {it:questionnaire_name} are exported. 
Versions can be specified in any order and using either "," or " " as a delimiter. 
For example, {opt versions(1 3 4)} or {opt versions(4,3,1)} both request to download Version 1,3 and 4 of the specified questionnaire. 

{marker lastversion}{...}
{phang}
{opt lastv:ersion} if specified, only the most recent version that can be found on the server of {it:questionnaire_name} will be exported. Can not be used in conjunction with {opt versions(numlist)}.

{phang}
{opt para:data} requests to export corresponding paradata which contains metadata on the interview process (events and timing).

{phang}
{opt bin:ary} can be used to export corresponding binary data which contains for example contains pictures or recored audio sequences. 

{phang}
{opt status(string)} only requests to export data with a specific status. By default, all interviews of {it:questionnaire_name} are exported. {it:status(string)} 
can be specified by using one of the following statuses:

		 {hline 33}
        	  ApprovedByHeadquarters  
	 	  ApprovedBySupervisor                 
          	  RejectedByHeadquarters
          	  RejectedBySupervisor 
          	  Completed              
         	  Restarted
	  	  SentToCapi
	  	  ReadyForInterview
	  	  InterviewerAssigned
	  	  SupervisorAssigned
	  	  Created
	  	  Restored
	  	  Deleted             
	 	{hline 33}

{phang}
{opt nozip} if specified, the exported ZIP files will not be unzipped. 

{phang}
{opt zipdir(string)} by default, and if {opt nozip} is not specified, {opt sursol export} unzipps the exported exported ZIP files and stores them in {opt dir:ectory(string)}. 
If this is not convenient for the user {opt zipdir(string)} specifies the path in which the unzipped files should be stored. {opt nozip} and {opt zipdir(string)} can not be specified together. 

{phang}
{opt start:date(string)} by default, {opt sursol export} requests to export all data irrespective when the last change to an interview was done. If one is interested only in a specific time frame from date X forward, 
{opt start:date(string)} can be specified in UTC date ({it:YYYY-MM-DD}). Please note, date specified refers to the last change that has been done for an interview not the date on which the interview took place. 

{phang}
{opt end:date(string)} similar to {opt start:date(string)}, one can determine to export only interviews for which changes have been made until date specified in {opt end:date(string)}. Must also be specified in UTC date ({it:YYYY-MM-DD}).

{marker sursol_export_rpath}{...}
{phang}
{opt rpath(string)} specifies the path to the R.exe through which the data export request to the server is transmitted. Required if non-windows OS. By default, and if windows as OS is used, {opt sursol export} assumes that the executable  
can be found in "C:\Program Files\R\R-X.X.X\bin\xBITVERSION\". It returns errors if it is not possible to detect any executable in the default or specified folder.

{title:Debugging}

{pstd} If you encounter the problem that the windows/mac shell box opens but closes shortly after without any data being exported: {p_end}
{pstd}{cmd:sursol export} relies on various R packages. By default, those R packages are being installed if the command can not locate the packages.{p_end} 
{pstd}However, some users reported that this is not working properly.{p_end}
{pstd}Therefore, try to install the following packages manually in R by opening R, either in applications such as RStudio or R.exe itself: {p_end}

{synoptline}
{pstd}	install.packages("stringr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd} 	install.packages("tidyverse", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd} 	install.packages("lubridate", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("jsonlite", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("httr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd} 	install.packages("dplyr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("date", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{synoptline}

Afterwards, {cmd:sursol export} should run.

{title:Examples}

{pstd}Request to export survey and paradata of versions 1,2 and 5 of questionnaire "Project X Baseline Survey" from server {it:https://projectX.mysurvey.solutions}{p_end}
{phang2}{cmd:. sursol export "MyQnr",  dir("${download}") ///}{p_end}
{phang2}{cmd:. server("projectX") ///}{p_end}
{phang2}{cmd:. user("API_2")  ///}{p_end}
{phang2}{cmd:. password("API_2_pw123") ///}{p_end}
{phang2}{cmd:. paradata ///}{p_end}
{phang2}{cmd:. versions(1 2 5)}{p_end}

{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!

{pstd} The command builds upon R scripts and snippets from other Survey Solutions users including {browse "https://forum.mysurvey.solutions/t/access-api-using-r/149/3": Michael Rahija, Arthur Shaw and Lena Nguyen.} 

{pstd}{cmd:sursol export} was last updated using Survey Solutions 20.04. 

{pstd} {ul:Attention!} The current export API as used by {cmd:sursol export} will be {browse "https://support.mysurvey.solutions/release-notes/version-20-04/":phased out in future releases.} 
{pstd} Drop by on {browse "https://github.com/petbrueck/sursol":GitHub} in the coming months to see if {cmd:sursol export} has been updated. 

