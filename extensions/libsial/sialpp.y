%{
/*
 * Copyright 2001 Silicon Graphics, Inc. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
/*
	This is the grammar for the preprocessor expression evaluation.
*/
#include "sial.h"
#include "sial.tab.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
static node_t *last_term;
%}

%union {
	node_t	*n;
	int	i;
}

%token	<n>	P_VAR P_NUMBER
%token  <i>	P_DEFINED

%type	<n>	term

%right	<i>	'?'
%left	<i>	P_BOR
%left	<i>	P_BAND
%left	<i>	P_OR
%left	<i>	P_XOR
%left	<i>	P_AND
%left	<i>	P_EQ P_NE
%left	<i>	P_GE P_GT P_LE P_LT
%left	<i>	P_SHL P_SHR
%left	<i>	P_ADD P_SUB
%left	<i>	P_MUL P_DIV P_MOD
%right	<i>	P_UMINUS P_FLIP P_NOT

%%

term:

	  term '?' term ':' term %prec '?'
	 				{ $$ = sial_newop(CEXPR, 3, $1, $3, $5); last_term = $$; }
	| term P_BOR 	term		{ $$ = sial_newop(BOR, 2, $1, $3); last_term = $$; }
	| term P_BAND	term		{ $$ = sial_newop(BAND, 2, $1, $3); last_term = $$; }
	| P_NOT term			{ $$ = sial_newop(NOT, 1, $2); last_term = $$; }
	| term P_EQ	term		{ $$ = sial_newop(EQ, 2, $1, $3); last_term = $$; }
	| term P_GE	term		{ $$ = sial_newop(GE, 2, $1, $3); last_term = $$; }
	| term P_GT	term		{ $$ = sial_newop(GT, 2, $1, $3); last_term = $$; }
	| term P_LE	term		{ $$ = sial_newop(LE, 2, $1, $3); last_term = $$; }
	| term P_LT	term		{ $$ = sial_newop(LT, 2, $1, $3); last_term = $$; }
	| term P_NE	term		{ $$ = sial_newop(NE, 2, $1, $3); last_term = $$; }
	| '(' term ')'			{ $$ = $2; last_term == $$; }
	| term P_OR	term		{ $$ = sial_newop(OR, 2, $1, $3); last_term = $$; }
	| term P_XOR	term		{ $$ = sial_newop(XOR, 2, $1, $3); last_term = $$; }
	| term P_SHR	term		{ $$ = sial_newop(SHR, 2, $1, $3); last_term = $$; }
	| term P_SHL	term		{ $$ = sial_newop(SHL, 2, $1, $3); last_term = $$; }
	| term P_DIV	term		{ $$ = sial_newop(DIV, 2, $1, $3); last_term = $$; }
	| term P_MOD	term		{ $$ = sial_newop(MOD, 2, $1, $3); last_term = $$; }
	| term P_SUB	term		{ $$ = sial_newop(SUB, 2, $1, $3); last_term = $$; }
	| term P_ADD	term		{ $$ = sial_newop(ADD, 2, $1, $3); last_term = $$; }
	| term P_MUL	term		{ $$ = sial_newop(MUL, 2, $1, $3); last_term = $$; }
	| term '&' term	%prec P_AND	{ $$ = sial_newop(AND, 2, $1, $3); last_term = $$; }
	| P_SUB term %prec P_UMINUS	{ $$ = sial_newop(UMINUS, 1, $2); last_term = $$; }
	| '~' term %prec P_FLIP		{ $$ = sial_newop(FLIP, 1, $2); last_term = $$; }
	| '+' term %prec P_UMINUS	{ $$ = $2; last_term = $$; }
	| P_DEFINED '(' {nomacs++;} P_VAR ')'		
					{ nomacs=0; $$ = sial_macexists($4); last_term = $$; }
	| P_NUMBER                      { last_term = $$; }
	| P_VAR				{ $$ = sial_makenum(B_UL, 0); last_term = $$; }
	;

%%

node_t *
sial_getppnode()
{
	return last_term;
}

int
sialpperror(char *s)
{
	sial_error(s);
	return 1;
}

