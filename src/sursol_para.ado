
capture program drop sursol_para

program sursol_para 
syntax anything,  DIRectory(string) [size] [EXport(string)] [TIME(real 30)] [PAUSETIME(real 60)] [DUR1(string)] [DUR2(string)] [DUR3(string)] [DUR4(string)] [DUR5(string)] [DUR6(string)] [DUR7(string)] [DUR8(string)] [DUR9(string)] [DUR10(string)] 

local currdir `c(pwd)'
local time_sec=`time'*60
local pausetime_sec=`pausetime'*60




mata : st_numscalar("OK", direxists("`directory'"))
if scalar(OK)==0 {
noi dis as error _n "Attention. Directory: ""`directory'"" not found."
noi dis as error  "Please correctly specify {help sursol_para##sursol_para_directory:directory(string)}"
ex 601
}


if length("`export'")>0{
	mata : st_numscalar("OK", direxists("`export'"))
	if scalar(OK)==0 {
	noi display as error "Attention, folder specified in EXPORT does not exist."
	ex 601
	}
}




if length("`export'")==0 loc export="`directory'"


forvalues x = 1(1)10 {
if length("`dur`x''") > 0 {
local n : word count `dur`x''
if `n'>2 {
noi display as error "Attention: Option dur`x' incorrectly specified."
noi dis as error "Only two variables allowed.  Needs to be {help sursol_para##sursol_para_dur:dur`x'(var1 var2)}"
exit 198
}
if `n'<2 {
noi display as error "Attention: Option dur`x' incorrectly specified."
noi dis as error "Two variables needed. Needs to be {help sursol_para##sursol_para_dur:dur`x'(var1 var2)}"
exit 198
}
}
}


loc nsuccess=0
qui{

	local folderstructure: dir "`directory'" dirs "`1'*", respectcase 
	capt erase "`export'\\paradata_all.tab"
	local folderstructure : list sort folderstructure
	local length : word count `folderstructure'
	if `length'==0 {
	noi di as error _n "Attention, no folder found named:  ""`1'"" 
	noi di as error "Check questionnaire name specified or directory!" 
	ex 601
	}
	else if `length'>0 {
	noi di as result _n "The following folder have been found:"
	foreach folder of loc folderstructure {
	noi di as result  "`folder'"
	}
	
	}

	//LOOP STARTS HERE
	loc notworked "" 
	loc i=0
	foreach folder of loc folderstructure {
	loc version= subinstr("`folder'", "`1'_"," ",.)

	 capt confirm  file "`directory'\\`folder'\paradata.tab" 
		if _rc!=0 {
		noi di as error  "ATTENTION! No paradata.tab file found for `folder' "
		local notworked `" `notworked'  "`folder'" " " "'
		loc ++i		
		continue 
		}
		 
		
		
	else {
 	noi di as text _n "`version' will be appended..."
	if length("`size'")>0 {	
      qui checksum "`directory'\\`folder'\paradata.tab"
      loc kb= round(`r(filelen)'/1024, 0.1)
      if `kb'>100000 noi dis as text "The file is `kb' KB large. That'll take a while..."
      else if `kb'>1000000 noi dis as text "The file is `kb' KB large. That'll take super long..."
	}
	insheet using "`directory'\\`folder'\paradata.tab", tab case names clear


	if  `c(N)'==0  {
		noi di as error  "ATTENTION! No data in paradata.tab file found for `folder' "
		local notworked `" `notworked'  "`folder'" " " "'
		loc ++i		
		continue 
		}	


	drop if inlist(event,"QuestionDeclaredValid", "VariableDisabled","VariableSet")
	replace timestamp=subinstr(timestamp,"-","/",.)
	replace timestamp=subinstr(timestamp,"T"," ",.)
	g variable=substr(parameters,1,strpos(parameters,"||")-1)
	sort interview__id order
	gen double time=clock(timestamp,"20YMDhms")
	gen timestamp1  = timestamp[_n - 1]
	gen double time1=clock(timestamp1,"20YMDhms")

	gen rawdur = (time -time1) / 1000 if order!=1 ///
	& !inlist(event,"ReceivedByInterviewer", "ReceivedBySupervisor","RejectedBySupervisor", "QuestionDeclaredInvalid", "Restarted")
    	replace rawdur=. if  rawdur<0 
	bys interview__id: egen rawdurint=total(rawdur),m



	bys interview__id: gen help = sum(event=="Completed")
	replace help=. if help>1
	replace help=rawdur if !missing(help)
	sort interview__id order
	bys interview__id: egen rawdur_fstcompl=total(help),m
	sort interview__id order

	g cleandur=rawdur
	replace cleandur=. if rawdur>=`time_sec' 
	replace cleandur=. if event=="Paused" & event[_n-1]=="Resumed"
	replace cleandur=. if inlist(event,"Resumed")
	replace help=cleandur if !missing(help)
	bys interview__id: egen cleandur_fstcompl=total(help),m




						forvalues x = 1(1)10 {
						if length("`dur`x''") > 0 {
							g dur`x' = 1 if  variable==word("`dur`x' '",1)
							replace dur`x'= 2 if variable[_n-1] == word("`dur`x' '",-1) /*& !missing(variable)*/				
							bys interview__id: egen maxdur=max(dur`x')
							bys interview__id: replace dur`x' = sum(dur`x') if maxdur==2
							replace dur`x' = 0 if dur`x' != 1  | maxdur!=2 | variable== word("`dur`x' '",-1) 
							replace dur`x' = cleandur if dur`x' == 1 
							drop maxdur

						}
						
					}

	
	//CREATE SOME DESCR. INDICATORS 
	bys interview__id: egen n_invalidq=total(event=="QuestionDeclaredInvalid")
	bys interview__id: egen n_answer=total(event=="AnswerSet")
	bys interview__id: egen n_removed=total(event=="AnswerRemoved")
	
	//CREATE LENGTH OF BREAKS

	replace rawdur=. if !inlist(event,"Paused","Resumed")
	replace rawdur=. if rawdur>(`pausetime_sec')
	bys interview__id: egen length_pause=total(rawdur)
	
	

	drop time1 time timestamp1 help 


		capt confirm file "`export'\\paradata_all.tab"
				if _rc!=0 {
					capture sort interview__id order
					export delimited using "`export'\\paradata_all.tab", replace delimiter(tab)
				}
				else {
					tempfile finalversion
					save `finalversion'
					sleep 150
					import delimited using "`export'\\paradata_all.tab", clear
					append using `finalversion'
					capture sort interview__id order
					export delimited using  "`export'\\paradata_all.tab", replace delimiter(tab)
				}
	loc ++nsuccess
	}	

loc ++i


}

if `nsuccess'==0 {
noi disp as error _n "No Paradata has been found in any of the specified folders" 
exit
}


if  `c(N)'==0  {
import delimited using "`export'\\paradata_all.tab", clear
}


sort interview__id order

//CREATE OVERVIEW STATS

						loc durlist ""
						forvalues x = 1(1)10 {
						if length("`dur`x''") > 0 {
							loc durlist `"`durlist' dur`x'  "' 
						}						
						}


collapse (firstnm) n_invalidq n_answer n_removed  rawdur_fstcompl cleandur_fstcompl length_pause  rawdurint  (sum) `durlist'  cleandur , by(interview__id)
rename cleandur clean_durint

g cleandur_min=clean_durint/60
g rawdur_min=rawdurint/60
g answ_pm=n_answer/cleandur_min 

lab var answ_pm "Answers per Minute"
lab var n_invalidq "Number of times a question was declared invalid during interview"
lab var rawdurint "Raw duration of interview in seconds between first and last action" 
lab var rawdur_fstcompl "Raw duration of interview in seconds between first action and first completion"
lab var n_answer "Number of answers sets" 
lab var n_removed "Number of answers removed"
lab var clean_durint "Active time working on interview. Actions>`time' minutes & breaks are filtered out"
lab var cleandur_fstcompl"Active time betw. first act and first completion. Actions>`time' minutes & breaks filtered"
lab var length_pause  "Length in seconds interview was paused. Breaks>`pausetime' minutes are filtered out"
lab var cleandur_min "clean_durint in minutes"
lab var rawdur_min "rawdurint in minutes"

if length("`durlist'") > 0 {
foreach x of var `durlist' {
loc var1=word("``x''",1)
loc var2=word("``x''",-1)
lab var `x' "Time betw. `var1'-`var2'. Miss if var1 answ. after var2 or var1/2 no answer."
replace `x'=. if `x'==0
}
}

order rawdurint clean_durint cleandur_min rawdur_min rawdur_fstcompl cleandur_fstcompl length_pause `durlist' n_answer answ_pm, a(interview__id)

save "`export'\\paradata_overview.dta", replace



//RESULTS
local worked: list folderstructure- notworked

	if `i'==1 & length("`notworked'")==0 {
		noi di as result _n(2) "Only 1 version found and successfully saved: "
		foreach folder of loc worked {
		noi di as result "`folder'"
}

	} 
	else if `i'>1 {
noi di as text _n "The following paradata has been successfully appended: "
foreach folder of loc worked {
noi di as result "`folder'"
	}
}

if length("`notworked'")>0 {
noi di as error _n "The following folders were found but paradata failed to be appended: "
foreach fail of loc notworked {
noi di as error "`fail'"
}
}
	cd "`currdir'"		

}

end	

