TITLE Sorting and Counting Random Integers     (program5_powdrild.asm)

; Author: David Powdrill
; Last Modified: 5/23/2020
; OSU email address: powdrild@oregonstate.edu
; Course number/section: 271-400
; Project Number: 5                Due Date: 5/24/2020
; Description: Generates an array of 200 random integers in the range of 10-29. It then displays the array of 200
;				random integers, the median of the array, the array sorted in ascending order, and an array of the
;				number of instances of each element that was in the 200 integer array. 

INCLUDE Irvine32.inc

LO = 10
HI = 29
ARRAYSIZE = 200
COUNTS_SIZE = 20

.data	
array		DWORD	ARRAYSIZE	DUP(?)					;array of 200 integers
counts		DWORD	COUNTS_SIZE	DUP(?)					;array of insances of each element in the array
median		BYTE	"List Median: ", 0
intro_1		BYTE	"Sorting and Counting Random Integers!		Programmed by David Powdrill ", 0
intro_2		BYTE	"This program generates 200 random numbers in the range [10...29], displays the ", 0
intro_3		BYTE	"original list, sorts the list, displays the median value, displays the list sorted in ", 0
intro_4		BYTE	"ascending order, then displays the number of instances of each generated value. ", 0
unsorted	BYTE	"Your unsorted random numbers: ", 0
sorted		BYTE	"Your sorted random numbers: ", 0
instance	BYTE	"Your list of instances of each generated number, starting with the numner of 10s: ", 0
goodBye		BYTE	"Goodbye, and thanks for using my program! ", 0

.code
main PROC
	call Randomize

	;introduction
	push	OFFSET intro_1			;20
	push	OFFSET intro_2			;16
	push	OFFSET intro_3			;12
	push	OFFSET intro_4			;8
	call	introduction

	;fillArray
	push	OFFSET array			;20
	push	LO						;16
	push	HI						;12
	push	ARRAYSIZE				;8
	call	fillArray

	;displayList
	push	OFFSET	array			;16
	push	ARRAYSIZE				;12	
	push	OFFSET unsorted			;8
	call	displayList

	;sortList
	push	OFFSET array			;12
	push	ARRAYSIZE				;8
	call	sortList

	;displayMedian
	push	OFFSET array			;16
	push	ARRAYSIZE				;12
	push	OFFSET median			;8
	call	displayMedian

	;displayList
	push	OFFSET	array			;16
	push	ARRAYSIZE				;12
	push	OFFSET sorted			;8
	call	displayList

	;countList
	push	OFFSET array			;20
	push	ARRAYSIZE				;16
	push	OFFSET counts			;12	
	push	LO						;8
	call	countList

	;displayList
	push	OFFSET counts			;16
	push	COUNTS_SIZE				;12
	push	OFFSET instance			;8
	call	displayList

	;farewell
	push	OFFSET goodBye			;8
	call	farewell

	exit	; exit to operating system
main ENDP

;----------------------------------------------------------
introduction	PROC
;
; Displays title, author, and description of program.
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: [ebp+20] = title and author
;			[ebp+16] = first description line
;			[ebp+12] = second description line
;			[ebp+8]  = third description line
;
; Returns: None 
;----------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;prints program title and author
	mov		edx, [ebp+20]
	call	WriteString
	call	CrLf
	call	CrLf

	;prints description line one
	mov		edx, [ebp+16]
	call	WriteString
	call	CrLf

	;prints description line two
	mov		edx, [ebp+12]
	call	WriteString
	call	CrLf

	;prints description line three
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	call	CrLf

	pop		ebp
	ret		

introduction		ENDP

;----------------------------------------------------------
fillArray	PROC
;
; Fills an array with 200 random integers between the values
; of 10-29.
;
; Preconditions: array is DWORD
;
; Postconditions: changes registers esi, ecx, eax
;
; Receives: [ebp+20] = array
;			[ebp+16] = LO
;			[ebp+12] = HI
;			[ebp+8]  = ARRAYSIZE
;
; Returns: array (esi) = random array 
;----------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;set up for loop
	mov		esi, [ebp+20]			;array
	mov		ecx, [ebp+8]			;ARRAYSIZE loop counter

fill:
	;makes random integer and stores in array
	mov		eax, [ebp+12]		
	sub		eax, [ebp+16]			;HI - LO
	inc		eax
	call	RandomRange
	add		eax, [ebp+16]			;adds LO to answer of (HI - LO) + 1
	mov		[esi], eax				;stores in array

	;moves to next element
	add		esi, 4
	loop	fill

	pop		ebp
	ret		16

fillArray		ENDP

;---------------------------------------------------------
sortList		PROC
;
; Sorts array of 200 integers in ascending order using 
; gnome sort. 
;
; Preconditions: array has been generated and array is DWORD
;
; Postconditions: changes registers esi, ecx, eax, ebx, edx
;
; Receives: [ebp+12] = array
;			[ebp+8]  = ARRAYSIZE
;
; Returns: array (esi) = array that has been sorted
;---------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;set up for loop
	mov		esi, [ebp+12]			;array
	mov		ecx, [ebp+8]			;ARRAYSIZE
	sub		ecx, 1
	mov		eax, 0

top:
	;check if made to end of sort
	cmp		eax, ecx
	jge		finish

	;checks if value at current position is samller thant the next value
	mov		ebx, [esi]
	mov		edx, [esi+4]
	cmp		ebx, edx
	jle		nextelement

	;call exchangeElements
	push	esi						;push current location
	add		esi, 4				
	push	esi						;push location of value to swap
	call	exchangeElements

	;moves to next elements to sort
	sub		esi, 8
	dec		eax
	jmp		top

nextelement:
	;moves to next element to sort
	inc		eax
	add		esi, 4
	jmp		top

finish:
	pop		ebp
	ret		8

sortList		ENDP

;---------------------------------------------------------
exchangeElements		PROC
;
; Exchanges elements in an array that's being sorted
;
; Preconditions: sortList found values that needs to be exchanged
;
; Postconditions: changes registers edx, ebx, esi
;
; Receives: [ebp+12] = location of first value (larger)
;			[ebp+8]  = location of second value (smaller)
;
; Returns: array (esi) = array with two values in correct order
;---------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;saves first (larger) value on the stack
	mov		edx, [ebp+12]			;location of first value (larger)
	mov		ebx, [edx]				;stores value at location in ebx
	push	ebx					

	;stores second value (smaller) in the location of the first value (larger) 
	mov		ebx, [ebp+8]			;location of second value (smaller)
	mov		edx, [ebx]				;stores value at location in edx
	mov		esi, [ebp+12]			;moves first value's (larger) location into esi
	mov		[esi], edx				;stores second (smaller) in first (larger) value's location

	;stores first value (greater) in the location of the second value (smaller)
	pop		ebx
	mov		esi, [ebp+8]			;moves second values's (smaller) location into esi
	mov		[esi], ebx				;stores first value (larger) in second value's (smaller) location

	pop		ebp
	ret		8

exchangeElements	ENDP

;---------------------------------------------------------
displayMedian		PROC
;
; Displays the median of the 200 integer array
;
; Preconditions: array must have been sorted in ascending order
;
; Postconditions: changes registers esi, ecx, eax, ebx, edx
;
; Receives: [ebp+16] = sorted array
;			[ebp+12] = ARRAYSIZE
;			[ebp+8]  = median text line
;
; Returns: None
;---------------------------------------------------------
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+16]

	;calculates distance of one middle value in bytes and stores on stack
	mov		eax, [ebp+12]
	mov		ebx, 2
	cdq
	div		ebx						;divides ARRAYSIZE by 2
	mov		ebx, 4
	mul		ebx						;calulates distance in bytes 
	push	eax						;stores distance in bytes of one middle value on stack

	;calculates distance of second middle value in bytes 
	mov		eax, [ebp+12]
	mov		ebx, 2
	div		ebx						;divides ARRAYSIZE by 2
	inc		eax						;moves index over 1 to get second middle index
	mov		ebx, 4
	mul		ebx

	;gets value of the second middle in eax
	add		esi, eax
	mov		eax, [esi]				;value of second middle in eax

	;gets value of first middle in ebx
	pop		ebx
	mov		esi, [ebp+16]
	add		esi, ebx
	mov		ebx, [esi]				;value of first middle in ebx

	;check if values are the same
	cmp		eax, ebx
	je		display

	;calculate average between two values
	add		eax, ebx
	mov		ebx, 2
	div		ebx

	;checks if there is a remainder
	cmp		edx, 0
	je		display

	;round up if there is a remainder
	inc		eax
	jmp		display

display:
	mov		edx, [ebp+8]	
	call	WriteString
	call	WriteDec				;displays median

	pop		ebp
	ret		12

displayMedian	ENDP

;---------------------------------------------------------
displayList		PROC
;
; Displays all values in an array 20 per line. 
;
; Preconditions: array is a DWORD
;
; Postconditions: changes register esi, ecx, ebx, edx, eax, al
;
; Receives: [ebp+16] = an array
;			[ebp+12] = size of array
;			[ebp+8]  = text displayed with array
;
; Returns: None
;---------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;set up
	mov		esi, [ebp+16]			;array
	mov		ecx, [ebp+12]			;size of array
	mov		ebx, 0					;value counter for new lines

	;prints text
	call	CrLf
	mov		edx, [ebp+8]			;array text
	call	WriteString
	call	CrLf

print:
	;moves value in array into eax
	mov		eax, [esi]

	;checks if new line is needed
	cmp		ebx, 19
	jg		newline

	;prints integer
	call	WriteDec
	mov		al, ' '
	call	WriteChar
	call	WriteChar
	add		ebx, 1
	jmp		next

newline:
	;creates new line and prints integer
	call	CrLf
	call	WriteDec
	mov		al, ' '
	call	WriteChar
	call	WriteChar
	mov		ebx, 1

next:
	;moves to next element
	add		esi, 4
	loop	print
	call	CrLf
	call	CrLf

	pop		ebp
	ret		12

displayList		ENDP

;----------------------------------------------------------
countList	PROC
;
; Counts the number of instances of an element in an array
;
; Preconditions: array must be sorted in ascending order
;				and must be a DWORD
;
; Postconditions: registers esi, ecx, edx, ebx, eax, edi
;
; Receives: [ebp+20] = array
;			[ebp+16] = ARRAYSIZE
;			[ebp+12] = counts array
;			[ebp+8]  = LO
;
; Returns: None 
;----------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;sets values
	mov		esi, [ebp+20]			;array
	mov		ecx, [ebp+16]			;ARRAYSIZE
	mov		edx, 0					;value counter
	mov		ebx, 0				

top1:
	;calculates array index and compares to last value's index
	mov		eax, [esi]				;value in eax 
	sub		eax, [ebp+8]			;new array index
	push	eax

	;check if value is same as last value
	cmp		eax, ebx
	je		count

	;moves counts to top of stack for countnew
	xor		edx, edx
	push	esi
	mov		esi, [ebp+12]			;counts array
	pop		edi
	push	esi
	mov		esi, edi				;moves array into esi
	jmp		countnew

count: 
	;increments value counter
	inc		edx						;increase count of value
	
	;calculates values location
	push	esi	
	mov		esi, [ebp+12]			;counts array
	mov		ebx, 4
	push	edx
	mul		ebx						;calculates value location
	pop		edx

	;stores value counter
	add		esi, eax			
	mov		[esi], edx				;stores value counter at correct location
	pop		esi					
	pop		ebx

	;moves to next value in array
	add		esi, 4				
	loop	top1
	jmp		done

countnew:
	;increments value counter
	inc		edx						;increase count of value

	;calculates value location
	pop		edi
	push	esi
	mov		esi, edi				;moves counts array into esi
	mov		ebx, 4
	push	edx
	mul		ebx						;calculates value location
	pop		edx

	;stores value counter
	add		esi, eax			
	mov		[esi], edx				;stores value counter at correct location
	pop		esi
	pop		ebx

	;moves to next value in array
	add		esi, 4				
	loop	top1

done:
	pop		ebp
	ret		16

countList		ENDP

;---------------------------------------------------------
farewell		PROC
;
; Displays a farewell message to the user. 
;
; Preconditions: All other procedures have been executed
;
; Postconditions: changes register edx
;
; Receives: [ebp+8] = goodBye text
;
; Returns: None
;---------------------------------------------------------
	push	ebp
	mov		ebp, esp

	;prints farwell message to user
	mov		edx, [ebp+8]
	call	WriteString

	pop		ebp
	ret		4

farewell		ENDP

END main



