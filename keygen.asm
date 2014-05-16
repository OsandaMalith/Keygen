.386 
.model flat,stdcall 
option casemap:none 

include			windows.inc 
include			kernel32.inc 
include			user32.inc
include			ufmodapi.inc
includelib		kernel32.lib
includelib		user32.lib 
includelib		ufmod.lib
includelib		winmm.lib

DlgProc			proto		:DWORD,:DWORD,:DWORD,:DWORD
FadeIn      		proto		:DWORD
FadeOut		    	proto		:DWORD
Generate		proto		:DWORD

.data 
include chiptune.inc
xmSize equ $ - table
Hash1			dd		026h
Hash2			dd		034h
Hash3			dd		0ch
Hash4			dd		0eh
FormatControl		db		"%d-",0
EndFormatControl 	db		"%d",0
AboutTxt		db		"A Keygen coded for Fun :D",10,13
			db		"Coded by Osanda",10,13
			db		"Written in MASM",10, 13
			db		"Don't follow one field, be a all rounder",10, 13
			db		"I live in the deep low level and in higher high levels", 0
AboutCap		db		"About",0

.data? 
hInstance		HINSTANCE	?  
Transparency		dd		?
NameBuffer		db		40 dup(?) 
SerialBuffer		db		40 dup(?)
SerialSection		db		32 dup(?)

.const
IDD_KEYGEN		equ		1001
IDC_EXIT		equ		1002
IDC_COPY		equ		1003 
IDC_ABOUT		equ		1004
IDC_NAME		equ		1005
IDC_SERIAL		equ		1006
ICON			equ		2001
LWA_ALPHA		equ		2
LWA_COLORKEY		equ		1
WS_EX_LAYERED		equ		80000h
DELAY_VALUE		equ		10

.code 
start: 
	invoke GetModuleHandle,NULL 
	mov hInstance,eax 
	invoke DialogBoxParam,hInstance,IDD_KEYGEN,NULL,addr DlgProc,NULL 
	invoke ExitProcess,eax 
    
DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
	.if uMsg == WM_INITDIALOG
		invoke GetWindowLong,hWnd,GWL_EXSTYLE 
		or eax,WS_EX_LAYERED 
		invoke SetWindowLong,hWnd,GWL_EXSTYLE,eax 
		invoke SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE	
		invoke LoadIcon,hInstance,ICON 
		invoke SendMessage,hWnd,WM_SETICON,1,eax
		invoke GetDlgItem,hWnd,IDC_NAME
		invoke SetFocus,eax 
		invoke uFMOD_PlaySong,addr table,xmSize,XM_MEMORY
		invoke FadeIn,hWnd
	.elseif uMsg==WM_LBUTTONDOWN							
		invoke SendMessage,hWnd,WM_NCLBUTTONDOWN,HTCAPTION,lParam
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		.if ax==IDC_NAME
			shr eax,16
		.if ax==EN_CHANGE
			invoke Generate,hWnd
		.endif
	.elseif eax==IDC_ABOUT
		invoke MessageBox,hWnd,addr AboutTxt,addr AboutCap,MB_OK	
	.elseif eax==IDC_COPY
		invoke SendDlgItemMessage,hWnd,IDC_SERIAL,EM_SETSEL,0,-1 
		invoke SendDlgItemMessage,hWnd,IDC_SERIAL,WM_COPY,0,0 
	.elseif eax==IDC_EXIT 
		invoke	SendMessage,hWnd,WM_CLOSE,0,0
	.endif
	.elseif	uMsg== WM_CLOSE
		invoke FadeOut,hWnd	
		invoke uFMOD_PlaySong,0,0,0 
		invoke EndDialog,hWnd,0 
	.endif        
	xor eax,eax
	ret 
DlgProc endp 

FadeIn proc hWnd:HWND
	invoke ShowWindow,hWnd,SW_SHOW
	mov Transparency,75
@@:
	invoke SetLayeredWindowAttributes,hWnd,0,Transparency,LWA_ALPHA
	invoke Sleep,DELAY_VALUE
	add Transparency,5
	cmp Transparency,255
	jne @b
	ret 
FadeIn endp

FadeOut proc hWnd:HWND
	mov Transparency,255
@@:
	invoke SetLayeredWindowAttributes,hWnd,0,Transparency,LWA_ALPHA
	invoke Sleep,DELAY_VALUE
	sub Transparency,5
	cmp Transparency,0
	jne @b
	ret
FadeOut endp

Generate proc hWnd:HWND
	invoke GetDlgItemText,hWnd,IDC_NAME,addr NameBuffer,40 
	mov edi,offset NameBuffer
	invoke lstrlen,edi	
	mov esi,eax			        
	xor ecx,ecx
	xor eax,eax			
	test esi,esi
	jle NOINPUT				
    mov edx,Hash1			
@@:						
	movsx ebx,byte ptr [eax+edi]
	add ebx,edx		
	add ecx,ebx		
	inc eax				
	cmp eax,esi		
	jl @b				
	invoke wsprintf,addr SerialBuffer,addr FormatControl,ecx 
	xor ecx,ecx			
	mov eax,ecx			
	mov edx,Hash2			
@@:						
	movsx ebx,byte ptr [eax+edi]
	imul ebx,edx	
	add ecx,ebx	
	inc eax			
	cmp eax,esi	
	jl @b			
	invoke wsprintf,addr SerialSection,addr FormatControl,ecx
	invoke lstrcat,addr SerialBuffer,addr SerialSection        
	xor ecx,ecx		
	mov eax,ecx		
	mov edx,Hash3		
@@:
	movsx ebx,byte ptr [eax+edi]
	add ebx,edx	
	add ecx,ebx
	inc eax
	cmp eax,esi
	jl @b
	invoke wsprintf,addr SerialSection,addr FormatControl,ecx
	invoke lstrcat,addr SerialBuffer,addr SerialSection
	xor ecx,ecx	
	mov eax,ecx	
	mov edx,Hash4	
@@:
	movsx ebx,byte ptr [eax+edi]
	imul ebx,edx	
	add ecx,ebx
	inc eax
	cmp eax,esi
	jl @b
	invoke wsprintf,addr SerialSection,addr EndFormatControl,ecx
	invoke lstrcat,addr SerialBuffer,addr SerialSection
	invoke SetDlgItemText,hWnd,IDC_SERIAL,addr SerialBuffer
	xor eax,eax
	ret
NOINPUT:
	invoke RtlZeroMemory,addr SerialBuffer,40
	invoke SetDlgItemText,hWnd,IDC_SERIAL,addr SerialBuffer
	xor eax,eax
    ret				
Generate endp

end start 


