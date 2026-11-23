
module game_logic(
    input  wire clk,
    input  wire rst_n,
    input [63:0] mines,
    input btn,up,down,left,right,
    output reg [63:0] revealed_cells,
    output reg [2:0] player_x,
    output reg [2:0] player_y
);

    //STATES
    localparam START = 0;
    localparam PLAY = 1;
    localparam GAMEOVER = 2;
    localparam WIN = 3;

    reg [1:0] current_state;
    reg [1:0] next_state;
    
    always @ (posedge clk or negedge rst_n)
        begin: STATE_MEMORY
        if (!rst_n)
            current_state <= PLAY;
        else
            current_state<=next_state;
        end

    always @ (current_state)
     begin: NEXT_STATE_LOGIC_AND_OUTPUT_LOGIC
        case (current_state)
            START : begin
                        player_x<=0;
                        player_y<=0;
                        revealed_cells = 64'b0;
                        if (btn) begin
                            next_state <= PLAY;
                        end
                    end
            PLAY :  begin
                            if (down)
                              player_y <= player_y+1;
                            if (up)
                              player_y <= player_y-1;
                            if (left)
                              player_x <= player_x-1;
                            if (right)
                              player_x <= player_x+1;
                        if (btn) begin
                            if (!revealed_cells[player_id]) begin
                                revealed_cells[player_id] <= 1;
                                if (mines[player_id])
                                    next_state <= GAMEOVER;
                            end 
                        end
                    end
            GAMEOVER : begin 
                if (btn) begin
                    next_state <= START;
                end
            end
         endcase
     end

    wire [7:0] player_id = {player_y, player_x};

endmodule
