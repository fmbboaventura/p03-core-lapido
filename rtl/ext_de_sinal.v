module ext_de_sinal
             (
            input [15:0] unex,

	    output [31:0] ext
             );

assign ext = {{16{unex[15]}}, unex};
endmodule
