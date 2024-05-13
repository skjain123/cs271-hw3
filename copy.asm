; hw2.asm
; Author: Sunil Jain
; Course/ Project ID: CS271 -Homework 2
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
     MAX_BOUND           = 1000         ; maximum boundary

.data

; insert variable definitions here

	intro_msg           Byte      0ah, 0Dh, "CS 271 HW 2 - Factors", 0
     desc_msg            Byte      0ah, 0Dh, "    This program calculates and displays the factors of numbers from lowerbound to upper bound.", 0ah, 0Dh, "    It also indicates when a number is prime", 0
     name_request        Byte      0ah, 0Dh, 0ah, 0Dh, "Enter your name: ", 0

     lower_b_request     Byte      0ah, 0Dh, "Enter a number between 1 and 1000 for the lowerbound of the range : ", 0
     upper_b_request     Byte      "Enter a number between 1 and 1000 for the upperbound of the range : ", 0
     repeat_request      Byte      0ah, 0Dh, "Would you like to do another calculation? (0=NO, 1=YES): ", 0

     lower_b_error       Byte      0ah, 0Dh, "The number you entered is too small (1-1000).", 0
     upper_b_error       Byte      0ah, 0Dh, "The number you entered is too big (1-1000).", 0
     improper_b_error    Byte      0ah, 0Dh, "The lowerbound must be >= the lowerbound", 0

     prime_msg           Byte      "  ** Prime Number **", 0
     bye_msg             Byte      0ah, 0Dh, "Good bye ", 0
     
     colon               Byte      " : ", 0
     newline             Byte      0ah, 0Dh, 0


     name_input          Byte      MAX_STR+1 DUP(?)
     lower_b_input       DWORD     MAX_STR+1 DUP(?)
     upper_b_input       DWORD     MAX_STR+1 DUP(?)

     index               DWORD     MAX_STR+1 DUP(?)
     is_prime            DWORD     0

.code
main proc

; insert executable instructions here


;-------------------------------------------------------------------------------------------
;    Prints the introduction and description messages, prompts for the user's name
	mov edx, OFFSET intro_msg
	Call WriteString
     mov edx, OFFSET desc_msg
	Call WriteString

     mov		edx, OFFSET name_request
	Call      WriteString

     mov       edx, OFFSET name_input
     mov       ecx, MAX_STR ; amount of characters to read in
     Call      ReadString

;-------------------------------------------------------------------------------------------
;    prompts for the lower bound and stores it, then checks if it is within 1-1000

get_lower_b:
     mov		edx, OFFSET lower_b_request
	Call      WriteString

     Call      ReadInt
     mov       lower_b_input, eax

     jmp       check_lower_b

;-------------------------------------------------------------------------------------------
;    prompts for the upper bound and stores it, then checks if it is within 1-1000

get_upper_b:
     mov		edx, OFFSET upper_b_request
	Call      WriteString

     Call      ReadInt
     mov       upper_b_input, eax

     jmp       check_upper_b


;-------------------------------------------------------------------------------------------
;    if the lower bound is not within 1-1000 print an error message and reprompt

print_lower_b_error:
     mov		edx, OFFSET lower_b_error
	Call      WriteString
     jmp       get_lower_b


;-------------------------------------------------------------------------------------------
;    if the upper bound is not within 1-1000 print an error message and reprompt

print_upper_b_error:
     mov		edx, OFFSET upper_b_error
	Call      WriteString
     jmp       get_lower_b

;-------------------------------------------------------------------------------------------
;    if the lowerbound is higher than the upperbound print an error and reprompt

print_improper_b_error:
     mov		edx, OFFSET improper_b_error
	Call      WriteString
     jmp       get_lower_b


;-------------------------------------------------------------------------------------------
;    checks if the lowerbound is within 1-1000 if it isnt reprompt, if it is get upperbound

check_lower_b:
     mov       eax, lower_b_input

     cmp       eax, MAX_BOUND
     jg        print_upper_b_error

     cmp       eax, MIN_BOUND
     jl        print_lower_b_error

     jmp       get_upper_b
     
;-------------------------------------------------------------------------------------------
; check if the upperbound is within 1-1000 if it isnt reprompt, if it is, check if the upperbound is higher than the lower

check_upper_b:
     mov       eax, upper_b_input

     cmp       eax, MAX_BOUND
     jg        print_upper_b_error

     cmp       eax, MIN_BOUND
     jl        print_lower_b_error
     jmp       check_improper_b

;-------------------------------------------------------------------------------------------
; check if the upperbound is higher than the lowerbound, if it isnt then reprompt, if it is then continue from here

check_improper_b:
     mov       eax, lower_b_input

     cmp       eax, upper_b_input
     jg        print_improper_b_error


;-------------------------------------------------------------------------------------------
; sets up the outer loop using the conditions: for (int i = lower; i <= upper; i++)
     
     mov edx, OFFSET newline
	Call WriteString
     mov       eax, lower_b_input
     mov       index, eax
     mov       ecx, index

index_loop:
     
     mov       index, ecx               ; saves the ecx in index so we can use ecx for the innerloop

     mov       eax, index               ; print out the number we are checking for prime number
     Call      WriteInt

     mov		edx, OFFSET colon        ; print out the colon to make it look nice
	Call      WriteString
     
     mov       ebx, upper_b_input       ; use ebx for a cmp with index for the loop conditions

;-------------------------------------------------------------------------------------------
; sets up the inner loop using ecx: for (int j = 1; j < index; j++)

     mov       ecx, 1
     mov       is_prime, 0              ; if this is 2 at the end of the inner loop, the number is a prime number

primes_loop:

     mov       eax, index               ; divide index by the inner loop's counter (1-index)
     cdq
     div       ecx

     cmp       edx, 0                   ; if the remainder is 0 then print the divisible number 
     je        print_div

     inc       ecx                      ; if it isnt 0, then increment the counter, and start the inner loop again
     cmp       ecx, index
     jle       primes_loop
     jmp       check_index_loop         ; if the loop Is done jump to the end of the inner loop

;-------------------------------------------------------------------------------------------
; print the ecx counter if it is divisible by index (incrementing using the outer loop)

print_div:
     mov       eax, ecx
     Call      WriteInt

     inc       is_prime                 ; increment this to count the amount of divisible numbers

     inc       ecx                      ; start the inner loop again
     cmp       ecx, index
     jle       primes_loop
     jmp       check_index_loop         ; if the loop Is done, jump to the end of the inner loop


;-------------------------------------------------------------------------------------------
; the end of the inner loop where we finally check if index is a prime number by counting the number of divisible numbers

check_index_loop:
     
     mov       ecx, is_prime            ; if 2 divisible numbers, it is prime
     cmp       ecx, 2
     je        print_prime_num

after_print_prime_num:                  ; a marker to jump to after saying this number is prime
     
     mov		edx, OFFSET newline      ; set up for the new outer loop
	Call      WriteString


     mov       ecx, index               ; move index back into ecx to use as a counter for the outer loop
     inc       ecx
     
     cmp       ecx, upper_b_input       ; for (int i = lower; i <= upper; i++)
     jle       index_loop               ; continue the loop if less than or equal to 
     jmp       after_index_loop         ; break the loop

;-------------------------------------------------------------------------------------------
; notify the user that the current number is a prime

print_prime_num:
     mov       edx, OFFSET prime_msg 
     Call      WriteString
     jmp       after_print_prime_num

;-------------------------------------------------------------------------------------------
; after both loops are done, prompt if the user wants to calculate again (1-yes, 0-no)

after_index_loop:
     mov       edx, OFFSET repeat_request
     Call      WriteString
     Call      ReadInt
     
     cmp       eax, 1
     je        get_lower_b
     
     mov       edx, OFFSET bye_msg      ; print good bye
     Call      WriteString
     mov       edx, OFFSET name_input   ; print the user name
     Call      WriteString

;-------------------------------------------------------------------------------------------
; Done!

	invoke ExitProcess,0
main endp

; insert additional procedures here

End main