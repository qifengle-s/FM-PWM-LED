module key_filter(
    input clk,
    input rst_n,
    input key_in,
    output isPress
);

reg key_state,key_flag;
reg [3:0] state;
reg [23:0] cnt;
reg [23:0] cnt2;
reg en_cnt; // 计数使能
reg en_cnt2;
reg key_in_sa;
reg key_in_sb;
reg key_tmpa;
reg key_tmpb;
reg cnt_full;
reg cnt_full2; // 长按计数

wire pedge;
wire nedge;

parameter IDEL = 4'b0001,
          FILTER0 = 4'b0010,
          DOWN = 4'b0100,
          FILTER1 = 4'b1000;

assign isPress = (~key_state) & key_flag;

always @(posedge clk or negedge rst_n)
    if(!rst_n)begin
        key_in_sa <= 1'b0;
        key_in_sb <= 1'b0;
    end
    else begin
        key_in_sa <= key_in;
        key_in_sb <= key_in_sa;
    end

always @(posedge clk or negedge rst_n)
    if(!rst_n)begin
        key_tmpa <= 1'b0;
        key_tmpa <= 1'b0;
    end
    else begin
        key_tmpa <= key_in_sb;
        key_tmpb <= key_tmpa;
    end
assign nedge = !key_tmpa & key_tmpb;
assign pedge = key_tmpa & (!key_tmpb);

always @(posedge clk or negedge rst_n)
    if(!rst_n)begin
        en_cnt <= 1'b0;
        state <= IDEL;
        key_flag <= 1'b0;
        key_state <= 1'b1;
    end
    else begin
        case(state)
            IDEL:
                begin
                    key_flag <= 1'b0;
                    if(nedge)begin
                        state <= FILTER0;
                        en_cnt <= 1'b1;
                    end
                    else
                        state <= IDEL;
                end
            FILTER0:
                if(cnt_full)begin
                    key_flag <= 1'b1;
                    key_state <= 1'b0;
                    en_cnt <= 1'b0;
                    state <= DOWN;
                end
                else if(pedge)begin
                    state <= IDEL;
                    en_cnt <= 1'b0;
                end
                else
                    state <= FILTER0;
            
            DOWN:
                begin
                    key_flag <= 1'b0;
                    en_cnt2 <= 1'b1;
                    if(cnt_full2) begin
                        key_flag <= 1'b1;
                        en_cnt2 <= 1'b0;
                    end
                    if(pedge)begin
                        state <= FILTER1;
                        en_cnt <= 1'b1;
                        en_cnt2 <= 1'b0;
                    end
                    else
                        state <= DOWN;
                end 
            
            FILTER1:
                if(cnt_full)begin
                    key_flag <= 1'b1;
                    key_state <= 1'b1;
                    en_cnt <= 1'b0;
                    state <= IDEL;
                end
                else if(nedge)begin
                    en_cnt <= 1'b0;
                    state <= DOWN;
                end
                else
                    state <= FILTER1;
            
            default:
                begin
                    state <= IDEL;
                    en_cnt <= 1'b0;
                    key_flag <= 1'b0;
                    key_state <= 1'b1;
                end
        endcase
    end

always @(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt <= 24'd0;
    else if(en_cnt)
        cnt <= cnt + 24'b1;
    else
        cnt <= 24'd0;

always @(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt2 <= 24'd0;
    else if(en_cnt2)
        cnt2 <= cnt2 + 24'b1;
    else
        cnt2 <= 24'd0;

always @(posedge clk or negedge rst_n)
    if(!rst_n) begin
        cnt_full <= 1'b0;
    end
    else if(cnt == 999_999)
        cnt_full <= 1'b1;
    else begin
        cnt_full <= 1'b0;
    end

always @(posedge clk or negedge rst_n)
    if(!rst_n) begin
        cnt_full2 <= 1'b0;
    end
    else if(cnt2 == 2_000_000 - 1)
        cnt_full2 <= 1'b1;
    else begin
        cnt_full2 <= 1'b0;
    end
endmodule