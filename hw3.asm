; hw2.asm
; Author: Sunil Jain
; Course/ Project ID: CS271 -Homework 3
; Date: 
; Description: 

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode : dword

; insert constant definitions here

     MAX_STR             = 80           ; maximum chars to read to name
     MIN_BOUND           = 1            ; minimum boundary
     MAX_BOUND           = 400         ; maximum boundary

.data

; insert variable definitions here

	intro_msg           Byte      0ah, 0Dh, "CS 271 HW 3 - Composites     Programmed by Sunil Jain", 0ah, 0Dh, 0
     desc_msg            Byte      0ah, 0Dh, "Enter the number of composite numbers you would like to see.", 0ah, 0Dh, "I'll accept orders for up to 400 composites.", 0ah, 0Dh, 0

     composite_request   Byte      0ah, 0Dh, "Enter the number of composites to display [1 .. 400]: ", 0
     repeat_request      Byte      0ah, 0Dh, "Would you like to go again (Yes=1/No=0): ", 0

     bound_error         Byte      "Out of range. Try again.", 0

     bye_msg             Byte      "Results certified by Sunil Jain.   Goodbye.", 0
     
     spaces              Byte      "     ", 0
     extra_space         Byte      " ", 0

     composite_input     DWORD     MAX_STR+1 DUP(?)

     index               DWORD     MAX_STR+1 DUP(?)
     composite_counter   DWORD     0
     factor_counter      DWORD     0
     spacing_counter     DWORD     0

.code


main proc

; insert executable instructions here

     Call                introduction

     again:

     Call                getUserData
     Call                showComposites

;              resets all counters for replayability
     mov                 composite_counter, 0
     mov                 factor_counter, 0
     mov                 spacing_counter, 0

     Call                goAgain                       ;    this returns either 0 Or 1 in eax based on the player's will

     cmp                 eax, 1
     je                  again                         ;    if the player chose 1, go again

     Call                farewell

     invoke ExitProcess,0

main                     endp

     ; insert additional procedures here

; Procedure: Prints the introduction and descriptions statements
; recieves: N/A
; returns: N/A
; preconditions: N/A
; registers changed: edx
introduction             PROC

;              print introduction And description messages
     mov                 edx, OFFSET intro_msg
	Call                WriteString
     mov                 edx, OFFSET desc_msg
	Call                WriteString

     ret
introduction             ENDP

; Procedure: prompts for the user data, gets the data, and calls for a check for the data
; recieves: n/a
; returns: composite_input
; preconditions: n/a
; registers changed: edx, eax
getUserData              PROC

;              prompt for the number of composites the user wants to see
     mov		          edx, OFFSET composite_request
	Call                WriteString

;              get the user input
     Call                ReadInt
     mov                 composite_input, eax

     Call                validate

     ret
getUserData              ENDP

; Procedure: 
; recieves: n/a
; returns: correct composite_input within 1-400
; preconditions: attempted to get an input for composite_input
; registers changed: eax, edx
validate                 PROC

;              checks if within bounds
     mov                 eax, composite_input

     cmp                 eax, MAX_BOUND
     jg                  validate_error

     cmp                 eax, MIN_BOUND
     jl                  validate_error

     ret

     validate_error:

;              if not in bounds then reprompt
     mov		          edx, OFFSET bound_error
	Call                WriteString
     Call                getUserData

     ret
validate                 ENDP

; Procedure: displays composite_input amount of composite numbers
; recieves: n/a
; returns: n/a
; preconditions: composite_input is found
; registers changed: ecx, eax, edx
showComposites           PROC

     Call                Crlf
     
;              setting up loop
     mov                 ecx, composite_input
     mov                 index, 1

     composite_loop:

;              checks if the index is a composite number
     Call                isComposite

     mov                 ecx, factor_counter
;              if it is a prime number then do not print it out and increment appropriate counters
     cmp                 ecx, 2
     je                  prime_num
     cmp                 ecx, 1
     je                  prime_num

     inc                 composite_counter
     inc                 spacing_counter

     mov                 eax, index
     call                WriteInt

;              correcting spacing for single digit numbers so there is no offset in the output by adding an extra space
     cmp                 eax, 10
     jge                 no_extra_space

     mov                 edx, OFFSET extra_space
     Call                WriteString

     no_extra_space:

;              every 10 numbers, add a new line: if spacing_counter is 10, add a new line, if not then add a new space
     mov                 eax, spacing_counter
     cmp                 eax, 10
     jl                  skip_new_line

     Call                Crlf
     mov                 spacing_counter, 0
     jmp                 prime_num                     ;    skip writing a new space if we are adding a new line

     skip_new_line:

     mov                 edx, OFFSET spaces
     Call                WriteString

;              skip here if the number is prime

     prime_num:

;              try the next number in the next loop
     inc                 index

;              for (int index = 1; composite_counter <= composite_input; index++)
     mov                 eax, composite_counter
     cmp                 eax, composite_input
     jl                  composite_loop

     ret
showComposites           ENDP

; Procedure: determines if a number is a composite for the showComposites to display
; recieves: n/a
; returns: factor_counter
; preconditions: index is reset at the start of program
; registers changed: ecx, eax, edx
isComposite              PROC

;              reset appropriate values and use the loop functionality to check if the index is a composite number
     mov                 factor_counter, 0
     mov                 ecx, index

     factor_loop:

     mov                 eax, index               ; divide index by the inner loop's counter (index->1)
     cdq
     div                 ecx

     cmp                 edx, 0                   ; if the remainder is not 0 then skip incrementing factor_counter
     jne                 not_factor

     inc                 factor_counter

     not_factor:

     loop                factor_loop

     ret
isComposite              ENDP

; Procedure: check if the user wants to replay this program
; recieves: n/a
; returns: eax
; preconditions: after the showComposites is called
; registers changed: edx, eax
goAgain                  PROC

     Call                Crlf
     mov                 edx, OFFSET repeat_request
     Call                WriteString
     Call                ReadInt

     ret
goAgain                  ENDP

; Procedure: says bye bye
; recieves: n/a
; returns: n/a
; preconditions: only if the user inputs 0 when prompted in goAgain
; registers changed: edx
farewell                 PROC

     Call                Crlf
     Call                Crlf
     
     mov                 edx, OFFSET bye_msg
     Call                WriteString

     ret
farewell                 ENDP

End main