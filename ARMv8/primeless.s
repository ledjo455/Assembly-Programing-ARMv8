 .include "includeConstantsARM64.inc"
.data
first:       .asciz "Please, enter the number you want to find prime less than: "
output1:      .asciz "Prime numbers smaller than your number are: "
output2:     .asciz "Error, check input and try again"
newline:      .asciz " \n"
format:      .asciz " "
aster:       .asciz "***************************************************************\n"
 
.equ BUFFERSIZE, 210

.bss
conversionBuffer: .skip 17
inputBuffer: .skip BUFFERSIZE

.text
.global main 
main:
     
    LDR x0,=first
    BL printMess
    MOV x0, STDIN           // Linux input console
    LDR x1, =inputBuffer    // buffer address 
    MOV X2, BUFFERSIZE      // buffer size 
    MOV X8, READ            // request to read datas
    SVC #0                  // call system
    LDR X1, =inputBuffer    // input buffer address 
    MOV X2, #0              // 
    STRB w1, [X1,X0]        // store null byte at the end of input string
                	 
    	/* Get Input */               
    
    LDR X0, =inputBuffer    // input buffer address passed as argument
    BL conversionAtoD       // conversion string in number in x0
    MOV X21, X0             // keep converted number in X21
	 
      /* Check Input */

	CMP X21,0               // if input <= 0 
	B.LE Error              // then goto Error
	LDR x0,=output1         // if not (else) print output1
        BL printMess
	BL testP               // call testP(input)
        LDR X0, =newline      //print a new line
        BL printMess 
        B Exit               //exit
        
     /* Error Message and call to main to reask for input */

Error: 
      LDR x0,=output2        // print output2
      BL printMess
      LDR X0, =newline      //print a new line
      BL printMess  
      LDR X0, =aster       //print asterisks
      BL printMess     
      B main    //go to main 
    /* EXIT */

Exit:	
	
      MOV X0, #0               // return 0 from main()
      MOV X8, EXIT             // select system call 'exit'
      SVC #0                   // perform the system call 
    
    /* checks for prime and prints numbers */
	
testP:
      MOV X28, X30
      MOV x18, #2              // j = 2
    
    /* first while loop */
firstwhile:
      CMP x18, X21             // While(j < input)
      B.GE exitfirstwhile
      MOV X2, 2                // i = 2
      MOV X3, 1                // y = 1
	/* second while loop */
secondwhile: 
      CMP X2, x18              // While( i< j)
      B.GE exitsecondwhile	
      UDIV X4, x18, X2         // j % i
      MUL  X4, X4, X2
      SUB  X5, x18, X4         // X5 = j % i
      CMP  X5, 0               // if j % i == 0
      B.NE iplusplus       
      MOV  X3, #0              // then y = 0;
iplusplus:
      ADD X2, X2, 1            // i++
      B secondwhile
exitsecondwhile:	
      CMP X3, 1               // if y == 1
      B.NE jplusplus
      MOV X0, x18                // first argument to conversion10
      LDR X1, =conversionBuffer  // second argument (by reference) to conversion10
      BL conversion10            // make the procedure call
	  
      LDR X0, =conversionBuffer
      BL printMess                // print j
      LDR x0,=format         //divide using space
      BL printMess
  
jplusplus:
      ADD x18, x18, 1             // j++
      B firstwhile
exitfirstwhile:	
      MOV X30, X28
      BR LR

.include "includeARM64.inc"
