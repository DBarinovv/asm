    118c:	55                   	push   rbp
    118d:	48 89 e5             	mov    rbp,rsp
    1190:	48 83 ec 20          	sub    rsp,0x20
    1194:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    119b:	00 00
    119d:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
    11a1:	31 c0                	xor    eax,eax

    11a3:	48 8d 3d 81 0e 00 00 	lea    rdi,[rip+0xe81]        # 202b <_IO_stdin_used+0x2b>
    11aa:	b8 00 00 00 00       	mov    eax,0x0
    11af:	e8 9c fe ff ff       	call   1050 <printf@plt>

    11b4:	48 c7 45 e0 00 00 00 	mov    QWORD PTR [rbp-0x20],0x0
    11bb:	00
    11bc:	48 c7 45 e8 00 00 00 	mov    QWORD PTR [rbp-0x18],0x0
    11c3:	00
    11c4:	c6 45 f0 00          	mov    BYTE PTR [rbp-0x10],0x0
    11c8:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    11cc:	48 89 c6             	mov    rsi,rax

    11cf:	48 8d 3d 66 0e 00 00 	lea    rdi,[rip+0xe66]        # 203c <_IO_stdin_used+0x3c>
    11d6:	b8 00 00 00 00       	mov    eax,0x0
    11db:	e8 90 fe ff ff       	call   1070 <__isoc99_scanf@plt>

    11e0:	48 8d 15 1d 0e 00 00 	lea    rdx,[rip+0xe1d]        # 2004 <_IO_stdin_used+0x4>
    11e7:	48 8d 45 e0          	lea    rax,[rbp-0x20]
    11eb:	48 89 d6             	mov    rsi,rdx
    11ee:	48 89 c7             	mov    rdi,rax
    11f1:	e8 6a fe ff ff       	call   1060 <strcmp@plt>
    11f6:	85 c0                	test   eax,eax
    11f8:	75 04                	jne    11fe <main+0x72>
    11fa:	c6 45 f0 01          	mov    BYTE PTR [rbp-0x10],0x1
    11fe:	0f b6 45 f0          	movzx  eax,BYTE PTR [rbp-0x10]
    1202:	84 c0                	test   al,al
    1204:	74 0c                	je     1212 <main+0x86>
    1206:	b8 00 00 00 00       	mov    eax,0x0
    120b:	e8 69 ff ff ff       	call   1179 <print_secret>
    1210:	eb 0c                	jmp    121e <main+0x92>
    1212:	48 8d 3d 29 0e 00 00 	lea    rdi,[rip+0xe29]        # 2042 <_IO_stdin_used+0x42>
    1219:	e8 12 fe ff ff       	call   1030 <puts@plt>
    121e:	b8 00 00 00 00       	mov    eax,0x0
    1223:	48 8b 4d f8          	mov    rcx,QWORD PTR [rbp-0x8]
    1227:	64 48 33 0c 25 28 00 	xor    rcx,QWORD PTR fs:0x28
    122e:	00 00
    1230:	74 05                	je     1237 <main+0xab>
    1232:	e8 09 fe ff ff       	call   1040 <__stack_chk_fail@plt>
    1237:	c9                   	leave
    1238:	c3                   	ret
    1239:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
