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
);

  //---------- Internal Constants ----------
  localparam int MINROUNDS = 4;
  // FSM states (one-hot encoding)
  parameter   P1_W2    = 5'b00001,
              P1_W1    = 5'b00010,
              TIE      = 5'b00100,
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

  localparam  ROCK     = 2'b01,
              PAPER    = 2'b11,
              SCISSORS = 2'b10;

  // Combinations       move          win_on      lose_to           
  localparam  moves = { ROCK:     new(SCISSORS,   PAPER),
                        PAPER:    new(ROCK,       SCISSORS),
                        SCISSORS: new(PAPER,      ROCK)
                      };
  
  //---------- Internal Registers ----------
  reg [4:0] rounds_to_play;
  reg [4:0] rounds_played;
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
    if (INIZIA) current_state <= TIE;         // reset the FSM
    else        current_state <= next_state;    
  end

  always @(current_state or PRIMO or SECONDO) begin: FSM_NextStateLogic
  //always @(posedge clk) begin: Datapath
  //  // ---- rst signal ----
  //  if (INIZIA) begin
  //    current_state <= TIE;               // reset the FSM
  //    rounds_to_play <= {PRIMO,SECONDO};  // set the n. of rounds to play
  //  end
//
  //  // [...]
  //  if ((PRIMO || SECOND 2'b00) begin
  //    rounds_to_play <= rounds_to_play;
  //  end
  //  else begin
  //    rounds_to_play <= rounds_to_play + 1;
  //  end
  //end
    next_state = 5'bx; // go unknown if not all state transitions have been explicitly assigned below
    // [...] output logic

    case (current_state)
    TIE:    if      (moves[PRIMO].win_on(SECONDO))    next_state = P1_W1;
            else if (moves[PRIMO].lose_to(SECONDO))   next_state = P2_W1;
            else                                      next_state = TIE;
    P1_W1:  if      (moves[PRIMO].win_on(SECONDO))    next_state = P1_W2;
            else if (moves[PRIMO].lose_to(SECONDO))   next_state = TIE;
            else                                      next_state = P1_W1;
    P2_W1:  if      (moves[SECONDO].win_on(PRIMO))    next_state = P2_W2;
            else if (moves[SECONDO].lose_to(PRIMO))   next_state = TIE;
            else                                      next_state = P2_W1;
    P1_W2:  if      (moves[PRIMO].win_on(SECONDO))    next_state = TIE;
            else if (moves[PRIMO].lose_to(SECONDO))   next_state = P1_W1;
            else                                      next_state = P1_W2;
    P2_W2:  if      (moves[SECONDO].win_on(PRIMO))    next_state = TIE;
            else if (moves[SECONDO].lose_to(PRIMO))   next_state = P2_W1;
            else                                      next_state = P2_W2;
    endcase
  end



endmodule