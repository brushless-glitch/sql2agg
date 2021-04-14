
/* description: Parses and executes mathematical expressions. */

/* lexical grammar */
%lex
%options case-insensitive
%%

\s+                   /* skip whitespace */
"--".*                /* ignore comment */
SELECT                return 'SELECT'
FROM                  return 'FROM'
WHERE                 return 'WHERE'
AND                   return 'AND'
OR                    return 'OR'
NOT                   return 'NOT'
BETWEEN               return 'BETWEEN'
IN                    return 'IN'
AS                    return 'AS'
LIKE                  return 'LIKE'
['][^']*[']           return 'TEXT'
[a-zA-Z_][a-zA-Z0-9_]*  return 'IDENTIFIER'
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
"*"                   return '*'
"/"                   return '/'
"-"                   return '-'
"+"                   return '+'
"^"                   return '^'
"!"                   return '!'
"%"                   return '%'
"("                   return '('
")"                   return ')'
"="                   return '='
">="                  return '>='
"<="                  return '<='
"!="                  return 'NE'
"<>"                  return 'NE'
">"                   return '>'
"<"                   return '<'
","                   return ','
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left ','
%left AND OR
%right NOT
%left UMINUS

%start result

%% /* language grammar */

result
    : sql_statement
        { return $1; }
    ;

sql_statement
    : SELECT fields FROM table WHERE condition EOF
        { $$ = yy.buildSelect($2, $6, $4); }
    | SELECT fields FROM table EOF
        { $$ = yy.buildSelect($2, null, $4); }
    ;

fields
    : field
        { $$ = yy.appendField(null, $1);}
    | fields ',' field
        { $$ = yy.appendField($1, $3);}
    ;

field
    : IDENTIFIER
        { $$ = { name: $1, value: 1 }; }
    | IDENTIFIER '=' expression
        { $$ = { name: $1, value: $3 };}
    ;

expression
    : text_expression
    | arithmetic_expression
    ;

text_expression
    : text_literal
    | IDENTIFIER
        { $$ = '$' + $1 }
    | text_expression '+' text_expression
        { $$ = yy.combineConcats($1, $3) }
    ;

text_literal
    :  TEXT
        { $$ = $1.replace (/(^')|('$)/g, ''); }
    ;

arithmetic_expression
    : NUMBER
    ;

table
    : 'IDENTIFIER'
    ;

condition
    : simple_condition
    | condition 'AND' condition
        { $$ = yy.combineConditions($1, "$and", $3); }
    | condition 'OR' condition
        { $$ = yy.combineConditions($1, "$or", $3); }
    | 'NOT' condition
        { $$ = yy.notCondition($2); }
    | '(' condition ')'
        { $$ = $2; }
    ;

simple_condition
    : IDENTIFIER '=' operand
        { $$ = yy.appendCondition($1, "$eq", $3); }
    | IDENTIFIER 'NE' operand
        { $$ = yy.appendCondition($1, "$ne", $3); }
    | IDENTIFIER '>=' operand
        { $$ = yy.appendCondition($1, "$gte", $3); }
    | IDENTIFIER '<=' operand
        { $$ = yy.appendCondition($1, "$lte", $3); }
    | IDENTIFIER '>' operand
        { $$ = yy.appendCondition($1, "$gt", $3); }
    | IDENTIFIER '<' operand
        { $$ = yy.appendCondition($1, "$lt", $3); }
    | IDENTIFIER BETWEEN operand AND operand
        { $$ = yy.appendBetweenCondition($1, $3, $5); }
    | IDENTIFIER IN '(' operand_list ')'
        { $$ = yy.appendInListCondition($1, $4); }
    | IDENTIFIER LIKE text_literal
        { $$ = yy.appendLikeCondition($1, $3); }
    ;

operand
    : NUMBER
        { $$ = Number($1); }
    | text_literal
    ;

operand_list
    : operand
        { $$ = [ $1 ]; }
    | operand_list ',' operand
        { $1.push($3); $$ = $1 }
    ;

e
    : e '+' e
        {$$ = $1+$3;}
    | e '-' e
        {$$ = $1-$3;}
    | e '*' e
        {$$ = $1*$3;}
    | e '/' e
        {$$ = $1/$3;}
    | e '^' e
        {$$ = Math.pow($1, $3);}
    | e '!'
        {{
          $$ = (function fact (n) { return n==0 ? 1 : fact(n-1) * n })($1);
        }}
    | e '%'
        {$$ = $1/100;}
    | '-' e %prec UMINUS
        {$$ = -$2;}
    | '(' e ')'
        {$$ = $2;}
    | NUMBER
        {$$ = Number(yytext);}
    | E
        {$$ = Math.E;}
    | PI
        {$$ = Math.PI;}
    ;

