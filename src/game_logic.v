
module game_logic(
    input  wire clk,
    input  wire rst_n,
    input [63:0] mines,
    input btn,
    output reg [63:0] revealed_cells
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
            current_state <= START;
        else
            current_state<=next_state;
        end

    always @ (current_state)
     begin: NEXT_STATE_LOGIC_AND_OUTPUT_LOGIC
        case (current_state)
            START : begin
                        revealed_cells = 64'b0;
                        if (btn) begin
                            next_state <= PLAY;
                        end
                    end
            PLAY :  begin
                        if (btn) begin
                            if (btn && !revealed_cells[player_id]) begin
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

    wire [7:0] player_id = {cursor_y, cursor_x};

endmodule
