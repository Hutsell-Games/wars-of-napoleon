DEFINT A-Z
DECLARE SUB align (index%, x%, y%)
DECLARE SUB arrange (who%, xloc%, yloc%)
DECLARE SUB brittle (who%)
DECLARE SUB despair (index%)
DECLARE SUB squares (index%, flag%)
DECLARE SUB namer (file$, s%, F%, a$)
DECLARE SUB arrange (who%, xloc%, yloc%)
DECLARE SUB Near1 (index%, Enemy%, near%)
DECLARE SUB over (flag%)
DECLARE SUB randarm (k%)
DECLARE SUB randmap ()
DECLARE SUB replace (y%, x%, z%)
DECLARE SUB routed (index%, flag%)
DECLARE SUB startmap ()
DECLARE SUB vistarg (active%, flag%)
REM $INCLUDE: 'nap10.bi'
CALL napstart: CLS

choose = 22: GOSUB lodecfg
mdly! = mdsp: IF mdsp = 5 THEN mdly! = 10
OPEN "I", 1, "equip.dat"
	FOR k = 0 TO 5: INPUT #1, equip$(k): NEXT k
CLOSE #1
CALL iconload
menu6:
	ON ERROR GOTO 0
menu7:
	SCREEN 9
	IF quiet > 0 THEN SOUND 1900, 1: SOUND 2000, 1

hilite = 14
OPEN "I", 1, "battle.$$$"
INPUT #1, SCENARIO$, side, sidex(1), sidex(2), commander$(sidex(1)), vp&(sidex(1)), leadbase(sidex(1)), expbase(sidex(1)), commander$(sidex(2)), vp&(sidex(2)), leadbase(sidex(2)), expbase(sidex(2)), difficult, fort, quiet
CLOSE #1
CALL randmap
setupx = 1 + INT(4 * RND)
timelimit = 25 + 5 * fort
IF vp&(1) > 200 AND vp&(2) > 200 THEN timelimit = 40 + 5 * fort
IF side = sidex(2) THEN
	timelimit = timelimit + 10
	bold = 3
	IF RND > .5 THEN bold = 4: IF RND > .5 THEN bold = 5
END IF
timelimit = timelimit + .1 * obstruct
unitsize& = vp&(1): IF vp&(2) > vp&(1) THEN unitsize& = vp&(2)
unitsize& = 3 * unitsize&
IF unitsize& < 500 THEN unitsize& = 500
bigg(2) = most
FOR k = 1 TO 2
vp&(k) = vp&(k) * 100           'scale up unit size
NEXT k
FOR k = 1 TO 2
CALL randarm(k)
NEXT k
seelimit = 18: IF RND > .8 THEN seelimit = 10 + INT(9 * RND)
name$(1) = commander$(1)
name$(41) = commander$(2)
IF name$(41) = "Napoleon" THEN
	leader(41) = 5: xper(41) = 5: morale(41) = 5
END IF
FOR k = 1 TO most
	IF strength(k) > 0 THEN
		z = ASC(MID$(sdtext$((unity(k) + 1)), unitx(k), 1))
		terrain(k) = z
	END IF
NEXT k

FOR i = 1 TO 2
	k = sidex(i)
	a = leader(1): IF k = 1 THEN a = leader(41)
	elan(k) = 80 + 5 * (expbase(k) - 3) + 5 * (a - 3)
	CALL brittle(k)
NEXT i

TICK 2
flag = 1
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ  ******************    BEGIN MAIN GAME LOOP    ******************  บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
ON ERROR GOTO 0
SCREEN 9, , 0, 0
CALL mainmap
	CALL clrbot: COLOR 4: PRINT "Initializing";
	FOR i = 1 TO 2: CALL Compact(i): NEXT i
	CALL lowtime
	FOR k = 1 TO bigg(2): Visible(k) = 0
	IF strength(k) > 0 AND uorder(k) <> 99 AND terrain(k) = 233 THEN CALL victory(k)
	NEXT k

	s = 1: F = bigg(side): IF side = 2 THEN s = m2
	FOR active = s TO F: IF strength(active) > 0 AND uorder(active) <> 99 THEN Visible(active) = 1: CALL see(active)
	NEXT active

	startit! = TIMER
IF file$ = "ERROR" GOTO menu7
CALL refresh
    
nother: CALL order: IF LEN(file$) > 1 GOTO nother
' SYSTEM, not END: QB64's END waits for a key, and won.exe waits for this program.
IF file$ = "๔" THEN file$ = "": CALL scriptend("Q"): SYSTEM
IF file$ = "๕" THEN file$ = "": flag = 0: GOTO menu7
GOTO nother
'ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
'บ  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ    END   MAIN GAME LOOP    ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  บ
'ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
lodecfg:
	RESTORE
	FOR k = 1 TO 5: READ adj1$(k): NEXT k
	FOR k = 1 TO 5: READ adj2$(k): NEXT k
	FOR k = 1 TO 5: READ adj3$(k): NEXT k
	FOR k = 1 TO 2: READ sname$(k): NEXT k
	FOR k = 1 TO 5: READ xplev$(k): NEXT k
	FOR k = 1 TO 5: READ ledlev$(k): NEXT k
	FOR k = 1 TO 5: READ morlev$(k): NEXT k
	bold = 3: seelimit = 18: side = 1: mdsp = 3
	limber = 1
	rely = 4: stakk = 3: lineofsight = 1: artcap = 1
	RETURN

DATA Timid,Cautious,Normal,Bold,Reckless
DATA Very Easy,Easy,Normal,Hard,Very Hard
DATA VERY Fast,Fast,Normal,Slow,VERY Slow
DATA Allies,French
DATA Green,Raw,Veteran,Seasoned,Hardened
DATA Inept,Weak,Good,Strong,Brilliant
DATA Beaten,Low,Good,High,Fearless

' $INCLUDE: 'nap1.bm'
' $INCLUDE: 'nap1a.bm'
' $INCLUDE: 'nap1c.bm'
' $INCLUDE: 'qb64.bm'
' $INCLUDE: 'napscript.bm'
