{smcl}
{cmd:help sursol export}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol export} {hline 2} downloads data of a questionnaire from a Survey Solutions Server. R software is required. 


{title:Syntax}

{p 8 17 2}
{cmd:sursol export}
{it:questionnaire_name}{cmd:,} {opt serv:er(url)}  {opt user(string)} {opt password(string)} {it:file-destination}  {it: dataset} [{it:{help sursol export##sursol export_options:sursol export options}}]


{synoptset 25 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{it:questionnaire_name}}name of the questionnaire as found on the server. Case and space insensitive {p_end}
{marker sursol_export_directory}{...}
{synopt:{opt serv:er(url)}}string of full URL of server, including protocol and hostname {p_end}
{synopt:{opt user(string)}}API user name{p_end}
{synopt:{opt password(string)}}password of API user{p_end}

{synopt:{it:file-destination}}{it:One of the following:}{p_end}
{synopt:{opt dir:ectory(string)}}Downloads data to your machine. Specify path in which exported data shall be stored.{p_end}
{marker dropbox}{...}
{synopt:{opt dropbox(access_token)}}Uploads data to Dropbox. Specify API Dropbox App access token.{p_end}

{synopt:{it:dataset}}{it:At least one or combination of:} {p_end}
{synopt:{opt stata}}export main survey data in Stata 14 format{p_end}
{synopt:{opt tabular}}export main survey data in tab separated text file format{p_end}
{synopt:{opt spss}}export main survey data in SPSS format{p_end}
{synopt:{opt para:data}}export paradata{p_end}
{synopt:{opt bin:ary}}export binary data{p_end}
{synopt:{opt ddi}}export DDI data{p_end}
{synoptline}


{marker sursol_export_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:export options }
{synoptline}
{synopt:{opt versions(numlist)}}export only specified versions{p_end}
{synopt:{opt lastv:ersion}}exports only the last version{p_end}
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
{opt sursol export} performs export of data from a Survey Solutions server using your locally installed R.exe through the Windows Command Prompt or Mac terminal. 

{pstd}
The command identifies data on the server corresponding to {it:questionnaire_name} and requests the data to be generated on the server. 
If successful, the data will be exported to the path specified in {opt dir:ectory(string)} in ZIP format. Unless not requested, all files will be unzipped. 
An installed version of R Statistical Software is required. Each Survey Solutions version of {it:questionnaire_name} will be treated seperately.


{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}

{phang}
{it: questionnaire_name} requests a list of all questionnaire versions available on the server corresponding to {it: questionnaire_name}. Case insensitive. Error message is displayed if no questionnaire is found. 

{marker server}{...}
{phang}
{opt serv:er(url)} specifies the server on which the survey is hosted. Full URL required: Protocol (e.g. {it:https://}), hostname (e.g. {it:projectX.mysurvey.solutions}) and any other URL information.
A typical server URL for servers hosted by the World Bank: {it: https://projectX.mysurvey.solutions}

{phang}
{opt user(string)} specifies the login name of an API account created on the server itself. 

{phang}
{opt password(string)} the corresponding password of the API account specified in {opt user(string)}. 


{synoptline}
{phang}
{it: One of the following specification of file destination:}

{phang}
{opt dir:ectory(string)} If specified, data will be downloaded to your machine. Use ({it:string}) to specify the path in which the exported ZIP files will be saved. 
By default all exported ZIP files will be unzipped into this path unless {opt nozip} or {opt zipdir(string)} is specified.

{phang}
{opt dropbox(access_token)} If specified, data will be automatically pushed to your Dropbox. This cloud-to-cloud data transfer is usually faster than direct download. To use this, you need to
{browse "https://www.dropbox.com/developers/apps":create your own App} for your Dropbox Account and generate an {browse "https://dropbox.tech/developers/generate-an-access-token-for-your-own-account":access token}.
Copy this token and paste it in {opt dropbox(access_token)}.
For now, data is not unzipped by {cmd:sursol export} if {opt dropbox(access_token)} is specified. 

{synoptline}

{marker dataset}{...}
{synoptline}
{phang}
{it: At least one or any combination of the following type of datasets to be requested: }

{phang}
{opt stata} requests to export main survey data in Stata 14 format.

{phang}
{opt tabular} requests to export main survey data in tab seperated text file format.

{phang}
{opt spss} requests to export main survey data in SPSS format. 

{phang}
{opt para:data} requests to export paradata which contains metadata on the interview process (events and timing).

{phang}
{opt bin:ary} requests to export binary data which contains for example contains pictures or recored audio sequences. 

{phang}
{opt ddi} requests to export DDI data (the list of data files, variables, their types, labels, question texts, interviewer instructions, etc.). 

{synoptline}


{marker optiona}{...}
{dlgtab:Optional}

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

{marker startdate}{...}
{phang}
{opt start:date(string)} by default, {opt sursol export} requests to export all data irrespective when the last change to an interview was done. If one is interested only in a specific time frame from date X forward, 
{opt start:date(string)} can be specified in UTC date ({it:YYYY-MM-DD}). Please note, date specified refers to the last change that has been done for an interview not the date on which the interview took place. 

{marker enddate}{...}
{phang}
{opt end:date(string)} similar to {opt start:date(string)}, one can determine to export only interviews for which changes have been made until date specified in {opt end:date(string)}. Must also be specified in UTC date ({it:YYYY-MM-DD}).
Please note, data is exported for interview with changes up to date specified in {opt end:date(string)} but not including this date. If you want to have all interviews with changes done until 20th April of 2020, use {opt end:date("2020-04-21")}.

{marker sursol_export_rpath}{...}
{phang}
{opt rpath(string)} specifies the path to the R.exe through which the data export request to the server is transmitted. Required if non-windows OS. By default, and if windows as OS is used, {opt sursol export} assumes that the executable  
can be found in "C:\Program Files\R\R-X.X.X\bin\xBITVERSION\". It returns errors if it is not possible to detect any executable in the default or specified folder.

{marker sursol_export_debugging}{...}
{title:Debugging}

{pstd} If you encounter the problem that the windows/mac shell box opens but closes shortly after without any data being exported: {p_end}
{pstd}{cmd:sursol export} relies on various R packages. By default, those R packages are being installed if the command can not locate the packages.{p_end} 
{pstd}However, some users reported that this is not working properly. This is most likely because of Stata / Windows or Mac Shell Box not having administrator rights to install the packages.{p_end}
{pstd}Therefore, try to install the following packages manually in R by opening R, either in IDE's such as RStudio or R.exe itself: {p_end}

{synoptline}
{pstd}	install.packages("stringr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd} 	install.packages("tidyverse", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd} 	install.packages("lubridate", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("jsonlite", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("httr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd} 	install.packages("dplyr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("date", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{synoptline}

{pstd}Make sure that you have administrator rights. Afterwards, {cmd:sursol export} should run. {p_end}

{title:Examples}

{pstd}Request to export main survey data in stata format and paradata of versions 1,2 and 5 of questionnaire named "Project X Baseline Survey" from server {it:https://projectX.mysurvey.solutions}.
Data shall be downloaded to the machine. {p_end}

{phang2}{cmd:. sursol export "Project X Baseline Survey",  dir("${download}") ///}{p_end}
{phang2}{cmd:. server("https://projectX.mysurvey.solutions") ///}{p_end}
{phang2}{cmd:. user("API_2")  ///}{p_end}
{phang2}{cmd:. password("API_2_pw123") ///}{p_end}
{phang2}{cmd:. stata paradata  ///}{p_end}
{phang2}{cmd:. versions(1 2 5)}{p_end}


{pstd}Afterwards request to export all binary data for all versions but push it to dropbox. {p_end}

{phang2}{cmd:. sursol export "Project X Baseline Survey",   ///}{p_end}
{phang2}{cmd:. server("https://projectX.mysurvey.solutions") ///}{p_end}
{phang2}{cmd:. user("API_2")  ///}{p_end}
{phang2}{cmd:. password("API_2_pw123") ///}{p_end}
{phang2}{cmd:. binary ///}{p_end}
{phang2}{cmd:. dropbox("64-character-long-access-token")}{p_end}


{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!

{pstd}{cmd:sursol export} was last updated using Survey Solutions 20.05 and adjusted to API V2.

{title:Acknowledgments}

{pstd} The command builds upon R scripts and snippets from other Survey Solutions users including {browse "https://forum.mysurvey.solutions/t/access-api-using-r/149/3": Lena Nguyen, Michael Rahija, and Arthur Shaw.} 
