`timescale 1ns / 1ns

module MorraCinese_tb;
  
  reg clk;
  reg [1:0] PRIMO;
  reg [1:0] SECONDO;
  reg INIZIA;
  wire [1:0] MANCHE;
  wire [1:0] PARTITA;
  
  reg [4:0] rounds_to_play;
  
  // Instantiate the Design Under Test (DUT)

  MorraCinese dut (
    .clk(clk),
    .PRIMO(PRIMO),
    .SECONDO(SECONDO),
    .INIZIA(INIZIA),
    .MANCHE(MANCHE),
    .PARTITA(PARTITA),
    .rounds_to_play(rounds_to_play)
  );
  
  // Clock generation:
  // schedule an inversion every 1 ns, giving a clock frequency 1/2ns = 500MHz
  initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
  end
  
  // Test Cases generation: 
  // waiting 2ns (1 clock cycle) between each round
  initial begin

    $monitor("@[%0t] INIZIA:%b, PRIMO:%b, SECONDO:%b, rounds_to_play:%b", $time, INIZIA, PRIMO, SECONDO, rounds_to_play);

    // Round 1
    INIZIA = 1'b0;
    PRIMO = 2'b01;
    SECONDO = 2'b10;
    #2;
    
    // Round 2
    PRIMO = 2'b10;
    SECONDO = 2'b01;
    #2;
    
    // Round 3
    INIZIA = 1'b0;
    PRIMO = 2'b11;
    SECONDO = 2'b01;
    #2;
    
    // Round 4
    INIZIA = 1'b0;
    PRIMO = 2'b01;
    SECONDO = 2'b01;
    #2;
    
    // Restart the game
    INIZIA = 1'b1;
    PRIMO = 2'b00;   // setting n. of rounds to play:
    SECONDO = 2'b01; // PRIMO+SECONDO + 4 = 0001 + 0100 = 5 rounds to play
    #2;
    
    // [...] more test cases
    
    $stop; // Stop simulation
  end
  
endmodule
