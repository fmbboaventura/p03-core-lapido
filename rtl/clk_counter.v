/***************************************************
 * Module: clk_counter
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Bloco que avalia a necessidade de
 * habilitar a busca de instrucao e a escrita do
 * pc, baseado em uma quantidade de pulsos de clock.
 ***************************************************/
module clk_counter
(
    input clk,
    input rst,

    output if_enable,
    output pc_write       // Habilita a escrita no pc
);

reg [2:0] counter;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        counter <= 3'b000;
    end else if (counter == 3'b100) begin
        counter <= 3'b000;
    end else begin
        counter <= counter + 1;
    end
end

assign if_enable = (counter == 3'b000);
assign pc_write = (counter == 3'b100);

endmodule // clk_counter
