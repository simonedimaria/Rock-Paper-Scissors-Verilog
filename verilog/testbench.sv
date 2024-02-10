`timescale 1ns / 1ns

module MorraCinese_tb;
  reg        clk;
  reg [1:0]  PRIMO;
  reg [1:0]  SECONDO;
  reg        INIZIA;
  wire [1:0] MANCHE;
  wire [1:0] PARTITA;
  
  reg [4:0] max_manches, manches_played;
  reg [4:0] current_state, next_state;
  reg       moves_are_valid;
  reg       played_max, played_min;
  reg [1:0] manche_winner, leading_player, tmp_game_winner, game_winner, last_p1_move, last_p2_move;
  
  // Instantiate the Design Under Test (DUT)
  MorraCinese dut (
    .clk    (clk),
    .PRIMO  (PRIMO),
    .SECONDO(SECONDO),
    .INIZIA (INIZIA),
    .MANCHE (MANCHE),
    .PARTITA(PARTITA)
    ,
    .max_manches  (max_manches),
    .manches_played (manches_played),
    .current_state(current_state),
    .next_state(next_state),
    .moves_are_valid(moves_are_valid),
    .played_max(played_max),
    .played_min(played_min),
    .manche_winner(manche_winner),
    .leading_player(leading_player),
    .tmp_game_winner(tmp_game_winner),
    .game_winner(game_winner),
    .last_p1_move(last_p1_move),
    .last_p2_move(last_p2_move)
  );
  
  // Clock generation:
  // schedule an inversion every 1 ns, giving a clock frequency 1/2ns = 500MHz
  initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
  end
  
  // Test Cases generation: 
  // waiting 2ns (1 clock cycle) between each round
  initial begin
    $monitor("@[t:%0t][clk:%b]    | INPUTS        --> INIZIA:%b, PRIMO:%b, SECONDO:%b\n",  $time, clk, INIZIA, PRIMO, SECONDO,
             "                 | DP internals  --> max_manches:%b, manches_played:%b, moves_are_valid:%b last_p1_move:%b, last_p2_move:%b, manche_winner:%b, leading_player:%b, tmp_game_winner:%b, game_winner:%b\n", max_manches, manches_played, moves_are_valid, last_p1_move, last_p2_move, manche_winner, leading_player, tmp_game_winner, game_winner,
             "                 | FSM internals --> current_state:%b, next_state:%b\n",  current_state, next_state,
             "                 | OUTPUTS       --> MANCHE:%b, PARTITA:%b",            MANCHE, PARTITA
             );

    // Round 0
    #2;
    INIZIA  = 1'b1;
    PRIMO   = 2'b01;
    SECONDO = 2'b10;
    
    // Round 1
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b00;
    SECONDO = 2'b00;

    // Round 2
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b10;
    SECONDO = 2'b01;
    
    // Round 3
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b11;
    SECONDO = 2'b01;
    
    // Round 4
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b00;
    SECONDO = 2'b10;
    
    // Round 5
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b01;
    SECONDO = 2'b01;

    // Round 6
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b01;
    SECONDO = 2'b01;

    // Round 7
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b10;
    SECONDO = 2'b01;
    
    // Restart the game
    #2;
    INIZIA  = 1'b1;
    PRIMO   = 2'b00;  // setting n. of rounds to play:
    SECONDO = 2'b01;  // PRIMO+SECONDO + 4 = 0001 + 0100 = 5 rounds to play
    
    // Round 1
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b01;
    SECONDO = 2'b10;

    // Round 2
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b11;
    SECONDO = 2'b01;

    // Round 3
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b10;
    SECONDO = 2'b11;

    // Round 4
    #2;
    INIZIA  = 1'b0;
    PRIMO   = 2'b11;
    SECONDO = 2'b10;

    // [...] more test cases
    
    #2    
    $stop; // Stop simulation
  end
  
endmodule
