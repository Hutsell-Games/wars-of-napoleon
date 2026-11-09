' Unit tests of the strategic game's SUBs that draw nothing.
' Run from the repo's folder:  qb64rust test tests
'
' Each test runs in a program of its own, so every shared array starts at
' zero. A test sets the few values the SUB reads, calls it and checks what
' the code gives today. These tests record behavior; they do not judge it.
' They cover only what the recorded sessions and games do not show: the 15
' sessions and the generated games already run these SUBs many times
' (docs\port-study.md, step 8). battle_test.bas holds the tactical game's.

'$INCLUDE: '../won.bi'

' -------------------------------------------------------------------- bubble
' Sorts mtx$(1 TO limit) and keeps array() beside it: the lists of cities
' and armies in the menus.

SUB TestBubbleSortsNamesAndTheirIndexes
mtx$(1) = "Vienna": array(1) = 3
mtx$(2) = "Berlin": array(2) = 1
mtx$(3) = "Milan": array(3) = 2
CALL bubble(3)
AssertEqualStr "Berlin", mtx$(1), "first"
AssertEqualStr "Milan", mtx$(2), "second"
AssertEqualStr "Vienna", mtx$(3), "third"
AssertEqualInt 1, array(1), "Berlin's index"
AssertEqualInt 2, array(2), "Milan's index"
AssertEqualInt 3, array(3), "Vienna's index"
END SUB

' Two equal names keep their order: the sort swaps only when the first is
' greater.
SUB TestBubbleKeepsEqualNamesInOrder
mtx$(1) = "Lyon": array(1) = 1
mtx$(2) = "Lyon": array(2) = 2
mtx$(3) = "Bern": array(3) = 3
CALL bubble(3)
AssertEqualStr "Bern", mtx$(1), "first"
AssertEqualInt 3, array(1), "Bern's index"
AssertEqualInt 1, array(2), "the first Lyon stays first"
AssertEqualInt 2, array(3), "the second Lyon stays second"
END SUB

' A list of one, or none, is left as it is.
SUB TestBubbleOfOneOrNoneChangesNothing
mtx$(1) = "Rome": array(1) = 7
mtx$(2) = "Amsterdam": array(2) = 8
CALL bubble(1)
CALL bubble(0)
AssertEqualStr "Rome", mtx$(1), "first"
AssertEqualStr "Amsterdam", mtx$(2), "second, beyond the limit"
AssertEqualInt 7, array(1), "Rome's index"
END SUB

' -------------------------------------------------------------------- normal
' A normal deviate from 12 RND: result = xbar + (sum - 5.5) * SQR(vary),
' stored in an INTEGER (DEFINT A-Z).

SUB TestNormalWithNoVarianceGivesTheMean
CALL normal(10, 0, result)
AssertEqualInt 10, result, "variance 0"
END SUB

' The sum of 12 RND has the mean 6, and the SUB takes away 5.5, so its
' results lean half a standard deviation above xbar. With a standard
' deviation of 10, the mean of 4000 results is near 5, not 0. The game's
' casualties and odds all come through this SUB.
SUB TestNormalLeansHalfADeviationHigh
RANDOMIZE 1
total& = 0
FOR i = 1 TO 4000
	CALL normal(0, 100, result)
	total& = total& + result
NEXT i
AssertNear 5, total& / 4000, 1, "the mean of 4000 results, standard deviation 10"
END SUB
'$INCLUDE: '../won1.bm'
'$INCLUDE: '../won2.bm'
'$INCLUDE: '../wonmenu.bm'
'$INCLUDE: '../qb64.bm'
'$INCLUDE: '../script.bm'
