`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hughes Systique Corporations
// Engineer: Manisha Riyana
// 
// Create Date: 24/06/2026 09:05:50 PM
// Module Name: sync_fifo
// Description: Testbench for synchronous FIFO
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
integer i;
    initial begin
    

    rst = 1;
    we = 0;
    re = 0;
    data_in = 0;

    #20;
    rst = 0;

    // Check empty after reset
    if(empty)
        $display("PASS: FIFO is empty after reset");
    else
        $display("FAIL: FIFO should be empty after reset");
        
    //-------------------------------------------------
    // Single entry test 
    //-------------------------------------------------
            $display("\n----- Single Entry Test -----");
        
        @(posedge clk);
        we = 1;
        data_in = 8'h55;
        
        @(posedge clk);
        we = 0;
        
        if(!empty)
            $display("PASS: FIFO not empty after one write");
        
        @(posedge clk);
        re = 1;
        
        @(posedge clk);
        re = 0;
        
        #1;
        
        if(empty)
            $display("PASS: FIFO empty after one read");
            
    //-------------------------------------------------
    // Fill FIFO completely
    //-------------------------------------------------
    we = 1;
    re = 0;

    for(i=0; i<8; i=i+1) begin
        @(posedge clk);
        data_in = i + 8'h10;
    end

    @(posedge clk);
    we = 0;

    if(full)
        $display("PASS: FIFO full asserted");
    else
        $display("FAIL: FIFO full not asserted");

    //-------------------------------------------------
    // Attempt overflow
    //-------------------------------------------------
    @(posedge clk);
    we = 1;
    data_in = 8'hFF;

    @(posedge clk);
    we = 0;
if(full)
    $display("PASS: Overflow prevented");
else
    $display("FAIL: Overflow protection failed");
    //-------------------------------------------------
    // Empty FIFO completely
    //-------------------------------------------------
    re = 1;

for(i=0; i<8; i=i+1) begin
    @(posedge clk);
   // #1;

    if(data_out == (8'h10 + i))
        $display("PASS: Data matched %h", data_out);
    else
        $display("FAIL: Expected %h Got %h",
                 (8'h10+i), data_out);
end

    re = 0;
    // Allow flag update
@(posedge clk);

    if(empty)
        $display("PASS: FIFO empty asserted");
    else
        $display("FAIL: FIFO empty not asserted");

    //-------------------------------------------------
    // Attempt underflow
    //-------------------------------------------------
    @(posedge clk);
    re = 1;

    @(posedge clk);
    re = 0;
if(empty)
    $display("PASS: Underflow prevented");
else
    $display("FAIL: Underflow protection failed");
    #20;
    $finish;
end
endmodule