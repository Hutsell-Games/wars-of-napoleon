# Minimal Changes to Get Wars of Napoleon Running with QB64

## Introduction
The code changes needed to get WON up and running in QB64 (plus maybe a few more). The goal is to get a stable baseline version that runs in QB64 on which further enhancements can be built.

## File Management
- Delete unneeded compilation related files - e.g. *.TMP, *.MAK
- Move all data related files into data, all images into images.
- Deleted old binaries: ARCH2.EXE, NAPIC.EXE, NAPOLEON.EXE, TACTICAL.EXE, VIC.EXE, WON.EXE
- Deleted PRINTDOC.BAT, REGISTER.DOC, WRHGAMES.DOC, SHAREW.TXT, GO.BAT
- Created a docs folder and moved appropriate files into it.

## Basic Code Cleanup
- Remove old DOS special characters, e.g. "�"