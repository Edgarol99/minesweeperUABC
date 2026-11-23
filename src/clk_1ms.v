
module clk_1ms (
    input  wire clk_25mhz,  
    input  wire rst_n,       
    output reg  clk_1ms
);

    // 12,500 requires a 14-bit counter
    reg [13:0] counter;

    always @(posedge clk_25mhz) begin
        if (!rst_n) begin
            counter <= 14'd0;
            clk_1ms <= 1'b0;
        end else begin
            if (counter == 14'd12_499) begin
                counter <= 14'd0;
                clk_1ms <= ~clk_1ms;
            end else begin
                counter <= counter + 14'd1;
            end
        end
    end

endmodule