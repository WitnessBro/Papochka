	model	tiny
	.code
	org		100h
	locals
entry:
		jmp	start
		
resident proc
	cmp		ax, 'MV'
	je 	success
	jmp dword ptr cs:[vec]
	iret
success:
	mov		ax, 10
	push 	cs
	pop 	es
	mov 	dx, offset resident
	mov 	bx, word ptr cs:[vec]
    mov 	cx, word ptr cs:[vec + 2]
    iret

vec dd ?
resident endp
end_res	equ	$

TSRSeg dw ?
TSROffs dw ?
env	db	' ', 0, 0, 1, 0, 'mv', 0
env_len	equ	10

start:
	call 	args
	cmp 	al, 1
	je 		install
	cmp 	al, 2
	je 		uninstall
	cmp 	al, 3
	je 		help
	mov		dx, offset m8
	call	print
	ret
help:
	mov 	dx, offset m1
	call 	print
	ret
	
uninstall:
	mov 	ax, 'MV'
	int 	2fh
    cmp 	ax, 10
    je 		already     
    mov 	dx, offset m4
    call	print
    ret
already:
	push 	es
	push 	bx
	mov 	TSRSeg, es
	mov 	TSROffs,	dx
    push 	bx
    push 	cx
	mov 	ax,	352fh
	int 	21h
	mov 	ax, es
	cmp 	ax,	TSRSeg
	jne 	unremoveable
	cli
	mov 	ax,	252fh
	pop 	ds
    pop		dx
    int		21h
    push 	cs
	pop 	ds
	mov 	ah,	49h
	int 	21h
	sti
	mov 	dx, offset m7
	call	print
	jmp 	exit
unremoveable:
	mov	 	dx, offset m6
	call	print
	jmp 	exit
		
exit:
	mov 	ax, 4c00h 
	int 	21h	
Install:
		mov		ax, 'MV'
		int		2Fh
		cmp		ax, 10
		jne		not_installed
		mov 	dx, offset m3
		call 	print
		ret
not_installed:

		mov 	ax, 352fh
		int 	21h
		mov		word ptr cs:[vec], bx
		mov		word ptr cs:[vec + 2], es
	
		mov 	es, cs:[2Ch] 
		mov 	ah, 49h               
		int 	21h 
	
		mov		ax, 4800h
		mov		bx, 1
		int		21h

		lea		si, env
		mov		es, ax
		xor		di, di
		mov		cx, env_len
		rep		movsb
		mov		cs:[2Ch], ax
	
		mov		ax, 252fh
		lea 	dx, resident
		int 	21h
		mov 	dx, offset m2
		call	print
		mov		ax, 3100h
		lea		dx, end_res
		add		dx, 15
		shr		dx, 4
		int 	21h
		
installed:
		mov	dx, offset m3
		mov	ah, 9
		int	21h
		ret

args proc
	mov		si, 80h
	lodsb
	cmp 	al, 3
	jne		bad_str
	inc 	si
nextchar:
	lodsw
	cmp 	ax, 'i-'
    je 		inst
	cmp 	ax, 'u-'
	je		uninst
	cmp 	ax, 'h-'
	je 		helps
	jmp 	bad_str
	
inst:
	mov		al, 1
	ret
uninst:
	mov		al, 2
	ret
helps:
	mov		al, 3

bad_str:
	mov 	al, 4
	ret
args endp

print proc
	mov	 	ah, 9
	int		21h
    ret
print endp


m1		db	13, 10,9,9,9, 'Usage: mv [-i] [-s?] [-u] [-h]', 13, 10, '$'
m2		db	13, 10,9,9,9, 'Installed.', 13, 10, '$'
m3		db	13, 10,9,9,9, 'Resident already installed!', 13, 10, '$'		
m4		db	13, 10,9,9,9, 'Not yet installed!', 13, 10, '$'
m6		db	13, 10,9,9,9, 'Error: Cannot delete resident.', 13, 10, '$'
m7		db	13, 10,9,9,9, 'Uninstalled.', 13, 10, '$'
m8		db	13, 10,9,9,9, 'Something wrong, check your args.', 13, 10, '$'
end		entry		