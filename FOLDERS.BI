' ===========================================================================
' FOLDERS.BI - the folders that hold the game's data files, relative to the
' folder the game runs in. The DOS game kept every file beside the program.
' Included by WON.BI and NAP10.BI. The forward slash works on Windows too.
' DOS takes only "\", so tools\pdsbuild.py gave the PDS 7.1 build "\" (the
' bridge, retired: docs\devnotes.md, item 60).
' ===========================================================================
CONST GFXDIR = "graphics/"      ' pictures (.VGA) and icon sets (.EGA) of both programs
CONST SCNDIR = "scenarios/"     ' GAMEDATA.INI, the scenarios (NWS*.INI, EURO*.MAP, LEAD*.DAT), the tactical game's .DAT files
