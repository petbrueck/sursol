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
{synopt:{opt qxvar(string)}}{browse "https://support.mysurvey.solutions/questionnaire-designer/components/questionnaire-variable/":questionnaire variable} as specified in Survey Solutions Designer. 
Reflects the name of the main questionnaire level file. {p_end}
{synoptline}
{pstd}If the {it: interview__comments.dta} file is currently not loaded, use {it:{cmd:using} {help filename}}, where {it:{help filename}} is the filepath to {it: interview__comments.dta} {p_end}

{marker sursol_getcomm_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:getcomm options }
{synoptline}
{synopt:{opt id:(var)}}variable that contains the globally unique identifier of each interview according to Survey Solutions format. By default: interview__id{p_end}
{synopt:{opt dir:ectory(string)}}path in which the survey data files are saved. Required if those files are not in the current working directory.{p_end}
{synopt:{opt stath:istory}} Comments left at interview milestones, e.g. when completing or rejecting, will be merged to the interview level file specified in {opt qxvar(string)}{p_end}
{synopt:{opt onlyv:ar(varlist)}}look up only comments left at specific variables specified through {it:{help varlist}}. The * and ? character can be used following regular {it:{help varlist}} syntax {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt sursol getcomms} aims to attach all comments that have been left by users in an interview to the respective variables within the survey data files. 

{pstd}
Survey Solutions exports all comments that are left by Interviewer, Supervisor, Headquarter or Admin Users within the {browse "https://support.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/":System Generated File} 
{it:interview__comments.dta}. 

{pstd}
In many scenarios it might be useful to have the comments in one place, next to the question/variable that the comment was attached to. To this end, this command identifies all comments within {it:interview__comments.dta} and merges it 
with the survey data. Variables that contain the comment will use the respective variable name plus the suffix "_comm". 

{pstd}
For each comment, the role of the person that left the comment (e.g. Interviewer or Supervisor) is attached to the comment.

{pstd}
If multiple comments are left at one question, the chronological order of comments is indicated. E.g. 1. Interviewer: "First comment", 2. Supervisor: "Second comment".

{marker procedure}{...}
{title:Procedure}

{pstd}The command will look up all comments in the currently loaded dataset or file specified in {it:{cmd:using} {it:{help filename}}} by interview__id and roster id(s). {cmd:sursol getcomm} 
assumes that the dataset variable names and anatomy follows the Survey Solutions standard as described 
{browse "https://support.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/":in here.}  {p_end}

{pstd}If there have been any comments left at questions within a roster, the name of the respective roster file needs to be stored in the variable {it:roster} and the corresponding roster row ids in {it:id1-id4}. {p_end}

{pstd}{cmd:sursol getcomm} uses the names stored in variable {it:roster} to look up the respective data files. {p_end}

{pstd}If variable {it: roster} is empty or "UNKNOWN", the command assumes that those comments are placed to questions found in the main export file which in turn is named as specified in {opt qxvar(string)}. {p_end}

{pstd}Each file as listed in variable {it: roster} of {it: interview__comments.dta} is opened, the comments are placed next to each respective question and the file is saved and replaced. {p_end}

{phang}
{it: {opt ATTENTION 1:}}: It might be necessary to clean the {it:roster} variable within {it: interview__comments.dta} before {cmd:sursol getcomm} can be used.
If there are multiple rosters within a questionnaire, e.g. {it:roster1} and {it:roster2}, which both source from the same question and comments are left at a question which is placed within {it:roster2}:  
The comment itself will be stored in {it: interview__comments.dta} with variable {it: roster} containing the name {it:roster2}. 
However, the survey data of {it:roster1} and {it:roster2} is stored only in one file, named {it:roster1.dta}. {cmd:sursol getcomm} would therefore return an error that "roster2.dta does not exist". See 
{help sursol_getcomm##example:Examples} below for more information.{p_end}

{phang}
{it: {opt ATTENTION 2:}}: If there are nested rosters that require multiple roster id's, the command identifies all variables that have the suffix "__id" within the roster file and assumes that the order of 
those variables in the dataset aligns with the level of nesting of such rosters. Example: For a roster {it:"roster3"} nested within two other rosters, the dataset should be ordered from left to right: 
{it:interview__id}, {it:roster1__id}, {it:roster2__id}, {it:roster3__id}.
It is therefore advised to use this command with a very early version of the exported data. If the roster id variables within the roster file have been reordered before running this command will produce an incorrect output! {p_end}


{marker example}{...}
{title:Example}

{pstd}The survey used two rosters which were sourced from the same question. Comments were placed within {it: roster2} but the questions of {it: roster2} are stored within {it:roster1.dta}. {p_end}
{pstd}Before running {cmd:sursol getcomm}, clean {it: interview__comments.dta}. {p_end}

{phang2}{cmd:. use "C:\Users\ProjectX\RAW_DATA\interview__comments.dta", clear}{p_end}
{phang2}{cmd:. replace roster="roster1" if roster=="roster2"}{p_end}
{phang2}{cmd:. save "C:\Users\ProjectX\RAW_DATA\interview__comments.dta", replace}{p_end}

{pstd}Now we can run the command. Look up comments found in interview__comments.dta and attach them to the files saved in the folder "C:\Users\ProjectX\RAW_DATA\". {p_end}
{pstd}Let's use {opt stath:istory} to also attach the comments left at completing, rejection etc. to the dataset "projectX.dta".{p_end}

{phang2}{cmd:. sursol getcomm using ""C:\Users\ProjectX\RAW_DATA\interview__comments.dta", ///}{p_end}
{phang2}{cmd:. dir("C:\Users\Desktop\ProjectX\RAW_DATA\") ///}{p_end}
{phang2}{cmd:. qxvar("projectX") ///}{p_end}
{phang2}{cmd:. stathistory}{p_end}

{pstd}If you wish to only attach comments from question q12 and all variables starting with "q20_"{p_end}

{phang2}{cmd:. sursol getcomm using ""C:\Users\ProjectX\RAW_DATA\interview__comments.dta", ///}{p_end}
{phang2}{cmd:. dir("C:\Users\Desktop\ProjectX\RAW_DATA\") ///}{p_end}
{phang2}{cmd:. qxvar("projectX") ///}{p_end}
{phang2}{cmd:. onlyv(q12 q20_*)}{p_end}


{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the command is taken!

{pstd}{cmd:sursol getcomm} was last updated using Survey Solutions 20.06
