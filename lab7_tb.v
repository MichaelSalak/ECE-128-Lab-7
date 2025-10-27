`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2025 08:26:50 PM
// Design Name: 
// Module Name: lab7_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



//                                       Problem 1
//-------------------------------------------------------------------------------------------
module sequenceMoore_tb();  //1100

reg clk, rst, in;
wire z;

sequenceMoore seq(.clk(clk), .rst(rst), .in(in), .z(z));

initial begin
    clk = 0;
    rst = 0;
    in = 0;
    #3 rst = 1;
end
always #5 clk = ~clk;

initial begin
    #10 in = 1;
    #10 in = 1;
    #10 in = 0;
    #10 in = 0; //complete sequence
    #10 in = 0; //reset
    #10 in = 1; 
    #10 in = 1;
    #10 in = 1; //repeat
    #10 in = 0;
    #10 in = 1; //reset
    #10 in = 1;
    #10 in = 0;
    #10 in = 0; //complete sequence
    #10 in = 0; //reset
    #10 $finish;
end
endmodule



//                                       Problem 2
//-------------------------------------------------------------------------------------------
module sequenceMealy_tb();  //1101

reg clk,rst,in;
wire z;

sequenceMealy seq(.clk(clk), .rst(rst), .in(in), .z(z));

initial begin
    clk = 0;
    rst = 0;
    in = 0;
    #3 rst = 1;
end
always #5 clk = ~clk;

initial begin
    #10 in = 1;
    #10 in = 1;
    #10 in = 0;
    #10 in = 1; //complete sequence
    #10 in = 0; //reset
    #10 in = 1;
    #10 in = 1;
    #10 in = 1; //repeat
    #10 in = 0;
    #10 in = 0; //reset
    #10 in = 1;
    #10 in = 1;
    #10 in = 0;
    #10 in = 1; //complete sequence
    #10 in = 0; //reset
    #10 $finish;
end
endmodule



//                                       Problem 3
//-------------------------------------------------------------------------------------------
module upCounter_tb();

reg clk,rst;
wire [11:0]bin_count;

upCounter cnt(.clk(clk), .rst(rst), .bin_count(bin_count));

initial begin
    clk = 0;
    rst = 0;
    #3 rst = 1;
end
always #5 clk = ~clk;

always @(posedge clk) begin     //end sim shortly after counter reset
    if(&bin_count) begin
        #10000 $finish;     //delay to showcase wrap around
    end
end
endmodule



//                                       Problem 4
//-------------------------------------------------------------------------------------------
module BCDconv_tb();

reg clk,en,rst; reg [11:0]bin_in;
wire done; wire [15:0]bcd_out;
reg [1:0]test;  //test cases

BCDconv conv(.clk(clk), .en(en), .rst(rst), .bin_in(bin_in), 
             .done(done), .bcd_out(bcd_out));
             
initial begin
    clk = 0;
    en = 0;
    rst = 0;
    bin_in = 0;
    test = 0;
    #3 rst = 1;
end
always #5 clk = ~clk;

initial begin
    repeat(3) begin //repeat 3x to hit each test case
        if(test == 3)
            #50 $finish; 
        case(test)  //test cases
            0: bin_in = 12'd1234;
            1: bin_in = 12'd1999;
            2: bin_in = 12'd4000;
        endcase
        
        en = 1;
        @(posedge done);    //wait until conversion finishes
        en = 0;             //disable system during input loading
        #10 test = test + 1;
    end  
end
endmodule



//                                       Problem 5
//-------------------------------------------------------------------------------------------
module display_tb();

reg clk, rst; 
wire dp,a,b,c,d,e,f,g; wire [3:0]anode;
reg [3:0]test; //test cases

display dut(.clk(clk), .rst(rst), .dp(dp),.a(a),.b(b),.c(c),
                   .d(d),.e(e),.f(f),.g(g), .anode(anode));

initial begin
    clk = 0;
    rst = 0;
    #3 rst = 1;
    test = 0;
end
always #5 clk = ~clk;

always @(anode) begin   
    if(anode == 4'b0111)
        test <= test + 1;   //increment count when final anode is used
    if(&test)
        $finish;    //finish after all tests
end
endmodule