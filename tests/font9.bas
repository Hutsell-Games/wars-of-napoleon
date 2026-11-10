' Prints every character that PRINT draws as a glyph in SCREEN 9: character c at row
' c \ 32 + 1, column c MOD 32 + 1, in color 15 on 0. tests/play.py builds it with the
' screen hook and reads QB64's 8 x 14 glyphs from its state at exit, to compare the
' tactical game's text with DOS's by character (QB64Rust's DIVERGENCES-QB45.md, Q-023).
' The control characters that PRINT acts on are left out.
SCREEN 9
COLOR 15
FOR c = 0 TO 255
	SELECT CASE c
		CASE 7, 9, 10, 11, 12, 13, 28, 29, 30, 31
		CASE ELSE
			LOCATE c \ 32 + 1, c MOD 32 + 1: PRINT CHR$(c);
	END SELECT
NEXT c
SYSTEM
