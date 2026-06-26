`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hughes Systique Corporations
// Engineer: Manisha Riyana
// 
// Create Date: 25/06/2026 09:05:50 PM
// Module Name: sync_fifo
// Description: Testbench for asynchronous FIFO
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Writing 4 values into fifo and reading it back
//////////////////////////////////////////////////////////////////////////////////

module async_fifo_tb();
    reg rclk,wclk,rrst,wrst;
    reg re,we;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire full, empty;
    
   async_fifo dut(
    .wclk(wclk),
    .rclk(rclk),
    .wrst(wrst),
    .rrst(rrst),
    .we(we),
    .re(re),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);
    
    initial begin
        wclk = 0;
        forever #10 wclk = ~wclk;
    end
    
    initial begin
        rclk = 0;
        forever #5 rclk = ~rclk;
    end
integer i;
    initial begin
    

    rrst = 1;
    wrst = 1;
    we = 0;
    re = 0;
    data_in = 0;

    #20;
    wrst = 0;
    rrst = 0;

    // Check empty after reset
    if(empty)
        $display("PASS: FIFO is empty after reset");
    else
        $display("FAIL: FIFO should be empty after reset");
        
    //-------------------------------------------------
    // Single entry test 
    //-------------------------------------------------
            $display("\n----- Single Entry Test -----");
        
        @(posedge wclk);
        we = 1;
        data_in = 8'h55;
        
        @(posedge wclk);
        we = 0;
        
        if(!empty)
            $display("PASS: FIFO not empty after one write");
        
        @(posedge rclk);
        re = 1;
        
        @(posedge rclk);
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
        @(posedge wclk);
        data_in = i + 8'h10;
        
    end

    @(posedge wclk);
    we = 0;

    if(full)
        $display("PASS: FIFO full asserted");
    else
        $display("FAIL: FIFO full not asserted");

    //-------------------------------------------------
    // Attempt overflow
    //-------------------------------------------------
    @(posedge wclk);
    we = 1;
    data_in = 8'hFF;

    @(posedge wclk);
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
    @(posedge rclk);
    #1;

    if(data_out == (8'h10 + i))
        $display("PASS: Data matched %h", data_out);
    else
        $display("FAIL: Expected %h Got %h",
                 (8'h10+i), data_out);
end

    re = 0;
    // Allow flag update
@(posedge rclk);

    if(empty)
        $display("PASS: FIFO empty asserted");
    else
        $display("FAIL: FIFO empty not asserted");

    //-------------------------------------------------
    // Attempt underflow
    //-------------------------------------------------
    @(posedge rclk);
    re = 1;

    @(posedge rclk);
    re = 0;
if(empty)
    $display("PASS: Underflow prevented");
else
    $display("FAIL: Underflow protection failed");
    #20;
    
    //-------------------------------------------------
// Simultaneous Read/Write Test
//-------------------------------------------------
$display("\n----- Simultaneous Read/Write Test -----");



// Write process
begin
    for(i=0; i<16; i=i+1) begin
        @(posedge wclk);
        if(!full) begin
        we = 1;
        data_in = i;
        $display("WRITE %h", data_in);
        end
        else
            we = 0;
    end
    we = 0;
end

// Read process
begin
    repeat(2) @(posedge rclk);   // Optional delay so FIFO has some data

    for(i=0; i<16; i=i+1) begin
        @(posedge rclk);
        if(!empty) begin
            re = 1;
            #1;
            $display("[%0t] READ  %h", $time, data_out);
        end
        else
            re = 0;
    end
    re = 0;
    
    @(posedge rclk);

end


    $finish;
end
endmodule