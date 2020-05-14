{smcl}
{cmd:help sursol userreport}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol userreport} {hline 2} exports detailed interviewer report for all interviewer users created on a Survey Solutions Server. R software is required.


{title:Syntax}

{p 8 17 2}
{cmd:sursol userreport}
{cmd:,} {opt dir:ectory(string)} {opt serv:er(url)}  {opt hquser(string)} {opt hqpass:word(string)} {it:file format} [{it:{help sursol userreport##sursol userreport_options:sursol userreport options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{marker sursol_userreport_directory}{...}
{synopt:{opt dir:ectory(string)}}path in which interviewers report will be stored {p_end}
{synopt:{opt serv:er(url)}}string of full URL of server, including protocol and hostname {p_end}
{synopt:{opt hquser(string)}}user name of Headquarter account{p_end}
{synopt:{opt hqpass:word(string)}}password of Headquarter account{p_end}

{synopt:{it:file format}}{it:At least one or combination of:} {p_end}
{synopt:{opt xlsx}}downloads report as .xlsx file{p_end}
{synopt:{opt csv}}downloads report as .csv file{p_end}
{synopt:{opt tab}}downloads report as .tab file{p_end}
{synoptline}


{marker sursol_userreport_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:sursol userreport options }
{synoptline}
{synopt:{opt r:path(string)}}path of R.exe. If OS non-Windows, this option is required{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt sursol userreport} downloads the full interviewer report for all interviewer user accounts from a Survey Solutions server using your locally installed R.exe through the Command Shell.  {p_end}

{pstd}
The command requests to export the interviewer report which also can be manually downloaded from the server via{p_end}
{pstd}
"Teams and Roles" -> "Interviewers" -> "Download report as XLSX, CSV, or TAB".  {p_end}

{pstd}
This report contains information about the users device, recent synchronizations activities and connection statistics.{p_end}

{pstd}  
If successful, the report will be exported to the path specified in {opt dir:ectory(string)} in either .xlsx, .csv or .tab format. {p_end}

{pstd}
An installed version of R Statistical Software is required. {p_end}


{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}

{marker directory}{...}
{phang}
{opt dir:ectory(string)} specifies the path in which the interviewer report will be saved. Existing files "Interviewers" will be overwritten. 

{marker server}{...}
{phang}
{opt serv:er(url)} specifies the server on which the survey is hosted. Full URL required: Protocol (e.g. {it:https://}), hostname (e.g. {it:projectX.mysurvey.solutions}) and any other URL information.
A typical server URL for servers hosted by the World Bank: {it: https://projectX.mysurvey.solutions}

{phang}
{opt hquser(string)} specifies the user name of an Headquarter account. {cmd:Important:} Do not use the credentials of an API user. 

{phang}
{opt hqpass:word(string)} the corresponding password of the Headquarter account specified in {opt hquser(string)}. {cmd:Important:} Do not use the credentials of an API user. 


{synoptline}
{phang}
{it: At least one or any combination of the following file format(s):}

{phang}
{opt xlsx} interviewer report will be saved as "Interviewers.xlsx" on sheet "Data".{p_end}

{phang}
{opt csv} interviewer report will be saved as "Interviewers.csv" on sheet "Interviewers".{p_end}

{phang}
{opt tab} interviewer report will be saved as "Interviewers.tab"{p_end}
{synoptline}


{marker optiona}{...}
{dlgtab:Optional}

{marker sursol_userreport_rpath}{...}
{phang}
{opt rpath(string)} specifies the path to the R.exe through which the data export request to the server is transmitted. Required if non-windows OS. By default, and if windows as OS is used, {opt sursol userreport} assumes that the executable  
can be found in "C:\Program Files\R\R-X.X.X\bin\xBITVERSION\". It returns errors if it is not possible to detect any executable in the default or specified folder.


{marker debugging}{...}
{title:Debugging}

{pstd} If you encounter the problem that the windows/mac shell box opens but closes shortly after without any report being exported: {p_end}
{pstd}{cmd:sursol userreport} relies on various R packages. By default, those R packages are being installed if the command can not locate the packages.{p_end} 
{pstd}However, some users reported that this is not working properly. This is most likely because of Stata / Windows or Mac Shell Box not having administrator rights to install the packages.{p_end}
{pstd}Therefore, try to install the following packages manually in R by opening R, either in IDE' such as RStudio or R.exe itself: {p_end}

{synoptline}
{pstd}	install.packages("httr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("xlsx", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{synoptline}

{pstd}Make sure that you have administrator rights. Afterwards, {cmd:sursol userreport} should run. {p_end}

{title:Examples}

{pstd}Request to get interviewer report from server {it:https://projectX.mysurvey.solutions}{p_end}

{phang2}{cmd:. sursol userreport,  dir("${download}/interview_reports") ///}{p_end}
{phang2}{cmd:. server("https://projectX.mysurvey.solutions") ///}{p_end}
{phang2}{cmd:. hquser("Hquser1")  ///}{p_end}
{phang2}{cmd:. hqpassword("Hquser1PW") ///}{p_end}


{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!

{pstd}{cmd:sursol userreport} was last updated using Survey Solutions 20.05
