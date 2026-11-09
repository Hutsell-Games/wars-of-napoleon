' Unit tests of the tactical game's SUBs that draw nothing.
' Run from the repo's folder:  qb64rust test tests
'
' Each test runs in a program of its own, so every shared array starts at
' zero. A test sets the few values the SUB reads, calls it and checks what
' the code gives today. These tests record behavior; they do not judge it.
' They cover only what the battles of tests\battles do not show
' (docs\port-study.md, step 8). The French units are 1 to m1 (40), the
' Allies' m2 (41) to most (80). rules_test.bas holds the strategic game's.

'$INCLUDE: '../nap10.bi'

' ------------------------------------------------------------------- Compact
' Moves the units of one side down over the units with no strength left,
' and sets bigg() to the last unit that has some. wipeout calls it after
' each unit that is eliminated.

SUB TestCompactClosesAGap
strength(1) = 500: name$(1) = "Bernadotte"
strength(2) = 0: name$(2) = "lost"
strength(3) = 300: name$(3) = "Lannes": unitx(3) = 12: unity(3) = 7
CALL Compact(1)
AssertEqualInt 500, strength(1), "unit 1 stays"
AssertEqualInt 300, strength(2), "unit 3 moved to 2"
AssertEqualStr "Lannes", name$(2), "its name moved with it"
AssertEqualInt 12, unitx(2), "and its place"
AssertEqualInt 7, unity(2), "and its row"
AssertEqualInt 0, strength(3), "unit 3 is empty"
AssertEqualInt 2, bigg(1), "two units left"
END SUB

' A side with no unit left gives bigg() one below its first unit: 0 for the
' French, 40 for the Allies. That is the side wipeout finds annihilated,
' which no recorded battle reaches.
SUB TestCompactOfASideWithNoUnitLeft
CALL Compact(1)
AssertEqualInt 0, bigg(1), "the French"
CALL Compact(2)
AssertEqualInt m2 - 1, bigg(2), "the Allies"
END SUB

' A side with every unit left keeps them all: bigg() is its last unit.
SUB TestCompactOfAFullSide
FOR k = m2 TO most: strength(k) = 100: NEXT k
CALL Compact(2)
AssertEqualInt most, bigg(2), "every Allied unit"
END SUB

' -------------------------------------------------------------------- normal
' The tactical game's copy of the strategic game's normal (rules_test.bas).

SUB TestNormalLeansHalfADeviationHigh
RANDOMIZE 1
total& = 0
FOR i = 1 TO 4000
	CALL normal(0, 100, result)
	total& = total& + result
NEXT i
AssertNear 5, total& / 4000, 1, "the mean of 4000 results, standard deviation 10"
END SUB
'$INCLUDE: '../nap1.bm'
'$INCLUDE: '../nap1a.bm'
'$INCLUDE: '../nap1c.bm'
'$INCLUDE: '../qb64.bm'
'$INCLUDE: '../napscript.bm'
