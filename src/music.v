
module musica_buscaminas #(parameter CLK_HZ = 25_175_000) (
    input  wire clk,
    input  wire boom,
    output reg  buzzer
);
    // Prescale by 64 (25.175 MHz -> 393.359 kHz)
    localparam TICK_HZ = CLK_HZ / 64;

    localparam [10:0] DO     = TICK_HZ / (2 * 262); // 750
    localparam [10:0] RE     = TICK_HZ / (2 * 294); // 668
    localparam [10:0] MI     = TICK_HZ / (2 * 330); // 595
    localparam [10:0] SOL    = TICK_HZ / (2 * 392); // 501
    localparam [10:0] LA     = TICK_HZ / (2 * 440); // 446
    localparam [10:0] DO2    = TICK_HZ / (2 * 523); // 376
    localparam [10:0] BOOM_N = TICK_HZ / (2 * 110); // 1787
    localparam [10:0] SIL    = 11'd0;

    reg [5:0]  prescale = 0;
    wire       tick     = (prescale == 6'd63);

    reg [17:0] t_nota   = 0; // max 98,339 (fits in 18 bits)
    reg [3:0]  paso     = 0;
    reg [10:0] cont     = 0; // max 1,787  (fits in 11 bits)

    // 1. 6-bit shared prescaler
    always @(posedge clk) begin
        prescale <= prescale + 6'd1;
    end

    // 2. Step timer (18-bit down-counter)
    always @(posedge clk) begin
        if (tick) begin
            if (t_nota == 18'd0) begin
                t_nota <= (TICK_HZ / 4) - 1;
                paso   <= paso + 4'd1;
            end else begin
                t_nota <= t_nota - 18'd1;
            end
        end
    end

    // 3. Compact 3-bit note ROM
    reg [2:0] note_idx;
    always @(*) begin
        if (boom)
            note_idx = 3'd7;
        else begin
            case (paso)
                4'd0:  note_idx = 3'd3; // MI
                4'd1:  note_idx = 3'd0; // SIL
                4'd2:  note_idx = 3'd3; // MI
                4'd3:  note_idx = 3'd4; // SOL
                4'd4:  note_idx = 3'd5; // LA
                4'd5:  note_idx = 3'd0; // SIL
                4'd6:  note_idx = 3'd4; // SOL
                4'd7:  note_idx = 3'd3; // MI
                4'd8:  note_idx = 3'd2; // RE
                4'd9:  note_idx = 3'd0; // SIL
                4'd10: note_idx = 3'd2; // RE
                4'd11: note_idx = 3'd3; // MI
                4'd12: note_idx = 3'd1; // DO
                4'd13: note_idx = 3'd0; // SIL
                4'd14: note_idx = 3'd6; // DO2
                4'd15: note_idx = 3'd0; // SIL
            endcase
        end
    end

    // 4. Single 8:1 decoder for 11-bit period
    reg [10:0] div;
    always @(*) begin
        case (note_idx)
            3'd1:    div = DO;
            3'd2:    div = RE;
            3'd3:    div = MI;
            3'd4:    div = SOL;
            3'd5:    div = LA;
            3'd6:    div = DO2;
            3'd7:    div = BOOM_N;
            default: div = SIL;
        endcase
    end

    // 5. Tone generator (11-bit down-counter)
    always @(posedge clk) begin
        if (div == 11'd0) begin
            buzzer <= 1'b0;
            cont   <= 11'd0;
        end else if (tick) begin
            if (cont == 11'd0) begin
                cont   <= div - 11'd1;
                buzzer <= ~buzzer;
            end else begin
                cont   <= cont - 11'd1;
            end
        end
    end

endmodule
