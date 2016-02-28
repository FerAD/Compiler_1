/* Archivo con el reconocedor léxico para la calculadora */
%{

#include <stdlib.h>
#include <math.h>

#define NUMERO  15
#define IDE  1
#define IF  2
#define THEN  3
#define WHILE  4
#define DO  5
#define BEG  6
#define END  7
#define MAS  8
#define MENOS  9
#define POR 10
#define ENTRE 11
#define IGUAL 12
#define PABRE 13
#define PCIERRA 14
#define PUNTOYCOMA 16

int entero;
char * op;
char * id;
char * sc;
char * ig;
char * pa;
char * pc;
int res;
int tamanioCadena;

 
  /* Se incluye el archivo generado por bison para tener las definiciones
     de los tokens */


%}
NUM	[1-9][0-9]*
ID 	[a-z,A-Z]([0-9][a-z,A-Z])*

%%

{NUM}	{ entero = atoi(yytext); return NUMERO;} // Lo convertimos a número entero
{ID}	{id = yytext; tamanioCadena++; return IDE;}
"if"	{sc = yytext; tamanioCadena++; return IF;} 
"then"	{sc = yytext; tamanioCadena++; return THEN;}
"while"	{sc = yytext; tamanioCadena++; return WHILE;}
"do"	{sc = yytext; tamanioCadena++; return DO;}
"begin"	{sc = yytext; tamanioCadena++; return BEG;}
"end" 	{sc = yytext; tamanioCadena++; return END;}
"+" 	{op = yytext; tamanioCadena++; return MAS;}
"-" 	{op = yytext; tamanioCadena++; return MENOS;}
"*" 	{op = yytext; tamanioCadena++; return POR;} 
"/" 	{op = yytext; tamanioCadena++; return ENTRE;}
":="	{ig = yytext; tamanioCadena++; return IGUAL;}
"("		{pa = yytext; tamanioCadena++; return PABRE;}
")"		{pc = yytext; tamanioCadena++; return PCIERRA;}
%%

int stmt(int val);	//funcion recibe el valor y lo que es
int expr();
int exprP();
int term();
int termP();
int factor();
int stmt_lst();
int opt_stmts();

int main(){	
	

	int resultado = 0;	//variable que me indica si es aceptado o no
	res = yylex();		//leo caracter
	
	if(res == IDE){		// si lo que leo es un ID
		resultado = stmt(res);	// llamo a stmt y guardo el resultado
	}else if(res == IF){	// si es un IF			
		resultado = stmt(res);	//llamo a stmt y guardo el resultado	
	}else if(res == WHILE){			//si es un WHILE 
		resultado = stmt(res);		//llamo a stmt y guardo el resultado
	}else if(res == BEG){	// si es BEGIN 
		resultado = stmt(res);	//llamo a stmt y guardo el resultado 	
	}

	if(resultado == 0){	// si el resultado obtenido de cualquiera de los if anterior es 0 no se acepta
		printf("NO ES ACEPTADO\n");	
	}else if(resultado == 1){	//si el resultado obtenido de los if anteriores es 1 se acepta el lenguaje
		printf("SI ES ACEPTADO\n");
	}
	return resultado;	//termino el programa


} 

int stmt(int val){	//stmt recibe una cadena de lo que dice lo que se lee y el valor que representa lo que se lee
	int resultado = 0;	//variable que me indica si se acepta
	int val2 = val;
	
	if(val2 == IDE){	//si el resor que se recibe corresponde a IDE
		res = yylex();	//me muevo dos espacios en busqueda de :=
		res = yylex();
		if(res == IGUAL){	//si lo que encuentro es := entonces vamos bien y el siguiente debe ser un expr
			resultado = expr();	//llamo a expr para que analice el siguiente dato a leer y guardo el resultado
		}else{	//si no encuentro un := entonces el lenguaje NO es aceptado
			resultado =  0;
		}
	}else if(val2 == IF){	// si el valor leeido de entrada es IF 
		res = yylex();	// leo el siguiente elemento
		resultado = expr();	// checo si es una expr
		if(resultado == 1){	// si si es expr
			if(res == THEN){	// checo que el siguiente resultado sea THEN 
				res = yylex();	// si si leeo el siguiente elemento 	
				if((resultado = stmt(res)) == 1){	// y checo si es un stmt
					resultado = 1;	// si si todo esta bien regresa 1
				}else {
					resultado = 0;	// si no regresa 0
				}
			}else{
				resultado = 0;
			}

		}
	}else if(val2 == WHILE){	//si el valor leeido es WHILE 
		res = yylex();	//leeo el siguiente elemento 
		resultado = expr();	//checo si es una expr
		if(resultado == 1){	// si si 
			if(res == DO){	// checo que el siguiente elemento sea un DO
				res = yylex();	// si si leeo lo que sigue 
				if((resultado = stmt(res)) == 1){	// checo que sea una stmt
					resultado = 1;	// regreso 1 si es una stmt
				}else{
					resultado = 0;	// sino regreso 0 
				}
			}else{
				resultado = 0; // si el siguiente elemento no es DO regreso 0
			}
		}

	}else if(val2 == BEG){	// if el valor leido es BEG 
		res = yylex();	// leeo otro elemento 
		if(res != 0){ // si no esta vacio entonces
			resultado = opt_stmts();	// checo que es una stmt o una lista de stmt
			if(resultado == 1){	// si esta correcto todo 
				res = yylex();	// leeo el siguiente caracter
				if(res == END){	// si el siguiente caracter es un end regreso 1 
					resultado = 1;
				}
			}
		}else{	// si es vacio entonces regreso 0
			resultado = 0;
		}

	}


	return resultado; 
}

int expr(){	// expr es un metodo que analisa el siguiente dato a leer 
	int resultado = 0;
	res = yylex();	//leeo el siguiente elemento
	if((resultado = term()) == 1){	// se le manda a term para que analice que es y se guarda el resultado
		resultado = exprP();	//si existe un term entonces se pasa a exprP para analizar lo que sigue a ese termino 
	}
	return resultado;	//se regresa un resultado
}

int exprP(){	// 
	int resultado = 0;	//variable resultado
	if(res == MAS){	// si lo leeido es un mas 
		res = yylex();	// leeo el siguiente elemento 
		if((resultado = term()) == 1){	// checo que sea un term si si 
			resultado = exprP();	// checo que ya no haya mas expreciones signo termino (+ 3) que agregar 
		}
	}else if(res == MENOS){	// si lo leeido es un menos 
		res = yylex();	// checo el siguiente caracter 	
		if((resultado = term()) == 1){	// checo que sea un termino 
			resultado = exprP();	// si si es un term entonces checo que no haya mas expreciones signo termino (- 3) que agregar
		}else{	// si el lo leeido no es un term regreso 0
			resultado = 0;
		}
	}else if(res == 0 || res == 1 || res == 15){ // si no es ni un mas ni un menos entonces 
		res = yylex();
		res = yylex();
		
		resultado = 1;
	}else if(res == THEN){	// si leeo un THEN entonces regreso 1
		return 1;
	}	
	else if(res == DO){	// si leeo un DO entonces regreso 1
		return 1;
	}
	else{	// si leeo cualquier cosa que no sea lo anterior regreso 0 
		resultado = 0;
	}
	return resultado;	// regreso el resultado 
}

int term(){	// metodo que checa si es un factor (id, numero, ( ) ) y sus posbiles concatenaciones 
	int resultado = 0;
	if((resultado = factor()) == 1){	// checo que lo que leeo sea un factor si es asi checa si hay mas elementos 
		resultado = termP();
	}
	return resultado;
}

int termP(){	// termp analiza si hay mas elementos en lac adena que pertenescan al factor como una multiplicacion o una divicion 
	int val;
	val = res;
	int resultado = 0;
	res = yylex();	// checo el siguiente elemento 
	if(res == POR){	// si es un por 
		res = yylex();	// leeo el siguiente elemento 
		if((resultado = factor()) == 1){	// checo que ele elemento leeido sea un numero o un id
			resultado = termP();	// checo que no haya mas elemento que multiplicar o dividir
		}
	}else if(res == ENTRE){	// si es un entre
		res = yylex();	// leeo el siguiente elemento 
		if((resultado = factor()) == 1){	// checo si es un numero o un id
			resultado = termP();	// si si es entonces checo que no haya mas elementos que multiplicar o dividir
		}
	}else if(res == 0 || res == MAS || res == MENOS){	// si lo leeido es un 0 o un mas o un menos entonces regreso 1
		resultado = 1;
	}else if(res == 1 || res == 15){	// si es un id o un numero regreso 1 
		resultado = 1;
	}else if(res == THEN){	// si lo leeido es then entonces regreso 1 
		return 1;
	}else if(res == DO){	// si lo leeido es DO entonces regreso 1 
		return 1;
	}else {
		return 0;
	}

	return resultado;
}

int factor(){	// checa que lo que se leea sea un numero un id o un parentesis que abre o cierra 
	int resultado = 0;
	if( res == PABRE){ 	// si es un PABRE entonces checa que lo que siga sea una exprecion y tenga un PCIERRA
		resultado = expr();
		res = yylex();
		if (res == PCIERRA && resultado == 1){	// si si es una expresion y tiene un PCIERRA entonces regresa 1
			return 1;
		}
	}else if(res == IDE){	// checa si es un ID
		resultado = 1;
	}else if(res == NUMERO){	//checa si es un NUMERO
		resultado = 1;
	}

	return resultado;
}

int opt_stmts(){	//checa si lo que sige de begin exista si no hay nada regresa 0 si hay algo checa que sea un stmt o un stmt list 
	int resultado = 0;
	if (res != 0){
		resultado = stmt_lst();	 //guardo el valor para regresar
	}else{
		resultado = 0;
	}
	
	return resultado;
}

int stmt_lst(){	// checa si es una serie de instrucciones o una instruccion nada mas 
	int resultado = 0;
	resultado = stmt(res);	// checa que sea un stmt
	if(resultado == 1){	// si si es un stmt
		res = yylex();	// lee la siguiente entrada
		
		if(res == PUNTOYCOMA){	// si es punto y coma es que hay mas instrucciones 
			resultado = stmt_lst();	// checa que otras instrucciones 
		}else if(res == 0 || res == END){	// si es 0 o end quiere decir que ya termino 
			resultado = 1;	// regresa 1
		}else {
			resultado = 0; 
		}
	}else{
		resultado = 0;
	}
	return resultado;
}


