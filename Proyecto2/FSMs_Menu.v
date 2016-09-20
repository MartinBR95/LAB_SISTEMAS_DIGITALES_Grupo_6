`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:51:55 09/13/2016 
// Design Name: 
// Module Name:    FSMs_Menu 
// Module Name:    FSMs_Menu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FSMs_Menu (IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW,Acceso,Mod,Alarma,STW,CLK,Dir,Numup,Numdown,Punt);

input wire CLK,IRQ,Barriba,Babajo,Bderecha,Bizquierda,Bcentro,RST,FRW; //IRQ: interrupcion del RTC para temporizador,FRW:finalizo lectura/escritura
output reg [6:0] Dir; //Direccion de memoria del rtc al que se apunta
output reg Acceso,Mod,Alarma,STW,Numup,Numdown; //Acceso: a control RTC, Mod: modificacion del RTC, Alarma:Apagar alarma,Num++/Num--:aumentar/disminuir valor contenido en la direccion actual
output reg [6:0] Punt;//Es un puntero que guarda la direccion donde se estan editando los valores
//////////////////////////////////Maquina de Estados Principal///////////////////////////////////////////////////
localparam [7:0]TiempoEspera=5;
//Registros de estado
reg [2:0] EstadoActual;
reg [2:0] EstadoSiguiente;
reg Mod_Siguiente;
reg Numup_Siguiente;
reg Numdown_Siguiente;
//Registros Internos
reg Barrido; //Indica que se debe recorrer la memoria
reg FBarrido; //Proviene de la maquina de Cuenta e indica que se ha terminado de recorrer la memoria
reg Espera; //Indica a la maquina de estado que debe realizar un ciclo de espera
reg [7:0] cuenta_espera;
reg Fespera;//La maquina de estado de espera indica que termino la espera
wire Fcount;
reg [6:0] Punt_Siguiente;
wire cond1;
assign cond1 = Barriba|Babajo|Bderecha|Bizquierda|Bcentro;
assign Fcount=Dir==7'h44;
//Valores Iniciales y asignacion de estado
always @( posedge CLK,posedge RST)
begin
	if (RST)
	begin
		EstadoActual <= 3'd1 ; //Estado inicial
		Punt<=7'h21;
		Mod<=1'b0;
		Numup<=1'b0;
		Numdown<=1'b0;
	end
	else
	begin
		EstadoActual <= EstadoSiguiente ;
		Punt<=Punt_Siguiente;
		Mod<=Mod_Siguiente;
	end
end
//Logica Combinacional de siguiente estado y logica de salida
always @(*)
begin
	Acceso=1'b1;
	Espera=1'b0;
	Barrido=1'b0;
	Mod_Siguiente=Mod;
	Punt_Siguiente=Punt;
	case(EstadoActual)
	3'd1:if(FRW)
		begin
			Barrido=1'b1;
			EstadoSiguiente=3'd2;
		end
		else
		begin
			EstadoSiguiente=3'd1;			
		end
	3'd2:if(FBarrido)
		begin
			Espera=1'b1;
			EstadoSiguiente=3'd3;
			Acceso=1'b0;
			Mod_Siguiente=1'b0;
		end
		else
		begin
			Barrido=1'b1;
			EstadoSiguiente=3'd2;
		end
		
	3'd3:if(Fespera)
		begin
			Barrido=1'b1;
			EstadoSiguiente=3'd4;
		end
		else
		begin
			EstadoSiguiente=3'd3;
		end
	3'd4:if(Bcentro)
		begin		
			Mod_Siguiente=1'b1;
			Barrido=1'b1;
			Punt_Siguiente=7'h21;
			EstadoSiguiente = 3'd2;
		end
		else
		begin
			Barrido=1'b1;
			EstadoSiguiente = 3'd2;
		end		
	default
	begin
		EstadoSiguiente = 3'd1;
	end
	endcase
end

//////////////////////////////////////Maquina de estados de Cuenta////////////////////////////////////
//Registros de estado
reg [2:0] EstadoActualc;
reg [2:0] EstadoSiguientec;
reg [6:0] Dir_Siguiente;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		EstadoActualc <= 3'd1;
		Dir <= 7'h02;
	end
	else
	begin
		EstadoActualc <= EstadoSiguientec;
		Dir <= Dir_Siguiente;
	end
end


always @(*)
begin
	FBarrido=1'b0;
	EstadoSiguientec = 3'd1;
	Dir_Siguiente = Dir;
	case(EstadoActualc)	
	3'd1:if(Barrido)
		begin
			EstadoSiguientec=3'd2;		
		end
		else
		begin
			EstadoSiguientec=3'd1;
			Dir_Siguiente=7'h21;
		end
	3'd2:if(FRW)
		begin	
			Dir_Siguiente = Dir + 1'b1;
			EstadoSiguientec=3'd3;			
		end
		else
		begin
			EstadoSiguientec=3'd2;
		end
	
	3'd3:if(Dir==7'h27)
		begin
			Dir_Siguiente=7'h41;
			EstadoSiguientec=3'd4;
		end
		else
		begin
			EstadoSiguientec=3'd4;
		end
	3'd4:if(Fcount)
		begin
			FBarrido=1'b1;
			EstadoSiguientec=3'd1;
			Dir_Siguiente=7'h21;
		end
		else
		begin	
			EstadoSiguientec=3'd2;
		end
	default
	begin
		EstadoSiguientec = 3'd1;
	end	
	endcase	
end
//////////////////////////////////////Maquina de estados de Espera////////////////////////////////////
//Registros de estado
reg [1:0] EstadoActuale;
reg [1:0] EstadoSiguientee;
reg [7:0] cuenta_espera_sig;
//Valores Iniciales y asignacion de estado
always@ ( posedge CLK, posedge RST )
begin
	if (RST)
	begin
		EstadoActuale <= 2'd1;
		cuenta_espera <= 8'd1;
	end
	else
	begin
		cuenta_espera <= cuenta_espera_sig;
		EstadoActuale <= EstadoSiguientee;
	end
end


always @(*)
begin
	cuenta_espera_sig = cuenta_espera;
	Fespera=1'b0;
	EstadoSiguientee=2'd1;
	case(EstadoActuale)	
	3'd1:if(Espera)
		begin
			EstadoSiguientee=2'd2;
		end
		else
		begin
			EstadoSiguientee=2'd1;
		end

	3'd2:if(Fespera)
		begin
			EstadoSiguientee=2'd1;
		end
		else
		begin
			if(cuenta_espera==TiempoEspera)
			begin
				cuenta_espera_sig=8'b1;
				Fespera=1'b1;
				EstadoSiguientee=2'd1;
			end
			else
			begin			
				cuenta_espera_sig = cuenta_espera+1'b1;
				EstadoSiguientee = 2'd2;
			end
		end
	default
	begin
		EstadoSiguientee = 2'd1;
	end	
	endcase	
end
endmodule

















