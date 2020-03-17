pc	and|else|is|return|break|for|not|while|continue|if|or|def|import|pass|elif|in|print|True|False|range|break|pass|or

let	[A-Za-z]
dig	[0-9]
digs	{dig}+
id	({let}|"_")({let}|{dig}|"_")*
sig	("-")
nent	{sig}?{digs}
id_inv ({dig}|"_")({let}|{dig}|"_")*
pent	{digs}?
pdec	("."({digs}?))?
pexp	("e"(({sig})?){digs})?
ndec	{pent}{pdec}{pexp}

nimg	({nent}|{ndec})("j"|"J")
nlong	{digs}("L"|"l")
str	    (("'")([^']*)("'"))|(("\"")([^"]*)("\""))
comment "#".*
err \=\?|{id_inv}
op	"+"|"-"|"*"|"**"|"/"|"//"|"%"|"<<"|">>"|"&"|"|"|"^"|"~"|"<"|">"|"<="|">="|"=="|"!="|"<>"

del	"("|")"|"["|"]"|"="|";"|","|":"|"."|">>="|"<<="|"+="|"-="|"*="|"/="|"//="|"&="|"|="|"^="|"**="|"%="


%{
  #include <stdio.h>
  #include <string.h>
  #include <stdbool.h>
  void process();
  void upper_string();
  void process_keyword();
  void insert_id();
  void show_ids();
  int cont_id=0;
  int n=0;
  int cont_err = 0;
  char ids[9999][9999];
  char buffer[100];
%}


%%


{pc}	{process_keyword(yytext);}

"+"               {process("suma", yytext);}
"-"               {process("menos", yytext);}
"*"               {process("mult", yytext);}
"**"              {process("OP-EXP", yytext);}
"/"               {process("OP-DIV", yytext);}
"//"              {process("OP-DIVE", yytext);}
"%"               {process("OP-MOD", yytext);}
"<<"              {process("OP-BLS", yytext);}
">>"              {process("OP-BRS", yytext);}
"&"               {process("OP-Y", yytext);}
"|"               {process("OP-O", yytext);}
">"				  {process("MAYOR", yytext);}
"<"		          {process("MENOR", yytext);}
"<="	          {process("menor_ig", yytext);}
">="		      {process("MAYOR-O-IGUAL", yytext);}
"~"               {process("OP-NOT", yytext);}
"^"               {process("OP-XOR", yytext);}
"!="	       	  {process("DIFERENTE", yytext);}
"=="			  {process("comp", yytext);}
"("			      {process("parabre", yytext);}
")"			      {process("parcierr", yytext);}
":"			      {process("dospunt", yytext);}
"["			      {process("corabre", yytext);}
"]"			      {process("corcierr", yytext);}
"="			      {process("assign", yytext);}
","			      {process("coma", yytext);}


{id}	{insert_id(yytext);}
{nent}	{process("entero", yytext);}
{ndec}	{process("real", yytext);}
{nimg}	{process("imaginario", yytext);}
{nlong}	{process("long", yytext);}
{str}	{process("cadena", yytext);}
{comment}         {process("COMENTARIO", yytext);}
{err}         {process("ERROR", yytext);cont_err++;}
{del}	{}


%%
int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    FILE *out_file = fopen("salida.txt", "w");
    yyout = out_file;
    yylex();
    fclose(yyin);
    fprintf(yyout, "\n");
    show_ids();
    fprintf(yyout, "\n");
    fprintf(yyout, "Se encontraron %d errores\n", cont_err);
}


void upper_string(char s[]) {
   int c = 0;
   while (s[c] != '\0') {
      if (s[c] >= 'a' && s[c] <= 'z') {
         s[c] = s[c] - 32;
      }
      c++;
   }
}

void process_keyword(char keyword[]) {
  upper_string(keyword);
  fprintf(yyout, "%s ", keyword);
}

void process(char rule_name[], char value[]) {
  if(rule_name!="COMENTARIO"){
    fprintf(yyout, "%s=%s ", rule_name, yytext);
  }
  
}

void insert_id(char text[]) {
  bool new_id = true;
	for(int i = 0; i < cont_id; i++){
		if(strcmp(text, ids[i]) == 0) {
			new_id = false;
            n = i;
		}
	}
  if (new_id){
    strcpy(ids[cont_id], text);
    n = cont_id;
    cont_id++;
  }
  sprintf(buffer, "ID%d", n);
  process(buffer,text);
}


void show_ids() {
  if(cont_id == 0) {
    fprintf(yyout, "No se detectaron identificadores\n");
  }
  else {
    fprintf(yyout, "Hay %d identificadores:\n", cont_id);
    for(int i = 0; i < cont_id; i++) {
      fprintf(yyout, "ID%d=%s; ", i, ids[i]);
    }
    fprintf(yyout, "\n");
	}
}

