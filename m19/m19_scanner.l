%option c++ prefix="m19_scanner_" outfile="m19_scanner.cpp"
%option stack noyywrap yylineno 8bit
%{ 
// make relevant includes before including the parser's tab file
#include <string>
#include <algorithm>
#include <math.h>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include "m19_parser.tab.h"

// don't change this
#define yyerror LexerError
%}


%x X_STRING X_COMMENT X_SPECIAL X_IGNOREAFTERZERO

SYMBOL       [:,;@&#$\][()={}/%<>+*?-]
SEPARATOR 	 [ \n\r\t]+

IDENTIFIER   [A-Za-z][A-Za-z0-9_]*

%%

">="                    { return tGE; } 
"<="                    { return tLE; }
"=="                    { return tEQ; }
"!="                    { return tNE; }

"!"					    { return tPRINT; }
"!!"				    { return tPRINTNL; }
"&&"                    { return tLOGICAND; }
"||"                    { return tLOGICOR; }
"~"                     { return tLOGICNOT; }
">@<"                   { return tRETURN; }
">>@"                   { return tBREAK; }
"@>>"                   { return tCONTINUE; }
"<<"                    { return tSINIT; }
">>"                    { return tSFIN; }

 /* ====================================================================== */
 /* ====[                 3.2 - Comentarios                       	 ]==== */
 /* ====================================================================== */

"/*"                     { yy_push_state(X_COMMENT); }
<X_COMMENT>"/*"          { yy_push_state(X_COMMENT); }    
<X_COMMENT>"*/"          { yy_pop_state(); }
<X_COMMENT>.|\n          { ; /* ignore rest of the content */ }

"//".*$                  { ; /* ignore comments started with // till EOF($) */ }

 /* ====================================================================== */
 /* ====[                3.7 - Identificadores (nomes)               ]==== */
 /* ====================================================================== */

{IDENTIFIER}             { yylval.s = new std::string(yytext); return tIDENTIFIER; }

 /* ====================================================================== */
 /* ====[                3.8.1 - Inteiros             				 ]==== */
 /* ====================================================================== */

[0-9]+              	 { yylval.i = strtol(yytext, nullptr, 10); if (errno == ERANGE) yyerror("Overflow Occured"); return tINTEGER; }

0[xX][a-fA-F0-9]+        { yylval.i = strtol(yytext, nullptr, 16); if (errno == ERANGE) yyerror("Overflow Occured"); return tINTEGER; }

 /* ====================================================================== */
 /* ====[                3.8.2 - Reais em virgula flutuante		     ]==== */
 /* ====================================================================== */

[0-9]++\.[0-9]+          { yylval.d = strtod(yytext, nullptr); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }

[0-9]++\a[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'a', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, -18); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\f[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'f', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, -15); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\p[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'p', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, -12); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\n[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'n', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, -9); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\u[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'u', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, -6); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\m[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'm', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, -3); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\k[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'k', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, 3); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\M[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'M', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, 6); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\G[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'G', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, 9); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\T[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'T', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, 12); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\P[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'P', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, 15); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }
[0-9]++\E[0-9]+          { std::string text = strdup(yytext); std::replace(text.begin(), text.end(), 'E', '.'); yylval.d = strtod(text.c_str(), nullptr)*pow(10, 18); if (errno == ERANGE) yyerror("Overflow Occured"); return tREAL; }

 /* ====================================================================== */
 /* ====[                3.8.3 - Cadeias de caracteres     		     ]==== */
 /* ====================================================================== */

\"                                   { yy_push_state(X_STRING); yylval.s = new std::string(""); }
<X_STRING>\"                         { yy_pop_state(); return tSTRING; }
<X_STRING>\\                         { yy_push_state(X_SPECIAL); }
<X_STRING>.                          { *yylval.s += yytext; }
<X_STRING>\n                         { yyerror("Newline in string"); }

<X_SPECIAL>0                         { yy_pop_state(); yy_pop_state(); yy_push_state(X_IGNOREAFTERZERO); }
<X_SPECIAL>n                         { *yylval.s += "\n"; yy_pop_state(); }
<X_SPECIAL>r                         { *yylval.s += "\r"; yy_pop_state(); }
<X_SPECIAL>t                         { *yylval.s += "\t"; yy_pop_state(); }
<X_SPECIAL>"\""                      { *yylval.s += "\""; yy_pop_state(); }
<X_SPECIAL>"\\"                      { *yylval.s += "\\"; yy_pop_state(); }
<X_SPECIAL>[a-fA-F0-9][a-fA-F0-9]?   { *yylval.s += std::string(1, strtol(yytext, nullptr, 16)); yy_pop_state(); }
<X_SPECIAL>.|\n                      { yyerror("Not a valid special character"); }

<X_IGNOREAFTERZERO>\"                { yy_pop_state(); return tSTRING; }
<X_IGNOREAFTERZERO>.                 { ; /* ignores */ }
<X_IGNOREAFTERZERO>\n                { yyerror("Newline in string"); }

 /* ====================================================================== */
 /* ====================================================================== */

{SYMBOL}                 { return *yytext; }

{SEPARATOR}              { ; /* ignore whitespace */ }

.                        { yyerror("Unknown character"); }

%%
