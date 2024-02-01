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
  - [5.1) Overview](#51-overview)
  - [5.2) Pre-optimization](#52-pre-optimization)
  - [5.3) Post-optimization](#53-post-optimization)
  - [5.4) Technology Mapping](#54-technology-mapping)
- [6. Notes](#6-notes)
  - [6.1) Design choices](#61-design-choices)
- [7. TO-DO](#7-to-do)


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
├── ELABORATO_SIS_2024.pdf             : Linee guida del progetto
├── images
│   ├── rock-paper-scissors.jpg
│   ├── RPS101.jpeg
│   ├── rps9.jpg
│   └── RPSLS.jpg
├── README.md
├── sis
│   ├── FSMD.blif                      : simulazione macchina a stati (pre mapping tecnologico)
│   ├── fsmSW_synch.blif               : simulazione macchina a stati (post mapping tecnologico)
│   ├── main.blif
│   ├── non_ottimizzato/               : sorgenti .blif del circuito non ottimizzati
│   │   ├──
│   │   └──
│   ├── output_sis.txt                 : output di testbench.sv
│   └── testbench.script               : file .script generato da testbench.sv 
└── verilog
    ├── design.sv                      : File principale del modello Verilog
    ├── output_verilog.txt             : output di testbench.sv
    └── testbench.sv                   : File principale del testbench
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

![FSM diagram image](FSM.svg)


## 3.4) Datapath

[...]


---
# 4. Implementation Details

The circuit in implemented in Verilog (behavioral style) and SIS. Both Verilog and SIS implementations have inputs and outputs in the same order as mentioned above.

## 4.1) Verilog

[...]

## 4.2) SIS

[...]


---
# 5. Report

## 5.1) Overview
   - Relazione.pdf
     - A4 format
     - Include student IDs, names, and surnames
     - Cover the specified points:
       - General circuit architecture (FSMD schema)
       - Controller state diagram
       - Datapath architecture
       - Circuit statistics pre and post optimization for area
       - Number of gates and delay obtained by mapping onto synch.genlib library
       - Explanation of design choices

## 5.2) Pre-optimization

[...]

## 5.3) Post-optimization

[...]

## 5.4) Technology Mapping

[...]


---
# 6. Notes

## 6.1) Design choices
> **Difficoltà 1**:  
> Identificazione segnali di controllo che vengono prodotti dalla FSM e che pilotano la selezione dei dati nel DataPath.

**Soluzione**: [...]

> **Difficoltà 2**:  
> Generazione da parte del DataPath di quei segnali di condizione che vincolano l'evoluzione tra gli stati della FSM

**Soluzione**: [...]

> **Design Choice 1**:   
> XNOR module or CMP module for comparisons (i.e. `manches>=4`, `manches<=19`, ...)

[...]

> **Design Choice 2**:   
> Which code styleguide for Verilog?

[lowRISC Verilog Coding Style](https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md)

> **Design Choice 3**:
> What bit encoding to use for FSM states / Moves?

Grey code. why? idk. TBD (To Be Discovered): https://www.allaboutcircuits.com/technical-articles/encoding-the-states-of-a-finite-state-machine-vhdl/

---
# 7. TO-DO

- [X] FSM
  - [X] Finite State Machine diagram using [Tikz on LaTeX](https://tikz.dev/library-automata)
  - [X] Use 5 states instead of 6 by removing the START state 
  - [ ] Fix input/output bits in table
  - [ ] how to manipulate idle? 
- [ ] Datapath using [draw.io](https://draw.io)
  - [ ] write bit size on each wire, registry, I/O, ...
  - [ ] fix constants invisible wire 
  - [ ] add names to registers
  - [ ] make one big datapath module
  - [ ] do the arrows nodes better
- [ ] Verilog implementation
  - [ ] Design structure
- [ ] SIS implementation
  - [ ] Module Players
  - [ ] Module datapath
- [ ] Testbench
- [ ] Pre-optimization statistics
- [ ] Post-optimization statistics
- [ ] Technology Mapping
- [ ] Complete the README.md file
- [ ] Write the report (LaTEX)
- [ ] Release


