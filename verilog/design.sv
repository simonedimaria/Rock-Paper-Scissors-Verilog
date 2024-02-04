//-----------------------------------------------------
// FSMD implementation of the Morra Cinese in Verilog
// Module Name : MorraCinese
// File Name   : design.sv
//-----------------------------------------------------

module MorraCinese (
  input wire clk,
  input wire [1:0] PRIMO,   // Player 1 move
  input wire [1:0] SECONDO, // Player 2 move
  input wire INIZIA,        // Restart the game
  output reg [1:0] MANCHE,  // Result of the last round
  output reg [1:0] PARTITA, // Result of the entire game
  //output reg [4:0] current_state, next_state
);

  //---------- Internal Constants ----------
  localparam int MINROUNDS = 4;
  localparam  INVALID = 2'b00,
              PLAYER1 = 2'b01,
              PLAYER2 = 2'b10,
              TIE     = 2'b11;
  localparam  NOT_ENDED = 2'b00,
              P1_WINNER = 2'b01,
              P2_WINNER = 2'b10,
              NO_WINNER = 2'b11;
              
  // FSM states (one-hot encoding)
  parameter   P1_W2    = 5'b00001,
              P1_W1    = 5'b00010,
              DRAW     = 5'b00100, // @TO-DO: rename to start
              P2_W1    = 5'b01000,
              P2_W2    = 5'b10000;
  // Moves
  class Move;
    bit [1:0] strong_to;
    bit [1:0] weak_to;
    function new(bit [1:0] _strong_to, bit [1:0] _weak_to);
      strong_to = _strong_to;
      weak_to  = _weak_to;
    endfunction
    function win_on(bit [1:0] move);
      return (move == strong_to);
    endfunction
    function lose_to(bit [1:0] move);
      return (move == weak_to);
    endfunction
  endclass

  //localparam  bit ROCK     = 2'b01,
  //            PAPER    = 2'b11,
  //            SCISSORS = 2'b10;

  typedef enum bit [1:0] {
    ROCK      = 2'b01,
    PAPER     = 2'b11,
    SCISSORS  = 2'b10
  } move_id;

  Move moves [move_id];
  
  initial begin
    moves[ROCK]     = new(SCISSORS,   PAPER);
    moves[PAPER]    = new(ROCK,       SCISSORS);
    moves[SCISSORS] = new(PAPER,      ROCK);
  end
  
  //---------- Internal Registers ----------
  reg [4:0] rounds_to_play;
  reg [4:0] rounds_played;
  reg MOVE_NOT_VALID;
  reg [4:0] current_state, next_state;

  ////////////////////
  //  ALU Datapath  //
  ////////////////////  



  ///////////
  //  FSM  //
  ///////////

  // @TO-DO: is posedge INIZIA needed?
  always @(posedge clk or posedge INIZIA) begin: FSM_PresentStateFFs 
    // ---- rst signal ----
    if (INIZIA) current_state <= DRAW;         // reset the FSM
    else        current_state <= next_state;    
  end

  always @(current_state or PRIMO or SECONDO) begin: FSM_NextStateLogic
    next_state = 5'bx; // go unknown if not all state transitions have been explicitly assigned below
    if (MOVE_NOT_VALID) begin // exit early
    end

    else begin;
      case (current_state)
        DRAW:   if      (moves[PRIMO].win_on(SECONDO))    begin next_state = P1_W1;  MANCHE = PLAYER1;  PARTITA = NOT_ENDED; end
                else if (moves[PRIMO].lose_to(SECONDO))   begin next_state = P2_W1;  MANCHE = PLAYER2;  PARTITA = NOT_ENDED; end
                else                                      begin next_state = DRAW;   MANCHE = TIE;      PARTITA = NOT_ENDED; end
        P1_W1:  if      (moves[PRIMO].win_on(SECONDO))    begin next_state = P1_W2;  MANCHE = PLAYER1;  PARTITA = P1_WINNER; end    
                else if (moves[PRIMO].lose_to(SECONDO))   begin next_state = DRAW;   MANCHE = PLAYER2;  PARTITA = NOT_ENDED; end  
                else                                      begin next_state = P1_W1;  MANCHE = TIE;      PARTITA = NOT_ENDED; end  
        P2_W1:  if      (moves[SECONDO].win_on(PRIMO))    begin next_state = P2_W2;  MANCHE = PLAYER2;  PARTITA = P2_WINNER; end
                else if (moves[SECONDO].lose_to(PRIMO))   begin next_state = DRAW;   MANCHE = PLAYER1;  PARTITA = NOT_ENDED; end
                else                                      begin next_state = P2_W1;  MANCHE = TIE;      PARTITA = NOT_ENDED; end
        P1_W2:  if      (moves[PRIMO].win_on(SECONDO))    begin next_state = DRAW;   MANCHE = PLAYER1;  PARTITA = P1_WINNER; end
                else if (moves[PRIMO].lose_to(SECONDO))   begin next_state = P1_W1;  MANCHE = PLAYER2;  PARTITA = NOT_ENDED; end
                else                                      begin next_state = P1_W2;  MANCHE = TIE;      PARTITA = P1_WINNER; end
        P2_W2:  if      (moves[SECONDO].win_on(PRIMO))    begin next_state = DRAW;   MANCHE = PLAYER2;  PARTITA = P2_WINNER; end
                else if (moves[SECONDO].lose_to(PRIMO))   begin next_state = P2_W1;  MANCHE = PLAYER1;  PARTITA = NOT_ENDED; end
                else                                      begin next_state = P2_W2;  MANCHE = TIE;      PARTITA = P2_WINNER; end
      endcase
    end
  end



endmodule