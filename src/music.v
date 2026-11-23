module musica_buscaminas #(parameter CLK_HZ = 50_000_000) (
    input  wire clk,
    input  wire boom,
    output reg  buzzer
);
    // (aquí ya NO va "localparam CLK_HZ = ...")
    localparam DO = CLK_HZ / (2 * 262);
  
endmodule
