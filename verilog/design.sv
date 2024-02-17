//-----------------------------------------------------
// FSMD implementation of the Morra Cinese in Verilog
// Module Name : MorraCinese
// File Name   : design.sv
//-----------------------------------------------------

module MorraCinese (
  input  logic         clk,
  input  logic  [1:0]  PRIMO,   // Player 1 input move
  input  logic  [1:0]  SECONDO, // Player 2 input move
  input  logic         INIZIA,  // Restart the game
  output logic  [1:0]  MANCHE,  // Result of the last round
  output logic  [1:0]  PARTITA  // Result of the entire game
  ,// for debugging purposes
  output logic [4:0] max_manches, manches_played,
  output logic [4:0] current_state,  next_state,
  output logic       moves_are_valid,
  output logic       played_max, played_min,
  output logic [1:0] early_winner, tmp_game_winner,
  output reg   [1:0] last_p1_move, last_p2_move
  
);

  //----------- Internal Constants -----------
  localparam int        MIN_MANCHES = 4;

  localparam bit [1:0]  INVALID = 2'b00,
                        PLAYER1 = 2'b01,
                        PLAYER2 = 2'b10,
                        NONE    = 2'b11;

  localparam bit [1:0]  NOT_ENDED = 2'b00,
                        P1_WINNER = 2'b01,
                        P2_WINNER = 2'b10,
                        DRAW      = 2'b11;
  //-----------------------------------------     
  //----- FSM states (one-hot encoding) -----
  parameter P1_W2 = 5'b00001,
            P1_W1 = 5'b00010,
            START = 5'b00100,
            P2_W1 = 5'b01000,
            P2_W2 = 5'b10000;
  //-----------------------------------------
  //------------- Players Moves -------------
  class Move;
    bit [1:0] strong_to;
    bit [1:0] weak_to;
    
    function new(bit [1:0] _strong_to, bit [1:0] _weak_to);
      strong_to = _strong_to;
      weak_to   = _weak_to;
    endfunction

    function win_on(bit [1:0] move);
      return (move == strong_to);
    endfunction
    
    function lose_to(bit [1:0] move);
      return (move == weak_to);
    endfunction
  endclass

  typedef enum bit [1:0] {
    ROCK      = 2'b01,
    PAPER     = 2'b10,
    SCISSORS  = 2'b11
  } move_id;

  Move moves [move_id];
  //-----------------------------------------
  //---------- Internal Registers -----------
  //reg [4:0] max_manches, manches_played;
  //reg [4:0] current_state, next_state;
  //reg       moves_are_valid;
  //reg       played_max, played_min;
  //reg [1:0] manche_winner, leading_player, tmp_game_winner, last_p1_move, last_p2_move;
  //reg [1:0] last_p1_move, last_p2_move;
  reg [1:0] last_manche_winner, last_game_winner;
  //-----------------------------------------
  //------------ Constructor ----------------
  initial begin
    moves[INVALID]  = new(INVALID,    INVALID); // [0,0] is invalid to avoid SIGSEGV in FSM_NextStateLogic
    moves[ROCK]     = new(SCISSORS,   PAPER);
    moves[PAPER]    = new(ROCK,       SCISSORS);
    moves[SCISSORS] = new(PAPER,      ROCK);
  end
  //-----------------------------------------
  

  ////////////////////
  //  ALU Datapath  //
  ////////////////////
  
always_ff @(posedge clk or PRIMO or SECONDO) begin: ALU_MoveValidator
    if (INIZIA)  moves_are_valid <= 1'b0;
    else begin
      moves_are_valid <= (PRIMO != INVALID) && (SECONDO != INVALID)
                        && !( (last_p1_move == PRIMO)   && (last_manche_winner == PLAYER1) )
                        && !( (last_p2_move == SECONDO) && (last_manche_winner == PLAYER2) );
    end
    // moves_are_valid will be 1 iff all conditions are met
  end
  
  always_ff @(posedge clk or moves_are_valid) begin: ALU_RoundsCounter
    if (INIZIA) begin 
      max_manches    = MIN_MANCHES + {PRIMO,SECONDO};
      manches_played = 0;
      last_p1_move   = INVALID;
      last_p2_move   = INVALID;
      played_min     = 1'b0;
      played_max     = 1'b0;
    end
    else begin
      manches_played = (manches_played + moves_are_valid); // will increase if moves_are_valid is 1
      played_min     = (manches_played >= MIN_MANCHES);
      played_max     = (manches_played >= max_manches);     // played_max will be 1 already when starting LR
      if (moves_are_valid) begin
        last_p1_move       = PRIMO;
        last_p2_move       = SECONDO;
        last_manche_winner = MANCHE;
      end
    end
  end


  ///////////
  //  FSM  //
  ///////////

  always_ff @(posedge clk or posedge INIZIA) begin: FSM_PresentStateFFs
    if (INIZIA) begin 
      current_state   <= START; // reset the FSM
    end
    else begin
      current_state <= next_state;
    end
  end

  always_comb begin: FSM_NextStateLogic
    if (moves_are_valid) begin
      case (current_state)
        START:  if      (moves[PRIMO].win_on(SECONDO))    begin next_state = P1_W1; MANCHE = PLAYER1; tmp_game_winner = NOT_ENDED; end
                else if (moves[PRIMO].lose_to(SECONDO))   begin next_state = P2_W1; MANCHE = PLAYER2; tmp_game_winner = NOT_ENDED; end
                else                                      begin next_state = START; MANCHE = NONE;    tmp_game_winner = NOT_ENDED; end
        P1_W1:  if      (moves[PRIMO].win_on(SECONDO))    begin next_state = P1_W2; MANCHE = PLAYER1; tmp_game_winner = P1_WINNER; end
                else if (moves[PRIMO].lose_to(SECONDO))   begin next_state = START; MANCHE = PLAYER2; tmp_game_winner = NOT_ENDED; end
                else                                      begin next_state = P1_W1; MANCHE = NONE;    tmp_game_winner = NOT_ENDED; end
        P2_W1:  if      (moves[SECONDO].win_on(PRIMO))    begin next_state = P2_W2; MANCHE = PLAYER2; tmp_game_winner = P2_WINNER; end
                else if (moves[SECONDO].lose_to(PRIMO))   begin next_state = START; MANCHE = PLAYER1; tmp_game_winner = NOT_ENDED; end
                else                                      begin next_state = P2_W1; MANCHE = NONE;    tmp_game_winner = NOT_ENDED; end
        P1_W2:  if      (moves[PRIMO].win_on(SECONDO))    begin next_state = START; MANCHE = PLAYER1; tmp_game_winner = P1_WINNER; end
                else if (moves[PRIMO].lose_to(SECONDO))   begin next_state = P1_W1; MANCHE = PLAYER2; tmp_game_winner = NOT_ENDED; end
                else                                      begin next_state = P1_W2; MANCHE = NONE;    tmp_game_winner = P1_WINNER; end
        P2_W2:  if      (moves[SECONDO].win_on(PRIMO))    begin next_state = START; MANCHE = PLAYER2; tmp_game_winner = P2_WINNER; end
                else if (moves[SECONDO].lose_to(PRIMO))   begin next_state = P2_W1; MANCHE = PLAYER1; tmp_game_winner = NOT_ENDED; end
                else                                      begin next_state = P2_W2; MANCHE = NONE;    tmp_game_winner = P2_WINNER; end
      endcase
    end
    else if (INIZIA) begin: rst
      next_state      = START;
      tmp_game_winner = NOT_ENDED;
      early_winner    = NOT_ENDED;
      MANCHE          = INVALID;
      PARTITA         = NOT_ENDED;
    end
    else begin: idle
      next_state = current_state; // @NOTE: bug? when reset (inizia 1) and new game it keeps last game current_state
      MANCHE     = INVALID;
      tmp_game_winner = NOT_ENDED;
    end

    if (played_min) begin
      if (early_winner) PARTITA = early_winner;
      else              PARTITA = tmp_game_winner;
    end
    else begin
      if (tmp_game_winner != NOT_ENDED && next_state == START) early_winner = tmp_game_winner;
      else PARTITA = NOT_ENDED;
    end
      
    if (played_max) begin
      case (next_state)
        P1_W2:  PARTITA = P1_WINNER;
        P1_W1:  PARTITA = P1_WINNER;
        START:  PARTITA =      DRAW;
        P2_W1:  PARTITA = P2_WINNER;
        P2_W2:  PARTITA = P2_WINNER;
      endcase
    end
    //end
  end

endmodule