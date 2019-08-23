{smcl}
{cmd:help sursol append }
{hline}

{title:Title}

{p 5 15}
{cmd:sursol append} {hline 2} detects all Survey Solutions folders as specified in {it:folder_uniqueid} and appends all survey data versions. 


{title:Syntax}

{p 8 17 2}
{cmd:sursol append}
{it:folder_uniqueid} 
{cmd:,} {opt dir:ectory(string)}  [{it:{help sursol append##sursol append_options:sursol append options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{it:folder_uniqueid}}string. Unique identifier of exported survey data which is contained in the folder names in {opt directory(string)}{p_end}
{synopt:{opt dir:ectory(string)}}path in which all exported survey data folders can be found {p_end}
{synoptline}



{marker sursol_append_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:sursol append options }
{synoptline}
{synopt:{opt ex:port(string)}}folder in which the appended data shall be exported{p_end}
{synopt:{opt se:rver(string)}}prefix of server url on which the collected data is hosted{p_end}
{synopt:{opt co:py(varlist)}}copies all variables specified in {it:varlist} from questionnaire level file to all other survey data files{p_end}
{synopt:{opt noac:tions}}no descriptive variables found in {it:interview__actions.dta} and {it:interview__comments.dta} will be merged to the questionnaire level file{p_end}
{synopt:{opt nodiag:nostics}}no descriptive variables found in {it:interview__diagnostics.dta} will be merged to the questionnaire level file{p_end}
{synopt:{opt qxvar(string)}}questionnaire variable specified in Survey Solutions Questionnaire Designer{p_end}  
{synopt:{opt noskip}}also saves empty datafile in the folder specified in {opt ex:port(string)}{p_end}  
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sursol append} identifies all folders in the path specified in {opt directory} of which the folder names contain {it: folder_uniqueid}.
Within each located folder, the command identifies all containing .dta files and appends the respective files in one master version. The master files are either saved in {opt directory} or {opt export}.{p_end}
{pstd}
A variable containing the version name is generated in the questionnaire level file. Variables that are string in one version and numeric 
in another are converted to string to avoid data loss. {p_end}
{pstd} 
Previously existing files in the path in which data is exported are overwritten. {p_end}


{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}

{phang}
{it: folder_uniqueid} specify using a unique identifier that can be found in all exported folders which shall be appended that can be found in {opt directory(string)}.
Usually either the name of the questionnaire as found on the server or the questionnaire variable as defined in the Questionnaire Designer. Do not include any of the following: "VERSION #_STATA_ALL".  

{phang}
{marker sursol_append_directory}{...}
{opt dir:ectory(string)} specifies the path in which the exported data files have been unzipped to. It is required that each questionnaire version has its own unique folder. 


{marker optiona}{...}
{dlgtab:Optional}

{marker sursol_append_export}{...}
{phang}
{opt ex:port(string)} by default, {cmd: sursol append} saves master files in {opt dir:ectory(string)}. {opt ex:port(string)} can be used to specify other folder paths.

{marker sursol_append_qxvar}{...}
{phang}
{opt qxvar(string)} can be used to specify the {browse "https://support.mysurvey.solutions/questionnaire-designer/components/questionnaire-variable/":Questionnaire Variable} which reflects the name of the main questionnaire level file. 
To be used if the Questionnaire Variable does not match {it:folder_uniqueid} and option {opt copy(varlist)} is used or {opt noactions} and/or {opt nodiagnostics} is NOT specified.

{phang}
{opt se:rver(string)} specifies the server on which the survey is hosted. Will be used to create URLs for each interview that will redirect the user to the location where each interview is hosted. 
Only prefix of domain name required: PREFIX.mysurvey.solutions. Full domain name, protocol and other URL information will be added automatically. If not specified, interview link variabe (intlink) will be empty. 

{phang}
{opt co:py(varlist)} {it: varlist} from the questionnaire level file (either {it:folder_uniqueid}.dta or {it:questionnaire variable.dta}) will be merged to all other 
interview files. Useful for variables that are used in future data processing such as identifiying variables (region, village, treatment status). 

{phang}
{opt noac:tions} By default, {cmd: sursol append} makes use of information in {it: interview__actions.dta} and merges all variables to the questionnaire level data file.
 Useful for data quality purposes and future documentation of the data generation process. This will be surpressed if {opt noac:tions} is specified. 

{phang}
{opt nodiag:nostics} By default, {cmd: sursol append} makes use of information in {it: interview__diagnostics.dta} and merges all variables to the questionnaire level
 data file. Useful for data quality purposes and future documentation of the data generation process. This will be surpressed if {opt nodiag:nostics} is specified. 

{phang}
{opt noskip} By default, {cmd: sursol append} ignores empty files of each version and does not attempt to append or save this file in the specified export folder. 
Especially in the beginning of data collections, rosters and their related data files can be empty. If {opt noskip} is specified, those empty files will still be saved which guarantees that the full data structure is available. 

by default, data files of each version with no observations are skipped. 

{title:Examples}

{pstd}Idenitfy and append all versions of the questionnaire "Project X Baseline Survey" which was hosted on "https://projectX.mysurvey.solutions" {p_end}
{phang2}{cmd:. sursol append "Project X Baseline Survey",  dir("${download}") ///}{p_end}
{phang2}{cmd:. export("C:\Users\username\Desktop\Project X\RAW_FILES") ///}{p_end}
{phang2}{cmd:. copy (village treatment)  ///}{p_end}
{phang2}{cmd:. qxvar("PROJECTX")  ///}{p_end}
{phang2}{cmd:. server("projectX")}{p_end}


{title:Author}

This command builds upon work by:

{pstd}Andreas Kutka, andreas.kutka@gmail.com

Revised and extended by:

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

Please report any bugs!!

No responsibility or liability for the correct functionality of the do-file taken!

{cmd:sursol append} was last updated using Survey Solutions 19.07

