INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO dwExitCode:DWORD

.data		;this is the data area

map BYTE 100 DUP('0')					;宣告地圖大小
count DWORD 10								;雙重迴圈中每個迴圈的大小 地圖
position DWORD 5							;紀錄當前位置

.code	;this is the code area


main proc
	

	mov esi,position
	mov map[esi],'1'
	
	
	mov ecx,count
	L1:
		call Print_Map									
		
		mov esi,position
		mov al,map[esi]
		add esi,count
		xchg map[esi],al
		sub esi,count
		mov map[esi],al
		
		mov eax,position
		add eax,count
		mov position,eax

		
		call Clrscr
		loop L1

	

	Invoke ExitProcess,0	
main endp

;-----------------------------------------   印出地圖  ------------------------------------------

Print_Map proc USES  esi ecx

	mov ecx,count		
	mov esi,OFFSET map

	mov map[32],'1'
	
	L1:
		push ecx
		
		mov ecx,count								;inner loop count

		Print_Map_inner_loop:
			mov eax,[esi]							;將map當前的數值移動到eax
			call WriteChar							;印出字元
			
			inc esi										;每次往後移動伊格位置
			loop Print_Map_inner_loop

		call crlf
		pop ecx
		loop L1

		ret
Print_Map endp
	
end main