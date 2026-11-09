# Someday

Ideas for the QB64 port that are not planned. Each was put off on purpose. The plan is `docs\port-study.md`, the
open work `TODO.md`.

## Round SINGLE results as DOS did (D12 (b))

**What.** Rewrite each line that stores a SINGLE expression in an INTEGER, so that QB64 rounds it as PDS 7.1 did.
The old compilers keep the x87's precision across the whole expression until it is stored. QB64 rounds each
SINGLE step first. So `x1 = .7 * x1` with 5 stores 3 in DOS and 4 in QB64.

**Why it would help.** A player's battles would come out as in DOS. The check of step 7b found the rounding in
four of the 15 sessions (`docs\devnotes.md`, "The check"):

- sessions 9 and 10: Innsbruck, `WON1.BM` line 136. Odds of 42% against DOS's 50%. In session 10 the
  strategic game decides the battle from them, and the game takes another course from there;
- session 5: a comparison, not a store. `IF cash(s) >= .2 * armysize(i)` (`WON2.BM` line 636) gives an army
  one more supply in QB64. Months later a supply loop draws one more `RND`, and a naval combat ends one shot
  sooner (`docs\devnotes.md`, "Session 5's missing wait");
- session 4: three numbers of `NWS9.SAV` off by one.

With the rewrite, those sessions could be held to their recordings to the end.

**What it takes.** The panel's view, 2026-11-09:

- a search for every store of a SINGLE expression in an INTEGER, and every comparison with one, by type
  (QB64Rust's `--dump typed`). Not only a constant times an INTEGER: sums, divisions and `SQR` round the same
  way;
- a form of the line measured in PDS 7.1, QB 4.5, QB64Rust and QB64pe, until QB64 gives the old compilers'
  integers. `.7 * CDBL(x)` is not it: QB64 takes `.7` as the DOUBLE 0.7, not the SINGLE widened;
- the bridge (`tools\pdsbuild.py`) showing that each edited line is unchanged in PDS;
- the strategic game first, the tactical game when its references are made.

**Status.** The user kept D12 (a) on 2026-11-09, after the check, and asked for this row.
