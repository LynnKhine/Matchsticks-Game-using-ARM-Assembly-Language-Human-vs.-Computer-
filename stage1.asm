// Stage 1: Game Setup
Main:
      BL ReadName
      BL Initialize          
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
      RET                    // Return to caller

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