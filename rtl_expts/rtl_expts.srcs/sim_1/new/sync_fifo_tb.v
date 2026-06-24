`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hughes Systique Corporations
// Engineer: Manisha Riyana
// 
// Create Date: 24/06/2026 09:05:50 PM
// Module Name: sync_fifo
// Description: Testbench for synchronous FIFO
s
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Writing 4 values into fifo and reading it back
//////////////////////////////////////////////////////////////////////////////////

module sync_fifo_tb();
    reg clk,rst;
    reg re,we;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire full, empty;
    
   sync_fifo dut(
    .clk(clk),
    .rst(rst),
    .we(we),
    .re(re),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst = 1;
        we = 0;
        re = 0;
        data_in = 0;
        
        #20;
        rst = 0;

        // Write 4 values
        @(posedge clk);
        we = 1; data_in = 8'h11;

        @(posedge clk);
        data_in = 8'h22;

        @(posedge clk);
        data_in = 8'h33;

        @(posedge clk);
        data_in = 8'h44;

        @(posedge clk);
        we = 0;

        // Read 4 values
        @(posedge clk);
        re = 1;

        repeat(4)
            @(posedge clk);

        re = 0;

        #20;
        $finish;
    end
endmodule