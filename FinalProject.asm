INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO dwExitCode:DWORD

.data		;this is the data area

map BYTE 100 DUP('0')					;�ŧi�a�Ϥj�p
count DWORD 10								;�����j�餤�C�Ӱj�骺�j�p �a��
position DWORD 5							;������e��m

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

;-----------------------------------------   �L�X�a��  ------------------------------------------

Print_Map proc USES  esi ecx

	mov ecx,count		
	mov esi,OFFSET map

	mov map[32],'1'
	
	L1:
		push ecx
		
		mov ecx,count								;inner loop count

		Print_Map_inner_loop:
			mov eax,[esi]							;�Nmap��e���ƭȲ��ʨ�eax
			call WriteChar							;�L�X�r��
			
			inc esi										;�C�����Ჾ�ʥ���m
			loop Print_Map_inner_loop

		call crlf
		pop ecx
		loop L1

		ret
Print_Map endp
	
end main