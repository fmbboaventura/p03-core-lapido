/***************************************************
 * Module: hazard_detection_unit
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo responsavel por identificar a
 * ocorrencia de load-use data hazards. Insere bolhas
 * no pipeline entre um load e a instrucao seguinte
 * se esta usar o dado carregado pela primeira.
 ***************************************************/
module hazard_detection_unit
(
    input ID_EX_mem_read,
    input [4:0] ID_EX_rt,
    input [4:0] IF_ID_rs,
    input [4:0] IF_ID_rt,
    output stall_pipeline);

assign stall_pipeline = (ID_EX_mem_read &&
                        (ID_EX_rt == IF_ID_rs) ||
                        (ID_EX_rt == IF_ID_rt));

endmodule // hazard_detection_unit
