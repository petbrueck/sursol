{smcl}
{* *! version 20.05.2  May 2020}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{manlink sursol} {hline 2}} is a package of Stata commands that standardizes and simplifies repetitive tasks within the realm of primary data collection using the Survey Solutions software package.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:sursol} {it:subcommand} ... [{cmd:,} {it:options}]


{marker servermanagement}{...}
{title:Server and Field Management}

{pstd} Any {it:subcommand} of the Server and Field Management makes use of the {browse "https://support.mysurvey.solutions/headquarters/api/survey-solutions-api/":Survey Solutions API}.
To use the following commands, the {browse "https://www.r-project.org/":R software environment} needs to be installed on your machine. But no further R knowledge is required. {p_end}

{synoptset 16}{...}
{synopthdr:subcommand}
{synoptline}
{synopt :{helpb sursol_export:export}}downloads data of any questionnaire from a Survey Solutions Server{p_end}
{synopt :{helpb sursol_approveHQ:[un]approveHQ}}(un)approves interview(s) as Headquarter based on specified rule {p_end}
{synopt :{helpb sursol_rejectHQ:rejectHQ}}rejects interview(s) as Headquarter based on specified rule {p_end}
{synopt :{helpb sursol_approve:approve}}approves interview(s) as Supervisor based on specified rule{p_end}
{synopt :{helpb sursol_reject:reject}}rejects interview(s) as Supervisor based on specified rule{p_end}
{synopt :{helpb sursol_varcomm:varcomm}}leaves a comment at specified variable for specified interview(s) on the Survey Solutions Server{p_end}
{synopt :{helpb sursol_actionlog:actionlog}}downloads {browse "https://support.mysurvey.solutions/headquarters/reporting/detailed-action-log/":detailed action log}
 for all interviewer users created on a Survey Solutions Server{p_end}
{synopt :{helpb sursol_userreport:userreport}}downloads {browse "https://support.mysurvey.solutions/headquarters/reporting/downloadable-report-on-interviewers/":report on interviewers} 
for all interviewer users created on a Survey Solutions Server{p_end}
{synoptline}
{p2colreset}{...}

{marker datamanagement}{...}
{title:Data Management}

{synoptset 16}{...}
{synopthdr:subcommand}
{synoptline}
{synopt :{helpb sursol_append:append}}detects all Survey Solutions Version folders  in the specified working directory and appends the survey data versions into master files.{p_end}
{synopt :{helpb sursol_para:para}}detects all Survey Solutions Version folders in the specified working directory, appends all para data versions and creates descriptive statistics for each interview{p_end}
{synopt :{helpb sursol_import:import}}imports tabular data exported by Survey Solutions{p_end}
{synopt :{helpb sursol_getcomm:getcomm}}merges all comments left at all questions during the interview process to the survey data files{p_end}
{synopt :{helpb sursol_mscrelab:mscrelab}}creates new variable label for multi-select questions for which category value title was not fully displayed in original variable label{p_end}
{synopt :{helpb sursol_reshape:reshape}}reshapes data from long to wide using the value labels of a roster id variable in the variable labels of reshaped {it: stub} variables{p_end}
{synoptline}
{p2colreset}{...}

{marker translation}{...}
{title:Translation management}

{synoptset 16}{...}
{synopthdr:subcommand}
{synoptline}
{synopt :{helpb sursol_transcheck:transcheck}}compares translation against original text to identify software-related misalignments{p_end}
{synopt :{helpb sursol_transcolor:transcolor}}changes the font color of specific text items in the translation file{p_end}
{synoptline}
{p2colreset}{...}


{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Some commands build upon previous work by colleagues and other Survey Solutions users. Those are credited within each respective help file. 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!


{title:Updates}

{pstd}Most commands of {cmd:sursol} were last updated using Survey Solutions 20.05

{pstd}The routines are updated continously. It is worthwhile to stop by from time to time on {browse "https://github.com/petbrueck/sursol":GitHub} to install any updates.

