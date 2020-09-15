# sursol - Stata codes for Survey Solutions 

**sursol** is a set of user-written Stata commands that standardizes and simplifies repetitive tasks within the realm of data collection using the Survey Solutions software package.

## **Installation**
Type 

`net install sursol , from("https://raw.githubusercontent.com/petbrueck/sursol/master/src") replace`  

in your Stata command window. Once installed, type `help sursol` to retrieve more information about the package.

## **Overview**
The list of sub-commands of **sursol** is work in progress and improved continuously. Some of those commands have not been used in many survey scenarios which increases the likelihood of bugs. Anyone is more than welcome to report any bug, issues or provide feature requests!

### Server and Field Management
 Any subcommand of the Server and Field Management makes use of the [Survey Solutions API](https://support.mysurvey.solutions/headquarters/api/survey-solutions-api/). To use the following commands, the [R software environment](https://www.r-project.org/) needs to be installed on your machine. But no further R knowledge is required.

- `sursol export`  downloads survey data of a questionnaire from a Survey Solutions Server. 
- `sursol [un]approveHQ` (un)approves interviews on the Survey Solutions Server as Headquarter based on specified rule.
- `sursol rejectHQ`  rejects interview(s) as Headquarter based on specified rule.
- `sursol approve`  approves interview(s) as Supervisor based on specified rule. 
- `sursol reject`  rejects interview(s) as Supervisor based on specified rule. 
- `sursol varcomm`  leaves a comment at specified variable for specified interviews on the Survey Solutions Server. 
- `sursol actionlog`  downloads detailed action log for all interviewer users created on a Survey Solutions Server. 
- `sursol userreport`  exports detailed interviewer report for all interviewer users created on a Survey Solutions Server. 

### Data Management
- `sursol append`  detects all Survey Solutions Version folders  in the specified working directory and appends the survey data versions into master files. 
- `sursol para`  detects all Survey Solutions Version folders in the specified working directory, appends all para data versions and creates descriptive statistics for each interview.
- `sursol import` imports tabular data exported by Survey Solutions.
- `sursol getcomm` merges all comments left at all questions during the interview process to the data files. 
- `sursol mscrelab` creates new variable label for multi-select questions for which category value title was not fully displayed in original variable label. 
- `sursol reshape` reshapes data from long to wide using the value labels of a roster id variable in the variable labels of reshaped stub variables.

### Translation Management
- `sursol transcheck` compares translation against original text to identify software-related misalignments.
- `sursol transcolor` changes the font color of specific text items in the translation file. 




## Disclaimer
The commands are not affiliated, associated, endorsed by or in any way officially connected with the [Data group of The World Bank](https://mysurvey.solutions/) that is developing the Survey Solutions software

No responsibility or liability for the correct functionality of the commands is taken!

Please report any bug, issues or provide feature requests!

