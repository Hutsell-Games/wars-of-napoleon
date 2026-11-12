'? B$ENRA()
'? 97f9  mov word ptr [bp - 0x14], 0
'? proc:WON2.02()
'? 9803  cmp word ptr [0x3d6], 1
'? 9808  je 0x980d
'? 980a  jmp 0x9818
'? proc:WON2.38()
'? 9812  mov word ptr [0x2b6], 0
'? 981b  jmp 0x98b1
'? 981e  shl ax, 1
'? 9825  add bx, word ptr [si + 0xa]
'? 9828  mov es, word ptr [si + 2]
'? 982b  cmp word ptr es:[bx], 0
'? 982f  jg 0x9834
'? 9831  jmp 0x98ad
'? 9839  add bx, word ptr [si + 0xa]
'? 983c  mov es, word ptr [si + 2]
'? 983f  cmp word ptr es:[bx], 0
'? 9843  jg 0x9848
'? 9845  jmp 0x98ad
'? 984b  shl bx, 1
'? 9852  add bx, word ptr [si + 0xa]
'? 9855  mov es, word ptr [si + 2]
'? 985b  mov word ptr [bp - 0x16], ax
'? 9863  add bx, word ptr [si + 0xa]
'? 9866  mov es, word ptr [si + 2]
'? 986c  mov word ptr [bp - 0x18], ax
'? 986f  mov word ptr [bp - 0x1a], 1
'? 9874  lea ax, [bp - 0x16]
'? ; pushed so far: ax
'? 9878  lea ax, [bp - 0x18]
'? ; pushed so far: ax, ax
'? 987c  lea ax, [bp - 0x1a]
'? ; pushed so far: ax, ax, ax
'? 9880  mov word ptr [bp - 0x1e], dx
'? proc:WON.08(ax, ax, ax)
'? 9890  add bx, word ptr [si + 0xa]
'? 9893  mov es, word ptr [si + 2]
'? 9899  mov word ptr es:[bx], ax
'? 98a1  add bx, word ptr [si + 0xa]
'? 98a4  mov es, word ptr [si + 2]
'? 98aa  mov word ptr es:[bx], ax
'? 98b0  inc ax
'? 98b1  mov word ptr [bp - 0x1c], ax
'? 98b4  cmp ax, 0x32
'? 98b7  jg 0x98bc
'? 98b9  jmp 0x981e
'? proc:WON2.12()
'? B$PSSD("press any key for ")
'? 98ce  shl bx, 1
'? 98d0  shl bx, 1
'? 98d5  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(",")
'? B$PSI2(year)
'? B$PSSD(" events")
'? 98f9  emu fld dword ptr [0x2ada]
'? 98fe  emu fstp dword ptr [bp - 0x22]
'? 9902  emu fwait
'? 9904  lea ax, [bp - 0x22]
'? proc:WON2.42(ax)
'? B$GOSA()
'? 9918  jmp 0x9b6e
'? 991c  shl ax, 1
'? 9923  add bx, word ptr [si + 0xa]
'? 9926  mov es, word ptr [si + 2]
'? 9929  mov word ptr es:[bx], 0x3e7
'? 9933  add bx, word ptr [si + 0xa]
'? 9936  mov es, word ptr [si + 2]
'? 9939  cmp word ptr es:[bx], 0
'? 993d  jge 0x994c
'? 9941  add bx, word ptr [si + 0xa]
'? 9944  mov es, word ptr [si + 2]
'? 9947  mov word ptr es:[bx], 0
'? 994f  shl bx, 1
'? 9956  add bx, word ptr [si + 0xa]
'? 9959  mov es, word ptr [si + 2]
'? 995c  cmp word ptr es:[bx], 0
'? 9960  jle 0x99ac
'? 9967  add bx, word ptr [si + 0xa]
'? 996a  mov es, word ptr [si + 2]
'? 996d  cmp word ptr es:[bx], 0
'? 9971  jle 0x99ac
'? 9973  mov word ptr [bp - 0x24], dx
'? B$RND0()
'? 997d  emu fld dword ptr [si]
'? 9980  emu fmul dword ptr [0x2784]
'? 9985  emu fadd dword ptr [0x2784]
'? 998a  emu fwait
'? B$INT4()
'? 9991  emu fmul dword ptr [0x2c02]
'? 9996  emu fiadd word ptr [bp - 0x1c]
'? 99a0  add bx, word ptr [si + 0xa]
'? 99a3  mov es, word ptr [si + 2]
'? 99a6  emu (seg 3) fistp word ptr [bx]
'? 99aa  emu fwait
'? 99af  shl bx, 1
'? 99b6  add bx, word ptr [si + 0xa]
'? 99b9  mov es, word ptr [si + 2]
'? 99bc  cmp word ptr es:[bx], 1
'? 99c0  jge 0x99e7
'? 99c7  add bx, word ptr [si + 0xa]
'? 99ca  mov es, word ptr [si + 2]
'? 99cd  cmp word ptr es:[bx], 0
'? 99d1  jle 0x99e7
'? 99d6  add ax, 0x384
'? 99de  add bx, word ptr [si + 0xa]
'? 99e1  mov es, word ptr [si + 2]
'? 99e4  mov word ptr es:[bx], ax
'? 99ea  shl bx, 1
'? 99f1  add bx, word ptr [si + 0xa]
'? 99f4  mov es, word ptr [si + 2]
'? 99fa  mov word ptr [bp - 0x26], ax
'? 99fd  cmp word ptr [bp - 0x26], 0x190
'? 9a02  jg 0x9a07
'? 9a04  jmp 0x9a3a
'? 9a0c  add bx, word ptr [si + 0xa]
'? 9a0f  mov es, word ptr [si + 2]
'? 9a12  cmp word ptr es:[bx], 0x384
'? 9a17  jge 0x9a37
'? 9a1b  add bx, word ptr [si + 0xa]
'? 9a1e  mov es, word ptr [si + 2]
'? 9a24  add ax, 0x64
'? 9a29  add bx, word ptr [si + 0xa]
'? 9a2c  mov es, word ptr [si + 2]
'? 9a2f  mov word ptr es:[bx], ax
'? 9a32  mov word ptr [bp - 0x28], 2
'? 9a37  jmp 0x9ac3
'? 9a3a  cmp word ptr [bp - 0x26], 0x320
'? 9a3f  jg 0x9a44
'? 9a41  jmp 0x9a7c
'? 9a47  shl bx, 1
'? 9a4e  add bx, word ptr [si + 0xa]
'? 9a51  mov es, word ptr [si + 2]
'? 9a54  cmp word ptr es:[bx], 0x320
'? 9a59  jge 0x9a79
'? 9a5d  add bx, word ptr [si + 0xa]
'? 9a60  mov es, word ptr [si + 2]
'? 9a66  add ax, 0xc8
'? 9a6b  add bx, word ptr [si + 0xa]
'? 9a6e  mov es, word ptr [si + 2]
'? 9a71  mov word ptr es:[bx], ax
'? 9a74  mov word ptr [bp - 0x28], 3
'? 9a79  jmp 0x9ac3
'? 9a7c  cmp word ptr [bp - 0x26], 0x3e8
'? 9a81  jg 0x9a86
'? 9a83  jmp 0x9abe
'? 9a89  shl bx, 1
'? 9a90  add bx, word ptr [si + 0xa]
'? 9a93  mov es, word ptr [si + 2]
'? 9a96  cmp word ptr es:[bx], 0x2bc
'? 9a9b  jge 0x9abb
'? 9a9f  add bx, word ptr [si + 0xa]
'? 9aa2  mov es, word ptr [si + 2]
'? 9aa8  add ax, 0x12c
'? 9aad  add bx, word ptr [si + 0xa]
'? 9ab0  mov es, word ptr [si + 2]
'? 9ab3  mov word ptr es:[bx], ax
'? 9ab6  mov word ptr [bp - 0x28], 4
'? 9abb  jmp 0x9ac3
'? 9abe  mov word ptr [bp - 0x28], 1
'? 9ac6  shl bx, 1
'? 9acd  add bx, word ptr [si + 0xa]
'? 9ad0  mov es, word ptr [si + 2]
'? 9ad3  cmp word ptr es:[bx], 0x3e7
'? 9ad8  jne 0x9add
'? 9ada  jmp 0x9b6a
'? 9add  mov word ptr [bp - 0x2a], dx
'? B$RND0()
'? 9ae7  emu fld dword ptr [di]
'? 9aea  emu fmul dword ptr [0x28ae]
'? 9af7  add bx, word ptr [si + 0xa]
'? 9afa  mov es, word ptr [si + 2]
'? 9afd  emu (seg 3) fild word ptr [bx]
'? 9b01  emu fwait
'? B$FCMP()
'? 9b08  ja 0x9b0d
'? 9b0a  jmp 0x9b6a
'? 9b12  add bx, word ptr [si + 0xa]
'? 9b15  mov es, word ptr [si + 2]
'? 9b20  add bx, word ptr [si + 0xa]
'? 9b23  mov es, word ptr [si + 2]
'? 9b2b  mov word ptr [bp - 0x2c], cx
'? 9b31  cdq
'? 9b32  idiv cx
'? 9b37  imul cx
'? 9b39  sub ax, word ptr [bp - 0x2c]
'? 9b3c  neg ax
'? 9b46  add bx, word ptr [si + 0xa]
'? 9b49  mov es, word ptr [si + 2]
'? 9b4c  mov word ptr es:[bx], ax
'? 9b51  add bx, word ptr [si + 0xa]
'? 9b54  mov es, word ptr [si + 2]
'? 9b57  cmp cx, word ptr es:[bx]
'? 9b5a  jle 0x9b6a
'? 9b5c  add cx, word ptr [bp - 0x1c]
'? 9b61  add bx, word ptr [si + 0xa]
'? 9b64  mov es, word ptr [si + 2]
'? 9b67  mov word ptr es:[bx], cx
'? 9b6d  inc ax
'? 9b6e  mov word ptr [bp - 0x1c], ax
'? 9b71  cmp ax, 0x32
'? 9b74  jg 0x9b79
'? 9b76  jmp 0x991c
'? 9b79  mov word ptr [bp - 0x2e], 0x32
'? 9b7e  lea ax, [bp - 0x2e]
'? proc:WON2.03(ax)
'? 9b8a  jmp 0xadee
'? 9b8e  mov word ptr [bp - 0x14], 0
'? 9b93  shl ax, 1
'? 9b9a  add bx, word ptr [si + 0xa]
'? 9b9d  mov es, word ptr [si + 2]
'? 9ba0  cmp word ptr es:[bx], 0x3e7
'? 9ba5  jne 0x9baa
'? 9ba7  jmp 0xaea3
'? 9bad  shl bx, 1
'? 9bb4  add bx, word ptr [si + 0xa]
'? 9bb7  mov es, word ptr [si + 2]
'? 9bba  emu (seg 3) fild word ptr [bx]
'? 9bbe  emu fdiv dword ptr [0x2c02]
'? 9bc3  mov word ptr [bp - 0x32], dx
'? 9bc6  emu fwait
'? B$INT4()
'? 9bcd  emu fistp word ptr [bp - 0x34]
'? 9bd1  emu fwait
'? 9bd6  add bx, word ptr [si + 0xa]
'? 9bd9  mov es, word ptr [si + 2]
'? 9be6  imul word ptr [bp - 0x34]
'? 9be9  sub cx, ax
'? 9beb  mov word ptr [bp - 0x34], cx
'? 9bee  mov word ptr [bp - 0x36], 1
'? 9bf3  cmp cx, 0x19
'? 9bf6  jle 0x9bfd
'? 9bf8  mov word ptr [bp - 0x36], 2
'? 9c00  shl bx, 1
'? 9c05  add bx, word ptr [si + 0xa]
'? 9c08  mov es, word ptr [si + 2]
'? 9c0b  cmp word ptr es:[bx], 1
'? 9c0f  jge 0x9c14
'? 9c11  jmp 0xadea
'? B$COLR(1, 11, 2)
'? proc:WON2.12()
'? 9c2d  shl bx, 1
'? 9c2f  shl bx, 1
'? 9c34  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" is moving to ")
'? 9c49  shl bx, 1
'? 9c50  add bx, word ptr [si + 0xa]
'? 9c53  mov es, word ptr [si + 2]
'? 9c59  shl ax, 1
'? 9c5b  shl ax, 1
'? 9c62  add bx, word ptr [si + 0xa]
'? ; pushed so far: bx
'? 9c66  mov word ptr [bp - 0x38], dx
'? B$PSSD(bx)
'? 9c76  add bx, word ptr [si + 0xa]
'? 9c79  mov es, word ptr [si + 2]
'? 9c7f  dec ax
'? 9c82  add bx, word ptr [si + 0xa]
'? 9c85  mov es, word ptr [si + 2]
'? 9c88  mov word ptr es:[bx], ax
'? 9c8d  add bx, word ptr [si + 0xa]
'? 9c90  mov es, word ptr [si + 2]
'? 9c93  cmp word ptr es:[bx], 0
'? 9c97  jl 0x9c9c
'? 9c99  jmp 0x9cd3
'? 9c9e  add bx, word ptr [si + 0xa]
'? 9ca1  mov es, word ptr [si + 2]
'? 9ca4  mov word ptr es:[bx], 0
'? proc:WON2.42(turbo!)
'? proc:WON2.12()
'? 9cba  shl bx, 1
'? 9cbc  shl bx, 1
'? 9cc1  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" is out of supplies !")
'? 9cd3  lea ax, [bp - 0x34]
'? proc:WON.12(ax)
'? 9cdf  shl bx, 1
'? 9ce6  add bx, word ptr [si + 0xa]
'? 9ce9  mov es, word ptr [si + 2]
'? 9cef  mov word ptr [bp - 0x3a], ax
'? 9cf7  add bx, word ptr [si + 0xa]
'? 9cfa  mov es, word ptr [si + 2]
'? 9d00  mov word ptr [bp - 0x3c], ax
'? 9d03  mov word ptr [bp - 0x3e], 5
'? 9d08  lea ax, [bp - 0x3a]
'? ; pushed so far: ax
'? 9d0c  lea ax, [bp - 0x3c]
'? ; pushed so far: ax, ax
'? 9d10  lea ax, [bp - 0x3e]
'? ; pushed so far: ax, ax, ax
'? 9d14  mov word ptr [bp - 0x40], dx
'? proc:WON.08(ax, ax, ax)
'? 9d24  add bx, word ptr [si + 0xa]
'? 9d27  mov es, word ptr [si + 2]
'? 9d2d  mov word ptr es:[bx], ax
'? 9d35  add bx, word ptr [si + 0xa]
'? 9d38  mov es, word ptr [si + 2]
'? 9d3e  mov word ptr es:[bx], ax
'? 9d41  mov word ptr [bp - 0x42], 1
'? 9d46  lea ax, [bp - 0x34]
'? ; pushed so far: ax
'? 9d4a  lea ax, [bp - 0x42]
'? proc:WON.01(ax, ax)
'? 9d56  shl bx, 1
'? 9d5b  add bx, word ptr [si + 0xa]
'? 9d5e  mov es, word ptr [si + 2]
'? 9d64  mov word ptr [bp - 0x44], ax
'? 9d67  shl ax, 1
'? 9d6e  add bx, word ptr [si + 0xa]
'? 9d71  mov es, word ptr [si + 2]
'? 9d74  cmp word ptr es:[bx], 0
'? 9d78  jne 0x9d7d
'? 9d7a  jmp 0xab3e
'? 9d7d  cmp word ptr [bp - 0x36], 1
'? 9d81  jne 0x9d9a
'? 9d86  shl bx, 1
'? 9d8b  add bx, word ptr [si + 0xa]
'? 9d8e  mov es, word ptr [si + 2]
'? 9d91  cmp word ptr es:[bx], 0x1a
'? 9d95  jge 0x9d9a
'? 9d97  jmp 0x9dba
'? 9d9a  cmp word ptr [bp - 0x36], 2
'? 9d9e  jne 0x9db7
'? 9da3  shl bx, 1
'? 9da8  add bx, word ptr [si + 0xa]
'? 9dab  mov es, word ptr [si + 2]
'? 9dae  cmp word ptr es:[bx], 0x19
'? 9db2  jle 0x9db7
'? 9db4  jmp 0x9dba
'? 9db7  jmp 0x9e82
'? B$COLR(1, 11, 2)
'? proc:WON2.12()
'? 9dd3  shl bx, 1
'? 9dd5  shl bx, 1
'? 9dda  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" and ")
'? 9def  shl bx, 1
'? 9df4  add bx, word ptr [si + 0xa]
'? 9df7  mov es, word ptr [si + 2]
'? 9dfd  shl ax, 1
'? 9dff  shl ax, 1
'? 9e06  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" meet in ")
'? 9e1b  shl bx, 1
'? 9e1d  shl bx, 1
'? 9e22  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? proc:WON2.42(turbo!)
'? 9e37  shl bx, 1
'? 9e3e  add bx, word ptr [si + 0xa]
'? 9e41  mov es, word ptr [si + 2]
'? 9e47  mov word ptr [bp - 0x46], ax
'? 9e4a  mov word ptr [bp - 0x48], 0
'? 9e4f  mov word ptr [bp - 0x4a], 6
'? 9e54  lea ax, [bp - 0x46]
'? ; pushed so far: ax
'? 9e58  lea ax, [bp - 0x48]
'? ; pushed so far: ax, ax
'? 9e5c  lea ax, [bp - 0x4a]
'? ; pushed so far: ax, ax, ax
'? 9e60  mov word ptr [bp - 0x4c], dx
'? proc:WON.08(ax, ax, ax)
'? 9e6e  add bx, word ptr [si + 0xa]
'? 9e71  mov es, word ptr [si + 2]
'? 9e77  mov word ptr es:[bx], ax
'? proc:WON2.12()
'? 9e7f  jmp 0xab3e
'? 9e82  mov word ptr [bp - 0x4e], 0
'? 9e87  mov word ptr [bp - 0x50], 3
'? 9e8c  lea ax, [bp - 0x44]
'? ; pushed so far: ax
'? 9e90  lea ax, [bp - 0x4e]
'? ; pushed so far: ax, ax
'? 9e94  lea ax, [bp - 0x50]
'? proc:WON.08(ax, ax, ax)
'? 9ea0  shl bx, 1
'? 9ea5  add bx, word ptr [si + 0xa]
'? 9ea8  mov es, word ptr [si + 2]
'? 9eae  mov word ptr [bp - 0x52], ax
'? B$COLR(1, 11, 2)
'? proc:WON2.12()
'? 9eca  shl bx, 1
'? 9ecc  shl bx, 1
'? 9ed1  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" attacks ")
'? 9ee6  shl bx, 1
'? 9ee8  shl bx, 1
'? 9eea  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" in ")
'? 9eff  shl bx, 1
'? 9f04  add bx, word ptr [si + 0xa]
'? 9f07  mov es, word ptr [si + 2]
'? 9f0d  shl ax, 1
'? 9f0f  shl ax, 1
'? 9f16  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? 9f1f  emu fld dword ptr [0x2ba]
'? 9f24  emu fsub dword ptr [0x2186]
'? 9f29  emu fstp dword ptr [bp - 0x56]
'? 9f2d  emu fwait
'? 9f2f  lea ax, [bp - 0x56]
'? proc:WON2.42(ax)
'? 9f3b  shl bx, 1
'? 9f40  add bx, word ptr [si + 0xa]
'? 9f43  mov es, word ptr [si + 2]
'? 9f46  cmp word ptr es:[bx], 0
'? 9f4a  jg 0x9f4f
'? 9f4c  jmp 0x9f69
'? 9f4f  lea ax, [bp - 0x34]
'? ; pushed so far: ax
'? 9f53  lea ax, [bp - 0x52]
'? ; pushed so far: ax, ax
'? 9f57  lea ax, [bp - 0x58]
'? ; pushed so far: ax, ax, ax
'? 9f5b  lea ax, [bp - 0x5a]
'? proc:WON.03(ax, ax, ax, ax)
'? 9f64  mov word ptr [bp - 0x14], 1
'? 9f6c  shl bx, 1
'? 9f73  add bx, word ptr [si + 0xa]
'? 9f76  mov es, word ptr [si + 2]
'? 9f79  cmp word ptr es:[bx], 0xa
'? 9f7d  jge 0x9f96
'? 9f81  add bx, word ptr [si + 0xa]
'? 9f84  mov es, word ptr [si + 2]
'? 9f8a  inc ax
'? 9f8d  add bx, word ptr [si + 0xa]
'? 9f90  mov es, word ptr [si + 2]
'? 9f93  mov word ptr es:[bx], ax
'? 9f99  shl bx, 1
'? 9f9e  add bx, word ptr [si + 0xa]
'? 9fa1  mov es, word ptr [si + 2]
'? 9fa4  cmp word ptr es:[bx], 2
'? 9fa8  jl 0x9fad
'? 9faa  jmp 0xa00d
'? 9fb0  shl bx, 1
'? 9fb2  shl bx, 1
'? 9fb7  add bx, word ptr [si + 0xa]
'? B$SCAT(bx, "'s army is crushed in ")
'? ; pushed so far: ax
'? 9fc8  shl bx, 1
'? ; pushed so far: ax
'? 9fcd  add bx, word ptr [si + 0xa]
'? ; pushed so far: ax
'? 9fd0  mov es, word ptr [si + 2]
'? ; pushed so far: ax
'? 9fd6  shl ax, 1
'? ; pushed so far: ax
'? 9fd8  shl ax, 1
'? ; pushed so far: ax
'? 9fdf  add bx, word ptr [si + 0xa]
'? B$SCAT(ax, bx)
'? ; pushed so far: ax
'? 9fe9  lea ax, [bp - 0x5e]
'? B$SAS1(ax, ax)
'? 9ff2  mov word ptr [bp - 0x60], 2
'? 9ff7  lea ax, [bp - 0x5e]
'? ; pushed so far: ax
'? 9ffb  lea ax, [bp - 0x60]
'? proc:WON2.35(ax, ax)
'? a007  mov word ptr [bp - 0x62], ax
'? a00a  jmp 0xa4de
'? a010  cmp ax, word ptr [bp - 0x58]
'? a013  jne 0xa018
'? a015  jmp 0xa1d2
'? a01b  shl bx, 1
'? a022  add bx, word ptr [si + 0xa]
'? a025  mov es, word ptr [si + 2]
'? a030  add bx, word ptr [si + 0xa]
'? a033  mov es, word ptr [si + 2]
'? a036  mov word ptr es:[bx], ax
'? a03e  add bx, word ptr [si + 0xa]
'? a041  mov es, word ptr [si + 2]
'? a047  mov word ptr es:[bx], ax
'? B$COLR(1, 11, 2)
'? proc:WON2.12()
'? a063  shl bx, 1
'? a065  shl bx, 1
'? a06a  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" withdraws to ")
'? a07f  shl bx, 1
'? a084  add bx, word ptr [si + 0xa]
'? a087  mov es, word ptr [si + 2]
'? a08d  shl ax, 1
'? a08f  shl ax, 1
'? a096  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? a09f  mov word ptr [bp - 0x64], 1
'? a0a4  lea ax, [bp - 0x34]
'? ; pushed so far: ax
'? a0a8  lea ax, [bp - 0x64]
'? proc:WON.01(ax, ax)
'? a0b4  shl bx, 1
'? a0bb  add bx, word ptr [si + 0xa]
'? a0be  mov es, word ptr [si + 2]
'? a0c9  add bx, word ptr [si + 0xa]
'? a0cc  mov es, word ptr [si + 2]
'? a0cf  mov word ptr es:[bx], ax
'? a0d2  lea ax, [bp - 0x34]
'? proc:WON.12(ax)
'? a0de  shl bx, 1
'? a0e5  add bx, word ptr [si + 0xa]
'? a0e8  mov es, word ptr [si + 2]
'? a0ee  shl ax, 1
'? a0f5  add bx, word ptr [si + 0xa]
'? a0f8  mov es, word ptr [si + 2]
'? a0fe  mov word ptr es:[bx], ax
'? a106  add bx, word ptr [si + 0xa]
'? a109  mov es, word ptr [si + 2]
'? a10c  mov word ptr es:[bx], 0xfffe
'? a114  shl bx, 1
'? a119  add bx, word ptr [si + 0xa]
'? a11c  mov es, word ptr [si + 2]
'? a11f  emu (seg 3) fild word ptr [bx]
'? B$RND0()
'? a12a  emu fld dword ptr [si]
'? a12d  emu fmul dword ptr [0x31ee]
'? a132  emu fwait
'? B$FCMP()
'? a139  ja 0xa13e
'? a13b  jmp 0xa1c6
'? a141  shl bx, 1
'? a148  add bx, word ptr [si + 0xa]
'? a14b  mov es, word ptr [si + 2]
'? a151  mov word ptr [bp - 0x66], ax
'? a159  add bx, word ptr [si + 0xa]
'? a15c  mov es, word ptr [si + 2]
'? a162  mov word ptr [bp - 0x68], ax
'? a165  mov word ptr [bp - 0x6a], 4
'? a16a  lea ax, [bp - 0x66]
'? ; pushed so far: ax
'? a16e  lea ax, [bp - 0x68]
'? ; pushed so far: ax, ax
'? a172  lea ax, [bp - 0x6a]
'? ; pushed so far: ax, ax, ax
'? a176  mov word ptr [bp - 0x6c], dx
'? proc:WON.08(ax, ax, ax)
'? a186  add bx, word ptr [si + 0xa]
'? a189  mov es, word ptr [si + 2]
'? a18f  mov word ptr es:[bx], ax
'? a197  add bx, word ptr [si + 0xa]
'? a19a  mov es, word ptr [si + 2]
'? a1a0  mov word ptr es:[bx], ax
'? a1a6  shl bx, 1
'? a1ad  add bx, word ptr [si + 0xa]
'? a1b0  mov es, word ptr [si + 2]
'? a1b3  cmp word ptr es:[bx], 0
'? a1b7  jle 0xa1c6
'? a1bb  add bx, word ptr [si + 0xa]
'? a1be  mov es, word ptr [si + 2]
'? a1c1  mov word ptr es:[bx], 0xfffe
'? proc:WON2.42(turbo!)
'? a1cf  jmp 0xadea
'? a1d5  shl bx, 1
'? a1dc  add bx, word ptr [si + 0xa]
'? a1df  mov es, word ptr [si + 2]
'? a1e5  mov word ptr [bp - 0x6e], ax
'? a1e8  mov word ptr [bp - 0x70], 4
'? a1ed  lea ax, [bp - 0x6e]
'? ; pushed so far: ax
'? a1f1  lea ax, [bp - 0x44]
'? ; pushed so far: ax, ax
'? a1f5  lea ax, [bp - 0x70]
'? ; pushed so far: ax, ax, ax
'? a1f9  mov word ptr [bp - 0x72], dx
'? proc:WON.08(ax, ax, ax)
'? a207  add bx, word ptr [si + 0xa]
'? a20a  mov es, word ptr [si + 2]
'? a210  mov word ptr es:[bx], ax
'? a216  shl bx, 1
'? a21b  add bx, word ptr [si + 0xa]
'? a21e  mov es, word ptr [si + 2]
'? a221  cmp word ptr es:[bx], 0
'? a225  jg 0xa22a
'? a227  jmp 0xa26b
'? a22d  shl bx, 1
'? a234  add bx, word ptr [si + 0xa]
'? a237  mov es, word ptr [si + 2]
'? a23d  mov word ptr [bp - 0x74], ax
'? a240  mov word ptr [bp - 0x76], 4
'? a245  lea ax, [bp - 0x44]
'? ; pushed so far: ax
'? a249  lea ax, [bp - 0x74]
'? ; pushed so far: ax, ax
'? a24d  lea ax, [bp - 0x76]
'? ; pushed so far: ax, ax, ax
'? a251  mov word ptr [bp - 0x78], dx
'? proc:WON.08(ax, ax, ax)
'? a25f  add bx, word ptr [si + 0xa]
'? a262  mov es, word ptr [si + 2]
'? a268  mov word ptr es:[bx], ax
'? a26b  lea ax, [bp - 0x52]
'? ; pushed so far: ax
'? a26f  lea ax, [bp - 0x7a]
'? proc:WON2.33(ax, ax)
'? a278  cmp word ptr [bp - 0x7a], 0
'? a27c  jle 0xa287
'? a281  mov word ptr [bp - 0x7c], ax
'? a284  jmp 0xa36a
'? a287  mov word ptr [bp - 0x7e], 0
'? a28c  mov word ptr [bp - 0x7a], 0
'? a294  jmp 0xa33a
'? a298  imul word ptr [0x210]
'? a29c  add ax, word ptr [bp - 0x44]
'? a29f  shl ax, 1
'? a2a6  add bx, word ptr [si + 0xa]
'? a2a9  mov es, word ptr [si + 2]
'? a2af  mov word ptr [bp - 0x28], ax
'? a2b2  or ax, ax
'? a2b4  jg 0xa2b9
'? a2b6  jmp 0xa336
'? a2b9  shl ax, 1
'? a2c0  add bx, word ptr [si + 0xa]
'? a2c3  mov es, word ptr [si + 2]
'? a2cc  sub dx, word ptr [bp - 0x36]
'? a2cf  cmp cx, dx
'? a2d1  je 0xa2d6
'? a2d3  jmp 0xa336
'? a2db  add bx, word ptr [si + 0xa]
'? a2de  mov es, word ptr [si + 2]
'? a2e4  cmp cx, word ptr [bp - 0x7e]
'? a2e7  jg 0xa2ec
'? a2e9  jmp 0xa336
'? a2ec  cmp word ptr [bp - 0x7e], 0
'? a2f0  jne 0xa309
'? a2f5  mov word ptr [bp - 0x7a], cx
'? a2fa  add bx, word ptr [si + 0xa]
'? a2fd  mov es, word ptr [si + 2]
'? a303  mov word ptr [bp - 0x7e], ax
'? a306  jmp 0xa336
'? a30c  shl bx, 1
'? a313  add bx, word ptr [si + 0xa]
'? a316  mov es, word ptr [si + 2]
'? a319  cmp word ptr es:[bx], 0
'? a31d  jne 0xa336
'? a322  mov word ptr [bp - 0x7a], ax
'? a32a  add bx, word ptr [si + 0xa]
'? a32d  mov es, word ptr [si + 2]
'? a333  mov word ptr [bp - 0x7e], ax
'? a339  inc ax
'? a33a  mov word ptr [bp - 0x1c], ax
'? a33d  cmp ax, 6
'? a340  jg 0xa345
'? a342  jmp 0xa298
'? a345  cmp word ptr [bp - 0x7a], 0
'? a349  jne 0xa34e
'? a34b  jmp 0xa434
'? a351  imul word ptr [bp - 0x7a]
'? a354  add ax, word ptr [bp - 0x44]
'? a357  shl ax, 1
'? a35e  add bx, word ptr [si + 0xa]
'? a361  mov es, word ptr [si + 2]
'? a367  mov word ptr [bp - 0x7c], ax
'? a36a  lea ax, [bp - 0x52]
'? proc:WON.12(ax)
'? a376  shl bx, 1
'? a37b  add bx, word ptr [si + 0xa]
'? a37e  mov es, word ptr [si + 2]
'? a384  mov word ptr es:[bx], ax
'? a387  mov word ptr [bp - 0x80], 0
'? a38c  lea ax, [bp - 0x52]
'? ; pushed so far: ax
'? a390  lea ax, [bp - 0x80]
'? proc:WON.01(ax, ax)
'? a39c  shl bx, 1
'? a3a1  add bx, word ptr [si + 0xa]
'? a3a4  mov es, word ptr [si + 2]
'? a3aa  mov word ptr es:[bx], ax
'? a3ad  shl ax, 1
'? a3b4  add bx, word ptr [si + 0xa]
'? a3b7  mov es, word ptr [si + 2]
'? a3bd  mov word ptr es:[bx], ax
'? proc:WON2.12()
'? a3c8  shl bx, 1
'? a3ca  shl bx, 1
'? a3cf  add bx, word ptr [si + 0xa]
'? B$SCAT(bx, " is withdrawing to ")
'? ; pushed so far: ax
'? a3e0  shl bx, 1
'? ; pushed so far: ax
'? a3e2  shl bx, 1
'? ; pushed so far: ax
'? a3e7  add bx, word ptr [si + 0xa]
'? B$SCAT(ax, bx)
'? B$PSSD(ax)
'? a3f6  lea ax, [bp - 0x52]
'? proc:WON.12(ax)
'? a3ff  mov word ptr [bp - 0x82], 0
'? a405  mov word ptr [bp - 0x84], 6
'? a40b  lea ax, [bp - 0x44]
'? ; pushed so far: ax
'? a40f  lea ax, [bp - 0x82]
'? ; pushed so far: ax, ax
'? a414  lea ax, [bp - 0x84]
'? proc:WON.08(ax, ax, ax)
'? a421  shl bx, 1
'? a426  add bx, word ptr [si + 0xa]
'? a429  mov es, word ptr [si + 2]
'? a42c  mov word ptr es:[bx], 0xfffe
'? a431  jmp 0xaace
'? a437  mov word ptr [bp - 0x62], ax
'? a43a  mov word ptr [bp - 0x86], 1
'? a440  cmp ax, 0x19
'? a443  jle 0xa44b
'? a445  mov word ptr [bp - 0x86], 2
'? a44f  shl bx, 1
'? a451  shl bx, 1
'? a456  add bx, word ptr [si + 0xa]
'? B$SCAT(bx, " ")
'? ; pushed so far: ax
'? a467  shl bx, 1
'? ; pushed so far: ax
'? a469  shl bx, 1
'? ; pushed so far: ax
'? a46e  add bx, word ptr [si + 0xa]
'? B$SCAT(ax, bx)
'? B$SCAT(ax, " surrenders to ")
'? ; pushed so far: ax
'? a485  shl bx, 1
'? ; pushed so far: ax
'? a487  shl bx, 1
'? ; pushed so far: ax
'? a489  add bx, word ptr [si + 0xa]
'? B$SCAT(ax, bx)
'? B$SCAT(ax, " in ")
'? ; pushed so far: ax
'? a4a0  shl bx, 1
'? ; pushed so far: ax
'? a4a5  add bx, word ptr [si + 0xa]
'? ; pushed so far: ax
'? a4a8  mov es, word ptr [si + 2]
'? ; pushed so far: ax
'? a4ae  shl ax, 1
'? ; pushed so far: ax
'? a4b0  shl ax, 1
'? ; pushed so far: ax
'? a4b7  add bx, word ptr [si + 0xa]
'? B$SCAT(ax, bx)
'? ; pushed so far: ax
'? a4c1  lea ax, [bp - 0x5e]
'? B$SAS1(ax, ax)
'? a4ca  mov word ptr [bp - 0x88], 2
'? a4d0  lea ax, [bp - 0x5e]
'? ; pushed so far: ax
'? a4d4  lea ax, [bp - 0x88]
'? proc:WON2.35(ax, ax)
'? a4de  cmp word ptr [0x756], 1
'? a4e3  jg 0xa4e8
'? a4e5  jmp 0xa4fc
'? a4eb  cmp ax, word ptr [bp - 0x36]
'? a4ee  jne 0xa4f3
'? a4f0  jmp 0xa4fc
'? B$SPLY("MFMST220o3g8g8g8o4c2")
'? a4ff  shl bx, 1
'? a504  add bx, word ptr [si + 0xa]
'? a507  mov es, word ptr [si + 2]
'? a50a  cmp word ptr es:[bx], 0
'? a50e  jg 0xa513
'? a510  jmp 0xa582
'? a516  shl bx, 1
'? a51d  add bx, word ptr [si + 0xa]
'? a520  mov es, word ptr [si + 2]
'? a526  mov word ptr [bp - 0x8a], ax
'? a52f  add bx, word ptr [si + 0xa]
'? a532  mov es, word ptr [si + 2]
'? a538  mov word ptr [bp - 0x8c], ax
'? a53c  mov word ptr [bp - 0x8e], 4
'? a542  lea ax, [bp - 0x8a]
'? ; pushed so far: ax
'? a547  lea ax, [bp - 0x8c]
'? ; pushed so far: ax, ax
'? a54c  lea ax, [bp - 0x8e]
'? ; pushed so far: ax, ax, ax
'? a551  mov word ptr [bp - 0x90], dx
'? proc:WON.08(ax, ax, ax)
'? a563  add bx, word ptr [si + 0xa]
'? a566  mov es, word ptr [si + 2]
'? a56d  mov word ptr es:[bx], ax
'? a575  add bx, word ptr [si + 0xa]
'? a578  mov es, word ptr [si + 2]
'? a57f  mov word ptr es:[bx], ax
'? a582  mov word ptr [bp - 0x28], 0xf
'? a58a  cmp ax, word ptr [bp - 0x36]
'? a58d  jne 0xa594
'? a58f  mov word ptr [bp - 0x28], 0xfff1
'? a594  lea ax, [bp - 0x36]
'? proc:WON2.18(ax)
'? a5a0  sub bx, word ptr [bp - 0x36]
'? a5a3  shl bx, 1
'? a5aa  add bx, word ptr [si + 0xa]
'? a5ad  mov es, word ptr [si + 2]
'? a5b3  add ax, 0x19
'? a5b8  add bx, word ptr [si + 0xa]
'? a5bb  mov es, word ptr [si + 2]
'? a5be  mov word ptr es:[bx], ax
'? a5c1  cmp word ptr [bp - 0x62], 1
'? a5c5  jg 0xa5ca
'? a5c7  jmp 0xa90b
'? a5cd  shl bx, 1
'? a5d4  add bx, word ptr [si + 0xa]
'? a5d7  mov es, word ptr [si + 2]
'? a5dd  sub ax, 0xc
'? a5e0  mov word ptr [bp - 0x28], ax
'? a5e8  add bx, word ptr [si + 0xa]
'? a5eb  mov es, word ptr [si + 2]
'? a5f1  sub ax, 0xb
'? a5f4  mov word ptr [bp - 0x92], ax
'? a5f8  lea ax, [bp - 0x44]
'? proc:WON2.11(ax)
'? a603  jmp 0xa6a3
'? a609  sub cx, 7
'? ; pushed so far: cx
'? a611  sub cx, 7
'? a61d  add ax, 9
'? ; pushed so far: ax
'? a625  add ax, 4
LINE (cx, cx)-(ax, ax), 2, BF
'? a643  add ax, word ptr [bp - 0x28]
'? a646  sub ax, 7
'? ; pushed so far: ax
'? a64e  add ax, word ptr [bp - 0x92]
'? ; pushed so far: ax
'? a652  sub ax, 7
'? a65e  sub ax, word ptr [bp - 0x94]
'? a662  add ax, 8
'? ; pushed so far: ax
'? a66a  sub ax, word ptr [bp - 0x94]
'? ; pushed so far: ax
'? a66e  add ax, 5
LINE (ax, ax)-(ax, ax), 5, BF
'? a688  emu fld dword ptr [0x3242]
'? a68d  emu fstp dword ptr [bp - 0x98]
'? a692  emu fwait
'? a694  lea ax, [bp - 0x98]
'? proc:WON2.42(ax)
'? a6a2  inc ax
'? a6a3  mov word ptr [bp - 0x94], ax
'? a6a7  cmp ax, 7
'? a6aa  jg 0xa6af
'? a6ac  jmp 0xa606
'? a6b2  sub ax, 7
'? ; pushed so far: ax
'? a6ba  sub ax, 7
'? a6c6  add ax, 9
'? ; pushed so far: ax
'? a6ce  add ax, 4
LINE (ax, ax)-(ax, ax), 2, BF
'? a6eb  add ax, 8
'? ; pushed so far: ax
'? a6f3  sub cx, 2
'? ; pushed so far: ax, cx
'? a6f7  mov word ptr [bp - 0x9a], ax
'? ; pushed so far: local9a
'? a708  add ax, 5
LINE (ax, cx)-(local9a, ax), 0
'? a723  inc ax
'? ; pushed so far: ax
'? a729  sub ax, 2
'? B$CASP([3248], 0.4!) after N1I2(ax, ax)
'? B$CIRC([324c], 8!, 15)
'? a753  sub ax, 7
'? a763  add ax, 8
'? ; pushed so far: ax
'? a76b  add ax, 5
LINE (ax, local92)-(ax, ax), 15, BF
'? ; pushed so far: local28
'? a78c  sub ax, 2
PAINT (local28, ax), 15
'? a7a5  sub ax, 6
'? ; pushed so far: ax
'? a7ad  add ax, 4
PSET (ax, ax), 15
'? ; pushed so far: "c0S4"
'? a7c9  add bx, word ptr [si + 0xa]
'? B$SCAT("c0S4", bx)
'? B$SCAT(ax, "BR2")
'? ; pushed so far: ax
'? a7e0  add bx, word ptr [si + 0xa]
'? B$SCAT(ax, bx)
'? B$SCAT(ax, "BR2")
'? ; pushed so far: ax
'? a7f7  add bx, word ptr [si + 0xa]
'? B$SCAT(ax, bx)
DRAW ax
'? a806  emu fld dword ptr [0x2186]
'? a80b  emu fstp dword ptr [bp - 0x9e]
'? a810  emu fwait
'? a812  lea ax, [bp - 0x9e]
'? proc:WON2.42(ax)
'? a81f  shl bx, 1
'? a826  add bx, word ptr [si + 0xa]
'? a829  mov es, word ptr [si + 2]
'? a82c  mov word ptr es:[bx], 0
'? ; pushed so far: ""
'? a838  shl bx, 1
'? ; pushed so far: ""
'? a83a  shl bx, 1
'? ; pushed so far: ""
'? a841  add bx, word ptr [si + 0xa]
'? ; pushed so far: "", bx
'? a845  mov word ptr [bp - 0xa0], cx
'? ; pushed so far: "", bx
'? a849  mov word ptr [bp - 0xa2], dx
'? B$SAS1("", bx)
'? ; pushed so far: ""
'? a85d  add bx, word ptr [si + 0xa]
'? B$SAS1("", bx)
'? a86f  add bx, word ptr [si + 0xa]
'? a872  mov es, word ptr [si + 2]
'? a875  mov word ptr es:[bx], 0
'? a87f  add bx, word ptr [si + 0xa]
'? a882  mov es, word ptr [si + 2]
'? a885  mov word ptr es:[bx], 0
'? a88f  add bx, word ptr [si + 0xa]
'? a892  mov es, word ptr [si + 2]
'? a895  mov word ptr es:[bx], 0
'? a89f  add bx, word ptr [si + 0xa]
'? a8a2  mov es, word ptr [si + 2]
'? a8a5  mov word ptr es:[bx], 0
'? a8af  add bx, word ptr [si + 0xa]
'? a8b2  mov es, word ptr [si + 2]
'? a8b5  mov word ptr es:[bx], 0
'? a8bd  shl bx, 1
'? a8c1  add bx, word ptr [si + 0xa]
'? a8c4  mov es, word ptr [si + 2]
'? a8cc  add bx, word ptr [si + 0xa]
'? a8cf  mov es, word ptr [si + 2]
'? a8d2  add ax, word ptr es:[bx]
'? a8d7  add bx, word ptr [si + 0xa]
'? a8da  mov es, word ptr [si + 2]
'? a8dd  mov word ptr es:[bx], ax
'? a8e2  add bx, word ptr [si + 0xa]
'? a8e5  mov es, word ptr [si + 2]
'? a8e8  mov word ptr es:[bx], 0
'? a8ef  add bx, word ptr [si + 0xa]
'? a8f2  mov es, word ptr [si + 2]
'? a8f5  cmp word ptr es:[bx], 0xa
'? a8f9  jle 0xa908
'? a8fd  add bx, word ptr [si + 0xa]
'? a900  mov es, word ptr [si + 2]
'? a903  mov word ptr es:[bx], 0xa
'? a908  jmp 0xaaa1
'? a911  add bx, word ptr [si + 0xa]
'? a914  mov es, word ptr [si + 2]
'? a917  cmp word ptr es:[bx], 0
'? a91b  je 0xa920
'? a91d  jmp 0xa93e
'? a920  mov word ptr [bp - 0xa4], 0x10
'? a926  cmp word ptr [0x3d6], 1
'? a92b  jne 0xa93b
'? a92d  cmp word ptr [0x638], 2
'? a932  jne 0xa93b
'? a938  mov word ptr [0x78a], ax
'? a93b  jmp 0xa96e
'? a93e  cmp word ptr [bp - 0xa4], 0
'? a943  je 0xa948
'? a945  jmp 0xa96e
'? ; pushed so far: "Napoleon banished to St. Helena"
'? a94c  lea ax, [bp - 0xa8]
'? B$SAS1("Napoleon banished to St. Helena", ax)
'? a956  mov word ptr [bp - 0xaa], 1
'? a95c  lea ax, [bp - 0xa8]
'? ; pushed so far: ax
'? a961  lea ax, [bp - 0xaa]
'? proc:WON2.22(ax, ax)
'? a96b  jmp 0xa5ca
'? a96e  cmp word ptr [bp - 0xa4], 0
'? a973  je 0xa978
'? a975  jmp 0xa99e
'? ; pushed so far: "Napoleon banished to St. Helena"
'? a97c  lea ax, [bp - 0xae]
'? B$SAS1("Napoleon banished to St. Helena", ax)
'? a986  mov word ptr [bp - 0xb0], 1
'? a98c  lea ax, [bp - 0xae]
'? ; pushed so far: ax
'? a991  lea ax, [bp - 0xb0]
'? proc:WON2.22(ax, ax)
'? a99b  jmp 0xa5ca
'? a9a4  add bx, word ptr [si + 0xa]
'? a9a7  mov es, word ptr [si + 2]
'? a9ae  mov word ptr es:[bx], ax
'? a9b7  add bx, word ptr [si + 0xa]
'? a9ba  mov es, word ptr [si + 2]
'? a9bd  mov word ptr es:[bx], 0xa
'? a9c2  shl ax, 1
'? a9c9  add bx, word ptr [si + 0xa]
'? a9cc  mov es, word ptr [si + 2]
'? a9cf  mov word ptr es:[bx], 1
'? a9d9  add bx, word ptr [si + 0xa]
'? a9dc  mov es, word ptr [si + 2]
'? a9df  mov word ptr es:[bx], 1
'? ; pushed so far: "Napoleon removed to "
'? a9ec  shl bx, 1
'? ; pushed so far: "Napoleon removed to "
'? a9ee  shl bx, 1
'? ; pushed so far: "Napoleon removed to "
'? a9f3  add bx, word ptr [si + 0xa]
'? B$SCAT("Napoleon removed to ", bx)
'? ; pushed so far: ax
'? a9fd  lea ax, [bp - 0xb4]
'? B$SAS1(ax, ax)
'? aa07  mov word ptr [bp - 0xb6], 3
'? aa0d  lea ax, [bp - 0xb4]
'? ; pushed so far: ax
'? aa12  lea ax, [bp - 0xb6]
'? proc:WON2.22(ax, ax)
'? aa22  add bx, word ptr [si + 0xa]
'? aa25  mov es, word ptr [si + 2]
'? aa28  emu (seg 3) fild word ptr [bx]
'? aa2c  emu fdiv dword ptr [0x2010]
'? aa34  add bx, word ptr [si + 0xa]
'? aa37  mov es, word ptr [si + 2]
'? aa3a  emu (seg 3) fistp word ptr [bx]
'? aa3e  emu fwait
'? aa43  jmp 0xaa6f
'? aa46  shl ax, 1
'? aa4d  add bx, word ptr [si + 0xa]
'? aa50  mov es, word ptr [si + 2]
'? aa53  emu (seg 3) fild word ptr [bx]
'? aa57  emu fdiv dword ptr [0x2010]
'? aa5e  add bx, word ptr [si + 0xa]
'? aa61  mov es, word ptr [si + 2]
'? aa64  emu (seg 3) fistp word ptr [bx]
'? aa68  emu fwait
'? aa6e  inc ax
'? aa6f  mov word ptr [bp - 0x94], ax
'? aa73  cmp ax, 0x19
'? aa76  jle 0xaa46
'? aa78  mov word ptr [bp - 0xb8], 1
'? aa7e  lea ax, [bp - 0xb8]
'? proc:WON.12(ax)
'? aa88  mov word ptr [bp - 0xba], 0xffe7
'? aa8e  lea ax, [bp - 0xba]
'? proc:WON2.18(ax)
'? aa98  cmp word ptr [bp - 0x34], 1
'? aa9c  jne 0xaaa1
'? aa9e  jmp 0xadea
'? aaa1  emu fld dword ptr [0x2ada]
'? aaa6  emu fstp dword ptr [bp - 0xbe]
'? aaab  emu fwait
'? aaad  lea ax, [bp - 0xbe]
'? proc:WON2.42(ax)
'? aaba  shl bx, 1
'? aabf  add bx, word ptr [si + 0xa]
'? aac2  mov es, word ptr [si + 2]
'? aac5  cmp word ptr es:[bx], 0
'? aac9  jne 0xaace
'? aacb  jmp 0xadea
'? aace  lea ax, [bp - 0x44]
'? proc:WON2.29(ax)
'? aada  shl bx, 1
'? aadf  add bx, word ptr [si + 0xa]
'? aae2  mov es, word ptr [si + 2]
'? aae5  cmp word ptr es:[bx], 0
'? aae9  jne 0xaaee
'? aaeb  jmp 0xab3e
'? proc:WON2.02()
'? B$COLR(1, 11, 2)
'? proc:WON2.12()
'? B$PSSD("There are still defenders in ")
'? ab15  shl bx, 1
'? ab17  shl bx, 1
'? ab1c  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? ab25  emu fld dword ptr [0x32d0]
'? ab2a  emu fstp dword ptr [bp - 0xc2]
'? ab2f  emu fwait
'? ab31  lea ax, [bp - 0xc2]
'? proc:WON2.42(ax)
'? ab3b  jmp 0x9e82
'? ab41  shl bx, 1
'? ab48  add bx, word ptr [si + 0xa]
'? ab4b  mov es, word ptr [si + 2]
'? ab51  mov word ptr es:[bx], ax
'? ab59  add bx, word ptr [si + 0xa]
'? ab5c  mov es, word ptr [si + 2]
'? ab5f  mov word ptr es:[bx], 0xfffe
'? ab67  shl bx, 1
'? ab6e  add bx, word ptr [si + 0xa]
'? ab71  mov es, word ptr [si + 2]
'? ab77  mov word ptr [bp - 0xc4], ax
'? ab7b  lea ax, [bp - 0xc4]
'? ; pushed so far: ax
'? ab80  mov word ptr [bp - 0xc6], dx
'? proc:WON2.29(ax)
'? ab90  add bx, word ptr [si + 0xa]
'? ab93  mov es, word ptr [si + 2]
'? ab9a  mov word ptr es:[bx], ax
'? ab9d  lea ax, [bp - 0x34]
'? proc:WON.12(ax)
'? aba9  shl bx, 1
'? abae  add bx, word ptr [si + 0xa]
'? abb1  mov es, word ptr [si + 2]
'? abb7  shl ax, 1
'? abbe  add bx, word ptr [si + 0xa]
'? abc1  mov es, word ptr [si + 2]
'? abc7  cmp ax, word ptr [bp - 0x36]
'? abca  jne 0xabcf
'? abcc  jmp 0xada2
'? abd2  shl bx, 1
'? abd7  add bx, word ptr [si + 0xa]
'? abda  mov es, word ptr [si + 2]
'? abe0  mov word ptr [bp - 0xc8], ax
'? abe4  cmp word ptr [0x3d6], 1
'? abe9  je 0xabee
'? abeb  jmp 0xac84
'? abf1  cmp ax, word ptr [bp - 0x36]
'? abf4  je 0xabf9
'? abf6  jmp 0xac84
'? abfd  shl bx, 1
'? ac02  add bx, word ptr [si + 0xa]
'? ac05  mov es, word ptr [si + 2]
'? ac08  cmp word ptr es:[bx], 0
'? ac0c  jg 0xac11
'? ac0e  jmp 0xac84
'? ac11  cmp word ptr [bp - 0x14], 0
'? ac15  je 0xac1a
'? ac17  jmp 0xac84
'? ac1a  mov word ptr [0x52], 0x43
'? ac20  mov word ptr [0x54], 0xf
'? ac26  mov word ptr [0x8a], 0xf
'? ac2c  mov word ptr [0x88], 3
'? ; pushed so far: "Raze ?"
'? ac3b  add bx, word ptr [si + 0xa]
'? B$SAS1("Raze ?", bx)
'? ; pushed so far: "No"
'? ac4b  add bx, word ptr [si + 0xa]
'? B$SAS1("No", bx)
'? ; pushed so far: "Yes"
'? ac5b  add bx, word ptr [si + 0xa]
'? B$SAS1("Yes", bx)
'? ac64  mov word ptr [0x56], 2
'? ac6a  mov word ptr [bp - 0xca], 0
'? ac70  lea ax, [bp - 0xca]
'? proc:WONMENU.03(ax)
'? ac7a  cmp word ptr [0x50], 2
'? ac7f  jne 0xac84
'? ac81  jmp 0xacd1
'? ac84  cmp word ptr [0x3d6], 1
'? ac89  je 0xac8e
'? ac8b  jmp 0xad8c
'? ac91  cmp ax, word ptr [bp - 0x36]
'? ac94  jne 0xac99
'? ac96  jmp 0xad8c
'? ac9d  shl bx, 1
'? aca4  add bx, word ptr [si + 0xa]
'? aca7  mov es, word ptr [si + 2]
'? acaa  cmp word ptr es:[bx], 0
'? acae  jg 0xacb3
'? acb0  jmp 0xad8c
'? acb3  cmp word ptr [bp - 0x14], 0
'? acb7  je 0xacbc
'? acb9  jmp 0xad8c
'? acc1  add bx, word ptr [si + 0xa]
'? acc4  mov es, word ptr [si + 2]
'? acc7  cmp word ptr es:[bx], 0x96
'? accc  jg 0xacd1
'? acce  jmp 0xad8c
'? acd5  shl bx, 1
'? acdc  add bx, word ptr [si + 0xa]
'? acdf  mov es, word ptr [si + 2]
'? ace2  mov word ptr es:[bx], 0
'? acec  add bx, word ptr [si + 0xa]
'? acef  mov es, word ptr [si + 2]
'? acf5  mov word ptr [bp - 0x28], ax
'? acfd  add bx, word ptr [si + 0xa]
'? ad00  mov es, word ptr [si + 2]
'? ad06  mov word ptr [bp - 0x92], cx
'? ad0a  sub ax, 5
'? ; pushed so far: ax
'? ad0e  sub cx, 5
'? ad1a  add ax, 5
'? ; pushed so far: ax
'? ad22  add ax, 5
LINE (ax, cx)-(ax, ax), 2, BF
'? proc:WON.14()
'? proc:WON2.12()
'? ad49  shl bx, 1
'? ad4b  shl bx, 1
'? ad50  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" has destroyed the forts at ")
'? ad66  shl bx, 1
'? ad68  shl bx, 1
'? ad6d  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? ad76  emu fld dword ptr [0x2b5e]
'? ad7b  emu fstp dword ptr [bp - 0xce]
'? ad80  emu fwait
'? ad82  lea ax, [bp - 0xce]
'? proc:WON2.42(ax)
'? ad8c  lea ax, [bp - 0x34]
'? ; pushed so far: ax
'? ad90  lea ax, [bp - 0xc8]
'? ; pushed so far: ax, ax
'? ad95  lea ax, [bp - 0x36]
'? ; pushed so far: ax, ax, ax
'? ad99  lea ax, [bp - 0x14]
'? proc:WON2.09(ax, ax, ax, ax)
'? ada5  shl bx, 1
'? adac  add bx, word ptr [si + 0xa]
'? adaf  mov es, word ptr [si + 2]
'? adb2  cmp word ptr es:[bx], 0xa
'? adb6  jl 0xadbb
'? adb8  jmp 0xadea
'? adbd  add bx, word ptr [si + 0xa]
'? adc0  mov es, word ptr [si + 2]
'? adc6  inc ax
'? adc9  add bx, word ptr [si + 0xa]
'? adcc  mov es, word ptr [si + 2]
'? adcf  mov word ptr es:[bx], ax
'? add2  emu fld dword ptr [0x28b6]
'? B$RND0()
'? adde  emu fld dword ptr [si]
'? ade1  emu fwait
'? B$FCMP()
'? ade8  ja 0xada2
'? aded  inc ax
'? adee  mov word ptr [bp - 0x30], ax
'? adf1  cmp ax, 0x32
'? adf4  jg 0xadf9
'? adf6  jmp 0x9b8e
'? adf9  jmp 0xaea3
LINE (525, 90)-(630, 305), 2, BF
'? B$COLR(1, 14, 2)
'? B$LOCT(1, 12, 1, 67, 4)
'? B$PESD(13062)
'? B$LOCT(1, 13, 1, 67, 4)
'? B$PESD(13082)
'? B$LOCT(1, 14, 1, 67, 4)
'? B$PESD(13102)
'? B$RETA()
'? aea9  add bx, word ptr [si + 0xa]
'? aeac  mov es, word ptr [si + 2]
'? aeb2  cdq
'? aeb3  xor ax, dx
'? aeb5  sub ax, dx
'? B$STI2(ax)
'? ; pushed so far: ax
'? aebe  lea ax, [bp - 0xd2]
'? B$SAS1(ax, ax)
'? ; pushed so far: "Game will end in "
'? aecf  add bx, word ptr [si + 0xa]
'? ; pushed so far: "Game will end in "
'? aed2  mov es, word ptr [si + 2]
'? ; pushed so far: "Game will end in "
'? aed8  shl ax, 1
'? ; pushed so far: "Game will end in "
'? aeda  shl ax, 1
'? ; pushed so far: "Game will end in "
'? aee1  add bx, word ptr [si + 0xa]
'? B$SCAT("Game will end in ", bx)
'? ; pushed so far: ax
'? aeeb  lea ax, [bp - 0xd2]
'? B$SCAT(ax, ax)
'? ; pushed so far: ax
'? aef6  lea ax, [bp - 0xd6]
'? B$SAS1(ax, ax)
'? af00  mov word ptr [bp - 0xd8], 5
'? af06  lea ax, [bp - 0xd6]
'? ; pushed so far: ax
'? af0b  lea ax, [bp - 0xd8]
'? proc:WON2.22(ax, ax)
'? af19  shl bx, 1
'? af1e  add bx, word ptr [si + 0xa]
'? af21  mov es, word ptr [si + 2]
'? af24  cmp word ptr es:[bx], 1
'? af28  jge 0xaf30
'? af2a  mov word ptr [0x822], 0
'? af30  cmp word ptr [0x822], 0
'? af35  jg 0xaf3a
'? af37  jmp 0xb298
'? proc:WON2.12()
'? af43  shl bx, 1
'? af4a  add bx, word ptr [si + 0xa]
'? af4d  mov es, word ptr [si + 2]
'? af50  emu (seg 3) fild word ptr [bx]
'? af54  emu fmul dword ptr [0x2ab0]
'? af59  emu fadd dword ptr [0x28b6]
'? af5e  mov word ptr [bp - 0xda], dx
'? B$RND0()
'? af69  emu fld dword ptr [di]
'? af6c  emu fwait
'? B$FCMP()
'? af73  jb 0xaf78
'? af75  jmp 0xb115
'? af7c  add bx, word ptr [si + 0xa]
'? af7f  mov es, word ptr [si + 2]
'? af82  emu (seg 3) fild word ptr [bx]
'? B$RND0()
'? af8d  emu fld dword ptr [si]
'? af90  emu fadd dword ptr [0x2186]
'? af95  emu fmulp st(1)
'? af9b  sub bx, word ptr [0x822]
'? af9f  shl bx, 1
'? afa4  add bx, word ptr [si + 0xa]
'? afa7  mov es, word ptr [si + 2]
'? afaa  emu (seg 3) fimul word ptr [bx]
'? afae  emu fmul dword ptr [0x2aac]
'? afb3  emu fistp word ptr [0x824]
'? afb8  emu fwait
'? afba  cmp word ptr [0x824], 1
'? afbf  jge 0xafc7
'? afc1  mov word ptr [0x824], 1
'? afc7  emu fld dword ptr [0x3246]
'? afcc  emu fild word ptr [0x824]
'? afd4  sub bx, word ptr [0x822]
'? afd8  shl bx, 1
'? afdf  add bx, word ptr [si + 0xa]
'? afe2  mov es, word ptr [si + 2]
'? afe5  emu (seg 3) fidiv word ptr [bx]
'? afe9  emu fwait
'? B$FCMP()
'? aff0  jbe 0xb01f
'? aff2  mov word ptr [bp - 0xdc], dx
'? B$RND0()
'? affd  emu fld dword ptr [di]
'? b000  emu fmul dword ptr [0x1fc2]
'? b005  emu fadd dword ptr [0x218a]
'? b00e  add bx, word ptr [si + 0xa]
'? b011  mov es, word ptr [si + 2]
'? b014  emu (seg 3) fimul word ptr [bx]
'? b018  emu fistp word ptr [0x824]
'? b01d  emu fwait
'? B$COLR(1, 15, 2)
'? b034  shl bx, 1
'? b036  shl bx, 1
'? b03b  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" raiders have sunk $")
'? B$PSI2(raider)
'? B$PSSD(" of ")
'? b062  sub bx, word ptr [0x822]
'? b066  shl bx, 1
'? b068  shl bx, 1
'? b06a  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" commerce")
'? B$COLR(1, 14, 2)
'? B$LOCT(1, 26, 1, 14, 4)
'? B$PESD("$$")
'? b0af  cmp word ptr [0x756], 1
'? b0b4  jg 0xb0b9
'? b0b6  jmp 0xb0c2
'? B$SPLY("t210l8o4co3bo4l4co3ccL8gfego4co3bo4c")
'? b0c5  cmp ax, word ptr [0x822]
'? b0c9  jne 0xb0d1
'? b0cb  mov word ptr [0x826], 1
'? b0d1  emu fld dword ptr [0x2ada]
'? b0d6  emu fstp dword ptr [bp - 0xe0]
'? b0db  emu fwait
'? b0dd  lea ax, [bp - 0xe0]
'? proc:WON2.42(ax)
LINE (100, 400)-(120, 415), 3, BF
'? b112  jmp 0xb298
'? b115  mov word ptr [0x824], 0
'? proc:WON2.01(2082)
'? B$COLR(1, 15, 2)
'? b139  shl bx, 1
'? b13b  shl bx, 1
'? b140  add bx, word ptr [si + 0xa]
'? B$PSSD(bx)
'? B$PSSD(" raiders have lost a ship (")
'? b156  shl bx, 1
'? b15b  add bx, word ptr [si + 0xa]
'? b15e  mov es, word ptr [si + 2]
'? B$PSI2(word ptr es:[bx])
'? B$PSSD(" remain)")
'? b172  cmp word ptr [0x756], 0
'? b177  jg 0xb17c
'? b179  jmp 0xb1af
'? B$SOND(590, [2712], 0.5!)
'? B$SOND(999, [2712], 0.5!)
'? B$SOND(1999, [2712], 0.5!)
'? b1b3  shl bx, 1
'? b1b8  add bx, word ptr [si + 0xa]
'? b1bb  mov es, word ptr [si + 2]
'? b1be  cmp word ptr es:[bx], 0
'? b1c2  jg 0xb1c7
'? b1c4  jmp 0xb1e0
'? b1c7  emu fld dword ptr [0x2ada]
'? b1cc  emu fstp dword ptr [bp - 0xe4]
'? b1d1  emu fwait
'? b1d3  lea ax, [bp - 0xe4]
'? proc:WON2.42(ax)
'? b1dd  jmp 0xaea3
'? b1e0  mov word ptr [0x822], 0
LINE (120, 400)-(160, 420), 3, BF
'? b214  jmp 0xb249
'? b228  imul word ptr [bp - 0x94]
'? B$FIL2() after N1I2(140, 410)
'? b231  sub sp, 4
'? b236  emu fstp dword ptr [bx]
'? b239  emu fwait
'? B$CIRC(11)
'? b248  inc ax
'? b249  mov word ptr [bp - 0x94], ax
'? b24d  cmp ax, 3
'? b250  jle 0xb218
'? b252  emu fld dword ptr [0x2ada]
'? b257  emu fstp dword ptr [bp - 0xe8]
'? b25c  emu fwait
'? b25e  lea ax, [bp - 0xe8]
'? proc:WON2.42(ax)
LINE (120, 400)-(160, 420), 3, BF
'? proc:WON2.37()
'? proc:WON2.37()
'? proc:WON2.24()
'? proc:WON2.12()
'? proc:WON2.07()
'? b2b2  add bx, word ptr [si + 0xa]
'? b2b5  mov es, word ptr [si + 2]
'? b2b8  cmp word ptr es:[bx], 0x28
'? b2bc  jg 0xb2c1
'? b2be  jmp 0xb30f
'? b2c7  add bx, word ptr [si + 0xa]
'? b2ca  mov es, word ptr [si + 2]
'? b2d0  add ax, 5
'? b2d6  add bx, word ptr [si + 0xa]
'? b2d9  mov es, word ptr [si + 2]
'? b2dc  mov word ptr es:[bx], ax
'? b2e5  add bx, word ptr [si + 0xa]
'? b2e8  mov es, word ptr [si + 2]
'? b2eb  cmp word ptr es:[bx], 0x32
'? b2ef  jle 0xb30f
'? b2f7  add bx, word ptr [si + 0xa]
'? b2fa  mov es, word ptr [si + 2]
'? b300  add ax, 0xa
'? b306  add bx, word ptr [si + 0xa]
'? b309  mov es, word ptr [si + 2]
'? b30c  mov word ptr es:[bx], ax
'? b30f  cmp word ptr [0x638], 2
'? b314  jne 0xb339
'? b31c  add bx, word ptr [si + 0xa]
'? b31f  mov es, word ptr [si + 2]
'? b322  cmp word ptr es:[bx], 0xb
'? b326  jge 0xb339
'? b328  emu fld dword ptr [0x3d8]
'? b32d  emu fadd dword ptr [0x28b2]
'? b332  emu fstp dword ptr [0x3d8]
'? b337  emu fwait
'? b33f  add bx, word ptr [si + 0xa]
'? b342  mov es, word ptr [si + 2]
'? b345  cmp word ptr es:[bx], 1
'? b349  jge 0xb359
'? b34e  add bx, word ptr [si + 0xa]
'? b351  mov es, word ptr [si + 2]
'? b354  mov word ptr es:[bx], 0
'? b35f  add bx, word ptr [si + 0xa]
'? b362  mov es, word ptr [si + 2]
'? b365  cmp word ptr es:[bx], 0x28
'? b369  jg 0xb36e
'? b36b  jmp 0xb3bc
'? b374  add bx, word ptr [si + 0xa]
'? b377  mov es, word ptr [si + 2]
'? b37d  add ax, 5
'? b383  add bx, word ptr [si + 0xa]
'? b386  mov es, word ptr [si + 2]
'? b389  mov word ptr es:[bx], ax
'? b392  add bx, word ptr [si + 0xa]
'? b395  mov es, word ptr [si + 2]
'? b398  cmp word ptr es:[bx], 0x32
'? b39c  jle 0xb3bc
'? b3a4  add bx, word ptr [si + 0xa]
'? b3a7  mov es, word ptr [si + 2]
'? b3ad  add ax, 0xa
'? b3b3  add bx, word ptr [si + 0xa]
'? b3b6  mov es, word ptr [si + 2]
'? b3b9  mov word ptr es:[bx], ax
'? b3bc  cmp word ptr [0x638], 1
'? b3c1  jne 0xb3e6
'? b3c9  add bx, word ptr [si + 0xa]
'? b3cc  mov es, word ptr [si + 2]
'? b3cf  cmp word ptr es:[bx], 0xb
'? b3d3  jge 0xb3e6
'? b3d5  emu fld dword ptr [0x3d8]
'? b3da  emu fadd dword ptr [0x28b2]
'? b3df  emu fstp dword ptr [0x3d8]
'? b3e4  emu fwait
'? b3e9  jmp 0xb3fb
'? b3ec  lea ax, [bp - 0x94]
'? proc:WON2.40(ax)
'? b3fa  inc ax
'? b3fb  mov word ptr [bp - 0x94], ax
'? b3ff  cmp ax, 2
'? b402  jle 0xb3ec
'? b404  cmp word ptr [0x3d6], 2
'? b409  je 0xb40e
'? b40b  jmp 0xb443
'? proc:WON2.12()
'? B$COLR(1, 14, 2)
'? B$PSSD("press a key")
'? b42d  emu fld dword ptr [0x2ada]
'? b432  emu fstp dword ptr [bp - 0xec]
'? b437  emu fwait
'? b439  lea ax, [bp - 0xec]
'? proc:WON2.42(ax)
'? B$EXSA()
'? b448  retf 0
