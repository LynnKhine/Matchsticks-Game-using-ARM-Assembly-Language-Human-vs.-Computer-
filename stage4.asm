// Stage 4: Graphics
Main:
      BL ReadName
      BL Initialize          
      BL GameLoop           
      B Done

ReadName:
      MOV R1, #prompt_player_name
      STR R1, .WriteString
      MOV R3, #store_player_name
      STR R3, .ReadString
      RET

Initialize:
      MOV R1, #input_matchstick
      STR R1, .WriteString
InputInteger:
      LDR R0, .InputNum      
      CMP R0, #10
      BLT InputInteger
      CMP R0, #100
      BGT InputInteger
      MOV R1, #display_player_name
      STR R1, .WriteString
      STR R3, .WriteString
      MOV R1, #remaining_matchstick
      STR R1, .WriteString
      STR R0, .WriteUnsignedNum
      MOV R5, #0             // R5 = 0 for human turn, 1 for computer turn
      RET                    // Remove graphics calls for now

// Game loop function - main game logic
GameLoop:
    BL Clear           // Clear screen at start of each game loop
    BL Draw1           // Draw initial matchsticks
    CMP R5, #0
    BEQ HumanTurn
    BNE ComputerTurn

HumanTurn:
      // Display current status
      MOV R1, #player_status
      STR R1, .WriteString
      STR R3, .WriteString   
      MOV R1, #status_middle
      STR R1, .WriteString
      STR R0, .WriteUnsignedNum 
      MOV R1, #status_end
      STR R1, .WriteString
      
      // Prompt for input
      MOV R1, #player_status
      STR R1, .WriteString
      STR R3, .WriteString   
      MOV R1, #prompt_end
      STR R1, .WriteString
      
InputValidation:
      LDR R4, .InputNum      // Get player input
      CMP R4, #1             // Check if >= 1
      BLT InputValidation
      CMP R4, #7             // Check if <= 7
      BGT InputValidation
      CMP R4, R0             // Check if <= remaining matchsticks
      BGT InputValidation
      
      // Update matchsticks
      SUB R0, R0, R4         
      
      // Update graphics after human move
      BL Clear
      BL Draw1
      
      // Check game end conditions after human move
      CMP R0, #0             
      BEQ CheckDrawOrWin     
      
      // Display remaining matchsticks after human player pick
      MOV R1, #remaining
      STR R1, .WriteString
      STR R0, .WriteUnsignedNum 
      MOV R1, #newline
      STR R1, .WriteString
      
      MOV R5, #1             // Switch to computer turn
      B GameLoop             

ComputerTurn:
      MOV R1, #computer_turn
      STR R1, .WriteString
      
ComputerSelect:
      LDR R4, .Random        
      AND R4, R4, #7         
      CMP R4, #0             
      BEQ ComputerSelect     
      CMP R4, R0             
      BGT ComputerSelect     
      
      // Display computer's choice
      MOV R1, #computerpick
      STR R1, .WriteString
      STR R4, .WriteUnsignedNum 

      // Update matchsticks
      SUB R0, R0, R4         
      
      // Update graphics after computer move
      BL Clear
      BL Draw1
      
      // Check game end conditions after computer move
      CMP R0, #0             
      BEQ CheckDrawOrWin     
      
      // Display remaining matchsticks
      MOV R1, #remaining
      STR R1, .WriteString
      STR R0, .WriteUnsignedNum 
      MOV R1, #newline
      STR R1, .WriteString

      MOV R5, #0             // Switch to human player turn
      B GameLoop             

CheckDrawOrWin:
      // Check if the previous remaining count was 1 (win/lose) or >1 (draw)
      ADD R8, R0, R4         // R8 = current (0) + just picked = previous count
      CMP R8, #1             // Was there exactly 1 matchstick before this move?
      BEQ PlayerLoses        // If yes, current player loses (picked last matchstick)
      B GameDraw             // If no, it's a draw (picked multiple to reach 0)

PlayerLoses:
      CMP R5, #0             
      BEQ HumanLoses         
      B ComputerLoses        

HumanLoses:
      BL Clear               
      MOV R1, #player_status
      STR R1, .WriteString
      STR R3, .WriteString   
      MOV R1, #you_lose
      STR R1, .WriteString
      B PlayAgain

ComputerLoses:
      BL Clear               
      MOV R1, #player_status
      STR R1, .WriteString
      STR R3, .WriteString   
      MOV R1, #you_win
      STR R1, .WriteString
      B PlayAgain

GameDraw:
      BL Clear               
      MOV R1, #draw_message
      STR R1, .WriteString
      B PlayAgain

PlayAgain:
      MOV R1, #play_again_prompt
      STR R1, .WriteString
      
PlayAgainInput:
      MOV R6, #play_again_input
      STR R6, .ReadString
      LDRB R7, [R6]          // Load first character (byte)
      CMP R7, #0x79          // Check if 'y' (ASCII 0x79)
      BEQ Main               // Restart game
      CMP R7, #0x6E          // Check if 'n' (ASCII 0x6E)
      BEQ Done               
      B PlayAgainInput       

// ------------------------
// Graphics Functions
// ------------------------
Draw1:
      PUSH {LR, R7}
      MOV R7, #0
Cdraw:
      BL DrawMatchsticks
      ADD R7, R7, #1
      CMP R7, R0             
      BLT Cdraw
      POP {LR, R7}
      RET

Clear:
      PUSH {LR, R1, R2, R4}  
      MOV R2, #.PixelScreen  
      MOV R4, #0xffffff
      MOV R1, #0
removematchstick:
      STR R4, [R2,R1]        
      ADD R1, R1, #8
      CMP R1, #6400
      BLT removematchstick
      POP {LR, R1, R2, R4}   
      RET

DrawMatchsticks:
      PUSH {LR, R1, R2, R6, R9, R10, R11, R12, R8}  // Changed registers to avoid R0 conflict
      MOV R2, #.PixelScreen  // Use R2 instead of R0
      MOV R11, #.red     // Red color for matchstick tip
      MOV R12, #0xdeb887     // Wooden color for matchstick handle
      MOV R1, #0
      MOV R8, #0
      CMP R7, #32
      BGT F1
      BLT compare
F1:
      ADD R1, R1, #1792
      ADD R8, R8, #32
      CMP R7, #64
      BGT F2
      BLT compare
F2:
      ADD R1, R1, #1792
      ADD R8, R8, #32
      CMP R7, #96
      BGT F3
      BLT compare
F3:
      ADD R1, R1, #1792
      ADD R8, R8, #32
compare:
      CMP R8, R7
      BEQ displaymatchstick
      BNE add8
add8:
      ADD R1, R1, #8
      ADD R8, R8, #1
      B compare
displaymatchstick:
      ADD R6, R1, #256       // Use R6 instead of R2
      ADD R9, R6, #256       // Use R9 instead of R3
      ADD R10, R9, #256      // Use R10 instead of R4
      STR R11, [R2, R1]      // First pixel (red tip)
      STR R12, [R2, R6]      // Second pixel (wooden handle)
      STR R12, [R2, R9]      // Third pixel (wooden handle)
      POP {LR, R1, R2, R6, R9, R10, R11, R12, R8}
      RET

Done:
      HALT

// ---------
//text output
// ---------
prompt_player_name: .ASCIZ "\nWelcome!\nPlease enter your name: "
store_player_name: .block 128 // Space for player name (up to 128 chars)
input_matchstick: .ASCIZ "\nHow many matchsticks (10-100) to start with?"
display_player_name: .ASCIZ "\n\nPlayer 1 is "
remaining_matchstick: .ASCIZ "\nMatchsticks: "
player_status: .ASCIZ "\nPlayer "
status_middle: .ASCIZ ", there are "
status_end: .ASCIZ " matchsticks remaining"
prompt_end: .ASCIZ ", how many do you want to remove (1-7)?"
computer_turn: .ASCIZ "\nComputer Player's turn"
you_win: .ASCIZ ", YOU WIN!"
you_lose: .ASCIZ ", YOU LOSE!"
draw_message: .ASCIZ "\nIt's a draw!"
play_again_prompt: .ASCIZ "\nPlay again (y/n) ?"
play_again_input: .block 8 // Space for y/n input
computerpick: .ASCIZ "\nComputer Pick: "
remaining: .ASCIZ "\nMatchstick(s) remaining: "
newline: .ASCIZ "\n"