
`default_nettype none

module tt_um_minesweeperUABC (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    localparam W = 5;
    localparam N = W * W;

    // ---- constants ----
    wire [N-1:0]   mines, zeros;
    wire [4*N-1:0] counts;
    map #(.W(W)) minefield (
        .clk(clk), 
        .rst_n(rst_n), 
        .btn(btn), 
        .revealed(revealed), 
        .mines(mines), 
        .zeros(zeros), 
        .counts(counts)
    );

    // VGA signals
    wire hsync;
    wire vsync;
    wire [1:0] R;
    wire [1:0] G;
    wire [1:0] B;
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;

    // Tiny VGA Pmod    
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    hvsync_generator vga_sync_gen (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)    
    );

    // Input
    wire up,down,left,right,btn;
    gamepad control(clk,rst_n,ui_in,up,down,left,right,btn);

    wire [2:0] player_x, player_y;
    player #(.W(W)) square (
        .clk(clk), .rst_n(rst_n),
        .up(up), .down(down), .left(left), .right(right),
        .x(player_x), .y(player_y)
    );

    // ---- game ----
    wire [N-1:0] revealed;
    wire         won, lost;
    game_logic #(.W(W)) game (
        .clk(clk), .rst_n(rst_n),
        .reveal(btn),
        .player_x(player_x), 
        .player_y(player_y),
        .mines(mines), .zeros(zeros),
        .revealed(revealed), .won(won), .lost(lost)
    );

    // ---- output ----
    render #(.W(W)) field (
        .hpos(pix_x), 
        .vpos(pix_y), 
        .active(video_active),
        .revealed(revealed), 
        .mines(mines), 
        .counts(counts),
        .player_x(player_x), 
        .player_y(player_y),
        .won(won), 
        .lost(lost),
        .r(R), 
        .g(G), 
        .b(B)
    );

    // Unused outputs assigned to 0.
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Suppress unused signals warning
    wire _unused_ok = &{ena, ui_in[7], ui_in[3:0], uio_in};

endmodule
