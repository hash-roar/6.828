
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 10 f0       	mov    $0xf010f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 02 01 00    	add    $0x102be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 f8 16 ff ff    	lea    -0xe908(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 d6 09 00 00       	call   f0100a39 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 14 17 ff ff    	lea    -0xe8ec(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 b0 09 00 00       	call   f0100a39 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 d6 07 00 00       	call   f0100877 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 02 01 00    	add    $0x10256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 20 11 f0    	mov    $0xf0112060,%edx
f01000be:	c7 c0 c0 26 11 f0    	mov    $0xf01126c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 e8 14 00 00       	call   f01015b7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3e 05 00 00       	call   f0100612 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 2f 17 ff ff    	lea    -0xe8d1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 51 09 00 00       	call   f0100a39 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 7c 07 00 00       	call   f010087d <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	56                   	push   %esi
f010010a:	53                   	push   %ebx
f010010b:	e8 ac 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100110:	81 c3 f8 01 01 00    	add    $0x101f8,%ebx
	va_list ap;

	if (panicstr)
f0100116:	83 bb 58 1d 00 00 00 	cmpl   $0x0,0x1d58(%ebx)
f010011d:	74 0f                	je     f010012e <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011f:	83 ec 0c             	sub    $0xc,%esp
f0100122:	6a 00                	push   $0x0
f0100124:	e8 54 07 00 00       	call   f010087d <monitor>
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	eb f1                	jmp    f010011f <_panic+0x19>
	panicstr = fmt;
f010012e:	8b 45 10             	mov    0x10(%ebp),%eax
f0100131:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	asm volatile("cli; cld");
f0100137:	fa                   	cli    
f0100138:	fc                   	cld    
	va_start(ap, fmt);
f0100139:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	ff 75 0c             	push   0xc(%ebp)
f0100142:	ff 75 08             	push   0x8(%ebp)
f0100145:	8d 83 4a 17 ff ff    	lea    -0xe8b6(%ebx),%eax
f010014b:	50                   	push   %eax
f010014c:	e8 e8 08 00 00       	call   f0100a39 <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	56                   	push   %esi
f0100155:	ff 75 10             	push   0x10(%ebp)
f0100158:	e8 a5 08 00 00       	call   f0100a02 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 86 17 ff ff    	lea    -0xe87a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 ce 08 00 00       	call   f0100a39 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb af                	jmp    f010011f <_panic+0x19>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 01 01 00    	add    $0x1018e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	push   0xc(%ebp)
f0100189:	ff 75 08             	push   0x8(%ebp)
f010018c:	8d 83 62 17 ff ff    	lea    -0xe89e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 a1 08 00 00       	call   f0100a39 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	push   0x10(%ebp)
f010019f:	e8 5e 08 00 00       	call   f0100a02 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 86 17 ff ff    	lea    -0xe87a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 87 08 00 00       	call   f0100a39 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c5:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	74 0a                	je     f01001d4 <serial_proc_data+0x14>
f01001ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	c3                   	ret    
		return -1;
f01001d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001d9:	c3                   	ret    

f01001da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	57                   	push   %edi
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	83 ec 1c             	sub    $0x1c,%esp
f01001e3:	e8 6a 05 00 00       	call   f0100752 <__x86.get_pc_thunk.si>
f01001e8:	81 c6 20 01 01 00    	add    $0x10120,%esi
f01001ee:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001f0:	8d 1d 98 1d 00 00    	lea    0x1d98,%ebx
f01001f6:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001ff:	eb 25                	jmp    f0100226 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100201:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100208:	8d 51 01             	lea    0x1(%ecx),%edx
f010020b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010020e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100211:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100217:	b8 00 00 00 00       	mov    $0x0,%eax
f010021c:	0f 44 d0             	cmove  %eax,%edx
f010021f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100229:	ff d0                	call   *%eax
f010022b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010022e:	74 06                	je     f0100236 <cons_intr+0x5c>
		if (c == 0)
f0100230:	85 c0                	test   %eax,%eax
f0100232:	75 cd                	jne    f0100201 <cons_intr+0x27>
f0100234:	eb f0                	jmp    f0100226 <cons_intr+0x4c>
	}
}
f0100236:	83 c4 1c             	add    $0x1c,%esp
f0100239:	5b                   	pop    %ebx
f010023a:	5e                   	pop    %esi
f010023b:	5f                   	pop    %edi
f010023c:	5d                   	pop    %ebp
f010023d:	c3                   	ret    

f010023e <kbd_proc_data>:
{
f010023e:	55                   	push   %ebp
f010023f:	89 e5                	mov    %esp,%ebp
f0100241:	56                   	push   %esi
f0100242:	53                   	push   %ebx
f0100243:	e8 74 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100248:	81 c3 c0 00 01 00    	add    $0x100c0,%ebx
f010024e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100253:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100254:	a8 01                	test   $0x1,%al
f0100256:	0f 84 f7 00 00 00    	je     f0100353 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f010025c:	a8 20                	test   $0x20,%al
f010025e:	0f 85 f6 00 00 00    	jne    f010035a <kbd_proc_data+0x11c>
f0100264:	ba 60 00 00 00       	mov    $0x60,%edx
f0100269:	ec                   	in     (%dx),%al
f010026a:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010026c:	3c e0                	cmp    $0xe0,%al
f010026e:	74 64                	je     f01002d4 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100270:	84 c0                	test   %al,%al
f0100272:	78 75                	js     f01002e9 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100274:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f010027a:	f6 c1 40             	test   $0x40,%cl
f010027d:	74 0e                	je     f010028d <kbd_proc_data+0x4f>
		data |= 0x80;
f010027f:	83 c8 80             	or     $0xffffff80,%eax
f0100282:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100284:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100287:	89 8b 78 1d 00 00    	mov    %ecx,0x1d78(%ebx)
	shift |= shiftcode[data];
f010028d:	0f b6 d2             	movzbl %dl,%edx
f0100290:	0f b6 84 13 b8 18 ff 	movzbl -0xe748(%ebx,%edx,1),%eax
f0100297:	ff 
f0100298:	0b 83 78 1d 00 00    	or     0x1d78(%ebx),%eax
	shift ^= togglecode[data];
f010029e:	0f b6 8c 13 b8 17 ff 	movzbl -0xe848(%ebx,%edx,1),%ecx
f01002a5:	ff 
f01002a6:	31 c8                	xor    %ecx,%eax
f01002a8:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002ae:	89 c1                	mov    %eax,%ecx
f01002b0:	83 e1 03             	and    $0x3,%ecx
f01002b3:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ba:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002be:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002c1:	a8 08                	test   $0x8,%al
f01002c3:	74 61                	je     f0100326 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002c5:	89 f2                	mov    %esi,%edx
f01002c7:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ca:	83 f9 19             	cmp    $0x19,%ecx
f01002cd:	77 4b                	ja     f010031a <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002cf:	83 ee 20             	sub    $0x20,%esi
f01002d2:	eb 0c                	jmp    f01002e0 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002d4:	83 8b 78 1d 00 00 40 	orl    $0x40,0x1d78(%ebx)
		return 0;
f01002db:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002e0:	89 f0                	mov    %esi,%eax
f01002e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002e5:	5b                   	pop    %ebx
f01002e6:	5e                   	pop    %esi
f01002e7:	5d                   	pop    %ebp
f01002e8:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e9:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f01002ef:	83 e0 7f             	and    $0x7f,%eax
f01002f2:	f6 c1 40             	test   $0x40,%cl
f01002f5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002f8:	0f b6 d2             	movzbl %dl,%edx
f01002fb:	0f b6 84 13 b8 18 ff 	movzbl -0xe748(%ebx,%edx,1),%eax
f0100302:	ff 
f0100303:	83 c8 40             	or     $0x40,%eax
f0100306:	0f b6 c0             	movzbl %al,%eax
f0100309:	f7 d0                	not    %eax
f010030b:	21 c8                	and    %ecx,%eax
f010030d:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
		return 0;
f0100313:	be 00 00 00 00       	mov    $0x0,%esi
f0100318:	eb c6                	jmp    f01002e0 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010031a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010031d:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100320:	83 fa 1a             	cmp    $0x1a,%edx
f0100323:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100326:	f7 d0                	not    %eax
f0100328:	a8 06                	test   $0x6,%al
f010032a:	75 b4                	jne    f01002e0 <kbd_proc_data+0xa2>
f010032c:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100332:	75 ac                	jne    f01002e0 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100334:	83 ec 0c             	sub    $0xc,%esp
f0100337:	8d 83 7c 17 ff ff    	lea    -0xe884(%ebx),%eax
f010033d:	50                   	push   %eax
f010033e:	e8 f6 06 00 00       	call   f0100a39 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100343:	b8 03 00 00 00       	mov    $0x3,%eax
f0100348:	ba 92 00 00 00       	mov    $0x92,%edx
f010034d:	ee                   	out    %al,(%dx)
}
f010034e:	83 c4 10             	add    $0x10,%esp
f0100351:	eb 8d                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f0100353:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100358:	eb 86                	jmp    f01002e0 <kbd_proc_data+0xa2>
		return -1;
f010035a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035f:	e9 7c ff ff ff       	jmp    f01002e0 <kbd_proc_data+0xa2>

f0100364 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100364:	55                   	push   %ebp
f0100365:	89 e5                	mov    %esp,%ebp
f0100367:	57                   	push   %edi
f0100368:	56                   	push   %esi
f0100369:	53                   	push   %ebx
f010036a:	83 ec 1c             	sub    $0x1c,%esp
f010036d:	e8 4a fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100372:	81 c3 96 ff 00 00    	add    $0xff96,%ebx
f0100378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010037b:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100380:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100385:	b9 84 00 00 00       	mov    $0x84,%ecx
f010038a:	89 fa                	mov    %edi,%edx
f010038c:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038d:	a8 20                	test   $0x20,%al
f010038f:	75 13                	jne    f01003a4 <cons_putc+0x40>
f0100391:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100397:	7f 0b                	jg     f01003a4 <cons_putc+0x40>
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
	     i++)
f010039f:	83 c6 01             	add    $0x1,%esi
f01003a2:	eb e6                	jmp    f010038a <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003a4:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003a8:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003b0:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b6:	bf 79 03 00 00       	mov    $0x379,%edi
f01003bb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003c0:	89 fa                	mov    %edi,%edx
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c9:	7f 0f                	jg     f01003da <cons_putc+0x76>
f01003cb:	84 c0                	test   %al,%al
f01003cd:	78 0b                	js     f01003da <cons_putc+0x76>
f01003cf:	89 ca                	mov    %ecx,%edx
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	ec                   	in     (%dx),%al
f01003d3:	ec                   	in     (%dx),%al
f01003d4:	ec                   	in     (%dx),%al
f01003d5:	83 c6 01             	add    $0x1,%esi
f01003d8:	eb e6                	jmp    f01003c0 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003da:	ba 78 03 00 00       	mov    $0x378,%edx
f01003df:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003e3:	ee                   	out    %al,(%dx)
f01003e4:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e9:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003ee:	ee                   	out    %al,(%dx)
f01003ef:	b8 08 00 00 00       	mov    $0x8,%eax
f01003f4:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f8:	89 f8                	mov    %edi,%eax
f01003fa:	80 cc 07             	or     $0x7,%ah
f01003fd:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100403:	0f 45 c7             	cmovne %edi,%eax
f0100406:	89 c7                	mov    %eax,%edi
f0100408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010040b:	0f b6 c0             	movzbl %al,%eax
f010040e:	89 f9                	mov    %edi,%ecx
f0100410:	80 f9 0a             	cmp    $0xa,%cl
f0100413:	0f 84 e4 00 00 00    	je     f01004fd <cons_putc+0x199>
f0100419:	83 f8 0a             	cmp    $0xa,%eax
f010041c:	7f 46                	jg     f0100464 <cons_putc+0x100>
f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	0f 84 a8 00 00 00    	je     f01004cf <cons_putc+0x16b>
f0100427:	83 f8 09             	cmp    $0x9,%eax
f010042a:	0f 85 da 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 2a ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 20 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 16 ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 0c ff ff ff       	call   f0100364 <cons_putc>
		cons_putc(' ');
f0100458:	b8 20 00 00 00       	mov    $0x20,%eax
f010045d:	e8 02 ff ff ff       	call   f0100364 <cons_putc>
		break;
f0100462:	eb 26                	jmp    f010048a <cons_putc+0x126>
	switch (c & 0xff) {
f0100464:	83 f8 0d             	cmp    $0xd,%eax
f0100467:	0f 85 9d 00 00 00    	jne    f010050a <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010046d:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100474:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010047a:	c1 e8 16             	shr    $0x16,%eax
f010047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100480:	c1 e0 04             	shl    $0x4,%eax
f0100483:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010048a:	66 81 bb a0 1f 00 00 	cmpw   $0x7cf,0x1fa0(%ebx)
f0100491:	cf 07 
f0100493:	0f 87 98 00 00 00    	ja     f0100531 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100499:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f010049f:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a4:	89 ca                	mov    %ecx,%edx
f01004a6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a7:	0f b7 9b a0 1f 00 00 	movzwl 0x1fa0(%ebx),%ebx
f01004ae:	8d 71 01             	lea    0x1(%ecx),%esi
f01004b1:	89 d8                	mov    %ebx,%eax
f01004b3:	66 c1 e8 08          	shr    $0x8,%ax
f01004b7:	89 f2                	mov    %esi,%edx
f01004b9:	ee                   	out    %al,(%dx)
f01004ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ee                   	out    %al,(%dx)
f01004c2:	89 d8                	mov    %ebx,%eax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004ca:	5b                   	pop    %ebx
f01004cb:	5e                   	pop    %esi
f01004cc:	5f                   	pop    %edi
f01004cd:	5d                   	pop    %ebp
f01004ce:	c3                   	ret    
		if (crt_pos > 0) {
f01004cf:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f01004d6:	66 85 c0             	test   %ax,%ax
f01004d9:	74 be                	je     f0100499 <cons_putc+0x135>
			crt_pos--;
f01004db:	83 e8 01             	sub    $0x1,%eax
f01004de:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ec:	b2 00                	mov    $0x0,%dl
f01004ee:	83 ca 20             	or     $0x20,%edx
f01004f1:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f01004f7:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004fb:	eb 8d                	jmp    f010048a <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004fd:	66 83 83 a0 1f 00 00 	addw   $0x50,0x1fa0(%ebx)
f0100504:	50 
f0100505:	e9 63 ff ff ff       	jmp    f010046d <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f010050a:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100511:	8d 50 01             	lea    0x1(%eax),%edx
f0100514:	66 89 93 a0 1f 00 00 	mov    %dx,0x1fa0(%ebx)
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100524:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010052c:	e9 59 ff ff ff       	jmp    f010048a <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100531:	8b 83 a4 1f 00 00    	mov    0x1fa4(%ebx),%eax
f0100537:	83 ec 04             	sub    $0x4,%esp
f010053a:	68 00 0f 00 00       	push   $0xf00
f010053f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100545:	52                   	push   %edx
f0100546:	50                   	push   %eax
f0100547:	e8 b1 10 00 00       	call   f01015fd <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010054c:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100552:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100558:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010055e:	83 c4 10             	add    $0x10,%esp
f0100561:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100566:	83 c0 02             	add    $0x2,%eax
f0100569:	39 d0                	cmp    %edx,%eax
f010056b:	75 f4                	jne    f0100561 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010056d:	66 83 ab a0 1f 00 00 	subw   $0x50,0x1fa0(%ebx)
f0100574:	50 
f0100575:	e9 1f ff ff ff       	jmp    f0100499 <cons_putc+0x135>

f010057a <serial_intr>:
{
f010057a:	e8 cf 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f010057f:	05 89 fd 00 00       	add    $0xfd89,%eax
	if (serial_exists)
f0100584:	80 b8 ac 1f 00 00 00 	cmpb   $0x0,0x1fac(%eax)
f010058b:	75 01                	jne    f010058e <serial_intr+0x14>
f010058d:	c3                   	ret    
{
f010058e:	55                   	push   %ebp
f010058f:	89 e5                	mov    %esp,%ebp
f0100591:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100594:	8d 80 b8 fe fe ff    	lea    -0x10148(%eax),%eax
f010059a:	e8 3b fc ff ff       	call   f01001da <cons_intr>
}
f010059f:	c9                   	leave  
f01005a0:	c3                   	ret    

f01005a1 <kbd_intr>:
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	83 ec 08             	sub    $0x8,%esp
f01005a7:	e8 a2 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f01005ac:	05 5c fd 00 00       	add    $0xfd5c,%eax
	cons_intr(kbd_proc_data);
f01005b1:	8d 80 36 ff fe ff    	lea    -0x100ca(%eax),%eax
f01005b7:	e8 1e fc ff ff       	call   f01001da <cons_intr>
}
f01005bc:	c9                   	leave  
f01005bd:	c3                   	ret    

f01005be <cons_getc>:
{
f01005be:	55                   	push   %ebp
f01005bf:	89 e5                	mov    %esp,%ebp
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 04             	sub    $0x4,%esp
f01005c5:	e8 f2 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 3e fd 00 00    	add    $0xfd3e,%ebx
	serial_intr();
f01005d0:	e8 a5 ff ff ff       	call   f010057a <serial_intr>
	kbd_intr();
f01005d5:	e8 c7 ff ff ff       	call   f01005a1 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005da:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
	return 0;
f01005e0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005e5:	3b 83 9c 1f 00 00    	cmp    0x1f9c(%ebx),%eax
f01005eb:	74 1e                	je     f010060b <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005ed:	8d 48 01             	lea    0x1(%eax),%ecx
f01005f0:	0f b6 94 03 98 1d 00 	movzbl 0x1d98(%ebx,%eax,1),%edx
f01005f7:	00 
			cons.rpos = 0;
f01005f8:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	0f 45 c1             	cmovne %ecx,%eax
f0100605:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
}
f010060b:	89 d0                	mov    %edx,%eax
f010060d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
f0100615:	57                   	push   %edi
f0100616:	56                   	push   %esi
f0100617:	53                   	push   %ebx
f0100618:	83 ec 1c             	sub    $0x1c,%esp
f010061b:	e8 9c fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100620:	81 c3 e8 fc 00 00    	add    $0xfce8,%ebx
	was = *cp;
f0100626:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100634:	5a a5 
	if (*cp != 0xA55A) {
f0100636:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063d:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100642:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100647:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064b:	0f 84 ac 00 00 00    	je     f01006fd <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100651:	89 8b a8 1f 00 00    	mov    %ecx,0x1fa8(%ebx)
f0100657:	b8 0e 00 00 00       	mov    $0xe,%eax
f010065c:	89 ca                	mov    %ecx,%edx
f010065e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065f:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100662:	89 f2                	mov    %esi,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	0f b6 c0             	movzbl %al,%eax
f0100668:	c1 e0 08             	shl    $0x8,%eax
f010066b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010066e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100676:	89 f2                	mov    %esi,%edx
f0100678:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100679:	89 bb a4 1f 00 00    	mov    %edi,0x1fa4(%ebx)
	pos |= inb(addr_6845 + 1);
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100685:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100691:	89 c8                	mov    %ecx,%eax
f0100693:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100698:	ee                   	out    %al,(%dx)
f0100699:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010069e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ab:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b0:	ee                   	out    %al,(%dx)
f01006b1:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006b6:	89 c8                	mov    %ecx,%eax
f01006b8:	89 f2                	mov    %esi,%edx
f01006ba:	ee                   	out    %al,(%dx)
f01006bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c0:	89 fa                	mov    %edi,%edx
f01006c2:	ee                   	out    %al,(%dx)
f01006c3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006c8:	89 c8                	mov    %ecx,%eax
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d0:	89 f2                	mov    %esi,%edx
f01006d2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006d8:	ec                   	in     (%dx),%al
f01006d9:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006db:	3c ff                	cmp    $0xff,%al
f01006dd:	0f 95 83 ac 1f 00 00 	setne  0x1fac(%ebx)
f01006e4:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006e9:	ec                   	in     (%dx),%al
f01006ea:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ef:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f0:	80 f9 ff             	cmp    $0xff,%cl
f01006f3:	74 1e                	je     f0100713 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006f8:	5b                   	pop    %ebx
f01006f9:	5e                   	pop    %esi
f01006fa:	5f                   	pop    %edi
f01006fb:	5d                   	pop    %ebp
f01006fc:	c3                   	ret    
		*cp = was;
f01006fd:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100704:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100709:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f010070e:	e9 3e ff ff ff       	jmp    f0100651 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100713:	83 ec 0c             	sub    $0xc,%esp
f0100716:	8d 83 88 17 ff ff    	lea    -0xe878(%ebx),%eax
f010071c:	50                   	push   %eax
f010071d:	e8 17 03 00 00       	call   f0100a39 <cprintf>
f0100722:	83 c4 10             	add    $0x10,%esp
}
f0100725:	eb ce                	jmp    f01006f5 <cons_init+0xe3>

f0100727 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100727:	55                   	push   %ebp
f0100728:	89 e5                	mov    %esp,%ebp
f010072a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010072d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100730:	e8 2f fc ff ff       	call   f0100364 <cons_putc>
}
f0100735:	c9                   	leave  
f0100736:	c3                   	ret    

f0100737 <getchar>:

int
getchar(void)
{
f0100737:	55                   	push   %ebp
f0100738:	89 e5                	mov    %esp,%ebp
f010073a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010073d:	e8 7c fe ff ff       	call   f01005be <cons_getc>
f0100742:	85 c0                	test   %eax,%eax
f0100744:	74 f7                	je     f010073d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100746:	c9                   	leave  
f0100747:	c3                   	ret    

f0100748 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	c3                   	ret    

f010074e <__x86.get_pc_thunk.ax>:
f010074e:	8b 04 24             	mov    (%esp),%eax
f0100751:	c3                   	ret    

f0100752 <__x86.get_pc_thunk.si>:
f0100752:	8b 34 24             	mov    (%esp),%esi
f0100755:	c3                   	ret    

f0100756 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	56                   	push   %esi
f010075a:	53                   	push   %ebx
f010075b:	e8 5c fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100760:	81 c3 a8 fb 00 00    	add    $0xfba8,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100766:	83 ec 04             	sub    $0x4,%esp
f0100769:	8d 83 b8 19 ff ff    	lea    -0xe648(%ebx),%eax
f010076f:	50                   	push   %eax
f0100770:	8d 83 d6 19 ff ff    	lea    -0xe62a(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	8d b3 db 19 ff ff    	lea    -0xe625(%ebx),%esi
f010077d:	56                   	push   %esi
f010077e:	e8 b6 02 00 00       	call   f0100a39 <cprintf>
f0100783:	83 c4 0c             	add    $0xc,%esp
f0100786:	8d 83 44 1a ff ff    	lea    -0xe5bc(%ebx),%eax
f010078c:	50                   	push   %eax
f010078d:	8d 83 e4 19 ff ff    	lea    -0xe61c(%ebx),%eax
f0100793:	50                   	push   %eax
f0100794:	56                   	push   %esi
f0100795:	e8 9f 02 00 00       	call   f0100a39 <cprintf>
	return 0;
}
f010079a:	b8 00 00 00 00       	mov    $0x0,%eax
f010079f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007a2:	5b                   	pop    %ebx
f01007a3:	5e                   	pop    %esi
f01007a4:	5d                   	pop    %ebp
f01007a5:	c3                   	ret    

f01007a6 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a6:	55                   	push   %ebp
f01007a7:	89 e5                	mov    %esp,%ebp
f01007a9:	57                   	push   %edi
f01007aa:	56                   	push   %esi
f01007ab:	53                   	push   %ebx
f01007ac:	83 ec 18             	sub    $0x18,%esp
f01007af:	e8 08 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007b4:	81 c3 54 fb 00 00    	add    $0xfb54,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ba:	8d 83 ed 19 ff ff    	lea    -0xe613(%ebx),%eax
f01007c0:	50                   	push   %eax
f01007c1:	e8 73 02 00 00       	call   f0100a39 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c6:	83 c4 08             	add    $0x8,%esp
f01007c9:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f01007cf:	8d 83 6c 1a ff ff    	lea    -0xe594(%ebx),%eax
f01007d5:	50                   	push   %eax
f01007d6:	e8 5e 02 00 00       	call   f0100a39 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007db:	83 c4 0c             	add    $0xc,%esp
f01007de:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007e4:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007ea:	50                   	push   %eax
f01007eb:	57                   	push   %edi
f01007ec:	8d 83 94 1a ff ff    	lea    -0xe56c(%ebx),%eax
f01007f2:	50                   	push   %eax
f01007f3:	e8 41 02 00 00       	call   f0100a39 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f8:	83 c4 0c             	add    $0xc,%esp
f01007fb:	c7 c0 e1 19 10 f0    	mov    $0xf01019e1,%eax
f0100801:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100807:	52                   	push   %edx
f0100808:	50                   	push   %eax
f0100809:	8d 83 b8 1a ff ff    	lea    -0xe548(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 24 02 00 00       	call   f0100a39 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100815:	83 c4 0c             	add    $0xc,%esp
f0100818:	c7 c0 60 20 11 f0    	mov    $0xf0112060,%eax
f010081e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100824:	52                   	push   %edx
f0100825:	50                   	push   %eax
f0100826:	8d 83 dc 1a ff ff    	lea    -0xe524(%ebx),%eax
f010082c:	50                   	push   %eax
f010082d:	e8 07 02 00 00       	call   f0100a39 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100832:	83 c4 0c             	add    $0xc,%esp
f0100835:	c7 c6 c0 26 11 f0    	mov    $0xf01126c0,%esi
f010083b:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100841:	50                   	push   %eax
f0100842:	56                   	push   %esi
f0100843:	8d 83 00 1b ff ff    	lea    -0xe500(%ebx),%eax
f0100849:	50                   	push   %eax
f010084a:	e8 ea 01 00 00       	call   f0100a39 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084f:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100852:	29 fe                	sub    %edi,%esi
f0100854:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085a:	c1 fe 0a             	sar    $0xa,%esi
f010085d:	56                   	push   %esi
f010085e:	8d 83 24 1b ff ff    	lea    -0xe4dc(%ebx),%eax
f0100864:	50                   	push   %eax
f0100865:	e8 cf 01 00 00       	call   f0100a39 <cprintf>
	return 0;
}
f010086a:	b8 00 00 00 00       	mov    $0x0,%eax
f010086f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100872:	5b                   	pop    %ebx
f0100873:	5e                   	pop    %esi
f0100874:	5f                   	pop    %edi
f0100875:	5d                   	pop    %ebp
f0100876:	c3                   	ret    

f0100877 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f0100877:	b8 00 00 00 00       	mov    $0x0,%eax
f010087c:	c3                   	ret    

f010087d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010087d:	55                   	push   %ebp
f010087e:	89 e5                	mov    %esp,%ebp
f0100880:	57                   	push   %edi
f0100881:	56                   	push   %esi
f0100882:	53                   	push   %ebx
f0100883:	83 ec 68             	sub    $0x68,%esp
f0100886:	e8 31 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010088b:	81 c3 7d fa 00 00    	add    $0xfa7d,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100891:	8d 83 50 1b ff ff    	lea    -0xe4b0(%ebx),%eax
f0100897:	50                   	push   %eax
f0100898:	e8 9c 01 00 00       	call   f0100a39 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010089d:	8d 83 74 1b ff ff    	lea    -0xe48c(%ebx),%eax
f01008a3:	89 04 24             	mov    %eax,(%esp)
f01008a6:	e8 8e 01 00 00       	call   f0100a39 <cprintf>
f01008ab:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01008ae:	8d bb 0a 1a ff ff    	lea    -0xe5f6(%ebx),%edi
f01008b4:	eb 4a                	jmp    f0100900 <monitor+0x83>
f01008b6:	83 ec 08             	sub    $0x8,%esp
f01008b9:	0f be c0             	movsbl %al,%eax
f01008bc:	50                   	push   %eax
f01008bd:	57                   	push   %edi
f01008be:	e8 b5 0c 00 00       	call   f0101578 <strchr>
f01008c3:	83 c4 10             	add    $0x10,%esp
f01008c6:	85 c0                	test   %eax,%eax
f01008c8:	74 08                	je     f01008d2 <monitor+0x55>
			*buf++ = 0;
f01008ca:	c6 06 00             	movb   $0x0,(%esi)
f01008cd:	8d 76 01             	lea    0x1(%esi),%esi
f01008d0:	eb 79                	jmp    f010094b <monitor+0xce>
		if (*buf == 0)
f01008d2:	80 3e 00             	cmpb   $0x0,(%esi)
f01008d5:	74 7f                	je     f0100956 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01008d7:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01008db:	74 0f                	je     f01008ec <monitor+0x6f>
		argv[argc++] = buf;
f01008dd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01008e0:	8d 48 01             	lea    0x1(%eax),%ecx
f01008e3:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01008e6:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ea:	eb 44                	jmp    f0100930 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008ec:	83 ec 08             	sub    $0x8,%esp
f01008ef:	6a 10                	push   $0x10
f01008f1:	8d 83 0f 1a ff ff    	lea    -0xe5f1(%ebx),%eax
f01008f7:	50                   	push   %eax
f01008f8:	e8 3c 01 00 00       	call   f0100a39 <cprintf>
			return 0;
f01008fd:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100900:	8d 83 06 1a ff ff    	lea    -0xe5fa(%ebx),%eax
f0100906:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100909:	83 ec 0c             	sub    $0xc,%esp
f010090c:	ff 75 a4             	push   -0x5c(%ebp)
f010090f:	e8 13 0a 00 00       	call   f0101327 <readline>
f0100914:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100916:	83 c4 10             	add    $0x10,%esp
f0100919:	85 c0                	test   %eax,%eax
f010091b:	74 ec                	je     f0100909 <monitor+0x8c>
	argv[argc] = 0;
f010091d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100924:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f010092b:	eb 1e                	jmp    f010094b <monitor+0xce>
			buf++;
f010092d:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100930:	0f b6 06             	movzbl (%esi),%eax
f0100933:	84 c0                	test   %al,%al
f0100935:	74 14                	je     f010094b <monitor+0xce>
f0100937:	83 ec 08             	sub    $0x8,%esp
f010093a:	0f be c0             	movsbl %al,%eax
f010093d:	50                   	push   %eax
f010093e:	57                   	push   %edi
f010093f:	e8 34 0c 00 00       	call   f0101578 <strchr>
f0100944:	83 c4 10             	add    $0x10,%esp
f0100947:	85 c0                	test   %eax,%eax
f0100949:	74 e2                	je     f010092d <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f010094b:	0f b6 06             	movzbl (%esi),%eax
f010094e:	84 c0                	test   %al,%al
f0100950:	0f 85 60 ff ff ff    	jne    f01008b6 <monitor+0x39>
	argv[argc] = 0;
f0100956:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100959:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100960:	00 
	if (argc == 0)
f0100961:	85 c0                	test   %eax,%eax
f0100963:	74 9b                	je     f0100900 <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100965:	83 ec 08             	sub    $0x8,%esp
f0100968:	8d 83 d6 19 ff ff    	lea    -0xe62a(%ebx),%eax
f010096e:	50                   	push   %eax
f010096f:	ff 75 a8             	push   -0x58(%ebp)
f0100972:	e8 a1 0b 00 00       	call   f0101518 <strcmp>
f0100977:	83 c4 10             	add    $0x10,%esp
f010097a:	85 c0                	test   %eax,%eax
f010097c:	74 38                	je     f01009b6 <monitor+0x139>
f010097e:	83 ec 08             	sub    $0x8,%esp
f0100981:	8d 83 e4 19 ff ff    	lea    -0xe61c(%ebx),%eax
f0100987:	50                   	push   %eax
f0100988:	ff 75 a8             	push   -0x58(%ebp)
f010098b:	e8 88 0b 00 00       	call   f0101518 <strcmp>
f0100990:	83 c4 10             	add    $0x10,%esp
f0100993:	85 c0                	test   %eax,%eax
f0100995:	74 1a                	je     f01009b1 <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100997:	83 ec 08             	sub    $0x8,%esp
f010099a:	ff 75 a8             	push   -0x58(%ebp)
f010099d:	8d 83 2c 1a ff ff    	lea    -0xe5d4(%ebx),%eax
f01009a3:	50                   	push   %eax
f01009a4:	e8 90 00 00 00       	call   f0100a39 <cprintf>
	return 0;
f01009a9:	83 c4 10             	add    $0x10,%esp
f01009ac:	e9 4f ff ff ff       	jmp    f0100900 <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009b1:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01009b6:	83 ec 04             	sub    $0x4,%esp
f01009b9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01009bc:	ff 75 08             	push   0x8(%ebp)
f01009bf:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009c2:	52                   	push   %edx
f01009c3:	ff 75 a4             	push   -0x5c(%ebp)
f01009c6:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f01009cd:	83 c4 10             	add    $0x10,%esp
f01009d0:	85 c0                	test   %eax,%eax
f01009d2:	0f 89 28 ff ff ff    	jns    f0100900 <monitor+0x83>
				break;
	}
}
f01009d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009db:	5b                   	pop    %ebx
f01009dc:	5e                   	pop    %esi
f01009dd:	5f                   	pop    %edi
f01009de:	5d                   	pop    %ebp
f01009df:	c3                   	ret    

f01009e0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009e0:	55                   	push   %ebp
f01009e1:	89 e5                	mov    %esp,%ebp
f01009e3:	53                   	push   %ebx
f01009e4:	83 ec 10             	sub    $0x10,%esp
f01009e7:	e8 d0 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01009ec:	81 c3 1c f9 00 00    	add    $0xf91c,%ebx
	cputchar(ch);
f01009f2:	ff 75 08             	push   0x8(%ebp)
f01009f5:	e8 2d fd ff ff       	call   f0100727 <cputchar>
	*cnt++;
}
f01009fa:	83 c4 10             	add    $0x10,%esp
f01009fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a00:	c9                   	leave  
f0100a01:	c3                   	ret    

f0100a02 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a02:	55                   	push   %ebp
f0100a03:	89 e5                	mov    %esp,%ebp
f0100a05:	53                   	push   %ebx
f0100a06:	83 ec 14             	sub    $0x14,%esp
f0100a09:	e8 ae f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a0e:	81 c3 fa f8 00 00    	add    $0xf8fa,%ebx
	int cnt = 0;
f0100a14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a1b:	ff 75 0c             	push   0xc(%ebp)
f0100a1e:	ff 75 08             	push   0x8(%ebp)
f0100a21:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a24:	50                   	push   %eax
f0100a25:	8d 83 d8 06 ff ff    	lea    -0xf928(%ebx),%eax
f0100a2b:	50                   	push   %eax
f0100a2c:	e8 0d 04 00 00       	call   f0100e3e <vprintfmt>
	return cnt;
}
f0100a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a37:	c9                   	leave  
f0100a38:	c3                   	ret    

f0100a39 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a39:	55                   	push   %ebp
f0100a3a:	89 e5                	mov    %esp,%ebp
f0100a3c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a3f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a42:	50                   	push   %eax
f0100a43:	ff 75 08             	push   0x8(%ebp)
f0100a46:	e8 b7 ff ff ff       	call   f0100a02 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a4b:	c9                   	leave  
f0100a4c:	c3                   	ret    

f0100a4d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a4d:	55                   	push   %ebp
f0100a4e:	89 e5                	mov    %esp,%ebp
f0100a50:	57                   	push   %edi
f0100a51:	56                   	push   %esi
f0100a52:	53                   	push   %ebx
f0100a53:	83 ec 14             	sub    $0x14,%esp
f0100a56:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a5c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a5f:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a62:	8b 1a                	mov    (%edx),%ebx
f0100a64:	8b 01                	mov    (%ecx),%eax
f0100a66:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a69:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a70:	eb 2f                	jmp    f0100aa1 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100a72:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100a75:	39 c3                	cmp    %eax,%ebx
f0100a77:	7f 4e                	jg     f0100ac7 <stab_binsearch+0x7a>
f0100a79:	0f b6 0a             	movzbl (%edx),%ecx
f0100a7c:	83 ea 0c             	sub    $0xc,%edx
f0100a7f:	39 f1                	cmp    %esi,%ecx
f0100a81:	75 ef                	jne    f0100a72 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a83:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a86:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a89:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a8d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a90:	73 3a                	jae    f0100acc <stab_binsearch+0x7f>
			*region_left = m;
f0100a92:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a95:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a97:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100a9a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100aa1:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100aa4:	7f 53                	jg     f0100af9 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100aa9:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100aac:	89 d0                	mov    %edx,%eax
f0100aae:	c1 e8 1f             	shr    $0x1f,%eax
f0100ab1:	01 d0                	add    %edx,%eax
f0100ab3:	89 c7                	mov    %eax,%edi
f0100ab5:	d1 ff                	sar    %edi
f0100ab7:	83 e0 fe             	and    $0xfffffffe,%eax
f0100aba:	01 f8                	add    %edi,%eax
f0100abc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100abf:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100ac3:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100ac5:	eb ae                	jmp    f0100a75 <stab_binsearch+0x28>
			l = true_m + 1;
f0100ac7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100aca:	eb d5                	jmp    f0100aa1 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100acc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100acf:	76 14                	jbe    f0100ae5 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100ad1:	83 e8 01             	sub    $0x1,%eax
f0100ad4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ad7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100ada:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100adc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100ae3:	eb bc                	jmp    f0100aa1 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100ae5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ae8:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100aea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100aee:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100af0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100af7:	eb a8                	jmp    f0100aa1 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100af9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100afd:	75 15                	jne    f0100b14 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100aff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b02:	8b 00                	mov    (%eax),%eax
f0100b04:	83 e8 01             	sub    $0x1,%eax
f0100b07:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b0a:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100b0c:	83 c4 14             	add    $0x14,%esp
f0100b0f:	5b                   	pop    %ebx
f0100b10:	5e                   	pop    %esi
f0100b11:	5f                   	pop    %edi
f0100b12:	5d                   	pop    %ebp
f0100b13:	c3                   	ret    
		for (l = *region_right;
f0100b14:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b17:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b1c:	8b 0f                	mov    (%edi),%ecx
f0100b1e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b21:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100b24:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0100b28:	39 c1                	cmp    %eax,%ecx
f0100b2a:	7d 0f                	jge    f0100b3b <stab_binsearch+0xee>
f0100b2c:	0f b6 1a             	movzbl (%edx),%ebx
f0100b2f:	83 ea 0c             	sub    $0xc,%edx
f0100b32:	39 f3                	cmp    %esi,%ebx
f0100b34:	74 05                	je     f0100b3b <stab_binsearch+0xee>
		     l--)
f0100b36:	83 e8 01             	sub    $0x1,%eax
f0100b39:	eb ed                	jmp    f0100b28 <stab_binsearch+0xdb>
		*region_left = l;
f0100b3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b3e:	89 07                	mov    %eax,(%edi)
}
f0100b40:	eb ca                	jmp    f0100b0c <stab_binsearch+0xbf>

f0100b42 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b42:	55                   	push   %ebp
f0100b43:	89 e5                	mov    %esp,%ebp
f0100b45:	57                   	push   %edi
f0100b46:	56                   	push   %esi
f0100b47:	53                   	push   %ebx
f0100b48:	83 ec 2c             	sub    $0x2c,%esp
f0100b4b:	e8 6c f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100b50:	81 c3 b8 f7 00 00    	add    $0xf7b8,%ebx
f0100b56:	8b 75 08             	mov    0x8(%ebp),%esi
f0100b59:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b5c:	8d 83 99 1b ff ff    	lea    -0xe467(%ebx),%eax
f0100b62:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100b64:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100b6b:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100b6e:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100b75:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0100b78:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b7f:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b85:	0f 86 f9 00 00 00    	jbe    f0100c84 <debuginfo_eip+0x142>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b8b:	c7 c0 f5 57 10 f0    	mov    $0xf01057f5,%eax
f0100b91:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100b97:	0f 86 87 01 00 00    	jbe    f0100d24 <debuginfo_eip+0x1e2>
f0100b9d:	c7 c0 1d 6d 10 f0    	mov    $0xf0106d1d,%eax
f0100ba3:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100ba7:	0f 85 7e 01 00 00    	jne    f0100d2b <debuginfo_eip+0x1e9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bb4:	c7 c0 bc 20 10 f0    	mov    $0xf01020bc,%eax
f0100bba:	c7 c2 f4 57 10 f0    	mov    $0xf01057f4,%edx
f0100bc0:	29 c2                	sub    %eax,%edx
f0100bc2:	c1 fa 02             	sar    $0x2,%edx
f0100bc5:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100bcb:	83 ea 01             	sub    $0x1,%edx
f0100bce:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bd1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100bd4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100bd7:	83 ec 08             	sub    $0x8,%esp
f0100bda:	56                   	push   %esi
f0100bdb:	6a 64                	push   $0x64
f0100bdd:	e8 6b fe ff ff       	call   f0100a4d <stab_binsearch>
	if (lfile == 0)
f0100be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100be5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100be8:	83 c4 10             	add    $0x10,%esp
f0100beb:	85 c0                	test   %eax,%eax
f0100bed:	0f 84 3f 01 00 00    	je     f0100d32 <debuginfo_eip+0x1f0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100bf3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100bf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bf9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100bfc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100bff:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c02:	83 ec 08             	sub    $0x8,%esp
f0100c05:	56                   	push   %esi
f0100c06:	6a 24                	push   $0x24
f0100c08:	c7 c0 bc 20 10 f0    	mov    $0xf01020bc,%eax
f0100c0e:	e8 3a fe ff ff       	call   f0100a4d <stab_binsearch>

	if (lfun <= rfun) {
f0100c13:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100c16:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100c19:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c1c:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0100c1f:	83 c4 10             	add    $0x10,%esp
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
		lline = lfile;
f0100c22:	8b 75 d4             	mov    -0x2c(%ebp),%esi
	if (lfun <= rfun) {
f0100c25:	39 d1                	cmp    %edx,%ecx
f0100c27:	7f 30                	jg     f0100c59 <debuginfo_eip+0x117>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c29:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100c2c:	c7 c2 bc 20 10 f0    	mov    $0xf01020bc,%edx
f0100c32:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100c35:	8b 11                	mov    (%ecx),%edx
f0100c37:	c7 c0 1d 6d 10 f0    	mov    $0xf0106d1d,%eax
f0100c3d:	81 e8 f5 57 10 f0    	sub    $0xf01057f5,%eax
f0100c43:	39 c2                	cmp    %eax,%edx
f0100c45:	73 09                	jae    f0100c50 <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c47:	81 c2 f5 57 10 f0    	add    $0xf01057f5,%edx
f0100c4d:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c50:	8b 41 08             	mov    0x8(%ecx),%eax
f0100c53:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfun;
f0100c56:	8b 75 d0             	mov    -0x30(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c59:	83 ec 08             	sub    $0x8,%esp
f0100c5c:	6a 3a                	push   $0x3a
f0100c5e:	ff 77 08             	push   0x8(%edi)
f0100c61:	e8 35 09 00 00       	call   f010159b <strfind>
f0100c66:	2b 47 08             	sub    0x8(%edi),%eax
f0100c69:	89 47 0c             	mov    %eax,0xc(%edi)
f0100c6c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c6f:	c7 c2 bc 20 10 f0    	mov    $0xf01020bc,%edx
f0100c75:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c79:	83 c4 10             	add    $0x10,%esp
f0100c7c:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0100c7f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100c82:	eb 1e                	jmp    f0100ca2 <debuginfo_eip+0x160>
  	        panic("User address");
f0100c84:	83 ec 04             	sub    $0x4,%esp
f0100c87:	8d 83 a3 1b ff ff    	lea    -0xe45d(%ebx),%eax
f0100c8d:	50                   	push   %eax
f0100c8e:	6a 7f                	push   $0x7f
f0100c90:	8d 83 b0 1b ff ff    	lea    -0xe450(%ebx),%eax
f0100c96:	50                   	push   %eax
f0100c97:	e8 6a f4 ff ff       	call   f0100106 <_panic>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100c9c:	83 ee 01             	sub    $0x1,%esi
f0100c9f:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100ca2:	39 f7                	cmp    %esi,%edi
f0100ca4:	7f 3c                	jg     f0100ce2 <debuginfo_eip+0x1a0>
	       && stabs[lline].n_type != N_SOL
f0100ca6:	0f b6 10             	movzbl (%eax),%edx
f0100ca9:	80 fa 84             	cmp    $0x84,%dl
f0100cac:	74 0b                	je     f0100cb9 <debuginfo_eip+0x177>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100cae:	80 fa 64             	cmp    $0x64,%dl
f0100cb1:	75 e9                	jne    f0100c9c <debuginfo_eip+0x15a>
f0100cb3:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100cb7:	74 e3                	je     f0100c9c <debuginfo_eip+0x15a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100cb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100cbc:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100cbf:	c7 c0 bc 20 10 f0    	mov    $0xf01020bc,%eax
f0100cc5:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100cc8:	c7 c0 1d 6d 10 f0    	mov    $0xf0106d1d,%eax
f0100cce:	81 e8 f5 57 10 f0    	sub    $0xf01057f5,%eax
f0100cd4:	39 c2                	cmp    %eax,%edx
f0100cd6:	73 0d                	jae    f0100ce5 <debuginfo_eip+0x1a3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100cd8:	81 c2 f5 57 10 f0    	add    $0xf01057f5,%edx
f0100cde:	89 17                	mov    %edx,(%edi)
f0100ce0:	eb 03                	jmp    f0100ce5 <debuginfo_eip+0x1a3>
f0100ce2:	8b 7d 0c             	mov    0xc(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ce5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100cea:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ced:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100cf0:	39 ce                	cmp    %ecx,%esi
f0100cf2:	7d 4a                	jge    f0100d3e <debuginfo_eip+0x1fc>
		for (lline = lfun + 1;
f0100cf4:	8d 56 01             	lea    0x1(%esi),%edx
f0100cf7:	8d 0c 76             	lea    (%esi,%esi,2),%ecx
f0100cfa:	c7 c0 bc 20 10 f0    	mov    $0xf01020bc,%eax
f0100d00:	8d 44 88 10          	lea    0x10(%eax,%ecx,4),%eax
f0100d04:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100d07:	eb 07                	jmp    f0100d10 <debuginfo_eip+0x1ce>
			info->eip_fn_narg++;
f0100d09:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100d0d:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d10:	39 d1                	cmp    %edx,%ecx
f0100d12:	74 25                	je     f0100d39 <debuginfo_eip+0x1f7>
f0100d14:	83 c0 0c             	add    $0xc,%eax
f0100d17:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100d1b:	74 ec                	je     f0100d09 <debuginfo_eip+0x1c7>
	return 0;
f0100d1d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d22:	eb 1a                	jmp    f0100d3e <debuginfo_eip+0x1fc>
		return -1;
f0100d24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d29:	eb 13                	jmp    f0100d3e <debuginfo_eip+0x1fc>
f0100d2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d30:	eb 0c                	jmp    f0100d3e <debuginfo_eip+0x1fc>
		return -1;
f0100d32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d37:	eb 05                	jmp    f0100d3e <debuginfo_eip+0x1fc>
	return 0;
f0100d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d41:	5b                   	pop    %ebx
f0100d42:	5e                   	pop    %esi
f0100d43:	5f                   	pop    %edi
f0100d44:	5d                   	pop    %ebp
f0100d45:	c3                   	ret    

f0100d46 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d46:	55                   	push   %ebp
f0100d47:	89 e5                	mov    %esp,%ebp
f0100d49:	57                   	push   %edi
f0100d4a:	56                   	push   %esi
f0100d4b:	53                   	push   %ebx
f0100d4c:	83 ec 2c             	sub    $0x2c,%esp
f0100d4f:	e8 cf 05 00 00       	call   f0101323 <__x86.get_pc_thunk.cx>
f0100d54:	81 c1 b4 f5 00 00    	add    $0xf5b4,%ecx
f0100d5a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100d5d:	89 c7                	mov    %eax,%edi
f0100d5f:	89 d6                	mov    %edx,%esi
f0100d61:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d64:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d67:	89 d1                	mov    %edx,%ecx
f0100d69:	89 c2                	mov    %eax,%edx
f0100d6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d6e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100d71:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d74:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d77:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d7a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d81:	39 c2                	cmp    %eax,%edx
f0100d83:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100d86:	72 41                	jb     f0100dc9 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d88:	83 ec 0c             	sub    $0xc,%esp
f0100d8b:	ff 75 18             	push   0x18(%ebp)
f0100d8e:	83 eb 01             	sub    $0x1,%ebx
f0100d91:	53                   	push   %ebx
f0100d92:	50                   	push   %eax
f0100d93:	83 ec 08             	sub    $0x8,%esp
f0100d96:	ff 75 e4             	push   -0x1c(%ebp)
f0100d99:	ff 75 e0             	push   -0x20(%ebp)
f0100d9c:	ff 75 d4             	push   -0x2c(%ebp)
f0100d9f:	ff 75 d0             	push   -0x30(%ebp)
f0100da2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100da5:	e8 06 0a 00 00       	call   f01017b0 <__udivdi3>
f0100daa:	83 c4 18             	add    $0x18,%esp
f0100dad:	52                   	push   %edx
f0100dae:	50                   	push   %eax
f0100daf:	89 f2                	mov    %esi,%edx
f0100db1:	89 f8                	mov    %edi,%eax
f0100db3:	e8 8e ff ff ff       	call   f0100d46 <printnum>
f0100db8:	83 c4 20             	add    $0x20,%esp
f0100dbb:	eb 13                	jmp    f0100dd0 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100dbd:	83 ec 08             	sub    $0x8,%esp
f0100dc0:	56                   	push   %esi
f0100dc1:	ff 75 18             	push   0x18(%ebp)
f0100dc4:	ff d7                	call   *%edi
f0100dc6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100dc9:	83 eb 01             	sub    $0x1,%ebx
f0100dcc:	85 db                	test   %ebx,%ebx
f0100dce:	7f ed                	jg     f0100dbd <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100dd0:	83 ec 08             	sub    $0x8,%esp
f0100dd3:	56                   	push   %esi
f0100dd4:	83 ec 04             	sub    $0x4,%esp
f0100dd7:	ff 75 e4             	push   -0x1c(%ebp)
f0100dda:	ff 75 e0             	push   -0x20(%ebp)
f0100ddd:	ff 75 d4             	push   -0x2c(%ebp)
f0100de0:	ff 75 d0             	push   -0x30(%ebp)
f0100de3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100de6:	e8 e5 0a 00 00       	call   f01018d0 <__umoddi3>
f0100deb:	83 c4 14             	add    $0x14,%esp
f0100dee:	0f be 84 03 be 1b ff 	movsbl -0xe442(%ebx,%eax,1),%eax
f0100df5:	ff 
f0100df6:	50                   	push   %eax
f0100df7:	ff d7                	call   *%edi
}
f0100df9:	83 c4 10             	add    $0x10,%esp
f0100dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dff:	5b                   	pop    %ebx
f0100e00:	5e                   	pop    %esi
f0100e01:	5f                   	pop    %edi
f0100e02:	5d                   	pop    %ebp
f0100e03:	c3                   	ret    

f0100e04 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e04:	55                   	push   %ebp
f0100e05:	89 e5                	mov    %esp,%ebp
f0100e07:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e0a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e0e:	8b 10                	mov    (%eax),%edx
f0100e10:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e13:	73 0a                	jae    f0100e1f <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e15:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e18:	89 08                	mov    %ecx,(%eax)
f0100e1a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e1d:	88 02                	mov    %al,(%edx)
}
f0100e1f:	5d                   	pop    %ebp
f0100e20:	c3                   	ret    

f0100e21 <printfmt>:
{
f0100e21:	55                   	push   %ebp
f0100e22:	89 e5                	mov    %esp,%ebp
f0100e24:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100e27:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e2a:	50                   	push   %eax
f0100e2b:	ff 75 10             	push   0x10(%ebp)
f0100e2e:	ff 75 0c             	push   0xc(%ebp)
f0100e31:	ff 75 08             	push   0x8(%ebp)
f0100e34:	e8 05 00 00 00       	call   f0100e3e <vprintfmt>
}
f0100e39:	83 c4 10             	add    $0x10,%esp
f0100e3c:	c9                   	leave  
f0100e3d:	c3                   	ret    

f0100e3e <vprintfmt>:
{
f0100e3e:	55                   	push   %ebp
f0100e3f:	89 e5                	mov    %esp,%ebp
f0100e41:	57                   	push   %edi
f0100e42:	56                   	push   %esi
f0100e43:	53                   	push   %ebx
f0100e44:	83 ec 3c             	sub    $0x3c,%esp
f0100e47:	e8 02 f9 ff ff       	call   f010074e <__x86.get_pc_thunk.ax>
f0100e4c:	05 bc f4 00 00       	add    $0xf4bc,%eax
f0100e51:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e54:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e57:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e5d:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f0100e63:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100e66:	eb 0a                	jmp    f0100e72 <vprintfmt+0x34>
			putch(ch, putdat);
f0100e68:	83 ec 08             	sub    $0x8,%esp
f0100e6b:	57                   	push   %edi
f0100e6c:	50                   	push   %eax
f0100e6d:	ff d6                	call   *%esi
f0100e6f:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e72:	83 c3 01             	add    $0x1,%ebx
f0100e75:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100e79:	83 f8 25             	cmp    $0x25,%eax
f0100e7c:	74 0c                	je     f0100e8a <vprintfmt+0x4c>
			if (ch == '\0')
f0100e7e:	85 c0                	test   %eax,%eax
f0100e80:	75 e6                	jne    f0100e68 <vprintfmt+0x2a>
}
f0100e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e85:	5b                   	pop    %ebx
f0100e86:	5e                   	pop    %esi
f0100e87:	5f                   	pop    %edi
f0100e88:	5d                   	pop    %ebp
f0100e89:	c3                   	ret    
		padc = ' ';
f0100e8a:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100e8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0100e95:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100e9c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0100ea3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ea8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100eab:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100eae:	8d 43 01             	lea    0x1(%ebx),%eax
f0100eb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100eb4:	0f b6 13             	movzbl (%ebx),%edx
f0100eb7:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100eba:	3c 55                	cmp    $0x55,%al
f0100ebc:	0f 87 c5 03 00 00    	ja     f0101287 <.L20>
f0100ec2:	0f b6 c0             	movzbl %al,%eax
f0100ec5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ec8:	89 ce                	mov    %ecx,%esi
f0100eca:	03 b4 81 4c 1c ff ff 	add    -0xe3b4(%ecx,%eax,4),%esi
f0100ed1:	ff e6                	jmp    *%esi

f0100ed3 <.L66>:
f0100ed3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100ed6:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100eda:	eb d2                	jmp    f0100eae <vprintfmt+0x70>

f0100edc <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100edc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100edf:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100ee3:	eb c9                	jmp    f0100eae <vprintfmt+0x70>

f0100ee5 <.L31>:
f0100ee5:	0f b6 d2             	movzbl %dl,%edx
f0100ee8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0100eeb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef0:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0100ef3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100ef6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100efa:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0100efd:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100f00:	83 f9 09             	cmp    $0x9,%ecx
f0100f03:	77 58                	ja     f0100f5d <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0100f05:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0100f08:	eb e9                	jmp    f0100ef3 <.L31+0xe>

f0100f0a <.L34>:
			precision = va_arg(ap, int);
f0100f0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f0d:	8b 00                	mov    (%eax),%eax
f0100f0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f12:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f15:	8d 40 04             	lea    0x4(%eax),%eax
f0100f18:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f1b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0100f1e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100f22:	79 8a                	jns    f0100eae <vprintfmt+0x70>
				width = precision, precision = -1;
f0100f24:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f27:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f2a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0100f31:	e9 78 ff ff ff       	jmp    f0100eae <vprintfmt+0x70>

f0100f36 <.L33>:
f0100f36:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100f39:	85 d2                	test   %edx,%edx
f0100f3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f40:	0f 49 c2             	cmovns %edx,%eax
f0100f43:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f46:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100f49:	e9 60 ff ff ff       	jmp    f0100eae <vprintfmt+0x70>

f0100f4e <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0100f4e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0100f51:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0100f58:	e9 51 ff ff ff       	jmp    f0100eae <vprintfmt+0x70>
f0100f5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f60:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f63:	eb b9                	jmp    f0100f1e <.L34+0x14>

f0100f65 <.L27>:
			lflag++;
f0100f65:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f69:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100f6c:	e9 3d ff ff ff       	jmp    f0100eae <vprintfmt+0x70>

f0100f71 <.L30>:
			putch(va_arg(ap, int), putdat);
f0100f71:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f74:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f77:	8d 58 04             	lea    0x4(%eax),%ebx
f0100f7a:	83 ec 08             	sub    $0x8,%esp
f0100f7d:	57                   	push   %edi
f0100f7e:	ff 30                	push   (%eax)
f0100f80:	ff d6                	call   *%esi
			break;
f0100f82:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100f85:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0100f88:	e9 90 02 00 00       	jmp    f010121d <.L25+0x45>

f0100f8d <.L28>:
			err = va_arg(ap, int);
f0100f8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f90:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f93:	8d 58 04             	lea    0x4(%eax),%ebx
f0100f96:	8b 10                	mov    (%eax),%edx
f0100f98:	89 d0                	mov    %edx,%eax
f0100f9a:	f7 d8                	neg    %eax
f0100f9c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f9f:	83 f8 06             	cmp    $0x6,%eax
f0100fa2:	7f 27                	jg     f0100fcb <.L28+0x3e>
f0100fa4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100fa7:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0100faa:	85 d2                	test   %edx,%edx
f0100fac:	74 1d                	je     f0100fcb <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0100fae:	52                   	push   %edx
f0100faf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fb2:	8d 80 df 1b ff ff    	lea    -0xe421(%eax),%eax
f0100fb8:	50                   	push   %eax
f0100fb9:	57                   	push   %edi
f0100fba:	56                   	push   %esi
f0100fbb:	e8 61 fe ff ff       	call   f0100e21 <printfmt>
f0100fc0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100fc3:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0100fc6:	e9 52 02 00 00       	jmp    f010121d <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0100fcb:	50                   	push   %eax
f0100fcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fcf:	8d 80 d6 1b ff ff    	lea    -0xe42a(%eax),%eax
f0100fd5:	50                   	push   %eax
f0100fd6:	57                   	push   %edi
f0100fd7:	56                   	push   %esi
f0100fd8:	e8 44 fe ff ff       	call   f0100e21 <printfmt>
f0100fdd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100fe0:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100fe3:	e9 35 02 00 00       	jmp    f010121d <.L25+0x45>

f0100fe8 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0100fe8:	8b 75 08             	mov    0x8(%ebp),%esi
f0100feb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fee:	83 c0 04             	add    $0x4,%eax
f0100ff1:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100ff4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff7:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0100ff9:	85 d2                	test   %edx,%edx
f0100ffb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ffe:	8d 80 cf 1b ff ff    	lea    -0xe431(%eax),%eax
f0101004:	0f 45 c2             	cmovne %edx,%eax
f0101007:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f010100a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010100e:	7e 06                	jle    f0101016 <.L24+0x2e>
f0101010:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101014:	75 0d                	jne    f0101023 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101016:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101019:	89 c3                	mov    %eax,%ebx
f010101b:	03 45 d0             	add    -0x30(%ebp),%eax
f010101e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101021:	eb 58                	jmp    f010107b <.L24+0x93>
f0101023:	83 ec 08             	sub    $0x8,%esp
f0101026:	ff 75 d8             	push   -0x28(%ebp)
f0101029:	ff 75 c8             	push   -0x38(%ebp)
f010102c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010102f:	e8 10 04 00 00       	call   f0101444 <strnlen>
f0101034:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101037:	29 c2                	sub    %eax,%edx
f0101039:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010103c:	83 c4 10             	add    $0x10,%esp
f010103f:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0101041:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101045:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101048:	eb 0f                	jmp    f0101059 <.L24+0x71>
					putch(padc, putdat);
f010104a:	83 ec 08             	sub    $0x8,%esp
f010104d:	57                   	push   %edi
f010104e:	ff 75 d0             	push   -0x30(%ebp)
f0101051:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101053:	83 eb 01             	sub    $0x1,%ebx
f0101056:	83 c4 10             	add    $0x10,%esp
f0101059:	85 db                	test   %ebx,%ebx
f010105b:	7f ed                	jg     f010104a <.L24+0x62>
f010105d:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0101060:	85 d2                	test   %edx,%edx
f0101062:	b8 00 00 00 00       	mov    $0x0,%eax
f0101067:	0f 49 c2             	cmovns %edx,%eax
f010106a:	29 c2                	sub    %eax,%edx
f010106c:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010106f:	eb a5                	jmp    f0101016 <.L24+0x2e>
					putch(ch, putdat);
f0101071:	83 ec 08             	sub    $0x8,%esp
f0101074:	57                   	push   %edi
f0101075:	52                   	push   %edx
f0101076:	ff d6                	call   *%esi
f0101078:	83 c4 10             	add    $0x10,%esp
f010107b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010107e:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101080:	83 c3 01             	add    $0x1,%ebx
f0101083:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101087:	0f be d0             	movsbl %al,%edx
f010108a:	85 d2                	test   %edx,%edx
f010108c:	74 4b                	je     f01010d9 <.L24+0xf1>
f010108e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101092:	78 06                	js     f010109a <.L24+0xb2>
f0101094:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101098:	78 1e                	js     f01010b8 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010109a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010109e:	74 d1                	je     f0101071 <.L24+0x89>
f01010a0:	0f be c0             	movsbl %al,%eax
f01010a3:	83 e8 20             	sub    $0x20,%eax
f01010a6:	83 f8 5e             	cmp    $0x5e,%eax
f01010a9:	76 c6                	jbe    f0101071 <.L24+0x89>
					putch('?', putdat);
f01010ab:	83 ec 08             	sub    $0x8,%esp
f01010ae:	57                   	push   %edi
f01010af:	6a 3f                	push   $0x3f
f01010b1:	ff d6                	call   *%esi
f01010b3:	83 c4 10             	add    $0x10,%esp
f01010b6:	eb c3                	jmp    f010107b <.L24+0x93>
f01010b8:	89 cb                	mov    %ecx,%ebx
f01010ba:	eb 0e                	jmp    f01010ca <.L24+0xe2>
				putch(' ', putdat);
f01010bc:	83 ec 08             	sub    $0x8,%esp
f01010bf:	57                   	push   %edi
f01010c0:	6a 20                	push   $0x20
f01010c2:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01010c4:	83 eb 01             	sub    $0x1,%ebx
f01010c7:	83 c4 10             	add    $0x10,%esp
f01010ca:	85 db                	test   %ebx,%ebx
f01010cc:	7f ee                	jg     f01010bc <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01010ce:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01010d1:	89 45 14             	mov    %eax,0x14(%ebp)
f01010d4:	e9 44 01 00 00       	jmp    f010121d <.L25+0x45>
f01010d9:	89 cb                	mov    %ecx,%ebx
f01010db:	eb ed                	jmp    f01010ca <.L24+0xe2>

f01010dd <.L29>:
	if (lflag >= 2)
f01010dd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01010e0:	8b 75 08             	mov    0x8(%ebp),%esi
f01010e3:	83 f9 01             	cmp    $0x1,%ecx
f01010e6:	7f 1b                	jg     f0101103 <.L29+0x26>
	else if (lflag)
f01010e8:	85 c9                	test   %ecx,%ecx
f01010ea:	74 63                	je     f010114f <.L29+0x72>
		return va_arg(*ap, long);
f01010ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ef:	8b 00                	mov    (%eax),%eax
f01010f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010f4:	99                   	cltd   
f01010f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fb:	8d 40 04             	lea    0x4(%eax),%eax
f01010fe:	89 45 14             	mov    %eax,0x14(%ebp)
f0101101:	eb 17                	jmp    f010111a <.L29+0x3d>
		return va_arg(*ap, long long);
f0101103:	8b 45 14             	mov    0x14(%ebp),%eax
f0101106:	8b 50 04             	mov    0x4(%eax),%edx
f0101109:	8b 00                	mov    (%eax),%eax
f010110b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010110e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101111:	8b 45 14             	mov    0x14(%ebp),%eax
f0101114:	8d 40 08             	lea    0x8(%eax),%eax
f0101117:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010111a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010111d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0101120:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0101125:	85 db                	test   %ebx,%ebx
f0101127:	0f 89 d6 00 00 00    	jns    f0101203 <.L25+0x2b>
				putch('-', putdat);
f010112d:	83 ec 08             	sub    $0x8,%esp
f0101130:	57                   	push   %edi
f0101131:	6a 2d                	push   $0x2d
f0101133:	ff d6                	call   *%esi
				num = -(long long) num;
f0101135:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101138:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010113b:	f7 d9                	neg    %ecx
f010113d:	83 d3 00             	adc    $0x0,%ebx
f0101140:	f7 db                	neg    %ebx
f0101142:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101145:	ba 0a 00 00 00       	mov    $0xa,%edx
f010114a:	e9 b4 00 00 00       	jmp    f0101203 <.L25+0x2b>
		return va_arg(*ap, int);
f010114f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101152:	8b 00                	mov    (%eax),%eax
f0101154:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101157:	99                   	cltd   
f0101158:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010115b:	8b 45 14             	mov    0x14(%ebp),%eax
f010115e:	8d 40 04             	lea    0x4(%eax),%eax
f0101161:	89 45 14             	mov    %eax,0x14(%ebp)
f0101164:	eb b4                	jmp    f010111a <.L29+0x3d>

f0101166 <.L23>:
	if (lflag >= 2)
f0101166:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101169:	8b 75 08             	mov    0x8(%ebp),%esi
f010116c:	83 f9 01             	cmp    $0x1,%ecx
f010116f:	7f 1b                	jg     f010118c <.L23+0x26>
	else if (lflag)
f0101171:	85 c9                	test   %ecx,%ecx
f0101173:	74 2c                	je     f01011a1 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0101175:	8b 45 14             	mov    0x14(%ebp),%eax
f0101178:	8b 08                	mov    (%eax),%ecx
f010117a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010117f:	8d 40 04             	lea    0x4(%eax),%eax
f0101182:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101185:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f010118a:	eb 77                	jmp    f0101203 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010118c:	8b 45 14             	mov    0x14(%ebp),%eax
f010118f:	8b 08                	mov    (%eax),%ecx
f0101191:	8b 58 04             	mov    0x4(%eax),%ebx
f0101194:	8d 40 08             	lea    0x8(%eax),%eax
f0101197:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010119a:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f010119f:	eb 62                	jmp    f0101203 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01011a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01011a4:	8b 08                	mov    (%eax),%ecx
f01011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011ab:	8d 40 04             	lea    0x4(%eax),%eax
f01011ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01011b1:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f01011b6:	eb 4b                	jmp    f0101203 <.L25+0x2b>

f01011b8 <.L26>:
			putch('X', putdat);
f01011b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01011bb:	83 ec 08             	sub    $0x8,%esp
f01011be:	57                   	push   %edi
f01011bf:	6a 58                	push   $0x58
f01011c1:	ff d6                	call   *%esi
			putch('X', putdat);
f01011c3:	83 c4 08             	add    $0x8,%esp
f01011c6:	57                   	push   %edi
f01011c7:	6a 58                	push   $0x58
f01011c9:	ff d6                	call   *%esi
			putch('X', putdat);
f01011cb:	83 c4 08             	add    $0x8,%esp
f01011ce:	57                   	push   %edi
f01011cf:	6a 58                	push   $0x58
f01011d1:	ff d6                	call   *%esi
			break;
f01011d3:	83 c4 10             	add    $0x10,%esp
f01011d6:	eb 45                	jmp    f010121d <.L25+0x45>

f01011d8 <.L25>:
			putch('0', putdat);
f01011d8:	8b 75 08             	mov    0x8(%ebp),%esi
f01011db:	83 ec 08             	sub    $0x8,%esp
f01011de:	57                   	push   %edi
f01011df:	6a 30                	push   $0x30
f01011e1:	ff d6                	call   *%esi
			putch('x', putdat);
f01011e3:	83 c4 08             	add    $0x8,%esp
f01011e6:	57                   	push   %edi
f01011e7:	6a 78                	push   $0x78
f01011e9:	ff d6                	call   *%esi
			num = (unsigned long long)
f01011eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ee:	8b 08                	mov    (%eax),%ecx
f01011f0:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01011f5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01011f8:	8d 40 04             	lea    0x4(%eax),%eax
f01011fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011fe:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0101203:	83 ec 0c             	sub    $0xc,%esp
f0101206:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010120a:	50                   	push   %eax
f010120b:	ff 75 d0             	push   -0x30(%ebp)
f010120e:	52                   	push   %edx
f010120f:	53                   	push   %ebx
f0101210:	51                   	push   %ecx
f0101211:	89 fa                	mov    %edi,%edx
f0101213:	89 f0                	mov    %esi,%eax
f0101215:	e8 2c fb ff ff       	call   f0100d46 <printnum>
			break;
f010121a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010121d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101220:	e9 4d fc ff ff       	jmp    f0100e72 <vprintfmt+0x34>

f0101225 <.L21>:
	if (lflag >= 2)
f0101225:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101228:	8b 75 08             	mov    0x8(%ebp),%esi
f010122b:	83 f9 01             	cmp    $0x1,%ecx
f010122e:	7f 1b                	jg     f010124b <.L21+0x26>
	else if (lflag)
f0101230:	85 c9                	test   %ecx,%ecx
f0101232:	74 2c                	je     f0101260 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101234:	8b 45 14             	mov    0x14(%ebp),%eax
f0101237:	8b 08                	mov    (%eax),%ecx
f0101239:	bb 00 00 00 00       	mov    $0x0,%ebx
f010123e:	8d 40 04             	lea    0x4(%eax),%eax
f0101241:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101244:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0101249:	eb b8                	jmp    f0101203 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010124b:	8b 45 14             	mov    0x14(%ebp),%eax
f010124e:	8b 08                	mov    (%eax),%ecx
f0101250:	8b 58 04             	mov    0x4(%eax),%ebx
f0101253:	8d 40 08             	lea    0x8(%eax),%eax
f0101256:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101259:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f010125e:	eb a3                	jmp    f0101203 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101260:	8b 45 14             	mov    0x14(%ebp),%eax
f0101263:	8b 08                	mov    (%eax),%ecx
f0101265:	bb 00 00 00 00       	mov    $0x0,%ebx
f010126a:	8d 40 04             	lea    0x4(%eax),%eax
f010126d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101270:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0101275:	eb 8c                	jmp    f0101203 <.L25+0x2b>

f0101277 <.L35>:
			putch(ch, putdat);
f0101277:	8b 75 08             	mov    0x8(%ebp),%esi
f010127a:	83 ec 08             	sub    $0x8,%esp
f010127d:	57                   	push   %edi
f010127e:	6a 25                	push   $0x25
f0101280:	ff d6                	call   *%esi
			break;
f0101282:	83 c4 10             	add    $0x10,%esp
f0101285:	eb 96                	jmp    f010121d <.L25+0x45>

f0101287 <.L20>:
			putch('%', putdat);
f0101287:	8b 75 08             	mov    0x8(%ebp),%esi
f010128a:	83 ec 08             	sub    $0x8,%esp
f010128d:	57                   	push   %edi
f010128e:	6a 25                	push   $0x25
f0101290:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101292:	83 c4 10             	add    $0x10,%esp
f0101295:	89 d8                	mov    %ebx,%eax
f0101297:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010129b:	74 05                	je     f01012a2 <.L20+0x1b>
f010129d:	83 e8 01             	sub    $0x1,%eax
f01012a0:	eb f5                	jmp    f0101297 <.L20+0x10>
f01012a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012a5:	e9 73 ff ff ff       	jmp    f010121d <.L25+0x45>

f01012aa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01012aa:	55                   	push   %ebp
f01012ab:	89 e5                	mov    %esp,%ebp
f01012ad:	53                   	push   %ebx
f01012ae:	83 ec 14             	sub    $0x14,%esp
f01012b1:	e8 06 ef ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01012b6:	81 c3 52 f0 00 00    	add    $0xf052,%ebx
f01012bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01012bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01012c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01012c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01012c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01012cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01012d3:	85 c0                	test   %eax,%eax
f01012d5:	74 2b                	je     f0101302 <vsnprintf+0x58>
f01012d7:	85 d2                	test   %edx,%edx
f01012d9:	7e 27                	jle    f0101302 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01012db:	ff 75 14             	push   0x14(%ebp)
f01012de:	ff 75 10             	push   0x10(%ebp)
f01012e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01012e4:	50                   	push   %eax
f01012e5:	8d 83 fc 0a ff ff    	lea    -0xf504(%ebx),%eax
f01012eb:	50                   	push   %eax
f01012ec:	e8 4d fb ff ff       	call   f0100e3e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01012f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01012f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012fa:	83 c4 10             	add    $0x10,%esp
}
f01012fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101300:	c9                   	leave  
f0101301:	c3                   	ret    
		return -E_INVAL;
f0101302:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101307:	eb f4                	jmp    f01012fd <vsnprintf+0x53>

f0101309 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101309:	55                   	push   %ebp
f010130a:	89 e5                	mov    %esp,%ebp
f010130c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010130f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101312:	50                   	push   %eax
f0101313:	ff 75 10             	push   0x10(%ebp)
f0101316:	ff 75 0c             	push   0xc(%ebp)
f0101319:	ff 75 08             	push   0x8(%ebp)
f010131c:	e8 89 ff ff ff       	call   f01012aa <vsnprintf>
	va_end(ap);

	return rc;
}
f0101321:	c9                   	leave  
f0101322:	c3                   	ret    

f0101323 <__x86.get_pc_thunk.cx>:
f0101323:	8b 0c 24             	mov    (%esp),%ecx
f0101326:	c3                   	ret    

f0101327 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101327:	55                   	push   %ebp
f0101328:	89 e5                	mov    %esp,%ebp
f010132a:	57                   	push   %edi
f010132b:	56                   	push   %esi
f010132c:	53                   	push   %ebx
f010132d:	83 ec 1c             	sub    $0x1c,%esp
f0101330:	e8 87 ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101335:	81 c3 d3 ef 00 00    	add    $0xefd3,%ebx
f010133b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010133e:	85 c0                	test   %eax,%eax
f0101340:	74 13                	je     f0101355 <readline+0x2e>
		cprintf("%s", prompt);
f0101342:	83 ec 08             	sub    $0x8,%esp
f0101345:	50                   	push   %eax
f0101346:	8d 83 df 1b ff ff    	lea    -0xe421(%ebx),%eax
f010134c:	50                   	push   %eax
f010134d:	e8 e7 f6 ff ff       	call   f0100a39 <cprintf>
f0101352:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101355:	83 ec 0c             	sub    $0xc,%esp
f0101358:	6a 00                	push   $0x0
f010135a:	e8 e9 f3 ff ff       	call   f0100748 <iscons>
f010135f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101362:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101365:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010136a:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101370:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101373:	eb 45                	jmp    f01013ba <readline+0x93>
			cprintf("read error: %e\n", c);
f0101375:	83 ec 08             	sub    $0x8,%esp
f0101378:	50                   	push   %eax
f0101379:	8d 83 a4 1d ff ff    	lea    -0xe25c(%ebx),%eax
f010137f:	50                   	push   %eax
f0101380:	e8 b4 f6 ff ff       	call   f0100a39 <cprintf>
			return NULL;
f0101385:	83 c4 10             	add    $0x10,%esp
f0101388:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010138d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101390:	5b                   	pop    %ebx
f0101391:	5e                   	pop    %esi
f0101392:	5f                   	pop    %edi
f0101393:	5d                   	pop    %ebp
f0101394:	c3                   	ret    
			if (echoing)
f0101395:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101399:	75 05                	jne    f01013a0 <readline+0x79>
			i--;
f010139b:	83 ef 01             	sub    $0x1,%edi
f010139e:	eb 1a                	jmp    f01013ba <readline+0x93>
				cputchar('\b');
f01013a0:	83 ec 0c             	sub    $0xc,%esp
f01013a3:	6a 08                	push   $0x8
f01013a5:	e8 7d f3 ff ff       	call   f0100727 <cputchar>
f01013aa:	83 c4 10             	add    $0x10,%esp
f01013ad:	eb ec                	jmp    f010139b <readline+0x74>
			buf[i++] = c;
f01013af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01013b2:	89 f0                	mov    %esi,%eax
f01013b4:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01013b7:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01013ba:	e8 78 f3 ff ff       	call   f0100737 <getchar>
f01013bf:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01013c1:	85 c0                	test   %eax,%eax
f01013c3:	78 b0                	js     f0101375 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013c5:	83 f8 08             	cmp    $0x8,%eax
f01013c8:	0f 94 c0             	sete   %al
f01013cb:	83 fe 7f             	cmp    $0x7f,%esi
f01013ce:	0f 94 c2             	sete   %dl
f01013d1:	08 d0                	or     %dl,%al
f01013d3:	74 04                	je     f01013d9 <readline+0xb2>
f01013d5:	85 ff                	test   %edi,%edi
f01013d7:	7f bc                	jg     f0101395 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01013d9:	83 fe 1f             	cmp    $0x1f,%esi
f01013dc:	7e 1c                	jle    f01013fa <readline+0xd3>
f01013de:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01013e4:	7f 14                	jg     f01013fa <readline+0xd3>
			if (echoing)
f01013e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01013ea:	74 c3                	je     f01013af <readline+0x88>
				cputchar(c);
f01013ec:	83 ec 0c             	sub    $0xc,%esp
f01013ef:	56                   	push   %esi
f01013f0:	e8 32 f3 ff ff       	call   f0100727 <cputchar>
f01013f5:	83 c4 10             	add    $0x10,%esp
f01013f8:	eb b5                	jmp    f01013af <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f01013fa:	83 fe 0a             	cmp    $0xa,%esi
f01013fd:	74 05                	je     f0101404 <readline+0xdd>
f01013ff:	83 fe 0d             	cmp    $0xd,%esi
f0101402:	75 b6                	jne    f01013ba <readline+0x93>
			if (echoing)
f0101404:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101408:	75 13                	jne    f010141d <readline+0xf6>
			buf[i] = 0;
f010140a:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0101411:	00 
			return buf;
f0101412:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101418:	e9 70 ff ff ff       	jmp    f010138d <readline+0x66>
				cputchar('\n');
f010141d:	83 ec 0c             	sub    $0xc,%esp
f0101420:	6a 0a                	push   $0xa
f0101422:	e8 00 f3 ff ff       	call   f0100727 <cputchar>
f0101427:	83 c4 10             	add    $0x10,%esp
f010142a:	eb de                	jmp    f010140a <readline+0xe3>

f010142c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010142c:	55                   	push   %ebp
f010142d:	89 e5                	mov    %esp,%ebp
f010142f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101432:	b8 00 00 00 00       	mov    $0x0,%eax
f0101437:	eb 03                	jmp    f010143c <strlen+0x10>
		n++;
f0101439:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010143c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101440:	75 f7                	jne    f0101439 <strlen+0xd>
	return n;
}
f0101442:	5d                   	pop    %ebp
f0101443:	c3                   	ret    

f0101444 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101444:	55                   	push   %ebp
f0101445:	89 e5                	mov    %esp,%ebp
f0101447:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010144a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010144d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101452:	eb 03                	jmp    f0101457 <strnlen+0x13>
		n++;
f0101454:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101457:	39 d0                	cmp    %edx,%eax
f0101459:	74 08                	je     f0101463 <strnlen+0x1f>
f010145b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010145f:	75 f3                	jne    f0101454 <strnlen+0x10>
f0101461:	89 c2                	mov    %eax,%edx
	return n;
}
f0101463:	89 d0                	mov    %edx,%eax
f0101465:	5d                   	pop    %ebp
f0101466:	c3                   	ret    

f0101467 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101467:	55                   	push   %ebp
f0101468:	89 e5                	mov    %esp,%ebp
f010146a:	53                   	push   %ebx
f010146b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101471:	b8 00 00 00 00       	mov    $0x0,%eax
f0101476:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010147a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010147d:	83 c0 01             	add    $0x1,%eax
f0101480:	84 d2                	test   %dl,%dl
f0101482:	75 f2                	jne    f0101476 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101484:	89 c8                	mov    %ecx,%eax
f0101486:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101489:	c9                   	leave  
f010148a:	c3                   	ret    

f010148b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010148b:	55                   	push   %ebp
f010148c:	89 e5                	mov    %esp,%ebp
f010148e:	53                   	push   %ebx
f010148f:	83 ec 10             	sub    $0x10,%esp
f0101492:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101495:	53                   	push   %ebx
f0101496:	e8 91 ff ff ff       	call   f010142c <strlen>
f010149b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f010149e:	ff 75 0c             	push   0xc(%ebp)
f01014a1:	01 d8                	add    %ebx,%eax
f01014a3:	50                   	push   %eax
f01014a4:	e8 be ff ff ff       	call   f0101467 <strcpy>
	return dst;
}
f01014a9:	89 d8                	mov    %ebx,%eax
f01014ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014ae:	c9                   	leave  
f01014af:	c3                   	ret    

f01014b0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014b0:	55                   	push   %ebp
f01014b1:	89 e5                	mov    %esp,%ebp
f01014b3:	56                   	push   %esi
f01014b4:	53                   	push   %ebx
f01014b5:	8b 75 08             	mov    0x8(%ebp),%esi
f01014b8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014bb:	89 f3                	mov    %esi,%ebx
f01014bd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014c0:	89 f0                	mov    %esi,%eax
f01014c2:	eb 0f                	jmp    f01014d3 <strncpy+0x23>
		*dst++ = *src;
f01014c4:	83 c0 01             	add    $0x1,%eax
f01014c7:	0f b6 0a             	movzbl (%edx),%ecx
f01014ca:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014cd:	80 f9 01             	cmp    $0x1,%cl
f01014d0:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f01014d3:	39 d8                	cmp    %ebx,%eax
f01014d5:	75 ed                	jne    f01014c4 <strncpy+0x14>
	}
	return ret;
}
f01014d7:	89 f0                	mov    %esi,%eax
f01014d9:	5b                   	pop    %ebx
f01014da:	5e                   	pop    %esi
f01014db:	5d                   	pop    %ebp
f01014dc:	c3                   	ret    

f01014dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01014dd:	55                   	push   %ebp
f01014de:	89 e5                	mov    %esp,%ebp
f01014e0:	56                   	push   %esi
f01014e1:	53                   	push   %ebx
f01014e2:	8b 75 08             	mov    0x8(%ebp),%esi
f01014e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014e8:	8b 55 10             	mov    0x10(%ebp),%edx
f01014eb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01014ed:	85 d2                	test   %edx,%edx
f01014ef:	74 21                	je     f0101512 <strlcpy+0x35>
f01014f1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01014f5:	89 f2                	mov    %esi,%edx
f01014f7:	eb 09                	jmp    f0101502 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01014f9:	83 c1 01             	add    $0x1,%ecx
f01014fc:	83 c2 01             	add    $0x1,%edx
f01014ff:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0101502:	39 c2                	cmp    %eax,%edx
f0101504:	74 09                	je     f010150f <strlcpy+0x32>
f0101506:	0f b6 19             	movzbl (%ecx),%ebx
f0101509:	84 db                	test   %bl,%bl
f010150b:	75 ec                	jne    f01014f9 <strlcpy+0x1c>
f010150d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010150f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101512:	29 f0                	sub    %esi,%eax
}
f0101514:	5b                   	pop    %ebx
f0101515:	5e                   	pop    %esi
f0101516:	5d                   	pop    %ebp
f0101517:	c3                   	ret    

f0101518 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101518:	55                   	push   %ebp
f0101519:	89 e5                	mov    %esp,%ebp
f010151b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010151e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101521:	eb 06                	jmp    f0101529 <strcmp+0x11>
		p++, q++;
f0101523:	83 c1 01             	add    $0x1,%ecx
f0101526:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0101529:	0f b6 01             	movzbl (%ecx),%eax
f010152c:	84 c0                	test   %al,%al
f010152e:	74 04                	je     f0101534 <strcmp+0x1c>
f0101530:	3a 02                	cmp    (%edx),%al
f0101532:	74 ef                	je     f0101523 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101534:	0f b6 c0             	movzbl %al,%eax
f0101537:	0f b6 12             	movzbl (%edx),%edx
f010153a:	29 d0                	sub    %edx,%eax
}
f010153c:	5d                   	pop    %ebp
f010153d:	c3                   	ret    

f010153e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010153e:	55                   	push   %ebp
f010153f:	89 e5                	mov    %esp,%ebp
f0101541:	53                   	push   %ebx
f0101542:	8b 45 08             	mov    0x8(%ebp),%eax
f0101545:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101548:	89 c3                	mov    %eax,%ebx
f010154a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010154d:	eb 06                	jmp    f0101555 <strncmp+0x17>
		n--, p++, q++;
f010154f:	83 c0 01             	add    $0x1,%eax
f0101552:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101555:	39 d8                	cmp    %ebx,%eax
f0101557:	74 18                	je     f0101571 <strncmp+0x33>
f0101559:	0f b6 08             	movzbl (%eax),%ecx
f010155c:	84 c9                	test   %cl,%cl
f010155e:	74 04                	je     f0101564 <strncmp+0x26>
f0101560:	3a 0a                	cmp    (%edx),%cl
f0101562:	74 eb                	je     f010154f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101564:	0f b6 00             	movzbl (%eax),%eax
f0101567:	0f b6 12             	movzbl (%edx),%edx
f010156a:	29 d0                	sub    %edx,%eax
}
f010156c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010156f:	c9                   	leave  
f0101570:	c3                   	ret    
		return 0;
f0101571:	b8 00 00 00 00       	mov    $0x0,%eax
f0101576:	eb f4                	jmp    f010156c <strncmp+0x2e>

f0101578 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101578:	55                   	push   %ebp
f0101579:	89 e5                	mov    %esp,%ebp
f010157b:	8b 45 08             	mov    0x8(%ebp),%eax
f010157e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101582:	eb 03                	jmp    f0101587 <strchr+0xf>
f0101584:	83 c0 01             	add    $0x1,%eax
f0101587:	0f b6 10             	movzbl (%eax),%edx
f010158a:	84 d2                	test   %dl,%dl
f010158c:	74 06                	je     f0101594 <strchr+0x1c>
		if (*s == c)
f010158e:	38 ca                	cmp    %cl,%dl
f0101590:	75 f2                	jne    f0101584 <strchr+0xc>
f0101592:	eb 05                	jmp    f0101599 <strchr+0x21>
			return (char *) s;
	return 0;
f0101594:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101599:	5d                   	pop    %ebp
f010159a:	c3                   	ret    

f010159b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010159b:	55                   	push   %ebp
f010159c:	89 e5                	mov    %esp,%ebp
f010159e:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015a5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01015a8:	38 ca                	cmp    %cl,%dl
f01015aa:	74 09                	je     f01015b5 <strfind+0x1a>
f01015ac:	84 d2                	test   %dl,%dl
f01015ae:	74 05                	je     f01015b5 <strfind+0x1a>
	for (; *s; s++)
f01015b0:	83 c0 01             	add    $0x1,%eax
f01015b3:	eb f0                	jmp    f01015a5 <strfind+0xa>
			break;
	return (char *) s;
}
f01015b5:	5d                   	pop    %ebp
f01015b6:	c3                   	ret    

f01015b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015b7:	55                   	push   %ebp
f01015b8:	89 e5                	mov    %esp,%ebp
f01015ba:	57                   	push   %edi
f01015bb:	56                   	push   %esi
f01015bc:	53                   	push   %ebx
f01015bd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015c3:	85 c9                	test   %ecx,%ecx
f01015c5:	74 2f                	je     f01015f6 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015c7:	89 f8                	mov    %edi,%eax
f01015c9:	09 c8                	or     %ecx,%eax
f01015cb:	a8 03                	test   $0x3,%al
f01015cd:	75 21                	jne    f01015f0 <memset+0x39>
		c &= 0xFF;
f01015cf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015d3:	89 d0                	mov    %edx,%eax
f01015d5:	c1 e0 08             	shl    $0x8,%eax
f01015d8:	89 d3                	mov    %edx,%ebx
f01015da:	c1 e3 18             	shl    $0x18,%ebx
f01015dd:	89 d6                	mov    %edx,%esi
f01015df:	c1 e6 10             	shl    $0x10,%esi
f01015e2:	09 f3                	or     %esi,%ebx
f01015e4:	09 da                	or     %ebx,%edx
f01015e6:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01015e8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01015eb:	fc                   	cld    
f01015ec:	f3 ab                	rep stos %eax,%es:(%edi)
f01015ee:	eb 06                	jmp    f01015f6 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01015f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015f3:	fc                   	cld    
f01015f4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01015f6:	89 f8                	mov    %edi,%eax
f01015f8:	5b                   	pop    %ebx
f01015f9:	5e                   	pop    %esi
f01015fa:	5f                   	pop    %edi
f01015fb:	5d                   	pop    %ebp
f01015fc:	c3                   	ret    

f01015fd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01015fd:	55                   	push   %ebp
f01015fe:	89 e5                	mov    %esp,%ebp
f0101600:	57                   	push   %edi
f0101601:	56                   	push   %esi
f0101602:	8b 45 08             	mov    0x8(%ebp),%eax
f0101605:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101608:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010160b:	39 c6                	cmp    %eax,%esi
f010160d:	73 32                	jae    f0101641 <memmove+0x44>
f010160f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101612:	39 c2                	cmp    %eax,%edx
f0101614:	76 2b                	jbe    f0101641 <memmove+0x44>
		s += n;
		d += n;
f0101616:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101619:	89 d6                	mov    %edx,%esi
f010161b:	09 fe                	or     %edi,%esi
f010161d:	09 ce                	or     %ecx,%esi
f010161f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101625:	75 0e                	jne    f0101635 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101627:	83 ef 04             	sub    $0x4,%edi
f010162a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010162d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101630:	fd                   	std    
f0101631:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101633:	eb 09                	jmp    f010163e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101635:	83 ef 01             	sub    $0x1,%edi
f0101638:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010163b:	fd                   	std    
f010163c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010163e:	fc                   	cld    
f010163f:	eb 1a                	jmp    f010165b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101641:	89 f2                	mov    %esi,%edx
f0101643:	09 c2                	or     %eax,%edx
f0101645:	09 ca                	or     %ecx,%edx
f0101647:	f6 c2 03             	test   $0x3,%dl
f010164a:	75 0a                	jne    f0101656 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010164c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010164f:	89 c7                	mov    %eax,%edi
f0101651:	fc                   	cld    
f0101652:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101654:	eb 05                	jmp    f010165b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0101656:	89 c7                	mov    %eax,%edi
f0101658:	fc                   	cld    
f0101659:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010165b:	5e                   	pop    %esi
f010165c:	5f                   	pop    %edi
f010165d:	5d                   	pop    %ebp
f010165e:	c3                   	ret    

f010165f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010165f:	55                   	push   %ebp
f0101660:	89 e5                	mov    %esp,%ebp
f0101662:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101665:	ff 75 10             	push   0x10(%ebp)
f0101668:	ff 75 0c             	push   0xc(%ebp)
f010166b:	ff 75 08             	push   0x8(%ebp)
f010166e:	e8 8a ff ff ff       	call   f01015fd <memmove>
}
f0101673:	c9                   	leave  
f0101674:	c3                   	ret    

f0101675 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101675:	55                   	push   %ebp
f0101676:	89 e5                	mov    %esp,%ebp
f0101678:	56                   	push   %esi
f0101679:	53                   	push   %ebx
f010167a:	8b 45 08             	mov    0x8(%ebp),%eax
f010167d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101680:	89 c6                	mov    %eax,%esi
f0101682:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101685:	eb 06                	jmp    f010168d <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101687:	83 c0 01             	add    $0x1,%eax
f010168a:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f010168d:	39 f0                	cmp    %esi,%eax
f010168f:	74 14                	je     f01016a5 <memcmp+0x30>
		if (*s1 != *s2)
f0101691:	0f b6 08             	movzbl (%eax),%ecx
f0101694:	0f b6 1a             	movzbl (%edx),%ebx
f0101697:	38 d9                	cmp    %bl,%cl
f0101699:	74 ec                	je     f0101687 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f010169b:	0f b6 c1             	movzbl %cl,%eax
f010169e:	0f b6 db             	movzbl %bl,%ebx
f01016a1:	29 d8                	sub    %ebx,%eax
f01016a3:	eb 05                	jmp    f01016aa <memcmp+0x35>
	}

	return 0;
f01016a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016aa:	5b                   	pop    %ebx
f01016ab:	5e                   	pop    %esi
f01016ac:	5d                   	pop    %ebp
f01016ad:	c3                   	ret    

f01016ae <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016ae:	55                   	push   %ebp
f01016af:	89 e5                	mov    %esp,%ebp
f01016b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01016b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01016b7:	89 c2                	mov    %eax,%edx
f01016b9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01016bc:	eb 03                	jmp    f01016c1 <memfind+0x13>
f01016be:	83 c0 01             	add    $0x1,%eax
f01016c1:	39 d0                	cmp    %edx,%eax
f01016c3:	73 04                	jae    f01016c9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016c5:	38 08                	cmp    %cl,(%eax)
f01016c7:	75 f5                	jne    f01016be <memfind+0x10>
			break;
	return (void *) s;
}
f01016c9:	5d                   	pop    %ebp
f01016ca:	c3                   	ret    

f01016cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016cb:	55                   	push   %ebp
f01016cc:	89 e5                	mov    %esp,%ebp
f01016ce:	57                   	push   %edi
f01016cf:	56                   	push   %esi
f01016d0:	53                   	push   %ebx
f01016d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01016d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01016d7:	eb 03                	jmp    f01016dc <strtol+0x11>
		s++;
f01016d9:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01016dc:	0f b6 02             	movzbl (%edx),%eax
f01016df:	3c 20                	cmp    $0x20,%al
f01016e1:	74 f6                	je     f01016d9 <strtol+0xe>
f01016e3:	3c 09                	cmp    $0x9,%al
f01016e5:	74 f2                	je     f01016d9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01016e7:	3c 2b                	cmp    $0x2b,%al
f01016e9:	74 2a                	je     f0101715 <strtol+0x4a>
	int neg = 0;
f01016eb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01016f0:	3c 2d                	cmp    $0x2d,%al
f01016f2:	74 2b                	je     f010171f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01016f4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01016fa:	75 0f                	jne    f010170b <strtol+0x40>
f01016fc:	80 3a 30             	cmpb   $0x30,(%edx)
f01016ff:	74 28                	je     f0101729 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101701:	85 db                	test   %ebx,%ebx
f0101703:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101708:	0f 44 d8             	cmove  %eax,%ebx
f010170b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101710:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101713:	eb 46                	jmp    f010175b <strtol+0x90>
		s++;
f0101715:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0101718:	bf 00 00 00 00       	mov    $0x0,%edi
f010171d:	eb d5                	jmp    f01016f4 <strtol+0x29>
		s++, neg = 1;
f010171f:	83 c2 01             	add    $0x1,%edx
f0101722:	bf 01 00 00 00       	mov    $0x1,%edi
f0101727:	eb cb                	jmp    f01016f4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101729:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010172d:	74 0e                	je     f010173d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010172f:	85 db                	test   %ebx,%ebx
f0101731:	75 d8                	jne    f010170b <strtol+0x40>
		s++, base = 8;
f0101733:	83 c2 01             	add    $0x1,%edx
f0101736:	bb 08 00 00 00       	mov    $0x8,%ebx
f010173b:	eb ce                	jmp    f010170b <strtol+0x40>
		s += 2, base = 16;
f010173d:	83 c2 02             	add    $0x2,%edx
f0101740:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101745:	eb c4                	jmp    f010170b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101747:	0f be c0             	movsbl %al,%eax
f010174a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010174d:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101750:	7d 3a                	jge    f010178c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101752:	83 c2 01             	add    $0x1,%edx
f0101755:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0101759:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f010175b:	0f b6 02             	movzbl (%edx),%eax
f010175e:	8d 70 d0             	lea    -0x30(%eax),%esi
f0101761:	89 f3                	mov    %esi,%ebx
f0101763:	80 fb 09             	cmp    $0x9,%bl
f0101766:	76 df                	jbe    f0101747 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0101768:	8d 70 9f             	lea    -0x61(%eax),%esi
f010176b:	89 f3                	mov    %esi,%ebx
f010176d:	80 fb 19             	cmp    $0x19,%bl
f0101770:	77 08                	ja     f010177a <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101772:	0f be c0             	movsbl %al,%eax
f0101775:	83 e8 57             	sub    $0x57,%eax
f0101778:	eb d3                	jmp    f010174d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f010177a:	8d 70 bf             	lea    -0x41(%eax),%esi
f010177d:	89 f3                	mov    %esi,%ebx
f010177f:	80 fb 19             	cmp    $0x19,%bl
f0101782:	77 08                	ja     f010178c <strtol+0xc1>
			dig = *s - 'A' + 10;
f0101784:	0f be c0             	movsbl %al,%eax
f0101787:	83 e8 37             	sub    $0x37,%eax
f010178a:	eb c1                	jmp    f010174d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f010178c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101790:	74 05                	je     f0101797 <strtol+0xcc>
		*endptr = (char *) s;
f0101792:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101795:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0101797:	89 c8                	mov    %ecx,%eax
f0101799:	f7 d8                	neg    %eax
f010179b:	85 ff                	test   %edi,%edi
f010179d:	0f 45 c8             	cmovne %eax,%ecx
}
f01017a0:	89 c8                	mov    %ecx,%eax
f01017a2:	5b                   	pop    %ebx
f01017a3:	5e                   	pop    %esi
f01017a4:	5f                   	pop    %edi
f01017a5:	5d                   	pop    %ebp
f01017a6:	c3                   	ret    
f01017a7:	66 90                	xchg   %ax,%ax
f01017a9:	66 90                	xchg   %ax,%ax
f01017ab:	66 90                	xchg   %ax,%ax
f01017ad:	66 90                	xchg   %ax,%ax
f01017af:	90                   	nop

f01017b0 <__udivdi3>:
f01017b0:	f3 0f 1e fb          	endbr32 
f01017b4:	55                   	push   %ebp
f01017b5:	57                   	push   %edi
f01017b6:	56                   	push   %esi
f01017b7:	53                   	push   %ebx
f01017b8:	83 ec 1c             	sub    $0x1c,%esp
f01017bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01017bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01017c3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01017cb:	85 c0                	test   %eax,%eax
f01017cd:	75 19                	jne    f01017e8 <__udivdi3+0x38>
f01017cf:	39 f3                	cmp    %esi,%ebx
f01017d1:	76 4d                	jbe    f0101820 <__udivdi3+0x70>
f01017d3:	31 ff                	xor    %edi,%edi
f01017d5:	89 e8                	mov    %ebp,%eax
f01017d7:	89 f2                	mov    %esi,%edx
f01017d9:	f7 f3                	div    %ebx
f01017db:	89 fa                	mov    %edi,%edx
f01017dd:	83 c4 1c             	add    $0x1c,%esp
f01017e0:	5b                   	pop    %ebx
f01017e1:	5e                   	pop    %esi
f01017e2:	5f                   	pop    %edi
f01017e3:	5d                   	pop    %ebp
f01017e4:	c3                   	ret    
f01017e5:	8d 76 00             	lea    0x0(%esi),%esi
f01017e8:	39 f0                	cmp    %esi,%eax
f01017ea:	76 14                	jbe    f0101800 <__udivdi3+0x50>
f01017ec:	31 ff                	xor    %edi,%edi
f01017ee:	31 c0                	xor    %eax,%eax
f01017f0:	89 fa                	mov    %edi,%edx
f01017f2:	83 c4 1c             	add    $0x1c,%esp
f01017f5:	5b                   	pop    %ebx
f01017f6:	5e                   	pop    %esi
f01017f7:	5f                   	pop    %edi
f01017f8:	5d                   	pop    %ebp
f01017f9:	c3                   	ret    
f01017fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101800:	0f bd f8             	bsr    %eax,%edi
f0101803:	83 f7 1f             	xor    $0x1f,%edi
f0101806:	75 48                	jne    f0101850 <__udivdi3+0xa0>
f0101808:	39 f0                	cmp    %esi,%eax
f010180a:	72 06                	jb     f0101812 <__udivdi3+0x62>
f010180c:	31 c0                	xor    %eax,%eax
f010180e:	39 eb                	cmp    %ebp,%ebx
f0101810:	77 de                	ja     f01017f0 <__udivdi3+0x40>
f0101812:	b8 01 00 00 00       	mov    $0x1,%eax
f0101817:	eb d7                	jmp    f01017f0 <__udivdi3+0x40>
f0101819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101820:	89 d9                	mov    %ebx,%ecx
f0101822:	85 db                	test   %ebx,%ebx
f0101824:	75 0b                	jne    f0101831 <__udivdi3+0x81>
f0101826:	b8 01 00 00 00       	mov    $0x1,%eax
f010182b:	31 d2                	xor    %edx,%edx
f010182d:	f7 f3                	div    %ebx
f010182f:	89 c1                	mov    %eax,%ecx
f0101831:	31 d2                	xor    %edx,%edx
f0101833:	89 f0                	mov    %esi,%eax
f0101835:	f7 f1                	div    %ecx
f0101837:	89 c6                	mov    %eax,%esi
f0101839:	89 e8                	mov    %ebp,%eax
f010183b:	89 f7                	mov    %esi,%edi
f010183d:	f7 f1                	div    %ecx
f010183f:	89 fa                	mov    %edi,%edx
f0101841:	83 c4 1c             	add    $0x1c,%esp
f0101844:	5b                   	pop    %ebx
f0101845:	5e                   	pop    %esi
f0101846:	5f                   	pop    %edi
f0101847:	5d                   	pop    %ebp
f0101848:	c3                   	ret    
f0101849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101850:	89 f9                	mov    %edi,%ecx
f0101852:	ba 20 00 00 00       	mov    $0x20,%edx
f0101857:	29 fa                	sub    %edi,%edx
f0101859:	d3 e0                	shl    %cl,%eax
f010185b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010185f:	89 d1                	mov    %edx,%ecx
f0101861:	89 d8                	mov    %ebx,%eax
f0101863:	d3 e8                	shr    %cl,%eax
f0101865:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101869:	09 c1                	or     %eax,%ecx
f010186b:	89 f0                	mov    %esi,%eax
f010186d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101871:	89 f9                	mov    %edi,%ecx
f0101873:	d3 e3                	shl    %cl,%ebx
f0101875:	89 d1                	mov    %edx,%ecx
f0101877:	d3 e8                	shr    %cl,%eax
f0101879:	89 f9                	mov    %edi,%ecx
f010187b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010187f:	89 eb                	mov    %ebp,%ebx
f0101881:	d3 e6                	shl    %cl,%esi
f0101883:	89 d1                	mov    %edx,%ecx
f0101885:	d3 eb                	shr    %cl,%ebx
f0101887:	09 f3                	or     %esi,%ebx
f0101889:	89 c6                	mov    %eax,%esi
f010188b:	89 f2                	mov    %esi,%edx
f010188d:	89 d8                	mov    %ebx,%eax
f010188f:	f7 74 24 08          	divl   0x8(%esp)
f0101893:	89 d6                	mov    %edx,%esi
f0101895:	89 c3                	mov    %eax,%ebx
f0101897:	f7 64 24 0c          	mull   0xc(%esp)
f010189b:	39 d6                	cmp    %edx,%esi
f010189d:	72 19                	jb     f01018b8 <__udivdi3+0x108>
f010189f:	89 f9                	mov    %edi,%ecx
f01018a1:	d3 e5                	shl    %cl,%ebp
f01018a3:	39 c5                	cmp    %eax,%ebp
f01018a5:	73 04                	jae    f01018ab <__udivdi3+0xfb>
f01018a7:	39 d6                	cmp    %edx,%esi
f01018a9:	74 0d                	je     f01018b8 <__udivdi3+0x108>
f01018ab:	89 d8                	mov    %ebx,%eax
f01018ad:	31 ff                	xor    %edi,%edi
f01018af:	e9 3c ff ff ff       	jmp    f01017f0 <__udivdi3+0x40>
f01018b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01018bb:	31 ff                	xor    %edi,%edi
f01018bd:	e9 2e ff ff ff       	jmp    f01017f0 <__udivdi3+0x40>
f01018c2:	66 90                	xchg   %ax,%ax
f01018c4:	66 90                	xchg   %ax,%ax
f01018c6:	66 90                	xchg   %ax,%ax
f01018c8:	66 90                	xchg   %ax,%ax
f01018ca:	66 90                	xchg   %ax,%ax
f01018cc:	66 90                	xchg   %ax,%ax
f01018ce:	66 90                	xchg   %ax,%ax

f01018d0 <__umoddi3>:
f01018d0:	f3 0f 1e fb          	endbr32 
f01018d4:	55                   	push   %ebp
f01018d5:	57                   	push   %edi
f01018d6:	56                   	push   %esi
f01018d7:	53                   	push   %ebx
f01018d8:	83 ec 1c             	sub    $0x1c,%esp
f01018db:	8b 74 24 30          	mov    0x30(%esp),%esi
f01018df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01018e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f01018e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f01018eb:	89 f0                	mov    %esi,%eax
f01018ed:	89 da                	mov    %ebx,%edx
f01018ef:	85 ff                	test   %edi,%edi
f01018f1:	75 15                	jne    f0101908 <__umoddi3+0x38>
f01018f3:	39 dd                	cmp    %ebx,%ebp
f01018f5:	76 39                	jbe    f0101930 <__umoddi3+0x60>
f01018f7:	f7 f5                	div    %ebp
f01018f9:	89 d0                	mov    %edx,%eax
f01018fb:	31 d2                	xor    %edx,%edx
f01018fd:	83 c4 1c             	add    $0x1c,%esp
f0101900:	5b                   	pop    %ebx
f0101901:	5e                   	pop    %esi
f0101902:	5f                   	pop    %edi
f0101903:	5d                   	pop    %ebp
f0101904:	c3                   	ret    
f0101905:	8d 76 00             	lea    0x0(%esi),%esi
f0101908:	39 df                	cmp    %ebx,%edi
f010190a:	77 f1                	ja     f01018fd <__umoddi3+0x2d>
f010190c:	0f bd cf             	bsr    %edi,%ecx
f010190f:	83 f1 1f             	xor    $0x1f,%ecx
f0101912:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101916:	75 40                	jne    f0101958 <__umoddi3+0x88>
f0101918:	39 df                	cmp    %ebx,%edi
f010191a:	72 04                	jb     f0101920 <__umoddi3+0x50>
f010191c:	39 f5                	cmp    %esi,%ebp
f010191e:	77 dd                	ja     f01018fd <__umoddi3+0x2d>
f0101920:	89 da                	mov    %ebx,%edx
f0101922:	89 f0                	mov    %esi,%eax
f0101924:	29 e8                	sub    %ebp,%eax
f0101926:	19 fa                	sbb    %edi,%edx
f0101928:	eb d3                	jmp    f01018fd <__umoddi3+0x2d>
f010192a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101930:	89 e9                	mov    %ebp,%ecx
f0101932:	85 ed                	test   %ebp,%ebp
f0101934:	75 0b                	jne    f0101941 <__umoddi3+0x71>
f0101936:	b8 01 00 00 00       	mov    $0x1,%eax
f010193b:	31 d2                	xor    %edx,%edx
f010193d:	f7 f5                	div    %ebp
f010193f:	89 c1                	mov    %eax,%ecx
f0101941:	89 d8                	mov    %ebx,%eax
f0101943:	31 d2                	xor    %edx,%edx
f0101945:	f7 f1                	div    %ecx
f0101947:	89 f0                	mov    %esi,%eax
f0101949:	f7 f1                	div    %ecx
f010194b:	89 d0                	mov    %edx,%eax
f010194d:	31 d2                	xor    %edx,%edx
f010194f:	eb ac                	jmp    f01018fd <__umoddi3+0x2d>
f0101951:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101958:	8b 44 24 04          	mov    0x4(%esp),%eax
f010195c:	ba 20 00 00 00       	mov    $0x20,%edx
f0101961:	29 c2                	sub    %eax,%edx
f0101963:	89 c1                	mov    %eax,%ecx
f0101965:	89 e8                	mov    %ebp,%eax
f0101967:	d3 e7                	shl    %cl,%edi
f0101969:	89 d1                	mov    %edx,%ecx
f010196b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010196f:	d3 e8                	shr    %cl,%eax
f0101971:	89 c1                	mov    %eax,%ecx
f0101973:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101977:	09 f9                	or     %edi,%ecx
f0101979:	89 df                	mov    %ebx,%edi
f010197b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010197f:	89 c1                	mov    %eax,%ecx
f0101981:	d3 e5                	shl    %cl,%ebp
f0101983:	89 d1                	mov    %edx,%ecx
f0101985:	d3 ef                	shr    %cl,%edi
f0101987:	89 c1                	mov    %eax,%ecx
f0101989:	89 f0                	mov    %esi,%eax
f010198b:	d3 e3                	shl    %cl,%ebx
f010198d:	89 d1                	mov    %edx,%ecx
f010198f:	89 fa                	mov    %edi,%edx
f0101991:	d3 e8                	shr    %cl,%eax
f0101993:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101998:	09 d8                	or     %ebx,%eax
f010199a:	f7 74 24 08          	divl   0x8(%esp)
f010199e:	89 d3                	mov    %edx,%ebx
f01019a0:	d3 e6                	shl    %cl,%esi
f01019a2:	f7 e5                	mul    %ebp
f01019a4:	89 c7                	mov    %eax,%edi
f01019a6:	89 d1                	mov    %edx,%ecx
f01019a8:	39 d3                	cmp    %edx,%ebx
f01019aa:	72 06                	jb     f01019b2 <__umoddi3+0xe2>
f01019ac:	75 0e                	jne    f01019bc <__umoddi3+0xec>
f01019ae:	39 c6                	cmp    %eax,%esi
f01019b0:	73 0a                	jae    f01019bc <__umoddi3+0xec>
f01019b2:	29 e8                	sub    %ebp,%eax
f01019b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01019b8:	89 d1                	mov    %edx,%ecx
f01019ba:	89 c7                	mov    %eax,%edi
f01019bc:	89 f5                	mov    %esi,%ebp
f01019be:	8b 74 24 04          	mov    0x4(%esp),%esi
f01019c2:	29 fd                	sub    %edi,%ebp
f01019c4:	19 cb                	sbb    %ecx,%ebx
f01019c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01019cb:	89 d8                	mov    %ebx,%eax
f01019cd:	d3 e0                	shl    %cl,%eax
f01019cf:	89 f1                	mov    %esi,%ecx
f01019d1:	d3 ed                	shr    %cl,%ebp
f01019d3:	d3 eb                	shr    %cl,%ebx
f01019d5:	09 e8                	or     %ebp,%eax
f01019d7:	89 da                	mov    %ebx,%edx
f01019d9:	83 c4 1c             	add    $0x1c,%esp
f01019dc:	5b                   	pop    %ebx
f01019dd:	5e                   	pop    %esi
f01019de:	5f                   	pop    %edi
f01019df:	5d                   	pop    %ebp
f01019e0:	c3                   	ret    
