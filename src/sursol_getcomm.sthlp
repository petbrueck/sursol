{smcl}
{cmd:help sursol getcomm}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol getcomm} {hline 2} merges all comments left at variables during interview process to the respective variables. 



{title:Syntax}

{p 8}
{cmd:sursol getcomm}  [{cmd:using} {it:{help filename}}] {cmd:,}  {opt qxvar(string)} [{it:{help sursol getcomm##sursol_getcomm_options:getcomm options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{marker sursol_getcomm_qxvar}{...}
{synopt:{opt qxvar(string)}}questionnaire variable specified in Survey Solutions Designer{p_end}  
{synoptline}

{marker sursol_getcomm_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:getcomm options }
{synoptline}
{synopt:{opt id:(var)}}variable that contains the globally unique identifier of each interview according to Survey Solutions format. By default: interview__id{p_end}
{synopt:{opt dir:ectory(string)}}path in which the survey data files are saved. Required if those files are not in the current working directory.{p_end}
{synopt:{opt stath:istory}} Comments left at interview milestones, e.g. when completing or rejecting, will be merged to the interview level file specified in {opt qxvar(string)}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt sursol getcomms} aims to attach all comments that have been left by Users to an interview to the respective variables within the survey data files. 

{pstd}
Survey Solutions exports all comments that are left by Interviewer, Supervisor, Headquarter or Admin Users within the{browse "https://support.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/": System Generated File} 
interview__comments.dta. 

{pstd}
In many scenarios it might be useful to have the comments in one place, next to the question/variable that the comment was attached to. To this end, this command identifies all comments within interview__comments.dta and merges it 
with the survey data using the suffix "_comm". 

{pstd}
For each comment, the Role of the person that left the comment (e.g. Interviewer) is attached to the comment.

{pstd}
If multiple comments are left at one question, the chronological order of comments is indicated. E.g. 1. Interviewer: "First comment", 2. Supervisor: "Second comment".

{pstd}
For comments left at questions that are placed within a roster the interview__id + respective roster id is used to correctly attribute the comment to the correct roster item. 

{pstd}
{it: {opt ATTENTION:}}: If there are nested rosters that require multiple roster id's, the command identifies all variables that have the suffix "__id" and assumes that the order of 
those variables aligns with the level of nesting of such rosters. It is therefore advised to use this command with a very early version of the exported data. 
If the roster variables have been reordered before running this command will produce an incorrect output! 


{title:Example}

{pstd}Look up comments found in interview__comments.dta and attach them to the files saved in the folder "${download}"{p_end}

{phang2}{cmd:. sursol getcomm using "${download}//interview__comments.dta", ///}{p_end}
{phang2}{cmd:. dir("${download}") ///}{p_end}
{phang2}{cmd:. qxvar("projectX") ///}{p_end}
{phang2}{cmd:. stathistory}{p_end}



{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the command is taken!

{pstd}{cmd:sursol getcomm} was last updated using Survey Solutions 19.11
