
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
LEFT                  return 'LEFT'
RIGHT                 return 'RIGHT'
OUTER                 return 'OUTER'
JOIN                  return 'JOIN'
ON                    return 'ON'
ORDER                 return 'ORDER'
BY                    return 'BY'
ASCENDING             return 'ASCENDING'
ASC                   return 'ASCENDING'
DESCENDING            return 'DESCENDING'
DESC                  return 'DESCENDING'
TOP                   return 'TOP'
LIMIT                 return 'LIMIT'
SKIP                  return 'SKIP'
SQRT                  return 'SQRT'
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
"."                   return '.'
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
    : sql_statement EOF
        { return $1; }
    ;

sql_statement
    : SELECT top_clause fields from_clause where_clause orderby_clause skip_clause limit_clause
        { $$ = yy.buildSelect({
                top: $2,
                fields: $3,
                from: $4,
                where: $5,
                sort: $6,
                skip: $7,
                limit: $8
            }); 
        }
    ;

top_clause
    :
        { $$ = null; }
    | TOP NUMBER
        { $$ = yy.toPositiveInt($2, 'TOP'); }
    ;

skip_clause
    :
        { $$ = null; }
    | SKIP NUMBER
        { $$ = yy.toPositiveInt($2, 'SKIP'); }
    ;

limit_clause
    :
        { $$ = null; }
    | LIMIT NUMBER
        { $$ = yy.toPositiveInt($2, 'LIMIT'); }
    ;

from_clause
    :
        { $$ = null; }
    | FROM table
        { $$ = $2; }
    ;

where_clause
    :
        { $$ = null; }
    | WHERE condition
        { $$ = $2; }
    ;

orderby_clause
    :
        { $$ = null; }
    | ORDER BY orderby_fieldspec
        { $$ = $3; }
    ;

orderby_fieldspec
    : IDENTIFIER
        { $$ = yy.appendOrderBySpec($1, 1); }
    | IDENTIFIER ASCENDING
        { $$ = yy.appendOrderBySpec($1, 1); }
    | IDENTIFIER DESCENDING
        { $$ = yy.appendOrderBySpec($1, -1); }
    | orderby_fieldspec ',' orderby_fieldspec
        { $$ = Object.assign($1, $3); }
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
        { $$ = { name: $1, value: $3.value };}
    | '*'
        { $$ = { name: $1, value: 1 };}
    ;

expression
    : text_literal
        { $$ = { isText: true, value: $1 }; }
    | NUMBER
        { $$ = { isNumberLiteral: true, value: Number($1) }; }
    | IDENTIFIER
        { $$ = { value: '$' + $1 }; }
    | expression '+' expression
        { $$ = yy.combineLeftRight('+', $1, $3); }
    | expression '-' expression
        { $$ = yy.combineLeftRight('$subtract', $1, $3); }
    | expression '*' expression
        { $$ = yy.combineLeftRight('$multiply', $1, $3); }
    | expression '/' expression
        { $$ = yy.combineLeftRight('$divide', $1, $3); }
    | expression '%' expression
        { $$ = yy.combineLeftRight('$mod', $1, $3); }
    | expression '^' expression
        { $$ = yy.combineLeftRight('$pow', $1, $3); }
    | '-' expression %prec UMINUS
        { $$ = yy.buildUnaryMinuxExpr($2); }
    | SQRT '(' expression ')'
        { $$ = { value: { "$sqrt": $3 } }; }
    | '(' expression ')'
        { $$ = $2; }
    ;

text_literal
    :  TEXT
        { $$ = $1.replace (/(^')|('$)/g, ''); }
    ;

table
    : IDENTIFIER
        { $$ = { main: $1 }; }
    | table join_spec join_target_spec ON IDENTIFIER '.' IDENTIFIER '=' IDENTIFIER '.' IDENTIFIER
        { $$ = yy.addLookup($1, $3, $5, $7, $9, $11); }
    ;

join_spec
    : JOIN
    | LEFT JOIN
    | LEFT OUTER JOIN
    ;

join_target_spec
    : IDENTIFIER
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

