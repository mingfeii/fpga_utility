onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_memory_tester/axi_master_checker_U/clk
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rst_n
add wave -noupdate /tb_memory_tester/axi_master_checker_U/axi_wr_en
add wave -noupdate /tb_memory_tester/axi_master_checker_U/axi_rd_en
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wr_finish
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rd_finish
add wave -noupdate /tb_memory_tester/axi_master_checker_U/fail
add wave -noupdate /tb_memory_tester/axi_master_checker_U/done
add wave -noupdate -divider AW
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awaddr
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awready
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awvalid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awlen
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awsize
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awburst
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awlock
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awcache
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awprot
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awqos
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awregion
add wave -noupdate -divider W
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wvalid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wready
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wdata
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wlast
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wstrb
add wave -noupdate /tb_memory_tester/axi_master_checker_U/state
add wave -noupdate /tb_memory_tester/axi_master_checker_U/state_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/write_data_count
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awaddr_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awvalid_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awaddr_lock
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awaddr_lock_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/bready_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wvalid_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/write_data_count_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/bid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/bresp
add wave -noupdate /tb_memory_tester/axi_master_checker_U/bvalid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/bready
add wave -noupdate -divider AR
add wave -noupdate /tb_memory_tester/axi_master_checker_U/arvalid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/arready
add wave -noupdate /tb_memory_tester/axi_master_checker_U/araddr
add wave -noupdate /tb_memory_tester/axi_master_checker_U/arid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/arlen
add wave -noupdate /tb_memory_tester/axi_master_checker_U/arsize
add wave -noupdate -divider R
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rvalid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rready
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rdata
add wave -noupdate /tb_memory_tester/axi_master_checker_U/read_data_store
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rid
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rlast
add wave -noupdate /tb_memory_tester/axi_master_checker_U/read_data_count
add wave -noupdate /tb_memory_tester/axi_master_checker_U/read_data_count_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/arburst
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rresp
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awaddr_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awvalid_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awaddr_lock
add wave -noupdate /tb_memory_tester/axi_master_checker_U/awaddr_lock_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/bready_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/wvalid_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/araddr_lock
add wave -noupdate /tb_memory_tester/axi_master_checker_U/araddr_lock_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/araddr_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/rready_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/arvalid_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/fail_nxt
add wave -noupdate /tb_memory_tester/axi_master_checker_U/done_nxt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20059826 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
configure wave -valuecolwidth 297
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
WaveRestoreZoom {16977406 ps} {25461630 ps}
