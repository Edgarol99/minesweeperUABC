
`default_nettype none

module map #(
    parameter W = 6                      // board is W x W (the MINES literal below is for W=6)
) (
    output wire [W*W-1:0]   mines,       // 1 = mine
    output wire [W*W-1:0]   zeros,       // 1 = safe cell with 0 adjacent mines (flood fill spreads from these)
    output wire [4*W*W-1:0] counts       // 4-bit adjacent-mine count per cell
);
    localparam N = W * W;

    //                row5       row4       row3       row2       row1       row0
    localparam [N-1:0] MINES = {
    6'b000100, 
    6'b100001, 
    6'b000000, 
    6'b010000, 
    6'b000010, 
    6'b000000};
    //  . . . . . .  row0
    //  . * . . . .  row1
    //  . . . . * .  row2
    //  . . . . . .  row3
    //  * . . . . *  row4
    //  . . * . . .  row5

    // Count mines around cell i (constant function, evaluated at elaboration).
    function [3:0] adj(input integer i);
        integer x, y, dx, dy, nx, ny, c;
        begin
            x = i % W;
            y = i / W;
            c = 0;
            for (dy = -1; dy <= 1; dy = dy + 1)
                for (dx = -1; dx <= 1; dx = dx + 1) begin
                    nx = x + dx;
                    ny = y + dy;
                    if ((dx != 0 || dy != 0) && nx >= 0 && nx < W && ny >= 0 && ny < W)
                        if (MINES[ny*W + nx]) c = c + 1;
                end
            adj = c;
        end
    endfunction

    assign mines = MINES;

    genvar g;
    generate
        for (g = 0; g < N; g = g + 1) begin : per_cell
            assign counts[g*4 +: 4] = adj(g);
            assign zeros[g]         = !MINES[g] && (adj(g) == 0);
        end
    endgenerate
endmodule
