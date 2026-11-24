`default_nettype none

module music_tb (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire buzzer;
    musicmmoi  #(.CLK_HZ(10_000_000)) musica (
        .clk   (clk),
        .boom  (ui_in[0]),      // ENTRADA
        .buzzer(buzzer)
    );
    assign ou_out = {7'b0, buzzer};
    assign uio_out = 8'b0;
    assign uio_oe =8'b0;
    wire _unused = &{ena,rst_n,uio_in,ui_in[7:1], 1'b0};
endmodule
