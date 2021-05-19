INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib

VK_LEFT  EQU 000000025h
VK_RIGHT EQU 000000027h

maxcol   EQU 79
GetKeyState PROTO, nVirtKey:DWORD

.data
 player1 BYTE "A",0 
 x1 BYTE 17
 y1 BYTE 0
 
 player2 BYTE "B",0
 x2 BYTE 18
 y2 BYTE 0
 
 floor BYTE "HHHHHHHHHHHHHHH",0
 x_f BYTE 0
 y_f BYTE 20

 x BYTE ?
 y BYTE ?
 
 cnt DWORD ? 
.code
main proc
 
 call displayer1
 call displayer2
L1:
 ;call wall
 call key

 call displayer1
 


 call displayer2
 

 ;call wall
jmp L1
	exit
main endp

key proc
mov ah,0
 INVOKE GetKeyState, VK_RIGHT

 mov bl, x1
 dec bl
 .IF ah && x2 < 79 && x2 != bl
	 invoke Sleep, 30
 mov  dl, x2
 mov  dh, y2
 call Gotoxy       
 mov  al,' '     
 call WriteChar
	inc x2
  .ENDIF
  
INVOKE GetKeyState, VK_LEFT
 mov bl, x1
 inc bl
  .IF ah && x2 > 1 && x2 != bl
   invoke Sleep, 30
 mov  dl, x2
 mov  dh, y2
 call Gotoxy       
 mov  al,' '     
 call WriteChar
	dec x2
  .ENDIF

  INVOKE GetKeyState, 'A'
	mov bl, x2
	inc bl
	.IF ah && x1 > 1 && x1 != bl
	invoke Sleep, 30
 mov  dl, x1
 mov  dh, y1
 call Gotoxy       
 mov  al,' '     
 call WriteChar
	dec x1
  .ENDIF

  INVOKE GetKeyState, 'D'
  mov bl, x2
  dec bl
  .IF ah && x1 < 79 && x1 != bl
  invoke Sleep, 30
 mov  dl, x1
 mov  dh, y1
 call Gotoxy       
 mov  al,' '     
 call WriteChar
  inc x1
  .ENDIF 
key endp

displayer1 proc

 mov dh, y1
 mov dl, x1
 call gotoxy
 mov al, player1
 call writechar
 ret
displayer1 endp

displayer2 proc
 mov dh, y2
 mov dl, x2
 call gotoxy
 mov al, player2
 call writechar
 ret
displayer2 endp


end main