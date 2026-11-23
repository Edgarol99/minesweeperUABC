
module push_btn(
    input clk,
    input clk_slow,
    input rst_n,
    input btn,
    output spike
);

reg current;
reg last;

always @(posedge clk_slow) begin
    current <= btn;
    last <= current;
end

reg [3:0] counter;
reg clean;

always @(posedge clk) begin
    if (last != current) 
        counter <= 0;
    else begin
        if (counter == 4'd10)
            clean <= last;
        else
            counter <= counter +1;
    end

end

pulse push(clk,rst_n,clean,spike);

endmodule