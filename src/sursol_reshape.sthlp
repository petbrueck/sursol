{smcl}
{cmd:help sursol reshape}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol reshape} {hline 2} reshapes data from long to wide using the value labels of a roster id variable in the variable labels of reshaped {it: stub} variables.

{title:Syntax}

{p 8 17 2}
{cmd:sursol_reshape}
{it:stub} 
{cmd:,} {opt id(varlist)} {opt roster(varlist)}  [{opt sub:stitut(string)}}


{synoptset 21 tabbed}{...}
{synopthdr:Required }
{synoptline}
{synopt:{it:stub}} Variables that should be reshaped to wide. See {it:{help reshape:reshape}}.{p_end}
{synopt:{opt id(varlist)}} unique identifier that will be used as the {opt i(i)} in {it:{help reshape:reshape}}.{p_end} 
{synopt:{opt roster(varlist)}} the roster identifier created by Survey Solutions. Will be used as the {opt j(j)} in {it:{help reshape:reshape}}.
Should contain value labels of the roster row which will be added to the new generated {it:stub} variable labels after reshape.{p_end} 
{synoptline}
{pstd}

{synoptset 21 tabbed}{...}
{synopthdr:Optional }
{synoptline}
{synopt:{opt sub:stitut(string)}} by default, the value label of {it:stub} will be placed in the beginning of the variable label. If {opt sub:stitut(string)} specified, 
the string will be looked up in the variable labels of {it:stub} and replaced with the value labels of {opt roster(varlist)}. {p_end}
{synoptline}

{title:Description}

{pstd}Survey Solutions exports the content of questions that are not asked at the questionnaire level, but asked within rosters, in subordinate files. 
See {browse "https://support.mysurvey.solutions/headquarters/export/questionnaire-data-export-file-anatomy/":here}
for a detailed description on the Export File Anatomy. {p_end}

{pstd}Each subordinate file contains an id corresponding to the roster row code (@rowcode) of each item. 
In case of multi-select and fixed set of items {browse "https://support.mysurvey.solutions/questionnaire-designer/components/rosters/": rosters} 
such an id stores the respective rowname in its value label.{p_end}

{pstd}At the stage of data cleaning and/or analysis it is often necessary to reshape such subordinate files from long to wide to be able to merge it with the questionnaire level dataset, 
{it:{browse "https://support.mysurvey.solutions/questionnaire-designer/components/questionnaire-variable/":questionnaire_variable}.dta}.{p_end}

{pstd}In contrast to a simple {help reshape wide:reshape wide} command, {cmd:sursol reshape} can be used to preserve the value labels stored in the roster id variable.{p_end}


{title:Example}

{hline}
{pstd}File asset.dta contains the number of assets owned BY ASSET & OBSERVATION. E.g. for each interview__id there are 20 assets asked => 20 Rows per interview in dataset. {p_end}
{pstd}Variable "asset__id" contains the value of the asset + the name of the asset in the value label. Variable "q1" contains the quantity of each asset and its variable label: "How many %asset% does your family own?" {p_end}

{pstd}Aim is to reshape from long to wide and add the name of the asset to each variable label{p_end}

{phang2}{cmd:. sursol_reshape q1 ,id(interview__id) roster(asset__id) sub("%asset%") } {p_end}

{pstd}Result is wide dataset with 40 variables and only one observation per interview__id. q1__1 -> "How many ASSET1 does your family own", q1__2 -> "How many ASSET2 does your family own" {p_end}


{pstd}Assuming that "asset.dta" would be nested within a roster called "household_member.dta", you'd need to account for that when reshaping:{p_end} 
{phang2}{cmd:. sursol_reshape q1 ,id(interview__id household_member__id) roster(asset__id) sub("%asset%") } {p_end}

{pstd}Result would be the reshaped asset data at the interview-household_member leve.{p_end}
{hline}

{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

{pstd}Please report any bugs!!

{pstd}No responsibility or liability for the correct functionality of the do-file taken!

