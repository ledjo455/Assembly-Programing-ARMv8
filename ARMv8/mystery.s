.include "includeConstantsARM64.inc"

.data
menu:   .asciz "If you want Encryption insert 1 for Decryption insert 2:  " 
screen:   .asciz "Enter a mystery text: "
inputKey: .asciz "Enter shift key: "
firstoutput:   .asciz "The encrypted text: "
secondoutput:  .asciz "The decrypted text: "
error:  .asciz "* ERROR * Please choose from 1-25. \n"
error2:  .asciz "* ERROR * Please choose either 1 or 2 from menus \n"
.equ BUFFERSIZE, 210
.bss
messageBuffer: .skip BUFFERSIZE
firstkey:           .skip BUFFERSIZE
choice:        .skip 2

.text
.global main
main:
    LDR x0,=screen                       // print screen                   
    BL printMess
    
    MOV x0, STDIN                        // Linux input console
    LDR x1, =messageBuffer               // buffer address
    MOV X2, BUFFERSIZE                   // buffer size
    MOV X8, READ                         // request to read message
    SVC #0                               // call system
    LDR X1, =messageBuffer     
    MOV X2, #0               
    STRB W2, [X1,X0]                     // store null byte at the end of input string
    
    LDR x0, =inputKey
    BL  printMess   
   
    MOV x0, STDIN                          // Linux input console     
    LDR x1, =firstkey                     // buffer address
    MOV X2, BUFFERSIZE                   // buffer size
    MOV X8, READ                        // request to read key
    SVC #0                             // call system

    /* Checking the first key */
    LDR X0,=firstkey                 //load to register X0
    BL conversionAtoD               //convert to decimal using the function from rosettacode
    MOV X21, X0                    //move to register X21
    CMP X21, 26                   // Compare the first key to 26
    B.GE errorkey                // if it is greater than or equal to 26 go to errorkey
    CMP X21, 0                  // compare to 0
    B.LE errorkey              //if it is less than 0 or equal to 0 go to errorkey              
    
    /* after validating input, prints to the user the menu */
    LDR x0,=menu                       // print menu                  
    BL printMess
	
    MOV x0, STDIN                       // Linux input console     
    LDR x1, =choice                     // buffer address
    MOV X2, 2                           // buffer size
    MOV X8, READ                        // request to read user choice
    SVC #0                              // call system
	
    /* after the user inputs a number (choice) we check if it is correct*/
    
        LDR X0,=choice                      //load the choice input to register X0
        BL conversionAtoD                  //convert to decimal
        MOV X22, X0                       //move to register X22
        CMP X22, 3                       //compare the number(choice) with 3
        B.GE errorchoice                // if it is greater than or equal to 3 go to errorchoice
        CMP X22, 0                     //compare the number(choice) to 0
        B.LE errorchoice              //if it is less than or equal to 0 go to errorchoice
        CMP X22, 1                   //compare the number to 1
        B.EQ Encryption             //if the number(choice) is equal to 1 go to encryption
        CMP X22, 2                 //compare to 2
        B.EQ Decryption           //if number(choice) is equal to 2 go to Decryption
        B Exit                   //exit   
    
    
	/* Performs the encryption of a text given the shift key */
Encryption:
    
    
         LDR X0,=firstkey                     // store the first key to register X0
         BL conversionAtoD                   //convert to decimal using the function 
         MOV X24, X0                        //copy register X0 (firstkey) to register X24
         LDR x1, =messageBuffer            // get starting address of message in X1
     
 firstloop:
         LDRB w2, [X1]                         // gets the first char
         CMP  w2,0                            // compare to 0
         B.EQ exitloop                       // if it is zero go to exitloop
	 CMP  w2, 'a'                        // compare the first letter to 'a'
	 B.LT secondloop                     //if it is larger than a go to secondloop
	 CMP  w2, 'z'                      // compare to 'z'
	 B.GT secondloop                   // if it is greater than go to secondloop  
	 
	  
         ADD  X2,X2,X24                     // add the key to the letter
	 CMP  X2, 'z'                       // compare the result with z
	 B.LE firstiterate                  // if it is less than or equal to z go to firstiterate      
	 SUB  X2,X2,'z'                    //  letter = letter - 'z' 
	 ADD  X2,X2,'a'                   //letter= letter + 'a' 
	 SUB  X2,X2, 1                   // letter = letter - 1
	 B firstiterate                         // go to firstiterate
	 
 secondloop:	                              
        CMP  w2, 'A'                         // compare letter(char value) to 'A'
	 B.LT firstiterate                   //if larger than or equal to 'A' value go to firstiterate 
	 CMP  w2, 'Z'                       // compare it to Z value
	 B.GT firstiterate                 // goes to firstiterate if it is greater than Z value
	 
         ADD  X2,X2,X24                         // letter = letter + shiftingkey
	 CMP  X2, 'Z'                          // compare the result with Z
	 B.LE firstiterate                    // if it is less than or equal to Z go to firstiterate
	 SUB  X2,X2,'Z'                      //  letter = letter - 'Z' 
	 ADD  X2,X2,'A'                     //   letter = letter + 'A'
	 SUB  X2,X2, 1			    //    letter = letter - 1
	 B firstiterate		   //	   go to firstiterate	
	 
 firstiterate:
        STRB w2,[x1]                        // store 
        ADD  x1,x1,1                       // j = j+1
        B firstloop                       // branch to firstloop
	 
 exitloop:  
       LDR x0, =firstoutput                      // X0=firstoutput text
       BL  printMess                            // print the text using printMess function
       LDR x0, =messageBuffer                  // get the encrypted message
       BL  printMess                          // print the encrypted message
       B Exit                                // go to exit

/* Performs the decryption of a text given the shift key */

Decryption:
    
      LDR x0,=firstkey                         // get key value in x0
      BL conversionAtoD    
      MOV X24, X0  
      LDR x1, =messageBuffer             // get starting address of message in x1
     
     
 thirdloop:
      LDRB w2, [x1]                           // get first letter
      CMP  w2,0                              // compare its value to 0
      B.EQ exitthirdloop                    // if it is equal to zero then go to exitthirdloop
      CMP  w2, 'a'                         // compare letter with 'a'
      B.LT fourthloop                     // if it is less than 'a' go to fourthloop
      CMP  w2, 'z'                       // compare to 'z'
      B.GT fourthloop                   // if it is greater than go to fourthloop
      SUB  X2,X2,X24                   // letter = letter - shiftingkey
      CMP  X2, 'a'                    //compare to 'a'
      B.GE seconditerate             // if it is greater than or equal go to seconditerate 
      ADD  X2,X2,'z'                // then letter = letter + 'z'
      SUB  X2,X2,'a'               // letter = letter - 'a'
      ADD  X2,X2, 1               // letter = letter + 1
      B seconditerate                    // go to seconditerate 

 fourthloop:                                   
      CMP  w2, 'A'                         // compare letter with 'A' char value
      B.LT seconditerate                  // if it is less than A go to seconditerate
      CMP  w2, 'Z'                        //  compare to Z
      B.GT seconditerate                 // if it is greater than go to seconditerate
      
      SUB  X2,X2,X24                      // letter = letter - shiftkey
      CMP  X2, 'A'                       // compare letter to 'A' 
      B.GE seconditerate                // go to skip 1 if greater than or equal to A
      ADD  X2,X2,'Z'                   // then letter = letter + 'Z' 
      SUB  X2,X2,'A'                  // letter = letter - 'A'
      ADD  X2,X2, 1                  // letter = letter + 1
      B seconditerate                       // branch to seconditerate

 seconditerate:
     STRB w2,[x1]                         // store register byte
     ADD  x1,x1,1                        // j = j+1
     B thirdloop                        // branch to thirdloop

 exitthirdloop:  
    LDR x0, =secondoutput               // X0 = secondoutput text
    BL  printMess                      // print using the function
    LDR x0, =messageBuffer            // print the message
    BL  printMess                    // using the function printMess 


Exit:

    MOV X0, #0                          // return 0 from main()
    MOV X8, EXIT                        // X8= exit system call
    SVC #0                              // do the system call
    
errorkey:
    LDR x0, =error                      // print output text
    BL  printMess    
    B main                             // repeat
errorchoice:
    LDR x0, =error2                      // print output text
    BL  printMess    
    B main                              // repeat  
        
.include "includeARM64.inc"
