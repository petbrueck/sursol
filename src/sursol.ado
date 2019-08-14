*****
* version 1.0  01August2019

capture prog drop sursol
program define sursol
	

*** 1. IDENTIFY SUBCOMMAND
********************************************************************************
gettoken proc 0: 0
	if length("`proc'")==0 {
		di as error "no subcommand specified. see help on {help sursol##|_new:sursol}"
		exit 198
	}
	
    if "`proc'"=="approveHQ" {
	sursol_approveHQ `0'
	}
	else if "`proc'"=="unapproveHQ" {
	sursol_unapproveHQ `0'
	}
	else if "`proc'"=="approve" {
	sursol_approve `0'
	}
	else if "`proc'"=="transcheck" {
	sursol_transcheck `0'
	}
	else if "`proc'"=="export" {
	sursol_export `0'
	}
	else if "`proc'"=="append" {
	sursol_append `0'
	}
	else if "`proc'"=="para" {
	sursol_para `0'
	}
	else if "`proc'"=="varcomm" {
	sursol_varcomm `0'
	}
	else {
	di as error "unrecognized command. check subcommand. see help on {help sursol##|_new:sursol}"
	qui ex 199
	}
end
