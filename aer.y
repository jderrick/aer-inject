/*
 * Grammar for the PCIE-AER injection.
 *
 * Copyright (c) 2009 by Intel Corp.
 *   Author: Huang Ying <ying.huang@intel.com>
 *
 * Based on mce.y of mce-inject, which is written by Andi Kleen
 * <andi.kleen@intel.com>.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; version 2 of the
 * License.
 */

%{
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>

#include "aer.h"

static struct aer_error_inj aerr;

static void init(void);

%}

%union {
	int num;
	char *str;
}

%token AER DOMAIN BUS DEV FN PCI_ID UNCOR_STATUS COR_STATUS HEADER_LOG
%token <num> TRAIN DLP POISON_TLP FCP COMP_TIME COMP_ABORT UNX_COMP RX_OVER
%token <num> MALF_TLP ECRC UNSUP
%token <num> RCVR BAD_TLP BAD_DLLP REP_ROLL REP_TIMER
%token <num> SYMBOL NUMBER
%token <str> PCI_ID_STR

%type<num> uncor_status_list uncor_status cor_status_list cor_status

%%

input: /* empty */
	| input aer_start aer { submit_aer(&aerr); }
	;

aer_start: AER		{ init(); }
	;

aer: aer_term
	| aer aer_term
	;

aer_term: UNCOR_STATUS uncor_status_list	{ aerr.uncor_status = $2; }
	| COR_STATUS cor_status_list		{ aerr.cor_status = $2; }
	| DOMAIN NUMBER BUS NUMBER DEV NUMBER FN NUMBER  { aerr.domain = $2;
	  	     	    	       	  	  aerr.bus = $4;
						  aerr.dev = $6;
						  aerr.fn = $8; }
	| BUS NUMBER DEV NUMBER FN NUMBER	{ aerr.domain = 0;
						  aerr.bus = $2;
						  aerr.dev = $4;
						  aerr.fn = $6; }
	| PCI_ID PCI_ID_STR			{ parse_pci_id($2, &aerr);
						  free($2); }
	| HEADER_LOG NUMBER NUMBER NUMBER NUMBER { aerr.header_log0 = $2;
						   aerr.header_log1 = $3;
						   aerr.header_log2 = $4;
						   aerr.header_log3 = $5; }
	;

uncor_status_list: /* empty */			{ $$ = 0; }
	| uncor_status_list uncor_status	{ $$ = $1 | $2; }
	;

uncor_status: TRAIN | DLP | POISON_TLP | FCP | COMP_TIME | COMP_ABORT
	| UNX_COMP | RX_OVER | MALF_TLP | ECRC | UNSUP | NUMBER
	;

cor_status_list: /* empty */			{ $$ = 0; }
	| cor_status_list cor_status		{ $$ = $1 | $2; }
	;

cor_status: RCVR | BAD_TLP | BAD_DLLP | REP_ROLL | REP_TIMER | NUMBER
	;

%% 

static void init(void)
{
	init_aer(&aerr);
}

int parse_pci_id(const char *str, struct aer_error_inj *aerr)
{
	int cnt;

	cnt = sscanf(str, "%08x:%02hhx:%02hhx.%01hhx",
		     &aerr->domain, &aerr->bus, &aerr->dev, &aerr->fn);
	if (cnt != 4) {
		cnt = sscanf(str, "%02hhx:%02hhx.%01hhx",
			     &aerr->bus, &aerr->dev, &aerr->fn);
		if (cnt == 3)
			aerr->domain = 0;
		else
			return 1;
	}

	return 0;
}

void yyerror(char const *msg, ...)
{
	va_list ap;
	va_start(ap, msg);
	fprintf(stderr, "%s:%d: ", filename, yylineno);
	vfprintf(stderr, msg, ap);
	fputc('\n', stderr);
	va_end(ap);
	exit(1);
}
