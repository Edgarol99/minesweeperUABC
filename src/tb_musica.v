`timescale 1ns/1ps
module tb_musica;
    reg  clk  = 0;
    reg  boom = 0;
    wire buzzer;

    musica_buscaminas #(.CLK_HZ(100_000)) uut (
        .clk(clk), .boom(boom), .buzzer(buzzer)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("onda.vcd");
        $dumpvars(0, tb_musica);
        #4_000_000 boom = 1;
        #500_000   boom = 0;
        #1_000_000 $finish;
    end
endmodule
