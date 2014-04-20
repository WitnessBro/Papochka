public main_hw
.model tiny
.code
org 100h
mai: jmp main_hw
	color  db 0h, 10001010b, 01001111b, 00001111b, 00000001b, 00000100b, 01001111b, 10000000b,  00000001b, 		   89h, 4h,         48h,		 15h, 89h, 10000000b, 	   30h
	color2 db  1, 		  0,   		 0, 10000000b, 10000000b, 10000000b,         0,   		1,  01101111b,   01010101b,  0,	  00000011b,   00000100b,   0,         1,   0100001b
	centr2	db ?
	centr	db 10 dup(0), 80, 35 dup (0), 160, 100 dup (0)
	shift	db 7, 7, 8, 8, 0, 0, 0, 8
	shift2	db ?
	TextPage	db 'Page = '
	TextVideo	db 'Video = '

proc main_hw 
	mov bp, sp
	mov ax, [bp+2]
	mov es, ax
	mov ax, [bp+4]
	lea bx, centr
	xlat
	lea si, centr2
	mov [si], ax
	mov di, ax
	mov ax, 2
	mul di
	mov di, ax
	add di, [bp+4]
	call vivod
	mov bx, 0
	mov dl, 218d
	mov es:[di+bx], dl
	mov cx, 31
	mov dl, 196d
ramka:
	add bx, 2
	mov es:[di+bx], dl
	loop ramka
	mov dl, 191d 
	add bx, 2
	mov es:[di+bx], dl
	lea si, centr2
	add di, [si]
	mov cx, 256
	mov dl, 0
	mov bx, 2
	mov si, offset color
	sub di, 2
	mov al, 179d
	mov es:[di+bx], al
	add di, 2
	mov al, [si]
	mov ah, [si+16]
	xor dh, dh
cykl:
	mov es:[di+bx], dl
	mov es:[di+bx+1], al
	add al, ah
	inc dl
	push dx
	add bx, 4
	cmp bx, 64
	jng go
	mov al, 179d
	mov es:[di+bx-2], al
	push si
	lea si, centr2
	add di, [si]
	pop si
	mov bx, 2
	mov es:[di+bx-2], al
	inc si
	mov al, [si]
	mov ah, [si+16]
go:
	pop dx
	loop cykl
	mov bx, 0
	mov dl, 192d
	mov es:[di+bx], dl
	mov cx, 31
	mov dl, 196d
ramka2:
	add bx, 2
	mov es:[di+bx], dl
	loop ramka2
	mov dl, 217d 
	add bx, 2
	mov es:[di+bx], dl
	
	lea si, centr2
	mov bx, [si]
	add bx, 16h
	lea si, TextPage
	mov cx, 7
cykl2:
	mov ax, 15
	mov dx, [si]
	mov es:[di+bx], dx
	mov es:[di+bx+1], ax
	inc si
	add bx, 2
	loop cykl2
	mov bp, sp
	mov dx, [bp+6]
	add dx, 30h
	mov bp, 15
	mov es:[di+bx], dx
	mov es:[di+bx+1], ax
ret
	int 20h
endp main_hw
proc vivod
	lea si, centr2
	mov bx, [si]
	add bx, 16h
	lea si, TextVideo
	mov cx, 8
cykl3:
	mov ax, 15
	mov dx, [si]
	mov es:[di+bx], dx
	mov es:[di+bx+1], ax
	inc si
	add bx, 2
	loop cykl3
	mov dx, [bp+8]
	add dx, 30h
	mov bp, 15
	mov es:[di+bx], dx
	mov es:[di+bx+1], ax
	lea si, centr2
	add di, [si]
	add di, [si]
	ret
endp vivod
end mai