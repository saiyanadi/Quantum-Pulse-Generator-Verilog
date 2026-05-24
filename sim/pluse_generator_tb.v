`timescale 1ns / 1ps

module pulse_generator_tb;

    // Inputs
    reg         clk;
    reg         rst_n;
    reg         trigger;
    reg  [15:0] delay_cycles;
    reg  [15:0] width_cycles;

    // Outputs
    wire        pulse_out;

    // Instantiate the Unit Under Test (UUT)
    pulse_generator uut (
        .clk(clk),
        .rst_n(rst_n),
        .trigger(trigger),
        .delay_cycles(delay_cycles),
        .width_cycles(width_cycles),
        .pulse_out(pulse_out)
    );

    // Clock Generation (100 MHz clock -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        trigger = 0;
        delay_cycles = 16'd5;  // Wait 5 clock cycles
        width_cycles = 16'd10; // Pulse stays high for 10 clock cycles

        // Hold reset state for 20ns
        #20;
        rst_n = 1;
        #20;

        // Apply Trigger Pulse
        trigger = 1;
        #10;
        trigger = 0;

        // Wait for simulation to observe delay and pulse execution
        #200;
        
        // Test a second configuration
        delay_cycles = 16'd3;
        width_cycles = 16'd4;
        trigger = 1;
        #10;
        trigger = 0;
        
        #100;
        $finish;
    end
      
endmodule
