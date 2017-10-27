grammar fortran;

module
    : 'module' IDENT NEWLINE+ use_statement* 'implicit none' NEWLINE+ decl* ('contains' NEWLINE+ subroutine+ )?  'end module' IDENT? NEWLINE+ EOF
    ;

use_statement
    : 'use' IDENT (',' 'only' ':' param_list)? NEWLINE+
    ;

decl
    : private_decl
    | public_decl
    | var_decl
    | interface_decl
    ;

private_decl
    : 'private' NEWLINE+
    ;

public_decl
    : 'public' IDENT (',' IDENT)* NEWLINE+
    ;

var_decl
    : var_type ('(' IDENT ')')? (',' var_modifier)* '::' var_sym_decl (',' var_sym_decl)* NEWLINE+
    ;

var_sym_decl
    : IDENT array_decl? ('=' expr)?
    ;

array_decl
    : '(' array_comp_decl (',' array_comp_decl)* ')'
    ;

array_comp_decl
    : expr
    | ':'
    ;

interface_decl
    : 'interface' IDENT NEWLINE+ ('module' 'procedure' IDENT NEWLINE+)* 'end' 'interface' IDENT? NEWLINE+
    ;

expr
    : expr '**' expr
    | expr ('*'|'/') expr
    | '-' expr
    | expr ('+'|'-') expr
    | number
    | '.not.' expr
    | logical_value
    | IDENT
    | fn_call
    | '(' expr ')'  // accessing array
	;

fn_call
    : IDENT '(' call_args? ')'
    ;

subroutine_call
    : 'call' IDENT '(' call_args? ')'
    ;

call_args
    : call_arg (',' call_arg)*
    ;

call_arg
    : expr
    | ':'
    ;

var_type
    : 'integer' | 'char' | 'real' | 'complex' | 'logical'
    ;

var_modifier
    : 'parameter' | 'intent' | 'dimension' | 'allocatable' | 'pointer'
    | 'intent' '(' ('in' | 'out' | 'inout' ) ')'
    | 'save'
    ;

subroutine
    : 'subroutine' IDENT ('(' param_list? ')')? NEWLINE+ decl* statement* 'end subroutine' NEWLINE+
    ;

param_list
    : IDENT (',' IDENT)*
    ;

statement
    :
    ( IDENT '=' expr
    | 'exit'
    | subroutine_call
    | if_statement
    | do_statement
    | ';'
    ) (NEWLINE+ | ';' NEWLINE*)
    ;

if_statement
    : 'if' '(' expr ')' statement
    | 'if' '(' expr ')' 'then' NEWLINE+ statement+ ('else' NEWLINE+ statement+)? 'end' 'if'
    ;

do_statement
    : 'do' (IDENT '=' expr ',' expr (',' expr)?)? NEWLINE+ statement+ 'end' 'do'
    ;

number
    : NUMBER                    // Real number
    | '(' NUMBER ',' NUMBER ')' // Complex number
    ;

logical_value
    : '.true.'
    | '.false.'
    ;

NUMBER
    : ([0-9]+ '.' [0-9]* | '.' [0-9]+) ([eEdD] [+-]? [0-9]+)? ('_' IDENT)?
    |  [0-9]+                          ([eEdD] [+-]? [0-9]+)? ('_' IDENT)?
    ;

IDENT
    : ('a' .. 'z' | 'A' .. 'Z') ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_')*
    ;

COMMENT
    : '!' ~[\r\n]* -> skip;

LINE_CONTINUATION
    : '&' WS* COMMENT? NEWLINE -> skip
    ;

NEWLINE
    : '\r'? '\n'
    ;

WS
    : [ \t] -> skip
    ;
