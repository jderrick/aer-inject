/*
 * Scanner for the PCIE-AER grammar.
 *
 * Copyright (c) 2009 by Intel Corp.
 *   Author: Huang Ying <ying.huang@intel.com>
 *
 * Based on mce.lex of mce-inject, which is written by Andi Kleen
 * <andi.kleen@intel.com>.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; version 2 of the
 * License.
 */

%{
#define _GNU_SOURCE 1
#include <stdlib.h>
#include <string.h>

#include "aer.h"
#include "aer.tab.h"
#include "util.h"

int yylineno;

static int lookup_symbol(const char *);
%}

%option nounput

HEXC	[0-9a-fA-F]

%%

#.*\n			/* comment */;
\n			++yylineno;
({HEXC}{4}:)?{HEXC}{2}:{HEXC}{2}\.{HEXC} { yylval.str = strdup(yytext); return PCI_ID_STR; }
0x{HEXC}+ 		|
0[0-7]+			|
[0-9]+			yylval.num = strtoull(yytext, NULL, 0); return NUMBER;
[:{}<>]			return yytext[0];
[_a-zA-Z][_a-zA-Z0-9]*	return lookup_symbol(yytext);
[ \t]+			/* white space */;
.			yyerror("Unrecognized character '%s'", yytext);

%%

/* Keyword handling */

static struct key {
	const char *name;
	int tok;
	int32_t val;
} keys[] = {
#define KEY(x) { #x, x }
#define ALIAS(x, y) { #x, y }
#define KEYVAL(x,v) { #x, x, v }
	KEY(AER),
	KEY(DOMAIN),
	KEY(BUS),
	KEY(DEV),
	KEY(FN),
	KEY(PCI_ID),
	ALIAS(ID, PCI_ID),
	KEY(UNCOR_STATUS),
	ALIAS(UNCOR, UNCOR_STATUS),
	ALIAS(UNCORRECTABLE, UNCOR_STATUS),
	KEY(COR_STATUS),
	ALIAS(COR, COR_STATUS),
	ALIAS(CORRECTABLE, COR_STATUS),
	KEY(HEADER_LOG),
	ALIAS(HL, HEADER_LOG),
	KEYVAL(TRAIN,PCI_ERR_UNC_TRAIN),
	KEYVAL(DLP, PCI_ERR_UNC_DLP),
	KEYVAL(POISON_TLP, PCI_ERR_UNC_POISON_TLP),
	KEYVAL(FCP, PCI_ERR_UNC_FCP),
	KEYVAL(COMP_TIME, PCI_ERR_UNC_COMP_TIME),
	KEYVAL(COMP_ABORT, PCI_ERR_UNC_COMP_ABORT),
	KEYVAL(UNX_COMP, PCI_ERR_UNC_UNX_COMP),
	KEYVAL(RX_OVER, PCI_ERR_UNC_RX_OVER),
	KEYVAL(MALF_TLP, PCI_ERR_UNC_MALF_TLP),
	KEYVAL(ECRC, PCI_ERR_UNC_ECRC),
	KEYVAL(UNSUP, PCI_ERR_UNC_UNSUP),
	KEYVAL(RCVR, PCI_ERR_COR_RCVR),
	KEYVAL(BAD_TLP, PCI_ERR_COR_BAD_TLP),
	KEYVAL(BAD_DLLP, PCI_ERR_COR_BAD_DLLP),
	KEYVAL(REP_ROLL, PCI_ERR_COR_REP_ROLL),
	KEYVAL(REP_TIMER, PCI_ERR_COR_REP_TIMER),
};

static int cmp_key(const void *av, const void *bv)
{
	const struct key *a = av;
	const struct key *b = bv;
	return strcasecmp(a->name, b->name);
}

static int lookup_symbol(const char *name)
{
	struct key *k;
	struct key key;
	key.name = name;
	k = bsearch(&key, keys, ARRAY_SIZE(keys), sizeof(struct key), cmp_key);
	if (k != NULL) {
		yylval.num = k->val;
		return k->tok;
	}
	return SYMBOL;
}

static void init_lex(void)
{
	qsort(keys, ARRAY_SIZE(keys), sizeof(struct key), cmp_key);
}

static char **argv;
char *filename = "<stdin>";

int yywrap(void)
{
	if (*argv == NULL)
		return 1;
	filename = *argv;
	yyin = fopen(filename, "r");
	ERROR_EXIT_ON(!yyin, "Can not open: %s", filename);
	argv++;
	return 0;
}

int parse_data(char **av)
{
	init_lex();
	argv = av;
	if (*argv)
		yywrap();
	return yyparse();
}
