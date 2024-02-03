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
  // FSM states
  localparam  P1_W2    = 3'b000,
              P1_W1    = 3'b001,
              TIE      = 3'b011,
              P2_W1    = 3'b010,
              P2_W2    = 3'b110;
  // Moves
  localparam  ROCK     = 2'b01,
              PAPER    = 2'b11,
              SCISSORS = 2'b10;
  // Combinations       move       win_on               lose_to           
  localparam  moves = { ROCK:     {"win_on": SCISSORS,  "lose_to": PAPER},
                        PAPER:    {"win_on": ROCK,      "lose_to": SCISSORS},
                        SCISSORS: {"win_on": PAPER,     "lose_to": ROCK}
                      };
  
  //---------- Internal Registers ----------
  reg [4:0] rounds_to_play;
  reg [4:0] rounds_played;
  reg [2:0] current_state, next_state;

  ////////////////////
  //  ALU Datapath  //
  ////////////////////  

  // [...]


  ///////////
  //  FSM  //
  ///////////

  // @TO-DO: change clk to trigger_fsm event?
  always @(posedge clk or negedge INIZIA) begin: FSM_PresentStateFFs 
    // ---- rst signal ----
    if (INIZIA) current_state <= TIE;         // reset the FSM
    else        current_state <= next_state;    
  end

  always @(current_state or PRIMO or SECONDO) begin: FSM_NextStateLogic
    next_state = 3'bx; // go unknown if not all state transitions have been explicitly assigned below
    // [...] output logic

    case (current_state)
      TIE:    moves[PRIMO]["win_on"] == SECONDO ? next_state = P1_W1 : 
              moves[PRIMO]["lose_to"] == SECONDO ? next_state = P2_W1 : 
              next_state = TIE;
      P1_W1:  moves[PRIMO]["win_on"] == SECONDO ? next_state = P1_W2 :
              moves[PRIMO]["lose_to"] == SECONDO ? next_state = TIE : 
              next_state = P1_W1; 
      P1_W2:  next_state = TIE;
      P2_W1:  moves[SECONDO]["win_on"] == PRIMO ? next_state = P2_W2 :
              moves[SECONDO]["lose_to"] == PRIMO ? next_state = TIE : 
              next_state = P2_W1;
      P2_W2:  next_state = TIE;
      default: next_state = TIE;
    endcase
  end



endmodule