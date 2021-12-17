/*
CPOL=0，CPHA =0	SCK空闲为低电平，数据在SCK的上升沿被采样
CPOL=0，CPHA =1	SCK空闲为低电平，数据在SCK的下降沿被采样
CPOL=1，CPHA =0	SCK空闲为高电平，数据在SCK的下降沿被采样
CPOL=1，CPHA =1	SCK空闲为高电平，数据在SCK的上升沿被采样
* 长度：16 sclk cycles 
* MSB is shifted in and out first.
* clk must be at least 4x faster than sclk
*    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
*    | SPI Mode | CPOL | CPHA | Shift Sclk edge   | Capture Sclk edge | 
*    | 0        | 0    | 0    | Falling (negedge) | Rising (posedge)  | 
*    | 1        | 0    | 1    | Rising (posedge)  | Falling (negedge) | 
*    | 2        | 1    | 0    | Rising (posedge)  | Falling (negedge) | 
*    | 3        | 1    | 1    | Falling (negedge) | Rising (posedge)  | 
*    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
*/
module spi_master #(parameter 
    HALF_CLK_DIV=4,
	SPI_MODE=1
)(
    input clk,
    input rst_n,
    //TX (MOSI)
    input i_valid,
    input [15:0] i_data,
    output logic i_ready,
    //RX (MISO)
    output logic o_valid,
    output logic [15:0] o_data,
    //SPI control signals 
    output logic sclk,
    input miso,
    output logic mosi
);

localparam W=$clog2(HALF_CLK_DIV*2+1);
logic [W-1:0] spi_clk_count;
logic spi_clk_r;
logic cpol,cpha;
logic leading_edga;
logic trailing_edge;
logic [5:0] spi_clk_edges;
logic [15:0] i_data_1r;
logic [3:0] tx_bit_count,rx_bit_count;
logic iack,iack_1r;

assign iack=i_valid & i_ready;
assign cpol=(SPI_MODE==2 || SPI_MODE==3);
assign cpha=(SPI_MODE==1 || SPI_MODE==3);

always_ff@(posedge clk or negedge rst_n)
    if (~rst_n)begin 
        i_ready <= 1'b0;
        spi_clk_edges <= 'd0;
        leading_edga <= 1'b0;
        trailing_edge <= 1'b0;
        spi_clk_r <= cpol;
        spi_clk_count <= '0;
    end 
    else begin 
            leading_edga <= 1'b0;
            trailing_edge <= 1'b0;
            if (iack)begin 
                i_ready <= 1'b0;
                spi_clk_edges <= 'd32;
            end 
            else if (spi_clk_edges > 0)begin 
                    i_ready <= 1'b0;
                    if (spi_clk_count==HALF_CLK_DIV*2-1)begin 
                        spi_clk_edges <= spi_clk_edges - 1;
                        trailing_edge <= 1'b1;
                        spi_clk_count <= 0;
                        spi_clk_r <= ~spi_clk_r;
                    end 
                    else if (spi_clk_count==HALF_CLK_DIV-1)begin 
                        spi_clk_edges <= spi_clk_edges - 1;
                        leading_edga <= 1'b1;
                        spi_clk_count <= spi_clk_count + 1;
                        spi_clk_r <= ~spi_clk_r;
                    end 
                    else  begin 
                        spi_clk_count <= spi_clk_count + 1;
                    end 
                end 
            else  
            i_ready <= 1'b1;
        end 
    

always_ff@(posedge clk or negedge rst_n)
    if (~rst_n)begin 
        iack_1r <= 1'b0;
        i_data_1r <= '0;
    end else begin 
        iack_1r <= iack;
        if (iack)
            i_data_1r <= i_data;
    end 
//MOSI
always_ff@(posedge clk or negedge rst_n)
    if (~rst_n)begin 
        mosi <= 1'b0;
        tx_bit_count <= 4'b1111;
    end else begin 
        if (i_ready)
            tx_bit_count <= 4'b1111;
        else if (iack_1r && ~cpha) begin //CPHA=0,
            mosi <= i_data_1r[4'b1111];
            tx_bit_count <= 4'b1110;
        end else if ((leading_edga && cpha) || (trailing_edge && ~cpha))begin
            mosi <= i_data_1r[tx_bit_count];
            tx_bit_count <= tx_bit_count - 1;
        end 
    end 
//MISO
always_ff@(posedge clk or negedge rst_n)
    if (~rst_n)begin 
        o_data <= 16'h0000;
        o_valid <= 1'b0;
        rx_bit_count <= 4'b1111;
    end else begin 
        o_valid <= 1'b0;
        if (i_ready)
            rx_bit_count <= 4'b1111;
        else if ((leading_edga && ~cpha) || (trailing_edge && cpha))begin 
            o_data[rx_bit_count] <= miso;
            rx_bit_count <= rx_bit_count - 1;
            if (rx_bit_count==0)
                o_valid <= 1'b1;
        end 
    end 
 //sclk
 always_ff@(posedge clk or negedge rst_n)
    if (~rst_n)
        sclk <= cpol;
    else sclk <= spi_clk_r;


endmodule 


