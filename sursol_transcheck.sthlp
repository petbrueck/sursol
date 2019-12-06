{smcl}
{cmd:help sursol transcheck }
{hline}

{title:Title}

{p 5 15}
{cmd:sursol transcheck} {hline 2} identifies software-related misalignments between Original Text and Translation Text. 


{title:Syntax}

{p 8 17 2}
{cmd:sursol transcheck}
{it:Original} {it:Translation} [{cmd:using} {it:{help filename}}]
{cmd:,}[{it:{help sursol transcheck##sursol transcheck_options:transcheck options}}]


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{it:Original}} string variable that contains the original text.{p_end}
{synopt:{it:Translation}} string variable that contains the translation of the original text.{p_end}
{synoptline}
{pstd}
If translation file not loaded to the dataset, use {cmd:using} {it:{help filename}}, where {it:{help filename}} is an excel file that contains the original and translation text in two seperate columns. 
{it:Original} and {it:Translation} specified in the {cmd:sursol transcheck} command must be in the first row of this excel file. {p_end}


{marker sursol_transcheck_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:transcheck options }
{synoptline}
{synopt:{opt html}}if specified, misalignments of html tags that can be used to format text will be checked{p_end}
{synopt:{opt sheet(string)}}if {cmd:using} {it:{help filename}} is specified, {opt sheet(string)} can be used to indicate the excel sheet in which {it:Original} and {it:Translation} can be found{p_end}
{synopt:{opt clear}}if {cmd:using} {it:{help filename}} is specified, clear indicates that it is okay to replace the data in memory, even though the current data have not been saved to disk.{p_end}
{synopt:{opt sub:stitution(string)}}in Survey Solutions, software substitutions are defined by %-signs, e.g. %rostertitle%. If another character is used, specify it in {opt sub:stitution(string)}{p_end}
{synopt:{opt miss:ing}} includes empty cells of translation in the check syntax and returns a variable indicating missing translations.{p_end}
{synopt:{opt sort}} arranges the observations in ascending order based on generated variable {it:problem} {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sursol transcheck} can be used to identify software-related misalignments between an Original Text and its Translation.  {p_end}
{pstd}
In any CAPI-software, it is of importance that the translation of questionnaire items, also contain software codes that have been included in the 
original script. Those codes mainly imply html-code for formatting text as well as software "substitutions" which are used to reference previous given answers in e.g. a question text or error messages. {p_end}

{pstd}
Especially for large and complex surveys, machine-readable translation files contain too much text to check for consistency. 
This command will flag misalignments if:  {p_end}

{pstd} 
a) Text substitutions (e.g. %rostertitle%) or HTML tags, or HTML tags if {opt html} is specified, are to be found in the {it:Original} but not in the {it:Translation} text and vice versa{p_end}

{pstd} 
b) The number of text substitutions, or HTML tags if {opt html} is specified, differs between the {it:Original} and the {it:Translation} text. E.g. two times %rostertitle% used in {it:Original} but only once in {it:Translation}.{p_end}

{pstd} 
The command creates the following variables, if applicable:{p_end}

		{hline 20}
        	problem 
		sub_missing_trans   
		sub_missing_orig 
		html_missing_trans
		html_missing_orig 
		no_translation         
	 	{hline 20}


{title:Examples}

{phang2}{cmd:. sursol transcheck Originaltext Translation using "C:\Users\translation.xlsx", clear missing}{p_end}

{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

Please report any bugs!!

No responsibility or liability for the correct functionality of the do-file taken!

{cmd:sursol transcheck} was last updated using Survey Solutions 19.11
