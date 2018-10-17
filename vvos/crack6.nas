; crack6.nas
; tab=4

[INSTRSET "i486p"]
[BITS 32]

		MOV 	EDX, 1000000
		INT 	0x40
		MOV 	EDX, 4
		INT 	0x40