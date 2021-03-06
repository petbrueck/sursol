*! version 20.05.2  May 2020
*! Author: Peter Brueckmann, p.brueckmann@mailbox.org


capture prog drop sursol
program define sursol
	
*** 0. Version check
********************************************************************************


*** 1. IDENTIFY SUBCOMMAND
********************************************************************************
gettoken proc 0 : 0, parse(" ,")

	if length("`proc'")==0 {
		di as error "no subcommand specified. See help on {help sursol##|_new:sursol}"
		exit 198
	}
	if "`proc'"=="approve" {
	sursol_approve `0'
	}
   	else if "`proc'"=="approveHQ" {
	sursol_approveHQ `0'
	}
	else if "`proc'"=="unapproveHQ" {
	sursol_unapproveHQ `0'
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
	else if "`proc'"=="import" {
	sursol_import `0'
	}
	else if "`proc'"=="getcomm" {
	sursol_getcomm `0'
	}
	else if "`proc'"=="rejectHQ" {
	sursol_rejectHQ `0'
	}
	else if "`proc'"=="reject" {
	sursol_reject `0'
	}
	else if "`proc'"=="transcolor" {
	sursol_transcolor `0'
	}
	else if "`proc'"=="mscrelab" {
	sursol_mscrelab `0'
	}
	else if "`proc'"=="reshape" {
	sursol_reshape `0'
	}
	else if "`proc'"=="actionlog" {
	sursol_actionlog `0'
	}
	else if "`proc'"=="userreport" {
	sursol_userreport `0'
	}
	else {
	di as error "Unrecognized command. Check subcommand. See help on {help sursol##|_new:sursol}"
	ex 199
	}
end

