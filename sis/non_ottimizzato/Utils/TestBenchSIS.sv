`timescale 1ns / 1ps

module MorraCinese_tb;
  logic        clk;
  logic [1:0]  PRIMO;
  logic [1:0]  SECONDO;
  logic        INIZIA;
  logic [1:0] MANCHE;
  logic [1:0] PARTITA;
  // for debug purposes 
  logic [4:0] max_manches, manches_played;
  logic [4:0] current_state, next_state;
  logic       moves_are_valid;
  logic       played_max, played_min;
  logic [1:0] manche_winner, leading_player, tmp_game_winner, game_winner, last_p1_move, last_p2_move;
    integer tbf, outf;


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


  // Constants
  localparam bit [0:0]  PLAY    = 1'b0,  
                        RESTART = 1'b1;

  localparam bit [1:0]  NO_MOVE  = 2'b00,
                        ROCK     = 2'b01,
                        PAPER    = 2'b10,
                        SCISSORS = 2'b11;

  localparam bit [1:0]  INVALID = 2'b00,
                        PLAYER1 = 2'b01,
                        PLAYER2 = 2'b10,
                        NONE    = 2'b11;

  localparam bit [1:0]  NOT_ENDED = 2'b00,
                        P1_WINNER = 2'b01,
                        P2_WINNER = 2'b10,
                        DRAW      = 2'b11;

  // Clock generation:
  // schedule an inversion every 1 ns, giving a clock frequency 1/2ns = 500MHz
  initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
  end
  
  // Define tasks for setting inputs
  task play_round_and_check;
    input logic [0:0] INIZIA_t;
    input logic [1:0] PRIMO_t;
    input logic [1:0] SECONDO_t;
    input logic [1:0] expected_MANCHE;
    input logic [1:0] expected_PARTITA;
    begin
      INIZIA  <= INIZIA_t;
      PRIMO   <= PRIMO_t;
      SECONDO <= SECONDO_t;
      $fdisplay(tbf,"simulate %b %b %b %b %b",INIZIA,  PRIMO[1], PRIMO[0], SECONDO[1],SECONDO[0]);
      
      @(posedge clk);

        assert (MANCHE  === expected_MANCHE)  else $error("Expected MANCHE:  %b, Received MANCHE:  %b, with inputs: INIZIA:%b, PRIMO:%b, SECONDO:%b", expected_MANCHE, MANCHE, INIZIA, PRIMO, SECONDO);   // @TO-DO: change manche_winner to MANCHE
        assert (PARTITA === expected_PARTITA) else $error("Expected PARTITA: %b, Received PARTITA: %b, with inputs: INIZIA:%b, PRIMO:%b, SECONDO:%b", expected_PARTITA, PARTITA, INIZIA, PRIMO, SECONDO); // may be broken :'(
        $fdisplay(outf,"Outputs: %b %b %b %b",  MANCHE[1],MANCHE[0],  PARTITA[1],PARTITA[0]);
    end
  endtask
  
  // Test Cases generation: 
  // waiting 2ns (1 clock cycle) between each round
  initial begin
  tbf     = $fopen("testbench.script", "w");
  outf = $fopen("output_verilog.txt", "w");
  $fdisplay(tbf,"read_blif FSMD.blif"); 
    $monitor("@[t:%0t][clk:%b]    | INPUTS        --> INIZIA:%b, PRIMO:%b, SECONDO:%b\n",  $time, clk, INIZIA, PRIMO, SECONDO,
             "                 | DP internals  --> max_manches:%b, manches_played:%b, moves_are_valid:%b last_p1_move:%b, last_p2_move:%b, manche_winner:%b, leading_player:%b, tmp_game_winner:%b, game_winner:%b\n", max_manches, manches_played, moves_are_valid, last_p1_move, last_p2_move, manche_winner, leading_player, tmp_game_winner, game_winner,
             "                 | FSM internals --> current_state:%b, next_state:%b\n",  current_state, next_state,
             "                 | OUTPUTS       --> MANCHE:%b, PARTITA:%b",            MANCHE, PARTITA
             );

    // Start
    play_round_and_check(RESTART, 2'b10, 2'b01, INVALID, NOT_ENDED);       // setting n. of rounds to play: PRIMO+SECONDO + 4 = 1001 + 0100 = 13 rounds to play
    //assert_output(INVALID, NOT_ENDED);
    
    // Round 1 (0-0)
    $display("Round 1");
    play_round_and_check(PLAY, NO_MOVE, NO_MOVE, INVALID, NOT_ENDED);
    //assert_output(INVALID, NOT_ENDED);

    // Round 2 (1-0)
    $display("Round 2");
    play_round_and_check(PLAY, PAPER, ROCK, PLAYER1, NOT_ENDED);
    //assert_output(PLAYER1, NOT_ENDED);

    
    // Round 3 (1-1)
    $display("Round 3");
    play_round_and_check(PLAY, SCISSORS, ROCK, PLAYER2, NOT_ENDED);
    //assert_output(PLAYER2, NOT_ENDED);
    
    // Round 4 (1-1)
    $display("Round 4");
    play_round_and_check(PLAY, NO_MOVE, PAPER, INVALID, NOT_ENDED);
    //assert_output(INVALID, NOT_ENDED);
    
    // Round 5 (1-1)
    $display("Round 5");
    play_round_and_check(PLAY, ROCK, ROCK, NONE, NOT_ENDED);
    //assert_output(NONE, NOT_ENDED);

    // Round 6 (1-1)
    $display("Round 6");
    play_round_and_check(PLAY, ROCK, ROCK, NONE, NOT_ENDED);
    //assert_output(NONE, NOT_ENDED);

    // Round 7 (2-1)
    $display("Round 7");
    play_round_and_check(PLAY, PAPER, ROCK, PLAYER1, NOT_ENDED);
    //assert_output(PLAYER1, NOT_ENDED);
    
    // more rounds
    // [...]


    // Restart the game
    play_round_and_check(RESTART, 2'b00, 2'b01, INVALID, NOT_ENDED);     // setting n. of rounds to play: PRIMO+SECONDO + 4 = 0001 + 0100 = 5 rounds to play
    //assert_output(INVALID, NOT_ENDED);

    // Round 1 (0-1)
    play_round_and_check(PLAY, ROCK, PAPER, PLAYER2, NOT_ENDED);
    //assert_output(PLAYER2, NOT_ENDED);

    // Round 2 (0-2)
    play_round_and_check(PLAY, SCISSORS, ROCK, PLAYER2, NOT_ENDED);
    //assert_output(PLAYER2, NOT_ENDED);

    // Round 3 (0-3)
    play_round_and_check(PLAY, PAPER, SCISSORS, PLAYER2, NOT_ENDED);
    //assert_output(PLAYER2, NOT_ENDED);

    // Round 4 (1-3)
    play_round_and_check(PLAY, SCISSORS, PAPER, PLAYER1, NOT_ENDED);
    //assert_output(PLAYER1, P2_WINNER);
    
    // Round 5 [...]


    #2    
    $stop; // Stop simulation
  end
  
endmodule