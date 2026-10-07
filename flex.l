%{
#include <stdio.h>
#include <ctype.h>

int line = 1;
int total = 0;

int inList = 0;
int inIndex = 0;

int keywords = 0, types = 0, ids = 0, nums = 0, texts = 0, flags = 0;
int arith = 0, assign = 0, compare = 0, logic = 0, conv = 0;
int blocks = 0, brackets = 0, others = 0, errors = 0;

void show(char *tok, char *type)
{
    char label[20], msg[60];
    int i;
    sprintf(label, "Line %d:", line);
    sprintf(msg, "%s DETECTED", type);
    for (i = 0; msg[i]; i++)
        msg[i] = toupper(msg[i]);
    printf("%-10s %-34s %s\n", label, msg, tok);
    total++;
}

void pipe_touching()
{
    brackets++;
    if (inIndex)     { inIndex = 0; show("|", "index delimiter (close)"); }
    else if (inList) { inList = 0;  show("|", "list delimiter (close)"); }
    else             { inIndex = 1; show("|", "index delimiter (open)"); }
}

void pipe_free()
{
    brackets++;
    if (inIndex)     { inIndex = 0; show("|", "index delimiter (close)"); }
    else if (inList) { inList = 0;  show("|", "list delimiter (close)"); }
    else             { inList = 1;  show("|", "list delimiter (open)"); }
}
%}

DIGIT   [0-9]
LETTER  [A-Za-z_]
ID      {LETTER}({LETTER}|{DIGIT})*
NUMBER  -?{DIGIT}+(\.{DIGIT}+)?
WS      [ \t\r]+

%%

{WS}        { }
\n          { line++; inList = 0; inIndex = 0; }
"//".*      { }

"hold"      { show(yytext, "keyword"); keywords++; }
"lock"      { show(yytext, "keyword"); keywords++; }
"pattern"   { show(yytext, "keyword"); keywords++; }
"gives"     { show(yytext, "keyword"); keywords++; }
"back"      { show(yytext, "keyword"); keywords++; }
"when"      { show(yytext, "keyword"); keywords++; }
"orwhen"    { show(yytext, "keyword"); keywords++; }
"otherwise" { show(yytext, "keyword"); keywords++; }
"inspect"   { show(yytext, "keyword"); keywords++; }
"on"        { show(yytext, "keyword"); keywords++; }
"fallback"  { show(yytext, "keyword"); keywords++; }
"repeat"    { show(yytext, "keyword"); keywords++; }
"across"    { show(yytext, "keyword"); keywords++; }
"untill"    { show(yytext, "keyword"); keywords++; }
"display"   { show(yytext, "keyword"); keywords++; }
"ask"       { show(yytext, "keyword"); keywords++; }

"as"|"then"     { show(yytext, "keyword"); keywords++; }

"num"|"text"|"flag"|"list"|"matrix"   { show(yytext, "type keyword"); types++; }
"yes"|"no"                  { show(yytext, "flag literal"); flags++; }
"to_num"|"to_text"          { show(yytext, "conversion function"); conv++; }

"equals"|"differs"|"exceeds"|"below"|"atleast"|"atmost"   { show(yytext, "comparison operator"); compare++; }
"also"|"alternatively"|"not"   { show(yytext, "logical operator"); logic++; }

{ID}"|"     { yytext[yyleng-1] = '\0'; show(yytext, "identifier"); ids++; pipe_touching(); }
{ID}        { show(yytext, "identifier"); ids++; }
{NUMBER}    { show(yytext, "number"); nums++; }
\"[^"\n]*\" { show(yytext, "text literal"); texts++; }

"<="        { show(yytext, "assignment operator"); assign++; }
"<<"        { show(yytext, "block start"); blocks++; }
">>"        { show(yytext, "block end"); blocks++; }
".."        { show(yytext, "range operator"); others++; }
"||"        { show(yytext, "matrix delimiter"); brackets++; }
")|"        { show(")", "right parenthesis"); brackets++; pipe_touching(); }
"|"         { pipe_free(); }
"<"         { show(yytext, "angle bracket open"); brackets++; }
">"         { show(yytext, "angle bracket close"); brackets++; }

[+\-*/%]    { show(yytext, "arithmetic operator"); arith++; }
"#"         { show(yytext, "length operator"); others++; }
":"         { show(yytext, "colon"); others++; }
";"         { show(yytext, "semicolon"); others++; }
","         { show(yytext, "comma"); others++; }
"("         { show(yytext, "left parenthesis"); brackets++; }
")"         { show(yytext, "right parenthesis"); brackets++; }

\"[^"\n]*   { printf("Lexical Error at line %d: unterminated text\n", line); errors++; }
.           { printf("Lexical Error at line %d: invalid token '%s'\n", line, yytext); errors++; }

%%

int yywrap()
{
    return 1;
}

int main()
{
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);

    printf("%-10s %-34s %s\n", "Line", "Message", "Token");

    yylex();

    printf("\n");

    printf("\nToken count\n");
    printf("%-24s %d\n", "keyword", keywords);
    printf("%-24s %d\n", "type keyword", types);
    printf("%-24s %d\n", "identifier", ids);
    printf("%-24s %d\n", "number", nums);
    printf("%-24s %d\n", "text literal", texts);
    printf("%-24s %d\n", "flag literal", flags);
    printf("%-24s %d\n", "conversion function", conv);
    printf("%-24s %d\n", "arithmetic operator", arith);
    printf("%-24s %d\n", "assignment operator", assign);
    printf("%-24s %d\n", "comparison operator", compare);
    printf("%-24s %d\n", "logical operator", logic);
    printf("%-24s %d\n", "block start/end", blocks);
    printf("%-24s %d\n", "brackets/delimiters", brackets);
    printf("%-24s %d\n", "others", others);
    printf("%-24s %d\n", "lexical errors", errors);
    printf("\n%-24s %d\n", "Total tokens", total);
    printf("%-24s %d\n", "Total lines", line);

    return 0;
}
