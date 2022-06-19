.MODEL SMALL
.STACK 100H
.DATA
    BUFFER              DB       255, 0, 255 DUP(?)
    ASIZE		        DW       ?
	ARRAY		        DW       100 DUP(?)
	NEGFLAG             DW       ?
	
	NEW_LINE            DB       0DH, 0AH, '$'
	ENTER_SIZE_MSG      DB       0DH, 0AH, "Enter size of array: ",        0DH, 0AH, '$'
	ENTER_MSG           DB       0DH, 0AH, "Enter element of array: ",     0DH, 0AH, '$'               
	INCORRECT_SYMB_MSG  DB       0DH, 0AH, "Incorrect symbol!",            0DH, 0AH, '$'         
	OVERFLOW_MSG	    DB       0DH, 0AH, "Overflow occured!",            0DH, 0AH, '$'           
	ALL_EQUAL_MSG	    DB       0DH, 0AH, "All elements are equal!",      0DH, 0AH, '$'     
	SORTED_INC_MSG	    DB       0DH, 0AH, "The sequnce is increasing!",   0DH, 0AH, '$' 
	SORTED_DEC_MSG	    DB       0DH, 0AH, "The sequence is decreasing!",  0DH, 0AH, '$' 
	NOT_SORTED_MSG	    DB       0DH, 0AH, "The sequence is not sorted!",  0DH, 0AH, '$'
	SIZE_LESS_ZERO_MSG  DB       0DH, 0AH, "Size can't be 0 or less!",     0DH, 0AH, '$'
    	BIG_SIZE_MSG        DB       0DH, 0AH, "Size can't be more than 100!", 0DH, 0AH, '$'
    
.CODE
;INPUT: DX - OFFSET OF STRING
PRINT_STRING PROC
	MOV     AH, 9H
	INT     21H
	RET		 
PRINT_STRING ENDP

INPUT_INT PROC
    PUSH    BX
    PUSH    CX
    PUSH    DX
    PUSH    SI
@@START:
    MOV     AH, 0AH
    LEA     DX, BUFFER
    INT     21H
    LEA     DX, NEW_LINE
    CALL    PRINT_STRING
    XOR     AX, AX
    LEA     SI, BUFFER + 2
    MOV     NEGFLAG, AX   
    CMP     BYTE PTR [SI], '-'
    JNE     @PLUS
    NOT     NEGFLAG
    INC     SI
    JMP     @@NEXT   
@PLUS:
    CMP     BYTE PTR [SI], '+'
    JNE     @@NEXT
    INC     SI
@@NEXT:
    CMP     BYTE PTR [SI],0DH
    JE      EX1   
    CMP     BYTE PTR [SI],'0'
    JB      @ERROR
    CMP     BYTE PTR [SI],'9'
    JA      @ERROR
    MOV     BX, 10
    MUL     BX
    SUB     BYTE PTR [SI],'0'
    ADD     AL, [SI]
    ADC     AH, 0     
    INC     SI
    JMP     @@NEXT  
@ERROR:
    LEA     DX, INCORRECT_SYMB_MSG
    CALL    PRINT_STRING
    LEA     DX, NEW_LINE
    CALL    PRINT_STRING
    JMP     @@START     
@OVERFLOW:
    LEA     DX, OVERFLOW_MSG
    CALL    PRINT_STRING
    LEA     DX, NEW_LINE
    CALL    PRINT_STRING
    JMP     @@START
EX1:
    CMP     NEGFLAG,0FFFFh
    JE      @CH_MINUS
    JMP     @CH_PLUS
    
@CH_MINUS:
    CMP AX, 32768
    JA  @OVERFLOW
    NEG AX
    JMP @PROC_EX
@CH_PLUS:
    CMP AX, 32767
    JA  @OVERFLOW
    JMP @PROC_EX       
@PROC_EX:
    POP     SI
    POP     DX
    POP     CX
    POP     BX
    RET           
INPUT_INT ENDP

;ARGS: SI - OFFSET OF ARRAY
;RET VALUE IN DX: 1 - TRUE, 0 - FALSE
IS_ALL_EQUAL PROC
	DEC     CX
@CHECK:
    	MOV     AX, [SI]
	MOV     BX, [SI + 2]
	ADD     SI, 2
	CMP     AX, BX
	JNE     @NOT_EQUAL
	LOOP    @CHECK
	
	JMP     @EQ	
@NOT_EQUAL:
	MOV     DX, 0
	RET	
@EQ:
	MOV     DX, 1
	RET
IS_ALL_EQUAL ENDP

;ARGS: SI - OFFSET OF ARRAY
;RET VALUE IN DX: 1 - TRUE, 0 - FALSE
IS_SORTED_INCREASE PROC
	DEC     CX
@@CHECK:
	MOV     AX, [SI]
	MOV     BX, [SI + 2]
	ADD     SI, 2
	CMP     AX, BX
	JG      @@NOT_SORTED  
	LOOP    @@CHECK
	
	JMP     @@SORTED
	
@@NOT_SORTED:
	MOV     DX, 0
	RET	
@@SORTED:	 
    MOV     DX, 1
	RET
IS_SORTED_INCREASE ENDP

;ARGS: SI - OFFSET OF ARRAY, CX - ARRAY COUNT
;RET VALUE IN DX: 1 - TRUE, 0 - FALSE
IS_SORTED_DECREASE PROC
	DEC     CX
@LOOP2:
	MOV     AX, [SI]
	MOV     BX, [SI + 2]
	ADD     SI, 2
	CMP     AX, BX
	JL      @NOT_SORTED_DEC
	LOOP    @LOOP2
	
	JMP     @SORTED_DEC 
	
@NOT_SORTED_DEC:
	MOV     DX, 0
	RET
@SORTED_DEC:
	MOV     DX, 1
	RET
IS_SORTED_DECREASE ENDP

START:
	MOV     AX, @DATA
	MOV     DS, AX
	XOR     AX, AX

    	LEA     DX, ENTER_SIZE_MSG
    	CALL    PRINT_STRING
    	CALL    INPUT_INT
    	CMP     AX, 0
    	JLE     @SIZE_LESS_ZERO
    	CMP     AX, 100
    	JG      @SIZE_TOO_BIG
    
    	MOV     WORD PTR [ASIZE], AX
    	MOV     CX, WORD PTR [ASIZE]
    	LEA     SI, ARRAY
    	
@INPUT_ARR:
	LEA     DX, ENTER_MSG
	CALL    PRINT_STRING
	CALL    INPUT_INT
	MOV     [SI], AX
	ADD     SI, 2
	LOOP    @INPUT_ARR
		 
	LEA     SI, ARRAY
	MOV     CX, WORD PTR ASIZE
	CALL    IS_ALL_EQUAL
	CMP     DX, 1
	JE      @EQUAL
	
	LEA     SI, ARRAY
	MOV     CX, WORD PTR ASIZE
	CALL    IS_SORTED_DECREASE
	CMP     DX, 1
	JE      @DECREASE
	
	LEA     SI, ARRAY
	MOV     CX, WORD PTR ASIZE
	CALL    IS_SORTED_INCREASE
	CMP     DX, 1
	JE      @INCREASE
	
	JMP     @NOT_SORTED
@SIZE_TOO_BIG:
    	LEA     DX, BIG_SIZE_MSG
    	CALL    PRINT_STRING
    	JMP     @EXIT
@SIZE_LESS_ZERO:
    	LEA     DX, SIZE_LESS_ZERO_MSG
    	CALL    PRINT_STRING
    	JMP     @EXIT  
@EQUAL:
	LEA     DX, ALL_EQUAL_MSG
	CALL    PRINT_STRING
	JMP     @EXIT 
@DECREASE:
	LEA     DX, SORTED_DEC_MSG
	CALL    PRINT_STRING
	JMP     @EXIT
@INCREASE:
	LEA     DX, SORTED_INC_MSG
	CALL    PRINT_STRING
	JMP     @EXIT
@NOT_SORTED:
	LEA     DX, NOT_SORTED_MSG
	CALL    PRINT_STRING
	JMP     @EXIT
@EXIT:
	MOV     AX, 4C00H
	INT     21H	   
END START
