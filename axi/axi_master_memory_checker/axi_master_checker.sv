
module axi_master_checker #(
    parameter DATA_WIDTH   = 128, //fixed 
    parameter ADDR_WIDTH   = 32,
    parameter ID_WIDTH     = 8,
    parameter WLEN         = 8,
    parameter RLEN         = 8,
    parameter ID           = 0,
    parameter START_ADDR = 32'h00000000,
    parameter STOP_ADDR = 32'h00001000
)(
    input                                 clk,
    input                                 rst_n,

    input                                  axi_wr_en,
    input                                  axi_rd_en,

    output logic                           wr_finish,
    output logic                           rd_finish,
    output logic                            fail,
    output logic                            done,

    output  logic [ID_WIDTH - 1 : 0]       awid,
    output  logic [ADDR_WIDTH - 1 : 0]     awaddr,
    output  logic [7 : 0]                  awlen,
    output  logic [2 : 0]                  awsize,
    output  logic [1 : 0]                  awburst,
    output  logic                          awlock,
    output  logic [3 : 0]                  awcache,
    output  logic [2 : 0]                  awprot,
    output  logic [3 : 0]                  awqos,
    output  logic [3 : 0]                  awregion,
    output  logic                          awvalid,
    input   logic                          awready,

    output  logic [DATA_WIDTH - 1 : 0]     wdata,
    output  logic [DATA_WIDTH / 8 - 1 : 0] wstrb,
    output  logic                          wlast,
    output  logic                          wvalid,
    input  logic                           wready,

   input  logic [ID_WIDTH - 1 : 0]       bid,
   input  logic [1 : 0]                  bresp,
   input  logic                          bvalid,
    output  logic                          bready,

    output   logic [ID_WIDTH - 1 : 0]       arid,
    output   logic [ADDR_WIDTH - 1 : 0]     araddr,
    output   logic [7 : 0]                  arlen,
    output   logic [2 : 0]                  arsize,
    output   logic [1 : 0]                  arburst,
    output   logic                          arlock,
    output   logic [3 : 0]                  arcache,
    output   logic [2 : 0]                  arprot,
    output   logic [3 : 0]                  arqos,
    output   logic [3 : 0]                  arregion,
    output   logic                          arvalid,
    input  logic                          arready,

    input  logic [ID_WIDTH - 1 : 0]       rid,
    input  logic [DATA_WIDTH - 1 : 0]     rdata,
    input  logic [1 : 0]                  rresp,
    input  logic                          rlast,
    input  logic                          rvalid,
    output  logic                          rready

);



enum int unsigned {WR_IDLE,WR_SIGNLE,WR_BURST,WR_RESP,ID_ERR,RD_IDLE,RD_SINGLE,RD_BURST} state,state_nxt;



logic  [7:0] write_data_count,write_data_count_nxt;
logic [ADDR_WIDTH-1:0] awaddr_nxt;
logic awvalid_nxt,awvalid_pre;

logic awaddr_lock,awaddr_lock_nxt;
logic bready_nxt,bready_pre;
logic wvalid_nxt,wvalid_pre;

reg [7:0] read_data_count,read_data_count_nxt;
logic araddr_lock,araddr_lock_nxt;
logic [ADDR_WIDTH-1:0] araddr_nxt;
logic rready_nxt,rready_pre;
logic arvalid_nxt,arvalid_pre;
logic [DATA_WIDTH-1:0] read_data_store;
logic fail_nxt;
logic done_nxt;
logic wlast_nxt;

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n) begin 
        awlen <= WLEN;
        awsize <= 3'b100; 
        awburst <= 2'b01;
        awid <= ID;
        awaddr <= START_ADDR;
        bready_pre <= 1'b0;
        state <= WR_IDLE;
        write_data_count <= 0;
        wvalid_pre <= 1'b0;
        awvalid_pre <= 1'b0;
        wdata <= 0;
        awaddr_lock <= 1'b0;
        wstrb <= 16'hFFFF;
        wlast <= 1'b0;
    end else begin 
        awaddr <= awaddr_nxt;
        state <= state_nxt;
        write_data_count <= write_data_count_nxt;
        wvalid_pre <= wvalid_nxt;
        wlast <= wlast_nxt;
        awvalid_pre <= awvalid_nxt;
        bready_pre <= bready_nxt;
        wdata <= {4{awaddr_nxt}};
        awaddr_lock <= awaddr_lock_nxt;
    end 

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n) begin
        arlen <= RLEN;
        arsize <= 3'b100;
        arburst <= 2'b01;
        arid <= ID;
        araddr <= START_ADDR;
        rready_pre <= 1'b0;
        arvalid_pre <= 1'b0;
        fail <= 1'b0;
        done <= 1'b0;
        araddr_lock <= 1'b0;
        read_data_count <= 0;
    end else begin 
        araddr <= araddr_nxt;
        rready_pre <= rready_nxt;
        arvalid_pre <= arvalid_nxt;
        fail <= fail_nxt;
        done <= done_nxt;
        araddr_lock <= araddr_lock_nxt;
        read_data_count <= read_data_count_nxt;
    end 

assign rready = rready_pre & (state==RD_BURST || state==RD_SINGLE);
assign wvalid = wvalid_pre & (state==WR_BURST || state==WR_SIGNLE);
assign awvalid = awvalid_pre & ~awaddr_lock;
assign arvalid = arvalid_pre & ~araddr_lock;
assign bready = bready_pre & (state==WR_RESP);


always_comb begin 
    //write channel 
    state_nxt = state;
    awaddr_nxt = awaddr;
    awaddr_lock_nxt = awaddr_lock;
    write_data_count_nxt = write_data_count;
    bready_nxt = 1'b0;
    wvalid_nxt = 1'b0;
    wlast_nxt = wlast;
    awvalid_nxt = 1'b0;
    //read channel 
    araddr_nxt = araddr;
    rready_nxt = 1'b0;
    arvalid_nxt = 1'b0;
    fail_nxt = fail;
    read_data_store  = {4{araddr}};
    araddr_lock_nxt = araddr_lock;
    done_nxt = 1'b0;
    read_data_count_nxt = read_data_count;
    case(state)
        WR_IDLE:begin 
            wlast_nxt = 1'b0;
            awaddr_nxt = awaddr;
            awaddr_lock_nxt = 1'b0;
            if (awaddr > STOP_ADDR) begin 
                awaddr_nxt = START_ADDR;
                if (axi_rd_en) state_nxt = RD_IDLE;
            end else begin 
                if (axi_wr_en) begin 
                    if (awlen==0) begin 
                        state_nxt = WR_SIGNLE;
                    end else begin 
                        state_nxt = WR_BURST; 
                        write_data_count_nxt = awlen;
                    end 
                end 
            end 
        end 
        WR_SIGNLE: begin 
            if (!awaddr_lock) begin 
                awvalid_nxt = 1'b1;
            end 

            if (awvalid && awready) begin 
                awaddr_lock_nxt = 1'b1;
            end 

            if (wvalid && wready) begin 
                wvalid_nxt = 1'b0;
                wlast_nxt = 1'b0;
                awaddr_nxt = awaddr + (DATA_WIDTH/8);
                state_nxt = WR_RESP;
            end else begin 
                wvalid_nxt = 1'b1;
                wlast_nxt = 1'b1;
                end 
        end 
        WR_BURST:begin 
            wvalid_nxt = 1'b1;
            if (!awaddr_lock) begin 
                awvalid_nxt = 1'b1;
            end 

            if (awvalid && awready) begin 
                awaddr_lock_nxt = 1'b1;
            end 

            if (wvalid && wready) begin 
                awaddr_nxt = awaddr + (DATA_WIDTH/8);
                write_data_count_nxt = write_data_count - 1'b1;
                if (write_data_count==1) wlast_nxt = 1'b1;
                if (write_data_count==0) begin 
                    wlast_nxt = 1'b0;
                    state_nxt = WR_RESP;
                end
            end 
        end 
        WR_RESP:begin 
            bready_nxt = 1'b1;
            if (bready && bvalid) begin 
               if (bid==ID)
                    state_nxt = WR_IDLE;
                else 
                    state_nxt = ID_ERR;
            end 

        end 
        ID_ERR:begin 
            if (axi_wr_en==0) //clear
                state_nxt = WR_IDLE;
        end 
        //RD 
        RD_IDLE: begin 
            araddr_nxt = araddr;
            araddr_lock_nxt = 1'b0;
            if (araddr > STOP_ADDR) begin 
                araddr_nxt = START_ADDR;
                done_nxt = 1'b1;
                if (axi_wr_en) state_nxt = WR_IDLE;
            end else begin 
                if (axi_rd_en) begin 
                    if (arlen==0) begin 
                        state_nxt = RD_SINGLE;
                    end else begin 
                        state_nxt = RD_BURST;
                        read_data_count_nxt = arlen;
                    end
                        
                end 
            end 
        end

        RD_SINGLE: begin 
        if (!araddr_lock) begin 
            arvalid_nxt = 1'b1;
        end 

        if (arready && arvalid) begin 
            araddr_lock_nxt = 1'b1;
        end 

        if (rvalid && rready) begin 
            rready_nxt = 1'b0;
            araddr_nxt = araddr + (DATA_WIDTH/8);
            state_nxt = RD_IDLE;
            if (rdata != read_data_store) fail_nxt = 1'b1;
        end else begin 
            rready_nxt = 1'b1;
            state_nxt = RD_SINGLE;
        end 

        end 

        RD_BURST: begin 
            rready_nxt = 1'b1;
            if (!araddr_lock) begin 
                arvalid_nxt = 1'b1;
            end 
            if (arready && arvalid) begin 
                araddr_lock_nxt = 1'b1;
             end 
            if (rvalid && rready) begin 
                araddr_nxt = araddr + (DATA_WIDTH/8);
                read_data_count_nxt = read_data_count - 1'b1;
                if (read_data_count==0) begin 
                    state_nxt = RD_IDLE;
                end 
                if (rid != ID) state_nxt = ID_ERR;
                if (rdata != read_data_store) fail_nxt = 1'b1;

            end 
        end 
    endcase 

end 

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        wr_finish <= 1'b0;
    else if (state==WR_IDLE && state_nxt==RD_IDLE)
        wr_finish <= 1'b1;
    else 
        wr_finish <= 1'b0;

always_ff@(posedge clk or negedge rst_n)
    if (!rst_n)
        rd_finish <= 1'b0;
    else if (state==RD_IDLE && state_nxt==WR_IDLE)
        rd_finish <= 1'b1;
    else 
        rd_finish <= 1'b0;



endmodule