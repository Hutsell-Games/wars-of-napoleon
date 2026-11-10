' Prints all 256 characters as glyphs in SCREEN 12: character c at row c \ 32 + 1, column
' c MOD 32 + 1, in color 15 on 0. tests/dosshot.py reads QB64's 8 x 16 glyphs from its state
' at exit, to draw a SCREEN 0 state as DOSBox-X saves a text screen (720 x 400). Step 3 found
' QB64's 8 x 16 font to be DOSBox-X's, pixel for pixel (docs\devnotes.md, "The fonts").
' _CONTROLCHR OFF makes PRINT draw the control characters too, as a text screen shows them.
SCREEN 12
_CONTROLCHR OFF
COLOR 15
FOR c = 0 TO 255
	LOCATE c \ 32 + 1, c MOD 32 + 1: PRINT CHR$(c);
NEXT c
SYSTEM
