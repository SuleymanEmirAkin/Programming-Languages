%{
void yyerror (char *s);
int yylex();
#include <stdio.h>    
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>


extern FILE *yyin; //For changing parsing input

char* fileName ;  //Input files name
int parsingMode; //0 is file input 1 is terminal input

//Checks wheter a given brush variable name is defined
int contains(char* );
//Prints some important variables and their values for debugging
void check();
//Initializes the canvas
void initializeCanvas();
//Adds one variable to our variable list
void oneBrush(char* fname,int fheight,int fwidth);
//Paint a given variable name to the canvas
void paint(char* fname);
//Prints the canvas
void exhibit();
//Struct defination for variable
struct cBrushS {
                char* name;
                int height;
                int width;
                };
//Varaible array
struct cBrushS * cBrush;
int** canvas;
int numberOfVariables = 0;
int ccanvasX,ccanvasY,ccursorX,ccursorY;
int userInput = 0;
%}
    /* Yacc definitions */
%union {int num; char* id;} 

%token programStart
%token canvasStart 
%token constant
%token brushDeclaration 
%token brush
%token renewBrush 
%token paintCanvas 
%token exhibitCanvas 
%token move 
%token to
%token cursorX 
%token cursorY
%token canvasX 
%token canvasY
%token semiColon
%token equals
%token comma
%token colon
%token drawingSectionToken
%token plus
%token minus

%token <id> message 
%token <id> idToken
%token <num> integer_literal

%type <id> idType 
%type <id> brushName
%type <id> brushNameWithSemiColon 
%type <num> cursor
%type <num> factor
%type <num> expression
%type <num> term
%%

Peakasso: programStart idType semiColon canvasInitSection brushDeclarationSection drawingSectionType    {exit(1);};
canvasInitSection: canvasStart colon canvasSizeInit cursorPosInit       {;};
canvasSizeInit :   constant canvasX equals integer_literal semiColon  
                   constant canvasY equals integer_literal semiColon   
                {if(5<=$4 && $4<=200) 
                        ccanvasX = $4; 
                else {
                        printf("WARNING CanvasX value(%d) out of range ",$4);
                        ccanvasX = 100;
                }
                if(5<=$9 && $9<=200) 
                        ccanvasY = $9; 
                else {
                        printf("WARNING CanvasY value(%d) out of range ",$9);
                        ccanvasY = 100;
                } 
                initializeCanvas();};


cursorPosInit  :   cursorX equals integer_literal semiColon cursorY equals integer_literal semiColon             
                        {ccursorX = $3; ccursorY = $7;};

brushDeclarationSection:   brushDeclaration colon                                    {;} 
                        | brushDeclaration colon variableDefination                  {;};

variableDefination: brush brushList semiColon                                        {;};

brushList   : brushName                                                              {;}
                | brushName comma brushList                                          {;};

brushName:  idType equals integer_literal integer_literal       {userInput = 1;$$ = $1;oneBrush($1,$3,$4);}
                |       idType {userInput = 0;$$ = $1;};

brushNameWithSemiColon : idType equals integer_literal integer_literal semiColon                                     
            {userInput = 1;$$ = $1;oneBrush($1,$3,$4);}
            |   idType semiColon {userInput = 0;$$ = $1;};

idType  :   idToken     {$$ = $1;};

drawingSectionType :  drawingSectionToken colon statements      {;};
statements      : statement                                     {;}
                | statement   statements                        {;};

statement :     renewStatement                                  {;}
            |   paintStatement                                  {;}
            |   exhibitStatement                                {;}
            |   cursorMoveStatement                             {;};

renewStatement : renewBrush  message  brushNameWithSemiColon   {
                if(contains($3)==0) {
                        printf("Variable %s is not defined ERROR\n",$3); 
                        exit(0);
                }
                memmove($2, $2 + 1, strlen($2));
                $2[strlen($2) - 1] = '\0';
                printf("%s\n",$2);
                if(userInput==0) {                 
                        if(parsingMode==0) {
                                fclose(yyin);
                                yyin = stdin;
                        }
                int height,width;
                scanf("%d",&height);
                scanf("%d",&width);
                oneBrush($3,height,width); 
                userInput = 1;
                if(parsingMode==0)
                        yyin = fopen(fileName, "r"); 
                }};

paintStatement : paintCanvas brushName   semiColon    {
                if(contains($2)==0) {
                        printf("Variable %s is not defined ERROR\n",$2); exit(0);}
                        paint($2);
                };

exhibitStatement: exhibitCanvas   semiColon                         {exhibit();};


cursorMoveStatement:  move cursor to expression    semiColon     
                {if($2==0) { 
                        if($4<=ccanvasX) 
                                ccursorX = $4; 
                        else 
                                printf("WARNING CursorX out of Range");
                }
                if($2==1) { 
                        if($4<=ccanvasY) 
                                ccursorY = $4; 
                        else 
                        printf("WARNING CursorY out of Range");
                }
                };

cursor:         cursorX                                 {$$ = 0;}
        |       cursorY                                 {$$ = 1;};

expression: term                                        {$$ = $1;}
        |   expression plus term                        {$$ = $1 + $3;}
        |   expression minus term                       {$$ = $1 - $3;};
         
term :  factor                                          {$$ = $1;};

factor:     integer_literal                             {$$ = $1;}
        |   cursor                                      {if($1==0) 
                                                                $$ = ccursorX;
                                                        else 
                                                                $$ = ccursorY;
                                                        }
        |   canvasX                                     {;}
        |   canvasY                                     {;};


%%                     
/* C code */

//Prints some important variables and their values for debugging
void check() {
        for (int i = 0; i<numberOfVariables;i++) {
                printf("\n\n%d\n",i);
                printf("Fname: %s\n",cBrush[i].name);
                printf("fwidth: %d\n",cBrush[i].width);
                printf("fheight: %d\n",cBrush[i].height);
        }
        printf("\nccanvasX: %d\n",ccanvasX);
        printf("ccanvasY: %d\n",ccanvasY);
        printf("ccursorX: %d\n",ccursorX);
        printf("ccursorY: %d\n",ccursorY);
}

//Checks wheter a given brush variable name is defined
int contains(char* fname) {
        for (int i = 0; i<numberOfVariables;i++) 
                if(strcmp(cBrush[i].name ,fname)==0) 
                        return 1;
        return 0;
}

//Adds one variable to our variable list
void oneBrush(char* fname,int fheight,int fwidth) {
        for (int i = 0; i<numberOfVariables;i++) {
                if(strcmp(cBrush[i].name ,fname)==0) {
                        cBrush[i].height = fheight;  
                        cBrush[i].width= fwidth;
                        return;
                }
        }
        cBrush[numberOfVariables].name = fname;
        cBrush[numberOfVariables].height = fheight;
        cBrush[numberOfVariables].width= fwidth;
        numberOfVariables++;
        //printf("Fname: %s\n",fname);  
        //printf("fwidth: %d\n",fwidth);
        //printf("fheight: %d\n",fheight);
        cBrush = realloc(cBrush,sizeof(struct cBrushS)* (numberOfVariables+1));
}

//Initializes the canvas
void initializeCanvas() {
        canvas = malloc(sizeof(int**)*ccanvasX);
        for(int i = 0; i<ccanvasX; i++) {
                canvas[i] = malloc(sizeof(int)*ccanvasY);
                for(int j = 0; j<ccanvasY; j++) {
                     canvas[i][j] = 0;   
                } 
        }
}

//Paint a given variable name to the canvas
void paint(char* fname) {
        int width,height;
        for (int i = 0; i<numberOfVariables;i++) {
                if(strcmp(cBrush[i].name ,fname)==0) {
                        width = cBrush[i].width;
                        height = cBrush[i].height;     
                        break;
                }
        }
        for(int j = 0; j < height ; j++) {
                for(int i = 0; i < width ; i++) {
                        canvas[ccursorY+j][ccursorX+i] = 1;
                }
        }
}

//Prints the canvas
void exhibit(){
        for(int j = 0; j < ccanvasY ; j++) {
                for(int i = 0; i < ccanvasX ; i++) {
                        if(canvas[j][i] == 0) {
                                printf(" ");
                        }else {
                                printf("*");
                        }
                }
                printf("\n");
        }
}
int main (void) {
        cBrush  = malloc(sizeof(struct cBrushS));
        

        printf("If you want to give input from terminal please"); 
        printf("write 1 and if you want to give input from .txt file please write 0\n");
        scanf("%d",&parsingMode);

        if(parsingMode==0) {
                fileName = malloc(sizeof(char)*1000);
                printf("Please enter a file name\n");
                scanf("%s",fileName);
                yyin = fopen(fileName, "r");
        }
        yyparse();       
}


void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 