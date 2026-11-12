SUB flashcity (which)
FOR c = 1 TO 15 STEP 2
CIRCLE (cityx(which), cityy(which)), 4, 0
CIRCLE (cityx(which), cityy(which)), 3, c
PAINT (cityx(which), cityy(which)), c, c
CALL TICK(.1)
NEXT c
CALL cityicon(which)
END SUB
