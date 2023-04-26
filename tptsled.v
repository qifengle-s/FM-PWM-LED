module tptsled(
	 input clk,
    input rst_n,
    input key_in_duty,
    input key_in_period,
    output led,
    output [5:0] sel,
    output [7:0] seg
);
wire isPress_duty, isPress_period;
reg [7:0] duty;
wire [23:0] period;
reg [8:0] frequency;
wire [23:0] htime;
wire [3:0] h0,h1,m0,s0,s1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        duty <= 8'd 99;
    else begin
        if(isPress_duty) begin
            duty <= duty - 8'd2;
            if(duty <= 0 || duty >= 99) duty <= 8'd99;
        end
    end
end

assign htime = period * duty / 100;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        frequency <= 8'd200;
    else begin
        if(isPress_period) begin
            frequency <= frequency - 8'd4;
            if(frequency <= 0 || frequency >= 200) frequency <= 8'd200;
        end
    end
end

assign period = 1_000_000_000/(frequency * 20);

led i1 (
	.clk(clk),
	.htime(htime),
	.led(led),
	.period(period),
	.rst_n(rst_n)
);

key_filter i2 (
	.clk(clk),
	.key_in(key_in_duty),
	.rst_n(rst_n),
    .isPress(isPress_duty)
);

key_filter i3 (
	.clk(clk),
	.key_in(key_in_period),
	.rst_n(rst_n),
    .isPress(isPress_period)
);

assign h0 = duty % 10;
assign h1 = duty / 10;
assign s0 = frequency % 10;
assign s1 = (frequency / 10) % 10;
assign m0 = frequency / 100;

seg_module i4 (
	.clk(clk),
	.h0(h0),
	.h1(h1),
	.m0(m0),
	.m1(4'hA),
	.rst_n(rst_n),
	.s0(s0),
	.s1(s1),
	.seg(seg),
	.sel(sel)
);
endmodule