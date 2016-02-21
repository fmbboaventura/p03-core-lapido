
/***************************************************
 * Module: comparator_tb
 * Project: core_lapido
 * Author: Gadiel Xavier
 * Description: Test Bench criado para o modulo do comparator.
 ***************************************************/

module comparator_tb();

	reg [31:0] a;		
	reg [31:0] b;
 	
    	wire c;
	
	comparator dut(
		.a(a),
		.b(b),
		.c(c)
	);


	initial begin
		a = 0;
		b = 0;

		display_comparator;
	end

	task display_comparator;
		begin
			a = $random;
			b = $random;
			#1;
			$display("a: %b\t b: %b\t c: %b", a, b, c);
			if (c==(a==b))
				$display("OK, passou no teste");
			else
				$display("Erro! Esperado %d, Obteve: %d", a==b, c);
		end
	endtask
endmodule