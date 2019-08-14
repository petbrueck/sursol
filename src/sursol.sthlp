{smcl}
{* *! version 1.0.0  25/07/2019}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{manlink sursol} {hline 2}} is a package of Stata commands that standardizes and simplifies repetitive tasks within the realm of primary data collection using the Survey Solutions software package.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:sursol} {it:subcommand} ... [{cmd:,} {it:options}]

{marker syntax}{...}
{title:Syntax}

{synoptset 16}{...}
{synopthdr:subcommand}
{synoptline}
{synopt :{helpb sursol_export:export}}downloads survey data of a questionnaire from a Survey Solutions Server. R software is required{p_end}
{synopt :{helpb sursol_append:append}}detects all Survey Solutions folders as specified in {it:folder_uniqueid} and appends all survey data versions{p_end}
{synopt :{helpb sursol_para:para}}detects all Survey Solutions export folders in the specified working directory, appends all para data versions and builds variables for each interview. {p_end}
{synopt :{helpb sursol_approveHQ:[un]approve}}(un)approves interviews as Headquarter based on specified rule. R software is required{p_end}
{synopt :{helpb sursol_import:import}}imports tabular data exported by Survey Solutions{p_end}
{synopt :{helpb sursol_transcheck:transcheck}}compares translation against original text to identify software-related misalignments. {p_end}
{synopt :{helpb sursol_varcomm:varcomm}}compares translation against original text to identify software-related misalignments. {p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:sursol} DESSCRIPTON!DESCRIPTION DESCRIPTION DESCRIPTION DESCRIPTIONDESCRIPTION DESCRIPTIONDESCRIPTION DESCRIPTIONDESCRIPTION DESCRIPTIONDESCRIPTION DESCRIPTIONDESCRIPTION DESCRIPTIONDESCRIPTION DESCRIPTIONDESCRIPTION DESCRIPTION
SOME MORE DESCRIPTION
{pstd}
MORE DESCRIPTION

{pstd}
{p_end}
