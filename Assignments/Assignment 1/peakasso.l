%{
#include "y.tab.h"
#include <string.h>
#include <stdio.h>
void yyerror (char *s);
int yylex();
%}
%%

!!.*                            ; //Comment ignore it
";"                             {return semiColon;}
"="                             {return equals;}
":"                             {return colon;}
","                             {return comma;}

"PROGRAM"                       {return programStart;}

"PLUS"                          {return plus;}
"MINUS"                         {return minus;}

"CANVAS-INIT-SECTION"           {return canvasStart;}
"CONST"                         {return constant;}
"CanvasX"                       {return canvasX;}
"CanvasY"                       {return canvasY;}
"BRUSH-DECLARATION-SECTION"     {return brushDeclaration;}
"BRUSH"                         {return brush;}
"DRAWING-SECTION"               {return drawingSectionToken;}
"RENEW-BRUSH"                   {return renewBrush;}
"PAINT-CANVAS"                  {return paintCanvas;}
"EXHIBIT-CANVAS"                {return exhibitCanvas;}
"MOVE"                          {return move;}
"TO"                            {return to;}
"CursorX"                       {return cursorX;}
"CursorY"                       {return cursorY;}
\'.*\'                          {yylval.id = strdup(yytext); return message;}
[a-zA-Z]+                       {yylval.id = strdup(yytext);return idToken;}
[+-]?[0-9]+                     {yylval.num = atoi(yytext);return integer_literal;}
%%
int yywrap (void) {return 1;}