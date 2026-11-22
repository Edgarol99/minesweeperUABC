module pulse (
    input wire clk,
    input wire btn,   
    output reg press 
);
    reg last;
    always @(posedge clk) begin
            press <= btn && ~last;
            last <= btn;
    end

endmodule
