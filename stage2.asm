// Stage 2: Single Player Input
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

// Initialize function - handles matchstick input and validation
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
      RET                    


GameLoop:
      CMP R0, #0             // Check if matchsticks are gone
      BEQ GameOver           // If zero, game over
      
      // Display current status
      MOV R1, #player_status
      STR R1, .WriteString
      STR R3, .WriteString   
      MOV R1, #status_middle
      STR R1, .WriteString
      STR R0, .WriteUnsignedNum 
      MOV R1, #status_end
      STR R1, .WriteString
      
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
      SUB R0, R0, R4         // Subtract removed matchsticks
      B GameLoop             // Continue game loop

GameOver:
      MOV R1, #game_over
      STR R1, .WriteString
      RET

Done:
      HALT

// ---------
//text output
// ---------
prompt_player_name: .ASCIZ "Welcome!\nPlease enter your name: "
store_player_name: .block 128 // Space for player name (up to 128 chars)
input_matchstick: .ASCIZ "\nHow many matchsticks (10-100) to start with?"
display_player_name: .ASCIZ "\n\nPlayer 1 is "
remaining_matchstick: .ASCIZ "\nMatchsticks: "
player_status: .ASCIZ "\nPlayer "
status_middle: .ASCIZ ", there are "
status_end: .ASCIZ " matchsticks remaining"
prompt_end: .ASCIZ ", how many do you want to remove (1-7)?"
game_over: .ASCIZ "\nGame Over"