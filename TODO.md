# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\port-study.md`.

## The port

- **Linux** (row 17 of the plan). Both programs open lower-case names of upper-case files: `"battle.$$$"`,
  `"nws.cfg"`, `'won.bi'`, `'nap10.bi'` and others. That works on Windows only. The copy of the history file
  (`SHELL "copy nws.his oldhist.ory"`) is a Windows command too.

- **Show the pictures of the DOS programs in the game** (D6 (b) of the plan). `ARCH2.EXE`, `VIC.EXE` and
  `NAPIC.EXE` have no source, and the port no longer runs them. Their screens are in `docs\` (`ARCH2.png`,
  `VIC.png`, `NAPIC.png`). The game could show them with `_LOADIMAGE` where it ran the programs. The QB64 user
  on the panel would like this for all four games at once.

## The tests

- **`WIDTH , 60` resets the palette in QB64, and PDS 7.1 kept it.** The City Report (`WON2.BM` line 1292)
  shows the "(peace)" rows in 00AA00 where DOS showed `europe`'s 008A00 (session 1, `12-cities`). Measure it
  in QB 4.5 and PDS 7.1 with a `verification\qb45\` program in QB64Rust, give it a `DIVERGENCES-QB45.md` row,
  then decide whether the port sets entry 2 again after the `WIDTH`.
- **`tests\play.py` does not compare text screens** (8 of the 305 shots). That is `tests\dosshot.py` of step 8.

- **The city markers are not DOS's pixel for pixel.** `cityicon` (`WON2.BM`) draws each city with `CIRCLE` of
  radius 4 and 3, then `PAINT`. On session 9's first map, 250 spots of 1 to 4 pixels at the top and bottom of
  the markers differ from the DOSBox-X screenshot, about 280 pixels of the screen. The tactical game's
  charging infantry has the same difference: `SHOWUNIT` (`NAP1.BM`) draws `CIRCLE (x + 6, y + 6), 4, c` over
  the icon (battles b3 and b4). Measure QB 4.5's small circles (a `verification\qb45\` program in QB64Rust,
  as for `LINE`), then decide as for the roads: draw them with QB 4.5's pixels in the port, or let
  `tests\dosshot.py` (step 8) leave them out.
- **The dotted box of the tactical game's help screen** (`help`, `NAP1.BM`: `LINE (0, 280)-(500, 310), 14, B,
  &H101`) is still QB64's `LINE`. A box has only flat and vertical edges, which QB64 draws with the same pixels
  as QB 4.5, but where the dots start on each edge is not measured. The tactical screens are compared by
  character, so it matters only if `tests\dosshot.py` (step 8) compares this screen's pixels.
- **No battle reaches `scriptend("W")`** (`NAP1A.BM`, the end of `wipeout`): one side wiped out while time is
  left. Battles b1 to b4 end in `over`, and b5 at F10. `wipeout` ends the battle only when every unit
  of one side is gone, not only its general. A battle for it needs a side small enough to destroy: a
  `BATTLE.$$$` whose VP field for that side is 1 or 2 (the game multiplies it by 100, `NAPOLEON.BAS`), with
  the other side attacking. A hand-written tactical script of step 8 (D10) could do it.
- **Which lines round the tactical game's losses differently.** Battles b2 and b3 lose a few men more or fewer
  in QB64 than in DOS: 639 against 640, 1,618 against 1,622, 12,591 against 12,590, 5,608 against 5,609
  (`docs\devnotes.md`, "Step 7b: the tactical references"). The likely lines are INTEGERs set from SINGLE
  products, D12's kind, which stays QB64's by D12 (a). A logging copy, as for session 5's missing wait, would
  name them, for D12's list and `docs\SOMEDAY.md`'s (b).

## The game

Each of these is how the game behaves, in DOS too by its code. Decide whether to change it. A change to how the
game plays changes the recorded screens.

- **`BATTLE.$$$` gives the tactical game the attacker's leader twice.** `battle` (`WON1.BM`) writes
  `armylead(attack)` as the 11th field, where the defender's leader is meant. Session 9 wrote
  `"Innsbruck",1,2,1,"Bernadotte",125,5,2,"Alexander",98,5,1,3,0,2`.
- **A battle won by wiping out the other side writes no `OUTCOME.&&&`.** `wipeout` (`NAP1A.BM`) ends the tactical
  game, and `expire` writes the file only when the time is up. The strategic game then reads the result of the
  battle before. The same when the player quits the battle with F10.
- **A small random army keeps all its cavalry.** In `randarm` (`NAP1.BM`), a unit that is to be cavalry
  (`armx = 2`) in an army of fewer than 11 units should become infantry half the time: `IF allarm < 11 … THEN
  amrx = 4`. The line sets `amrx`, and the rest of the SUB reads `armx`, so it only draws an `RND`. A fix
  changes which units the tactical game makes.
