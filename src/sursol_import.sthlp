{smcl}
{cmd:help sursol import }
{hline}

{title:Title}

{p 5 15}
{cmd:sursol import} {hline 2} detects all exported Survey Solutions folders as specified in {it:folder_uniqueid} and imports all .tab survey data into Stata.


{title:Syntax}

{p 8 17 2}
{cmd:sursol import}
{it:folder_uniqueid} 
{cmd:,} {opt dir:ectory(string)}  [{it:{help sursol import##sursol import_options:sursol import options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{it:folder_uniqueid}}string. Unique identifier of exported survey data which is contained in the folder names in {opt directory(string)}{p_end}
{synopt:{opt dir:ectory(string)}}path in which all exported survey data folders can be found {p_end}
{synoptline}



{marker sursol_import_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:sursol import options }
{synoptline}
{synopt:{opt ex:port(string)}}folder in which the imported data shall be exported{p_end}
{synopt:{opt version(real)}}Stata version in which data has to be saved{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sursol import} identifies all folders in the path specified in {opt directory} of which the folder names contain {it: folder_uniqueid}.
Within each located folder, the command identifies all containing .tab files and imports each file into stata and saves them either in {opt directory} or {opt export}.{p_end}
{pstd} 
Previously existing files in the path in which data are saved are overwritten. {p_end}


{marker syntax}{...}
{title:Syntax}

{dlgtab:Required}

{phang}
{it: folder_uniqueid} specify using a unique identifier that can be found in all exported folders which shall be imported that can be found in {opt directory(string)}.
Usually either the name of the questionnaire as found on the server or the questionnaire variable as defined in the Questionnaire Designer. Do not include any of the following: "VERSION #_STATA_ALL".  

{phang}
{marker sursol_import_directory}{...}
{opt dir:ectory(string)} specifies the path in which the exported data files have been unzipped to. It is required that each questionnaire version has its own unique folder. 


{marker optiona}{...}
{dlgtab:Optional}

{marker sursol_import_export}{...}
{phang}
{opt ex:port(string)} by default, {cmd: sursol import} saves master files in {opt dir:ectory(string)}. {opt ex:port(string)} can be used to specify other folder paths.

{phang}
{opt version(real)} By default, {cmd: sursol import} saves the imported data in the Stata {help version:version} that is currently loaded.
 If the data has to be saved in an older Stata version, use this option to specify which Stata version it should be saved in.


{title:Examples}

{pstd}Idenitfy and import all versions of the questionnaire "Project X Baseline Survey" and save them into Stata 13 (while Stata 15 has been used){p_end}
{phang2}{cmd:. sursol import "Project X Baseline Survey",  dir("${download}") ///}{p_end}
{phang2}{cmd:. export("C:\Users\username\Desktop\Project X\RAW_FILES")  version(13) }{p_end}

{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

Please report any bugs!!

No responsibility or liability for the correct functionality of the do-file taken!

{cmd:sursol import} was last updated using Survey Solutions 19.07