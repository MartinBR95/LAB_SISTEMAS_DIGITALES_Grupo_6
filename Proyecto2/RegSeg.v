//////////////////////////////////////////////////////////////////////////////////
module RegSeg
	(
	input CLK,RST,				//Reloj general del circuito
	input UP,  				//Se�al de incremento
	input DOWN,				//Se�al de decremento
	input Modificando,	//Se�al de modificacion 
	input Actualizar, 	//Se�al de actualizacion de datos
	input  [7:0]DATA_in,	//Datos de entrada 
	output [7:0]DATA_out	//Datos de salida
   );

reg [7:0]Auxiliar  =  8'd0; //

////////////////////////////////////////////////
/////////// SECCION DE BANDERAS ////////////////
always @(posedge CLK, posedge RST)		//Modificacion de datos
begin
	if(RST == 1'b1) Auxiliar = 8'h22;
	else begin	
	if(UP == 1'b1 && Modificando == 1'b1) 	 //Si se incrementa manualmente 
	begin
	case (Auxiliar)
			8'h09 : Auxiliar = 8'h10; 
			8'h19 : Auxiliar = 8'h20; 
			8'h29 : Auxiliar = 8'h30; 
			8'h39 : Auxiliar = 8'h40; 
			8'h49 : Auxiliar = 8'h50; 
			8'h59 : Auxiliar = 8'h00; 
			default Auxiliar = Auxiliar + 1'b1;
	endcase 
	end 

	if(DOWN == 1'b1 && UP == 1'b0 && Modificando == 1'b1) //Si se decrementa manualmente
	begin
	case (Auxiliar)
			8'h00 : Auxiliar = 8'h59; 
			8'h10 : Auxiliar = 8'h09; 
			8'h20 : Auxiliar = 8'h19; 
			8'h30 : Auxiliar = 8'h29; 
			8'h40 : Auxiliar = 8'h39; 
			8'h50 : Auxiliar = 8'h49; 
			default Auxiliar = Auxiliar - 1'b1;
	endcase 
	end 

	if(Modificando == 1'b0 && Actualizar == 1'b1) Auxiliar = DATA_in; //Si se debe actualizar el registro con los datos de entrada
	else Auxiliar = Auxiliar; end
end

assign DATA_out = Auxiliar; 
endmodule 