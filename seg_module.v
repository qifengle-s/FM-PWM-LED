module seg_module(
    input clk,
    input rst_n,
    input [3:0] s0,
    input [3:0] s1,
    input [3:0] m0,
    input [3:0] m1,
    input [3:0] h0,
    input [3:0] h1,

    output reg [5:0] sel,
    output reg [7:0] seg
);

reg [3:0] data;
reg [14:0] cnt;

always@(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt <= 15'd0;
    else if(cnt == 24999)
        cnt <= 15'd0;
    else
        cnt <= cnt + 1'b1;

always@(posedge clk or negedge rst_n) // 段选
    if(!rst_n)
        sel <= 6'b111110;
    else if(cnt == 24999)begin
        case(sel)
            6'b111110: sel <= 6'b111101;
            6'b111101: sel <= 6'b111011;
            6'b111011: sel <= 6'b110111;
            6'b110111: sel <= 6'b101111;
            6'b101111: sel <= 6'b011111;
            6'b011111: sel <= 6'b111110;

            default: sel <= 6'b111110;

        endcase
    end

always@(posedge clk or negedge rst_n)
    case(sel)
        6'b111110: data = s0;
        6'b111101: data = s1;
        6'b111011: data = m0;
        6'b110111: data = m1;
        6'b101111: data = h0;
        6'b011111: data = h1;

        default: data = 4'b0000;
    endcase

always@(*)
    case(data)
        4'h0: seg = 8'b11000000;
        4'h1: seg = 8'b11111001;
        4'h2: seg = 8'b10100100;
        4'h3: seg = 8'b10110000;
        4'h4: seg = 8'b10011001;
        4'h5: seg = 8'b10010010;
        4'h6: seg = 8'b10000010;
        4'h7: seg = 8'b11111000;
        4'h8: seg = 8'b10000000;
        4'h9: seg = 8'b10010000;
		4'hA: seg = 8'b11111111;

        default: seg = 8'b11000000;

    endcase
endmodule