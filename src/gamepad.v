
module gamepad (
    input wire clk,
    input wire clk_slow,
    input wire rst_n,
    input wire [7:0] ui_in,
    output wire up,
    output wire down,
    output wire left,
    output wire right,
    output wire btn
);

    // Gamepad Pmod
    wire inp_b, inp_y, inp_select, inp_start, inp_up, inp_down, inp_left, inp_right, inp_a, inp_x, inp_l, inp_r;

    gamepad_pmod_single ctrl(
        // Inputs:
        .rst_n(rst_n),
        .clk(clk),
        .pmod_data(ui_in[6]),
        .pmod_clk(ui_in[5]),
        .pmod_latch(ui_in[4]),
        // Outputs:
        .b(inp_b),
        .y(inp_y),
        .select(inp_select),
        .start(inp_start),
        .up(inp_up),
        .down(inp_down),
        .left(inp_left),
        .right(inp_right),
        .a(inp_a),
        .x(inp_x),
        .l(inp_l),
        .r(inp_r)
    );

    wire ctrl_up,ctrl_down,ctrl_left,ctrl_right,ctrl_btn;
    pulse pad_up(clk,rst_n,inp_up,ctrl_up);
    pulse pad_down(clk,rst_n,inp_down,ctrl_down);
    pulse pad_left(clk,rst_n,inp_left,ctrl_left);
    pulse pad_right(clk,rst_n,inp_right,ctrl_right);
    pulse pad_btn(clk,rst_n,inp_a,ctrl_btn);

    wire clk_1ms;
    clk_1ms btn_clk(clk,rst_n,clk_1ms);

    wire push_up,push_down,push_left,push_right,push_action;
    push_btn u1(clk,clk_slow,rst_n,ui_in[0],push_up);
    push_btn u2(clk,clk_slow,rst_n,ui_in[1],push_down);
    push_btn u3(clk,clk_slow,rst_n,ui_in[2],push_left);
    push_btn u4(clk,clk_slow,rst_n,ui_in[3],push_right);
    push_btn u5(clk,clk_slow,rst_n,ui_in[7],push_action);

    assign up = ctrl_up | push_up;
    assign down = ctrl_down | push_down;
    assign left = ctrl_left | push_left;
    assign right = ctrl_right | push_right;
    assign btn = ctrl_btn | push_btn;

endmodule
