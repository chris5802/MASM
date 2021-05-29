INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib

GetKeyState PROTO, nVirtkey:DWORD ;判斷按鍵狀況

mGoTo MACRO indexX:REQ, indexY:REQ  ;移動游標   
 PUSH edx
 MOV dl, indexX
 MOV dh, indexY
 call Gotoxy
 POP edx
ENDM

mWrite MACRO drawText:REQ   ;劃出圖像
 LOCAL string
 .data
  string BYTE drawText, 0
 .code
  PUSH edx
  MOV edx, OFFSET string
  call WriteString
  POP edx
ENDM

VK_LEFT EQU 000000025h   ;左方向鍵
VK_RIGHT EQU 000000027h  ;右方向鍵


.data  ;this is the data area

InitialPos_X3 EQU 50        ;角色1起始位置X
InitialPos_Y3 EQU 0      ;角色1起始位置Y
CurrentPos_X3 BYTE InitialPos_X3   ;角色1當前位置X
CurrentPos_Y3 BYTE InitialPos_Y3   ;角色1當前位置Y
Player3 EQU 'hhhhhhhhh'
cnt DWORD ?
Array BYTE  100 DUP(?) 
num DWORD ?

Wall EQU '|'    ;牆壁

Min_X EQU 30   
Max_X EQU 91   ;地圖寬
Min_Y EQU 0 
Max_Y EQU 30   ;地圖高

flag BYTE 0



.code ;this is the code area

main proc

  call ShowWall
  call ShowRole

  Invoke ExitProcess,0 
main endp

;----------------------------------------
;     畫出人物      
;----------------------------------------
ShowRole  PROC 
  call Randomize
  mov num,0

 Drop:
 .IF CurrentPos_Y3 > Max_Y
   mov esi,0
 dec CurrentPos_Y3
 jnl L1    ;跳出迴圈
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

    cmp CurrentPos_Y3 ,0  ;如果y小於0
    mov esi,29
   
    Jl L2                  ;跳到L2

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

   cmp esi ,0  ;如果y大於29
   mov num, 0
   mov CurrentPos_Y3,30
   Jl L1                 ;跳到Ll

   INVOKE Sleep,10
   Loop L2

   EndDrop: 
  
 ret
ShowRole ENDP

;----------------------------------------
;     畫出牆壁      
;----------------------------------------
ShowWall PROC USES eax
 
 mov al,Min_Y

 WallLoop:
  cmp al,Max_Y    ;eax < Max_Y?
  jnl EndWall     ;跳出迴圈

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
;     輸入
;----------------------------------------


end main