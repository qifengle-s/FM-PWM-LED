module led (
    input clk,
    input rst_n,
    input [23:0] period,
    input [23:0] htime,
    output reg led
);
    reg [23:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cnt <= 24'b0;
        else begin
            if(cnt >= period)
                cnt <= 24'b0;
            else
                cnt <= cnt + 24'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            led <= 1'b0;
        else begin
            if(cnt <= htime)
                led <= 1'b1;
            else
                led <= 1'b0;
        end
    end
endmodule