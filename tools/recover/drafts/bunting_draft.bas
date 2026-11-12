'? B$ENRA()
SCREEN 12
LINE (530, 100)-(638, 380), 2, BF
LINE (535, 280)-(638, 380), 7, BF
LINE (535, 100)-(638, 279), 8, BF
LINE (535, 100)-(639, 380), 4, B
'? B$PSET() after N1I2(580, 200)
DRAW "S7C14E3U2E4U4E3H5E3H6D5"
DRAW "G3F4G4F1G1H7E1H2E3H2E4H3E3H2G5F1G3D1G3D3G2D1F2G2H3U1H2E2H3G3D7F3D5F10R14U2"
PAINT (570, 190), 4, 14
LINE (540, 200)-(630, 300), 7, BF
LINE (540, 200)-(630, 300), 0, B
'? 0896  mov word ptr [bp - 0x14], 0
'? 089e  jmp 0x8d5
'? 08a2  inc word ptr [bp - 0x14]
'? 08a8  sub cx, word ptr [bp - 0x14]
'? 08b5  add ax, 0x24e
LINE (cx, 180)-(ax, local16), 7
'? 08d4  inc ax
'? 08d5  mov word ptr [bp - 0x16], ax
'? 08d8  cmp ax, 0xc8
'? 08db  jle 0x8a2
'? 08e0  jmp 0x920
'? 08e4  shl ax, 1
'? 08e6  shl ax, 1
'? 08e8  shl ax, 1
'? 08ec  add ax, 0x21c
'? ; pushed so far: ax, 230
'? 08f4  mov word ptr [bp - 0x18], bx
'? 08ff  add ax, 0x220
LINE (ax, 230)-(ax, 280), 0, BF
'? 091f  inc ax
'? 0920  mov word ptr [bp - 0x16], ax
'? 0923  cmp ax, 0xa
'? 0926  jle 0x8e4
LINE (540, 250)-(630, 260), 7, BF
LINE (536, 202)-(540, 298), 0, BF
LINE (578, 181)-(569, 200), 0
LINE -(558, 200), 0
LINE -(578, 181), 0
PAINT (572, 190), 0
LINE (540, 280)-(630, 282), 0, B
'? 0a24  jmp 0xa5f
'? ; pushed so far: 570
'? 0a2f  shl ax, 1
'? ; pushed so far: 570
'? 0a31  shl ax, 1
'? ; pushed so far: 570
'? 0a33  add ax, 0x118
'? ; pushed so far: 570, ax
'? 0a37  mov word ptr [bp - 0x1a], ax
LINE (570, ax)-(600, local1a), 0, B
'? 0a5e  inc ax
'? 0a5f  mov word ptr [bp - 0x16], ax
'? 0a62  cmp ax, 5
'? 0a65  jle 0xa28
LINE (566, 280)-(569, 300), 0, BF
LINE (601, 280)-(602, 300), 0, B
DRAW "S4BG80BE102BU81C14E3U2E4U4E3H5E3H6D5"
DRAW "G3F4G4F1G1H7E1H2E3H2E4H3E3H2G5F1G3D1G3D3G2D1F2G2H3U1H2E2H3G3D7F3D5F10R13BH5"
'? B$PNT1(0)
'? 0ad7  emu fld dword ptr [si]
'? 0ada  emu fistp word ptr [bp - 0x1c]
'? 0ade  emu fwait
'? B$PNT1(1)
'? 0aeb  emu fld dword ptr [si]
'? 0aee  emu fistp word ptr [bp - 0x1e]
'? 0af2  emu fwait
PAINT (local1c, local1e), 4, 14
DRAW "BD2BL17BH12BE2BU4BD1BL3C15H2E3H3L2H2L3H1E3H5L4"
DRAW "H2U2H3L3G5H2U2H2U3H3G1L5U4H3G1L2U4H3L2D54F2R4E2F3R2E4F5R2E2F1D1G2D2F1E1"
DRAW "F1E17R8U2BH4BL3BL7"
'? B$PNT1(0)
'? 0b31  emu fld dword ptr [si]
'? 0b34  emu fistp word ptr [bp - 0x1c]
'? 0b38  emu fwait
'? B$PNT1(1)
'? 0b45  emu fld dword ptr [si]
'? 0b48  emu fistp word ptr [bp - 0x1e]
'? 0b4c  emu fwait
PAINT (local1c, local1e), 0, 15
DRAW "C15U1H3G1L1H2L2G2BH5C15U2H2U2H2L1H1U1E2H4L2H1U2H2L2"
DRAW "BG2BD3BG2BD5C15R2F2G1F2E1F3R1D2G2BF5BE13BD69BR1BD1BG1BU1"
DRAW "C14E2H2E3U6E3U2E4D1G1D2G2D3E7U1F1D2G3D2G3D3G2D4G2L4H2BR5"
'? B$PNT1(0)
'? 0b8a  emu fld dword ptr [si]
'? 0b8d  emu fistp word ptr [bp - 0x1c]
'? 0b91  emu fwait
'? B$PNT1(1)
'? 0b9e  emu fld dword ptr [si]
'? 0ba1  emu fistp word ptr [bp - 0x1e]
'? 0ba5  emu fwait
PAINT (local1c, local1e), 4, 14
DRAW "BF50C14E2H2E3U6E3U2E4D1G1D2G2D3E7U1F1D2G3D2G3D3G2D4G2L4H2BR5"
'? B$PNT1(0)
'? 0bd2  emu fld dword ptr [si]
'? 0bd5  emu fistp word ptr [bp - 0x1c]
'? 0bd9  emu fwait
'? B$PNT1(1)
'? 0be6  emu fld dword ptr [si]
'? 0be9  emu fistp word ptr [bp - 0x1e]
'? 0bed  emu fwait
PAINT (local1c, local1e), 4, 14
DRAW "BU45C14E2H2E3U6E3U2E4D1G1D2G2D3E7U1F1D2G3D2G3D3G2D4G2L4H2BR5"
'? B$PNT1(0)
'? 0c1a  emu fld dword ptr [si]
'? 0c1d  emu fistp word ptr [bp - 0x1c]
'? 0c21  emu fwait
'? B$PNT1(1)
'? 0c2e  emu fld dword ptr [si]
'? 0c31  emu fistp word ptr [bp - 0x1e]
'? 0c35  emu fwait
PAINT (local1c, local1e), 4, 14
LINE (638, 350)-(600, 300), 0
LINE -(568, 300), 0
LINE -(600, 380), 0
LINE -(636, 380), 0
LINE -(638, 350), 0
PAINT (600, 320), 8, 0
'? proc:WON2.42(turbo!)
'? B$EXSA()
'? 0d0f  retf 0
