module pulse_generator (
    input  wire        clk,         // System Clock
    input  wire        rst_n,       // Active-low asynchronous reset
    input  wire        trigger,     // Input trigger to start the sequence
    input  wire [15:0] delay_cycles,// Number of clock cycles to wait before pulse
    input  wire [15:0] width_cycles,// Number of clock cycles the pulse stays HIGH
    output reg         pulse_out    // Output control pulse
);

    // State Machine Encoding
    localparam IDLE  = 2'b00,
               DELAY = 2'b01,
               PULSE = 2'b10;

    reg [1:0]  current_state, next_state;
    reg [15:0] counter;

    // State Transition Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next State Logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (trigger)
                    next_state = DELAY;
                else
                    next_state = IDLE;
            end
            DELAY: begin
                // Wait until counter matches the requested delay cycles
                if (counter >= delay_cycles - 1)
                    next_state = PULSE;
                else
                    next_state = DELAY;
            end
            PULSE: begin
                // Keep pulse active until requested width cycles expire
                if (counter >= width_cycles - 1)
                    next_state = IDLE;
                else
                    next_state = PULSE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Counter and Output Control Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 16'd0;
            pulse_out <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    counter   <= 16'd0;
                    pulse_out <= 1'b0;
                end
                DELAY: begin
                    pulse_out <= 1'b0;
                    if (counter >= delay_cycles - 1)
                        counter <= 16'd0; // Reset counter for the next stage
                    else
                        counter <= counter + 1'b1;
                end
                PULSE: begin
                    pulse_out <= 1'b1; // Drive pulse HIGH
                    if (counter >= width_cycles - 1)
                        counter <= 16'd0;
                    else
                        counter <= counter + 1'b1;
                end
            endcase
        end
    end

endmodule
