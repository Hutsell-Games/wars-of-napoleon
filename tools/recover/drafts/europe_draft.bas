'? B$ENRA()
SCREEN 12
CLS
LINE (0, 0)-(639, 438), 10, B
'? 07dc  mov word ptr [bp - 0x14], ax
'? 07df  cmp word ptr [bp - 0x14], 2
'? 07e3  jne 0x7f7
'? 07e5  mov word ptr [bp - 0x18], 0x3f
'? 07ea  mov word ptr [bp - 0x1a], 0x28
'? 07ef  mov word ptr [bp - 0x1c], 0
'? 07f4  jmp 0x836
'? 07f7  cmp word ptr [bp - 0x14], 3
'? 07fb  jne 0x80f
'? 07fd  mov word ptr [bp - 0x18], 0xa
'? 0802  mov word ptr [bp - 0x1a], 0xa
'? 0807  mov word ptr [bp - 0x1c], 0x1e
'? 080c  jmp 0x836
'? 080f  cmp word ptr [bp - 0x14], 4
'? 0813  jne 0x827
'? 0815  mov word ptr [bp - 0x18], 0x1e
'? 081a  mov word ptr [bp - 0x1a], 0xa
'? 081f  mov word ptr [bp - 0x1c], 0xa
'? 0824  jmp 0x836
'? 0827  mov word ptr [bp - 0x18], 0
'? 082c  mov word ptr [bp - 0x1a], 0x22
'? 0831  mov word ptr [bp - 0x1c], 0
PAINT (200, 200), 2, 10
'? ; pushed so far: 1, 0
'? 0857  cdq
'? B$MUI4(1, 0, 1, local18)
'? 0862  shl cx, 1
'? 0864  shl cx, 1
'? 0866  shl cx, 1
'? 0868  shl cx, 1
'? 086a  shl cx, 1
'? 086c  shl cx, 1
'? 086e  shl cx, 1
'? 0870  shl cx, 1
'? 0872  mov word ptr [bp - 0x1e], dx
'? 0875  mov word ptr [bp - 0x20], ax
'? 087a  cdq
'? 087b  add ax, word ptr [bp - 0x20]
'? 087e  adc dx, word ptr [bp - 0x1e]
'? 0881  mov word ptr [bp - 0x22], dx
'? 0884  mov word ptr [bp - 0x24], ax
'? 088a  cdq
'? 088b  add ax, word ptr [bp - 0x24]
'? 088e  adc dx, word ptr [bp - 0x22]
'? 0891  mov word ptr [bp - 0x28], ax
'? 0894  mov word ptr [bp - 0x26], dx
'? B$PAL2(2, local26, local28)
PSET (1, 240), 10
DRAW "C10R2F1R4F1R11E1R4F1E6U2E2U3E1U3E1U1E1U2E1U1E1U4E1U6E1U4E1U3E2U2E2U2E1H1"
DRAW "U7E2F3D2F1D4F2D1F1E2U2H1U1H1U2H1U7H6U4H2U6E2H4U3H1U4H1U8H7"
DRAW "H8L2H3L3H1L2H3L4H3U2R1E1U1H1U3"
DRAW "E3R2F1R3F2R19F1R6F4R12F1R6E5H2U3H4U3H1U2R7F7R2F4R5F1R4F2R6E2U2H4U3R3F1R6"
DRAW "E4R4U6R12F1R7E4R1E4R2E7R1E2U1E1U3E5R3F1G2D3R1E2R2E1R1F3R1E1U2H2U1H1E2"
DRAW "R2U1E3R1E3R5F1R3F3U4H2U2E4R2F5E3R7F2R3U7R3U5E3H1U1H1U1E3H3E2U4H2U2H4U1"
DRAW "R37D2G8L5D7"
PSET (1, 411), 10
DRAW "C10R5E5R35E5R5E5U5E10U10E5U10E5R5U5H5U5H5U5E5R5E5R5E5U5E5R5E5R10E5R5E10"
DRAW "U10E5R5E5R10F10R5F10R5"
PSET (246, 371), 10
DRAW "C10D10F5R5U5E5U5E5U15H5U5H5L5G5D5G5D5F5D10"
PSET (267, 300), 1
DRAW "C10D5F1D3G1D3G6D2G5H2L1H1U3H1U7R1E2"
DRAW "U3E2R4E2R1E1U2E1R1"
PSET (110, 372), 10
DRAW "C10F1D1F1R1F3R2E3U1H1U2H1L1U2L4G1L2G2"
PSET (100, 369), 10
DRAW "C10L1G2D1F1R3E2H1U1L2"
PSET (128, 357), 10
DRAW "C10F2R1E3H2L1G1L1D1"
PSET (319, 413), 10
DRAW "C10L3H1L3H2L10H2L7G2L1G2D6F4R3F1R2F3R2F5"
DRAW "R4F2R19U2E1U1E5U1E4U1E1U2E1H1L1G1L4G1L4G1L8H2L2"
PSET (345, 416), 10
DRAW "C10R1E2R2E2R2E2R1E1R1E1R1E2U1E1U4E1U1E2R1E1R1E4U5H4U1H1E1U1E1U1E4U1E4R3"
DRAW "F5D1F3R1F3D1F1D2F1D1F1E7H4U3H2U3H14U2H4U3H5U1H1R4E2H9U1H3L1H3U1H2U2H4L1"
DRAW "H7U2H3U10H1U2H1U4H3U2H4U1H5U7E2U5E6U1E3R1E3R1E3"
PSET (346, 416), 10
DRAW "C10U10R5E5U15E5U15H5U5H10L5H15U5H15U5H15U10H5U5H5U5H5L10G5L5G5L15G15L5G5"
DRAW "L10H5"
PSET (353, 235), 10
DRAW "C10R10F10D3F3E3R3F2D5F5D10F5D10F5D5F10D5F10R5F5D10G5D5F5D10G5D10G5D5"
DRAW "F15R15D5F5G5H10L5G10F10"
DRAW "G3D1G1D8"
PSET (247, 17), 10
DRAW "C10R1G1D1G2F5D1R1D2G2F1E1R2F2R4F2R3F1R2D1"
DRAW "G2L3G2D2R5F1R3F1E4R8E1R11E1R3E2R8F1R1F1R1F1R2F2R4F2R3F4R7E8R3E2R9E1R10E2"
DRAW "R10E2R7E2R4E1R1E3R7E1R9E1R3E2R5E1F2D1F3R1F1R8E8R2H2L2H2U1E1R1F1R3F1R1E1"
DRAW "R4E4U3E2U6BG15BL194BH2BL1G2F2R3E2R2E3H2L4G2L1BR7BL2BE5BR7BL3E1R1F2R2E4R1"
DRAW "F2D2G3D4G2L3H2U2H5E1R1BF5BD10L2H2L2G2F1R5E1BR14BE23D4G1F5R3F1R10E1U2E2R2"
DRAW "E1R4E5BG5BD8BL2F3R4E2H1L2H2L2G2"
PSET (100, 1), 10
DRAW "R2F2D5F1D5F1D4F3D6G3L1D2R6E2R10F2R4F2R2F2D2G7D1F2R1F6R3F1G3L1G1L6H1L4H1L4H1L7H1L15"
DRAW "H1L7H2L9G3L2G1L32G4L6G3L7H1E1R2E1R2E4R2E2U1E1U2E5R3E1R5F1R5F1R6F1E5R1E2"
DRAW "L1G1L1G1L3G1L3H2L3H3U1H3L5H3L1H2L6G2H3U5E3R2F1R2F1R4E7U5H2L2G1L7G2H1E3R2"
DRAW "E1R4E2R1F1R4F1R5F3R1E5U1H3"
PSET (443, 438), 10
DRAW "C10U8E3F4R1E1U8H1U5E4"
DRAW "E3R2F5E1"
DRAW "R1E2H4U5H2U3E4R2E5U1E3U2R5F1D4F8E2H2U3R3"
DRAW "F3R2U3H4E2R10F5G1D1F4E4U1E1R3F3"
DRAW "D47"
LINE (472, 408)-(474, 412), 10, BF
LINE (468, 396)-(470, 404), 10, BF
LINE (520, 410)-(522, 412), 10, BF
PAINT (100, 100), 1, 10
PAINT (400, 20), 1, 10
PAINT (200, 350), 1, 10
PAINT (505, 415), 1, 10
'? 0c28  cmp word ptr [bp - 0x16], 2
'? 0c2c  je 0xc31
'? 0c2e  jmp 0xd17
LINE (46, 158)-(200, 195), 10
LINE -(300, 195), 10
LINE -(525, 250), 10
PAINT (100, 300), 3, 10
PAINT (100, 430), 3, 10
PAINT (300, 420), 3, 10
PAINT (260, 310), 3, 10
PAINT (250, 350), 3, 10
'? 0d1d  add bx, word ptr [si + 0xa]
'? 0d20  mov es, word ptr [si + 2]
'? B$DSEG(es)
'? ; pushed so far: "mtn.vga"
'? 0d32  add bx, word ptr [si + 0xa]
'? ; pushed so far: "mtn.vga"
'? 0d35  mov es, word ptr [si + 2]
'? B$BLOD("mtn.vga", bx, 1)
'? B$DSG0()
'? 0d4a  jmp 0xdce
'? 0d4d  nop
'? 0d4e  shl ax, 1
'? 0d55  add bx, word ptr [si + 0xa]
'? 0d58  mov es, word ptr [si + 2]
'? ; pushed so far: word ptr es:[bx]
'? 0d63  add bx, word ptr [si + 0xa]
'? ; pushed so far: word ptr es:[bx]
'? 0d66  mov es, word ptr [si + 2]
'? ; pushed so far: word ptr es:[bx], word ptr es:[bx]
'? 0d6c  mov word ptr [bp - 0x2a], ax
'? B$GPUT(COMMON+0270, COMMON+026e, 702, 3) after N1I2(word ptr es:[bx], word ptr es:[bx])
'? 0d91  add bx, word ptr [si + 0xa]
'? 0d94  mov es, word ptr [si + 2]
'? 0d9a  add ax, 0xa
'? ; pushed so far: ax
'? 0da3  add bx, word ptr [si + 0xa]
'? ; pushed so far: ax
'? 0da6  mov es, word ptr [si + 2]
'? ; pushed so far: ax
'? 0dac  add ax, 0x14
'? B$GPUT(COMMON+0270, COMMON+026e, 702, 3) after N1I2(ax, ax)
'? 0dcd  inc ax
'? 0dce  mov word ptr [bp - 0x2c], ax
'? 0dd1  cmp ax, 0x13
'? 0dd4  jg 0xdd9
'? 0dd6  jmp 0xd4e
'? proc:WON2.25()
'? proc:WON.14()
'? proc:WON2.16()
'? 0deb  jmp 0xdfb
'? 0dee  lea ax, [bp - 0x2e]
'? proc:WON2.40(ax)
'? 0dfa  inc ax
'? 0dfb  mov word ptr [bp - 0x2e], ax
'? 0dfe  cmp ax, 2
'? 0e01  jle 0xdee
'? 0e03  cmp word ptr [0x822], 0
'? 0e08  jg 0xe0d
'? 0e0a  jmp 0xea2
'? B$COLR(1, 14, 2)
'? 0e1e  mov word ptr [bp - 0x1a], 0x8c
'? 0e23  mov word ptr [bp - 0x1c], 0x195
'? B$CASP([53be], 0.25!) after N1I2(local1a, local1c)
'? B$CIRC([53c2], 70!, 13)
PAINT (local1a, local1c), 3, 13
'? 0e6c  sub ax, 0x20
'? 0e6f  mov word ptr [bp - 0x30], ax
'? 0e75  sub ax, 8
'? 0e78  mov word ptr [bp - 0x32], ax
'? ; pushed so far: "RAID COMMERCE"
'? 0e7f  lea ax, [bp - 0x36]
'? B$SAS1("RAID COMMERCE", ax)
'? 0e88  mov word ptr [bp - 0x38], 0
'? 0e8d  lea ax, [bp - 0x30]
'? ; pushed so far: ax
'? 0e91  lea ax, [bp - 0x32]
'? ; pushed so far: ax, ax
'? 0e95  lea ax, [bp - 0x36]
'? ; pushed so far: ax, ax, ax
'? 0e99  lea ax, [bp - 0x38]
'? proc:WON2.41(ax, ax, ax, ax)
'? proc:WON2.37()
'? B$EXSA()
'? 0eac  retf 0
