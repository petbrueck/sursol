{smcl}
{cmd:help sursol rejectHQ}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol rejectHQ} {hline 2} rejects interview(s) as Headquarter based on specified rule. R software is required.



{title:Syntax}

{p 8 17 2}
{cmd:sursol rejectHQ}
{it:{help if}}{cmd:,} {opt serv:er(url)}  {opt user(string)} {opt password(string)} [{it:{help sursol rejectHQ##sursol rejectHQ_options:reject_options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{opt serv:er(string)}}string of full URL of server, including protocol and hostname {p_end}
{synopt:{opt user(string)}}API user name{p_end}
{synopt:{opt password(string)}}password of API user{p_end}
{synoptline}


{marker sursol_rejectHQ_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:reject options }
{synoptline}
{synopt:{opt comm:ent(string)}}text to be attached to rejection{p_end}
{synopt:{opt id:(var)}}variable that contains the globally unique identifier of each interview according to Survey Solutions format{p_end}
{synopt:{opt r:path(string)}}path of R application{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt sursol rejectHQ}  rejects interview(s) as Headquarter on a Survey Solutions server for which the {it:if} condition is true. {p_end}

{pstd}
The command lists all 32-character long identifier of the interviews for which the {it:if} condition is true in the current dataset. If not specified in {opt id(varlist)}, 
the command uses the Survey Solutions system generated variable "interview__id" by default.{p_end}

{pstd}
An installed version of R Statistical Software is required and will be accessed through the Windows Command Prompt or Mac terminal.
The command prompt/terminal returns warnings if (1) interview was in status that was not ready to be rejected or (2) interview has not been found. {p_end}

{pstd}
Interviews can be rejected by Headquarter with the following status only: {it:Completed} and {it:Approved by Supervisor}.  {p_end}

{pstd}
In case an interview is rejected with status {it:Approved by Supervisor}, it will be put into status {it:"Rejected by Headquarters"} and assigned to the responsible Supervisor.{p_end}

{pstd}
In case an interview is rejected with status {it:Completed}, it will be put into status {it:"Rejected by Supervisor"} and assigned to the responsible Interviewer.{p_end}

{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}

{marker server}{...}
{phang}
{opt serv:er(url)} specifies the server on which the survey is hosted. Full URL required: Protocol (e.g. {it:https://}), hostname (e.g. {it:projectX.mysurvey.solutions}) and any other URL information.
A typical server URL for servers hosted by the World Bank: {it: https://projectX.mysurvey.solutions}

{phang}
{opt user(string)} specifies the login name of an API account created on the server itself. 

{phang}
{opt password(string)} the corresponding password of the API account specified in {opt user(string)}. 


{marker optiona}{...}
{dlgtab:Optional}

{phang}
{opt comm:ent(string)} text to be attached to rejection. Comment will be visible in the Status History as well as final survey data set. The enumerator will see this comment in the dashboard folder "Rejected" attached to the interview case. If not specified, no comment will be attached!" 

{phang}
{opt id:(var)} by default, the command uses the variable {browse "https://support.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/":interview__id} as the unique identifier of each interview. 
If interview__id has been renamed {opt id:(var)} can be used to indicate the new variable. Must be unique 32-character long identifier generated by Survey Solutions.

{marker sursol_rejectHQ_rpath}{...}
{phang}
{opt rpath(string)} specifies the path to the R application through which the data export request to the server is transmitted. {opt sursol rejectHQ} assumes that the executable can 
be found in "C:\Program Files\R\R-X.X.X\bin\xBITVERSION\" if Windows is OS. For Linux/Mac users, it looks at "usr/bin/R". It returns errors if it is 
not possible to detect any executable in the default or specified folder.

{marker debugging}{...}
{title:Debugging}

{pstd} If you encounter the problem that the windows/mac shell box opens but closes shortly after without any interviews being rejected by HQ: {p_end}
{pstd}{cmd:sursol rejectHQ} relies on various R packages. By default, those R packages are being installed if the command can not locate the packages.{p_end} 
{pstd}However, some users reported that this is not working properly. This is most likely because of Stata / Windows or Mac Shell Box not having administrator rights to install the packages.{p_end}
{pstd}Therefore, try to install the following packages manually in R by opening R, either in IDE's such as RStudio or R.exe itself: {p_end}

{synoptline}
{pstd}	install.packages("stringr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("jsonlite", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{pstd}	install.packages("httr", repos = 'https://cloud.r-project.org/', dep = TRUE){p_end}
{synoptline}

{pstd}Make sure that you have administrator rights. Afterwards, {cmd:sursol rejectHQ} should run. {p_end}

{title:Examples}

{pstd}Load survey dataset and reject interviews if q61 is larger than 7 (q61 is a variable defined in the Designer asking "How many days are there in a week"){p_end}

{phang2}{cmd:. use "C:\Users\survey_X.dta" ,clear }{p_end}

{phang2}{cmd:. sursol rejectHQ if q61>7, server("https://projectX.mysurvey.solutions") /// }{p_end}
{phang2}{cmd:. user("API_acc") ///  }{p_end}
{phang2}{cmd:. password("API_acc2019")  /// }{p_end}
{phang2}{cmd:. comment("Look at Q61. Answer is not possible at all. Please confirm.") }{p_end}


{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!

{pstd}{cmd:sursol rejectHQ} was last updated using Survey Solutions 20.10
