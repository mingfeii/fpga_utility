//ddr这边接口固定128bit,burst 8
//假设地址使能和读写使能是一起拉的。
module simple_ddr #(
    parameter WFIFO_WIDTH = 128, //fixed
    parameter DM_BIT_WIDTH = 16

)(
    input                       clk,
    input                       rst_n,

    output 						wr_busy,
    input [WFIFO_WIDTH-1'b1:0]	wr_data,
    input [DM_BIT_WIDTH-1'b1:0] wr_datamask,
    input [31:0]				wr_addr,
    input 						wr_en,
    input						wr_addr_en,
    output 						wr_ack,
    output 						rd_busy,
    input  [31:0] 				rd_addr,
    input  						rd_addr_en,
    input  						rd_en,
    output [WFIFO_WIDTH-1'b1:0]	rd_data,
    output 						rd_valid,
    output 						rd_ack
);

logic [127:0] wr_data_1;
logic [31:0] wr_addr_1;
logic [127:0] rdata_0;

logic we,re;
logic wr_addr_en_1;
logic we_1,wr_en_1;
logic rd_data_full;
logic rd_data_empty;
logic rd_data_rd_valid;
logic we_2;
logic re_1,re_2;

logic wr_addr_full;
logic wr_addr_empty;
logic wr_addr_rd_valid;
logic [31:0] wr_addr_rdata;

logic wr_data_full;
logic wr_data_empty;
logic wr_data_rd_valid;
logic [127:0] wr_data_rdata;


logic rd_addr_full;
logic rd_addr_empty;
logic rd_addr_rd_valid;
logic [31:0] rd_addr_rdata;

assign wr_busy = wr_addr_full | wr_data_full;
assign rd_busy = rd_data_full | rd_addr_full;
assign we = ~wr_data_empty & ~wr_addr_empty;
assign re = ~rd_addr_empty;


always_ff@(posedge clk) begin re_1 <= re; re_2 <= re_1; end 

always_ff@(posedge clk) we_2 <= we_1;

always_ff@(posedge clk) we_1 <= we;

always_ff@(posedge clk) wr_en_1 <= wr_en;


always_ff@(posedge clk) begin 
    wr_addr_1 <= wr_addr;
    wr_addr_en_1 <= wr_addr_en;
end 


always_ff@(posedge clk or negedge rst_n)begin
    integer i;
    if (~rst_n)
        wr_data_1 <= '0;
    else begin 
        for (i=0;i<16;i++)begin 
            if (wr_en & !wr_datamask[i]) begin 
                wr_data_1[i*8+:8] <= wr_data[i*8+:8];
            end 
        end 
    end 
end 





addr_fifo u_addr_wr(
.almost_full_o  (                   ),
.prog_full_o    (                   ),
.full_o         ( wr_addr_full      ),
.overflow_o     (                   ),
.wr_ack_o       (                   ),
.empty_o        ( wr_addr_empty     ),
.almost_empty_o (                   ),
.underflow_o    (                   ),
.rd_valid_o     ( wr_addr_rd_valid  ),
.rdata          ( wr_addr_rdata     ),
.clk_i          ( clk               ),
.wr_en_i        ( wr_addr_en_1        ),
.rd_en_i        ( we_1    ),
.a_rst_i        ( ~rst_n            ),
.wdata          ( wr_addr_1           ),
.datacount_o    (                   ),
.rst_busy       (                   )
);




data_fifo u_data_wr(
.almost_full_o  (                       ),
.prog_full_o    (                       ),
.full_o         ( wr_data_full          ),
.overflow_o     (                       ),
.wr_ack_o       ( wr_ack                ),
.empty_o        ( wr_data_empty         ),
.almost_empty_o (                       ),
.underflow_o    (                       ),
.rd_valid_o     ( wr_data_rd_valid      ),
.rdata          ( wr_data_rdata         ),
.clk_i          ( clk                   ),
.wr_en_i        ( wr_en_1               ),
.rd_en_i        ( we_1                  ),
.a_rst_i        ( ~rst_n                ),
.wdata          ( wr_data_1             ),
.datacount_o    (                       ),
.rst_busy       (                       )
);




addr_fifo u_addr_rd(
.almost_full_o  (                   ),
.prog_full_o    (                   ),
.full_o         ( rd_addr_full      ),
.overflow_o     (                   ),
.wr_ack_o       (                   ),
.empty_o        ( rd_addr_empty     ),
.almost_empty_o (                   ),
.underflow_o    (                   ),
.rd_valid_o     ( rd_addr_rd_valid  ),
.rdata          ( rd_addr_rdata     ),
.clk_i          ( clk               ),
.wr_en_i        ( rd_addr_en        ),
.rd_en_i        ( ~rd_addr_empty    ),
.a_rst_i        ( ~rst_n            ),
.wdata          ( rd_addr           ),
.datacount_o    (                   ),
.rst_busy       (                   )
);


data_fifo u_data_rd(
.almost_full_o  (                       ),
.prog_full_o    (                       ),
.full_o         ( rd_data_full          ),
.overflow_o     (                       ),
.wr_ack_o       ( rd_ack                ),
.empty_o        ( rd_data_empty         ),
.almost_empty_o (                       ),
.underflow_o    (                       ),
.rd_valid_o     ( rd_valid              ), // output to port 
.rdata          ( rd_data               ),
.clk_i          ( clk                   ),
.wr_en_i        ( re_2                  ),
.rd_en_i        (  rd_en                ),
.a_rst_i        ( ~rst_n                ),
.wdata          ( rdata_0               ),
.datacount_o    (                       ),
.rst_busy       (                       )
);



ddr_simple_dual_port_ram #(
   .DATA_WIDTH (128),
   .ADDR_WIDTH (28),
   .RAM_INIT_FILE(""),
   .OUTPUT_REG ("TRUE")
) ddr_ram (
   .wdata   (wr_data_rdata),
   .waddr   (wr_addr_rdata), 
   .raddr   (rd_addr_rdata),
   .we      (we_2), 
   .wclk    (clk), 
   .re      (re_1), 
   .rclk    (clk),
   .rdata   (rdata_0)
);





endmodule 