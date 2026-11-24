
module pulse (
    input wire clk,
    input wire rst_n,
    input wire btn,   
    output wire press 
);

    reg last;
    always @(posedge clk) begin
        if (~rst_n)
            last <= 1'b0;
        else 
        last <= btn;
    end
    assign press = btn && ~last;

endmodule
