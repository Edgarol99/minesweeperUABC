module musica_buscaminas #(parameter CLK_HZ = 10_000_000) (
    input  wire clk,
    input  wire boom,
    output reg  buzzer
);
    
    localparam DO = CLK_HZ / (2 * 262);
    localparam RE = CLK_HZ / (2 * 294);
    localparam MI = CLK_HZ / (2 * 330);
    localparam SOL = CLK_HZ / (2 * 392);
    localparam LA  = CLK_HZ / (2 * 440);
    localparam DO2 = CLK_HZ / (2 * 523);
    localparam BOOM_N = CLK_HZ / (2 * 110);
    localparam SIL    = 0;

    reg [24:0] t_nota = 0;
    reg [3:0]  paso   = 0;
    reg [17:0] cont   = 0;
    reg [17:0] div;
    
     always @(posedge clk) begin
        if (t_nota == CLK_HZ/4 - 1) begin
            t_nota <= 0;
            paso   <= paso + 1;
        end else
            t_nota <= t_nota + 1;
     end
         always @(*) begin
        if (boom)
            div = BOOM_N;
        else begin
            case (paso)
               0:  div = MI;   1:  div = SIL;
                2:  div = MI;   3:  div = SOL;
                4:  div = LA;   5:  div = SIL;
                6:  div = SOL;  7:  div = MI;
                8:  div = RE;   9:  div = SIL;
                10: div = RE;   11: div = MI;
                12: div = DO;   13: div = SIL;
                14: div = DO2;  15: div = SIL;   
            endcase
        end
         end
    always @(posedge clk) begin
        if(div ==0) begin
            buzzer <=0;
            cont <=0;
        end else if (cont >= div -1) begin
            cont <=0;
            buzzer <= ~buzzer;
        end else
            cont<= cont + 1;
    end
    
endmodule
