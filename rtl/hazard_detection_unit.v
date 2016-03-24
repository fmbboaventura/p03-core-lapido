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
    input ID_EX_is_load,
    input [4:0] ID_EX_rt,
    input [4:0] IF_ID_rs,
    input [4:0] IF_ID_rt,
    input branch_taken,
    output stall_pipeline);

assign stall_pipeline = (branch_taken ||
                        ID_EX_is_load &&
                        ((ID_EX_rt == IF_ID_rs) ||
                        (ID_EX_rt == IF_ID_rt)));

endmodule // hazard_detection_unit
