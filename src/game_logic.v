
`default_nettype none

module game_logic #(
    parameter W = 6,
    parameter N = W * W
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         reveal,         // one-clock pulse
    input  wire [2:0]   player_x,
    input  wire [2:0]   player_y,
    input  wire [N-1:0] mines,          // constants from board_map
    input  wire [N-1:0] zeros,
    output reg  [N-1:0] revealed,
    output wire         won,
    output wire         lost
);
    // ---- win / lose, derived from the board ----
    assign lost = |(revealed & mines);
    assign won  = !lost && ((revealed | mines) == {N{1'b1}});

    // ---- flood fill: spread[i] = 1 if a revealed zero cell touches cell i ----
    wire [N-1:0] spread;

    genvar x, y, dx, dy;
    generate
        for (y = 0; y < W; y = y + 1) begin : row
            for (x = 0; x < W; x = x + 1) begin : col
                wire [8:0] hit;
                for (dy = 0; dy < 3; dy = dy + 1) begin : ndy
                    for (dx = 0; dx < 3; dx = dx + 1) begin : ndx
                        localparam NX = x + dx - 1;
                        localparam NY = y + dy - 1;
                        if (NX >= 0 && NX < W && NY >= 0 && NY < W && !(dx == 1 && dy == 1)) begin : real_nb
                            assign hit[dy*3 + dx] = revealed[NY*W + NX] & zeros[NY*W + NX];
                        end else begin : no_nb
                            assign hit[dy*3 + dx] = 1'b0;
                        end
                    end
                end
                assign spread[y*W + x] = |hit;
            end
        end
    endgenerate

    wire [4:0]   idx  = player_y * W + player_x;
    wire         can_reveal = reveal && !lost && !won;
    wire [N-1:0] pick = can_reveal ? ({{(N-1){1'b0}}, 1'b1} << idx) : {N{1'b0}};

    always @(posedge clk) begin
        if (!rst_n | ((won|lost) & reveal))
            revealed <= {N{1'b0}};
        else
            revealed <= revealed | spread | pick;
    end
endmodule
