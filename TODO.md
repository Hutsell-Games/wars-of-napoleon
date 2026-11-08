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

- **The city markers are not DOS's pixel for pixel.** `cityicon` (`WON2.BM`) draws each city with `CIRCLE` of
  radius 4 and 3, then `PAINT`. On session 9's first map, 250 spots of 1 to 4 pixels at the top and bottom of
  the markers differ from the DOSBox-X screenshot, about 280 pixels of the screen. Measure QB 4.5's small
  circles (a `verification\qb45\` program in QB64Rust, as for `LINE`), then decide as for the roads: draw
  them with QB 4.5's pixels in the port, or let `tests\dosshot.py` (step 8) leave them out.
- **The dotted box of the tactical game's help screen** (`help`, `NAP1.BM`: `LINE (0, 280)-(500, 310), 14, B,
  &H101`) is still QB64's `LINE`. A box has only flat and vertical edges, which QB64 draws with the same pixels
  as QB 4.5, but where the dots start on each edge is not measured. The tactical screens are compared by
  character, so it matters only if `tests\dosshot.py` (step 8) compares this screen's pixels.
- **The French armies move elsewhere than in DOS, already in May 1805**, in a replay of session 9. Before the
  battle, the port has an army at Bologna and marches Davout to Köln. Session 9's `03-attack` screenshot has
  French armies at Cherbourg and Rouen. By July one army is near Cherbourg in DOS and at Bologna in the port.
  May's `NWS9.SAV` is equal. The hooks did not cause it: step 4's timed keys gave the same. Find where the
  play parts with step 7's trace mode or QB64Rust's `--trace-values` (`docs\devnotes.md`, "Step 4" and
  "Step 6").

## The game

Each of these is how the game behaves, in DOS too by its code. Decide whether to change it. A change to how the
game plays changes the recorded screens.

- **`BATTLE.$$$` gives the tactical game the attacker's leader twice.** `battle` (`WON1.BM`) writes
  `armylead(attack)` as the 11th field, where the defender's leader is meant. Session 9 wrote
  `"Innsbruck",1,2,1,"Bernadotte",125,5,2,"Alexander",98,5,1,3,0,2`.
- **A battle won by wiping out the other side writes no `OUTCOME.&&&`.** `wipeout` (`NAP1A.BM`) ends the tactical
  game, and `expire` writes the file only when the time is up. The strategic game then reads the result of the
  battle before. The same when the player quits the battle with F10.
