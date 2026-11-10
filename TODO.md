# To do

Open work on the QB64 port (branch `qb64rust`). Remove an item when it is done. The plan is
`docs\port-study.md`.

## The port

- **Show the pictures of the DOS programs in the game** (D6 (b) of the plan). `ARCH2.EXE`, `VIC.EXE` and
  `NAPIC.EXE` have no source, and the port no longer runs them. Their screens are in `docs\` (`ARCH2.png`,
  `VIC.png`, `NAPIC.png`). The game could show them with `_LOADIMAGE` where it ran the programs. The QB64 user
  on the panel would like this for all four games at once.

## The tests

- **Run the Linux check again after changes.** `play.py check` passed on Linux under Xvfb on 2026-11-09
  (WSL, QB64Rust's Linux build), against the references recorded on Windows (`docs\devnotes.md`, item 58).
  Nothing runs it on its own. It could be a job of `.github\workflows\build.yml`, or a step run by hand before
  a merge.
- **Later, not part of the port's steps: draw the small circles and sloped lines with QB 4.5's pixels** (user,
  2026-11-09: "not part of this process, don't want to get slowed down"). Step 8 measured QB 4.5's small
  `CIRCLE`s (QB64Rust's `verification\qb45\q45_circle_pixels`, `DIVERGENCES-QB45.md` Q-036). QB64 lights other
  pixels for 3 of 10 radii in `SCREEN 12` and 8 of 10 in `SCREEN 9`, and for the game's ellipses. That is the
  city markers (radius 4), the ships (radius 18, aspect .4), the "RAID COMMERCE" mark (radius 70, aspect .25),
  the tombstone (radius 8, aspect .4) and the charging units of the tactical game (radius 4 in `SCREEN 9`). The
  solid sloped `LINE`s differ too (Q-025): an army's pointer, the burning building, the picture of naval
  combat. `tests\known-differences.txt` leaves all of them out until then. The roads were redrawn this way
  (`styledline`, user, 2026-11-07); here it would be a SUB per shape, and nearly every map shot's reference
  recorded again.
- **The dotted box of the tactical game's help screen** (`help`, `NAP1.BM`: `LINE (0, 280)-(500, 310), 14, B,
  &H101`) is still QB64's `LINE`, and where its dots start is not measured. No recorded shot shows the help
  screen, so nothing compares it.
- **No script reaches `scriptend("W")`**, a battle won by wiping out the other side. Step 8 tried about 50
  battles: a small Allied or French army (200 to 1,000 men), high and low leadership, a fort for extra turns,
  and seeds 1 to 8, with the player resting or advancing south (b2's and b4's keys). Every battle ended in
  `over`: the time ran out with the small side still on the map, having lost a few hundred men at most. An
  army of 200 men has no unit at all, and the battle ends at once (`unitsize&`, `NAPOLEON.BAS`). A script that
  steers the player's units onto the enemy is needed, with the map's terrain in mind. One of the tries found
  the `over(3)` bug, now fixed, and became battle b6. `Compact`'s empty side, which
  `wipeout` meets, has a unit test (`tests\battle_test.bas`), and so has `writeoutcome`, which `wipeout` now
  calls (`docs\devnotes.md`, item 61).
- **No script reaches Napoleon's exile** (`WON1.BM` lines 1070 to 1086: "Napoleon removed to Corsica", or
  "banished to St. Helena" when Corsica is occupied). Napoleon's own army, army 1, must surrender or be
  crushed. A script would play the Allies and send large armies against him for several turns.
- **What coverage finds no script reaching** (`play.py coverage`, 2026-11-09: 88.2% of the strategic game's
  lines, 73.9% of the tactical game's). In the strategic game, `newcity` and `roman` (`WON1.BM`, `WON2.BM`)
  never run. In the tactical game, `help` and `report` never run, and less than half of `order`, the keys of a
  player's unit: the battles only rest, retreat, quit, step south and ask Intell. A battle that moves, fires
  and asks for help and the report would reach most of it. `tests\out\qb64\coverage\subs-*.txt` lists the SUBs.

## The game

Each of these is how the game behaves, in DOS too by its code. Decide whether to change it. A change to how the
game plays changes the recorded screens. Three were fixed on 2026-11-10 (`docs\devnotes.md`, item 61); each
fix gets a line in `tests\known-differences.txt` where the port then differs from a DOS recording.

- **The retreat's penalty takes 20% of one unit, not of the army.** The strategic retreat (F9, `NAP1.BM`)
  and now the F10 quit add `.2 * strength(side)` to the side's losses. `strength()` is indexed by unit, so
  this is unit 1's strength for the French and unit 2's for the Allies. Unit 2 is a French unit: the Allies'
  units start at 41 (`m2`).
- **`normal` leans half a standard deviation high.** Both programs draw their casualties and odds from
  `normal` (`WON2.BM` and `NAP1A.BM`), which adds 12 `RND` and takes away 5.5. The sum's mean is 6, so the
  results come out half a standard deviation above the mean they are given. `TestNormalLeansHalfADeviationHigh`
  in both unit test files records it. A fix (5.5 to 6) changes every battle.
