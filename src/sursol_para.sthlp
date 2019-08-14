{smcl}
{cmd:help sursol para}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol para} {hline 2} detects all Survey Solutions export folders in the specified working directory, appends all para data versions and builds variables for each interview. 

{title:Syntax}

{p 8}
{cmd:sursol para} {it:folder_uniqueid} {cmd:,} {opt dir:ectory(string)} [{it:{help sursol para##sursol para_options:sursol paraoptions}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{marker sursol_para_directory}{...}
{synopt:{it:folder_uniqueid}}string. Unique identifier of exported survey data which is contained in the folder names in {opt directory(string)}{p_end}
{synopt:{opt directory(string)}} path where all exported survey data folders can be found in which the paradata.tabs are saved{p_end}
{synoptline}


{marker sursol_para_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:sursol paraoptions }
{synoptline}
{synopt:{opt export(string)}} path in which the appended data shall be exported{p_end}
{synopt:{opt time(integer)}} ignores time difference between individual answers set larger than {it:integer} minutes when calculating 
durations. By default 30 minutes{p_end}
{synopt:{opt pausetime(integer)}} ignores breaks longer than {it: integer} minutes while building {it: length_pause}. By default, 60 minutes{p_end}
{synopt:{opt dur1-10(var1 var2)}} calculates time spent between {it: var1} and {it:var2}. dur1({it:var1} {it:var2}) - dur10({it:var1} {it:var2}) can be specified {p_end}
{synoptline}

{title:Description}

{p 4 4 2} {cmd:sursol para} identifies all sub-folders in {opt directory} named "{it:folder_uniqueid}_VERSION*}". 
For each version, the respective paradata is imported, cleaned, variables created and saved as "paradata_cleaned.tab" within each version's sub-directory.
In addition, a paradata overview file is saved at {opt directory}. 

{p 4 4 2} {cmd:sursol para} builds the following variables:

{synoptset 21 tabbed}{...}
{synopthdr:Variable}
{synoptline}
{synopt:{it: rawdurint} }  Time passed between first and last action (seconds){p_end}
{synopt:{it: clean_durint} }Active time spent on interview. Actions that took longer than {opt time(integer)} and breaks are excluded{p_end}
{synopt:{it: rawdur_fstcompl} } Time passed between first action and first time interview was completed (seconds){p_end}
{synopt:{it: cleandur_fstcompl} } Time passed between first action and first time interview was completed (seconds). Actions that took longer than {opt time(integer)} and breaks are excluded{p_end}
{synopt:{it: length_pause} } Time (seconds) interview was paused.  Breaks longer than {opt pausetime(integer)} are filtered out {p_end}
{marker sursol_para_dur}{...}
{synopt:{it: dur1-dur10} } If option {opt dur1-10(var1 var2)} specified, contains the time spent between {it:var1}-{it:var2} in seconds {p_end}
{synopt:{it: n_answer } } # of answers set. For multi-select questions each option ticked, one answer{p_end}
{synopt:{it: answ_pm } } Answers per minute: {it:n_answer}/{it:clean_durint} {p_end}
{synopt:{it: n_removed} } # of times question answers have been changed and/or removed.{p_end}
{synopt:{it: n_invalidq} } # of error messages displayed during interview*{p_end}
{synoptline}
{phang}*Please note, this does not reflect the number of error messages still displayed at the end of an interview. This indicator can be found in the "interview_diagnostics.dta" file provided by Survey Solutions. 

{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}
{phang}
{it: folder_uniqueid} specify using a unique identifier that can be found in the name of folders in which the paradata.tab files of interest can be found in {opt directory(string)}.
Usually either the name of the questionnaire as found on the server or the questionnaire variable as defined in the Questionnaire Designer. Do not include any of the following: "VERSION #_STATA_ALL".  
Case sensitive!

{phang}
{it: {opt directory(string)}} path where all exported survey data folders can be found in which the paradata.tabs are saved. It is required that one seperate folder for each Questionnaire Version exists. 



{marker optiona}{...}
{dlgtab:Optional}

{phang}
{opt export(string)} by default, {opt sursol para} appends all paradata.tab files of all questionnaire version's identified in all folders in {opt directory(string)} and saves the master file in {opt directory(string)}. 
{opt export(string)} can be used to save the master files in a different path. 

{phang}
{opt time(integer)} by default all actions that took more than 30 minutes between individual answers are set to missing. {opt time(integer)} can be used to determine different number of minutes after which actions are ignored. 
The assumption is that the time between two question should not be longer than X and would indicate time not actively spent interviewing 

{phang}
{opt pausetime(integer)} by default all time passed between enumerator paused interview and resumed longer than 60 minutes are ignored.   {opt pausetime(integer)} can be used to change this threshold. 

{phang}
{opt dur1-5(var1 var2)} those options can be used to calculate the time spent between two specific questions. 
If var1 or var2 can not be found in questionnaire OR {it:var1} is answered after {it:var2}, variable {it:durX} will be set to missing.
 Possible applications: Time spent at key/filter questions or duration of specific sections. 

{title:Examples}

{pstd}All Interview Versions have been exported and unzipped into ${downloads} and I would like to ignore actions that lasted longer than 40 minutes:{p_end}

{phang2}{cmd:.  sursol para, dir(${downloads}) time(40) }{p_end}
