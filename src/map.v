`default_nettype none

// ---------------------------------------------------------------------------
// map : random W x W mine map (W <= 5), 3..10 mines, driven by a 16-bit LFSR.
//
// A map is generated when `btn` is pressed while nothing is revealed (i.e. the
// first click of a game). The clicked cell shows up in `revealed` one clock
// later, and generation never puts a mine in that cell or its 8 neighbours, so
// the first click is always a zero and opens an area.
//
// While generating (a few dozen clocks), `zeros` is forced to 0 so the flood
// fill doesn't spread over a half-built map.
// ---------------------------------------------------------------------------
module map #(
    parameter W = 5                      // positions come from a 5-bit value, so W <= 5
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             btn,
    input  wire [W*W-1:0]   revealed,
    output wire [W*W-1:0]   mines,       // 1 = mine
    output wire [W*W-1:0]   zeros,       // 1 = safe cell with 0 adjacent mines
    output wire [4*W*W-1:0] counts       // 4-bit adjacent-mine count per cell
);
    localparam N         = W * W;

    localparam [N-1:0] COL_FIRST = {W{ {{(W-1){1'b0}}, 1'b1} }};   // x = 0 in every row
    localparam [N-1:0] COL_LAST  = COL_FIRST << (W-1);              // x = W-1 in every row

    function [N-1:0] grow(input [N-1:0] a);
        reg [N-1:0] h;
        begin
            h    = a | ((a << 1) & ~COL_FIRST) | ((a >> 1) & ~COL_LAST);   // left/right
            grow = h | (h << W) | (h >> W);                                 // up/down
        end
    endfunction

    reg [15:0] lfsr;

    function [15:0] lfsr_step(input [15:0] s);
        integer k;
        reg [15:0] t;
        begin
            t = s;
            for (k = 0; k < 7; k = k + 1)
                t = {t[14:0], t[15] ^ t[14] ^ t[12] ^ t[3]};
            lfsr_step = t;
        end
    endfunction

    always @(posedge clk) begin
        if (!rst_n) lfsr <= 16'hACE1;    // never 0
        else        lfsr <= lfsr_step(lfsr);
    end

    // mine placement: one random position per clock, rejected if it is off the
    // board, already a mine, or inside the safe zone around the first click.
    // Rejected tries cost a clock but never count, so the total is exact.
    reg [N-1:0] mines_reg;
    reg [3:0]   mines_count;
    reg [3:0]   mines_target;
    reg         making;

    wire [4:0]  rand_pos = lfsr[4:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            mines_reg    <= {N{1'b0}};
            mines_count  <= 4'd0;
            mines_target <= 4'd0;
            making       <= 1'b0;
        end else if (btn && !(|revealed)) begin             // first click: start a new map
            mines_reg    <= {N{1'b0}};
            mines_count  <= 4'd0;
            mines_target <= lfsr[10:8];
            making       <= 1'b1;
        end else if (making) begin
            mines_reg[rand_pos] <= 1'b1;
            mines_count         <= mines_count + 4'd1;
            if (mines_count + 4'd1 == mines_target)
                making <= 1'b0;
        end
    end

    assign mines = mines_reg;

    assign zeros = ~grow(mines_reg) & {N{~making}};

    // adjacent-mine count for every cell
    genvar x, y, dx, dy;
    generate
        for (y = 0; y < W; y = y + 1) begin : row
            for (x = 0; x < W; x = x + 1) begin : col
                wire [8:0] nb;
                for (dy = 0; dy < 3; dy = dy + 1) begin : ndy
                    for (dx = 0; dx < 3; dx = dx + 1) begin : ndx
                        localparam NX = x + dx - 1;
                        localparam NY = y + dy - 1;
                        if (NX >= 0 && NX < W && NY >= 0 && NY < W && !(dx == 1 && dy == 1))
                            assign nb[dy*3 + dx] = mines_reg[NY*W + NX];
                        else
                            assign nb[dy*3 + dx] = 1'b0;
                    end
                end
                assign counts[(y*W + x)*4 +: 4] = nb[0] + nb[1] + nb[2] + nb[3] + nb[4]
                                                + nb[5] + nb[6] + nb[7] + nb[8];
            end
        end
    endgenerate
endmodule