ORG 0H            
LJMP  MAIN 
STRING1:  DB "test string one" ;; string data 
DB 0  ;; Null termination 
STRING1_L: DB 15
STRING2:  DB "test string two" ;; string data 
DB 0  ;; Null termination  
STRING2_L:  DB  15

STRCPY: 
;; the function copies from source (DPTR points to the source address) to destination(R0 points to the destination address): 
;; Load each character from source string's memory. 
;; Q: Which memory? MOV? MOVX? MOVC?  
;; Check to make sure it is not the null character  
;; If it is null, return the len in A; otherwise, increment count and save the character to the corresponding RAM location. 
;; The caller expects return value in accumulator A  
;; This function may safely use R1 without saving  

PUSH DPH
PUSH DPL
PUSH 00
PUSH 01

MOV R1, #0
NEXTCHAR:
INC R1
MOV A , #0
MOVC A, @A + DPTR 
MOV @R0, A

INC DPTR
INC R0

JNZ NEXTCHAR

MOV A, R1
DEC A

POP 01
POP 00
POP DPL
POP DPH

RET

STRCONCAT: 
PUSH 00
PUSH DPL
PUSH DPH
PUSH 01

;; Load the address of STRING1 to DPTR
MOV DPTR, #STRING1  
Call STRCPY 
;; Load the address of STRING2 to DPTR 
MOV DPTR, #STRING2
MOV R1, A
ADD A , R0
MOV R0, A 
Call STRCPY
ADD A, R1

POP 01
POP DPH
POP DPL
POP 00

RET

TESTSTRING: 
;; The purpose is to call STRCONCAT, fetch the answer 
;; and check whether it works right 
;; If the length is different from the expected length 
;; then jump to ERROR. 
;; Else Compare the copied data with the string1 and then string 2 
;; If one character does not match 
;; then jump to ERROR.  
;;else jump to SUCCESS  

MOV A, #0
MOV DPTR, #STRING1_L
MOVC A, @A+DPTR
MOV R7, A

MOV A, #0
MOV DPTR, #STRING2_L
MOVC A, @A+DPTR
ADD A, R7
MOV R7, A

CALL STRCONCAT

CJNE A, 07, ERROR

MOV DPTR, #STRING1
CHECKLOOP_STR1:
MOV A, #0
MOVC A, @A+DPTR
JZ FINISHED1

MOV R6, A ;char from string 1
MOV A, @R0 ;char from output

CJNE A, 06, ERROR
INC DPTR
INC R0
SJMP CHECKLOOP_STR1

FINISHED1:

MOV DPTR, #STRING2
CHECKLOOP_STR2:
MOV A, #0
MOVC A, @A+DPTR
JZ FINISHED2

MOV R6, A ;char from string 2
MOV A, @R0

CJNE A, 06, ERROR
INC DPTR
INC R0
SJMP CHECKLOOP_STR2

FINISHED2:
MOV A, @R0
JNZ ERROR

RET
MAIN: 
;Assign #60h to R0 
MOV R0, #60H
LCALL TESTSTRING

;; Call TESTSTRING 
SUCCESS: SJMP SUCCESS 
ERROR: SJMP ERROR  
END


