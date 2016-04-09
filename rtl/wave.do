onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /lapido_top_tb/dut/ex_stage/clk
add wave -noupdate -radix unsigned /lapido_top_tb/dut/ex_stage/rst
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/clk
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/rst
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/branch_addr
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/branch_taken
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/jump_addr
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/is_jump
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/stall_pipeline
add wave -noupdate -group IF_stage -radix hexadecimal /lapido_top_tb/dut/if_stage/instruction
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/pc
add wave -noupdate -group IF_stage -radix unsigned /lapido_top_tb/dut/if_stage/imem_instruction
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/clk
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/rst
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/branch_taken
add wave -noupdate -group ID_stage -radix hexadecimal -childformat {{{/lapido_top_tb/dut/id_stage/instruction_reg[31]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[30]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[29]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[28]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[27]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[26]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[25]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[24]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[23]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[22]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[21]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[20]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[19]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[18]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[17]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[16]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[15]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[14]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[13]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[12]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[11]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[10]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[9]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[8]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[7]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[6]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[5]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[4]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[3]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[2]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[1]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction_reg[0]} -radix hexadecimal}} -subitemconfig {{/lapido_top_tb/dut/id_stage/instruction_reg[31]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[30]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[29]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[28]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[27]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[26]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[25]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[24]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[23]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[22]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[21]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[20]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[19]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[18]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[17]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[16]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[15]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[14]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[13]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[12]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[11]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[10]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[9]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[8]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[7]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[6]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[5]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[4]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[3]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[2]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[1]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction_reg[0]} {-height 15 -radix hexadecimal}} /lapido_top_tb/dut/id_stage/instruction_reg
add wave -noupdate -group ID_stage -radix hexadecimal -childformat {{{/lapido_top_tb/dut/id_stage/instruction[31]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[30]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[29]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[28]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[27]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[26]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[25]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[24]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[23]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[22]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[21]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[20]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[19]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[18]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[17]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[16]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[15]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[14]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[13]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[12]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[11]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[10]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[9]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[8]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[7]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[6]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[5]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[4]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[3]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[2]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[1]} -radix hexadecimal} {{/lapido_top_tb/dut/id_stage/instruction[0]} -radix hexadecimal}} -subitemconfig {{/lapido_top_tb/dut/id_stage/instruction[31]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[30]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[29]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[28]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[27]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[26]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[25]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[24]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[23]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[22]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[21]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[20]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[19]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[18]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[17]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[16]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[15]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[14]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[13]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[12]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[11]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[10]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[9]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[8]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[7]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[6]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[5]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[4]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[3]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[2]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[1]} {-height 15 -radix hexadecimal} {/lapido_top_tb/dut/id_stage/instruction[0]} {-height 15 -radix hexadecimal}} /lapido_top_tb/dut/id_stage/instruction
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/pc
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/data_rs
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/data_rt
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/stall_pipeline
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/rs
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/rt
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/jump_addr
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/is_jump
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_alu_funct
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_alu_src_mux
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_reg_dst_mux
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_is_load
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_fl_write_enable
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_mem_write_enable
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_sel_beq_bne
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_sel_jt_jf
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_is_branch
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_sel_jflag_branch
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_wb_res_mux
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_reg_write_enable
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_rd
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_rs
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_rt
add wave -noupdate -group ID_stage -radix decimal /lapido_top_tb/dut/id_stage/out_imm
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/out_next_pc
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/ir_opcode
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/ir_funct
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/insert_bubble
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/in_stall_pipeline
add wave -noupdate -group ID_stage -radix unsigned /lapido_top_tb/dut/id_stage/sel_j_jr
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/clk
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/rst
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/branch_taken
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/alu_funct
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/alu_src_mux
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/reg_dst_mux
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/fl_write_enable
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/mem_write_enable
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/sel_beq_bne
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/sel_jt_jf
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/is_branch
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/sel_jflag_branch
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/wb_res_mux
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/reg_write_enable
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/rs
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/rt
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/rd
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/data_rs
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/data_rt
add wave -noupdate -expand -group EX_stage -radix decimal /lapido_top_tb/dut/ex_stage/imm
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/EX_MEM_data
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/MEM_WB_data
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/fowardA
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/fowardB
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/next_pc
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_mem_write_enable
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_wb_res_mux
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_reg_write_enable
add wave -noupdate -expand -group EX_stage -radix decimal /lapido_top_tb/dut/ex_stage/out_imm
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_next_pc
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_branch_addr
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_alu_res
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_mem_addr
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_mem_data
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_flags
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/out_reg_dest
add wave -noupdate -expand -group EX_stage -radix decimal /lapido_top_tb/dut/ex_stage/op1
add wave -noupdate -expand -group EX_stage -radix decimal /lapido_top_tb/dut/ex_stage/op2
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/mem_addr
add wave -noupdate -expand -group EX_stage -radix unsigned /lapido_top_tb/dut/ex_stage/mem_data
add wave -noupdate -expand -group EX_stage -radix decimal /lapido_top_tb/dut/ex_stage/alu_res
add wave -noupdate -group alu -radix decimal /lapido_top_tb/dut/ex_stage/alu/op1
add wave -noupdate -group alu -radix decimal /lapido_top_tb/dut/ex_stage/alu/op2
add wave -noupdate -group alu -radix hexadecimal /lapido_top_tb/dut/ex_stage/alu/alu_funct
add wave -noupdate -group alu -radix decimal -childformat {{{/lapido_top_tb/dut/ex_stage/alu/alu_res[31]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[30]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[29]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[28]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[27]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[26]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[25]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[24]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[23]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[22]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[21]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[20]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[19]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[18]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[17]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[16]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[15]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[14]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[13]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[12]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[11]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[10]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[9]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[8]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[7]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[6]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[5]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[4]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[3]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[2]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[1]} -radix decimal} {{/lapido_top_tb/dut/ex_stage/alu/alu_res[0]} -radix decimal}} -subitemconfig {{/lapido_top_tb/dut/ex_stage/alu/alu_res[31]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[30]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[29]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[28]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[27]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[26]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[25]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[24]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[23]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[22]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[21]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[20]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[19]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[18]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[17]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[16]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[15]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[14]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[13]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[12]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[11]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[10]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[9]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[8]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[7]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[6]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[5]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[4]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[3]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[2]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[1]} {-height 15 -radix decimal} {/lapido_top_tb/dut/ex_stage/alu/alu_res[0]} {-height 15 -radix decimal}} /lapido_top_tb/dut/ex_stage/alu/alu_res
add wave -noupdate -group alu -radix binary /lapido_top_tb/dut/ex_stage/alu/flags
add wave -noupdate -group alu /lapido_top_tb/dut/ex_stage/alu/unsigned_res
add wave -noupdate -group flags -radix binary /lapido_top_tb/dut/ex_stage/flags/clk
add wave -noupdate -group flags -radix binary /lapido_top_tb/dut/ex_stage/flags/rst
add wave -noupdate -group flags -radix binary /lapido_top_tb/dut/ex_stage/flags/branch_taken
add wave -noupdate -group flags -radix binary -childformat {{{/lapido_top_tb/dut/ex_stage/flags/in_flags[5]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/in_flags[4]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/in_flags[3]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/in_flags[2]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/in_flags[1]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/in_flags[0]} -radix binary}} -expand -subitemconfig {{/lapido_top_tb/dut/ex_stage/flags/in_flags[5]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/in_flags[4]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/in_flags[3]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/in_flags[2]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/in_flags[1]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/in_flags[0]} {-height 15 -radix binary}} /lapido_top_tb/dut/ex_stage/flags/in_flags
add wave -noupdate -group flags -radix binary /lapido_top_tb/dut/ex_stage/flags/fl_write_enable
add wave -noupdate -group flags -radix binary -childformat {{{/lapido_top_tb/dut/ex_stage/flags/out_flags[5]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/out_flags[4]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/out_flags[3]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/out_flags[2]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/out_flags[1]} -radix binary} {{/lapido_top_tb/dut/ex_stage/flags/out_flags[0]} -radix binary}} -expand -subitemconfig {{/lapido_top_tb/dut/ex_stage/flags/out_flags[5]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/out_flags[4]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/out_flags[3]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/out_flags[2]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/out_flags[1]} {-height 15 -radix binary} {/lapido_top_tb/dut/ex_stage/flags/out_flags[0]} {-height 15 -radix binary}} /lapido_top_tb/dut/ex_stage/flags/out_flags
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/clk
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/rst
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/en
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/rd
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/rs
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/rt
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/data
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/data_rs
add wave -noupdate -expand -group reg_file -radix unsigned /lapido_top_tb/dut/reg_file/data_rt
add wave -noupdate -expand -group reg_file -radix decimal -childformat {{{/lapido_top_tb/dut/reg_file/registers[15]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[14]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[13]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[12]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[11]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[10]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[9]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[8]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[7]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[6]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[5]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[4]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[3]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[2]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[1]} -radix decimal} {{/lapido_top_tb/dut/reg_file/registers[0]} -radix decimal}} -expand -subitemconfig {{/lapido_top_tb/dut/reg_file/registers[15]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[14]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[13]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[12]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[11]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[10]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[9]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[8]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[7]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[6]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[5]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[4]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[3]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[2]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[1]} {-height 15 -radix decimal} {/lapido_top_tb/dut/reg_file/registers[0]} {-height 15 -radix decimal}} /lapido_top_tb/dut/reg_file/registers
add wave -noupdate -group hdu -radix unsigned /lapido_top_tb/dut/hdu/ID_EX_is_load
add wave -noupdate -group hdu -radix unsigned /lapido_top_tb/dut/hdu/ID_EX_rt
add wave -noupdate -group hdu -radix unsigned /lapido_top_tb/dut/hdu/IF_ID_rs
add wave -noupdate -group hdu -radix unsigned /lapido_top_tb/dut/hdu/IF_ID_rt
add wave -noupdate -group hdu -radix unsigned /lapido_top_tb/dut/hdu/stall_pipeline
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/ID_EX_rs
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/ID_EX_rt
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/EX_MEM_reg_write_enable
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/EX_MEM_rd
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/MEM_WB_reg_write_enable
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/MEM_WB_rd
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/fowardA
add wave -noupdate -group fu -radix unsigned /lapido_top_tb/dut/fu/fowardB
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/clk
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/rst
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/wb_res_mux
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/reg_write_enable
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/mem_write
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/in_next_pc
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/alu_res
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/in_mem_addr
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/in_mem_data
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/in_immediate
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/in_reg_dst
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/out_wb_res_mux
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/out_reg_write_enable
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/out_next_pc
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/out_mem_data
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/out_alu_res
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/out_imm
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/out_reg_dst
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/wire_out_mem_data
add wave -noupdate -group MEM_stage -radix unsigned /lapido_top_tb/dut/mem_stage/wire_out_bru
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/wb_res_mux
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/reg_write_enable
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/next_pc
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/mem_data
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/alu_res
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/imm
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/reg_dst
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/out_reg_write_enable
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/out_wb_res
add wave -noupdate -expand -group WB_stage -radix unsigned /lapido_top_tb/dut/wb_stage/out_reg_dst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {815 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 142
configure wave -valuecolwidth 81
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {740 ps} {788 ps}
