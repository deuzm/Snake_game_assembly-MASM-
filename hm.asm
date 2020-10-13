.model small
.stack 100h
 
.data
    saveMode db ? 
    currentX dw 160
    currentY dw 80 
    segmentSize dw 4 ; size of the snake segment x,y
    color db 15  
    timePrevious db 0  
    snakeSpeed dw 02h 
    snakeSize dw 4
    snakePosX dw 100 dup (?)
    snakePosY dw 100 dup (?)

    arrayLength dw 0
    directionX dw 4
    directionY dw 0

    randX dw ?
    randY dw ?

    applePresent dw 0

    count dw 0
    speed db 10
    again dw 0

    endString db 13, 10, '_______________GAME OVER________________', '$', 13, 10

    
.code  

main:  
    mov ax, @data
    mov ds, ax
    
    mov ah, 0Fh  
    int 10h  
    
    mov saveMode, al
    mov ah, 0   ; set display mode function.
    mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
    int 10h  ; set it!   

    StartOver:
        mov currentX, 160
        mov currentY, 80
        mov snakeSize, 4
        mov arrayLength, 0
        mov count, 0
        mov directionX, 4
        mov directionY, 0
        mov dx, currentY   ;set y
        mov cx, 0

        call ClearScreen
        
    ;time
    CheckTime:
        
        mov ah, 2Ch ;ch = hour, cl = minute, dh = second, dl = 1/100 second
        int 21h  

        ;Adjusting speed
        mov bl, speed
        sub ax, ax
        mov al, dl
        div bl   

        cmp al, timePrevious   ;is the current time equal to previoustime
        je checkTime           ;if its same check again
        
        ;if its different, then draw, move, etc
        mov  timePrevious, al  ;update time

        ;Adjusting speed
        sub ax, ax
        mov al, dl
        div bl

        call ClearScreen

        call DrawApple

        call CheckAppleCollision
        call DisplayCount
        call ListenForInput
        call MoveHead
        call CheckEndGame
        call SaveHeadPos
        call DrawSnake

        jmp CheckTime  

        EndGame:
        call EndFunction
        mov ax, again
        cmp ax, 0
        jne StartOver

    mov ah, 0
    int 16h
    
    mov ah, 0
    mov al, saveMode
    int 10h
    mov ah, 4ch
    int 21h
    ret

EndFunction proc
        call ClearScreen
        ;Displaying end string
        mov dx, offset endString
        mov ah, 09h 
        int 21h

        mov ah, 01h             
        int 21h
        ret
        ;Wait for input
EndFunction endp

DisplayCount proc
        mov ax, count
        call OutCountInt
        ret
DisplayCount endp

CheckEndGame proc
        CheckBounaryCollision:
                cmp currentX, 316
                jge EndGame
                cmp currentX, 0
                jl EndGame
                cmp currentY, 196
                jge EndGame
                cmp currentY, 0
                jl EndGame
        CheckSnakeCollision:
                mov cx, arrayLength
                CheckSnakeCollisionLoop:
                        mov si, offset snakePosX
                        add si, bx
                        mov ax, [si]
                        cmp currentX, ax
                        je checkCollisionY
                        continueCheck:
                        add bx, 2
                        call DrawSegment
                        dec cx
                        cmp cx, 0
                jg CheckSnakeCollisionLoop
                ret
                checkCollisionY:
                        mov si, offset snakePosY
                        add si, bx
                        mov ax, [si]
                        cmp currentY, ax
                        jne continueCheck
                        jmp EndGame
                ; mov currentY, ax
        ret
CheckEndGame endp

CheckAppleCollision proc 
        mov ax, currentX
        mov bx, currentY
        cmp ax, randX
        je xequal
        ret
        xequal:
                cmp bx, randY
                je colided
                ret
        colided:
                inc count
                inc snakeSize
                dec applePresent
                ret

CheckAppleCollision endp

DrawApple proc
        mov ax, currentX
        mov bx, currentY
        push ax
        push bx
                cmp applePresent, 0
                je setCoords
                okk:
                        mov ax, randX
                        mov currentX, ax
                        mov ax, randY
                        mov currentY, ax
                        mov color, 12
                        call DrawSegment
                        mov color, 14
                        jmp exit
                 setCoords:
                call SetAppleCoords
                inc applePresent
                jmp okk
        exit:
        pop bx
        pop ax
        mov currentX, ax
        mov currentY, bx
        ret
DrawApple endp

SetAppleCoords proc near
        ;Setting x for an apple
        SetX:
                call GetRandomNumber
                cmp dx, 80
                jge subX
                mov ax, dx
                xor dx, dx
                mov dx, 4
                mul dx          ;mul to set apple to coords
                mov randX, ax
        SetY:
                call GetRandomNumber
                cmp dx, 30
                jge subY
                mov ax, dx
                xor dx, dx
                mov dx, 4
                mul dx 
                mov randY, ax
                ret
        subX:
                sub dx, 80
                mov randX, dx
                mov ax, dx
                xor dx, dx
                mov dx, 4
                mul dx 
                mov randX, ax
                jmp SetY
        subY:
                cmp dx, 79
                jge subAgain
                continueSub:
                sub dx, 30
                mov randY, dx
                mov ax, dx
                mov dx, 4
                mul dx 
                mov randY, ax
                ret
                subAgain:
                sub dx, 30 
                jmp continueSub

SetAppleCoords endp


GetRandomNumber proc
        mov ah, 0
	int 1Ah        ;getting clock value
        mov ax, dx      ;incremented approximately 18.206 times per second
	mov dx, 7993
	mul dx
        xor dx, dx
        mov cx, 100
        div cx
        ret
        ;random number is in range of 1..100 in dx
GetRandomNumber endp

ListenForInput proc
        ;check which key was pressed
        mov ah, 01h
        int 16h

        jz leaveListenForInput

        mov ah, 00h
        int 16h
        ;w
        cmp al, 77h
        je moveSnakeUp
        ;s
        cmp al, 73h
        je moveSnakeDown
        ;a
        cmp al, 61h
        je moveSnakeLeft
        ;d
        cmp al, 64h
        je moveSnakeRight
        ret

        moveSnakeUp:
                cmp directionY, 0
                jne skip
                mov ax, 0 
                mov bx, -4
                mov directionY, bx
                mov directionX, ax
                ret
        moveSnakeDown:
                cmp directionY, 0
                jne skip
                mov ax, 4
                mov bx, 0
                mov directionY, ax
                mov directionX, bx 
                ret
        moveSnakeLeft:
                cmp directionX, 0
                jne skip
                mov ax, 0
                mov bx, -4
                mov directionY, ax
                mov directionX, bx
                ret
        moveSnakeRight:
                cmp directionX, 0
                jne skip
                mov ax, 0
                mov bx, 4
                mov directionY, ax
                mov directionX, bx
                ret
        skip:
        ret

        leaveListenForInput:
        ret
ListenForInput endp

MoveHead proc
        mov dx, directionX
        mov ax, directionY
        add currentX, dx
        add currentY, ax
        ret
MoveHead endp 

SaveHeadPos proc
        mov cx, 0
                lea si, snakePosY
                mov ax, 2
                mul arrayLength
                add si, ax
                mov ax, currentY
                mov [si], ax
                
                lea si, snakePosX
                mov ax, 2
                mul arrayLength
                add si, ax
                mov ax, currentX
                mov [si], ax

                
                mov ax, arrayLength
                cmp ax, snakeSize
                je rewriteArray
                inc arrayLength

                ret

         rewriteArray:
                ;moving last previous element to n-1 in x coords

                mov cx, 0
                flipLoop:

                                lea si, snakePosX
                                mov ax, 2
                                mul cx
                                add si, ax
                                add si, 2
                                mov bx, [si]
                                sub si, 2
                                mov [si], bx
                                inc cx
                        cmp cx, arrayLength
                        jne flipLoop

                ;moving last previous element to n-1 in y coords
                mov cx, 0
                dec cx
                        flipLoop2:
                                lea si, snakePosY
                                mov ax, 2
                                mul cx
                                add si, ax
                                add si, 2
                                mov bx, [si]
                                sub si, 2
                                mov [si], bx
                                inc cx
                        cmp cx, arrayLength
                        jne flipLoop2
                
        ret
SaveHeadPos endp

DrawSnake proc  
        push cx
                mov bx, 0
                ;mov cx, 3
                mov cx, arrayLength

                DrawSnakeLoop:
                        mov si, offset snakePosX
                        add si, bx
                        mov ax, [si]
                        mov currentX, ax
                        
                        mov si, offset snakePosY
                        add si, bx
                        mov ax, [si]
                        mov currentY, ax
                ; mov currentY, ax
                        add bx, 2
                        call DrawSegment
                        dec cx
                        cmp cx, 0
                jg DrawSnakeLoop

        pop cx
        ret
DrawSnake endp
  
DrawSegment proc 
    push cx
    push dx
        mov cx, currentX
        mov dx, currentY

        
        DrawHorizontal:
            
        mov ah, 0Ch       ;set configuration for writing a pixl
        mov al, color     ;set pixel color
        mov bh, 0         ;set the page number 
        int 10h          
        
        inc cx 
         
        ;cx - currentX > segmentSize (yes - next line, no - continue)
        mov ax, cx
        sub ax, currentX
        cmp ax, segmentSize
        jng DrawHorizontal  
        
        mov cx, currentX   ;goes back to initial column
        inc dx             ;we jump to another line (y) 
        
        ;dx - currentY  > segmentSize (yes - exit proc, no - continue)
        mov ax, dx
        sub ax, currentY
        cmp ax, segmentSize
        jng DrawHorizontal
        
     
    pop dx
    pop cx
    ret   
DrawSegment endp

ClearScreen proc  
        push ax

        mov ah, 08h
        mov bh, 00h
        mov bl, 00h
        int 10h  
        MOV AX,0600H    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
        MOV BH,11H    ;ATTRIBUTE 7 FOR BACKGROUND AND 1 FOR FOREGROUND
        MOV CX,0000H    ;STARTING COORDINATES
        MOV DX,184FH    ;ENDING COORDINATES
        INT 10H        ;FOR VIDEO DISPLAY
        
        pop ax
        ret
ClearScreen endp

OutCountInt proc 
        push bx
        push cx
        push dx
        xor cx, cx
        mov bx, 10
        SplitAndPush:
                xor dx, dx
                div bx
                push dx
                inc cx
                test ax, ax
                jnz SplitAndPush
                mov  dl, 0  ;Column
                mov  dh, 0   ;Row
                mov  bh, 0    ;Display page
                mov  ah, 02h  ;SetCursorPosition
                int  10h
        PopAndDisplay:
                pop ax
                add  ax, '0'
                mov dx, ax
                mov ah, 0Eh
                int 10h
        loop PopAndDisplay
        pop dx
        pop cx
        pop bx
        ret
OutCountInt endp
    
End main

