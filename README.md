# 0. Project Overview

- [0. Project Overview](#0-project-overview)
- [1. Game Rules](#1-game-rules)
- [2. Project Structure](#2-project-structure)
- [3. Circuit Specifications](#3-circuit-specifications)
  - [3.1) Inputs](#31-inputs)
  - [3.2) Outputs](#32-outputs)
  - [3.3) FSM diagram](#33-fsm-diagram)
  - [3.4) Datapath](#34-datapath)
- [4. Implementation Details](#4-implementation-details)
  - [4.1) Verilog](#41-verilog)
  - [4.2) SIS](#42-sis)
- [5. Report](#5-report)

---
# 1. Game Rules

- Players: Two
- Moves: Rock, Paper, Scissors
- Winning Rules:
  - Rock beats Scissors
  - Scissors beat Paper
  - Paper beats Rock

- Tie: If both players choose the same move, the round ends in a tie.
- Minimum of 4 rounds must be played.
- Maximum of 19 rounds. The maximum is set by the initial clock cycle of the game.
- The winner is the first player to win 2 more rounds than their opponent, having played at least 4 rounds.
- In each round, the winner of the previous round cannot repeat their last move. If they do, the round is invalid and must be replayed.


---
# 2. Project Structure

```
.
├── README.md
├── report
│   ├── assets
│   │   │
│   │   └── [...]
│   ├── datapath.drawio
│   ├── FSMD.drawio
│   ├── REPORT.pdf
│   └── REPORT.tex
├── sis
│   ├── FSMD.blif
│   ├── non_ottimizzato
│   │   ├── Base
│   │   │   ├── Adder
│   │   │   │   ├── Adder_1b.blif
│   │   │   │   ├── Adder_4b.blif
│   │   │   │   └── Adder_5b.blif
│   │   │   ├── Comparators
│   │   │   │   ├── Equal_2b.blif
│   │   │   │   ├── Equal_4b.blif
│   │   │   │   ├── Equal_5b.blif
│   │   │   │   ├── Greater_5b.blif
│   │   │   │   └── GreaterEqual_5b.blif
│   │   │   ├── Constants
│   │   │   │   ├── Four_4b.blif
│   │   │   │   ├── One_1b.blif
│   │   │   │   ├── One_2b.blif
│   │   │   │   ├── Zero_1b.blif
│   │   │   │   └── Zero_2b.blif
│   │   │   ├── Gates
│   │   │   │   ├── And_2b.blif
│   │   │   │   ├── And_3b.blif
│   │   │   │   ├── Nand_2b.blif
│   │   │   │   ├── Nor_2b.blif
│   │   │   │   ├── Not_1b.blif
│   │   │   │   ├── Or_2b.blif
│   │   │   │   ├── Xnor_1b.blif
│   │   │   │   ├── Xnor_2b.blif
│   │   │   │   └── Xor_2b.blif
│   │   │   ├── Mux
│   │   │   │   ├── Mux_2i1b.blif
│   │   │   │   ├── Mux_2i2b.blif
│   │   │   │   ├── Mux_2i4b.blif
│   │   │   │   └── Mux_2i5b.blif
│   │   │   ├── Registers
│   │   │   │   ├── Register_1b.blif
│   │   │   │   ├── Register_2b.blif
│   │   │   │   ├── Register_4b.blif
│   │   │   │   ├── Register_5b.blif
│   │   │   │   ├── RegisterRST_1b.blif
│   │   │   │   └── RegisterRST_2b.blif
│   │   │   └── Utils
│   │   │       ├── InputEqualOutput.blif
│   │   │       └── NoFanout.blif
│   │   ├── Datapath.blif
│   │   ├── fsm.blif
│   │   ├── FSMD.blif
│   │   ├── fsmN.blif
│   │   ├── Modules
│   │   │   ├── CounterMatches.blif
│   │   │   ├── LastNonZero.blif
│   │   │   ├── MaxManchesCalculator.blif
│   │   │   ├── Player.blif
│   │   │   └── Players.blif
│   │   └── Utils
│   │       ├── fsmTab.blif
│   │       ├── opts
│   │       │   ├── algebraic.txt
│   │       │   ├── boolean.txt
│   │       │   ├── delay.txt
│   │       │   ├── res
│   │       │   │   ├── algebraic.txt
│   │       │   │   ├── boolean.txt
│   │       │   │   ├── delay.txt
│   │       │   │   ├── rugged.txt
│   │       │   │   └── script.txt
│   │       │   ├── rugged.txt
│   │       │   ├── script.txt
│   │       │   └── Stats.ods
│   │       ├── simulate10b.script
│   │       ├── simulate4b.script
│   │       ├── simulate8b.script
│   │       └── TestBenchSIS.sv
│   ├── output_sis.txt
│   └── testbench.script
├── utils
│   ├── bsis.sh
│   └── create_test.bash
└── verilog
    ├── design.sv
    ├── output_verilog.txt
    └── testbench.sv

22 directories, 93 files
```

---
# 3. Circuit Specifications

## 3.1) Inputs

1. **PRIMO \[2 bits\]**: Move selected by the first player.
   - 00: No move
   - 01: Rock
   - 10: Paper
   - 11: Scissors

2. **SECONDO \[2 bits\]**: Move selected by the second player.

3. **INIZIA \[1 bit\]**: When set to 1, resets the system to the initial configuration. The concatenation of PRIMO and SECONDO inputs specifies the maximum number of rounds beyond the required four.

## 3.2) Outputs

1. **MANCHE \[2 bits\]**: Result of the last played round.
   - 00: Invalid round
   - 01: Round won by Player 1
   - 10: Round won by Player 2
   - 11: Round tied

2. **PARTITA \[2 bits\]**: Result of the entire game.
   - 00: Game ongoing
   - 01: Game over, Player 1 wins
   - 10: Game over, Player 2 wins
   - 11: Game over, Tie

## 3.3) FSM diagram

[FSM diagram image](./report/REPORT.pdf#page=5)


## 3.4) Datapath

[detailed Datapath image](./report/REPORT.pdf#page=13)


---
# 4. Implementation Details

The circuit in implemented in Verilog (behavioral style) and SIS. Both Verilog and SIS implementations have inputs and outputs in the same order as mentioned above.

## 4.1) Verilog

[Verilog design choices](./report/REPORT.pdf#page=13)
[Verilog code](./verilog/design.sv)


## 4.2) SIS

[Fucking zeros and fucking ones cursed code](./sis/non_ottimizzato/)


---
# 5. Report

[have fun :)](./report/REPORT.pdf)
