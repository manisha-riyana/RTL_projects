`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hughes Systique Corporations
// Engineer: Manisha Riyana
// 
// Create Date: 24/06/2026 09:05:50 PM
// Module Name: sync_fifo
// Description: Designing a basic synchronous FIFO
s
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sync_fifo
#( parameter depth = 8,
   parameter data_width =8 )
(
    input clk,
    input rst,
    input we,
    input re,
    input [data_width-1:0] data_in,
    output [data_width-1:0] data_out,
    output full,
    output empty
    );
    
    reg [data_width-1:0] data_out;
    reg[$clog2(depth):0] wptr;
    reg[$clog2(depth)-1:0] rptr;
    reg [data_width-1:0] mem [0:depth-1];
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rptr <= 0;
            wptr <= 0;
            for(i=0;i<depth;i=i+1)
                mem[i] = 0;
            data_out <= 0;
        end
        else begin
            if(we && !full) begin
                mem[wptr[$clog2(depth)-1:0]] <= data_in;
                wptr <= wptr+1;
            end
            if(re && !empty) begin
                data_out <= mem[rptr];
                rptr <= rptr+1;
            end
        end
    end
    
    assign empty = wptr == rptr;
    assign full = (wptr[$clog2(depth)-1:0] == rptr) && wptr[$clog2(depth)];
    
endmodule
