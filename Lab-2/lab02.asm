.model small
.stack 100h

.data
    inStringMessage         db "Enter string: $"
    inLettersMessage        db "Enter letters: $"
    
    emptyStringMessage      db "String is empty!$"
    emptyLettersMessage     db "You didn't enter any letters!$"
    notUniqueLettersMessage db "You entered several identical letters!$"
    
    resultMessage           db "Result: $"
    
    string                  db 201 dup('$')
    letters                 db 201 dup('$')
    stringSize              dw 0
    lettersSize             dw 0
    
    wordLength              dw ?
    wordStart               dw ?
    wordEnd                 dw ?
    lettersCount            dw ?
    rememberMainLoop        dw ?
.code

; dx - offset of string
printString proc  
    mov     ah, 9
    int     21h
    ret
printString endp

; al - symbol 
printSymbol proc
    mov     ah, 06h
    int     21h
    ret
printSymbol endp

count proc
    push si
    mov si, wordStart
    
    @count:
        mov dl, string[si]
        inc si
        cmp dl, 32
        je @endCount
        cmp dl, '$'
        je @endCount
        inc wordEnd
        inc wordLength
        jmp @count  
    
    @endCount:
        pop si
        ret      
count endp
         
deleteWordsWithGivenLetters proc       
    mov si, 0
    
    @mainLoop:
        cmp si, stringSize
        jge @temp
        mov dl, string[si]
        cmp dl, ' '
        jne @word
        
        inc si
        cmp si, stringSize
        jle @mainLoop   
    
    @word:
        mov wordStart, si
        mov wordEnd, si
        mov wordLength, 0
        call count
        mov lettersCount, 0
            
        mov rememberMainLoop, si 
        mov si, wordStart
        
        @outCheckerLoop:
            mov di, 0
       
            @inCheckerLoop:
                
                mov dl, string[si]
                mov dh, letters[di]
                
                cmp dl, dh
                je  @incLettCount
                jne @continueInLoop
                
                @incLettCount:
                    inc lettersCount
                
                @continueInLoop:    
                    inc di
                
             cmp di, lettersSize
             je @endInCheckerLoop
             jle @inCheckerLoop
             
             @endInCheckerLoop:
             inc si
        
        cmp si, wordEnd
        jle @outCheckerLoop
        
        mov ax, lettersCount
        mov dx, lettersSize
        
        cmp ax, dx
        jge @delete
        jne @continue
        
        @temp:
            jmp @exit
        
        @delete:
            mov si, 0
            @delOutLoop:
                push si
                mov si, wordStart
                
                @delInLoop:
                   mov dh, string[si + 1]
                   mov string[si], dh
                   inc si
                cmp si, stringSize
                jl @delInLoop
                
                pop si
                inc si
                dec stringSize
   
            cmp si, wordLength
            jl @delOutLoop
            

            mov si, wordStart
  
                                      
        jmp @goLoop 
            
        @continue:
            mov si, rememberMainLoop
            add si, wordLength
            jmp @goLoop
        
        @goLoop:
            jmp @mainLoop

    @exit:
        ret       
deleteWordsWithGivenLetters endp

start:
    mov     ax, @data
    mov     ds, ax
    mov     ax, 0

StringInput:
    xor     dx, dx   
    mov     dx, offset inStringMessage
    call    printString
    xor     si, si
    mov     cx, 1
    stringLoop:
        mov     ah, 1
        int     21h
        cmp     al, 0Dh
        je      IsStringEmpty
        mov     string[si], al
        inc     si
        cmp     si, 200
        je      IsStringEmpty
        inc     cx
        inc     stringSize
     loop stringLoop

LettersInput:
     xor    dx, dx     
     lea    dx,inLettersMessage
     call   printString
     xor    si, si
     mov    cx, 1 
     lettersLoop:
        mov     ah, 1
        int     21h 
        cmp     al, 0Dh
        je      IsLettersEmpty
        mov     letters[si], al
        inc     si
        cmp     si, 200
        je      IsLettersEmpty
        inc     cx
        inc     lettersSize 
     loop lettersLoop
Main:    
    call    deleteWordsWithGivenLetters
    
    lea     dx, resultMessage
    call    printString
        
    lea     dx, string
    call    printString
         
    jmp     Exit

CheckIsLettersUnique:
    mov si, 0
    
    @checkLoop1:
        mov di, si
        @checkLoop2:
            mov dh, letters[si]
            mov dl, letters[di + 1]
            cmp dh, dl
            je NotUniqueLetter
            inc di
        cmp di, lettersSize
        jne @checkLoop2
        inc si 
   cmp si, lettersSize 
   je Main
   jne @checkLoop1    
 
NotUniqueLetter:
    lea dx, notUniqueLettersMessage
    call printString 
    jmp Exit
                 
IsStringEmpty:
    cmp     stringSize, 0
    je      StringIsEmpty
    jne     LettersInput

IsLettersEmpty:
    cmp     lettersSize, 0
    je      LettersIsEmpty
    jne     CheckIsLettersUnique   
    
StringIsEmpty:
    lea     dx, emptyStringMessage
    call    printString
    jmp     Exit

LettersIsEmpty:
    lea     dx, emptyLettersMessage
    call    printString
    jmp     Exit
          
Exit:
    mov     ax, 4C00h
    int     21h
    ret
           
end start    
