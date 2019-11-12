{smcl}
{cmd:help sursol getcomm}
{hline}

{title:Title}

{p 5 15}
{cmd:sursol getcomm} {hline 2} merges all comments left at variables during interview process to the respective variables. 



{title:Syntax}

{p 8}
{cmd:sursol getcomm}  [{cmd:using} {it:{help filename}}] {cmd:,}  {opt qxvar(string)} [{it:{help sursol getcomm##sursol_getcomm_options:getcomm options}}]

If interview__comments already in use {it:[{cmd:using} {it:{help filename}}]} not required.  TO BE CONTINUED.............................

{marker sursol_getcomm_options}{...}
{synoptset 21 tabbed}{...}
{synopthdr:getcomm options }
{synoptline}
{synopt:{opt qxvar(string)}}questionnaire variable specified in Survey Solutions Questionnaire Designer. Required.{p_end}  
{synopt:{opt id:(var)}}variable that contains the globally unique identifier of each interview according to Survey Solutions format{p_end}
{synopt:{opt dir:ectory)}}path in which the survey data files are saved. Required if those files are not in the current working directory.{p_end}
{synopt:{opt stath:istory}} descriptionTBADDED{p_end}
{synopt:{opt rosterid:(var)}}descriptionTBADDED{p_end}
{synoptline}




{title:Author}

{pstd}Peter Brückmann, p.brueckmann@mailbox.org 

Please report any bugs!!

No responsibility or liability for the correct functionality of the do-file taken!

{cmd:sursol getcomm} was last updated using Survey Solutions 19.08
