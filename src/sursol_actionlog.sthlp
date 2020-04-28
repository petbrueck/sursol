{smcl}
{cmd:help sursol actionlog}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol actionlog} {hline 2} downloads detailed action log for all interviewer users created on a Survey Solutions Server. R software is required. 


{title:Syntax}

{p 8 17 2}
{cmd:sursol actionlog}
{cmd:,} {opt dir:ectory(string)} {opt serv:er(string)}  {opt user(string)} {opt password(string)} [{it:{help sursol actionlog##sursol actionlog_options:sursol actionlog options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{marker sursol_export_directory}{...}
{synopt:{opt dir:ectory(string)}}path in which exported data will be stored {p_end}
{synopt:{opt serv:er(string)}}prefix of server domain name {p_end}
{synopt:{opt user(string)}}API user name{p_end}
{synopt:{opt password(string)}}password of API user{p_end}
{synoptline}


{marker sursol_export_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:sursol actionlog options }
{synoptline}
{synopt:{opt r:path(string)}}path of R.exe. If OS non-Windows, this option is required{p_end}
{synopt:{opt append}}appends all action logs in one long file{p_end}
{synopt:{opt process}}additional variables are generated based on action log raw content{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt sursol actionlog} returns audit log records for all interviewer user accounts from a Survey Solutions server using your locally installed R.exe through the Command Shell.  {p_end}

{pstd}
The command identifies all supervisors listed on the server, identifies all interviewers listed for each supervisor and returns the audit log for each individual interviewer user account. 
If successful, the action log will be exported to the path specified in {opt dir:ectory(string)} in .tab format.   {p_end}

{pstd}
Each file is named "actions_log_USERNAME.tab". {p_end}

{pstd}
An installed version of R Statistical Software is required. {p_end}


{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}

{marker directory}{...}
{phang}
{opt dir:ectory(string)} specifies the path in which the action log files will be saved. 

{phang}
{opt serv:er(string)} specifies the server on which the survey is hosted. Only prefix of domain name required: PREFIX.mysurvey.solutions. Full domain name, protocol and other URL information will be added automatically. 

{phang}
{opt user(string)} specifies the login name of an API account created on the server itself. 

{phang}
{opt password(string)} the corresponding password of the API account specified in {opt user(string)}. 


{marker optiona}{...}
{dlgtab:Optional}

{marker sursol_export_rpath}{...}
{phang}
{opt rpath(string)} specifies the path to the R.exe through which the data export request to the server is transmitted. Required if non-windows OS. By default, and if windows as OS is used, {opt sursol actionlog} assumes that the executable  
can be found in "C:\Program Files\R\R-X.X.X\bin\xBITVERSION\". It returns errors if it is not possible to detect any executable in the default or specified folder.

{phang}
{opt append} appends all action logs that are to be found in {opt dir:ectory(string)} after export. Saves the appended file as {it:"all_actions_log.tab"}. 

{phang}
{opt process} if specified, the content of user action log's will be processed. The following variables are generated: 

{synoptset 21 tabbed}{...}
{synopthdr:Variable}
{synoptline}
{synopt:{it: date} } String of date of action in YYYY-MM-DD format{p_end}
{synopt:{it: time} } String of time of action in HH:MM:SS format{p_end}

{synopt:{it: user_name} } User name of this action log. Useful if logs are appended{p_end}
{synopt:{it: user_loggedin} } Dummy if user logged into the application {p_end}

{synopt:{it: sync_completed} } Dummy if sync was started{p_end}
{synopt:{it: sync_completed} } Dummy if sync was sucessfully completed{p_end}
{synopt:{it: sync_failed} } Dummy if sync failed{p_end}

{synopt:{it: int_created } } Dummy if interview was created from assignment {p_end}
{synopt:{it: int_opened} } Dummy if interview was opened {p_end}
{synopt:{it: int_closed} } Dummy if interview was closed {p_end}
{synopt:{it: int_completed } } Dummy if interview was completed when closed{p_end}
{synopt:{it: int_deleted} } Dummy if interview was discarded from tablet{p_end}

{synopt:{it: interview__key} } Interview__key of interview for which action has been taken{p_end}
{synopt:{it: assignment__id} } Assignment__id from which interview has been created{p_end}
{synoptline} 

{title:Debugging}

{pstd} If you encounter the problem that the windows/mac shell box opens but closes shortly after without any data being exported: {p_end}
{pstd}{cmd:sursol actionlog} relies on various R packages. By default, those R packages are being installed if the command can not locate the packages.{p_end} 
{pstd}However, some users reported that this is not working properly.{p_end}
{pstd}Therefore, try to install the following packages manually in R by opening R, either in applications such as RStudio or R.exe itself: {p_end}

{synoptline}
{pstd}	install.packages("stringr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("jsonlite", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("httr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("date", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("data.table", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{synoptline}

Afterwards, {cmd:sursol actionlog} should run.

{title:Examples}

{pstd}Request to export detailed action logs from server {it:https://projectX.mysurvey.solutions}, append and analyse parts of the content {p_end}

{phang2}{cmd:. sursol actionlog,  dir("${download}/action_log_folder") ///}{p_end}
{phang2}{cmd:. server("projectX") ///}{p_end}
{phang2}{cmd:. user("API_2")  ///}{p_end}
{phang2}{cmd:. password("API_2_pw123") ///}{p_end}
{phang2}{cmd:. append ///}{p_end}
{phang2}{cmd:. process}{p_end}

{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!

{pstd}{cmd:sursol actionlog} was last updated using Survey Solutions 20.04