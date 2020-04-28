{smcl}
{cmd:help sursol transcolor }
{hline}

{title:Title}

{p 5 15}
{cmd:sursol transcolor} {hline 2} changes the font color of specific text items in the translation file. 


{title:Syntax}

{p 8 17 2}
{cmd:sursol transcolor}
{it:Translation} [{cmd:using} {it:{help filename}}]
{cmd:,}[{it:{help sursol transcolor##sursol transcolor_options:transcolor options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{it:Translation}} string variable that contains the translation of the original text.{p_end}
{synoptline}
{pstd}
If translation file not loaded to the dataset, use {cmd:using} {it:{help filename}}, where {it:{help filename}} is an excel file that contains the original and translation text in two seperate columns. 
{it:Original} and {it:Translation} specified in the {cmd:sursol transcolor} command must be in the first row of this excel file. {p_end}


{marker sursol_transcolor_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:transcolor options }
{synoptline}
{synopt:{opt sheet(string)}}if {cmd:using} {it:{help filename}} is specified, {opt sheet(string)} can be used to indicate the excel sheet in which {it:Original} and {it:Translation} can be found{p_end}
{synopt:{opt clear}}if {cmd:using} {it:{help filename}} is specified, clear indicates that it is okay to replace the data in memory, even though the current data have not been saved to disk.{p_end}
{synopt:{opt only(string)}}by default, any text substitution within {it:Translation} will be changed. Use {opt only(string)} to specify specific text. Case sensitive. {p_end}
{synopt:{opt sub:stitution(string)}}in Survey Solutions, software substitutions are defined by %-signs, e.g. %rostertitle%. If another character is used, specify it in {opt sub:stitution(string)}{p_end}
{synopt:{opt color(string)}}by default, color of text items will be changed to "maroon". Use {opt color(string)} to specify other HTML 4.01 color name or any RGB Value. {p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:sursol transcolor} can be used to color specific text items in the translation file which will subsequently be uploaded to the Survey Solutions Designer.{p_end}

{pstd}
It sometimes can be cumbersome for translators to include html-tags within the translation and to place it correctly. In contrast to do this in the Survey Solutions Designer, 
this command can be used to change the color of specific items after the translation.{p_end}

{pstd}
By default, {cmd:sursol transcolor} identifies any software text substitution (e.g. %rostertitle%) within {it:Translation} and changes its font color to "maroon", or any other color specified in {opt color(string)}.
{p_end}

{pstd}
{opt only(string)} can be used to change the color of specific text items, e.g. "During the last 12 months" or "%member%". 
{p_end}
{pstd}


{title:Examples}

    {hline}
{pstd}Questionnaire was designed in English and shall be administered in English. {p_end}
{pstd}Instead of coloring any text substititon manually within the Designer Interface, do it in a "translation"-file: {p_end}

{pstd}Import current template with empty translation column.{p_end}
{phang2}{cmd:. import excel "${drive}//template_file.xlsx", clear sheet("Translations") firstrow allstring} {p_end}

{pstd}Replace the empty translation column with Originaltext if it contains some text substitution (e.g. %rostertitle%).{p_end}
{phang2}{cmd:. replace Translation=Originaltext if (length(Originaltext) - length(subinstr(Originaltext, "%", "", .)))>1} {p_end}

{pstd}Change color of any text substitution to Fuchsia.{p_end}
{phang2}{cmd:. sursol transcolor Translation, color("Fuchsia")} {p_end}

{pstd}Export the excel file which can be uploaded to the Designer .{p_end}
{phang2}{cmd:. export excel "${drive}\english_colored_upload.xlsx", replace sheet("Translations") firstrow(varlab) missing(" ")} {p_end}
    {hline}
{pstd}Translation file received from translator. Specific text substitution and text phrases shall be colored.{p_end}

{pstd}Change color of specific text substitution within a roster as defined in the Designer to Maroon.{p_end}
{phang2}{cmd:. sursol transcolor Translation using ${drive}//translated_file.xlsx" , clear only(%hh_assets%)} {p_end}

{pstd}Change color of translated phrase "During the last 12 months" to specific RGB color.{p_end}
{phang2}{cmd:. sursol transcolor Translation, only("Au cours des 12 derniers mois") color("#FFFF01")} {p_end}

{pstd}Export the excel file which can be uploaded to the Designer .{p_end}
{phang2}{cmd:. export excel "${drive}\translation_colored_upload.xlsx", replace sheet("Translations") firstrow(varlab) missing(" ")} {p_end}
    {hline}

{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!

{pstd}{cmd:sursol transcolor} was last updated using Survey Solutions 20.01
