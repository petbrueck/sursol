# sursol - Stata codes for Survey Solutions 

**sursol** is a set of user-written Stata commands that standardizes and simplifies repetitive tasks within the realm of data collection using the Survey Solutions software package.

## **Content**
The list of sub-commands of **sursol**  is work in progress and improved continuously. Some of those commandshave not been used in many survey scenarios which increases the likelihood of bugs. Anyone is more than welcome to report any bug or provide feature requests!

No responsibility or liability for the correct functionality of any of the commands is taken!

### Server and Field Management
- `sursol [un]approveHQ` (un)approves interviews on the Survey Solutions Server as Headquarter based on specified rule. R software needs to be installed.
- `sursol rejectHQ`  rejects interview(s) as Headquarter based on specified rule. R software needs to be installed. 
- `sursol reject`  rejects interview(s) as Supervisor based on specified rule. R software needs to be installed. 
- `sursol varcomm`  leaves a comment at specified variable for specified interviews on the Survey Solutions Server. R software needs to be installed.

### Data Management
- `sursol export`  downloads survey data of a questionnaire from a Survey Solutions Server. R software needs to be installed.
- `sursol append`  detects all Survey Solutions Version folders  in the specified working directory and appends the survey data versions into master files. 
- `sursol para`  detects all Survey Solutions Version folders in the specified working directory, appends all para data versions and creates descriptive statistics for each interview.
- `sursol import` imports tabular data exported by Survey Solutions.
- `sursol getcomm` merges all comments left at all questions during the interview process to the data files. !!Early Beta. No helpfile!!


### Translation Management
- `sursol transcheck` compares translation against original text to identify software-related misalignments.

## **Installation**
Type 

`net install sursol , from("https://raw.githubusercontent.com/petbrueck/sursol/master/src") replace`  

in your Stata command window.

Once installed, type
`help sursol` to retrieve more information about the package.







===  
*Disclaimer: The commands are not affiliated, associated, endorsed by or in any way officially connected with the [Data group of The World Bank](https://mysurvey.solutions/) that is developing the Survey Solutions software*

*As noted above, no responsibility or liability for the correct functionality of the commands is taken!*

*Please report any bug or provide feature requests!*

