%{
//-- don't change *any* of these: if you do, you'll break the compiler.
#include <cdk/compiler.h>
#include "ast/all.h"
#define LINE               compiler->scanner()->lineno()
#define yylex()            compiler->scanner()->scan()
#define yyerror(s)         compiler->scanner()->error(s)
#define YYPARSE_PARAM_TYPE std::shared_ptr<cdk::compiler>
#define YYPARSE_PARAM      compiler
//-- don't change *any* of these --- END!
%}

%union {
  int                   i;	/* integer value */
  double                d;  /* double value */
  std::string          *s;	/* symbol name or string literal */
  cdk::basic_node      *node;	/* node pointer */
  cdk::sequence_node   *sequence;
  cdk::expression_node *expression; /* expression nodes */
  cdk::lvalue_node     *lvalue;
  basic_type           *type;
  m19::block_node      *block;
  m19::sections_node   *section;
  m19::body_node       *body;  /* added body node */
};

%token <i> tINTEGER
%token <s> tIDENTIFIER tSTRING
%token <d> tREAL
%token tRETURN tBREAK tCONTINUE tPRINT tPRINTNL tSINIT tSFIN
%token tLOGICAND tLOGICOR tLOGICNOT

%nonassoc '?' tLOGICNOT

%right '='
%left tLOGICOR tLOGICAND
%left tGE tLE tEQ tNE '>' '<'
%left '+' '-'
%left '*' '/' '%'

%nonassoc tUNARY '[' ':'

%type <node> decl file var instr funct arg cond_instr iter_instr 
%type <sequence> declarations args sections instructions bvars expressions
%type <expression> expr literal functcall
%type <body> body
%type <section> section
%type <lvalue> lval
%type <block> block initial_section final_section
%type <type> type
%type <s> str

%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

file : declarations                                                      { compiler->ast($$ = $1); }
     | /* empty */                                                       { compiler->ast($$ = new cdk::sequence_node(LINE)); }
     ;

declarations : decl                                                      { $$ = new cdk::sequence_node(LINE, $1); }
             | declarations decl                                         { $$ = new cdk::sequence_node(LINE, $2, $1); }
             ;

decl : var ';'                                                           { $$ = $1;}
     | funct                                                             { $$ = $1;}
     ;

var : type tIDENTIFIER                                                   { $$ = new m19::var_decla_node(LINE, $1, false, false,  $2, NULL); }
    | type tIDENTIFIER tPRINT                                            { $$ = new m19::var_decla_node(LINE, $1, true, false, $2, NULL); }
    | type tIDENTIFIER '?'                                               { $$ = new m19::var_decla_node(LINE, $1, false, true, $2, NULL); }
    | type tIDENTIFIER tPRINT '=' expr                                   { $$ = new m19::var_decla_node(LINE, $1, true, false, $2, $5); }
    | type tIDENTIFIER '?' '=' expr                                      { $$ = new m19::var_decla_node(LINE, $1, false, true, $2, $5); }
    | type tIDENTIFIER     '=' expr                                      { $$ = new m19::var_decla_node(LINE, $1, false, false, $2, $4); }
    ;

literal : tINTEGER                                                       { $$ = new cdk::integer_node(LINE, $1); }
        | tREAL                                                          { $$ = new cdk::double_node(LINE, $1); }
        | str                                                            { $$ = new cdk::string_node(LINE, $1); }
        ;

funct : type tIDENTIFIER     '(' args ')'                                { $$ = new m19::function_decla_node(LINE, $1, false, false, $2,$4); }
      | type tIDENTIFIER tPRINT '(' args ')'                             { $$ = new m19::function_decla_node(LINE, $1, true, false, $2, $5); }
      | type tIDENTIFIER '?' '(' args ')'                                { $$ = new m19::function_decla_node(LINE, $1, false, true, $2, $5); }
      | tPRINT  tIDENTIFIER     '(' args ')'                             { $$ = new m19::function_decla_node(LINE, new basic_type(), false, false, $2, $4); }
      | tPRINT  tIDENTIFIER tPRINT '(' args ')'                          { $$ = new m19::function_decla_node(LINE, new basic_type(), true, false, $2, $5); }
      | tPRINT  tIDENTIFIER '?' '(' args ')'                             { $$ = new m19::function_decla_node(LINE, new basic_type(), false, true, $2, $5); }
      | type tIDENTIFIER     '(' args ')'             body               { $$ = new m19::function_definition_node(LINE, $1 , $2, false, $4, NULL, $6); }
      | type tIDENTIFIER     '(' args ')' '=' literal body               { $$ = new m19::function_definition_node(LINE, $1 , $2, false, $4, $7, $8); }
      | type tIDENTIFIER tPRINT '(' args ')'             body            { $$ = new m19::function_definition_node(LINE, $1 , $2, true, $5, NULL, $7); }
      | type tIDENTIFIER tPRINT '(' args ')' '=' literal body            { $$ = new m19::function_definition_node(LINE, $1 , $2, true, $5, $8, $9); }
      | tPRINT  tIDENTIFIER     '(' args ')'             body            { $$ = new m19::function_definition_node(LINE, new basic_type(), $2, false, $4, NULL, $6); }
      | tPRINT  tIDENTIFIER     '(' args ')' '=' literal body            { $$ = new m19::function_definition_node(LINE, new basic_type(), $2, false, $4, $7, $8); }
      | tPRINT  tIDENTIFIER tPRINT '(' args ')'             body         { $$ = new m19::function_definition_node(LINE, new basic_type(), $2, true, $5, NULL, $7); }
      | tPRINT  tIDENTIFIER tPRINT '(' args ')' '=' literal body         { $$ = new m19::function_definition_node(LINE, new basic_type(), $2, true, $5, $8, $9); }
      ;

args : arg                                                               { $$ = new cdk::sequence_node(LINE, $1); }
     | args ',' arg                                                      { $$ = new cdk::sequence_node(LINE, $3, $1); }
     | /* empty */                                                       { $$ = new cdk::sequence_node(LINE); }
     ;

arg : type tIDENTIFIER                                                   { $$ = new m19::var_decla_node(LINE, $1, false, false, $2, NULL); }
    ;

type : '#'                                                               { $$ = new basic_type(4, basic_type::TYPE_INT); }
     | '%'                                                               { $$ = new basic_type(8, basic_type::TYPE_DOUBLE); }
     | '$'                                                               { $$ = new basic_type(4, basic_type::TYPE_STRING); }
     | '<' type '>'                                                      { $$ = new basic_type(4, basic_type::TYPE_POINTER); $$->_subtype = $2; }
     ;

str : tSTRING                                                            { $$ =  $1; }
    | str tSTRING                                                        { $$ =  new std::string(*$1 + *$2); delete $1; delete $2; }
    ;

body : initial_section sections final_section                            { $$ = new m19::body_node(LINE, $1, $2, $3); }
     | initial_section sections                                          { $$ = new m19::body_node(LINE, $1, $2, NULL); }
     | sections final_section                                            { $$ = new m19::body_node(LINE, NULL, $1, $2); }
     | sections                                                          { $$ = new m19::body_node(LINE, NULL, $1, NULL); }
     | initial_section                                                   { $$ = new m19::body_node(LINE, $1, NULL, NULL); }
     | final_section                                                     { $$ = new m19::body_node(LINE, NULL, NULL, $1); }
     ;

initial_section : tSINIT block                                           { $$ = $2; }
                ;

final_section : tSFIN block                                              { $$ = $2; }
              ;

sections : section                                                       { $$ = new cdk::sequence_node(LINE, $1); }
         | sections section                                              { $$ = new cdk::sequence_node(LINE, $2, $1); }
         ;

section : '[' expressions ']' block                                      { $$ = new m19::sections_node(LINE, $2, false, $4); }
        | '(' expressions ')' block                                      { $$ = new m19::sections_node(LINE, $2, true, $4); }
        | block                                                          { $$ = new m19::sections_node(LINE, new cdk::sequence_node(LINE), true, $1); }
        ;

block : '{' '}'                                                          { $$ = new m19::block_node(LINE, new cdk::sequence_node(LINE), new cdk::sequence_node(LINE)); }
      | '{' bvars '}'                                                    { $$ = new m19::block_node(LINE, $2, new cdk::sequence_node(LINE)); }
      | '{' instructions '}'                                             { $$ = new m19::block_node(LINE, new cdk::sequence_node(LINE), $2); }
      | '{' bvars instructions '}'                                       { $$ = new m19::block_node(LINE, $2, $3); }
      ;

bvars : var ';'                                                          { $$ = new cdk::sequence_node(LINE, $1); }
      | bvars var ';'                                                    { $$ = new cdk::sequence_node(LINE, $2, $1); }
      ;

instructions : instr                                                     { $$ = new cdk::sequence_node(LINE, $1); }
             | instructions instr                                        { $$ = new cdk::sequence_node(LINE, $2, $1); }
             ;

instr : expr ';'                                                         { $$ = new m19::evaluation_node(LINE, $1); }
      | expr tPRINT                                                      { $$ = new m19::print_node(LINE, $1, false); }
      | expr tPRINTNL                                                    { $$ = new m19::print_node(LINE, $1, true); }
      | tBREAK                                                           { $$ = new m19::stop_node(LINE); }
      | tCONTINUE                                                        { $$ = new m19::next_node(LINE); }
      | tRETURN                                                          { $$ = new m19::return_node(LINE); }
      | cond_instr                                                       { $$ = $1; }
      | iter_instr                                                       { $$ = $1; }
      | block                                                            { $$ = $1; }
      ;

cond_instr : '[' expr ']' '#' instr                                      { $$ = new m19::if_node(LINE, $2, $5); }
           | '[' expr ']' '?' instr                                      { $$ = new m19::if_else_node(LINE, $2, $5, NULL); }
           | '[' expr ']' '?' instr ':' instr                            { $$ = new m19::if_else_node(LINE, $2, $5, $7); }
           ;

iter_instr : '[' bvars expressions ';' expressions ']' instr             { $$ = new m19::for_node(LINE, $2, $3, $5, $7); }
           | '[' expressions ';' expressions ';' expressions ']' instr   { $$ = new m19::for_node(LINE, $2, $4, $6, $8); }
           ;

expr : literal                                                           { $$ = $1; }
     | expr '+' expr	                                                   { $$ = new cdk::add_node(LINE, $1, $3); }
     | expr '-' expr	                                                   { $$ = new cdk::sub_node(LINE, $1, $3); }
     | expr '*' expr	                                                   { $$ = new cdk::mul_node(LINE, $1, $3); }
     | expr '/' expr	                                                   { $$ = new cdk::div_node(LINE, $1, $3); }
     | expr '%' expr	                                                   { $$ = new cdk::mod_node(LINE, $1, $3); }
     | expr '<' expr	                                                   { $$ = new cdk::lt_node(LINE, $1, $3); }
     | expr '>' expr	                                                   { $$ = new cdk::gt_node(LINE, $1, $3); }
     | expr tGE expr	                                                   { $$ = new cdk::ge_node(LINE, $1, $3); }
     | expr tLE expr                                                     { $$ = new cdk::le_node(LINE, $1, $3); }
     | expr tNE expr	                                                   { $$ = new cdk::ne_node(LINE, $1, $3); }
     | expr tEQ expr	                                                   { $$ = new cdk::eq_node(LINE, $1, $3); }
     | expr tLOGICOR expr                                                { $$ = new cdk::or_node(LINE, $1, $3); }
     | expr tLOGICAND expr                                               { $$ = new cdk::and_node(LINE, $1, $3); }
     | tLOGICNOT expr                                                    { $$ = new cdk::not_node(LINE, $2); }
     | '+' expr %prec tUNARY                                             { $$ = new m19::identity_node(LINE, $2); }
     | '-' expr %prec tUNARY                                             { $$ = new cdk::neg_node(LINE, $2); }
     | '[' expr ']'                                                      { $$ = new m19::alloc_node(LINE, $2); }
     | '(' expr ')'                                                      { $$ = $2; }
     | '@'                                                               { $$ = new m19::read_node(LINE); }
     | '@' '=' expr                                                      { $$ = new cdk::assignment_node(LINE, nullptr, $3); }
     | '@' '(' expr ')'                                                  { $$ = new cdk::assignment_node(LINE, nullptr, $3); }
     | functcall                                                         { $$ = $1; }
     | lval                                                              { $$ = new cdk::rvalue_node(LINE, $1); }  //FIXME
     | lval '?'                                                          { $$ = new m19::memory_address_node(LINE, $1); }
     | lval '=' expr                                                     { $$ = new cdk::assignment_node(LINE, $1, $3); }
     ;

functcall : tIDENTIFIER '(' expressions ')'                              { $$ = new m19::function_invoc_node(LINE, $1, $3); }
          ;

lval : tIDENTIFIER                                                       { $$ = new cdk::variable_node(LINE, $1); }
     | expr '[' expr ']'                                                 { $$ = new m19::indexing_node(LINE, $1, $3); }
     ;

expressions : expr                                                       { $$ = new cdk::sequence_node(LINE, $1); }
            | expressions ',' expr                                       { $$ = new cdk::sequence_node(LINE, $3, $1); }
            | /* empty */                                                { $$ = new cdk::sequence_node(LINE); }
            ;

%%
