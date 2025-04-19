; multi-segment executable file template.

data segment
    ; add your data here!
    
    received DB 059h,083h,0E1h,0B9h,047h,016h ;simulazione
    r_l equ $-received
    stringa DB 'Received: 010 110 011 000 001 111 100 001 101 110 010 100 011 100 010 110'
    DB 10,13,10,13 ;line feed e carriege return, due volte
    DB 'Decoded: '
    decoded DB 16 dup(48) ;16 perche' ogni 3 byte ci sono 8 triplette e quindi 8 bit, inserisco ogni bit in ogni by di decoded
    d_l equ $-decoded 
    DB 10,13,10,13,'$';fine stringa per stampa
    pkey db "press any key...$"
ends

stack segment
    DB   128  dup('S')
ends
    
code segment
;----------------
;   PROCEDURE   |
;----------------

tripletta PROC NEAR
        XOR CX,CX
        PUSH DI
        PUSH SI ;salvo gli indici nello stack
        
        MOV BP,SP ;indice stack
        MOV DH,11100000b ;maschera
        MOV BX,[BP] ;copia dell'indice di received
        MOV AL,received[BX]
   
        ;condizione che mi garantisce l'uscita dopo 8 triplette
   trip:CMP CH,8
        JE end_trip
        
        CMP CH,2 ;quando ho fatto le prime 2 triplette
        JE cong_1
        CMP CH,5 ;quando ho fatto le prime 5 triplette
        JE cong_2
        
        ;1a tripletta intera nel byte
        
        PUSH AX
        PUSH BP
        MOV BP,SP
        MOV AX,[BP+2] ;copia di AL
        POP BP
        AND AL,DH ;applico maschera, ottengo i primi 3 bit piu' significativi
        SHR AL,5 ;adesso sono i meno significativi
        CALL count ;conta i bit di maggioranza e scrive il risultato in decoded
        INC CH ;incremento il contatore di triplette fatte
        POP AX ;ripristino il byte (di received) in AL liberandolo dallo stack
        
        ;2a tripletta intera nel byte
        
        PUSH AX
        PUSH BP
        MOV BP,SP
        MOV AX,[BP+2];copia
        POP BP
        SHL AL,3 ;sposto per ottenere i 3 bit successivi piu' significativi, eliminando quelli che precedono a sinistra
        AND AL,DH ;ERRORE: ho omesso di applicare la maschera
        SHR AL,5
        CALL count
        INC CH
        POP AX
        
 return:
        JMP trip
 
 end_trip:
        
        POP SI
        POP DI
RET

cong_1 PROC NEAR
    MOV AL,received[BX];resetto il byte per il quale ho appena lavorato le prime 2 triplette "intere"
    AND AL,00000011b; applico maschera ad hoc per estrarre 2 bit meno significativi
    SHL AL,1; creo posto per il bit rimanente presente nel byte successivo di received
    INC CH;incremento contatore triplette lavorate
    INC BX;incremento indice received
    MOV AH,received[BX]
    AND AH,10000000b;estraggo il bit piu' significativo dal byte successivo
    SHR AH,7;lo rendo il meno significativo
    OR AL,AH;congiunzione dei bit
    CALL count
    MOV AL,received[BX];resetto il nuovo byte
    SHL AL,1;slitto di 1
    JMP return
RET

cong_2 PROC NEAR
    MOV AL,received[BX];resetto il byte per il quale ho appena lavorato le prime 2 triplette "intere", shiftate precedentemente a sinistra
    AND AL,00000010b; applico maschera ad hoc per estrarre il penultimo bit meno significativo (perche' precedentemente shiftato a sx di 1)
    SHL AL,2; creo posto per i 2 bit rimanenti presenti nel byte successivo di received
    INC CH;incremento contatore triplette lavorate
    INC BX;incremento indice received
    MOV AH,received[BX]
    AND AH,11000000b;estraggo i 2 bit piu' significativi dal byte successivo
    SHR AH,6;li rendo i meno significativi
    OR AL,AH;congiunzione dei bit
    CALL count
    MOV AL,received[BX];ERRORE: ho omesso di scrivere l'indice [CL], resetto il nuovo byte
    SHL AL,2;slitto di 2
    JMP return
RET

count PROC NEAR
        PUSH CX
        XOR CX,CX
        PUSH BX
        XOR BX,BX
  loopc:CMP CL,3
        JE end_loopc
        
        PUSH AX
        PUSH BP
        MOV BP,SP
        MOV AX,[BP+2]
        POP BP
        AND AL, 00000001b
        CMP AL,1
        JNE non_uno
        INC CH ;contatore uni
 non_uno:
        POP AX
        SHR AL,1;deve shiftare a destra di 1
        INC CL
        JMP loopc
 end_loopc:
        MOV AL,CH ;scrivo in AL il risultato anche se inutile potevo usare direttamente CH
        
        ;---------------------------------------------------------------------------------------------------------------
        ;   PARTE MANCANTE COMPITO, salvataggio bit in decoded e incremento DI nello stack, ovvero indice di decoded   |
        ;---------------------------------------------------------------------------------------------------------------
        
        MOV BX,[BP+2] ;ci metto DI indice di decoded
        CMP CH,2 ;se CH e' piu' piccolo di 2, allora il bit e' zero altrimenti 1
        JL zero
        MOV decoded[BX],49
   zero:;tutti i byte di decoded sono gia' inzializzati a zero
        INC BX ;incremento BX indice di decoded
        MOV [BP+2], BX ;salvo l'indice incrementato nello stack
        POP BX
        POP CX
        ;-------------------------
        ;   FINE PARTE MANCANTE  |
        ;-------------------------
RET        
                  
            
;--------------------
;   FINE PROCEDURE  |
;--------------------            

start:
    ; set segment registers:
        mov ax, data
        mov ds, ax
        mov es, ax
    
        ; add your code here
        
        XOR CX,CX
        XOR BX,BX
        XOR DX,DX
        XOR AX,AX
        
        XOR SI,SI ;indice received
        XOR DI,DI ;indice decoded
        
   loop:CMP DI,d_l ;indice decoded, appena arriva a fine termina il programma
        JE end_loop
        CALL tripletta
        ADD SI,3 ;scorro received di 3 byte
        ;ADD DI,8 ;ERRORE, non devo scorrere decoded di 3 ma di 8 byte
        ;non serve, lo incremento ad ogni count nello stack
        JMP loop
end_loop:
        ;-----------------------
        ;stampa stringa decoded|
        ;-----------------------
                       
        lea dx, stringa
        mov ah, 9
        int 21h
        
        ;----------------
        ;fine codice mio|
        ;----------------
         
        lea dx, pkey
        mov ah, 9
        int 21h        ; output string at ds:dx
        
        ; wait for any key....    
        mov ah, 1
        int 21h
        
        mov ax, 4c00h ; exit to operating system.
        int 21h    
ends

end start ; set entry point and stop the assembler.
