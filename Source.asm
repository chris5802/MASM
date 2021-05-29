INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib

GetKeyState PROTO, nVirtkey:DWORD ;�P�_���䪬�p

mGoTo MACRO indexX:REQ, indexY:REQ  ;���ʴ��   
 PUSH edx
 MOV dl, indexX
 MOV dh, indexY
 call Gotoxy
 POP edx
ENDM

mWrite MACRO drawText:REQ   ;���X�Ϲ�
 LOCAL string
 .data
  string BYTE drawText, 0
 .code
  PUSH edx
  MOV edx, OFFSET string
  call WriteString
  POP edx
ENDM

VK_LEFT EQU 000000025h   ;����V��
VK_RIGHT EQU 000000027h  ;�k��V��


.data  ;this is the data area

InitialPos_X3 EQU 50        ;����1�_�l��mX
InitialPos_Y3 EQU 0      ;����1�_�l��mY
CurrentPos_X3 BYTE InitialPos_X3   ;����1��e��mX
CurrentPos_Y3 BYTE InitialPos_Y3   ;����1��e��mY
Player3 EQU 'hhhhhhhhh'
cnt DWORD ?
Array BYTE  100 DUP(?) 
num DWORD ?

Wall EQU '|'    ;���

Min_X EQU 30   
Max_X EQU 91   ;�a�ϼe
Min_Y EQU 0 
Max_Y EQU 30   ;�a�ϰ�

flag BYTE 0



.code ;this is the code area

main proc

  call ShowWall
  call ShowRole

  Invoke ExitProcess,0 
main endp

;----------------------------------------
;     �e�X�H��      
;----------------------------------------
ShowRole  PROC 
  call Randomize
  mov num,0

 Drop:
 .IF CurrentPos_Y3 > Max_Y
   mov esi,0
 dec CurrentPos_Y3
 jnl L1    ;���X�j��
   .ENDIF

   mov eax, 15
   call RandomRange
   cmp eax, 4
   jg L1

   mov ebx, 12
   mul ebx
   add eax, 31
   
   
   mov CurrentPos_X3, al
   push  eax
   
   mGoTo CurrentPos_X3,CurrentPos_Y3
   mWrite Player3
   
   add CurrentPos_Y3, 2

  jmp Drop

  

  L1:
    
    pop eax

    mov CurrentPos_X3,al

    mGoTo CurrentPos_X3,CurrentPos_Y3
    mWrite '            '

    sub CurrentPos_Y3,2

    cmp CurrentPos_Y3 ,0  ;�p�Gy�p��0
    mov esi,29
   
    Jl L2                  ;����L2

    mov esi, num
    mov array[esi], al
    inc esi
    mov num,esi

    mGoTo CurrentPos_X3,CurrentPos_Y3
    mWrite Player3
    
        loop L1

    L2:

 
   mov al,array[esi] 
   push eax
   
 .IF esi==0
   mov eax, 5
   call RandomRange
   mov ebx, 12
   mul ebx
   add eax, 31

   mov CurrentPos_X3, al
   push  eax

  mov CurrentPos_Y3,30
  mGoTo CurrentPos_X3,CurrentPos_Y3
   ; mWrite Player3

  .ENDIF
   dec esi

   cmp esi ,0  ;�p�Gy�j��29
   mov num, 0
   mov CurrentPos_Y3,30
   Jl L1                 ;����Ll

   INVOKE Sleep,10
   Loop L2

   EndDrop: 
  
 ret
ShowRole ENDP

;----------------------------------------
;     �e�X���      
;----------------------------------------
ShowWall PROC USES eax
 
 mov al,Min_Y

 WallLoop:
  cmp al,Max_Y    ;eax < Max_Y?
  jnl EndWall     ;���X�j��

  mGoTo Min_X,al
  mWrite Wall
  mGoTo Max_X,al
  mWrite Wall
  inc eax
  jmp WallLoop
 
 EndWall:
  
 ret
ShowWall ENDP

;----------------------------------------
;     ��J
;----------------------------------------


end main