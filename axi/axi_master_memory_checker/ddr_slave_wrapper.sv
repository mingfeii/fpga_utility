

module ddr_slave_wrapper #(
    parameter DATA_WIDTH   = 128,
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 8
)(
    input                                 aclk,
    input                                 aresetn,

//DDR controler interface
    input  logic  						  wr_busy,
    output logic  [DATA_WIDTH-1:0]	      wr_data,
    output logic  [DATA_WIDTH / 8 - 1:0]  wr_datamask,
    output logic  [31:0]				  wr_addr,
    output logic  						  wr_en,
    output logic 						  wr_addr_en,
    input  logic 						  wr_ack,
    input  logic 						  rd_busy,
    output logic   [31:0] 				  rd_addr,
    output logic   						  rd_addr_en,
    output logic  						  rd_en,
    input  logic  [DATA_WIDTH-1:0]	      rd_data,
    input  logic  						  rd_valid,
    input  logic  					      rd_ack ,
//AXI SLAVE interface 
    input  logic [ID_WIDTH - 1 : 0]       awid,
    input  logic [ADDR_WIDTH - 1 : 0]     awaddr,
    input  logic [7 : 0]                  awlen,
    input  logic [2 : 0]                  awsize,
    input  logic [1 : 0]                  awburst,
    input  logic                          awlock,
    input  logic [3 : 0]                  awcache,
    input  logic [2 : 0]                  awprot,
    input  logic [3 : 0]                  awqos,
    input  logic [3 : 0]                  awregion,
    input  logic                          awvalid,
    output logic                          awready,

    input  logic [DATA_WIDTH - 1 : 0]     wdata,
    input  logic [DATA_WIDTH / 8 - 1 : 0] wstrb,
    input  logic                          wlast,
    input  logic                          wvalid,
    output logic                          wready,

    output logic [ID_WIDTH - 1 : 0]       bid,
    output logic [1 : 0]                  bresp,
    output logic                          bvalid,
    input  logic                          bready,

    input  logic [ID_WIDTH - 1 : 0]       arid,
    input  logic [ADDR_WIDTH - 1 : 0]     araddr,
    input  logic [7 : 0]                  arlen,
    input  logic [2 : 0]                  arsize,
    input  logic [1 : 0]                  arburst,
    input  logic                          arlock,
    input  logic [3 : 0]                  arcache,
    input  logic [2 : 0]                  arprot,
    input  logic [3 : 0]                  arqos,
    input  logic [3 : 0]                  arregion,
    input  logic                          arvalid,
    output logic                          arready,

    output logic [ID_WIDTH - 1 : 0]       rid,
    output logic [DATA_WIDTH - 1 : 0]     rdata,
    output logic [1 : 0]                  rresp,
    output logic                          rlast,
    output logic                          rvalid,
    input  logic                          rready

);


function reg[7:0] decode_size;
    input [2:0] axsize;

    case (axsize)
        3'b000: decode_size = 8'b00000001;
        3'b001: decode_size = 8'b00000010;
        3'b010: decode_size = 8'b00000100;
        3'b011: decode_size = 8'b00001000;
        3'b100: decode_size = 8'b00010000;
        3'b101: decode_size = 8'b00100000;
        3'b110: decode_size = 8'b01000000;
        3'b111: decode_size = 8'b10000000;
        default:decode_size = 8'b00000001;
    endcase

endfunction


localparam  AXI4_RESP_OKAY    = 2'b00;
localparam STRB_WIDTH = (DATA_WIDTH/8);
localparam VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);

logic                         wr_en_nxt;
logic                         wr_addr_en_nxt;
reg         [7:0]		      decode_wsize;
reg         [7:0]		      decode_rsize; 
reg         [ID_WIDTH-1:0]    write_id_reg,write_id_nxt;

logic                         rd_addr_en_nxt;
logic [ID_WIDTH-1:0]          rid_nxt; 
logic                         rlast_nxt; 
logic [DATA_WIDTH-1:0]        rdata_nxt;     
logic                         rvalid_nxt;

logic  [ID_WIDTH-1:0]         bid_nxt;
logic                         bvalid_nxt;
logic                         awready_nxt;
logic                         wready_nxt;
reg [2:0]                     awsize_reg,awsize_reg_nxt;

logic [ADDR_WIDTH-1:0] write_addr,write_addr_nxt;
logic [7:0]            write_count,write_count_nxt; 

enum int unsigned {WR_IDLE,WR_BURST,WRITE_RESP} write_state,write_state_nxt;

assign wr_addr = write_addr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
assign bresp = AXI4_RESP_OKAY;
assign decode_wsize = decode_size(awsize_reg);

always_ff@(posedge aclk or negedge aresetn)
    if (~aresetn) begin
        write_state <= WR_IDLE;
        write_addr  <= 0;
        write_count <= 0;
        wr_en <= 1'b0;
        wr_addr_en <= 1'b0;
        wr_data <= '0;
        wr_datamask <= '0;
        awready <= 1'b0;
        wready <= 1'b0;
        bid <= 0;
        bvalid <=1'b0;
        write_id_reg <= 0;
        awsize_reg <= 0;
    end else begin
        awsize_reg <= awsize_reg_nxt;
        write_state <= write_state_nxt;
        write_addr  <= write_addr_nxt;
        write_count <= write_count_nxt;
        wr_en <= wr_en_nxt;
        wr_addr_en <= wr_addr_en_nxt;
        wr_data <= wdata;
        wr_datamask <= ~wstrb;
        awready <= awready_nxt;
        wready <= wready_nxt;
        bid <= bid_nxt;
        bvalid <= bvalid_nxt;
        write_id_reg <= write_id_nxt;
    end

always_comb begin 
    wr_en_nxt = 1'b0;
    wr_addr_en_nxt = 1'b0;
    awready_nxt = 1'b0;
    wready_nxt = 1'b0;
    write_id_nxt= write_id_reg;
    bid_nxt = bid;
    bvalid_nxt = 1'b0;
    awsize_reg_nxt = awsize_reg;
    write_state_nxt = write_state;
    write_count_nxt = write_count;
    write_addr_nxt  = write_addr;
    case(write_state)
    WR_IDLE: begin 
        awready_nxt = ~wr_busy;
        if (awvalid && awready) begin
            write_addr_nxt = awaddr;
            awsize_reg_nxt = awsize;
            write_id_nxt = awid;
            write_count_nxt = awlen;
            awready_nxt = 1'b0;
            write_state_nxt = WR_BURST;
        end else  
            write_state_nxt = WR_IDLE;
        end
    WR_BURST:begin 
        wready_nxt = ~wr_busy;
        if (wvalid && wready) begin 
            wr_addr_en_nxt = 1'b1;
            wr_en_nxt = 1'b1;
            if (wr_en) begin 
                write_addr_nxt = write_addr  + decode_wsize; 
            end 
            write_count_nxt = write_count-1;

            if (write_count > 0) begin 
                write_state_nxt = WR_BURST;
            end else  begin 
                wready_nxt = 1'b0;
                bid_nxt = write_id_reg;
                write_state_nxt = WRITE_RESP;
                end 
        end else begin 
                write_state_nxt = WR_BURST;
            end 
        end 
    WRITE_RESP: begin 
        bvalid_nxt = 1'b1;
        if (bready && bvalid) begin 
            bvalid_nxt = 1'b0;
            write_state_nxt = WR_IDLE;
        end else begin 
            write_state_nxt = WRITE_RESP;
        end 
    end 

    default:write_state_nxt=WR_IDLE;
    endcase 
end 


logic   [ADDR_WIDTH-1:0] read_adrs,read_addr_nxt;
logic   [7:0]            read_count,read_count_nxt;
logic   [7:0]            read_data_count,read_data_count_nxt;
logic                    addr_rd_lock,addr_rd_lock_nxt;
logic                    arready_nxt;
reg [2:0]                arsize_reg,arsize_reg_nxt;

enum int unsigned {RD_IDLE,RD_SINGLE,RD_BURST} read_state,read_state_nxt;

assign rd_addr = read_adrs >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
assign decode_rsize = decode_size(arsize_reg);
assign rd_en = 1'b1;

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn) begin
        read_state <= RD_IDLE;
        read_adrs  <= 0;
        read_count <= 0;         
        read_data_count <= 0;
        rd_addr_en <= 1'b0;
        rid <= 0;
        rlast <= 1'b0;
        rdata <= 0;
        rvalid <= 1'b0;
        arready <= 1'b0;
        arsize_reg <= 0;
    end else begin    
        read_state <= read_state_nxt;
        read_adrs  <= read_addr_nxt;
        read_count <= read_count_nxt;
        read_data_count <= read_data_count_nxt;
        rd_addr_en <= rd_addr_en_nxt;
        rid <= rid_nxt;
        rlast <= rlast_nxt;
        rdata <= rd_data;
        rvalid <= rvalid_nxt;
        arready <= arready_nxt;
        arsize_reg <= arsize_reg_nxt;
    end

always_ff@(posedge aclk or negedge aresetn)
    if (!aresetn)
        addr_rd_lock <= 1'b0;
    else if (read_state==RD_IDLE)   
        addr_rd_lock <= 1'b0;
    else if (addr_rd_lock_nxt==1'b1)
        addr_rd_lock <= 1'b1;

always_comb begin 
    rd_addr_en_nxt = 1'b0;
    rid_nxt = rid;
    arready_nxt = 1'b0;
    rlast_nxt = '0;
    rresp = 0;
    rvalid_nxt = 1'b0;
    addr_rd_lock_nxt = 1'b0;
    arsize_reg_nxt = arsize_reg;
    read_data_count_nxt = read_data_count;
    read_state_nxt = read_state;
    read_count_nxt = read_count;
    read_addr_nxt  = read_adrs;
    case (read_state)
        RD_IDLE:begin 
            arready_nxt = ~rd_busy;
            if (arvalid && arready) begin 
                read_addr_nxt = araddr;
                arsize_reg_nxt = arsize;
                rid_nxt = arid;
                arready_nxt = 1'b0;
                if (arlen==0)
                    read_state_nxt = RD_SINGLE;
                else begin
                    read_count_nxt = arlen;
                    read_data_count_nxt = arlen;
                    read_state_nxt = RD_BURST;    
                end 
            end else begin 
                read_state_nxt = RD_IDLE;
            end 
        end

        RD_SINGLE:begin 
            if (rready && !rd_busy && !addr_rd_lock) begin 
                rd_addr_en_nxt = 1'b1;
                addr_rd_lock_nxt = 1'b1;
            end 
            if (rd_valid)begin 
                rvalid_nxt = 1'b1;
                rlast_nxt  = 1'b1;
                read_state_nxt = RD_IDLE; 
            end else  begin 
                read_state_nxt = RD_SINGLE;
            end 
        end
        RD_BURST:begin
            if (!rd_busy && rready && !addr_rd_lock) begin 
                rd_addr_en_nxt = 1'b1;
                read_count_nxt = read_count-1;
                if (read_count==0) begin
                    addr_rd_lock_nxt = 1'b1;
                end
            end
            if (rd_addr_en) read_addr_nxt = read_adrs + decode_rsize;
            if (rd_valid) begin 
                rvalid_nxt = 1'b1;
                read_data_count_nxt = read_data_count - 1;
                if (read_data_count==0) begin 
                    rlast_nxt = 1'b1;
                    read_state_nxt =RD_IDLE;
                 end 
                end  
            end
    
        default:begin 
            read_state_nxt = RD_IDLE;
        end 


    endcase
end

endmodule

