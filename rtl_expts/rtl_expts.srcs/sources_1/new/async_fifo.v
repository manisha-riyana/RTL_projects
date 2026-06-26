`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hughes Systique Corporations
// Engineer: Manisha Riyana
// 
// Create Date: 25/06/2026 09:05:50 PM
// Module Name: async_fifo
// Description: Designing a basic asynchronous FIFO
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module async_fifo
#( parameter depth = 8,
   parameter data_width =8,
   parameter ADDR_WIDTH = 3)    // 8 locations )
(
    input wclk,
    input rclk,
    input wrst,
    input rrst,
    input we,
    input re,
    input [data_width-1:0] data_in,
    output reg [data_width-1:0] data_out,
    output full,
    output empty
    );
    
    reg [ADDR_WIDTH:0] wptr_bin,rptr_bin;
    wire [ADDR_WIDTH:0] wptr_gray,rptr_gray;
    reg [data_width-1:0] mem [0:depth-1];
    reg[ADDR_WIDTH:0] wptr_sync,wptr_sync1,rptr_sync,rptr_sync1;

    integer i;
    
    always @(posedge wclk or posedge wrst) begin
        if(wrst) begin
            rptr_sync <= 0;
            rptr_sync1 <= 0;
            wptr_bin <= 0;
            for(i=0;i<depth;i=i+1)
                mem[i] = 0;
        end
        else begin
            if(we && !full) begin
                mem[wptr_bin[$clog2(depth)-1:0]] <= data_in;
                wptr_bin <= wptr_bin+1;
            end
            else wptr_bin <= wptr_bin;
            rptr_sync <= rptr_gray;
            rptr_sync1 <= rptr_sync;
        end
    end
    
     always @(posedge rclk or posedge rrst) begin
        if(rrst) begin
            wptr_sync <= 0;
            wptr_sync1 <= 0;
            rptr_bin <= 0;
            data_out <= 0;
        end
        else begin
            if(re && !empty) begin
                data_out <= mem[rptr_bin[ADDR_WIDTH-1:0]];
                rptr_bin <= rptr_bin+1;
            end
            else rptr_bin <= rptr_bin;
            wptr_sync <= wptr_gray;
            wptr_sync1 <= wptr_sync;
        end
    end
    
    assign wptr_gray = (wptr_bin >> 1) ^ wptr_bin;
    assign rptr_gray = (rptr_bin >> 1) ^ rptr_bin;
     
    assign empty = wptr_sync1 == rptr_gray;
    
    wire [ADDR_WIDTH:0] wptr_gray_next;

assign wptr_gray_next = ((wptr_bin+1)>>1) ^ (wptr_bin+1);

assign full =
    (wptr_gray_next ==
    {~rptr_sync1[ADDR_WIDTH:ADDR_WIDTH-1],
      rptr_sync1[ADDR_WIDTH-2:0]});
   //assign full = wptr_bin == {~rptr_bin[ADDR_WIDTH-1],rptr_bin[ADDR_WIDTH-2:0]};
    
endmodule
