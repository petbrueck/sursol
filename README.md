# sursol - Stata codes for working with the Survey Solutions data collection software

**sursol** is a set of user-written Stata commands that standardizes and simplifies repetitive tasks within the realm of data collection using the Survey Solutions software package.

### **Content**
The list of sub-commands of **sursol**  is work in progres and improved continuously.  While `export`,  `append`,  `para` and  `transcheck` have been tested in numerous cases, all other commands might be buggy. No responsibility or liability for the correct functionality of the commands is taken!

- `sursol export`  downloads survey data of a questionnaire from a Survey Solutions Server. R software is required.
- `sursol append`  detects all Survey Solutions Version folders  in the specified working directory and appends the survey data versions into master files. 
- `sursol para`  detects all Survey Solutions Version folders in the specified working directory, appends all para data versions and creates descriptive statistics for each interview.
- `sursol [un]approveHQ` (un)approves interviews on the Survey Solutions Server as Headquarter based on specified rule. R software is required.
- `sursol varcomm`  leaves a comment at specified variable for specified interviews on the Survey Solutions Server. R software is required.
- `sursol import` imports tabular data exported by Survey Solutions.
- `sursol transcheck` compares translation against original text to identify software-related misalignments.



===  
*Disclaimer: The commands are not affiliated, associated, endorsed by or in any way officially connected with the  [Data group of The World Bank](https://mysurvey.solutions/) that developes the Survey Solutions software.


