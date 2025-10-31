TITLE Project 5 - Pascal's Triangle Program     (Proj3_eaven.asm)

; Author: Nathan Eave
; Last Modified: May 24, 2025
; OSU email address: eaven@oregonstate.edu
; Course number/section:   CS271 Section: 400
; Project Number: Project #5                 Due Date: May 25, 2025
; Description: This program will introduce the programmer and then randomly generate
;			   a number of temperature readings. The exact number of temperature readings
;			   depends on the constant values DAYS_MEASURED and TEMPS_PER_DAY. It will
;			   then display the temperature readings, the highest temperature of each day,
;			   the lowest temperature of each day, and the average high and average low
;			   temperature.
INCLUDE Irvine32.inc

MIN_TEMP		=	  20 ;Minimum temperature that can be generated
MAX_TEMP		=	  80 ;Maximum temperature that can be generated
DAYS_MEASURED   =	  14 ;Number of days to print temperature readings for
TEMPS_PER_DAY	=	  11 ;Number of temperature readings per day to generate
ARRAYSIZE		=	  DAYS_MEASURED * TEMPS_PER_DAY ;Our array needs to be able to hold this many values

.data
greeting		BYTE  "Welcome to Chaotic Temperature Statistics by Nathan Eave",10,13,
					  "This program will generate a number of temperature readings and give you all the details!",10,13,
					  "The number of days and temperature readings per date are determined by constants.",10,13,
					  "Once I generate the temperatures, I'll show you the highs, lows, and averages!",10,13,10,13,0

tempIntro		BYTE  "Each row below is one day of temperature readings: ",10,13,0
highTempIntro	BYTE  "The highest temperature of each day was:",10,13,0
lowTempIntro	BYTE  "The lowest temperature of each day was:",10,13,0
avgHighIntro	BYTE  "The (truncated) average high temperature was: ",0
avgLowIntro		BYTE  "The (truncated) average low temperature was: ",0

goodbye			BYTE  10,13,"Thanks for using Chaotic Temperature Statistics! Let's play again soon!",10,13,0

tempArray		DWORD ARRAYSIZE DUP(?)
dailyHighs		DWORD DAYS_MEASURED DUP(?)
dailyLows		DWORD DAYS_MEASURED DUP(?)
averageHigh		DWORD ?
averageLow		DWORD ?


.code
main PROC
	call		Randomize

	push		OFFSET greeting
	call		printGreeting

	push		OFFSET tempArray
	call		generateTemperatures

	push		OFFSET dailyHighs
	push		OFFSET tempArray
	call		findDailyHighs

	push		OFFSET dailyLows
	push		OFFSET tempArray
	call		findDailyLows

	push		OFFSET tempIntro
	push		OFFSET tempArray
	push		DAYS_MEASURED
	push		TEMPS_PER_DAY
	call		displayTempArray


	push		OFFSET highTempIntro
	push		OFFSET dailyHighs
	push		1 ;The highest temperature of each day is displayed in one row
	push		DAYS_MEASURED
	call		displayTempArray


	push		OFFSET lowTempIntro
	push		OFFSET dailyLows
	push		1 ;The lowest temperature of each day is displayed in one row
	push		DAYS_MEASURED
	call		displayTempArray


	push		OFFSET dailyHighs
	push		OFFSET dailyLows
	push		OFFSET averageHigh
	push		OFFSET averageLow
	call		calcAverageLowHighTemps

	push		OFFSET avgHighIntro
	push		averageHigh
	call		displayTempwithString

	push		OFFSET avgLowIntro
	push		averageLow
	call		displayTempwithString


	push		OFFSET goodbye
	call		printGreeting

Invoke ExitProcess,0	; exit to operating system
main ENDP

; -------------------------------------------------------------------------------------------
; Name: printGreeting
; 
; Prints a message to the user.
;
; Receives: 
;		  [EBP + 8] =  reference to the message
; 
; -------------------------------------------------------------------------------------------


printGreeting PROC
	push	EBP
	mov		EBP, ESP
	push	EDX

	;[EBP + 8] = OFFSET greeting
	;[EBP + 4] = return address
	;[EBP] = old ebp

	mov		EDX, [EBP + 8]
	call	WriteString

	pop		EDX
	pop		EBP
	ret		8
printGreeting ENDP


; -------------------------------------------------------------------------------------------
; Name: generateTemperatures
; 
; Generates an array of temperature values. The size of the array is determined by the constant
; values TEMPS_PER_DAY and DAYS_MEASURED. Temperatures generated are between constant values
;' MIN_TEMP and MAX_TEMP.
;
; Preconditions: TEMPS_PER_DAY and DAYS_MEASURED are positive values. MIN_TEMP and MAX_TEMP
;				 both exist and MIN_TEMP < MAX_TEMP.
;
; Postconditions: none
;
; Receives:
;		  [EBP + 8] = address of the array

; 
; Returns: Array is filled with TEMPS_PER_DAY * DAYS_MEASURED number of temperatures in range.
; -------------------------------------------------------------------------------------------
generateTemperatures PROC
	push	EBP
	mov		EBP, ESP
	push	ECX
	push	EDI
	push	EAX

	;[EBP + 8] = OFFSET tempArray
	;[EBP + 4] = return address
	;[EBP] = old ebp

	mov		ECX, TEMPS_PER_DAY * DAYS_MEASURED
	mov		EDI, [EBP + 8]

_genTemp:
	mov		EAX, MAX_TEMP-MIN_TEMP+1
	call	RandomRange
	ADD		EAX, MIN_TEMP

	mov		[EDI], EAX
	ADD		EDI, 4
	LOOP	_genTemp
	
	pop		EAX
	pop		EDI
	pop		ECX
	pop		EBP
	ret		8
generateTemperatures ENDP

; -------------------------------------------------------------------------------------------
; Name: findDailyHighs
; 
; Generates an array of the highest temperature value of each day. The size of the array is 
; determined by the constant value DAYS_MEASURED, as there is one highest temperature for each day.
;
; Preconditions: TEMPS_PER_DAY and DAYS_MEASURED are positive values. The array of temperatures
;				 exists.
;
; Postconditions: none
;
; Receives:
;		  [EBP + 8] = address of the array of daily high temperatures
;		  [EBP + 12] = address of all temperatures that have been generated
; 
; Returns: Array is filled with the highest temperature of each day.
; -------------------------------------------------------------------------------------------
findDailyHighs PROC
	push	EBP
	mov		EBP, ESP
	push	ESI
	push	EDI
	push	EBX
	push	EAX
	push	ECX

	;[EBP + 12] = OFFSET dailyHighs
	;[EBP + 8] = OFFSET tempArray
	;[EBP + 4] = return address
	;[EBP] = old ebp

	mov		ESI, [EBP + 8]
	mov		EDI, [EBP + 12] ;move address of daily highs into EDI
	mov		EBX, DAYS_MEASURED


_daysLoop:
	mov		ECX, TEMPS_PER_DAY - 1 ;we need to loop through each day, TEMPS_PER_DAY number of times
	mov		EAX, [ESI] ;we need to set the max temp as the first temp of that day
	mov		[EDI], EAX ;sets the max temp as the first temp of the day
	cmp		ECX, 0
	JZ		_onlyOneTempHigh

_tempsLoop:
	mov		EAX, [ESI + 4 * ECX] ;loops backwards through each day - starting at the end of the day working to the start
	cmp		[EDI], EAX ; compare the current max with whatever temperature we're looking at

	JGE		_dontUpdateTemp ;if current max is >= current temp, don't update it

	mov		[EDI], EAX ;if current temp is > max temp, we have a new max temp
	
_dontUpdateTemp:
	loop	_tempsLoop ;then we go through the loop again (for each day)

_onlyOneTempHigh:
	ADD		ESI, 4 * TEMPS_PER_DAY ;once a day is done, we need to move to the next day in the tempArray
	ADD		EDI, 4 ;and we will need to store our dailyHigh in a new spot in the destination array, dailyHighs
	dec		EBX ;EBX is used to loop # of days measured time, so since we finished a day we will decrement this
	cmp		EBX, 0
	JNZ		_daysLoop ;if EBX isn't zero, we need to go to the next day and do it again

	pop		ECX
	pop		EAX
	pop		EBX
	pop		EDI
	pop		ESI
	pop		EBP
	ret		12
findDailyHighs ENDP

; -------------------------------------------------------------------------------------------
; Name: findDailyLows
; 
; Generates an array of the lowest temperature value of each day. The size of the array is 
; determined by the constant value DAYS_MEASURED, as there is one lowest temperature for each day.
;
; Preconditions: TEMPS_PER_DAY and DAYS_MEASURED are positive values. The array of temperatures
;				 exists.
;
; Postconditions: none
;
; Receives:
;		  [EBP + 8] = address of the array of daily low temperatures
;		  [EBP + 12] = address of all temperatures that have been generated
; 
; Returns: Array is filled with the lowest temperature of each day.
; -------------------------------------------------------------------------------------------
findDailyLows PROC
	push	EBP
	mov		EBP, ESP
	push	ESI
	push	EDI
	push	EBX
	push	ECX
	push	EAX

	;[EBP + 12] = OFFSET dailyHighs
	;[EBP + 8] = OFFSET tempArray
	;[EBP + 4] = return address
	;[EBP] = old ebp

	mov		ESI, [EBP + 8]
	mov		EDI, [EBP + 12] ;move address of daily highs into EDI
	mov		EBX, DAYS_MEASURED

_daysLoopLow:
	mov		ECX, TEMPS_PER_DAY - 1 ;we need to loop through each day, TEMPS_PER_DAY number of times
	mov		EAX, [ESI] ;we need to set the max temp as the first temp of that day
	mov		[EDI], EAX ;sets the max temp as the first temp of the day
	cmp		ECX, 0
	JZ		_onlyOneTempLow

_tempsLoopLow:
	mov		EAX, [ESI + 4 * ECX] ;loops backwards through each day - starting at the end of the day working to the start
	cmp		[EDI], EAX ; compare the current max with whatever temperature we're looking at

	JLE		_dontUpdateTempLow ;if current max is >= current temp, don't update it

	mov		[EDI], EAX ;if current temp is > max temp, we have a new max temp
	
_dontUpdateTempLow:
	loop	_tempsLoopLow ;then we go through the loop again (for each day)

_onlyOneTempLow:
	ADD		ESI, 4 * TEMPS_PER_DAY ;once a day is done, we need to move to the next day in the tempArray
	ADD		EDI, 4 ;and we will need to store our dailyHigh in a new spot in the destination array, dailyHighs
	dec		EBX ;EBX is used to loop # of days measured time, so since we finished a day we will decrement this
	cmp		EBX, 0
	JNZ		_daysLoopLow ;if EBX isn't zero, we need to go to the next day and do it again

	pop		EAX
	pop		ECX
	pop		EBX
	pop		EDI
	pop		ESI
	pop		EBP
	ret		12
findDailyLows ENDP


; -------------------------------------------------------------------------------------------
; Name: calcAverageLowHighTemps
; 
; Calculates the average of all the daily high temperatures and the average of all the daily low
; temperatures.
;
; Preconditions: DAYS_MEASURED is a positive value. The arrays of temperatures exists.
;				 The values for the average high and average low temperature values are DWORDS.
;
; Postconditions: none
;
; Receives:
;		  [EBP + 8] = address of the DWORD value for the average low temperature
;		  [EBP + 12] = address of the DWORD value for the average high temperature
;		  [EBP + 16] = address of the array of daily low temperatures
;		  [EBP + 20] = address of the array of daily high temperatures
; 
; Returns: The average of the daily high temperatures and average of the daily low temperatures.
; -------------------------------------------------------------------------------------------
calcAverageLowHighTemps PROC
	push	EBP
	mov		EBP, ESP
	push	ECX
	push	ESI
	push	EAX
	push	EDI
	push	EBX
	push	EDX
	;[EBP + 20] = OFFSET dailyHighs
	;[EBP + 16] = OFFSET dailyLows
	;[EBP + 12] = OFFSET averageHigh
	;[EBP + 8] = OFFSET averageLow
	;[EBP + 4] = return address
	;[EBP] = old ebp

	mov		ECX, DAYS_MEASURED
	mov		ESI, [EBP + 20]
	mov		EAX, 0
_highAvg:
	ADD		EAX, [ESI]
	ADD		ESI, 4
	LOOP	_highAvg

	mov		EDI, [EBP + 12]
	mov		EBX, DAYS_MEASURED
	mov		EDX, 0
	DIV		EBX
	mov		[EDI], EAX


	mov		ECX, DAYS_MEASURED
	mov		ESI, [EBP + 16]
	mov		EAX, 0
_lowAvg:
	ADD		EAX, [ESI]
	ADD		ESI, 4
	LOOP	_lowAvg

	mov		EBX, DAYS_MEASURED
	mov		EDX, 0
	DIV		EBX	
	mov		EDI, [EBP + 8]
	mov		[EDI], EAX

	pop		EDX
	pop		EBX
	pop		EDI
	pop		EAX
	pop		ESI
	pop		ECX
	pop		EBP
	ret		20
calcAverageLowHighTemps ENDP


; -------------------------------------------------------------------------------------------
; Name: displayTempArray
; 
; Displays an array of temperatures.
;
; Preconditions: The array is type DWORD.
;
; Postconditions: none
;
; Receives:
;		  [EBP + 8] = number of columns that should be displayed in each row
;		  [EBP + 12] = number of rows that should be displayed
;		  [EBP + 16] = address of the array of the array to print
;		  [EBP + 20] = reference to message that introduces the array
; 
; Returns: Prints an array of temperatures.
; -------------------------------------------------------------------------------------------
displayTempArray PROC
	push	EBP
	mov		EBP, ESP
	push	EDX
	push	ESI
	push	EBX
	push	ECX
	push	EAX

	;[EBP + 20] = OFFSET message
	;[EBP + 16] = OFFSET array
	;[EBP + 12] = number of rows
	;[EBP + 8] = number of columns
	;[EBP + 4] = return address
	;[EBP] = old ebp

	mov		EDX, [EBP + 20]
	call	WriteString


	mov		ESI, [EBP + 16]
	mov		EBX, 0 ;EBX is the total number of values we have printed so far
	mov		ECX, [EBP + 12]
	mov		EDX, 0 ;EDX is the column that we are currently printing
_beginRow:
	mov		EAX, [ESI + 4 * EBX]
	call	WriteDec
	mov		AL, ' '
	call	writeChar
	inc		EBX
	inc		EDX
	cmp		EDX, DWORD PTR [EBP + 8] ;Compare the number of column we're currently printing to total number of columns to print
	jl		_beginRow

	mov		EDX, 0
	call	CrLF

	loop	_beginRow


	call	CrLF
	pop		EAX
	pop		ECX
	pop		EBX
	pop		ESI
	pop		EDX
	pop		EBP
	ret		20
displayTempArray ENDP


; -------------------------------------------------------------------------------------------
; Name: displayTempwithString
; 
; Display a temperature and an a message associated with that temperature.
;
; Preconditions: The value is type DWORD.
;
; Postconditions: none
;
; Receives:
;		  [EBP + 8] = value to be displayed
;		  [EBP + 12] = reference to message that introduces the value
; 
; Returns: Displays a string and a temperature.
; -------------------------------------------------------------------------------------------
displayTempwithString PROC
	push	EBP
	mov		EBP, ESP
	push	EDX
	push	EAX

	;[EBP + 12] = OFFSET introduction sentence
	;[EBP + 8] = value to show
	;[EBP + 4] = return address
	;[EBP] = old ebp

	mov		EDX, [EBP + 12]
	call	WriteString

	mov		EAX, [EBP + 8]
	call	WriteDec
	call	CrLF

	pop		EAX
	pop		EDX
	pop		EBP
	ret		12

displayTempwithString ENDP
END main