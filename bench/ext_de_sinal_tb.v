
module ext_de_sinal_tb;

reg  [15:0] unex;
wire   [31:0] ext;

ext_de_sinal dut(
                   .unex(unex),
                   .ext(ext)
                  );

initial
begin
   unex = 16'b0000000000000000;
   display_comparator;
end


task display_comparator;
	begin
   		unex = 16'b0000000011111111;
        #1;
		$display("unex: %b\t ext: %b", unex, ext);
   		unex = 16'b1000000011111111;
        #1;
		$display("unex: %b\t ext: %b", unex, ext);
	end
endtask
endmodule
