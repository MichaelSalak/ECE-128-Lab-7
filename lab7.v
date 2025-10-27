`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2025 09:07:40 PM
// Design Name: 
// Module Name: sequenceMoore
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
module sequenceMoore(input clk, rst, in, output reg z); //1100

parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;   //extra state for output
reg [2:0] PS,NS;

always @(posedge clk or negedge rst) begin
    if(!rst)
        PS <= S0;
    else
        PS <= NS;
end

always @(*) begin   //outputs depend only on current state
    z = 0;
    case(PS)
        S0: NS = in ? S1 : S0;  //0xxx: NS = S1 if in = 1, S0 else
        S1: NS = in ? S2 : S0;  //1xxx: NS = S2 if in = 1, S0 else
        S2: NS = in ? S2 : S3;  //11xx: NS = S2 if in = 1, S3 else
        S3: NS = in ? S1 : S4;  //110x: NS = S1 if in = 1, S4 else
        S4: begin  
            NS = in ? S1 : S0;  //1100: NS = S1 if in = 1, S0 else
            z = 1;
        end   
    endcase
end
endmodule



//                                       Problem 2
//-------------------------------------------------------------------------------------------
module sequenceMealy(input clk, rst, in, output reg z); //1101

parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3;
reg [1:0] PS,NS;

always @(posedge clk or negedge rst) begin
    if(!rst)
        PS <= S0;
    else
        PS <= NS;
end

always @(*) begin   //outputs depend on current state and inputs
    z = 0;
    case(PS)
        S0: NS = in ? S1 : S0;  //0xxx: NS = S1 if in = 1, S0 else
        S1: NS = in ? S2 : S0;  //1xxx: NS = S2 if in = 1, S0 else
        S2: NS = in ? S2 : S3;  //11xx: NS = S2 if in = 1, S3 else
        S3: begin   
            NS = in ? S1 : S0;  //110x: NS = S1 if in = 1, S0 else
            z = in; //z = 1 only if input = 1
        end
    endcase
end
endmodule



//                                       Problem 3
//-------------------------------------------------------------------------------------------
module upCounter(input clk, rst, output reg [11:0]bin_count);

wire done;

clk_div delay(.clk(clk), .rst(rst), .done(done));   

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        bin_count <= 0;
    end else begin
        if(done)    //increment count after delay
            bin_count <= bin_count + 1;
    end
end
endmodule


//clock divider for counter delay
module clk_div(input clk, rst, output reg done);
    
    reg [20:0]count;    //slow
    //reg [16:0]count;    //fast
    //reg [4:0]count;     //very fast (for simulation)
    
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            count <= 0;
            done <= 0;
        end else begin
            if(&count) begin   //&count: 'AND' all bits together (check for max count)
                count <= 0;
                done <= 1;
            end else begin
                count <= count + 1;
                done <= 0;
            end
        end
    end
endmodule



//                                       Problem 4
//-------------------------------------------------------------------------------------------
module BCDconv(input clk, en, rst, input [11:0]bin_in, 
               output reg [15:0]bcd_out, output reg done);

parameter IDLE = 2'b00;
parameter ADD = 2'b01;
parameter SHIFT = 2'b10;
parameter DONE = 2'b11;

reg [27:0]shift_reg;   //16 + 12 = 28
reg [3:0]shift_idx;    //index state for all 12 bits
reg [1:0]state;        

always @(posedge clk or negedge rst) begin
    if(!rst) begin  //wipe all registers on reset
        done <= 0;
        bcd_out <= 0;
        shift_reg <= 0;
        shift_idx <= 0;
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                done <= 0;
                if(en) begin
                    shift_idx <= 0;
                    shift_reg <= {16'b0, bin_in};   //load shifting register 
                    state <= SHIFT;
                end
            end
            ADD: begin
                if(en) begin
                    if(shift_reg[27:24] > 4)
                        shift_reg[27:24] <= shift_reg[27:24] + 3;
                    if(shift_reg[23:20] > 4)
                        shift_reg[23:20] <= shift_reg[23:20] + 3;
                    if(shift_reg[19:16] > 4)
                        shift_reg[19:16] <= shift_reg[19:16] + 3;
                    if(shift_reg[15:12] > 4)
                        shift_reg[15:12] <= shift_reg[15:12] + 3;
                    state <= SHIFT;
                end
            end
            SHIFT: begin  
                if(en) begin    //pause when disabled
                    shift_reg <= shift_reg << 1;  //shift (after add) and 
                                                  // update values next clock edge
                    shift_idx <= shift_idx + 1;   //increment shift index counter
                    
                    if(shift_idx == 11)
                        state <= DONE;
                    else
                        state <= ADD;
                end
            end
            DONE: begin
                bcd_out <= shift_reg[27:12];    //extract BCD value
                done <= 1;
                state <= IDLE;   //return to idle next clock edge for next value
            end
        endcase
    end
end
endmodule



//                                       Problem 5
//-------------------------------------------------------------------------------------------
module display(input clk, rst, output dp,a,b,c,d,e,f,g, output [3:0]anode);

reg [15:0]bcd_val;  //value to display
reg en;

wire [11:0]bin_in;
wire [15:0]bcd_out;
wire done;

upCounter counter(.clk(clk), .rst(rst), .bin_count(bin_in));
BCDconv conv(.clk(clk), .en(en), .rst(rst), .bin_in(bin_in), .bcd_out(bcd_out),
             .done(done));
multi_display seg_display(.clk(clk), .bcd_in(bcd_val), .anode(anode), .dp(dp),
                          .a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g));

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        bcd_val <= 0;
        en <= 1;
    end else begin
        if(done) begin
            en <= 0;
            bcd_val <= bcd_out; //update value when done signal is recieved
        end else
            en <= 1;
    end
end
endmodule


//top display module
module multi_display(input clk, input [15:0]bcd_in, 
                     output [3:0]anode, output dp,a,b,c,d,e,f,g);
                     
wire [3:0] val;

anodeGen digit(.clk(clk), .bcd_in(bcd_in), .anode(anode), .val(val));
segConv seg(.num(val),.dp(dp),.a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g));

endmodule


//select digit 
module anodeGen(input clk, input [15:0]bcd_in, output reg [3:0]anode, 
                output reg [3:0] val);

reg [9:0] count = 0; 
initial begin
    anode <= 4'b1110; //initialize
    val <= 4'b0000;
    count <= 0;
end

always @(posedge clk) begin
    count <= count + 1;
    if(count == 1023) begin   //count 2^10-1 clock cycles
        anode <= {anode[0],anode[3:1]};	//shift current anode
        count <= 0;  //overwrite count++, reset count
    end
    case(anode)
        4'b1110: val <= bcd_in[3:0];
        4'b1101: val <= bcd_in[7:4];
        4'b1011: val <= bcd_in[11:8];
        4'b0111: val <= bcd_in[15:12];
    endcase
end
endmodule


//seven segment converter
module segConv(input [3:0]num, output reg dp,a,b,c,d,e,f,g);
               
always @(*) begin
    dp = 1'b1;   //default decimal value
    case(num)   //active low
        4'b0000: {a,b,c,d,e,f,g} = 7'b0000001;
        4'b0001: {a,b,c,d,e,f,g} = 7'b1001111;
        4'b0010: {a,b,c,d,e,f,g} = 7'b0010010;
        4'b0011: {a,b,c,d,e,f,g} = 7'b0000110;
        4'b0100: {a,b,c,d,e,f,g} = 7'b1001100;
        4'b0101: {a,b,c,d,e,f,g} = 7'b0100100;
        4'b0110: {a,b,c,d,e,f,g} = 7'b0100000;
        4'b0111: {a,b,c,d,e,f,g} = 7'b0001111;
        4'b1000: {a,b,c,d,e,f,g} = 7'b0000000;
        4'b1001: {a,b,c,d,e,f,g} = 7'b0001100;
        default: {a,b,c,d,e,f,g} = 7'b1111111;
    endcase
end
endmodule