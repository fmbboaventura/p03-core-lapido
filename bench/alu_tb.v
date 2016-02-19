/***************************************************
 * Module: alu_tb
 * Project: core_lapido
 * Author: Felipe Cordeiro
 * Description: Test Bench criado para o modulo da alu.
 ***************************************************/

`include "lapido_defs.v"

module alu_tb();

	reg signed [31:0] op1;		// Primeiro operando
	reg signed [31:0] op2; 	// Segundo operando
    reg [5:0] alu_funct; 	// Operacao da alu

    wire signed [32:0] alu_res; 	// O 33th bit eh o carry da alu
    wire [4:0] flags;     	// Demais flags

    alu dut(
		.op1(op1),
		.op2(op2),
		.alu_funct(alu_funct),
		.alu_res(alu_res),
		.flags(flags)
	);



	initial begin
		op1 = 0;
		op2 = 0;
		alu_funct = 0;

		test_add;
	end

	task display_flags;
		begin
			$display("Flags: ");
			$display(
				"Zero: %b\tTrue: %b\tNeg: %b\tOveflow: %b\nNegZero: %b\tCarry: %b",
				flags[`FL_ZERO], flags[`FL_TRUE], flags[`FL_NEG], flags[`FL_OVERFLOW],
				flags[`FL_NEGZERO],
				alu_res[32] // <--carry da alu
		    );
		end
	endtask

	task test_add;
		begin
			$display("FN_ADD");
			alu_funct = `FN_ADD;
			op1 = $random;
			op2 = $random;
			#1;
			$display("rs: %d\trt: %d\tres: %d", op1, op2, alu_res);
			display_flags;

			if(alu_res == op1 + op2) $display("OK!");
			else $display("ERRO! @ %t , Esperado: %d,  Obteve %d",
			$time, op1 + op2, alu_res);
		end
	endtask // test_add

endmodule
