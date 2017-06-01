﻿.386
.model flat,stdcall
option casemap:none
include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
include C:\masm32\include\comctl32.inc

includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\include\comctl32.lib


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
Paint_Proc proto :DWORD,:DWORD
Tempo_Proc proto :DWORD,:DWORD,:DWORD
clearScreen proto :DWORD,:DWORD
IDB_MAIN   equ 1
IDB_MAIN1  equ 2
IDB_FIG    equ 3
IDB_APPLE  equ 4


.data
ClassName db "SimpleWin32ASMBitmapClass",0
AppName  db "Win32ASM Simple Bitmap Example",0

hBitmap  dd 0
hBitmap2 dd 0
hBitmap3 dd 0
hBitmap4 dd 0

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?

rectFundo RECT <>
hBitmap dd ?
rect RECT <>
estado db ?


.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov    CommandLine,eax
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.while TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.break .if (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.endw
	mov     eax,msg.wParam
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT
   LOCAL hdc:HDC
   LOCAL hMemDC:HDC
   .if uMsg==WM_CREATE
      invoke LoadBitmap,hInstance,IDB_FIG
      mov hBitmap,eax

      invoke LoadBitmap,hInstance,IDB_MAIN1
      mov hBitmap2,eax

      invoke LoadBitmap,hInstance,IDB_MAIN
      mov hBitmap3,eax

      invoke LoadBitmap,hInstance,IDB_APPLE
      mov hBitmap4,eax

    ;  invoke Tempo_Proc,hWnd,hdc,1

      mov   rect.left,2
      mov   rect.top,2
      mov   rect.right,500
      mov   rect.bottom,500
      mov   estado,0
; chamar Bitblt ao criar para criar pano de fundo
      invoke GetClientRect,hWnd,addr rectFundo

   .elseif uMsg==WM_CHAR
      cmp   wParam,'d'
      jne   nao
      add   rect.left, 6
      add   rect.right, 6
      ;invoke Tempo_Proc,hWnd,hdc,1
 
nao:
      cmp   wParam,'a'
      jne   nao1
      sub   rect.left, 6
      sub   rect.right, 6

nao1:
      cmp   wParam,'s'
      jne   nao2
      add   rect.top, 6

nao2:
      cmp   wParam,'w'
      jne   nao3      
      sub   rect.top, 6
      sub   rect.top, 6

nao3:
      not   estado
      invoke InvalidateRect, hWnd, NULL, FALSE

   .elseif uMsg==WM_PAINT
      invoke BeginPaint,hWnd,addr ps
      mov hdc,eax
      invoke CreateCompatibleDC,hdc
      mov hMemDC,eax

;      invoke SelectObject,hMemDC,hBitmap
;      invoke BitBlt,hdc,200,200,200,200,hMemDC,150,150,SRCCOPY
;      invoke SelectObject,hMemDC,hBitmap3
;      invoke BitBlt,hdc,rect.left,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
;      invoke DeleteDC,hMemDC

      invoke SelectObject,hMemDC,hBitmap
      invoke BitBlt,hdc,0,0,10000,10000,hMemDC,50,10,MERGECOPY	


      cmp   estado,0
      jne   fig2
fig1:
      invoke SelectObject,hMemDC,hBitmap3
      invoke BitBlt,hdc,rect.left,rect.top,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
     
      invoke Paint_Proc,hWnd,hdc

     ;invoke Tempo_Proc,hWnd,hdc,1
 ;    invoke DeleteDC,hMemDC
      jmp    fim  
fig2:    
      invoke SelectObject,hMemDC,hBitmap4
      invoke BitBlt,hdc,100,1000,130,1030,hMemDC,0,0,SRCCOPY

      invoke SelectObject,hMemDC,hBitmap2
      invoke BitBlt,hdc,rect.left,rect.top,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
      mov ecx,rect.left
      add ecx,20
      mov edx,rect.top
      add edx,20
      invoke Rectangle,hdc,rect.left,rect.top,ecx,edx
      invoke Paint_Proc,hWnd,hdc

  ;    invoke DeleteDC,hMemDC
fim:
      invoke DeleteDC,hMemDC

     
      invoke EndPaint,hWnd,addr ps
	.elseif uMsg==WM_DESTROY
      invoke DeleteObject,hBitmap
		invoke PostQuitMessage,NULL
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp

Paint_Proc proc hWin:DWORD, hDC:DWORD

    LOCAL hPen      :DWORD
    LOCAL hPenOld   :DWORD
    LOCAL hBrush    :DWORD
    LOCAL hBrushOld :DWORD

    LOCAL lb        :LOGBRUSH

    invoke CreatePen,0,1,00000000h  
    mov hPen, eax

    mov lb.lbStyle, BS_SOLID
    mov lb.lbColor, 00FF0000h       
    mov lb.lbHatch, NULL

    invoke CreateBrushIndirect,ADDR lb
    mov hBrush, eax

    invoke SelectObject,hDC,hPen
    mov hPenOld, eax

    invoke SelectObject,hDC,hBrush
    mov hBrushOld, eax

  ; ------------------------------------------------
  ; The 4 GDI functions use the pen colour set above
  ; and fill the area with the current brush.
  ; ------------------------------------------------

    mov ecx,rect.left
    add ecx,20
    mov edx,rect.top
    add edx,20
    invoke Rectangle,hDC,rect.left,rect.top,ecx,edx

   invoke CreatePen,0,1,000000h  
    mov hPen, eax

    mov lb.lbStyle, BS_SOLID
    mov lb.lbColor, 999000h       
    mov lb.lbHatch, NULL

    invoke CreateBrushIndirect,ADDR lb
    mov hBrush, eax

    invoke SelectObject,hDC,hPen
    mov hPenOld, eax

    invoke SelectObject,hDC,hBrush
    mov hBrushOld, eax
    mov lb.lbColor, 000000h  
    invoke Rectangle,hDC,100,200,110,210
  ; ------------------------------------------------

    invoke SelectObject,hDC,hBrushOld
    invoke DeleteObject,hBrush

    invoke SelectObject,hDC,hPenOld
    invoke DeleteObject,hPen

    ret

Paint_Proc endp



Tempo_Proc proc hWin:DWORD, hDC:DWORD, movit:DWORD 


    LOCAL hOld :DWORD
    LOCAL memDC:DWORD
    LOCAL var1 :DWORD
    LOCAL var2 :DWORD
    LOCAL var3 :DWORD

    invoke CreateCompatibleDC,hDC
    mov memDC, eax

    .if movit == 0
  ; -------------------
  ; for normal repaint
  ; -------------------
      invoke BitBlt,hDC,10,10,265,550,memDC,0,0,SRCCOPY

    .else
  ; --------------------------
  ; when you press the button
  ; --------------------------
    ; ********************************************************

    mov var3, 0         ;botão foi apertado, a animação vai começar,
         ;a imagem vai para a direita

    .while var3 < 1     ;<< set the number of times image is looped

      mov var1, 0       ;vai do zero ao 310, que é o tamanho necessário       
      .while var1 < 305 ;para a animação ocorrer de forma certa
      ; ------------------------------------------------
      ; Read across the double bitmap 1 pixel at a time
      ; and display a set rectangle size on the screen
      ; ------------------------------------------------      

      mov ecx,var1
      add ecx,20
      invoke Rectangle,hDC,var1,10,ecx,110 ;muda a
      ;invoke clearScreen,hWin,hDC


      ; -----------------------
      ; Simple delay technique
      ; -----------------------
        invoke GetTickCount
        mov var2, eax
        add var2, 10    ; nominal milliseconds delay

        .while eax < var2
          invoke GetTickCount
        .endw

        inc var1       ;para a imagem avançar
      .endw

    inc var3
    .endw

    ; ********************************************************

    .endif

    invoke SelectObject,hDC,hOld
    invoke DeleteDC,memDC

    ret

Tempo_Proc endp



clearScreen proc hWin:DWORD, hDC:DWORD

    LOCAL hPen      :DWORD
    LOCAL hPenOld   :DWORD
    LOCAL hBrush    :DWORD
    LOCAL hBrushOld :DWORD

    LOCAL lb        :LOGBRUSH

    invoke CreatePen,0,1,00FFFFFFh
    mov hPen, eax

    mov lb.lbStyle, BS_SOLID
    mov lb.lbColor, 00FFFFFFh       ;white
    mov lb.lbHatch, NULL

    invoke CreateBrushIndirect,ADDR lb
    mov hBrush, eax

    invoke SelectObject,hDC,hPen
    mov hPenOld, eax

    invoke SelectObject,hDC,hBrush
    mov hBrushOld, eax

  ; ------------------------------------------------
  ; The 4 GDI functions use the pen colour set above
  ; and fill the area with the current brush.
  ; ------------------------------------------------

    invoke Rectangle,hDC,0,0,10000,10000
  ; ------------------------------------------------

    invoke SelectObject,hDC,hBrushOld
    invoke DeleteObject,hBrush

    invoke SelectObject,hDC,hPenOld
    invoke DeleteObject,hPen

    ret

clearScreen endp


end start


