
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 8f 38 10 80       	mov    $0x8010388f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 c0 85 10 80       	push   $0x801085c0
80100042:	68 60 c6 10 80       	push   $0x8010c660
80100047:	e8 2b 50 00 00       	call   80105077 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 05 11 80       	mov    0x80110574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 05 11 80       	mov    $0x80110564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 c6 10 80       	push   $0x8010c660
801000c1:	e8 d3 4f 00 00       	call   80105099 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 05 11 80       	mov    0x80110574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 c6 10 80       	push   $0x8010c660
8010010c:	e8 ef 4f 00 00       	call   80105100 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 c6 10 80       	push   $0x8010c660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 6b 4c 00 00       	call   80104d97 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 05 11 80       	mov    0x80110570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 c6 10 80       	push   $0x8010c660
80100188:	e8 73 4f 00 00       	call   80105100 <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 c7 85 10 80       	push   $0x801085c7
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 26 27 00 00       	call   8010290d <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 d8 85 10 80       	push   $0x801085d8
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 e5 26 00 00       	call   8010290d <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 df 85 10 80       	push   $0x801085df
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 c6 10 80       	push   $0x8010c660
80100255:	e8 3f 4e 00 00       	call   80105099 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 05 11 80       	mov    0x80110574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 c7 4b 00 00       	call   80104e85 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 c6 10 80       	push   $0x8010c660
801002c9:	e8 32 4e 00 00       	call   80105100 <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e2:	e8 b2 4c 00 00       	call   80105099 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 e6 85 10 80       	push   $0x801085e6
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec ef 85 10 80 	movl   $0x801085ef,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055b:	e8 a0 4b 00 00       	call   80105100 <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 f6 85 10 80       	push   $0x801085f6
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 05 86 10 80       	push   $0x80108605
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 8b 4b 00 00       	call   80105152 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 07 86 10 80       	push   $0x80108607
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 0b 86 10 80       	push   $0x8010860b
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 90 10 80       	mov    0x80109000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 bf 4c 00 00       	call   801053bb <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 d6 4b 00 00       	call   801052fc <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 90 10 80       	mov    0x80109000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 8b 64 00 00       	call   80106c46 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 7e 64 00 00       	call   80106c46 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 71 64 00 00       	call   80106c46 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 61 64 00 00       	call   80106c46 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 c0 b5 10 80       	push   $0x8010b5c0
8010080e:	e8 86 48 00 00       	call   80105099 <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 08 08 11 80       	mov    0x80110808,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 08 08 11 80    	mov    0x80110808,%edx
80100870:	a1 04 08 11 80       	mov    0x80110804,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 08 08 11 80       	mov    0x80110808,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 08 08 11 80    	mov    0x80110808,%edx
8010089e:	a1 04 08 11 80       	mov    0x80110804,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 08 08 11 80       	mov    0x80110808,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 08 08 11 80    	mov    0x80110808,%edx
801008dd:	a1 00 08 11 80       	mov    0x80110800,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 08 08 11 80       	mov    0x80110808,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 08 08 11 80    	mov    %edx,0x80110808
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 80 07 11 80    	mov    %dl,-0x7feef880(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 08 08 11 80       	mov    0x80110808,%eax
80100937:	8b 15 00 08 11 80    	mov    0x80110800,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 08 08 11 80       	mov    0x80110808,%eax
80100949:	a3 04 08 11 80       	mov    %eax,0x80110804
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 00 08 11 80       	push   $0x80110800
80100956:	e8 2a 45 00 00       	call   80104e85 <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 c0 b5 10 80       	push   $0x8010b5c0
80100979:	e8 82 47 00 00       	call   80105100 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 b7 45 00 00       	call   80104f43 <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 28 11 00 00       	call   80101ac8 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 c0 b5 10 80       	push   $0x8010b5c0
801009b1:	e8 e3 46 00 00       	call   80105099 <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 c0 b5 10 80       	push   $0x8010b5c0
801009d3:	e8 28 47 00 00       	call   80105100 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 84 0f 00 00       	call   8010196a <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 c0 b5 10 80       	push   $0x8010b5c0
801009fb:	68 00 08 11 80       	push   $0x80110800
80100a00:	e8 92 43 00 00       	call   80104d97 <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 00 08 11 80    	mov    0x80110800,%edx
80100a0e:	a1 04 08 11 80       	mov    0x80110804,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 00 08 11 80       	mov    0x80110800,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 00 08 11 80    	mov    %edx,0x80110800
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 00 08 11 80       	mov    0x80110800,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 00 08 11 80       	mov    %eax,0x80110800
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a7e:	e8 7d 46 00 00       	call   80105100 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 d9 0e 00 00       	call   8010196a <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 17 10 00 00       	call   80101ac8 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 c0 b5 10 80       	push   $0x8010b5c0
80100abc:	e8 d8 45 00 00       	call   80105099 <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 c0 b5 10 80       	push   $0x8010b5c0
80100afe:	e8 fd 45 00 00       	call   80105100 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 59 0e 00 00       	call   8010196a <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 1e 86 10 80       	push   $0x8010861e
80100b27:	68 c0 b5 10 80       	push   $0x8010b5c0
80100b2c:	e8 46 45 00 00       	call   80105077 <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 cc 11 11 80 a0 	movl   $0x80100aa0,0x801111cc
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 c8 11 11 80 8f 	movl   $0x8010098f,0x801111c8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 cf 33 00 00       	call   80103f2b <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 6f 1f 00 00       	call   80102ada <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 ce 29 00 00       	call   8010354d <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 9e 19 00 00       	call   80102528 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 3e 2a 00 00       	call   801035d9 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 ce 03 00 00       	jmp    80100f73 <exec+0x402>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 ba 0d 00 00       	call   8010196a <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 0b 13 00 00       	call   80101ed8 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 49 03 00 00    	jbe    80100f22 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 3b 03 00 00    	jne    80100f25 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 ac 71 00 00       	call   80107d9b <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 2c 03 00 00    	je     80100f28 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 ab 12 00 00       	call   80101ed8 <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 f2 02 00 00    	jne    80100f2b <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 d6 02 00 00    	jb     80100f2e <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 cd 74 00 00       	call   80108142 <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 ac 02 00 00    	je     80100f31 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 c3 73 00 00       	call   8010806b <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 81 02 00 00    	js     80100f34 <exec+0x3c3>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100cb5:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 49 0f 00 00       	call   80101c2a <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 f0 28 00 00       	call   801035d9 <end_op>
  ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 2b 74 00 00       	call   80108142 <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 10 02 00 00    	je     80100f37 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 2d 76 00 00       	call   80108368 <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
    if(argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 e0 01 00 00    	ja     80100f3a <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 d5 47 00 00       	call   80105549 <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 a8 47 00 00       	call   80105549 <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 58 77 00 00       	call   8010851f <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 6b 01 00 00    	js     80100f3d <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
  ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 bc 76 00 00       	call   8010851f <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 d2 00 00 00    	js     80100f40 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
    if(*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
      last = s+1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 6c             	add    $0x6c,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 4b 46 00 00       	call   801054ff <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 04             	mov    0x4(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 40 18             	mov    0x18(%eax),%eax
80100ee3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ee9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	50                   	push   %eax
80100f05:	e8 78 6f 00 00       	call   80107e82 <switchuvm>
80100f0a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	ff 75 d0             	pushl  -0x30(%ebp)
80100f13:	e8 b0 73 00 00       	call   801082c8 <freevm>
80100f18:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80100f20:	eb 51                	jmp    80100f73 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f22:	90                   	nop
80100f23:	eb 1c                	jmp    80100f41 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f25:	90                   	nop
80100f26:	eb 19                	jmp    80100f41 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f28:	90                   	nop
80100f29:	eb 16                	jmp    80100f41 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f2b:	90                   	nop
80100f2c:	eb 13                	jmp    80100f41 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f2e:	90                   	nop
80100f2f:	eb 10                	jmp    80100f41 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f31:	90                   	nop
80100f32:	eb 0d                	jmp    80100f41 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f34:	90                   	nop
80100f35:	eb 0a                	jmp    80100f41 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f37:	90                   	nop
80100f38:	eb 07                	jmp    80100f41 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f3a:	90                   	nop
80100f3b:	eb 04                	jmp    80100f41 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f3d:	90                   	nop
80100f3e:	eb 01                	jmp    80100f41 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f40:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f41:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f45:	74 0e                	je     80100f55 <exec+0x3e4>
    freevm(pgdir);
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4d:	e8 76 73 00 00       	call   801082c8 <freevm>
80100f52:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f55:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f59:	74 13                	je     80100f6e <exec+0x3fd>
    iunlockput(ip);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 d8             	pushl  -0x28(%ebp)
80100f61:	e8 c4 0c 00 00       	call   80101c2a <iunlockput>
80100f66:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f69:	e8 6b 26 00 00       	call   801035d9 <end_op>
  }
  return -1;
80100f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f73:	c9                   	leave  
80100f74:	c3                   	ret    

80100f75 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f75:	55                   	push   %ebp
80100f76:	89 e5                	mov    %esp,%ebp
80100f78:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f7b:	83 ec 08             	sub    $0x8,%esp
80100f7e:	68 26 86 10 80       	push   $0x80108626
80100f83:	68 20 08 11 80       	push   $0x80110820
80100f88:	e8 ea 40 00 00       	call   80105077 <initlock>
80100f8d:	83 c4 10             	add    $0x10,%esp
}
80100f90:	90                   	nop
80100f91:	c9                   	leave  
80100f92:	c3                   	ret    

80100f93 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f93:	55                   	push   %ebp
80100f94:	89 e5                	mov    %esp,%ebp
80100f96:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f99:	83 ec 0c             	sub    $0xc,%esp
80100f9c:	68 20 08 11 80       	push   $0x80110820
80100fa1:	e8 f3 40 00 00       	call   80105099 <acquire>
80100fa6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa9:	c7 45 f4 54 08 11 80 	movl   $0x80110854,-0xc(%ebp)
80100fb0:	eb 2d                	jmp    80100fdf <filealloc+0x4c>
    if(f->ref == 0){
80100fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb5:	8b 40 04             	mov    0x4(%eax),%eax
80100fb8:	85 c0                	test   %eax,%eax
80100fba:	75 1f                	jne    80100fdb <filealloc+0x48>
      f->ref = 1;
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fc6:	83 ec 0c             	sub    $0xc,%esp
80100fc9:	68 20 08 11 80       	push   $0x80110820
80100fce:	e8 2d 41 00 00       	call   80105100 <release>
80100fd3:	83 c4 10             	add    $0x10,%esp
      return f;
80100fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd9:	eb 23                	jmp    80100ffe <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdb:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fdf:	b8 b4 11 11 80       	mov    $0x801111b4,%eax
80100fe4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fe7:	72 c9                	jb     80100fb2 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fe9:	83 ec 0c             	sub    $0xc,%esp
80100fec:	68 20 08 11 80       	push   $0x80110820
80100ff1:	e8 0a 41 00 00       	call   80105100 <release>
80100ff6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ff9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ffe:	c9                   	leave  
80100fff:	c3                   	ret    

80101000 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101000:	55                   	push   %ebp
80101001:	89 e5                	mov    %esp,%ebp
80101003:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101006:	83 ec 0c             	sub    $0xc,%esp
80101009:	68 20 08 11 80       	push   $0x80110820
8010100e:	e8 86 40 00 00       	call   80105099 <acquire>
80101013:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 40 04             	mov    0x4(%eax),%eax
8010101c:	85 c0                	test   %eax,%eax
8010101e:	7f 0d                	jg     8010102d <filedup+0x2d>
    panic("filedup");
80101020:	83 ec 0c             	sub    $0xc,%esp
80101023:	68 2d 86 10 80       	push   $0x8010862d
80101028:	e8 39 f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010102d:	8b 45 08             	mov    0x8(%ebp),%eax
80101030:	8b 40 04             	mov    0x4(%eax),%eax
80101033:	8d 50 01             	lea    0x1(%eax),%edx
80101036:	8b 45 08             	mov    0x8(%ebp),%eax
80101039:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 20 08 11 80       	push   $0x80110820
80101044:	e8 b7 40 00 00       	call   80105100 <release>
80101049:	83 c4 10             	add    $0x10,%esp
  return f;
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010104f:	c9                   	leave  
80101050:	c3                   	ret    

80101051 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101051:	55                   	push   %ebp
80101052:	89 e5                	mov    %esp,%ebp
80101054:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101057:	83 ec 0c             	sub    $0xc,%esp
8010105a:	68 20 08 11 80       	push   $0x80110820
8010105f:	e8 35 40 00 00       	call   80105099 <acquire>
80101064:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	8b 40 04             	mov    0x4(%eax),%eax
8010106d:	85 c0                	test   %eax,%eax
8010106f:	7f 0d                	jg     8010107e <fileclose+0x2d>
    panic("fileclose");
80101071:	83 ec 0c             	sub    $0xc,%esp
80101074:	68 35 86 10 80       	push   $0x80108635
80101079:	e8 e8 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
80101081:	8b 40 04             	mov    0x4(%eax),%eax
80101084:	8d 50 ff             	lea    -0x1(%eax),%edx
80101087:	8b 45 08             	mov    0x8(%ebp),%eax
8010108a:	89 50 04             	mov    %edx,0x4(%eax)
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8b 40 04             	mov    0x4(%eax),%eax
80101093:	85 c0                	test   %eax,%eax
80101095:	7e 15                	jle    801010ac <fileclose+0x5b>
    release(&ftable.lock);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	68 20 08 11 80       	push   $0x80110820
8010109f:	e8 5c 40 00 00       	call   80105100 <release>
801010a4:	83 c4 10             	add    $0x10,%esp
801010a7:	e9 8b 00 00 00       	jmp    80101137 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 10                	mov    (%eax),%edx
801010b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010b4:	8b 50 04             	mov    0x4(%eax),%edx
801010b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ba:	8b 50 08             	mov    0x8(%eax),%edx
801010bd:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010c0:	8b 50 0c             	mov    0xc(%eax),%edx
801010c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010c6:	8b 50 10             	mov    0x10(%eax),%edx
801010c9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010cc:	8b 40 14             	mov    0x14(%eax),%eax
801010cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010dc:	8b 45 08             	mov    0x8(%ebp),%eax
801010df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010e5:	83 ec 0c             	sub    $0xc,%esp
801010e8:	68 20 08 11 80       	push   $0x80110820
801010ed:	e8 0e 40 00 00       	call   80105100 <release>
801010f2:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010f8:	83 f8 01             	cmp    $0x1,%eax
801010fb:	75 19                	jne    80101116 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010fd:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101101:	0f be d0             	movsbl %al,%edx
80101104:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101107:	83 ec 08             	sub    $0x8,%esp
8010110a:	52                   	push   %edx
8010110b:	50                   	push   %eax
8010110c:	e8 83 30 00 00       	call   80104194 <pipeclose>
80101111:	83 c4 10             	add    $0x10,%esp
80101114:	eb 21                	jmp    80101137 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101116:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101119:	83 f8 02             	cmp    $0x2,%eax
8010111c:	75 19                	jne    80101137 <fileclose+0xe6>
    begin_op();
8010111e:	e8 2a 24 00 00       	call   8010354d <begin_op>
    iput(ff.ip);
80101123:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101126:	83 ec 0c             	sub    $0xc,%esp
80101129:	50                   	push   %eax
8010112a:	e8 0b 0a 00 00       	call   80101b3a <iput>
8010112f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101132:	e8 a2 24 00 00       	call   801035d9 <end_op>
  }
}
80101137:	c9                   	leave  
80101138:	c3                   	ret    

80101139 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101139:	55                   	push   %ebp
8010113a:	89 e5                	mov    %esp,%ebp
8010113c:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
80101142:	8b 00                	mov    (%eax),%eax
80101144:	83 f8 02             	cmp    $0x2,%eax
80101147:	75 40                	jne    80101189 <filestat+0x50>
    ilock(f->ip);
80101149:	8b 45 08             	mov    0x8(%ebp),%eax
8010114c:	8b 40 10             	mov    0x10(%eax),%eax
8010114f:	83 ec 0c             	sub    $0xc,%esp
80101152:	50                   	push   %eax
80101153:	e8 12 08 00 00       	call   8010196a <ilock>
80101158:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	83 ec 08             	sub    $0x8,%esp
80101164:	ff 75 0c             	pushl  0xc(%ebp)
80101167:	50                   	push   %eax
80101168:	e8 25 0d 00 00       	call   80101e92 <stati>
8010116d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 40 10             	mov    0x10(%eax),%eax
80101176:	83 ec 0c             	sub    $0xc,%esp
80101179:	50                   	push   %eax
8010117a:	e8 49 09 00 00       	call   80101ac8 <iunlock>
8010117f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101182:	b8 00 00 00 00       	mov    $0x0,%eax
80101187:	eb 05                	jmp    8010118e <filestat+0x55>
  }
  return -1;
80101189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010118e:	c9                   	leave  
8010118f:	c3                   	ret    

80101190 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101190:	55                   	push   %ebp
80101191:	89 e5                	mov    %esp,%ebp
80101193:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010119d:	84 c0                	test   %al,%al
8010119f:	75 0a                	jne    801011ab <fileread+0x1b>
    return -1;
801011a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011a6:	e9 9b 00 00 00       	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ab:	8b 45 08             	mov    0x8(%ebp),%eax
801011ae:	8b 00                	mov    (%eax),%eax
801011b0:	83 f8 01             	cmp    $0x1,%eax
801011b3:	75 1a                	jne    801011cf <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 40 0c             	mov    0xc(%eax),%eax
801011bb:	83 ec 04             	sub    $0x4,%esp
801011be:	ff 75 10             	pushl  0x10(%ebp)
801011c1:	ff 75 0c             	pushl  0xc(%ebp)
801011c4:	50                   	push   %eax
801011c5:	e8 72 31 00 00       	call   8010433c <piperead>
801011ca:	83 c4 10             	add    $0x10,%esp
801011cd:	eb 77                	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_INODE){
801011cf:	8b 45 08             	mov    0x8(%ebp),%eax
801011d2:	8b 00                	mov    (%eax),%eax
801011d4:	83 f8 02             	cmp    $0x2,%eax
801011d7:	75 60                	jne    80101239 <fileread+0xa9>
    ilock(f->ip);
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	83 ec 0c             	sub    $0xc,%esp
801011e2:	50                   	push   %eax
801011e3:	e8 82 07 00 00       	call   8010196a <ilock>
801011e8:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	8b 50 14             	mov    0x14(%eax),%edx
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	8b 40 10             	mov    0x10(%eax),%eax
801011fa:	51                   	push   %ecx
801011fb:	52                   	push   %edx
801011fc:	ff 75 0c             	pushl  0xc(%ebp)
801011ff:	50                   	push   %eax
80101200:	e8 d3 0c 00 00       	call   80101ed8 <readi>
80101205:	83 c4 10             	add    $0x10,%esp
80101208:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010120b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010120f:	7e 11                	jle    80101222 <fileread+0x92>
      f->off += r;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 50 14             	mov    0x14(%eax),%edx
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	01 c2                	add    %eax,%edx
8010121c:	8b 45 08             	mov    0x8(%ebp),%eax
8010121f:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101222:	8b 45 08             	mov    0x8(%ebp),%eax
80101225:	8b 40 10             	mov    0x10(%eax),%eax
80101228:	83 ec 0c             	sub    $0xc,%esp
8010122b:	50                   	push   %eax
8010122c:	e8 97 08 00 00       	call   80101ac8 <iunlock>
80101231:	83 c4 10             	add    $0x10,%esp
    return r;
80101234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101237:	eb 0d                	jmp    80101246 <fileread+0xb6>
  }
  panic("fileread");
80101239:	83 ec 0c             	sub    $0xc,%esp
8010123c:	68 3f 86 10 80       	push   $0x8010863f
80101241:	e8 20 f3 ff ff       	call   80100566 <panic>
}
80101246:	c9                   	leave  
80101247:	c3                   	ret    

80101248 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101248:	55                   	push   %ebp
80101249:	89 e5                	mov    %esp,%ebp
8010124b:	53                   	push   %ebx
8010124c:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101256:	84 c0                	test   %al,%al
80101258:	75 0a                	jne    80101264 <filewrite+0x1c>
    return -1;
8010125a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010125f:	e9 1b 01 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_PIPE)
80101264:	8b 45 08             	mov    0x8(%ebp),%eax
80101267:	8b 00                	mov    (%eax),%eax
80101269:	83 f8 01             	cmp    $0x1,%eax
8010126c:	75 1d                	jne    8010128b <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 0c             	mov    0xc(%eax),%eax
80101274:	83 ec 04             	sub    $0x4,%esp
80101277:	ff 75 10             	pushl  0x10(%ebp)
8010127a:	ff 75 0c             	pushl  0xc(%ebp)
8010127d:	50                   	push   %eax
8010127e:	e8 bb 2f 00 00       	call   8010423e <pipewrite>
80101283:	83 c4 10             	add    $0x10,%esp
80101286:	e9 f4 00 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_INODE){
8010128b:	8b 45 08             	mov    0x8(%ebp),%eax
8010128e:	8b 00                	mov    (%eax),%eax
80101290:	83 f8 02             	cmp    $0x2,%eax
80101293:	0f 85 d9 00 00 00    	jne    80101372 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101299:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012a7:	e9 a3 00 00 00       	jmp    8010134f <filewrite+0x107>
      int n1 = n - i;
801012ac:	8b 45 10             	mov    0x10(%ebp),%eax
801012af:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012b8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012bb:	7e 06                	jle    801012c3 <filewrite+0x7b>
        n1 = max;
801012bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012c3:	e8 85 22 00 00       	call   8010354d <begin_op>
      ilock(f->ip);
801012c8:	8b 45 08             	mov    0x8(%ebp),%eax
801012cb:	8b 40 10             	mov    0x10(%eax),%eax
801012ce:	83 ec 0c             	sub    $0xc,%esp
801012d1:	50                   	push   %eax
801012d2:	e8 93 06 00 00       	call   8010196a <ilock>
801012d7:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012da:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 50 14             	mov    0x14(%eax),%edx
801012e3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801012e9:	01 c3                	add    %eax,%ebx
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 40 10             	mov    0x10(%eax),%eax
801012f1:	51                   	push   %ecx
801012f2:	52                   	push   %edx
801012f3:	53                   	push   %ebx
801012f4:	50                   	push   %eax
801012f5:	e8 35 0d 00 00       	call   8010202f <writei>
801012fa:	83 c4 10             	add    $0x10,%esp
801012fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101300:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101304:	7e 11                	jle    80101317 <filewrite+0xcf>
        f->off += r;
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	8b 50 14             	mov    0x14(%eax),%edx
8010130c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010130f:	01 c2                	add    %eax,%edx
80101311:	8b 45 08             	mov    0x8(%ebp),%eax
80101314:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101317:	8b 45 08             	mov    0x8(%ebp),%eax
8010131a:	8b 40 10             	mov    0x10(%eax),%eax
8010131d:	83 ec 0c             	sub    $0xc,%esp
80101320:	50                   	push   %eax
80101321:	e8 a2 07 00 00       	call   80101ac8 <iunlock>
80101326:	83 c4 10             	add    $0x10,%esp
      end_op();
80101329:	e8 ab 22 00 00       	call   801035d9 <end_op>

      if(r < 0)
8010132e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101332:	78 29                	js     8010135d <filewrite+0x115>
        break;
      if(r != n1)
80101334:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101337:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133a:	74 0d                	je     80101349 <filewrite+0x101>
        panic("short filewrite");
8010133c:	83 ec 0c             	sub    $0xc,%esp
8010133f:	68 48 86 10 80       	push   $0x80108648
80101344:	e8 1d f2 ff ff       	call   80100566 <panic>
      i += r;
80101349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134c:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101352:	3b 45 10             	cmp    0x10(%ebp),%eax
80101355:	0f 8c 51 ff ff ff    	jl     801012ac <filewrite+0x64>
8010135b:	eb 01                	jmp    8010135e <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010135d:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010135e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101361:	3b 45 10             	cmp    0x10(%ebp),%eax
80101364:	75 05                	jne    8010136b <filewrite+0x123>
80101366:	8b 45 10             	mov    0x10(%ebp),%eax
80101369:	eb 14                	jmp    8010137f <filewrite+0x137>
8010136b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101370:	eb 0d                	jmp    8010137f <filewrite+0x137>
  }
  panic("filewrite");
80101372:	83 ec 0c             	sub    $0xc,%esp
80101375:	68 58 86 10 80       	push   $0x80108658
8010137a:	e8 e7 f1 ff ff       	call   80100566 <panic>
}
8010137f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101382:	c9                   	leave  
80101383:	c3                   	ret    

80101384 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101384:	55                   	push   %ebp
80101385:	89 e5                	mov    %esp,%ebp
80101387:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010138a:	8b 45 08             	mov    0x8(%ebp),%eax
8010138d:	83 ec 08             	sub    $0x8,%esp
80101390:	6a 01                	push   $0x1
80101392:	50                   	push   %eax
80101393:	e8 1e ee ff ff       	call   801001b6 <bread>
80101398:	83 c4 10             	add    $0x10,%esp
8010139b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a1:	83 c0 18             	add    $0x18,%eax
801013a4:	83 ec 04             	sub    $0x4,%esp
801013a7:	6a 1c                	push   $0x1c
801013a9:	50                   	push   %eax
801013aa:	ff 75 0c             	pushl  0xc(%ebp)
801013ad:	e8 09 40 00 00       	call   801053bb <memmove>
801013b2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013b5:	83 ec 0c             	sub    $0xc,%esp
801013b8:	ff 75 f4             	pushl  -0xc(%ebp)
801013bb:	e8 6e ee ff ff       	call   8010022e <brelse>
801013c0:	83 c4 10             	add    $0x10,%esp
}
801013c3:	90                   	nop
801013c4:	c9                   	leave  
801013c5:	c3                   	ret    

801013c6 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013c6:	55                   	push   %ebp
801013c7:	89 e5                	mov    %esp,%ebp
801013c9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	83 ec 08             	sub    $0x8,%esp
801013d5:	52                   	push   %edx
801013d6:	50                   	push   %eax
801013d7:	e8 da ed ff ff       	call   801001b6 <bread>
801013dc:	83 c4 10             	add    $0x10,%esp
801013df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	83 c0 18             	add    $0x18,%eax
801013e8:	83 ec 04             	sub    $0x4,%esp
801013eb:	68 00 02 00 00       	push   $0x200
801013f0:	6a 00                	push   $0x0
801013f2:	50                   	push   %eax
801013f3:	e8 04 3f 00 00       	call   801052fc <memset>
801013f8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013fb:	83 ec 0c             	sub    $0xc,%esp
801013fe:	ff 75 f4             	pushl  -0xc(%ebp)
80101401:	e8 7f 23 00 00       	call   80103785 <log_write>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	pushl  -0xc(%ebp)
8010140f:	e8 1a ee ff ff       	call   8010022e <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave  
80101419:	c3                   	ret    

8010141a <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101420:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101427:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010142e:	e9 13 01 00 00       	jmp    80101546 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101436:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010143c:	85 c0                	test   %eax,%eax
8010143e:	0f 48 c2             	cmovs  %edx,%eax
80101441:	c1 f8 0c             	sar    $0xc,%eax
80101444:	89 c2                	mov    %eax,%edx
80101446:	a1 38 12 11 80       	mov    0x80111238,%eax
8010144b:	01 d0                	add    %edx,%eax
8010144d:	83 ec 08             	sub    $0x8,%esp
80101450:	50                   	push   %eax
80101451:	ff 75 08             	pushl  0x8(%ebp)
80101454:	e8 5d ed ff ff       	call   801001b6 <bread>
80101459:	83 c4 10             	add    $0x10,%esp
8010145c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010145f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101466:	e9 a6 00 00 00       	jmp    80101511 <balloc+0xf7>
      m = 1 << (bi % 8);
8010146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146e:	99                   	cltd   
8010146f:	c1 ea 1d             	shr    $0x1d,%edx
80101472:	01 d0                	add    %edx,%eax
80101474:	83 e0 07             	and    $0x7,%eax
80101477:	29 d0                	sub    %edx,%eax
80101479:	ba 01 00 00 00       	mov    $0x1,%edx
8010147e:	89 c1                	mov    %eax,%ecx
80101480:	d3 e2                	shl    %cl,%edx
80101482:	89 d0                	mov    %edx,%eax
80101484:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148a:	8d 50 07             	lea    0x7(%eax),%edx
8010148d:	85 c0                	test   %eax,%eax
8010148f:	0f 48 c2             	cmovs  %edx,%eax
80101492:	c1 f8 03             	sar    $0x3,%eax
80101495:	89 c2                	mov    %eax,%edx
80101497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149a:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010149f:	0f b6 c0             	movzbl %al,%eax
801014a2:	23 45 e8             	and    -0x18(%ebp),%eax
801014a5:	85 c0                	test   %eax,%eax
801014a7:	75 64                	jne    8010150d <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ac:	8d 50 07             	lea    0x7(%eax),%edx
801014af:	85 c0                	test   %eax,%eax
801014b1:	0f 48 c2             	cmovs  %edx,%eax
801014b4:	c1 f8 03             	sar    $0x3,%eax
801014b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ba:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014bf:	89 d1                	mov    %edx,%ecx
801014c1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c4:	09 ca                	or     %ecx,%edx
801014c6:	89 d1                	mov    %edx,%ecx
801014c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014cb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014cf:	83 ec 0c             	sub    $0xc,%esp
801014d2:	ff 75 ec             	pushl  -0x14(%ebp)
801014d5:	e8 ab 22 00 00       	call   80103785 <log_write>
801014da:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014dd:	83 ec 0c             	sub    $0xc,%esp
801014e0:	ff 75 ec             	pushl  -0x14(%ebp)
801014e3:	e8 46 ed ff ff       	call   8010022e <brelse>
801014e8:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f1:	01 c2                	add    %eax,%edx
801014f3:	8b 45 08             	mov    0x8(%ebp),%eax
801014f6:	83 ec 08             	sub    $0x8,%esp
801014f9:	52                   	push   %edx
801014fa:	50                   	push   %eax
801014fb:	e8 c6 fe ff ff       	call   801013c6 <bzero>
80101500:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101509:	01 d0                	add    %edx,%eax
8010150b:	eb 57                	jmp    80101564 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010150d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101511:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101518:	7f 17                	jg     80101531 <balloc+0x117>
8010151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101520:	01 d0                	add    %edx,%eax
80101522:	89 c2                	mov    %eax,%edx
80101524:	a1 20 12 11 80       	mov    0x80111220,%eax
80101529:	39 c2                	cmp    %eax,%edx
8010152b:	0f 82 3a ff ff ff    	jb     8010146b <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101531:	83 ec 0c             	sub    $0xc,%esp
80101534:	ff 75 ec             	pushl  -0x14(%ebp)
80101537:	e8 f2 ec ff ff       	call   8010022e <brelse>
8010153c:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010153f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101546:	8b 15 20 12 11 80    	mov    0x80111220,%edx
8010154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154f:	39 c2                	cmp    %eax,%edx
80101551:	0f 87 dc fe ff ff    	ja     80101433 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101557:	83 ec 0c             	sub    $0xc,%esp
8010155a:	68 64 86 10 80       	push   $0x80108664
8010155f:	e8 02 f0 ff ff       	call   80100566 <panic>
}
80101564:	c9                   	leave  
80101565:	c3                   	ret    

80101566 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101566:	55                   	push   %ebp
80101567:	89 e5                	mov    %esp,%ebp
80101569:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010156c:	83 ec 08             	sub    $0x8,%esp
8010156f:	68 20 12 11 80       	push   $0x80111220
80101574:	ff 75 08             	pushl  0x8(%ebp)
80101577:	e8 08 fe ff ff       	call   80101384 <readsb>
8010157c:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010157f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101582:	c1 e8 0c             	shr    $0xc,%eax
80101585:	89 c2                	mov    %eax,%edx
80101587:	a1 38 12 11 80       	mov    0x80111238,%eax
8010158c:	01 c2                	add    %eax,%edx
8010158e:	8b 45 08             	mov    0x8(%ebp),%eax
80101591:	83 ec 08             	sub    $0x8,%esp
80101594:	52                   	push   %edx
80101595:	50                   	push   %eax
80101596:	e8 1b ec ff ff       	call   801001b6 <bread>
8010159b:	83 c4 10             	add    $0x10,%esp
8010159e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a4:	25 ff 0f 00 00       	and    $0xfff,%eax
801015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015af:	99                   	cltd   
801015b0:	c1 ea 1d             	shr    $0x1d,%edx
801015b3:	01 d0                	add    %edx,%eax
801015b5:	83 e0 07             	and    $0x7,%eax
801015b8:	29 d0                	sub    %edx,%eax
801015ba:	ba 01 00 00 00       	mov    $0x1,%edx
801015bf:	89 c1                	mov    %eax,%ecx
801015c1:	d3 e2                	shl    %cl,%edx
801015c3:	89 d0                	mov    %edx,%eax
801015c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cb:	8d 50 07             	lea    0x7(%eax),%edx
801015ce:	85 c0                	test   %eax,%eax
801015d0:	0f 48 c2             	cmovs  %edx,%eax
801015d3:	c1 f8 03             	sar    $0x3,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015db:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e0:	0f b6 c0             	movzbl %al,%eax
801015e3:	23 45 ec             	and    -0x14(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	75 0d                	jne    801015f7 <bfree+0x91>
    panic("freeing free block");
801015ea:	83 ec 0c             	sub    $0xc,%esp
801015ed:	68 7a 86 10 80       	push   $0x8010867a
801015f2:	e8 6f ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	8d 50 07             	lea    0x7(%eax),%edx
801015fd:	85 c0                	test   %eax,%eax
801015ff:	0f 48 c2             	cmovs  %edx,%eax
80101602:	c1 f8 03             	sar    $0x3,%eax
80101605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101608:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010160d:	89 d1                	mov    %edx,%ecx
8010160f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101612:	f7 d2                	not    %edx
80101614:	21 ca                	and    %ecx,%edx
80101616:	89 d1                	mov    %edx,%ecx
80101618:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010161f:	83 ec 0c             	sub    $0xc,%esp
80101622:	ff 75 f4             	pushl  -0xc(%ebp)
80101625:	e8 5b 21 00 00       	call   80103785 <log_write>
8010162a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	ff 75 f4             	pushl  -0xc(%ebp)
80101633:	e8 f6 eb ff ff       	call   8010022e <brelse>
80101638:	83 c4 10             	add    $0x10,%esp
}
8010163b:	90                   	nop
8010163c:	c9                   	leave  
8010163d:	c3                   	ret    

8010163e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010163e:	55                   	push   %ebp
8010163f:	89 e5                	mov    %esp,%ebp
80101641:	57                   	push   %edi
80101642:	56                   	push   %esi
80101643:	53                   	push   %ebx
80101644:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101647:	83 ec 08             	sub    $0x8,%esp
8010164a:	68 8d 86 10 80       	push   $0x8010868d
8010164f:	68 40 12 11 80       	push   $0x80111240
80101654:	e8 1e 3a 00 00       	call   80105077 <initlock>
80101659:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010165c:	83 ec 08             	sub    $0x8,%esp
8010165f:	68 20 12 11 80       	push   $0x80111220
80101664:	ff 75 08             	pushl  0x8(%ebp)
80101667:	e8 18 fd ff ff       	call   80101384 <readsb>
8010166c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010166f:	a1 38 12 11 80       	mov    0x80111238,%eax
80101674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101677:	8b 3d 34 12 11 80    	mov    0x80111234,%edi
8010167d:	8b 35 30 12 11 80    	mov    0x80111230,%esi
80101683:	8b 1d 2c 12 11 80    	mov    0x8011122c,%ebx
80101689:	8b 0d 28 12 11 80    	mov    0x80111228,%ecx
8010168f:	8b 15 24 12 11 80    	mov    0x80111224,%edx
80101695:	a1 20 12 11 80       	mov    0x80111220,%eax
8010169a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010169d:	57                   	push   %edi
8010169e:	56                   	push   %esi
8010169f:	53                   	push   %ebx
801016a0:	51                   	push   %ecx
801016a1:	52                   	push   %edx
801016a2:	50                   	push   %eax
801016a3:	68 94 86 10 80       	push   $0x80108694
801016a8:	e8 19 ed ff ff       	call   801003c6 <cprintf>
801016ad:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016b0:	90                   	nop
801016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016b4:	5b                   	pop    %ebx
801016b5:	5e                   	pop    %esi
801016b6:	5f                   	pop    %edi
801016b7:	5d                   	pop    %ebp
801016b8:	c3                   	ret    

801016b9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016b9:	55                   	push   %ebp
801016ba:	89 e5                	mov    %esp,%ebp
801016bc:	83 ec 28             	sub    $0x28,%esp
801016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016cd:	e9 9e 00 00 00       	jmp    80101770 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	c1 e8 03             	shr    $0x3,%eax
801016d8:	89 c2                	mov    %eax,%edx
801016da:	a1 34 12 11 80       	mov    0x80111234,%eax
801016df:	01 d0                	add    %edx,%eax
801016e1:	83 ec 08             	sub    $0x8,%esp
801016e4:	50                   	push   %eax
801016e5:	ff 75 08             	pushl  0x8(%ebp)
801016e8:	e8 c9 ea ff ff       	call   801001b6 <bread>
801016ed:	83 c4 10             	add    $0x10,%esp
801016f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f6:	8d 50 18             	lea    0x18(%eax),%edx
801016f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016fc:	83 e0 07             	and    $0x7,%eax
801016ff:	c1 e0 06             	shl    $0x6,%eax
80101702:	01 d0                	add    %edx,%eax
80101704:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101707:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170a:	0f b7 00             	movzwl (%eax),%eax
8010170d:	66 85 c0             	test   %ax,%ax
80101710:	75 4c                	jne    8010175e <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101712:	83 ec 04             	sub    $0x4,%esp
80101715:	6a 40                	push   $0x40
80101717:	6a 00                	push   $0x0
80101719:	ff 75 ec             	pushl  -0x14(%ebp)
8010171c:	e8 db 3b 00 00       	call   801052fc <memset>
80101721:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101724:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101727:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010172b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010172e:	83 ec 0c             	sub    $0xc,%esp
80101731:	ff 75 f0             	pushl  -0x10(%ebp)
80101734:	e8 4c 20 00 00       	call   80103785 <log_write>
80101739:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010173c:	83 ec 0c             	sub    $0xc,%esp
8010173f:	ff 75 f0             	pushl  -0x10(%ebp)
80101742:	e8 e7 ea ff ff       	call   8010022e <brelse>
80101747:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	83 ec 08             	sub    $0x8,%esp
80101750:	50                   	push   %eax
80101751:	ff 75 08             	pushl  0x8(%ebp)
80101754:	e8 f8 00 00 00       	call   80101851 <iget>
80101759:	83 c4 10             	add    $0x10,%esp
8010175c:	eb 30                	jmp    8010178e <ialloc+0xd5>
    }
    brelse(bp);
8010175e:	83 ec 0c             	sub    $0xc,%esp
80101761:	ff 75 f0             	pushl  -0x10(%ebp)
80101764:	e8 c5 ea ff ff       	call   8010022e <brelse>
80101769:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010176c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101770:	8b 15 28 12 11 80    	mov    0x80111228,%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	39 c2                	cmp    %eax,%edx
8010177b:	0f 87 51 ff ff ff    	ja     801016d2 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101781:	83 ec 0c             	sub    $0xc,%esp
80101784:	68 e7 86 10 80       	push   $0x801086e7
80101789:	e8 d8 ed ff ff       	call   80100566 <panic>
}
8010178e:	c9                   	leave  
8010178f:	c3                   	ret    

80101790 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101796:	8b 45 08             	mov    0x8(%ebp),%eax
80101799:	8b 40 04             	mov    0x4(%eax),%eax
8010179c:	c1 e8 03             	shr    $0x3,%eax
8010179f:	89 c2                	mov    %eax,%edx
801017a1:	a1 34 12 11 80       	mov    0x80111234,%eax
801017a6:	01 c2                	add    %eax,%edx
801017a8:	8b 45 08             	mov    0x8(%ebp),%eax
801017ab:	8b 00                	mov    (%eax),%eax
801017ad:	83 ec 08             	sub    $0x8,%esp
801017b0:	52                   	push   %edx
801017b1:	50                   	push   %eax
801017b2:	e8 ff e9 ff ff       	call   801001b6 <bread>
801017b7:	83 c4 10             	add    $0x10,%esp
801017ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c0:	8d 50 18             	lea    0x18(%eax),%edx
801017c3:	8b 45 08             	mov    0x8(%ebp),%eax
801017c6:	8b 40 04             	mov    0x4(%eax),%eax
801017c9:	83 e0 07             	and    $0x7,%eax
801017cc:	c1 e0 06             	shl    $0x6,%eax
801017cf:	01 d0                	add    %edx,%eax
801017d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017de:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e1:	8b 45 08             	mov    0x8(%ebp),%eax
801017e4:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017eb:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017ef:	8b 45 08             	mov    0x8(%ebp),%eax
801017f2:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101800:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101807:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010180b:	8b 45 08             	mov    0x8(%ebp),%eax
8010180e:	8b 50 18             	mov    0x18(%eax),%edx
80101811:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101814:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101817:	8b 45 08             	mov    0x8(%ebp),%eax
8010181a:	8d 50 1c             	lea    0x1c(%eax),%edx
8010181d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101820:	83 c0 0c             	add    $0xc,%eax
80101823:	83 ec 04             	sub    $0x4,%esp
80101826:	6a 34                	push   $0x34
80101828:	52                   	push   %edx
80101829:	50                   	push   %eax
8010182a:	e8 8c 3b 00 00       	call   801053bb <memmove>
8010182f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101832:	83 ec 0c             	sub    $0xc,%esp
80101835:	ff 75 f4             	pushl  -0xc(%ebp)
80101838:	e8 48 1f 00 00       	call   80103785 <log_write>
8010183d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101840:	83 ec 0c             	sub    $0xc,%esp
80101843:	ff 75 f4             	pushl  -0xc(%ebp)
80101846:	e8 e3 e9 ff ff       	call   8010022e <brelse>
8010184b:	83 c4 10             	add    $0x10,%esp
}
8010184e:	90                   	nop
8010184f:	c9                   	leave  
80101850:	c3                   	ret    

80101851 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101851:	55                   	push   %ebp
80101852:	89 e5                	mov    %esp,%ebp
80101854:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101857:	83 ec 0c             	sub    $0xc,%esp
8010185a:	68 40 12 11 80       	push   $0x80111240
8010185f:	e8 35 38 00 00       	call   80105099 <acquire>
80101864:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101867:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010186e:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101875:	eb 5d                	jmp    801018d4 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187a:	8b 40 08             	mov    0x8(%eax),%eax
8010187d:	85 c0                	test   %eax,%eax
8010187f:	7e 39                	jle    801018ba <iget+0x69>
80101881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101884:	8b 00                	mov    (%eax),%eax
80101886:	3b 45 08             	cmp    0x8(%ebp),%eax
80101889:	75 2f                	jne    801018ba <iget+0x69>
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	8b 40 04             	mov    0x4(%eax),%eax
80101891:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101894:	75 24                	jne    801018ba <iget+0x69>
      ip->ref++;
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 08             	mov    0x8(%eax),%eax
8010189c:	8d 50 01             	lea    0x1(%eax),%edx
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	68 40 12 11 80       	push   $0x80111240
801018ad:	e8 4e 38 00 00       	call   80105100 <release>
801018b2:	83 c4 10             	add    $0x10,%esp
      return ip;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	eb 74                	jmp    8010192e <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018be:	75 10                	jne    801018d0 <iget+0x7f>
801018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c3:	8b 40 08             	mov    0x8(%eax),%eax
801018c6:	85 c0                	test   %eax,%eax
801018c8:	75 06                	jne    801018d0 <iget+0x7f>
      empty = ip;
801018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d0:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018d4:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801018db:	72 9a                	jb     80101877 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e1:	75 0d                	jne    801018f0 <iget+0x9f>
    panic("iget: no inodes");
801018e3:	83 ec 0c             	sub    $0xc,%esp
801018e6:	68 f9 86 10 80       	push   $0x801086f9
801018eb:	e8 76 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	8b 55 08             	mov    0x8(%ebp),%edx
801018fc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 55 0c             	mov    0xc(%ebp),%edx
80101904:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010191b:	83 ec 0c             	sub    $0xc,%esp
8010191e:	68 40 12 11 80       	push   $0x80111240
80101923:	e8 d8 37 00 00       	call   80105100 <release>
80101928:	83 c4 10             	add    $0x10,%esp

  return ip;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010192e:	c9                   	leave  
8010192f:	c3                   	ret    

80101930 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101930:	55                   	push   %ebp
80101931:	89 e5                	mov    %esp,%ebp
80101933:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101936:	83 ec 0c             	sub    $0xc,%esp
80101939:	68 40 12 11 80       	push   $0x80111240
8010193e:	e8 56 37 00 00       	call   80105099 <acquire>
80101943:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	8b 40 08             	mov    0x8(%eax),%eax
8010194c:	8d 50 01             	lea    0x1(%eax),%edx
8010194f:	8b 45 08             	mov    0x8(%ebp),%eax
80101952:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101955:	83 ec 0c             	sub    $0xc,%esp
80101958:	68 40 12 11 80       	push   $0x80111240
8010195d:	e8 9e 37 00 00       	call   80105100 <release>
80101962:	83 c4 10             	add    $0x10,%esp
  return ip;
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101968:	c9                   	leave  
80101969:	c3                   	ret    

8010196a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010196a:	55                   	push   %ebp
8010196b:	89 e5                	mov    %esp,%ebp
8010196d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101970:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101974:	74 0a                	je     80101980 <ilock+0x16>
80101976:	8b 45 08             	mov    0x8(%ebp),%eax
80101979:	8b 40 08             	mov    0x8(%eax),%eax
8010197c:	85 c0                	test   %eax,%eax
8010197e:	7f 0d                	jg     8010198d <ilock+0x23>
    panic("ilock");
80101980:	83 ec 0c             	sub    $0xc,%esp
80101983:	68 09 87 10 80       	push   $0x80108709
80101988:	e8 d9 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010198d:	83 ec 0c             	sub    $0xc,%esp
80101990:	68 40 12 11 80       	push   $0x80111240
80101995:	e8 ff 36 00 00       	call   80105099 <acquire>
8010199a:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010199d:	eb 13                	jmp    801019b2 <ilock+0x48>
    sleep(ip, &icache.lock);
8010199f:	83 ec 08             	sub    $0x8,%esp
801019a2:	68 40 12 11 80       	push   $0x80111240
801019a7:	ff 75 08             	pushl  0x8(%ebp)
801019aa:	e8 e8 33 00 00       	call   80104d97 <sleep>
801019af:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b2:	8b 45 08             	mov    0x8(%ebp),%eax
801019b5:	8b 40 0c             	mov    0xc(%eax),%eax
801019b8:	83 e0 01             	and    $0x1,%eax
801019bb:	85 c0                	test   %eax,%eax
801019bd:	75 e0                	jne    8010199f <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	8b 40 0c             	mov    0xc(%eax),%eax
801019c5:	83 c8 01             	or     $0x1,%eax
801019c8:	89 c2                	mov    %eax,%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d0:	83 ec 0c             	sub    $0xc,%esp
801019d3:	68 40 12 11 80       	push   $0x80111240
801019d8:	e8 23 37 00 00       	call   80105100 <release>
801019dd:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	8b 40 0c             	mov    0xc(%eax),%eax
801019e6:	83 e0 02             	and    $0x2,%eax
801019e9:	85 c0                	test   %eax,%eax
801019eb:	0f 85 d4 00 00 00    	jne    80101ac5 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 04             	mov    0x4(%eax),%eax
801019f7:	c1 e8 03             	shr    $0x3,%eax
801019fa:	89 c2                	mov    %eax,%edx
801019fc:	a1 34 12 11 80       	mov    0x80111234,%eax
80101a01:	01 c2                	add    %eax,%edx
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 00                	mov    (%eax),%eax
80101a08:	83 ec 08             	sub    $0x8,%esp
80101a0b:	52                   	push   %edx
80101a0c:	50                   	push   %eax
80101a0d:	e8 a4 e7 ff ff       	call   801001b6 <bread>
80101a12:	83 c4 10             	add    $0x10,%esp
80101a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	8d 50 18             	lea    0x18(%eax),%edx
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	8b 40 04             	mov    0x4(%eax),%eax
80101a24:	83 e0 07             	and    $0x7,%eax
80101a27:	c1 e0 06             	shl    $0x6,%eax
80101a2a:	01 d0                	add    %edx,%eax
80101a2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a32:	0f b7 10             	movzwl (%eax),%edx
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a43:	8b 45 08             	mov    0x8(%ebp),%eax
80101a46:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a62:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a69:	8b 50 08             	mov    0x8(%eax),%edx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a75:	8d 50 0c             	lea    0xc(%eax),%edx
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	83 c0 1c             	add    $0x1c,%eax
80101a7e:	83 ec 04             	sub    $0x4,%esp
80101a81:	6a 34                	push   $0x34
80101a83:	52                   	push   %edx
80101a84:	50                   	push   %eax
80101a85:	e8 31 39 00 00       	call   801053bb <memmove>
80101a8a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
80101a90:	ff 75 f4             	pushl  -0xc(%ebp)
80101a93:	e8 96 e7 ff ff       	call   8010022e <brelse>
80101a98:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa1:	83 c8 02             	or     $0x2,%eax
80101aa4:	89 c2                	mov    %eax,%edx
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aac:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab3:	66 85 c0             	test   %ax,%ax
80101ab6:	75 0d                	jne    80101ac5 <ilock+0x15b>
      panic("ilock: no type");
80101ab8:	83 ec 0c             	sub    $0xc,%esp
80101abb:	68 0f 87 10 80       	push   $0x8010870f
80101ac0:	e8 a1 ea ff ff       	call   80100566 <panic>
  }
}
80101ac5:	90                   	nop
80101ac6:	c9                   	leave  
80101ac7:	c3                   	ret    

80101ac8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac8:	55                   	push   %ebp
80101ac9:	89 e5                	mov    %esp,%ebp
80101acb:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ace:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad2:	74 17                	je     80101aeb <iunlock+0x23>
80101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad7:	8b 40 0c             	mov    0xc(%eax),%eax
80101ada:	83 e0 01             	and    $0x1,%eax
80101add:	85 c0                	test   %eax,%eax
80101adf:	74 0a                	je     80101aeb <iunlock+0x23>
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	8b 40 08             	mov    0x8(%eax),%eax
80101ae7:	85 c0                	test   %eax,%eax
80101ae9:	7f 0d                	jg     80101af8 <iunlock+0x30>
    panic("iunlock");
80101aeb:	83 ec 0c             	sub    $0xc,%esp
80101aee:	68 1e 87 10 80       	push   $0x8010871e
80101af3:	e8 6e ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af8:	83 ec 0c             	sub    $0xc,%esp
80101afb:	68 40 12 11 80       	push   $0x80111240
80101b00:	e8 94 35 00 00       	call   80105099 <acquire>
80101b05:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b08:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0e:	83 e0 fe             	and    $0xfffffffe,%eax
80101b11:	89 c2                	mov    %eax,%edx
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b19:	83 ec 0c             	sub    $0xc,%esp
80101b1c:	ff 75 08             	pushl  0x8(%ebp)
80101b1f:	e8 61 33 00 00       	call   80104e85 <wakeup>
80101b24:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b27:	83 ec 0c             	sub    $0xc,%esp
80101b2a:	68 40 12 11 80       	push   $0x80111240
80101b2f:	e8 cc 35 00 00       	call   80105100 <release>
80101b34:	83 c4 10             	add    $0x10,%esp
}
80101b37:	90                   	nop
80101b38:	c9                   	leave  
80101b39:	c3                   	ret    

80101b3a <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b3a:	55                   	push   %ebp
80101b3b:	89 e5                	mov    %esp,%ebp
80101b3d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b40:	83 ec 0c             	sub    $0xc,%esp
80101b43:	68 40 12 11 80       	push   $0x80111240
80101b48:	e8 4c 35 00 00       	call   80105099 <acquire>
80101b4d:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 08             	mov    0x8(%eax),%eax
80101b56:	83 f8 01             	cmp    $0x1,%eax
80101b59:	0f 85 a9 00 00 00    	jne    80101c08 <iput+0xce>
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	8b 40 0c             	mov    0xc(%eax),%eax
80101b65:	83 e0 02             	and    $0x2,%eax
80101b68:	85 c0                	test   %eax,%eax
80101b6a:	0f 84 98 00 00 00    	je     80101c08 <iput+0xce>
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b77:	66 85 c0             	test   %ax,%ax
80101b7a:	0f 85 88 00 00 00    	jne    80101c08 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b80:	8b 45 08             	mov    0x8(%ebp),%eax
80101b83:	8b 40 0c             	mov    0xc(%eax),%eax
80101b86:	83 e0 01             	and    $0x1,%eax
80101b89:	85 c0                	test   %eax,%eax
80101b8b:	74 0d                	je     80101b9a <iput+0x60>
      panic("iput busy");
80101b8d:	83 ec 0c             	sub    $0xc,%esp
80101b90:	68 26 87 10 80       	push   $0x80108726
80101b95:	e8 cc e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba0:	83 c8 01             	or     $0x1,%eax
80101ba3:	89 c2                	mov    %eax,%edx
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bab:	83 ec 0c             	sub    $0xc,%esp
80101bae:	68 40 12 11 80       	push   $0x80111240
80101bb3:	e8 48 35 00 00       	call   80105100 <release>
80101bb8:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bbb:	83 ec 0c             	sub    $0xc,%esp
80101bbe:	ff 75 08             	pushl  0x8(%ebp)
80101bc1:	e8 a8 01 00 00       	call   80101d6e <itrunc>
80101bc6:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	ff 75 08             	pushl  0x8(%ebp)
80101bd8:	e8 b3 fb ff ff       	call   80101790 <iupdate>
80101bdd:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101be0:	83 ec 0c             	sub    $0xc,%esp
80101be3:	68 40 12 11 80       	push   $0x80111240
80101be8:	e8 ac 34 00 00       	call   80105099 <acquire>
80101bed:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bfa:	83 ec 0c             	sub    $0xc,%esp
80101bfd:	ff 75 08             	pushl  0x8(%ebp)
80101c00:	e8 80 32 00 00       	call   80104e85 <wakeup>
80101c05:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 40 12 11 80       	push   $0x80111240
80101c1f:	e8 dc 34 00 00       	call   80105100 <release>
80101c24:	83 c4 10             	add    $0x10,%esp
}
80101c27:	90                   	nop
80101c28:	c9                   	leave  
80101c29:	c3                   	ret    

80101c2a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c2a:	55                   	push   %ebp
80101c2b:	89 e5                	mov    %esp,%ebp
80101c2d:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	ff 75 08             	pushl  0x8(%ebp)
80101c36:	e8 8d fe ff ff       	call   80101ac8 <iunlock>
80101c3b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c3e:	83 ec 0c             	sub    $0xc,%esp
80101c41:	ff 75 08             	pushl  0x8(%ebp)
80101c44:	e8 f1 fe ff ff       	call   80101b3a <iput>
80101c49:	83 c4 10             	add    $0x10,%esp
}
80101c4c:	90                   	nop
80101c4d:	c9                   	leave  
80101c4e:	c3                   	ret    

80101c4f <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c4f:	55                   	push   %ebp
80101c50:	89 e5                	mov    %esp,%ebp
80101c52:	53                   	push   %ebx
80101c53:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c56:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c5a:	77 42                	ja     80101c9e <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c62:	83 c2 04             	add    $0x4,%edx
80101c65:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c70:	75 24                	jne    80101c96 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	8b 00                	mov    (%eax),%eax
80101c77:	83 ec 0c             	sub    $0xc,%esp
80101c7a:	50                   	push   %eax
80101c7b:	e8 9a f7 ff ff       	call   8010141a <balloc>
80101c80:	83 c4 10             	add    $0x10,%esp
80101c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8c:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c92:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c99:	e9 cb 00 00 00       	jmp    80101d69 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c9e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca2:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ca6:	0f 87 b0 00 00 00    	ja     80101d5c <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb9:	75 1d                	jne    80101cd8 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	8b 00                	mov    (%eax),%eax
80101cc0:	83 ec 0c             	sub    $0xc,%esp
80101cc3:	50                   	push   %eax
80101cc4:	e8 51 f7 ff ff       	call   8010141a <balloc>
80101cc9:	83 c4 10             	add    $0x10,%esp
80101ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd5:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	8b 00                	mov    (%eax),%eax
80101cdd:	83 ec 08             	sub    $0x8,%esp
80101ce0:	ff 75 f4             	pushl  -0xc(%ebp)
80101ce3:	50                   	push   %eax
80101ce4:	e8 cd e4 ff ff       	call   801001b6 <bread>
80101ce9:	83 c4 10             	add    $0x10,%esp
80101cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf2:	83 c0 18             	add    $0x18,%eax
80101cf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d05:	01 d0                	add    %edx,%eax
80101d07:	8b 00                	mov    (%eax),%eax
80101d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d10:	75 37                	jne    80101d49 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d22:	8b 45 08             	mov    0x8(%ebp),%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	83 ec 0c             	sub    $0xc,%esp
80101d2a:	50                   	push   %eax
80101d2b:	e8 ea f6 ff ff       	call   8010141a <balloc>
80101d30:	83 c4 10             	add    $0x10,%esp
80101d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d39:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d3b:	83 ec 0c             	sub    $0xc,%esp
80101d3e:	ff 75 f0             	pushl  -0x10(%ebp)
80101d41:	e8 3f 1a 00 00       	call   80103785 <log_write>
80101d46:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d49:	83 ec 0c             	sub    $0xc,%esp
80101d4c:	ff 75 f0             	pushl  -0x10(%ebp)
80101d4f:	e8 da e4 ff ff       	call   8010022e <brelse>
80101d54:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5a:	eb 0d                	jmp    80101d69 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d5c:	83 ec 0c             	sub    $0xc,%esp
80101d5f:	68 30 87 10 80       	push   $0x80108730
80101d64:	e8 fd e7 ff ff       	call   80100566 <panic>
}
80101d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d6c:	c9                   	leave  
80101d6d:	c3                   	ret    

80101d6e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d6e:	55                   	push   %ebp
80101d6f:	89 e5                	mov    %esp,%ebp
80101d71:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d7b:	eb 45                	jmp    80101dc2 <itrunc+0x54>
    if(ip->addrs[i]){
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	83 c2 04             	add    $0x4,%edx
80101d86:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8a:	85 c0                	test   %eax,%eax
80101d8c:	74 30                	je     80101dbe <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d94:	83 c2 04             	add    $0x4,%edx
80101d97:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9e:	8b 12                	mov    (%edx),%edx
80101da0:	83 ec 08             	sub    $0x8,%esp
80101da3:	50                   	push   %eax
80101da4:	52                   	push   %edx
80101da5:	e8 bc f7 ff ff       	call   80101566 <bfree>
80101daa:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db3:	83 c2 04             	add    $0x4,%edx
80101db6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dbd:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc2:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc6:	7e b5                	jle    80101d7d <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dce:	85 c0                	test   %eax,%eax
80101dd0:	0f 84 a1 00 00 00    	je     80101e77 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 cb e3 ff ff       	call   801001b6 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 18             	add    $0x18,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd1>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 2e f7 ff ff       	call   80101566 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	pushl  -0x14(%ebp)
80101e4d:	e8 dc e3 ff ff       	call   8010022e <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e5b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5e:	8b 12                	mov    (%edx),%edx
80101e60:	83 ec 08             	sub    $0x8,%esp
80101e63:	50                   	push   %eax
80101e64:	52                   	push   %edx
80101e65:	e8 fc f6 ff ff       	call   80101566 <bfree>
80101e6a:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e70:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e81:	83 ec 0c             	sub    $0xc,%esp
80101e84:	ff 75 08             	pushl  0x8(%ebp)
80101e87:	e8 04 f9 ff ff       	call   80101790 <iupdate>
80101e8c:	83 c4 10             	add    $0x10,%esp
}
80101e8f:	90                   	nop
80101e90:	c9                   	leave  
80101e91:	c3                   	ret    

80101e92 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e92:	55                   	push   %ebp
80101e93:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 00                	mov    (%eax),%eax
80101e9a:	89 c2                	mov    %eax,%edx
80101e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9f:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea5:	8b 50 04             	mov    0x4(%eax),%edx
80101ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eab:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 50 18             	mov    0x18(%eax),%edx
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed5:	90                   	nop
80101ed6:	5d                   	pop    %ebp
80101ed7:	c3                   	ret    

80101ed8 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed8:	55                   	push   %ebp
80101ed9:	89 e5                	mov    %esp,%ebp
80101edb:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee5:	66 83 f8 03          	cmp    $0x3,%ax
80101ee9:	75 5c                	jne    80101f47 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 85 c0             	test   %ax,%ax
80101ef5:	78 20                	js     80101f17 <readi+0x3f>
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efe:	66 83 f8 09          	cmp    $0x9,%ax
80101f02:	7f 13                	jg     80101f17 <readi+0x3f>
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0b:	98                   	cwtl   
80101f0c:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101f13:	85 c0                	test   %eax,%eax
80101f15:	75 0a                	jne    80101f21 <readi+0x49>
      return -1;
80101f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1c:	e9 0c 01 00 00       	jmp    8010202d <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f28:	98                   	cwtl   
80101f29:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101f30:	8b 55 14             	mov    0x14(%ebp),%edx
80101f33:	83 ec 04             	sub    $0x4,%esp
80101f36:	52                   	push   %edx
80101f37:	ff 75 0c             	pushl  0xc(%ebp)
80101f3a:	ff 75 08             	pushl  0x8(%ebp)
80101f3d:	ff d0                	call   *%eax
80101f3f:	83 c4 10             	add    $0x10,%esp
80101f42:	e9 e6 00 00 00       	jmp    8010202d <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	8b 40 18             	mov    0x18(%eax),%eax
80101f4d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f50:	72 0d                	jb     80101f5f <readi+0x87>
80101f52:	8b 55 10             	mov    0x10(%ebp),%edx
80101f55:	8b 45 14             	mov    0x14(%ebp),%eax
80101f58:	01 d0                	add    %edx,%eax
80101f5a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5d:	73 0a                	jae    80101f69 <readi+0x91>
    return -1;
80101f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f64:	e9 c4 00 00 00       	jmp    8010202d <readi+0x155>
  if(off + n > ip->size)
80101f69:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6c:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6f:	01 c2                	add    %eax,%edx
80101f71:	8b 45 08             	mov    0x8(%ebp),%eax
80101f74:	8b 40 18             	mov    0x18(%eax),%eax
80101f77:	39 c2                	cmp    %eax,%edx
80101f79:	76 0c                	jbe    80101f87 <readi+0xaf>
    n = ip->size - off;
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	8b 40 18             	mov    0x18(%eax),%eax
80101f81:	2b 45 10             	sub    0x10(%ebp),%eax
80101f84:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8e:	e9 8b 00 00 00       	jmp    8010201e <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f93:	8b 45 10             	mov    0x10(%ebp),%eax
80101f96:	c1 e8 09             	shr    $0x9,%eax
80101f99:	83 ec 08             	sub    $0x8,%esp
80101f9c:	50                   	push   %eax
80101f9d:	ff 75 08             	pushl  0x8(%ebp)
80101fa0:	e8 aa fc ff ff       	call   80101c4f <bmap>
80101fa5:	83 c4 10             	add    $0x10,%esp
80101fa8:	89 c2                	mov    %eax,%edx
80101faa:	8b 45 08             	mov    0x8(%ebp),%eax
80101fad:	8b 00                	mov    (%eax),%eax
80101faf:	83 ec 08             	sub    $0x8,%esp
80101fb2:	52                   	push   %edx
80101fb3:	50                   	push   %eax
80101fb4:	e8 fd e1 ff ff       	call   801001b6 <bread>
80101fb9:	83 c4 10             	add    $0x10,%esp
80101fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc7:	ba 00 02 00 00       	mov    $0x200,%edx
80101fcc:	29 c2                	sub    %eax,%edx
80101fce:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd1:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd4:	39 c2                	cmp    %eax,%edx
80101fd6:	0f 46 c2             	cmovbe %edx,%eax
80101fd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdf:	8d 50 18             	lea    0x18(%eax),%edx
80101fe2:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe5:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fea:	01 d0                	add    %edx,%eax
80101fec:	83 ec 04             	sub    $0x4,%esp
80101fef:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff2:	50                   	push   %eax
80101ff3:	ff 75 0c             	pushl  0xc(%ebp)
80101ff6:	e8 c0 33 00 00       	call   801053bb <memmove>
80101ffb:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffe:	83 ec 0c             	sub    $0xc,%esp
80102001:	ff 75 f0             	pushl  -0x10(%ebp)
80102004:	e8 25 e2 ff ff       	call   8010022e <brelse>
80102009:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102015:	01 45 10             	add    %eax,0x10(%ebp)
80102018:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201b:	01 45 0c             	add    %eax,0xc(%ebp)
8010201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102021:	3b 45 14             	cmp    0x14(%ebp),%eax
80102024:	0f 82 69 ff ff ff    	jb     80101f93 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010202a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202d:	c9                   	leave  
8010202e:	c3                   	ret    

8010202f <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202f:	55                   	push   %ebp
80102030:	89 e5                	mov    %esp,%ebp
80102032:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010203c:	66 83 f8 03          	cmp    $0x3,%ax
80102040:	75 5c                	jne    8010209e <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102049:	66 85 c0             	test   %ax,%ax
8010204c:	78 20                	js     8010206e <writei+0x3f>
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102055:	66 83 f8 09          	cmp    $0x9,%ax
80102059:	7f 13                	jg     8010206e <writei+0x3f>
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102062:	98                   	cwtl   
80102063:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
8010206a:	85 c0                	test   %eax,%eax
8010206c:	75 0a                	jne    80102078 <writei+0x49>
      return -1;
8010206e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102073:	e9 3d 01 00 00       	jmp    801021b5 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207f:	98                   	cwtl   
80102080:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
80102087:	8b 55 14             	mov    0x14(%ebp),%edx
8010208a:	83 ec 04             	sub    $0x4,%esp
8010208d:	52                   	push   %edx
8010208e:	ff 75 0c             	pushl  0xc(%ebp)
80102091:	ff 75 08             	pushl  0x8(%ebp)
80102094:	ff d0                	call   *%eax
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	e9 17 01 00 00       	jmp    801021b5 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	8b 40 18             	mov    0x18(%eax),%eax
801020a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a7:	72 0d                	jb     801020b6 <writei+0x87>
801020a9:	8b 55 10             	mov    0x10(%ebp),%edx
801020ac:	8b 45 14             	mov    0x14(%ebp),%eax
801020af:	01 d0                	add    %edx,%eax
801020b1:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b4:	73 0a                	jae    801020c0 <writei+0x91>
    return -1;
801020b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bb:	e9 f5 00 00 00       	jmp    801021b5 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020c0:	8b 55 10             	mov    0x10(%ebp),%edx
801020c3:	8b 45 14             	mov    0x14(%ebp),%eax
801020c6:	01 d0                	add    %edx,%eax
801020c8:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020cd:	76 0a                	jbe    801020d9 <writei+0xaa>
    return -1;
801020cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d4:	e9 dc 00 00 00       	jmp    801021b5 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e0:	e9 99 00 00 00       	jmp    8010217e <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e5:	8b 45 10             	mov    0x10(%ebp),%eax
801020e8:	c1 e8 09             	shr    $0x9,%eax
801020eb:	83 ec 08             	sub    $0x8,%esp
801020ee:	50                   	push   %eax
801020ef:	ff 75 08             	pushl  0x8(%ebp)
801020f2:	e8 58 fb ff ff       	call   80101c4f <bmap>
801020f7:	83 c4 10             	add    $0x10,%esp
801020fa:	89 c2                	mov    %eax,%edx
801020fc:	8b 45 08             	mov    0x8(%ebp),%eax
801020ff:	8b 00                	mov    (%eax),%eax
80102101:	83 ec 08             	sub    $0x8,%esp
80102104:	52                   	push   %edx
80102105:	50                   	push   %eax
80102106:	e8 ab e0 ff ff       	call   801001b6 <bread>
8010210b:	83 c4 10             	add    $0x10,%esp
8010210e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	25 ff 01 00 00       	and    $0x1ff,%eax
80102119:	ba 00 02 00 00       	mov    $0x200,%edx
8010211e:	29 c2                	sub    %eax,%edx
80102120:	8b 45 14             	mov    0x14(%ebp),%eax
80102123:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102126:	39 c2                	cmp    %eax,%edx
80102128:	0f 46 c2             	cmovbe %edx,%eax
8010212b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102131:	8d 50 18             	lea    0x18(%eax),%edx
80102134:	8b 45 10             	mov    0x10(%ebp),%eax
80102137:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213c:	01 d0                	add    %edx,%eax
8010213e:	83 ec 04             	sub    $0x4,%esp
80102141:	ff 75 ec             	pushl  -0x14(%ebp)
80102144:	ff 75 0c             	pushl  0xc(%ebp)
80102147:	50                   	push   %eax
80102148:	e8 6e 32 00 00       	call   801053bb <memmove>
8010214d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102150:	83 ec 0c             	sub    $0xc,%esp
80102153:	ff 75 f0             	pushl  -0x10(%ebp)
80102156:	e8 2a 16 00 00       	call   80103785 <log_write>
8010215b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010215e:	83 ec 0c             	sub    $0xc,%esp
80102161:	ff 75 f0             	pushl  -0x10(%ebp)
80102164:	e8 c5 e0 ff ff       	call   8010022e <brelse>
80102169:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 10             	add    %eax,0x10(%ebp)
80102178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217b:	01 45 0c             	add    %eax,0xc(%ebp)
8010217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102181:	3b 45 14             	cmp    0x14(%ebp),%eax
80102184:	0f 82 5b ff ff ff    	jb     801020e5 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010218a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010218e:	74 22                	je     801021b2 <writei+0x183>
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	8b 40 18             	mov    0x18(%eax),%eax
80102196:	3b 45 10             	cmp    0x10(%ebp),%eax
80102199:	73 17                	jae    801021b2 <writei+0x183>
    ip->size = off;
8010219b:	8b 45 08             	mov    0x8(%ebp),%eax
8010219e:	8b 55 10             	mov    0x10(%ebp),%edx
801021a1:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021a4:	83 ec 0c             	sub    $0xc,%esp
801021a7:	ff 75 08             	pushl  0x8(%ebp)
801021aa:	e8 e1 f5 ff ff       	call   80101790 <iupdate>
801021af:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b2:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b5:	c9                   	leave  
801021b6:	c3                   	ret    

801021b7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b7:	55                   	push   %ebp
801021b8:	89 e5                	mov    %esp,%ebp
801021ba:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bd:	83 ec 04             	sub    $0x4,%esp
801021c0:	6a 0e                	push   $0xe
801021c2:	ff 75 0c             	pushl  0xc(%ebp)
801021c5:	ff 75 08             	pushl  0x8(%ebp)
801021c8:	e8 84 32 00 00       	call   80105451 <strncmp>
801021cd:	83 c4 10             	add    $0x10,%esp
}
801021d0:	c9                   	leave  
801021d1:	c3                   	ret    

801021d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d2:	55                   	push   %ebp
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021df:	66 83 f8 01          	cmp    $0x1,%ax
801021e3:	74 0d                	je     801021f2 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e5:	83 ec 0c             	sub    $0xc,%esp
801021e8:	68 43 87 10 80       	push   $0x80108743
801021ed:	e8 74 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f9:	eb 7b                	jmp    80102276 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fb:	6a 10                	push   $0x10
801021fd:	ff 75 f4             	pushl  -0xc(%ebp)
80102200:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102203:	50                   	push   %eax
80102204:	ff 75 08             	pushl  0x8(%ebp)
80102207:	e8 cc fc ff ff       	call   80101ed8 <readi>
8010220c:	83 c4 10             	add    $0x10,%esp
8010220f:	83 f8 10             	cmp    $0x10,%eax
80102212:	74 0d                	je     80102221 <dirlookup+0x4f>
      panic("dirlink read");
80102214:	83 ec 0c             	sub    $0xc,%esp
80102217:	68 55 87 10 80       	push   $0x80108755
8010221c:	e8 45 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102221:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102225:	66 85 c0             	test   %ax,%ax
80102228:	74 47                	je     80102271 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222a:	83 ec 08             	sub    $0x8,%esp
8010222d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102230:	83 c0 02             	add    $0x2,%eax
80102233:	50                   	push   %eax
80102234:	ff 75 0c             	pushl  0xc(%ebp)
80102237:	e8 7b ff ff ff       	call   801021b7 <namecmp>
8010223c:	83 c4 10             	add    $0x10,%esp
8010223f:	85 c0                	test   %eax,%eax
80102241:	75 2f                	jne    80102272 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102243:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102247:	74 08                	je     80102251 <dirlookup+0x7f>
        *poff = off;
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102251:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102255:	0f b7 c0             	movzwl %ax,%eax
80102258:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 00                	mov    (%eax),%eax
80102260:	83 ec 08             	sub    $0x8,%esp
80102263:	ff 75 f0             	pushl  -0x10(%ebp)
80102266:	50                   	push   %eax
80102267:	e8 e5 f5 ff ff       	call   80101851 <iget>
8010226c:	83 c4 10             	add    $0x10,%esp
8010226f:	eb 19                	jmp    8010228a <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102271:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102272:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102276:	8b 45 08             	mov    0x8(%ebp),%eax
80102279:	8b 40 18             	mov    0x18(%eax),%eax
8010227c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010227f:	0f 87 76 ff ff ff    	ja     801021fb <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102285:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228a:	c9                   	leave  
8010228b:	c3                   	ret    

8010228c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228c:	55                   	push   %ebp
8010228d:	89 e5                	mov    %esp,%ebp
8010228f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102292:	83 ec 04             	sub    $0x4,%esp
80102295:	6a 00                	push   $0x0
80102297:	ff 75 0c             	pushl  0xc(%ebp)
8010229a:	ff 75 08             	pushl  0x8(%ebp)
8010229d:	e8 30 ff ff ff       	call   801021d2 <dirlookup>
801022a2:	83 c4 10             	add    $0x10,%esp
801022a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ac:	74 18                	je     801022c6 <dirlink+0x3a>
    iput(ip);
801022ae:	83 ec 0c             	sub    $0xc,%esp
801022b1:	ff 75 f0             	pushl  -0x10(%ebp)
801022b4:	e8 81 f8 ff ff       	call   80101b3a <iput>
801022b9:	83 c4 10             	add    $0x10,%esp
    return -1;
801022bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c1:	e9 9c 00 00 00       	jmp    80102362 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cd:	eb 39                	jmp    80102308 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d2:	6a 10                	push   $0x10
801022d4:	50                   	push   %eax
801022d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d8:	50                   	push   %eax
801022d9:	ff 75 08             	pushl  0x8(%ebp)
801022dc:	e8 f7 fb ff ff       	call   80101ed8 <readi>
801022e1:	83 c4 10             	add    $0x10,%esp
801022e4:	83 f8 10             	cmp    $0x10,%eax
801022e7:	74 0d                	je     801022f6 <dirlink+0x6a>
      panic("dirlink read");
801022e9:	83 ec 0c             	sub    $0xc,%esp
801022ec:	68 55 87 10 80       	push   $0x80108755
801022f1:	e8 70 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fa:	66 85 c0             	test   %ax,%ax
801022fd:	74 18                	je     80102317 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102302:	83 c0 10             	add    $0x10,%eax
80102305:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102308:	8b 45 08             	mov    0x8(%ebp),%eax
8010230b:	8b 50 18             	mov    0x18(%eax),%edx
8010230e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102311:	39 c2                	cmp    %eax,%edx
80102313:	77 ba                	ja     801022cf <dirlink+0x43>
80102315:	eb 01                	jmp    80102318 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102317:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102318:	83 ec 04             	sub    $0x4,%esp
8010231b:	6a 0e                	push   $0xe
8010231d:	ff 75 0c             	pushl  0xc(%ebp)
80102320:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102323:	83 c0 02             	add    $0x2,%eax
80102326:	50                   	push   %eax
80102327:	e8 7b 31 00 00       	call   801054a7 <strncpy>
8010232c:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232f:	8b 45 10             	mov    0x10(%ebp),%eax
80102332:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102339:	6a 10                	push   $0x10
8010233b:	50                   	push   %eax
8010233c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233f:	50                   	push   %eax
80102340:	ff 75 08             	pushl  0x8(%ebp)
80102343:	e8 e7 fc ff ff       	call   8010202f <writei>
80102348:	83 c4 10             	add    $0x10,%esp
8010234b:	83 f8 10             	cmp    $0x10,%eax
8010234e:	74 0d                	je     8010235d <dirlink+0xd1>
    panic("dirlink");
80102350:	83 ec 0c             	sub    $0xc,%esp
80102353:	68 62 87 10 80       	push   $0x80108762
80102358:	e8 09 e2 ff ff       	call   80100566 <panic>
  
  return 0;
8010235d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102362:	c9                   	leave  
80102363:	c3                   	ret    

80102364 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102364:	55                   	push   %ebp
80102365:	89 e5                	mov    %esp,%ebp
80102367:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236a:	eb 04                	jmp    80102370 <skipelem+0xc>
    path++;
8010236c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	0f b6 00             	movzbl (%eax),%eax
80102376:	3c 2f                	cmp    $0x2f,%al
80102378:	74 f2                	je     8010236c <skipelem+0x8>
    path++;
  if(*path == 0)
8010237a:	8b 45 08             	mov    0x8(%ebp),%eax
8010237d:	0f b6 00             	movzbl (%eax),%eax
80102380:	84 c0                	test   %al,%al
80102382:	75 07                	jne    8010238b <skipelem+0x27>
    return 0;
80102384:	b8 00 00 00 00       	mov    $0x0,%eax
80102389:	eb 7b                	jmp    80102406 <skipelem+0xa2>
  s = path;
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102391:	eb 04                	jmp    80102397 <skipelem+0x33>
    path++;
80102393:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102397:	8b 45 08             	mov    0x8(%ebp),%eax
8010239a:	0f b6 00             	movzbl (%eax),%eax
8010239d:	3c 2f                	cmp    $0x2f,%al
8010239f:	74 0a                	je     801023ab <skipelem+0x47>
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	0f b6 00             	movzbl (%eax),%eax
801023a7:	84 c0                	test   %al,%al
801023a9:	75 e8                	jne    80102393 <skipelem+0x2f>
    path++;
  len = path - s;
801023ab:	8b 55 08             	mov    0x8(%ebp),%edx
801023ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b1:	29 c2                	sub    %eax,%edx
801023b3:	89 d0                	mov    %edx,%eax
801023b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b8:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023bc:	7e 15                	jle    801023d3 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023be:	83 ec 04             	sub    $0x4,%esp
801023c1:	6a 0e                	push   $0xe
801023c3:	ff 75 f4             	pushl  -0xc(%ebp)
801023c6:	ff 75 0c             	pushl  0xc(%ebp)
801023c9:	e8 ed 2f 00 00       	call   801053bb <memmove>
801023ce:	83 c4 10             	add    $0x10,%esp
801023d1:	eb 26                	jmp    801023f9 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d6:	83 ec 04             	sub    $0x4,%esp
801023d9:	50                   	push   %eax
801023da:	ff 75 f4             	pushl  -0xc(%ebp)
801023dd:	ff 75 0c             	pushl  0xc(%ebp)
801023e0:	e8 d6 2f 00 00       	call   801053bb <memmove>
801023e5:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ee:	01 d0                	add    %edx,%eax
801023f0:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f3:	eb 04                	jmp    801023f9 <skipelem+0x95>
    path++;
801023f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
801023fc:	0f b6 00             	movzbl (%eax),%eax
801023ff:	3c 2f                	cmp    $0x2f,%al
80102401:	74 f2                	je     801023f5 <skipelem+0x91>
    path++;
  return path;
80102403:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102406:	c9                   	leave  
80102407:	c3                   	ret    

80102408 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102408:	55                   	push   %ebp
80102409:	89 e5                	mov    %esp,%ebp
8010240b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240e:	8b 45 08             	mov    0x8(%ebp),%eax
80102411:	0f b6 00             	movzbl (%eax),%eax
80102414:	3c 2f                	cmp    $0x2f,%al
80102416:	75 17                	jne    8010242f <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102418:	83 ec 08             	sub    $0x8,%esp
8010241b:	6a 01                	push   $0x1
8010241d:	6a 01                	push   $0x1
8010241f:	e8 2d f4 ff ff       	call   80101851 <iget>
80102424:	83 c4 10             	add    $0x10,%esp
80102427:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242a:	e9 bb 00 00 00       	jmp    801024ea <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010242f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102435:	8b 40 68             	mov    0x68(%eax),%eax
80102438:	83 ec 0c             	sub    $0xc,%esp
8010243b:	50                   	push   %eax
8010243c:	e8 ef f4 ff ff       	call   80101930 <idup>
80102441:	83 c4 10             	add    $0x10,%esp
80102444:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102447:	e9 9e 00 00 00       	jmp    801024ea <namex+0xe2>
    ilock(ip);
8010244c:	83 ec 0c             	sub    $0xc,%esp
8010244f:	ff 75 f4             	pushl  -0xc(%ebp)
80102452:	e8 13 f5 ff ff       	call   8010196a <ilock>
80102457:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102461:	66 83 f8 01          	cmp    $0x1,%ax
80102465:	74 18                	je     8010247f <namex+0x77>
      iunlockput(ip);
80102467:	83 ec 0c             	sub    $0xc,%esp
8010246a:	ff 75 f4             	pushl  -0xc(%ebp)
8010246d:	e8 b8 f7 ff ff       	call   80101c2a <iunlockput>
80102472:	83 c4 10             	add    $0x10,%esp
      return 0;
80102475:	b8 00 00 00 00       	mov    $0x0,%eax
8010247a:	e9 a7 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010247f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102483:	74 20                	je     801024a5 <namex+0x9d>
80102485:	8b 45 08             	mov    0x8(%ebp),%eax
80102488:	0f b6 00             	movzbl (%eax),%eax
8010248b:	84 c0                	test   %al,%al
8010248d:	75 16                	jne    801024a5 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010248f:	83 ec 0c             	sub    $0xc,%esp
80102492:	ff 75 f4             	pushl  -0xc(%ebp)
80102495:	e8 2e f6 ff ff       	call   80101ac8 <iunlock>
8010249a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a0:	e9 81 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a5:	83 ec 04             	sub    $0x4,%esp
801024a8:	6a 00                	push   $0x0
801024aa:	ff 75 10             	pushl  0x10(%ebp)
801024ad:	ff 75 f4             	pushl  -0xc(%ebp)
801024b0:	e8 1d fd ff ff       	call   801021d2 <dirlookup>
801024b5:	83 c4 10             	add    $0x10,%esp
801024b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bf:	75 15                	jne    801024d6 <namex+0xce>
      iunlockput(ip);
801024c1:	83 ec 0c             	sub    $0xc,%esp
801024c4:	ff 75 f4             	pushl  -0xc(%ebp)
801024c7:	e8 5e f7 ff ff       	call   80101c2a <iunlockput>
801024cc:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cf:	b8 00 00 00 00       	mov    $0x0,%eax
801024d4:	eb 50                	jmp    80102526 <namex+0x11e>
    }
    iunlockput(ip);
801024d6:	83 ec 0c             	sub    $0xc,%esp
801024d9:	ff 75 f4             	pushl  -0xc(%ebp)
801024dc:	e8 49 f7 ff ff       	call   80101c2a <iunlockput>
801024e1:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024ea:	83 ec 08             	sub    $0x8,%esp
801024ed:	ff 75 10             	pushl  0x10(%ebp)
801024f0:	ff 75 08             	pushl  0x8(%ebp)
801024f3:	e8 6c fe ff ff       	call   80102364 <skipelem>
801024f8:	83 c4 10             	add    $0x10,%esp
801024fb:	89 45 08             	mov    %eax,0x8(%ebp)
801024fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102502:	0f 85 44 ff ff ff    	jne    8010244c <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102508:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250c:	74 15                	je     80102523 <namex+0x11b>
    iput(ip);
8010250e:	83 ec 0c             	sub    $0xc,%esp
80102511:	ff 75 f4             	pushl  -0xc(%ebp)
80102514:	e8 21 f6 ff ff       	call   80101b3a <iput>
80102519:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251c:	b8 00 00 00 00       	mov    $0x0,%eax
80102521:	eb 03                	jmp    80102526 <namex+0x11e>
  }
  return ip;
80102523:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102526:	c9                   	leave  
80102527:	c3                   	ret    

80102528 <namei>:

struct inode*
namei(char *path)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252e:	83 ec 04             	sub    $0x4,%esp
80102531:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102534:	50                   	push   %eax
80102535:	6a 00                	push   $0x0
80102537:	ff 75 08             	pushl  0x8(%ebp)
8010253a:	e8 c9 fe ff ff       	call   80102408 <namex>
8010253f:	83 c4 10             	add    $0x10,%esp
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010254a:	83 ec 04             	sub    $0x4,%esp
8010254d:	ff 75 0c             	pushl  0xc(%ebp)
80102550:	6a 01                	push   $0x1
80102552:	ff 75 08             	pushl  0x8(%ebp)
80102555:	e8 ae fe ff ff       	call   80102408 <namex>
8010255a:	83 c4 10             	add    $0x10,%esp
}
8010255d:	c9                   	leave  
8010255e:	c3                   	ret    

8010255f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010255f:	55                   	push   %ebp
80102560:	89 e5                	mov    %esp,%ebp
80102562:	83 ec 14             	sub    $0x14,%esp
80102565:	8b 45 08             	mov    0x8(%ebp),%eax
80102568:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102570:	89 c2                	mov    %eax,%edx
80102572:	ec                   	in     (%dx),%al
80102573:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102576:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010257a:	c9                   	leave  
8010257b:	c3                   	ret    

8010257c <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010257c:	55                   	push   %ebp
8010257d:	89 e5                	mov    %esp,%ebp
8010257f:	57                   	push   %edi
80102580:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102581:	8b 55 08             	mov    0x8(%ebp),%edx
80102584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102587:	8b 45 10             	mov    0x10(%ebp),%eax
8010258a:	89 cb                	mov    %ecx,%ebx
8010258c:	89 df                	mov    %ebx,%edi
8010258e:	89 c1                	mov    %eax,%ecx
80102590:	fc                   	cld    
80102591:	f3 6d                	rep insl (%dx),%es:(%edi)
80102593:	89 c8                	mov    %ecx,%eax
80102595:	89 fb                	mov    %edi,%ebx
80102597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010259d:	90                   	nop
8010259e:	5b                   	pop    %ebx
8010259f:	5f                   	pop    %edi
801025a0:	5d                   	pop    %ebp
801025a1:	c3                   	ret    

801025a2 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a2:	55                   	push   %ebp
801025a3:	89 e5                	mov    %esp,%ebp
801025a5:	83 ec 08             	sub    $0x8,%esp
801025a8:	8b 55 08             	mov    0x8(%ebp),%edx
801025ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025bd:	ee                   	out    %al,(%dx)
}
801025be:	90                   	nop
801025bf:	c9                   	leave  
801025c0:	c3                   	ret    

801025c1 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025c1:	55                   	push   %ebp
801025c2:	89 e5                	mov    %esp,%ebp
801025c4:	56                   	push   %esi
801025c5:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025c6:	8b 55 08             	mov    0x8(%ebp),%edx
801025c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025cc:	8b 45 10             	mov    0x10(%ebp),%eax
801025cf:	89 cb                	mov    %ecx,%ebx
801025d1:	89 de                	mov    %ebx,%esi
801025d3:	89 c1                	mov    %eax,%ecx
801025d5:	fc                   	cld    
801025d6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d8:	89 c8                	mov    %ecx,%eax
801025da:	89 f3                	mov    %esi,%ebx
801025dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025df:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e2:	90                   	nop
801025e3:	5b                   	pop    %ebx
801025e4:	5e                   	pop    %esi
801025e5:	5d                   	pop    %ebp
801025e6:	c3                   	ret    

801025e7 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025e7:	55                   	push   %ebp
801025e8:	89 e5                	mov    %esp,%ebp
801025ea:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ed:	90                   	nop
801025ee:	68 f7 01 00 00       	push   $0x1f7
801025f3:	e8 67 ff ff ff       	call   8010255f <inb>
801025f8:	83 c4 04             	add    $0x4,%esp
801025fb:	0f b6 c0             	movzbl %al,%eax
801025fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102601:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102604:	25 c0 00 00 00       	and    $0xc0,%eax
80102609:	83 f8 40             	cmp    $0x40,%eax
8010260c:	75 e0                	jne    801025ee <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010260e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102612:	74 11                	je     80102625 <idewait+0x3e>
80102614:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102617:	83 e0 21             	and    $0x21,%eax
8010261a:	85 c0                	test   %eax,%eax
8010261c:	74 07                	je     80102625 <idewait+0x3e>
    return -1;
8010261e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102623:	eb 05                	jmp    8010262a <idewait+0x43>
  return 0;
80102625:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262a:	c9                   	leave  
8010262b:	c3                   	ret    

8010262c <ideinit>:

void
ideinit(void)
{
8010262c:	55                   	push   %ebp
8010262d:	89 e5                	mov    %esp,%ebp
8010262f:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102632:	83 ec 08             	sub    $0x8,%esp
80102635:	68 6a 87 10 80       	push   $0x8010876a
8010263a:	68 00 b6 10 80       	push   $0x8010b600
8010263f:	e8 33 2a 00 00       	call   80105077 <initlock>
80102644:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102647:	83 ec 0c             	sub    $0xc,%esp
8010264a:	6a 0e                	push   $0xe
8010264c:	e8 da 18 00 00       	call   80103f2b <picenable>
80102651:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102654:	a1 40 29 11 80       	mov    0x80112940,%eax
80102659:	83 e8 01             	sub    $0x1,%eax
8010265c:	83 ec 08             	sub    $0x8,%esp
8010265f:	50                   	push   %eax
80102660:	6a 0e                	push   $0xe
80102662:	e8 73 04 00 00       	call   80102ada <ioapicenable>
80102667:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010266a:	83 ec 0c             	sub    $0xc,%esp
8010266d:	6a 00                	push   $0x0
8010266f:	e8 73 ff ff ff       	call   801025e7 <idewait>
80102674:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102677:	83 ec 08             	sub    $0x8,%esp
8010267a:	68 f0 00 00 00       	push   $0xf0
8010267f:	68 f6 01 00 00       	push   $0x1f6
80102684:	e8 19 ff ff ff       	call   801025a2 <outb>
80102689:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010268c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102693:	eb 24                	jmp    801026b9 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102695:	83 ec 0c             	sub    $0xc,%esp
80102698:	68 f7 01 00 00       	push   $0x1f7
8010269d:	e8 bd fe ff ff       	call   8010255f <inb>
801026a2:	83 c4 10             	add    $0x10,%esp
801026a5:	84 c0                	test   %al,%al
801026a7:	74 0c                	je     801026b5 <ideinit+0x89>
      havedisk1 = 1;
801026a9:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801026b0:	00 00 00 
      break;
801026b3:	eb 0d                	jmp    801026c2 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026b9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026c0:	7e d3                	jle    80102695 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026c2:	83 ec 08             	sub    $0x8,%esp
801026c5:	68 e0 00 00 00       	push   $0xe0
801026ca:	68 f6 01 00 00       	push   $0x1f6
801026cf:	e8 ce fe ff ff       	call   801025a2 <outb>
801026d4:	83 c4 10             	add    $0x10,%esp
}
801026d7:	90                   	nop
801026d8:	c9                   	leave  
801026d9:	c3                   	ret    

801026da <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026da:	55                   	push   %ebp
801026db:	89 e5                	mov    %esp,%ebp
801026dd:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e4:	75 0d                	jne    801026f3 <idestart+0x19>
    panic("idestart");
801026e6:	83 ec 0c             	sub    $0xc,%esp
801026e9:	68 6e 87 10 80       	push   $0x8010876e
801026ee:	e8 73 de ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801026f3:	8b 45 08             	mov    0x8(%ebp),%eax
801026f6:	8b 40 08             	mov    0x8(%eax),%eax
801026f9:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026fe:	76 0d                	jbe    8010270d <idestart+0x33>
    panic("incorrect blockno");
80102700:	83 ec 0c             	sub    $0xc,%esp
80102703:	68 77 87 10 80       	push   $0x80108777
80102708:	e8 59 de ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010270d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	8b 50 08             	mov    0x8(%eax),%edx
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	0f af c2             	imul   %edx,%eax
80102720:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102723:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102727:	7e 0d                	jle    80102736 <idestart+0x5c>
80102729:	83 ec 0c             	sub    $0xc,%esp
8010272c:	68 6e 87 10 80       	push   $0x8010876e
80102731:	e8 30 de ff ff       	call   80100566 <panic>
  
  idewait(0);
80102736:	83 ec 0c             	sub    $0xc,%esp
80102739:	6a 00                	push   $0x0
8010273b:	e8 a7 fe ff ff       	call   801025e7 <idewait>
80102740:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102743:	83 ec 08             	sub    $0x8,%esp
80102746:	6a 00                	push   $0x0
80102748:	68 f6 03 00 00       	push   $0x3f6
8010274d:	e8 50 fe ff ff       	call   801025a2 <outb>
80102752:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	0f b6 c0             	movzbl %al,%eax
8010275b:	83 ec 08             	sub    $0x8,%esp
8010275e:	50                   	push   %eax
8010275f:	68 f2 01 00 00       	push   $0x1f2
80102764:	e8 39 fe ff ff       	call   801025a2 <outb>
80102769:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010276c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010276f:	0f b6 c0             	movzbl %al,%eax
80102772:	83 ec 08             	sub    $0x8,%esp
80102775:	50                   	push   %eax
80102776:	68 f3 01 00 00       	push   $0x1f3
8010277b:	e8 22 fe ff ff       	call   801025a2 <outb>
80102780:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102786:	c1 f8 08             	sar    $0x8,%eax
80102789:	0f b6 c0             	movzbl %al,%eax
8010278c:	83 ec 08             	sub    $0x8,%esp
8010278f:	50                   	push   %eax
80102790:	68 f4 01 00 00       	push   $0x1f4
80102795:	e8 08 fe ff ff       	call   801025a2 <outb>
8010279a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010279d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a0:	c1 f8 10             	sar    $0x10,%eax
801027a3:	0f b6 c0             	movzbl %al,%eax
801027a6:	83 ec 08             	sub    $0x8,%esp
801027a9:	50                   	push   %eax
801027aa:	68 f5 01 00 00       	push   $0x1f5
801027af:	e8 ee fd ff ff       	call   801025a2 <outb>
801027b4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027b7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ba:	8b 40 04             	mov    0x4(%eax),%eax
801027bd:	83 e0 01             	and    $0x1,%eax
801027c0:	c1 e0 04             	shl    $0x4,%eax
801027c3:	89 c2                	mov    %eax,%edx
801027c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c8:	c1 f8 18             	sar    $0x18,%eax
801027cb:	83 e0 0f             	and    $0xf,%eax
801027ce:	09 d0                	or     %edx,%eax
801027d0:	83 c8 e0             	or     $0xffffffe0,%eax
801027d3:	0f b6 c0             	movzbl %al,%eax
801027d6:	83 ec 08             	sub    $0x8,%esp
801027d9:	50                   	push   %eax
801027da:	68 f6 01 00 00       	push   $0x1f6
801027df:	e8 be fd ff ff       	call   801025a2 <outb>
801027e4:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027e7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ea:	8b 00                	mov    (%eax),%eax
801027ec:	83 e0 04             	and    $0x4,%eax
801027ef:	85 c0                	test   %eax,%eax
801027f1:	74 30                	je     80102823 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801027f3:	83 ec 08             	sub    $0x8,%esp
801027f6:	6a 30                	push   $0x30
801027f8:	68 f7 01 00 00       	push   $0x1f7
801027fd:	e8 a0 fd ff ff       	call   801025a2 <outb>
80102802:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102805:	8b 45 08             	mov    0x8(%ebp),%eax
80102808:	83 c0 18             	add    $0x18,%eax
8010280b:	83 ec 04             	sub    $0x4,%esp
8010280e:	68 80 00 00 00       	push   $0x80
80102813:	50                   	push   %eax
80102814:	68 f0 01 00 00       	push   $0x1f0
80102819:	e8 a3 fd ff ff       	call   801025c1 <outsl>
8010281e:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102821:	eb 12                	jmp    80102835 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102823:	83 ec 08             	sub    $0x8,%esp
80102826:	6a 20                	push   $0x20
80102828:	68 f7 01 00 00       	push   $0x1f7
8010282d:	e8 70 fd ff ff       	call   801025a2 <outb>
80102832:	83 c4 10             	add    $0x10,%esp
  }
}
80102835:	90                   	nop
80102836:	c9                   	leave  
80102837:	c3                   	ret    

80102838 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102838:	55                   	push   %ebp
80102839:	89 e5                	mov    %esp,%ebp
8010283b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010283e:	83 ec 0c             	sub    $0xc,%esp
80102841:	68 00 b6 10 80       	push   $0x8010b600
80102846:	e8 4e 28 00 00       	call   80105099 <acquire>
8010284b:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010284e:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102853:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102856:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010285a:	75 15                	jne    80102871 <ideintr+0x39>
    release(&idelock);
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 00 b6 10 80       	push   $0x8010b600
80102864:	e8 97 28 00 00       	call   80105100 <release>
80102869:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010286c:	e9 9a 00 00 00       	jmp    8010290b <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102874:	8b 40 14             	mov    0x14(%eax),%eax
80102877:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010287c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287f:	8b 00                	mov    (%eax),%eax
80102881:	83 e0 04             	and    $0x4,%eax
80102884:	85 c0                	test   %eax,%eax
80102886:	75 2d                	jne    801028b5 <ideintr+0x7d>
80102888:	83 ec 0c             	sub    $0xc,%esp
8010288b:	6a 01                	push   $0x1
8010288d:	e8 55 fd ff ff       	call   801025e7 <idewait>
80102892:	83 c4 10             	add    $0x10,%esp
80102895:	85 c0                	test   %eax,%eax
80102897:	78 1c                	js     801028b5 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289c:	83 c0 18             	add    $0x18,%eax
8010289f:	83 ec 04             	sub    $0x4,%esp
801028a2:	68 80 00 00 00       	push   $0x80
801028a7:	50                   	push   %eax
801028a8:	68 f0 01 00 00       	push   $0x1f0
801028ad:	e8 ca fc ff ff       	call   8010257c <insl>
801028b2:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b8:	8b 00                	mov    (%eax),%eax
801028ba:	83 c8 02             	or     $0x2,%eax
801028bd:	89 c2                	mov    %eax,%edx
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c7:	8b 00                	mov    (%eax),%eax
801028c9:	83 e0 fb             	and    $0xfffffffb,%eax
801028cc:	89 c2                	mov    %eax,%edx
801028ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028d3:	83 ec 0c             	sub    $0xc,%esp
801028d6:	ff 75 f4             	pushl  -0xc(%ebp)
801028d9:	e8 a7 25 00 00       	call   80104e85 <wakeup>
801028de:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028e1:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028e6:	85 c0                	test   %eax,%eax
801028e8:	74 11                	je     801028fb <ideintr+0xc3>
    idestart(idequeue);
801028ea:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028ef:	83 ec 0c             	sub    $0xc,%esp
801028f2:	50                   	push   %eax
801028f3:	e8 e2 fd ff ff       	call   801026da <idestart>
801028f8:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028fb:	83 ec 0c             	sub    $0xc,%esp
801028fe:	68 00 b6 10 80       	push   $0x8010b600
80102903:	e8 f8 27 00 00       	call   80105100 <release>
80102908:	83 c4 10             	add    $0x10,%esp
}
8010290b:	c9                   	leave  
8010290c:	c3                   	ret    

8010290d <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010290d:	55                   	push   %ebp
8010290e:	89 e5                	mov    %esp,%ebp
80102910:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102913:	8b 45 08             	mov    0x8(%ebp),%eax
80102916:	8b 00                	mov    (%eax),%eax
80102918:	83 e0 01             	and    $0x1,%eax
8010291b:	85 c0                	test   %eax,%eax
8010291d:	75 0d                	jne    8010292c <iderw+0x1f>
    panic("iderw: buf not busy");
8010291f:	83 ec 0c             	sub    $0xc,%esp
80102922:	68 89 87 10 80       	push   $0x80108789
80102927:	e8 3a dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010292c:	8b 45 08             	mov    0x8(%ebp),%eax
8010292f:	8b 00                	mov    (%eax),%eax
80102931:	83 e0 06             	and    $0x6,%eax
80102934:	83 f8 02             	cmp    $0x2,%eax
80102937:	75 0d                	jne    80102946 <iderw+0x39>
    panic("iderw: nothing to do");
80102939:	83 ec 0c             	sub    $0xc,%esp
8010293c:	68 9d 87 10 80       	push   $0x8010879d
80102941:	e8 20 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102946:	8b 45 08             	mov    0x8(%ebp),%eax
80102949:	8b 40 04             	mov    0x4(%eax),%eax
8010294c:	85 c0                	test   %eax,%eax
8010294e:	74 16                	je     80102966 <iderw+0x59>
80102950:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102955:	85 c0                	test   %eax,%eax
80102957:	75 0d                	jne    80102966 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102959:	83 ec 0c             	sub    $0xc,%esp
8010295c:	68 b2 87 10 80       	push   $0x801087b2
80102961:	e8 00 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102966:	83 ec 0c             	sub    $0xc,%esp
80102969:	68 00 b6 10 80       	push   $0x8010b600
8010296e:	e8 26 27 00 00       	call   80105099 <acquire>
80102973:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102976:	8b 45 08             	mov    0x8(%ebp),%eax
80102979:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102980:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102987:	eb 0b                	jmp    80102994 <iderw+0x87>
80102989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298c:	8b 00                	mov    (%eax),%eax
8010298e:	83 c0 14             	add    $0x14,%eax
80102991:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102997:	8b 00                	mov    (%eax),%eax
80102999:	85 c0                	test   %eax,%eax
8010299b:	75 ec                	jne    80102989 <iderw+0x7c>
    ;
  *pp = b;
8010299d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a0:	8b 55 08             	mov    0x8(%ebp),%edx
801029a3:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029a5:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801029aa:	3b 45 08             	cmp    0x8(%ebp),%eax
801029ad:	75 23                	jne    801029d2 <iderw+0xc5>
    idestart(b);
801029af:	83 ec 0c             	sub    $0xc,%esp
801029b2:	ff 75 08             	pushl  0x8(%ebp)
801029b5:	e8 20 fd ff ff       	call   801026da <idestart>
801029ba:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029bd:	eb 13                	jmp    801029d2 <iderw+0xc5>
    sleep(b, &idelock);
801029bf:	83 ec 08             	sub    $0x8,%esp
801029c2:	68 00 b6 10 80       	push   $0x8010b600
801029c7:	ff 75 08             	pushl  0x8(%ebp)
801029ca:	e8 c8 23 00 00       	call   80104d97 <sleep>
801029cf:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029d2:	8b 45 08             	mov    0x8(%ebp),%eax
801029d5:	8b 00                	mov    (%eax),%eax
801029d7:	83 e0 06             	and    $0x6,%eax
801029da:	83 f8 02             	cmp    $0x2,%eax
801029dd:	75 e0                	jne    801029bf <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801029df:	83 ec 0c             	sub    $0xc,%esp
801029e2:	68 00 b6 10 80       	push   $0x8010b600
801029e7:	e8 14 27 00 00       	call   80105100 <release>
801029ec:	83 c4 10             	add    $0x10,%esp
}
801029ef:	90                   	nop
801029f0:	c9                   	leave  
801029f1:	c3                   	ret    

801029f2 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029f2:	55                   	push   %ebp
801029f3:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f5:	a1 14 22 11 80       	mov    0x80112214,%eax
801029fa:	8b 55 08             	mov    0x8(%ebp),%edx
801029fd:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029ff:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a04:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a07:	5d                   	pop    %ebp
80102a08:	c3                   	ret    

80102a09 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a09:	55                   	push   %ebp
80102a0a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a0c:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a11:	8b 55 08             	mov    0x8(%ebp),%edx
80102a14:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a16:	a1 14 22 11 80       	mov    0x80112214,%eax
80102a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a1e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a21:	90                   	nop
80102a22:	5d                   	pop    %ebp
80102a23:	c3                   	ret    

80102a24 <ioapicinit>:

void
ioapicinit(void)
{
80102a24:	55                   	push   %ebp
80102a25:	89 e5                	mov    %esp,%ebp
80102a27:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a2a:	a1 44 23 11 80       	mov    0x80112344,%eax
80102a2f:	85 c0                	test   %eax,%eax
80102a31:	0f 84 a0 00 00 00    	je     80102ad7 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a37:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
80102a3e:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a41:	6a 01                	push   $0x1
80102a43:	e8 aa ff ff ff       	call   801029f2 <ioapicread>
80102a48:	83 c4 04             	add    $0x4,%esp
80102a4b:	c1 e8 10             	shr    $0x10,%eax
80102a4e:	25 ff 00 00 00       	and    $0xff,%eax
80102a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a56:	6a 00                	push   $0x0
80102a58:	e8 95 ff ff ff       	call   801029f2 <ioapicread>
80102a5d:	83 c4 04             	add    $0x4,%esp
80102a60:	c1 e8 18             	shr    $0x18,%eax
80102a63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a66:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
80102a6d:	0f b6 c0             	movzbl %al,%eax
80102a70:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a73:	74 10                	je     80102a85 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a75:	83 ec 0c             	sub    $0xc,%esp
80102a78:	68 d0 87 10 80       	push   $0x801087d0
80102a7d:	e8 44 d9 ff ff       	call   801003c6 <cprintf>
80102a82:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a8c:	eb 3f                	jmp    80102acd <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a91:	83 c0 20             	add    $0x20,%eax
80102a94:	0d 00 00 01 00       	or     $0x10000,%eax
80102a99:	89 c2                	mov    %eax,%edx
80102a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9e:	83 c0 08             	add    $0x8,%eax
80102aa1:	01 c0                	add    %eax,%eax
80102aa3:	83 ec 08             	sub    $0x8,%esp
80102aa6:	52                   	push   %edx
80102aa7:	50                   	push   %eax
80102aa8:	e8 5c ff ff ff       	call   80102a09 <ioapicwrite>
80102aad:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab3:	83 c0 08             	add    $0x8,%eax
80102ab6:	01 c0                	add    %eax,%eax
80102ab8:	83 c0 01             	add    $0x1,%eax
80102abb:	83 ec 08             	sub    $0x8,%esp
80102abe:	6a 00                	push   $0x0
80102ac0:	50                   	push   %eax
80102ac1:	e8 43 ff ff ff       	call   80102a09 <ioapicwrite>
80102ac6:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ac9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ad3:	7e b9                	jle    80102a8e <ioapicinit+0x6a>
80102ad5:	eb 01                	jmp    80102ad8 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ad7:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ad8:	c9                   	leave  
80102ad9:	c3                   	ret    

80102ada <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ada:	55                   	push   %ebp
80102adb:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102add:	a1 44 23 11 80       	mov    0x80112344,%eax
80102ae2:	85 c0                	test   %eax,%eax
80102ae4:	74 39                	je     80102b1f <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae9:	83 c0 20             	add    $0x20,%eax
80102aec:	89 c2                	mov    %eax,%edx
80102aee:	8b 45 08             	mov    0x8(%ebp),%eax
80102af1:	83 c0 08             	add    $0x8,%eax
80102af4:	01 c0                	add    %eax,%eax
80102af6:	52                   	push   %edx
80102af7:	50                   	push   %eax
80102af8:	e8 0c ff ff ff       	call   80102a09 <ioapicwrite>
80102afd:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b00:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b03:	c1 e0 18             	shl    $0x18,%eax
80102b06:	89 c2                	mov    %eax,%edx
80102b08:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0b:	83 c0 08             	add    $0x8,%eax
80102b0e:	01 c0                	add    %eax,%eax
80102b10:	83 c0 01             	add    $0x1,%eax
80102b13:	52                   	push   %edx
80102b14:	50                   	push   %eax
80102b15:	e8 ef fe ff ff       	call   80102a09 <ioapicwrite>
80102b1a:	83 c4 08             	add    $0x8,%esp
80102b1d:	eb 01                	jmp    80102b20 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102b1f:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102b20:	c9                   	leave  
80102b21:	c3                   	ret    

80102b22 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b22:	55                   	push   %ebp
80102b23:	89 e5                	mov    %esp,%ebp
80102b25:	8b 45 08             	mov    0x8(%ebp),%eax
80102b28:	05 00 00 00 80       	add    $0x80000000,%eax
80102b2d:	5d                   	pop    %ebp
80102b2e:	c3                   	ret    

80102b2f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b35:	83 ec 08             	sub    $0x8,%esp
80102b38:	68 02 88 10 80       	push   $0x80108802
80102b3d:	68 20 22 11 80       	push   $0x80112220
80102b42:	e8 30 25 00 00       	call   80105077 <initlock>
80102b47:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b4a:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
80102b51:	00 00 00 
  freerange(vstart, vend);
80102b54:	83 ec 08             	sub    $0x8,%esp
80102b57:	ff 75 0c             	pushl  0xc(%ebp)
80102b5a:	ff 75 08             	pushl  0x8(%ebp)
80102b5d:	e8 2a 00 00 00       	call   80102b8c <freerange>
80102b62:	83 c4 10             	add    $0x10,%esp
}
80102b65:	90                   	nop
80102b66:	c9                   	leave  
80102b67:	c3                   	ret    

80102b68 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b68:	55                   	push   %ebp
80102b69:	89 e5                	mov    %esp,%ebp
80102b6b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b6e:	83 ec 08             	sub    $0x8,%esp
80102b71:	ff 75 0c             	pushl  0xc(%ebp)
80102b74:	ff 75 08             	pushl  0x8(%ebp)
80102b77:	e8 10 00 00 00       	call   80102b8c <freerange>
80102b7c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b7f:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102b86:	00 00 00 
}
80102b89:	90                   	nop
80102b8a:	c9                   	leave  
80102b8b:	c3                   	ret    

80102b8c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b8c:	55                   	push   %ebp
80102b8d:	89 e5                	mov    %esp,%ebp
80102b8f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b92:	8b 45 08             	mov    0x8(%ebp),%eax
80102b95:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ba2:	eb 15                	jmp    80102bb9 <freerange+0x2d>
    kfree(p);
80102ba4:	83 ec 0c             	sub    $0xc,%esp
80102ba7:	ff 75 f4             	pushl  -0xc(%ebp)
80102baa:	e8 1a 00 00 00       	call   80102bc9 <kfree>
80102baf:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbc:	05 00 10 00 00       	add    $0x1000,%eax
80102bc1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bc4:	76 de                	jbe    80102ba4 <freerange+0x18>
    kfree(p);
}
80102bc6:	90                   	nop
80102bc7:	c9                   	leave  
80102bc8:	c3                   	ret    

80102bc9 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bc9:	55                   	push   %ebp
80102bca:	89 e5                	mov    %esp,%ebp
80102bcc:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bd7:	85 c0                	test   %eax,%eax
80102bd9:	75 1b                	jne    80102bf6 <kfree+0x2d>
80102bdb:	81 7d 08 3c 54 11 80 	cmpl   $0x8011543c,0x8(%ebp)
80102be2:	72 12                	jb     80102bf6 <kfree+0x2d>
80102be4:	ff 75 08             	pushl  0x8(%ebp)
80102be7:	e8 36 ff ff ff       	call   80102b22 <v2p>
80102bec:	83 c4 04             	add    $0x4,%esp
80102bef:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bf4:	76 0d                	jbe    80102c03 <kfree+0x3a>
    panic("kfree");
80102bf6:	83 ec 0c             	sub    $0xc,%esp
80102bf9:	68 07 88 10 80       	push   $0x80108807
80102bfe:	e8 63 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c03:	83 ec 04             	sub    $0x4,%esp
80102c06:	68 00 10 00 00       	push   $0x1000
80102c0b:	6a 01                	push   $0x1
80102c0d:	ff 75 08             	pushl  0x8(%ebp)
80102c10:	e8 e7 26 00 00       	call   801052fc <memset>
80102c15:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c18:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c1d:	85 c0                	test   %eax,%eax
80102c1f:	74 10                	je     80102c31 <kfree+0x68>
    acquire(&kmem.lock);
80102c21:	83 ec 0c             	sub    $0xc,%esp
80102c24:	68 20 22 11 80       	push   $0x80112220
80102c29:	e8 6b 24 00 00       	call   80105099 <acquire>
80102c2e:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c31:	8b 45 08             	mov    0x8(%ebp),%eax
80102c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c37:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c40:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c45:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102c4a:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c4f:	85 c0                	test   %eax,%eax
80102c51:	74 10                	je     80102c63 <kfree+0x9a>
    release(&kmem.lock);
80102c53:	83 ec 0c             	sub    $0xc,%esp
80102c56:	68 20 22 11 80       	push   $0x80112220
80102c5b:	e8 a0 24 00 00       	call   80105100 <release>
80102c60:	83 c4 10             	add    $0x10,%esp
}
80102c63:	90                   	nop
80102c64:	c9                   	leave  
80102c65:	c3                   	ret    

80102c66 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c66:	55                   	push   %ebp
80102c67:	89 e5                	mov    %esp,%ebp
80102c69:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c6c:	a1 54 22 11 80       	mov    0x80112254,%eax
80102c71:	85 c0                	test   %eax,%eax
80102c73:	74 10                	je     80102c85 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c75:	83 ec 0c             	sub    $0xc,%esp
80102c78:	68 20 22 11 80       	push   $0x80112220
80102c7d:	e8 17 24 00 00       	call   80105099 <acquire>
80102c82:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c85:	a1 58 22 11 80       	mov    0x80112258,%eax
80102c8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c91:	74 0a                	je     80102c9d <kalloc+0x37>
    kmem.freelist = r->next;
80102c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c96:	8b 00                	mov    (%eax),%eax
80102c98:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102c9d:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ca2:	85 c0                	test   %eax,%eax
80102ca4:	74 10                	je     80102cb6 <kalloc+0x50>
    release(&kmem.lock);
80102ca6:	83 ec 0c             	sub    $0xc,%esp
80102ca9:	68 20 22 11 80       	push   $0x80112220
80102cae:	e8 4d 24 00 00       	call   80105100 <release>
80102cb3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cb9:	c9                   	leave  
80102cba:	c3                   	ret    

80102cbb <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102cbb:	55                   	push   %ebp
80102cbc:	89 e5                	mov    %esp,%ebp
80102cbe:	83 ec 14             	sub    $0x14,%esp
80102cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ccc:	89 c2                	mov    %eax,%edx
80102cce:	ec                   	in     (%dx),%al
80102ccf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cd2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cd6:	c9                   	leave  
80102cd7:	c3                   	ret    

80102cd8 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cd8:	55                   	push   %ebp
80102cd9:	89 e5                	mov    %esp,%ebp
80102cdb:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cde:	6a 64                	push   $0x64
80102ce0:	e8 d6 ff ff ff       	call   80102cbb <inb>
80102ce5:	83 c4 04             	add    $0x4,%esp
80102ce8:	0f b6 c0             	movzbl %al,%eax
80102ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf1:	83 e0 01             	and    $0x1,%eax
80102cf4:	85 c0                	test   %eax,%eax
80102cf6:	75 0a                	jne    80102d02 <kbdgetc+0x2a>
    return -1;
80102cf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cfd:	e9 23 01 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d02:	6a 60                	push   $0x60
80102d04:	e8 b2 ff ff ff       	call   80102cbb <inb>
80102d09:	83 c4 04             	add    $0x4,%esp
80102d0c:	0f b6 c0             	movzbl %al,%eax
80102d0f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d12:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d19:	75 17                	jne    80102d32 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d1b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d20:	83 c8 40             	or     $0x40,%eax
80102d23:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d28:	b8 00 00 00 00       	mov    $0x0,%eax
80102d2d:	e9 f3 00 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d35:	25 80 00 00 00       	and    $0x80,%eax
80102d3a:	85 c0                	test   %eax,%eax
80102d3c:	74 45                	je     80102d83 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d3e:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d43:	83 e0 40             	and    $0x40,%eax
80102d46:	85 c0                	test   %eax,%eax
80102d48:	75 08                	jne    80102d52 <kbdgetc+0x7a>
80102d4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d4d:	83 e0 7f             	and    $0x7f,%eax
80102d50:	eb 03                	jmp    80102d55 <kbdgetc+0x7d>
80102d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d55:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5b:	05 20 90 10 80       	add    $0x80109020,%eax
80102d60:	0f b6 00             	movzbl (%eax),%eax
80102d63:	83 c8 40             	or     $0x40,%eax
80102d66:	0f b6 c0             	movzbl %al,%eax
80102d69:	f7 d0                	not    %eax
80102d6b:	89 c2                	mov    %eax,%edx
80102d6d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d72:	21 d0                	and    %edx,%eax
80102d74:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d79:	b8 00 00 00 00       	mov    $0x0,%eax
80102d7e:	e9 a2 00 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d83:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d88:	83 e0 40             	and    $0x40,%eax
80102d8b:	85 c0                	test   %eax,%eax
80102d8d:	74 14                	je     80102da3 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d8f:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d96:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d9b:	83 e0 bf             	and    $0xffffffbf,%eax
80102d9e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102da3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da6:	05 20 90 10 80       	add    $0x80109020,%eax
80102dab:	0f b6 00             	movzbl (%eax),%eax
80102dae:	0f b6 d0             	movzbl %al,%edx
80102db1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102db6:	09 d0                	or     %edx,%eax
80102db8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102dbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc0:	05 20 91 10 80       	add    $0x80109120,%eax
80102dc5:	0f b6 00             	movzbl (%eax),%eax
80102dc8:	0f b6 d0             	movzbl %al,%edx
80102dcb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dd0:	31 d0                	xor    %edx,%eax
80102dd2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dd7:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ddc:	83 e0 03             	and    $0x3,%eax
80102ddf:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102de6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de9:	01 d0                	add    %edx,%eax
80102deb:	0f b6 00             	movzbl (%eax),%eax
80102dee:	0f b6 c0             	movzbl %al,%eax
80102df1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102df4:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102df9:	83 e0 08             	and    $0x8,%eax
80102dfc:	85 c0                	test   %eax,%eax
80102dfe:	74 22                	je     80102e22 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e00:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e04:	76 0c                	jbe    80102e12 <kbdgetc+0x13a>
80102e06:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e0a:	77 06                	ja     80102e12 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e0c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e10:	eb 10                	jmp    80102e22 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e12:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e16:	76 0a                	jbe    80102e22 <kbdgetc+0x14a>
80102e18:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e1c:	77 04                	ja     80102e22 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e1e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e25:	c9                   	leave  
80102e26:	c3                   	ret    

80102e27 <kbdintr>:

void
kbdintr(void)
{
80102e27:	55                   	push   %ebp
80102e28:	89 e5                	mov    %esp,%ebp
80102e2a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e2d:	83 ec 0c             	sub    $0xc,%esp
80102e30:	68 d8 2c 10 80       	push   $0x80102cd8
80102e35:	e8 bf d9 ff ff       	call   801007f9 <consoleintr>
80102e3a:	83 c4 10             	add    $0x10,%esp
}
80102e3d:	90                   	nop
80102e3e:	c9                   	leave  
80102e3f:	c3                   	ret    

80102e40 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e40:	55                   	push   %ebp
80102e41:	89 e5                	mov    %esp,%ebp
80102e43:	83 ec 14             	sub    $0x14,%esp
80102e46:	8b 45 08             	mov    0x8(%ebp),%eax
80102e49:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e4d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e51:	89 c2                	mov    %eax,%edx
80102e53:	ec                   	in     (%dx),%al
80102e54:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e57:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e5b:	c9                   	leave  
80102e5c:	c3                   	ret    

80102e5d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e5d:	55                   	push   %ebp
80102e5e:	89 e5                	mov    %esp,%ebp
80102e60:	83 ec 08             	sub    $0x8,%esp
80102e63:	8b 55 08             	mov    0x8(%ebp),%edx
80102e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e69:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e6d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e70:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e74:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e78:	ee                   	out    %al,(%dx)
}
80102e79:	90                   	nop
80102e7a:	c9                   	leave  
80102e7b:	c3                   	ret    

80102e7c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e82:	9c                   	pushf  
80102e83:	58                   	pop    %eax
80102e84:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e87:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e8a:	c9                   	leave  
80102e8b:	c3                   	ret    

80102e8c <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e8c:	55                   	push   %ebp
80102e8d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e8f:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e94:	8b 55 08             	mov    0x8(%ebp),%edx
80102e97:	c1 e2 02             	shl    $0x2,%edx
80102e9a:	01 c2                	add    %eax,%edx
80102e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e9f:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ea1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102ea6:	83 c0 20             	add    $0x20,%eax
80102ea9:	8b 00                	mov    (%eax),%eax
}
80102eab:	90                   	nop
80102eac:	5d                   	pop    %ebp
80102ead:	c3                   	ret    

80102eae <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102eb1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	0f 84 0b 01 00 00    	je     80102fc9 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ebe:	68 3f 01 00 00       	push   $0x13f
80102ec3:	6a 3c                	push   $0x3c
80102ec5:	e8 c2 ff ff ff       	call   80102e8c <lapicw>
80102eca:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ecd:	6a 0b                	push   $0xb
80102ecf:	68 f8 00 00 00       	push   $0xf8
80102ed4:	e8 b3 ff ff ff       	call   80102e8c <lapicw>
80102ed9:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102edc:	68 20 00 02 00       	push   $0x20020
80102ee1:	68 c8 00 00 00       	push   $0xc8
80102ee6:	e8 a1 ff ff ff       	call   80102e8c <lapicw>
80102eeb:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102eee:	68 80 96 98 00       	push   $0x989680
80102ef3:	68 e0 00 00 00       	push   $0xe0
80102ef8:	e8 8f ff ff ff       	call   80102e8c <lapicw>
80102efd:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f00:	68 00 00 01 00       	push   $0x10000
80102f05:	68 d4 00 00 00       	push   $0xd4
80102f0a:	e8 7d ff ff ff       	call   80102e8c <lapicw>
80102f0f:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f12:	68 00 00 01 00       	push   $0x10000
80102f17:	68 d8 00 00 00       	push   $0xd8
80102f1c:	e8 6b ff ff ff       	call   80102e8c <lapicw>
80102f21:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f24:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f29:	83 c0 30             	add    $0x30,%eax
80102f2c:	8b 00                	mov    (%eax),%eax
80102f2e:	c1 e8 10             	shr    $0x10,%eax
80102f31:	0f b6 c0             	movzbl %al,%eax
80102f34:	83 f8 03             	cmp    $0x3,%eax
80102f37:	76 12                	jbe    80102f4b <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f39:	68 00 00 01 00       	push   $0x10000
80102f3e:	68 d0 00 00 00       	push   $0xd0
80102f43:	e8 44 ff ff ff       	call   80102e8c <lapicw>
80102f48:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f4b:	6a 33                	push   $0x33
80102f4d:	68 dc 00 00 00       	push   $0xdc
80102f52:	e8 35 ff ff ff       	call   80102e8c <lapicw>
80102f57:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f5a:	6a 00                	push   $0x0
80102f5c:	68 a0 00 00 00       	push   $0xa0
80102f61:	e8 26 ff ff ff       	call   80102e8c <lapicw>
80102f66:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f69:	6a 00                	push   $0x0
80102f6b:	68 a0 00 00 00       	push   $0xa0
80102f70:	e8 17 ff ff ff       	call   80102e8c <lapicw>
80102f75:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f78:	6a 00                	push   $0x0
80102f7a:	6a 2c                	push   $0x2c
80102f7c:	e8 0b ff ff ff       	call   80102e8c <lapicw>
80102f81:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f84:	6a 00                	push   $0x0
80102f86:	68 c4 00 00 00       	push   $0xc4
80102f8b:	e8 fc fe ff ff       	call   80102e8c <lapicw>
80102f90:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f93:	68 00 85 08 00       	push   $0x88500
80102f98:	68 c0 00 00 00       	push   $0xc0
80102f9d:	e8 ea fe ff ff       	call   80102e8c <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fa5:	90                   	nop
80102fa6:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102fab:	05 00 03 00 00       	add    $0x300,%eax
80102fb0:	8b 00                	mov    (%eax),%eax
80102fb2:	25 00 10 00 00       	and    $0x1000,%eax
80102fb7:	85 c0                	test   %eax,%eax
80102fb9:	75 eb                	jne    80102fa6 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fbb:	6a 00                	push   $0x0
80102fbd:	6a 20                	push   $0x20
80102fbf:	e8 c8 fe ff ff       	call   80102e8c <lapicw>
80102fc4:	83 c4 08             	add    $0x8,%esp
80102fc7:	eb 01                	jmp    80102fca <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102fc9:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102fca:	c9                   	leave  
80102fcb:	c3                   	ret    

80102fcc <cpunum>:

int
cpunum(void)
{
80102fcc:	55                   	push   %ebp
80102fcd:	89 e5                	mov    %esp,%ebp
80102fcf:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fd2:	e8 a5 fe ff ff       	call   80102e7c <readeflags>
80102fd7:	25 00 02 00 00       	and    $0x200,%eax
80102fdc:	85 c0                	test   %eax,%eax
80102fde:	74 26                	je     80103006 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fe0:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102fe5:	8d 50 01             	lea    0x1(%eax),%edx
80102fe8:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102fee:	85 c0                	test   %eax,%eax
80102ff0:	75 14                	jne    80103006 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ff2:	8b 45 04             	mov    0x4(%ebp),%eax
80102ff5:	83 ec 08             	sub    $0x8,%esp
80102ff8:	50                   	push   %eax
80102ff9:	68 10 88 10 80       	push   $0x80108810
80102ffe:	e8 c3 d3 ff ff       	call   801003c6 <cprintf>
80103003:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103006:	a1 5c 22 11 80       	mov    0x8011225c,%eax
8010300b:	85 c0                	test   %eax,%eax
8010300d:	74 0f                	je     8010301e <cpunum+0x52>
    return lapic[ID]>>24;
8010300f:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80103014:	83 c0 20             	add    $0x20,%eax
80103017:	8b 00                	mov    (%eax),%eax
80103019:	c1 e8 18             	shr    $0x18,%eax
8010301c:	eb 05                	jmp    80103023 <cpunum+0x57>
  return 0;
8010301e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103023:	c9                   	leave  
80103024:	c3                   	ret    

80103025 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103025:	55                   	push   %ebp
80103026:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103028:	a1 5c 22 11 80       	mov    0x8011225c,%eax
8010302d:	85 c0                	test   %eax,%eax
8010302f:	74 0c                	je     8010303d <lapiceoi+0x18>
    lapicw(EOI, 0);
80103031:	6a 00                	push   $0x0
80103033:	6a 2c                	push   $0x2c
80103035:	e8 52 fe ff ff       	call   80102e8c <lapicw>
8010303a:	83 c4 08             	add    $0x8,%esp
}
8010303d:	90                   	nop
8010303e:	c9                   	leave  
8010303f:	c3                   	ret    

80103040 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103040:	55                   	push   %ebp
80103041:	89 e5                	mov    %esp,%ebp
}
80103043:	90                   	nop
80103044:	5d                   	pop    %ebp
80103045:	c3                   	ret    

80103046 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103046:	55                   	push   %ebp
80103047:	89 e5                	mov    %esp,%ebp
80103049:	83 ec 14             	sub    $0x14,%esp
8010304c:	8b 45 08             	mov    0x8(%ebp),%eax
8010304f:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103052:	6a 0f                	push   $0xf
80103054:	6a 70                	push   $0x70
80103056:	e8 02 fe ff ff       	call   80102e5d <outb>
8010305b:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010305e:	6a 0a                	push   $0xa
80103060:	6a 71                	push   $0x71
80103062:	e8 f6 fd ff ff       	call   80102e5d <outb>
80103067:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010306a:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103071:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103074:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103079:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010307c:	83 c0 02             	add    $0x2,%eax
8010307f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103082:	c1 ea 04             	shr    $0x4,%edx
80103085:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103088:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010308c:	c1 e0 18             	shl    $0x18,%eax
8010308f:	50                   	push   %eax
80103090:	68 c4 00 00 00       	push   $0xc4
80103095:	e8 f2 fd ff ff       	call   80102e8c <lapicw>
8010309a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010309d:	68 00 c5 00 00       	push   $0xc500
801030a2:	68 c0 00 00 00       	push   $0xc0
801030a7:	e8 e0 fd ff ff       	call   80102e8c <lapicw>
801030ac:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030af:	68 c8 00 00 00       	push   $0xc8
801030b4:	e8 87 ff ff ff       	call   80103040 <microdelay>
801030b9:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030bc:	68 00 85 00 00       	push   $0x8500
801030c1:	68 c0 00 00 00       	push   $0xc0
801030c6:	e8 c1 fd ff ff       	call   80102e8c <lapicw>
801030cb:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ce:	6a 64                	push   $0x64
801030d0:	e8 6b ff ff ff       	call   80103040 <microdelay>
801030d5:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030df:	eb 3d                	jmp    8010311e <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030e1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030e5:	c1 e0 18             	shl    $0x18,%eax
801030e8:	50                   	push   %eax
801030e9:	68 c4 00 00 00       	push   $0xc4
801030ee:	e8 99 fd ff ff       	call   80102e8c <lapicw>
801030f3:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801030f9:	c1 e8 0c             	shr    $0xc,%eax
801030fc:	80 cc 06             	or     $0x6,%ah
801030ff:	50                   	push   %eax
80103100:	68 c0 00 00 00       	push   $0xc0
80103105:	e8 82 fd ff ff       	call   80102e8c <lapicw>
8010310a:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010310d:	68 c8 00 00 00       	push   $0xc8
80103112:	e8 29 ff ff ff       	call   80103040 <microdelay>
80103117:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010311a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010311e:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103122:	7e bd                	jle    801030e1 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103124:	90                   	nop
80103125:	c9                   	leave  
80103126:	c3                   	ret    

80103127 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103127:	55                   	push   %ebp
80103128:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010312a:	8b 45 08             	mov    0x8(%ebp),%eax
8010312d:	0f b6 c0             	movzbl %al,%eax
80103130:	50                   	push   %eax
80103131:	6a 70                	push   $0x70
80103133:	e8 25 fd ff ff       	call   80102e5d <outb>
80103138:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010313b:	68 c8 00 00 00       	push   $0xc8
80103140:	e8 fb fe ff ff       	call   80103040 <microdelay>
80103145:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103148:	6a 71                	push   $0x71
8010314a:	e8 f1 fc ff ff       	call   80102e40 <inb>
8010314f:	83 c4 04             	add    $0x4,%esp
80103152:	0f b6 c0             	movzbl %al,%eax
}
80103155:	c9                   	leave  
80103156:	c3                   	ret    

80103157 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103157:	55                   	push   %ebp
80103158:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010315a:	6a 00                	push   $0x0
8010315c:	e8 c6 ff ff ff       	call   80103127 <cmos_read>
80103161:	83 c4 04             	add    $0x4,%esp
80103164:	89 c2                	mov    %eax,%edx
80103166:	8b 45 08             	mov    0x8(%ebp),%eax
80103169:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010316b:	6a 02                	push   $0x2
8010316d:	e8 b5 ff ff ff       	call   80103127 <cmos_read>
80103172:	83 c4 04             	add    $0x4,%esp
80103175:	89 c2                	mov    %eax,%edx
80103177:	8b 45 08             	mov    0x8(%ebp),%eax
8010317a:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010317d:	6a 04                	push   $0x4
8010317f:	e8 a3 ff ff ff       	call   80103127 <cmos_read>
80103184:	83 c4 04             	add    $0x4,%esp
80103187:	89 c2                	mov    %eax,%edx
80103189:	8b 45 08             	mov    0x8(%ebp),%eax
8010318c:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010318f:	6a 07                	push   $0x7
80103191:	e8 91 ff ff ff       	call   80103127 <cmos_read>
80103196:	83 c4 04             	add    $0x4,%esp
80103199:	89 c2                	mov    %eax,%edx
8010319b:	8b 45 08             	mov    0x8(%ebp),%eax
8010319e:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031a1:	6a 08                	push   $0x8
801031a3:	e8 7f ff ff ff       	call   80103127 <cmos_read>
801031a8:	83 c4 04             	add    $0x4,%esp
801031ab:	89 c2                	mov    %eax,%edx
801031ad:	8b 45 08             	mov    0x8(%ebp),%eax
801031b0:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031b3:	6a 09                	push   $0x9
801031b5:	e8 6d ff ff ff       	call   80103127 <cmos_read>
801031ba:	83 c4 04             	add    $0x4,%esp
801031bd:	89 c2                	mov    %eax,%edx
801031bf:	8b 45 08             	mov    0x8(%ebp),%eax
801031c2:	89 50 14             	mov    %edx,0x14(%eax)
}
801031c5:	90                   	nop
801031c6:	c9                   	leave  
801031c7:	c3                   	ret    

801031c8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031c8:	55                   	push   %ebp
801031c9:	89 e5                	mov    %esp,%ebp
801031cb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031ce:	6a 0b                	push   $0xb
801031d0:	e8 52 ff ff ff       	call   80103127 <cmos_read>
801031d5:	83 c4 04             	add    $0x4,%esp
801031d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031de:	83 e0 04             	and    $0x4,%eax
801031e1:	85 c0                	test   %eax,%eax
801031e3:	0f 94 c0             	sete   %al
801031e6:	0f b6 c0             	movzbl %al,%eax
801031e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031ef:	50                   	push   %eax
801031f0:	e8 62 ff ff ff       	call   80103157 <fill_rtcdate>
801031f5:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031f8:	6a 0a                	push   $0xa
801031fa:	e8 28 ff ff ff       	call   80103127 <cmos_read>
801031ff:	83 c4 04             	add    $0x4,%esp
80103202:	25 80 00 00 00       	and    $0x80,%eax
80103207:	85 c0                	test   %eax,%eax
80103209:	75 27                	jne    80103232 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010320b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010320e:	50                   	push   %eax
8010320f:	e8 43 ff ff ff       	call   80103157 <fill_rtcdate>
80103214:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103217:	83 ec 04             	sub    $0x4,%esp
8010321a:	6a 18                	push   $0x18
8010321c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010321f:	50                   	push   %eax
80103220:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103223:	50                   	push   %eax
80103224:	e8 3a 21 00 00       	call   80105363 <memcmp>
80103229:	83 c4 10             	add    $0x10,%esp
8010322c:	85 c0                	test   %eax,%eax
8010322e:	74 05                	je     80103235 <cmostime+0x6d>
80103230:	eb ba                	jmp    801031ec <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103232:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103233:	eb b7                	jmp    801031ec <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103235:	90                   	nop
  }

  // convert
  if (bcd) {
80103236:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010323a:	0f 84 b4 00 00 00    	je     801032f4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103240:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103243:	c1 e8 04             	shr    $0x4,%eax
80103246:	89 c2                	mov    %eax,%edx
80103248:	89 d0                	mov    %edx,%eax
8010324a:	c1 e0 02             	shl    $0x2,%eax
8010324d:	01 d0                	add    %edx,%eax
8010324f:	01 c0                	add    %eax,%eax
80103251:	89 c2                	mov    %eax,%edx
80103253:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103256:	83 e0 0f             	and    $0xf,%eax
80103259:	01 d0                	add    %edx,%eax
8010325b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010325e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103261:	c1 e8 04             	shr    $0x4,%eax
80103264:	89 c2                	mov    %eax,%edx
80103266:	89 d0                	mov    %edx,%eax
80103268:	c1 e0 02             	shl    $0x2,%eax
8010326b:	01 d0                	add    %edx,%eax
8010326d:	01 c0                	add    %eax,%eax
8010326f:	89 c2                	mov    %eax,%edx
80103271:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103274:	83 e0 0f             	and    $0xf,%eax
80103277:	01 d0                	add    %edx,%eax
80103279:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010327c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010327f:	c1 e8 04             	shr    $0x4,%eax
80103282:	89 c2                	mov    %eax,%edx
80103284:	89 d0                	mov    %edx,%eax
80103286:	c1 e0 02             	shl    $0x2,%eax
80103289:	01 d0                	add    %edx,%eax
8010328b:	01 c0                	add    %eax,%eax
8010328d:	89 c2                	mov    %eax,%edx
8010328f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103292:	83 e0 0f             	and    $0xf,%eax
80103295:	01 d0                	add    %edx,%eax
80103297:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010329a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010329d:	c1 e8 04             	shr    $0x4,%eax
801032a0:	89 c2                	mov    %eax,%edx
801032a2:	89 d0                	mov    %edx,%eax
801032a4:	c1 e0 02             	shl    $0x2,%eax
801032a7:	01 d0                	add    %edx,%eax
801032a9:	01 c0                	add    %eax,%eax
801032ab:	89 c2                	mov    %eax,%edx
801032ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b0:	83 e0 0f             	and    $0xf,%eax
801032b3:	01 d0                	add    %edx,%eax
801032b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032bb:	c1 e8 04             	shr    $0x4,%eax
801032be:	89 c2                	mov    %eax,%edx
801032c0:	89 d0                	mov    %edx,%eax
801032c2:	c1 e0 02             	shl    $0x2,%eax
801032c5:	01 d0                	add    %edx,%eax
801032c7:	01 c0                	add    %eax,%eax
801032c9:	89 c2                	mov    %eax,%edx
801032cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ce:	83 e0 0f             	and    $0xf,%eax
801032d1:	01 d0                	add    %edx,%eax
801032d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d9:	c1 e8 04             	shr    $0x4,%eax
801032dc:	89 c2                	mov    %eax,%edx
801032de:	89 d0                	mov    %edx,%eax
801032e0:	c1 e0 02             	shl    $0x2,%eax
801032e3:	01 d0                	add    %edx,%eax
801032e5:	01 c0                	add    %eax,%eax
801032e7:	89 c2                	mov    %eax,%edx
801032e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ec:	83 e0 0f             	and    $0xf,%eax
801032ef:	01 d0                	add    %edx,%eax
801032f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032f4:	8b 45 08             	mov    0x8(%ebp),%eax
801032f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032fa:	89 10                	mov    %edx,(%eax)
801032fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032ff:	89 50 04             	mov    %edx,0x4(%eax)
80103302:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103305:	89 50 08             	mov    %edx,0x8(%eax)
80103308:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010330b:	89 50 0c             	mov    %edx,0xc(%eax)
8010330e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103311:	89 50 10             	mov    %edx,0x10(%eax)
80103314:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103317:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010331a:	8b 45 08             	mov    0x8(%ebp),%eax
8010331d:	8b 40 14             	mov    0x14(%eax),%eax
80103320:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103326:	8b 45 08             	mov    0x8(%ebp),%eax
80103329:	89 50 14             	mov    %edx,0x14(%eax)
}
8010332c:	90                   	nop
8010332d:	c9                   	leave  
8010332e:	c3                   	ret    

8010332f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010332f:	55                   	push   %ebp
80103330:	89 e5                	mov    %esp,%ebp
80103332:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103335:	83 ec 08             	sub    $0x8,%esp
80103338:	68 3c 88 10 80       	push   $0x8010883c
8010333d:	68 60 22 11 80       	push   $0x80112260
80103342:	e8 30 1d 00 00       	call   80105077 <initlock>
80103347:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010334a:	83 ec 08             	sub    $0x8,%esp
8010334d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103350:	50                   	push   %eax
80103351:	ff 75 08             	pushl  0x8(%ebp)
80103354:	e8 2b e0 ff ff       	call   80101384 <readsb>
80103359:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010335c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010335f:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
80103364:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103367:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = dev;
8010336c:	8b 45 08             	mov    0x8(%ebp),%eax
8010336f:	a3 a4 22 11 80       	mov    %eax,0x801122a4
  recover_from_log();
80103374:	e8 b2 01 00 00       	call   8010352b <recover_from_log>
}
80103379:	90                   	nop
8010337a:	c9                   	leave  
8010337b:	c3                   	ret    

8010337c <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010337c:	55                   	push   %ebp
8010337d:	89 e5                	mov    %esp,%ebp
8010337f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103389:	e9 95 00 00 00       	jmp    80103423 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010338e:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103397:	01 d0                	add    %edx,%eax
80103399:	83 c0 01             	add    $0x1,%eax
8010339c:	89 c2                	mov    %eax,%edx
8010339e:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033a3:	83 ec 08             	sub    $0x8,%esp
801033a6:	52                   	push   %edx
801033a7:	50                   	push   %eax
801033a8:	e8 09 ce ff ff       	call   801001b6 <bread>
801033ad:	83 c4 10             	add    $0x10,%esp
801033b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b6:	83 c0 10             	add    $0x10,%eax
801033b9:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801033c0:	89 c2                	mov    %eax,%edx
801033c2:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033c7:	83 ec 08             	sub    $0x8,%esp
801033ca:	52                   	push   %edx
801033cb:	50                   	push   %eax
801033cc:	e8 e5 cd ff ff       	call   801001b6 <bread>
801033d1:	83 c4 10             	add    $0x10,%esp
801033d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	8d 50 18             	lea    0x18(%eax),%edx
801033dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e0:	83 c0 18             	add    $0x18,%eax
801033e3:	83 ec 04             	sub    $0x4,%esp
801033e6:	68 00 02 00 00       	push   $0x200
801033eb:	52                   	push   %edx
801033ec:	50                   	push   %eax
801033ed:	e8 c9 1f 00 00       	call   801053bb <memmove>
801033f2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	ff 75 ec             	pushl  -0x14(%ebp)
801033fb:	e8 ef cd ff ff       	call   801001ef <bwrite>
80103400:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	ff 75 f0             	pushl  -0x10(%ebp)
80103409:	e8 20 ce ff ff       	call   8010022e <brelse>
8010340e:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103411:	83 ec 0c             	sub    $0xc,%esp
80103414:	ff 75 ec             	pushl  -0x14(%ebp)
80103417:	e8 12 ce ff ff       	call   8010022e <brelse>
8010341c:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010341f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103423:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103428:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010342b:	0f 8f 5d ff ff ff    	jg     8010338e <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103431:	90                   	nop
80103432:	c9                   	leave  
80103433:	c3                   	ret    

80103434 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103434:	55                   	push   %ebp
80103435:	89 e5                	mov    %esp,%ebp
80103437:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010343a:	a1 94 22 11 80       	mov    0x80112294,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103446:	83 ec 08             	sub    $0x8,%esp
80103449:	52                   	push   %edx
8010344a:	50                   	push   %eax
8010344b:	e8 66 cd ff ff       	call   801001b6 <bread>
80103450:	83 c4 10             	add    $0x10,%esp
80103453:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103459:	83 c0 18             	add    $0x18,%eax
8010345c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010345f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103462:	8b 00                	mov    (%eax),%eax
80103464:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
80103469:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103470:	eb 1b                	jmp    8010348d <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103478:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010347c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010347f:	83 c2 10             	add    $0x10,%edx
80103482:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103489:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010348d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103492:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103495:	7f db                	jg     80103472 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103497:	83 ec 0c             	sub    $0xc,%esp
8010349a:	ff 75 f0             	pushl  -0x10(%ebp)
8010349d:	e8 8c cd ff ff       	call   8010022e <brelse>
801034a2:	83 c4 10             	add    $0x10,%esp
}
801034a5:	90                   	nop
801034a6:	c9                   	leave  
801034a7:	c3                   	ret    

801034a8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034a8:	55                   	push   %ebp
801034a9:	89 e5                	mov    %esp,%ebp
801034ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ae:	a1 94 22 11 80       	mov    0x80112294,%eax
801034b3:	89 c2                	mov    %eax,%edx
801034b5:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801034ba:	83 ec 08             	sub    $0x8,%esp
801034bd:	52                   	push   %edx
801034be:	50                   	push   %eax
801034bf:	e8 f2 cc ff ff       	call   801001b6 <bread>
801034c4:	83 c4 10             	add    $0x10,%esp
801034c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cd:	83 c0 18             	add    $0x18,%eax
801034d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034d3:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e5:	eb 1b                	jmp    80103502 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ea:	83 c0 10             	add    $0x10,%eax
801034ed:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
801034f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034fa:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103502:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103507:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010350a:	7f db                	jg     801034e7 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010350c:	83 ec 0c             	sub    $0xc,%esp
8010350f:	ff 75 f0             	pushl  -0x10(%ebp)
80103512:	e8 d8 cc ff ff       	call   801001ef <bwrite>
80103517:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010351a:	83 ec 0c             	sub    $0xc,%esp
8010351d:	ff 75 f0             	pushl  -0x10(%ebp)
80103520:	e8 09 cd ff ff       	call   8010022e <brelse>
80103525:	83 c4 10             	add    $0x10,%esp
}
80103528:	90                   	nop
80103529:	c9                   	leave  
8010352a:	c3                   	ret    

8010352b <recover_from_log>:

static void
recover_from_log(void)
{
8010352b:	55                   	push   %ebp
8010352c:	89 e5                	mov    %esp,%ebp
8010352e:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103531:	e8 fe fe ff ff       	call   80103434 <read_head>
  install_trans(); // if committed, copy from log to disk
80103536:	e8 41 fe ff ff       	call   8010337c <install_trans>
  log.lh.n = 0;
8010353b:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103542:	00 00 00 
  write_head(); // clear the log
80103545:	e8 5e ff ff ff       	call   801034a8 <write_head>
}
8010354a:	90                   	nop
8010354b:	c9                   	leave  
8010354c:	c3                   	ret    

8010354d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010354d:	55                   	push   %ebp
8010354e:	89 e5                	mov    %esp,%ebp
80103550:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103553:	83 ec 0c             	sub    $0xc,%esp
80103556:	68 60 22 11 80       	push   $0x80112260
8010355b:	e8 39 1b 00 00       	call   80105099 <acquire>
80103560:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103563:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103568:	85 c0                	test   %eax,%eax
8010356a:	74 17                	je     80103583 <begin_op+0x36>
      sleep(&log, &log.lock);
8010356c:	83 ec 08             	sub    $0x8,%esp
8010356f:	68 60 22 11 80       	push   $0x80112260
80103574:	68 60 22 11 80       	push   $0x80112260
80103579:	e8 19 18 00 00       	call   80104d97 <sleep>
8010357e:	83 c4 10             	add    $0x10,%esp
80103581:	eb e0                	jmp    80103563 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103583:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103589:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010358e:	8d 50 01             	lea    0x1(%eax),%edx
80103591:	89 d0                	mov    %edx,%eax
80103593:	c1 e0 02             	shl    $0x2,%eax
80103596:	01 d0                	add    %edx,%eax
80103598:	01 c0                	add    %eax,%eax
8010359a:	01 c8                	add    %ecx,%eax
8010359c:	83 f8 1e             	cmp    $0x1e,%eax
8010359f:	7e 17                	jle    801035b8 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035a1:	83 ec 08             	sub    $0x8,%esp
801035a4:	68 60 22 11 80       	push   $0x80112260
801035a9:	68 60 22 11 80       	push   $0x80112260
801035ae:	e8 e4 17 00 00       	call   80104d97 <sleep>
801035b3:	83 c4 10             	add    $0x10,%esp
801035b6:	eb ab                	jmp    80103563 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035b8:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801035bd:	83 c0 01             	add    $0x1,%eax
801035c0:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
801035c5:	83 ec 0c             	sub    $0xc,%esp
801035c8:	68 60 22 11 80       	push   $0x80112260
801035cd:	e8 2e 1b 00 00       	call   80105100 <release>
801035d2:	83 c4 10             	add    $0x10,%esp
      break;
801035d5:	90                   	nop
    }
  }
}
801035d6:	90                   	nop
801035d7:	c9                   	leave  
801035d8:	c3                   	ret    

801035d9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035d9:	55                   	push   %ebp
801035da:	89 e5                	mov    %esp,%ebp
801035dc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035e6:	83 ec 0c             	sub    $0xc,%esp
801035e9:	68 60 22 11 80       	push   $0x80112260
801035ee:	e8 a6 1a 00 00       	call   80105099 <acquire>
801035f3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035f6:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801035fb:	83 e8 01             	sub    $0x1,%eax
801035fe:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103603:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103608:	85 c0                	test   %eax,%eax
8010360a:	74 0d                	je     80103619 <end_op+0x40>
    panic("log.committing");
8010360c:	83 ec 0c             	sub    $0xc,%esp
8010360f:	68 40 88 10 80       	push   $0x80108840
80103614:	e8 4d cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103619:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010361e:	85 c0                	test   %eax,%eax
80103620:	75 13                	jne    80103635 <end_op+0x5c>
    do_commit = 1;
80103622:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103629:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
80103630:	00 00 00 
80103633:	eb 10                	jmp    80103645 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 60 22 11 80       	push   $0x80112260
8010363d:	e8 43 18 00 00       	call   80104e85 <wakeup>
80103642:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103645:	83 ec 0c             	sub    $0xc,%esp
80103648:	68 60 22 11 80       	push   $0x80112260
8010364d:	e8 ae 1a 00 00       	call   80105100 <release>
80103652:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103659:	74 3f                	je     8010369a <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010365b:	e8 f5 00 00 00       	call   80103755 <commit>
    acquire(&log.lock);
80103660:	83 ec 0c             	sub    $0xc,%esp
80103663:	68 60 22 11 80       	push   $0x80112260
80103668:	e8 2c 1a 00 00       	call   80105099 <acquire>
8010366d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103670:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
80103677:	00 00 00 
    wakeup(&log);
8010367a:	83 ec 0c             	sub    $0xc,%esp
8010367d:	68 60 22 11 80       	push   $0x80112260
80103682:	e8 fe 17 00 00       	call   80104e85 <wakeup>
80103687:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010368a:	83 ec 0c             	sub    $0xc,%esp
8010368d:	68 60 22 11 80       	push   $0x80112260
80103692:	e8 69 1a 00 00       	call   80105100 <release>
80103697:	83 c4 10             	add    $0x10,%esp
  }
}
8010369a:	90                   	nop
8010369b:	c9                   	leave  
8010369c:	c3                   	ret    

8010369d <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010369d:	55                   	push   %ebp
8010369e:	89 e5                	mov    %esp,%ebp
801036a0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036aa:	e9 95 00 00 00       	jmp    80103744 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036af:	8b 15 94 22 11 80    	mov    0x80112294,%edx
801036b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b8:	01 d0                	add    %edx,%eax
801036ba:	83 c0 01             	add    $0x1,%eax
801036bd:	89 c2                	mov    %eax,%edx
801036bf:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801036c4:	83 ec 08             	sub    $0x8,%esp
801036c7:	52                   	push   %edx
801036c8:	50                   	push   %eax
801036c9:	e8 e8 ca ff ff       	call   801001b6 <bread>
801036ce:	83 c4 10             	add    $0x10,%esp
801036d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d7:	83 c0 10             	add    $0x10,%eax
801036da:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801036e1:	89 c2                	mov    %eax,%edx
801036e3:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801036e8:	83 ec 08             	sub    $0x8,%esp
801036eb:	52                   	push   %edx
801036ec:	50                   	push   %eax
801036ed:	e8 c4 ca ff ff       	call   801001b6 <bread>
801036f2:	83 c4 10             	add    $0x10,%esp
801036f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036fb:	8d 50 18             	lea    0x18(%eax),%edx
801036fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103701:	83 c0 18             	add    $0x18,%eax
80103704:	83 ec 04             	sub    $0x4,%esp
80103707:	68 00 02 00 00       	push   $0x200
8010370c:	52                   	push   %edx
8010370d:	50                   	push   %eax
8010370e:	e8 a8 1c 00 00       	call   801053bb <memmove>
80103713:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103716:	83 ec 0c             	sub    $0xc,%esp
80103719:	ff 75 f0             	pushl  -0x10(%ebp)
8010371c:	e8 ce ca ff ff       	call   801001ef <bwrite>
80103721:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103724:	83 ec 0c             	sub    $0xc,%esp
80103727:	ff 75 ec             	pushl  -0x14(%ebp)
8010372a:	e8 ff ca ff ff       	call   8010022e <brelse>
8010372f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103732:	83 ec 0c             	sub    $0xc,%esp
80103735:	ff 75 f0             	pushl  -0x10(%ebp)
80103738:	e8 f1 ca ff ff       	call   8010022e <brelse>
8010373d:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103740:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103744:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103749:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010374c:	0f 8f 5d ff ff ff    	jg     801036af <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103752:	90                   	nop
80103753:	c9                   	leave  
80103754:	c3                   	ret    

80103755 <commit>:

static void
commit()
{
80103755:	55                   	push   %ebp
80103756:	89 e5                	mov    %esp,%ebp
80103758:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010375b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103760:	85 c0                	test   %eax,%eax
80103762:	7e 1e                	jle    80103782 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103764:	e8 34 ff ff ff       	call   8010369d <write_log>
    write_head();    // Write header to disk -- the real commit
80103769:	e8 3a fd ff ff       	call   801034a8 <write_head>
    install_trans(); // Now install writes to home locations
8010376e:	e8 09 fc ff ff       	call   8010337c <install_trans>
    log.lh.n = 0; 
80103773:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
8010377a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010377d:	e8 26 fd ff ff       	call   801034a8 <write_head>
  }
}
80103782:	90                   	nop
80103783:	c9                   	leave  
80103784:	c3                   	ret    

80103785 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103785:	55                   	push   %ebp
80103786:	89 e5                	mov    %esp,%ebp
80103788:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010378b:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103790:	83 f8 1d             	cmp    $0x1d,%eax
80103793:	7f 12                	jg     801037a7 <log_write+0x22>
80103795:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010379a:	8b 15 98 22 11 80    	mov    0x80112298,%edx
801037a0:	83 ea 01             	sub    $0x1,%edx
801037a3:	39 d0                	cmp    %edx,%eax
801037a5:	7c 0d                	jl     801037b4 <log_write+0x2f>
    panic("too big a transaction");
801037a7:	83 ec 0c             	sub    $0xc,%esp
801037aa:	68 4f 88 10 80       	push   $0x8010884f
801037af:	e8 b2 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
801037b4:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801037b9:	85 c0                	test   %eax,%eax
801037bb:	7f 0d                	jg     801037ca <log_write+0x45>
    panic("log_write outside of trans");
801037bd:	83 ec 0c             	sub    $0xc,%esp
801037c0:	68 65 88 10 80       	push   $0x80108865
801037c5:	e8 9c cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
801037ca:	83 ec 0c             	sub    $0xc,%esp
801037cd:	68 60 22 11 80       	push   $0x80112260
801037d2:	e8 c2 18 00 00       	call   80105099 <acquire>
801037d7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037e1:	eb 1d                	jmp    80103800 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e6:	83 c0 10             	add    $0x10,%eax
801037e9:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801037f0:	89 c2                	mov    %eax,%edx
801037f2:	8b 45 08             	mov    0x8(%ebp),%eax
801037f5:	8b 40 08             	mov    0x8(%eax),%eax
801037f8:	39 c2                	cmp    %eax,%edx
801037fa:	74 10                	je     8010380c <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103800:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103805:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103808:	7f d9                	jg     801037e3 <log_write+0x5e>
8010380a:	eb 01                	jmp    8010380d <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
8010380c:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 40 08             	mov    0x8(%eax),%eax
80103813:	89 c2                	mov    %eax,%edx
80103815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103818:	83 c0 10             	add    $0x10,%eax
8010381b:	89 14 85 6c 22 11 80 	mov    %edx,-0x7feedd94(,%eax,4)
  if (i == log.lh.n)
80103822:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103827:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010382a:	75 0d                	jne    80103839 <log_write+0xb4>
    log.lh.n++;
8010382c:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103831:	83 c0 01             	add    $0x1,%eax
80103834:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
80103839:	8b 45 08             	mov    0x8(%ebp),%eax
8010383c:	8b 00                	mov    (%eax),%eax
8010383e:	83 c8 04             	or     $0x4,%eax
80103841:	89 c2                	mov    %eax,%edx
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103848:	83 ec 0c             	sub    $0xc,%esp
8010384b:	68 60 22 11 80       	push   $0x80112260
80103850:	e8 ab 18 00 00       	call   80105100 <release>
80103855:	83 c4 10             	add    $0x10,%esp
}
80103858:	90                   	nop
80103859:	c9                   	leave  
8010385a:	c3                   	ret    

8010385b <v2p>:
8010385b:	55                   	push   %ebp
8010385c:	89 e5                	mov    %esp,%ebp
8010385e:	8b 45 08             	mov    0x8(%ebp),%eax
80103861:	05 00 00 00 80       	add    $0x80000000,%eax
80103866:	5d                   	pop    %ebp
80103867:	c3                   	ret    

80103868 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103868:	55                   	push   %ebp
80103869:	89 e5                	mov    %esp,%ebp
8010386b:	8b 45 08             	mov    0x8(%ebp),%eax
8010386e:	05 00 00 00 80       	add    $0x80000000,%eax
80103873:	5d                   	pop    %ebp
80103874:	c3                   	ret    

80103875 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103875:	55                   	push   %ebp
80103876:	89 e5                	mov    %esp,%ebp
80103878:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010387b:	8b 55 08             	mov    0x8(%ebp),%edx
8010387e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103881:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103884:	f0 87 02             	lock xchg %eax,(%edx)
80103887:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010388a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010388d:	c9                   	leave  
8010388e:	c3                   	ret    

8010388f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010388f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103893:	83 e4 f0             	and    $0xfffffff0,%esp
80103896:	ff 71 fc             	pushl  -0x4(%ecx)
80103899:	55                   	push   %ebp
8010389a:	89 e5                	mov    %esp,%ebp
8010389c:	51                   	push   %ecx
8010389d:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038a0:	83 ec 08             	sub    $0x8,%esp
801038a3:	68 00 00 40 80       	push   $0x80400000
801038a8:	68 3c 54 11 80       	push   $0x8011543c
801038ad:	e8 7d f2 ff ff       	call   80102b2f <kinit1>
801038b2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038b5:	e8 93 45 00 00       	call   80107e4d <kvmalloc>
  mpinit();        // collect info about this machine
801038ba:	e8 43 04 00 00       	call   80103d02 <mpinit>
  lapicinit();
801038bf:	e8 ea f5 ff ff       	call   80102eae <lapicinit>
  seginit();       // set up segments
801038c4:	e8 2d 3f 00 00       	call   801077f6 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038cf:	0f b6 00             	movzbl (%eax),%eax
801038d2:	0f b6 c0             	movzbl %al,%eax
801038d5:	83 ec 08             	sub    $0x8,%esp
801038d8:	50                   	push   %eax
801038d9:	68 80 88 10 80       	push   $0x80108880
801038de:	e8 e3 ca ff ff       	call   801003c6 <cprintf>
801038e3:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038e6:	e8 6d 06 00 00       	call   80103f58 <picinit>
  ioapicinit();    // another interrupt controller
801038eb:	e8 34 f1 ff ff       	call   80102a24 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038f0:	e8 24 d2 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
801038f5:	e8 58 32 00 00       	call   80106b52 <uartinit>
  pinit();         // process table
801038fa:	e8 56 0b 00 00       	call   80104455 <pinit>
  tvinit();        // trap vectors
801038ff:	e8 18 2e 00 00       	call   8010671c <tvinit>
  binit();         // buffer cache
80103904:	e8 2b c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103909:	e8 67 d6 ff ff       	call   80100f75 <fileinit>
  ideinit();       // disk
8010390e:	e8 19 ed ff ff       	call   8010262c <ideinit>
  if(!ismp)
80103913:	a1 44 23 11 80       	mov    0x80112344,%eax
80103918:	85 c0                	test   %eax,%eax
8010391a:	75 05                	jne    80103921 <main+0x92>
    timerinit();   // uniprocessor timer
8010391c:	e8 58 2d 00 00       	call   80106679 <timerinit>
  startothers();   // start other processors
80103921:	e8 7f 00 00 00       	call   801039a5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103926:	83 ec 08             	sub    $0x8,%esp
80103929:	68 00 00 00 8e       	push   $0x8e000000
8010392e:	68 00 00 40 80       	push   $0x80400000
80103933:	e8 30 f2 ff ff       	call   80102b68 <kinit2>
80103938:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010393b:	e8 3c 0c 00 00       	call   8010457c <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103940:	e8 1a 00 00 00       	call   8010395f <mpmain>

80103945 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103945:	55                   	push   %ebp
80103946:	89 e5                	mov    %esp,%ebp
80103948:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010394b:	e8 15 45 00 00       	call   80107e65 <switchkvm>
  seginit();
80103950:	e8 a1 3e 00 00       	call   801077f6 <seginit>
  lapicinit();
80103955:	e8 54 f5 ff ff       	call   80102eae <lapicinit>
  mpmain();
8010395a:	e8 00 00 00 00       	call   8010395f <mpmain>

8010395f <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010395f:	55                   	push   %ebp
80103960:	89 e5                	mov    %esp,%ebp
80103962:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103965:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396b:	0f b6 00             	movzbl (%eax),%eax
8010396e:	0f b6 c0             	movzbl %al,%eax
80103971:	83 ec 08             	sub    $0x8,%esp
80103974:	50                   	push   %eax
80103975:	68 97 88 10 80       	push   $0x80108897
8010397a:	e8 47 ca ff ff       	call   801003c6 <cprintf>
8010397f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103982:	e8 0b 2f 00 00       	call   80106892 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103987:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010398d:	05 a8 00 00 00       	add    $0xa8,%eax
80103992:	83 ec 08             	sub    $0x8,%esp
80103995:	6a 01                	push   $0x1
80103997:	50                   	push   %eax
80103998:	e8 d8 fe ff ff       	call   80103875 <xchg>
8010399d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039a0:	e8 88 11 00 00       	call   80104b2d <scheduler>

801039a5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039a5:	55                   	push   %ebp
801039a6:	89 e5                	mov    %esp,%ebp
801039a8:	53                   	push   %ebx
801039a9:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039ac:	68 00 70 00 00       	push   $0x7000
801039b1:	e8 b2 fe ff ff       	call   80103868 <p2v>
801039b6:	83 c4 04             	add    $0x4,%esp
801039b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039bc:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039c1:	83 ec 04             	sub    $0x4,%esp
801039c4:	50                   	push   %eax
801039c5:	68 0c b5 10 80       	push   $0x8010b50c
801039ca:	ff 75 f0             	pushl  -0x10(%ebp)
801039cd:	e8 e9 19 00 00       	call   801053bb <memmove>
801039d2:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039d5:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
801039dc:	e9 90 00 00 00       	jmp    80103a71 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801039e1:	e8 e6 f5 ff ff       	call   80102fcc <cpunum>
801039e6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039ec:	05 60 23 11 80       	add    $0x80112360,%eax
801039f1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f4:	74 73                	je     80103a69 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039f6:	e8 6b f2 ff ff       	call   80102c66 <kalloc>
801039fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a01:	83 e8 04             	sub    $0x4,%eax
80103a04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a07:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a0d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a12:	83 e8 08             	sub    $0x8,%eax
80103a15:	c7 00 45 39 10 80    	movl   $0x80103945,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1e:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 00 a0 10 80       	push   $0x8010a000
80103a29:	e8 2d fe ff ff       	call   8010385b <v2p>
80103a2e:	83 c4 10             	add    $0x10,%esp
80103a31:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a33:	83 ec 0c             	sub    $0xc,%esp
80103a36:	ff 75 f0             	pushl  -0x10(%ebp)
80103a39:	e8 1d fe ff ff       	call   8010385b <v2p>
80103a3e:	83 c4 10             	add    $0x10,%esp
80103a41:	89 c2                	mov    %eax,%edx
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	0f b6 00             	movzbl (%eax),%eax
80103a49:	0f b6 c0             	movzbl %al,%eax
80103a4c:	83 ec 08             	sub    $0x8,%esp
80103a4f:	52                   	push   %edx
80103a50:	50                   	push   %eax
80103a51:	e8 f0 f5 ff ff       	call   80103046 <lapicstartap>
80103a56:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a59:	90                   	nop
80103a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a63:	85 c0                	test   %eax,%eax
80103a65:	74 f3                	je     80103a5a <startothers+0xb5>
80103a67:	eb 01                	jmp    80103a6a <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a69:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a6a:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a71:	a1 40 29 11 80       	mov    0x80112940,%eax
80103a76:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a7c:	05 60 23 11 80       	add    $0x80112360,%eax
80103a81:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a84:	0f 87 57 ff ff ff    	ja     801039e1 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a8a:	90                   	nop
80103a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a8e:	c9                   	leave  
80103a8f:	c3                   	ret    

80103a90 <p2v>:
80103a90:	55                   	push   %ebp
80103a91:	89 e5                	mov    %esp,%ebp
80103a93:	8b 45 08             	mov    0x8(%ebp),%eax
80103a96:	05 00 00 00 80       	add    $0x80000000,%eax
80103a9b:	5d                   	pop    %ebp
80103a9c:	c3                   	ret    

80103a9d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a9d:	55                   	push   %ebp
80103a9e:	89 e5                	mov    %esp,%ebp
80103aa0:	83 ec 14             	sub    $0x14,%esp
80103aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103aaa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103aae:	89 c2                	mov    %eax,%edx
80103ab0:	ec                   	in     (%dx),%al
80103ab1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ab4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ab8:	c9                   	leave  
80103ab9:	c3                   	ret    

80103aba <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103aba:	55                   	push   %ebp
80103abb:	89 e5                	mov    %esp,%ebp
80103abd:	83 ec 08             	sub    $0x8,%esp
80103ac0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ac6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aca:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103acd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ad1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ad5:	ee                   	out    %al,(%dx)
}
80103ad6:	90                   	nop
80103ad7:	c9                   	leave  
80103ad8:	c3                   	ret    

80103ad9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ad9:	55                   	push   %ebp
80103ada:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103adc:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103ae1:	89 c2                	mov    %eax,%edx
80103ae3:	b8 60 23 11 80       	mov    $0x80112360,%eax
80103ae8:	29 c2                	sub    %eax,%edx
80103aea:	89 d0                	mov    %edx,%eax
80103aec:	c1 f8 02             	sar    $0x2,%eax
80103aef:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103af5:	5d                   	pop    %ebp
80103af6:	c3                   	ret    

80103af7 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103af7:	55                   	push   %ebp
80103af8:	89 e5                	mov    %esp,%ebp
80103afa:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103afd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b04:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b0b:	eb 15                	jmp    80103b22 <sum+0x2b>
    sum += addr[i];
80103b0d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b10:	8b 45 08             	mov    0x8(%ebp),%eax
80103b13:	01 d0                	add    %edx,%eax
80103b15:	0f b6 00             	movzbl (%eax),%eax
80103b18:	0f b6 c0             	movzbl %al,%eax
80103b1b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b1e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b25:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b28:	7c e3                	jl     80103b0d <sum+0x16>
    sum += addr[i];
  return sum;
80103b2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b2d:	c9                   	leave  
80103b2e:	c3                   	ret    

80103b2f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b2f:	55                   	push   %ebp
80103b30:	89 e5                	mov    %esp,%ebp
80103b32:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b35:	ff 75 08             	pushl  0x8(%ebp)
80103b38:	e8 53 ff ff ff       	call   80103a90 <p2v>
80103b3d:	83 c4 04             	add    $0x4,%esp
80103b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b43:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b49:	01 d0                	add    %edx,%eax
80103b4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b54:	eb 36                	jmp    80103b8c <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b56:	83 ec 04             	sub    $0x4,%esp
80103b59:	6a 04                	push   $0x4
80103b5b:	68 a8 88 10 80       	push   $0x801088a8
80103b60:	ff 75 f4             	pushl  -0xc(%ebp)
80103b63:	e8 fb 17 00 00       	call   80105363 <memcmp>
80103b68:	83 c4 10             	add    $0x10,%esp
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	75 19                	jne    80103b88 <mpsearch1+0x59>
80103b6f:	83 ec 08             	sub    $0x8,%esp
80103b72:	6a 10                	push   $0x10
80103b74:	ff 75 f4             	pushl  -0xc(%ebp)
80103b77:	e8 7b ff ff ff       	call   80103af7 <sum>
80103b7c:	83 c4 10             	add    $0x10,%esp
80103b7f:	84 c0                	test   %al,%al
80103b81:	75 05                	jne    80103b88 <mpsearch1+0x59>
      return (struct mp*)p;
80103b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b86:	eb 11                	jmp    80103b99 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b88:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b92:	72 c2                	jb     80103b56 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b99:	c9                   	leave  
80103b9a:	c3                   	ret    

80103b9b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b9b:	55                   	push   %ebp
80103b9c:	89 e5                	mov    %esp,%ebp
80103b9e:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ba1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	83 c0 0f             	add    $0xf,%eax
80103bae:	0f b6 00             	movzbl (%eax),%eax
80103bb1:	0f b6 c0             	movzbl %al,%eax
80103bb4:	c1 e0 08             	shl    $0x8,%eax
80103bb7:	89 c2                	mov    %eax,%edx
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	83 c0 0e             	add    $0xe,%eax
80103bbf:	0f b6 00             	movzbl (%eax),%eax
80103bc2:	0f b6 c0             	movzbl %al,%eax
80103bc5:	09 d0                	or     %edx,%eax
80103bc7:	c1 e0 04             	shl    $0x4,%eax
80103bca:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bcd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bd1:	74 21                	je     80103bf4 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bd3:	83 ec 08             	sub    $0x8,%esp
80103bd6:	68 00 04 00 00       	push   $0x400
80103bdb:	ff 75 f0             	pushl  -0x10(%ebp)
80103bde:	e8 4c ff ff ff       	call   80103b2f <mpsearch1>
80103be3:	83 c4 10             	add    $0x10,%esp
80103be6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103be9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bed:	74 51                	je     80103c40 <mpsearch+0xa5>
      return mp;
80103bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf2:	eb 61                	jmp    80103c55 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf7:	83 c0 14             	add    $0x14,%eax
80103bfa:	0f b6 00             	movzbl (%eax),%eax
80103bfd:	0f b6 c0             	movzbl %al,%eax
80103c00:	c1 e0 08             	shl    $0x8,%eax
80103c03:	89 c2                	mov    %eax,%edx
80103c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c08:	83 c0 13             	add    $0x13,%eax
80103c0b:	0f b6 00             	movzbl (%eax),%eax
80103c0e:	0f b6 c0             	movzbl %al,%eax
80103c11:	09 d0                	or     %edx,%eax
80103c13:	c1 e0 0a             	shl    $0xa,%eax
80103c16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1c:	2d 00 04 00 00       	sub    $0x400,%eax
80103c21:	83 ec 08             	sub    $0x8,%esp
80103c24:	68 00 04 00 00       	push   $0x400
80103c29:	50                   	push   %eax
80103c2a:	e8 00 ff ff ff       	call   80103b2f <mpsearch1>
80103c2f:	83 c4 10             	add    $0x10,%esp
80103c32:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c35:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c39:	74 05                	je     80103c40 <mpsearch+0xa5>
      return mp;
80103c3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3e:	eb 15                	jmp    80103c55 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c40:	83 ec 08             	sub    $0x8,%esp
80103c43:	68 00 00 01 00       	push   $0x10000
80103c48:	68 00 00 0f 00       	push   $0xf0000
80103c4d:	e8 dd fe ff ff       	call   80103b2f <mpsearch1>
80103c52:	83 c4 10             	add    $0x10,%esp
}
80103c55:	c9                   	leave  
80103c56:	c3                   	ret    

80103c57 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c57:	55                   	push   %ebp
80103c58:	89 e5                	mov    %esp,%ebp
80103c5a:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c5d:	e8 39 ff ff ff       	call   80103b9b <mpsearch>
80103c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c69:	74 0a                	je     80103c75 <mpconfig+0x1e>
80103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6e:	8b 40 04             	mov    0x4(%eax),%eax
80103c71:	85 c0                	test   %eax,%eax
80103c73:	75 0a                	jne    80103c7f <mpconfig+0x28>
    return 0;
80103c75:	b8 00 00 00 00       	mov    $0x0,%eax
80103c7a:	e9 81 00 00 00       	jmp    80103d00 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	8b 40 04             	mov    0x4(%eax),%eax
80103c85:	83 ec 0c             	sub    $0xc,%esp
80103c88:	50                   	push   %eax
80103c89:	e8 02 fe ff ff       	call   80103a90 <p2v>
80103c8e:	83 c4 10             	add    $0x10,%esp
80103c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c94:	83 ec 04             	sub    $0x4,%esp
80103c97:	6a 04                	push   $0x4
80103c99:	68 ad 88 10 80       	push   $0x801088ad
80103c9e:	ff 75 f0             	pushl  -0x10(%ebp)
80103ca1:	e8 bd 16 00 00       	call   80105363 <memcmp>
80103ca6:	83 c4 10             	add    $0x10,%esp
80103ca9:	85 c0                	test   %eax,%eax
80103cab:	74 07                	je     80103cb4 <mpconfig+0x5d>
    return 0;
80103cad:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb2:	eb 4c                	jmp    80103d00 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cbb:	3c 01                	cmp    $0x1,%al
80103cbd:	74 12                	je     80103cd1 <mpconfig+0x7a>
80103cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc2:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cc6:	3c 04                	cmp    $0x4,%al
80103cc8:	74 07                	je     80103cd1 <mpconfig+0x7a>
    return 0;
80103cca:	b8 00 00 00 00       	mov    $0x0,%eax
80103ccf:	eb 2f                	jmp    80103d00 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cd8:	0f b7 c0             	movzwl %ax,%eax
80103cdb:	83 ec 08             	sub    $0x8,%esp
80103cde:	50                   	push   %eax
80103cdf:	ff 75 f0             	pushl  -0x10(%ebp)
80103ce2:	e8 10 fe ff ff       	call   80103af7 <sum>
80103ce7:	83 c4 10             	add    $0x10,%esp
80103cea:	84 c0                	test   %al,%al
80103cec:	74 07                	je     80103cf5 <mpconfig+0x9e>
    return 0;
80103cee:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf3:	eb 0b                	jmp    80103d00 <mpconfig+0xa9>
  *pmp = mp;
80103cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfb:	89 10                	mov    %edx,(%eax)
  return conf;
80103cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d00:	c9                   	leave  
80103d01:	c3                   	ret    

80103d02 <mpinit>:

void
mpinit(void)
{
80103d02:	55                   	push   %ebp
80103d03:	89 e5                	mov    %esp,%ebp
80103d05:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d08:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103d0f:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d12:	83 ec 0c             	sub    $0xc,%esp
80103d15:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d18:	50                   	push   %eax
80103d19:	e8 39 ff ff ff       	call   80103c57 <mpconfig>
80103d1e:	83 c4 10             	add    $0x10,%esp
80103d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d28:	0f 84 96 01 00 00    	je     80103ec4 <mpinit+0x1c2>
    return;
  ismp = 1;
80103d2e:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103d35:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3b:	8b 40 24             	mov    0x24(%eax),%eax
80103d3e:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d46:	83 c0 2c             	add    $0x2c,%eax
80103d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d53:	0f b7 d0             	movzwl %ax,%edx
80103d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d59:	01 d0                	add    %edx,%eax
80103d5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d5e:	e9 f2 00 00 00       	jmp    80103e55 <mpinit+0x153>
    switch(*p){
80103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d66:	0f b6 00             	movzbl (%eax),%eax
80103d69:	0f b6 c0             	movzbl %al,%eax
80103d6c:	83 f8 04             	cmp    $0x4,%eax
80103d6f:	0f 87 bc 00 00 00    	ja     80103e31 <mpinit+0x12f>
80103d75:	8b 04 85 f0 88 10 80 	mov    -0x7fef7710(,%eax,4),%eax
80103d7c:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d81:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d87:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d8b:	0f b6 d0             	movzbl %al,%edx
80103d8e:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d93:	39 c2                	cmp    %eax,%edx
80103d95:	74 2b                	je     80103dc2 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d9a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d9e:	0f b6 d0             	movzbl %al,%edx
80103da1:	a1 40 29 11 80       	mov    0x80112940,%eax
80103da6:	83 ec 04             	sub    $0x4,%esp
80103da9:	52                   	push   %edx
80103daa:	50                   	push   %eax
80103dab:	68 b2 88 10 80       	push   $0x801088b2
80103db0:	e8 11 c6 ff ff       	call   801003c6 <cprintf>
80103db5:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103db8:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103dbf:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103dc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dc5:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dc9:	0f b6 c0             	movzbl %al,%eax
80103dcc:	83 e0 02             	and    $0x2,%eax
80103dcf:	85 c0                	test   %eax,%eax
80103dd1:	74 15                	je     80103de8 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103dd3:	a1 40 29 11 80       	mov    0x80112940,%eax
80103dd8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dde:	05 60 23 11 80       	add    $0x80112360,%eax
80103de3:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103de8:	a1 40 29 11 80       	mov    0x80112940,%eax
80103ded:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103df3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103df9:	05 60 23 11 80       	add    $0x80112360,%eax
80103dfe:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e00:	a1 40 29 11 80       	mov    0x80112940,%eax
80103e05:	83 c0 01             	add    $0x1,%eax
80103e08:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103e0d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e11:	eb 42                	jmp    80103e55 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e1c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e20:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103e25:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e29:	eb 2a                	jmp    80103e55 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e2b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e2f:	eb 24                	jmp    80103e55 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e34:	0f b6 00             	movzbl (%eax),%eax
80103e37:	0f b6 c0             	movzbl %al,%eax
80103e3a:	83 ec 08             	sub    $0x8,%esp
80103e3d:	50                   	push   %eax
80103e3e:	68 d0 88 10 80       	push   $0x801088d0
80103e43:	e8 7e c5 ff ff       	call   801003c6 <cprintf>
80103e48:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e4b:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103e52:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e58:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e5b:	0f 82 02 ff ff ff    	jb     80103d63 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e61:	a1 44 23 11 80       	mov    0x80112344,%eax
80103e66:	85 c0                	test   %eax,%eax
80103e68:	75 1d                	jne    80103e87 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e6a:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103e71:	00 00 00 
    lapic = 0;
80103e74:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103e7b:	00 00 00 
    ioapicid = 0;
80103e7e:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103e85:	eb 3e                	jmp    80103ec5 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e8e:	84 c0                	test   %al,%al
80103e90:	74 33                	je     80103ec5 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e92:	83 ec 08             	sub    $0x8,%esp
80103e95:	6a 70                	push   $0x70
80103e97:	6a 22                	push   $0x22
80103e99:	e8 1c fc ff ff       	call   80103aba <outb>
80103e9e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ea1:	83 ec 0c             	sub    $0xc,%esp
80103ea4:	6a 23                	push   $0x23
80103ea6:	e8 f2 fb ff ff       	call   80103a9d <inb>
80103eab:	83 c4 10             	add    $0x10,%esp
80103eae:	83 c8 01             	or     $0x1,%eax
80103eb1:	0f b6 c0             	movzbl %al,%eax
80103eb4:	83 ec 08             	sub    $0x8,%esp
80103eb7:	50                   	push   %eax
80103eb8:	6a 23                	push   $0x23
80103eba:	e8 fb fb ff ff       	call   80103aba <outb>
80103ebf:	83 c4 10             	add    $0x10,%esp
80103ec2:	eb 01                	jmp    80103ec5 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103ec4:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103ec5:	c9                   	leave  
80103ec6:	c3                   	ret    

80103ec7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ec7:	55                   	push   %ebp
80103ec8:	89 e5                	mov    %esp,%ebp
80103eca:	83 ec 08             	sub    $0x8,%esp
80103ecd:	8b 55 08             	mov    0x8(%ebp),%edx
80103ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ed7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103eda:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ede:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ee2:	ee                   	out    %al,(%dx)
}
80103ee3:	90                   	nop
80103ee4:	c9                   	leave  
80103ee5:	c3                   	ret    

80103ee6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ee6:	55                   	push   %ebp
80103ee7:	89 e5                	mov    %esp,%ebp
80103ee9:	83 ec 04             	sub    $0x4,%esp
80103eec:	8b 45 08             	mov    0x8(%ebp),%eax
80103eef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ef3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ef7:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103efd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f01:	0f b6 c0             	movzbl %al,%eax
80103f04:	50                   	push   %eax
80103f05:	6a 21                	push   $0x21
80103f07:	e8 bb ff ff ff       	call   80103ec7 <outb>
80103f0c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f0f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f13:	66 c1 e8 08          	shr    $0x8,%ax
80103f17:	0f b6 c0             	movzbl %al,%eax
80103f1a:	50                   	push   %eax
80103f1b:	68 a1 00 00 00       	push   $0xa1
80103f20:	e8 a2 ff ff ff       	call   80103ec7 <outb>
80103f25:	83 c4 08             	add    $0x8,%esp
}
80103f28:	90                   	nop
80103f29:	c9                   	leave  
80103f2a:	c3                   	ret    

80103f2b <picenable>:

void
picenable(int irq)
{
80103f2b:	55                   	push   %ebp
80103f2c:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	ba 01 00 00 00       	mov    $0x1,%edx
80103f36:	89 c1                	mov    %eax,%ecx
80103f38:	d3 e2                	shl    %cl,%edx
80103f3a:	89 d0                	mov    %edx,%eax
80103f3c:	f7 d0                	not    %eax
80103f3e:	89 c2                	mov    %eax,%edx
80103f40:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f47:	21 d0                	and    %edx,%eax
80103f49:	0f b7 c0             	movzwl %ax,%eax
80103f4c:	50                   	push   %eax
80103f4d:	e8 94 ff ff ff       	call   80103ee6 <picsetmask>
80103f52:	83 c4 04             	add    $0x4,%esp
}
80103f55:	90                   	nop
80103f56:	c9                   	leave  
80103f57:	c3                   	ret    

80103f58 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f58:	55                   	push   %ebp
80103f59:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f5b:	68 ff 00 00 00       	push   $0xff
80103f60:	6a 21                	push   $0x21
80103f62:	e8 60 ff ff ff       	call   80103ec7 <outb>
80103f67:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f6a:	68 ff 00 00 00       	push   $0xff
80103f6f:	68 a1 00 00 00       	push   $0xa1
80103f74:	e8 4e ff ff ff       	call   80103ec7 <outb>
80103f79:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f7c:	6a 11                	push   $0x11
80103f7e:	6a 20                	push   $0x20
80103f80:	e8 42 ff ff ff       	call   80103ec7 <outb>
80103f85:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f88:	6a 20                	push   $0x20
80103f8a:	6a 21                	push   $0x21
80103f8c:	e8 36 ff ff ff       	call   80103ec7 <outb>
80103f91:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f94:	6a 04                	push   $0x4
80103f96:	6a 21                	push   $0x21
80103f98:	e8 2a ff ff ff       	call   80103ec7 <outb>
80103f9d:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fa0:	6a 03                	push   $0x3
80103fa2:	6a 21                	push   $0x21
80103fa4:	e8 1e ff ff ff       	call   80103ec7 <outb>
80103fa9:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fac:	6a 11                	push   $0x11
80103fae:	68 a0 00 00 00       	push   $0xa0
80103fb3:	e8 0f ff ff ff       	call   80103ec7 <outb>
80103fb8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fbb:	6a 28                	push   $0x28
80103fbd:	68 a1 00 00 00       	push   $0xa1
80103fc2:	e8 00 ff ff ff       	call   80103ec7 <outb>
80103fc7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103fca:	6a 02                	push   $0x2
80103fcc:	68 a1 00 00 00       	push   $0xa1
80103fd1:	e8 f1 fe ff ff       	call   80103ec7 <outb>
80103fd6:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103fd9:	6a 03                	push   $0x3
80103fdb:	68 a1 00 00 00       	push   $0xa1
80103fe0:	e8 e2 fe ff ff       	call   80103ec7 <outb>
80103fe5:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103fe8:	6a 68                	push   $0x68
80103fea:	6a 20                	push   $0x20
80103fec:	e8 d6 fe ff ff       	call   80103ec7 <outb>
80103ff1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ff4:	6a 0a                	push   $0xa
80103ff6:	6a 20                	push   $0x20
80103ff8:	e8 ca fe ff ff       	call   80103ec7 <outb>
80103ffd:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104000:	6a 68                	push   $0x68
80104002:	68 a0 00 00 00       	push   $0xa0
80104007:	e8 bb fe ff ff       	call   80103ec7 <outb>
8010400c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010400f:	6a 0a                	push   $0xa
80104011:	68 a0 00 00 00       	push   $0xa0
80104016:	e8 ac fe ff ff       	call   80103ec7 <outb>
8010401b:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010401e:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104025:	66 83 f8 ff          	cmp    $0xffff,%ax
80104029:	74 13                	je     8010403e <picinit+0xe6>
    picsetmask(irqmask);
8010402b:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104032:	0f b7 c0             	movzwl %ax,%eax
80104035:	50                   	push   %eax
80104036:	e8 ab fe ff ff       	call   80103ee6 <picsetmask>
8010403b:	83 c4 04             	add    $0x4,%esp
}
8010403e:	90                   	nop
8010403f:	c9                   	leave  
80104040:	c3                   	ret    

80104041 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104041:	55                   	push   %ebp
80104042:	89 e5                	mov    %esp,%ebp
80104044:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010404e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104051:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405a:	8b 10                	mov    (%eax),%edx
8010405c:	8b 45 08             	mov    0x8(%ebp),%eax
8010405f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104061:	e8 2d cf ff ff       	call   80100f93 <filealloc>
80104066:	89 c2                	mov    %eax,%edx
80104068:	8b 45 08             	mov    0x8(%ebp),%eax
8010406b:	89 10                	mov    %edx,(%eax)
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 00                	mov    (%eax),%eax
80104072:	85 c0                	test   %eax,%eax
80104074:	0f 84 cb 00 00 00    	je     80104145 <pipealloc+0x104>
8010407a:	e8 14 cf ff ff       	call   80100f93 <filealloc>
8010407f:	89 c2                	mov    %eax,%edx
80104081:	8b 45 0c             	mov    0xc(%ebp),%eax
80104084:	89 10                	mov    %edx,(%eax)
80104086:	8b 45 0c             	mov    0xc(%ebp),%eax
80104089:	8b 00                	mov    (%eax),%eax
8010408b:	85 c0                	test   %eax,%eax
8010408d:	0f 84 b2 00 00 00    	je     80104145 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104093:	e8 ce eb ff ff       	call   80102c66 <kalloc>
80104098:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010409b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010409f:	0f 84 9f 00 00 00    	je     80104144 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040af:	00 00 00 
  p->writeopen = 1;
801040b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040bc:	00 00 00 
  p->nwrite = 0;
801040bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040c9:	00 00 00 
  p->nread = 0;
801040cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cf:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040d6:	00 00 00 
  initlock(&p->lock, "pipe");
801040d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dc:	83 ec 08             	sub    $0x8,%esp
801040df:	68 04 89 10 80       	push   $0x80108904
801040e4:	50                   	push   %eax
801040e5:	e8 8d 0f 00 00       	call   80105077 <initlock>
801040ea:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040ed:	8b 45 08             	mov    0x8(%ebp),%eax
801040f0:	8b 00                	mov    (%eax),%eax
801040f2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040f8:	8b 45 08             	mov    0x8(%ebp),%eax
801040fb:	8b 00                	mov    (%eax),%eax
801040fd:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	8b 00                	mov    (%eax),%eax
80104106:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	8b 00                	mov    (%eax),%eax
8010410f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104112:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104115:	8b 45 0c             	mov    0xc(%ebp),%eax
80104118:	8b 00                	mov    (%eax),%eax
8010411a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104120:	8b 45 0c             	mov    0xc(%ebp),%eax
80104123:	8b 00                	mov    (%eax),%eax
80104125:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104129:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412c:	8b 00                	mov    (%eax),%eax
8010412e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104132:	8b 45 0c             	mov    0xc(%ebp),%eax
80104135:	8b 00                	mov    (%eax),%eax
80104137:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010413d:	b8 00 00 00 00       	mov    $0x0,%eax
80104142:	eb 4e                	jmp    80104192 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104144:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104149:	74 0e                	je     80104159 <pipealloc+0x118>
    kfree((char*)p);
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	ff 75 f4             	pushl  -0xc(%ebp)
80104151:	e8 73 ea ff ff       	call   80102bc9 <kfree>
80104156:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104159:	8b 45 08             	mov    0x8(%ebp),%eax
8010415c:	8b 00                	mov    (%eax),%eax
8010415e:	85 c0                	test   %eax,%eax
80104160:	74 11                	je     80104173 <pipealloc+0x132>
    fileclose(*f0);
80104162:	8b 45 08             	mov    0x8(%ebp),%eax
80104165:	8b 00                	mov    (%eax),%eax
80104167:	83 ec 0c             	sub    $0xc,%esp
8010416a:	50                   	push   %eax
8010416b:	e8 e1 ce ff ff       	call   80101051 <fileclose>
80104170:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104173:	8b 45 0c             	mov    0xc(%ebp),%eax
80104176:	8b 00                	mov    (%eax),%eax
80104178:	85 c0                	test   %eax,%eax
8010417a:	74 11                	je     8010418d <pipealloc+0x14c>
    fileclose(*f1);
8010417c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417f:	8b 00                	mov    (%eax),%eax
80104181:	83 ec 0c             	sub    $0xc,%esp
80104184:	50                   	push   %eax
80104185:	e8 c7 ce ff ff       	call   80101051 <fileclose>
8010418a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010418d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104192:	c9                   	leave  
80104193:	c3                   	ret    

80104194 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104194:	55                   	push   %ebp
80104195:	89 e5                	mov    %esp,%ebp
80104197:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	83 ec 0c             	sub    $0xc,%esp
801041a0:	50                   	push   %eax
801041a1:	e8 f3 0e 00 00       	call   80105099 <acquire>
801041a6:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041ad:	74 23                	je     801041d2 <pipeclose+0x3e>
    p->writeopen = 0;
801041af:	8b 45 08             	mov    0x8(%ebp),%eax
801041b2:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041b9:	00 00 00 
    wakeup(&p->nread);
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	05 34 02 00 00       	add    $0x234,%eax
801041c4:	83 ec 0c             	sub    $0xc,%esp
801041c7:	50                   	push   %eax
801041c8:	e8 b8 0c 00 00       	call   80104e85 <wakeup>
801041cd:	83 c4 10             	add    $0x10,%esp
801041d0:	eb 21                	jmp    801041f3 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041d2:	8b 45 08             	mov    0x8(%ebp),%eax
801041d5:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041dc:	00 00 00 
    wakeup(&p->nwrite);
801041df:	8b 45 08             	mov    0x8(%ebp),%eax
801041e2:	05 38 02 00 00       	add    $0x238,%eax
801041e7:	83 ec 0c             	sub    $0xc,%esp
801041ea:	50                   	push   %eax
801041eb:	e8 95 0c 00 00       	call   80104e85 <wakeup>
801041f0:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041f3:	8b 45 08             	mov    0x8(%ebp),%eax
801041f6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041fc:	85 c0                	test   %eax,%eax
801041fe:	75 2c                	jne    8010422c <pipeclose+0x98>
80104200:	8b 45 08             	mov    0x8(%ebp),%eax
80104203:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104209:	85 c0                	test   %eax,%eax
8010420b:	75 1f                	jne    8010422c <pipeclose+0x98>
    release(&p->lock);
8010420d:	8b 45 08             	mov    0x8(%ebp),%eax
80104210:	83 ec 0c             	sub    $0xc,%esp
80104213:	50                   	push   %eax
80104214:	e8 e7 0e 00 00       	call   80105100 <release>
80104219:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	ff 75 08             	pushl  0x8(%ebp)
80104222:	e8 a2 e9 ff ff       	call   80102bc9 <kfree>
80104227:	83 c4 10             	add    $0x10,%esp
8010422a:	eb 0f                	jmp    8010423b <pipeclose+0xa7>
  } else
    release(&p->lock);
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	83 ec 0c             	sub    $0xc,%esp
80104232:	50                   	push   %eax
80104233:	e8 c8 0e 00 00       	call   80105100 <release>
80104238:	83 c4 10             	add    $0x10,%esp
}
8010423b:	90                   	nop
8010423c:	c9                   	leave  
8010423d:	c3                   	ret    

8010423e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010423e:	55                   	push   %ebp
8010423f:	89 e5                	mov    %esp,%ebp
80104241:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104244:	8b 45 08             	mov    0x8(%ebp),%eax
80104247:	83 ec 0c             	sub    $0xc,%esp
8010424a:	50                   	push   %eax
8010424b:	e8 49 0e 00 00       	call   80105099 <acquire>
80104250:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104253:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010425a:	e9 ad 00 00 00       	jmp    8010430c <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010425f:	8b 45 08             	mov    0x8(%ebp),%eax
80104262:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104268:	85 c0                	test   %eax,%eax
8010426a:	74 0d                	je     80104279 <pipewrite+0x3b>
8010426c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104272:	8b 40 24             	mov    0x24(%eax),%eax
80104275:	85 c0                	test   %eax,%eax
80104277:	74 19                	je     80104292 <pipewrite+0x54>
        release(&p->lock);
80104279:	8b 45 08             	mov    0x8(%ebp),%eax
8010427c:	83 ec 0c             	sub    $0xc,%esp
8010427f:	50                   	push   %eax
80104280:	e8 7b 0e 00 00       	call   80105100 <release>
80104285:	83 c4 10             	add    $0x10,%esp
        return -1;
80104288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428d:	e9 a8 00 00 00       	jmp    8010433a <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104292:	8b 45 08             	mov    0x8(%ebp),%eax
80104295:	05 34 02 00 00       	add    $0x234,%eax
8010429a:	83 ec 0c             	sub    $0xc,%esp
8010429d:	50                   	push   %eax
8010429e:	e8 e2 0b 00 00       	call   80104e85 <wakeup>
801042a3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042a6:	8b 45 08             	mov    0x8(%ebp),%eax
801042a9:	8b 55 08             	mov    0x8(%ebp),%edx
801042ac:	81 c2 38 02 00 00    	add    $0x238,%edx
801042b2:	83 ec 08             	sub    $0x8,%esp
801042b5:	50                   	push   %eax
801042b6:	52                   	push   %edx
801042b7:	e8 db 0a 00 00       	call   80104d97 <sleep>
801042bc:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042c8:	8b 45 08             	mov    0x8(%ebp),%eax
801042cb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042d1:	05 00 02 00 00       	add    $0x200,%eax
801042d6:	39 c2                	cmp    %eax,%edx
801042d8:	74 85                	je     8010425f <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e3:	8d 48 01             	lea    0x1(%eax),%ecx
801042e6:	8b 55 08             	mov    0x8(%ebp),%edx
801042e9:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042ef:	25 ff 01 00 00       	and    $0x1ff,%eax
801042f4:	89 c1                	mov    %eax,%ecx
801042f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042fc:	01 d0                	add    %edx,%eax
801042fe:	0f b6 10             	movzbl (%eax),%edx
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104308:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104312:	7c ab                	jl     801042bf <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104314:	8b 45 08             	mov    0x8(%ebp),%eax
80104317:	05 34 02 00 00       	add    $0x234,%eax
8010431c:	83 ec 0c             	sub    $0xc,%esp
8010431f:	50                   	push   %eax
80104320:	e8 60 0b 00 00       	call   80104e85 <wakeup>
80104325:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104328:	8b 45 08             	mov    0x8(%ebp),%eax
8010432b:	83 ec 0c             	sub    $0xc,%esp
8010432e:	50                   	push   %eax
8010432f:	e8 cc 0d 00 00       	call   80105100 <release>
80104334:	83 c4 10             	add    $0x10,%esp
  return n;
80104337:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010433a:	c9                   	leave  
8010433b:	c3                   	ret    

8010433c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010433c:	55                   	push   %ebp
8010433d:	89 e5                	mov    %esp,%ebp
8010433f:	53                   	push   %ebx
80104340:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	83 ec 0c             	sub    $0xc,%esp
80104349:	50                   	push   %eax
8010434a:	e8 4a 0d 00 00       	call   80105099 <acquire>
8010434f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104352:	eb 3f                	jmp    80104393 <piperead+0x57>
    if(proc->killed){
80104354:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010435a:	8b 40 24             	mov    0x24(%eax),%eax
8010435d:	85 c0                	test   %eax,%eax
8010435f:	74 19                	je     8010437a <piperead+0x3e>
      release(&p->lock);
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	83 ec 0c             	sub    $0xc,%esp
80104367:	50                   	push   %eax
80104368:	e8 93 0d 00 00       	call   80105100 <release>
8010436d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104375:	e9 bf 00 00 00       	jmp    80104439 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010437a:	8b 45 08             	mov    0x8(%ebp),%eax
8010437d:	8b 55 08             	mov    0x8(%ebp),%edx
80104380:	81 c2 34 02 00 00    	add    $0x234,%edx
80104386:	83 ec 08             	sub    $0x8,%esp
80104389:	50                   	push   %eax
8010438a:	52                   	push   %edx
8010438b:	e8 07 0a 00 00       	call   80104d97 <sleep>
80104390:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104393:	8b 45 08             	mov    0x8(%ebp),%eax
80104396:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439c:	8b 45 08             	mov    0x8(%ebp),%eax
8010439f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a5:	39 c2                	cmp    %eax,%edx
801043a7:	75 0d                	jne    801043b6 <piperead+0x7a>
801043a9:	8b 45 08             	mov    0x8(%ebp),%eax
801043ac:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b2:	85 c0                	test   %eax,%eax
801043b4:	75 9e                	jne    80104354 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043bd:	eb 49                	jmp    80104408 <piperead+0xcc>
    if(p->nread == p->nwrite)
801043bf:	8b 45 08             	mov    0x8(%ebp),%eax
801043c2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c8:	8b 45 08             	mov    0x8(%ebp),%eax
801043cb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d1:	39 c2                	cmp    %eax,%edx
801043d3:	74 3d                	je     80104412 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801043db:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043de:	8b 45 08             	mov    0x8(%ebp),%eax
801043e1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043e7:	8d 48 01             	lea    0x1(%eax),%ecx
801043ea:	8b 55 08             	mov    0x8(%ebp),%edx
801043ed:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801043f8:	89 c2                	mov    %eax,%edx
801043fa:	8b 45 08             	mov    0x8(%ebp),%eax
801043fd:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104402:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104404:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010440e:	7c af                	jl     801043bf <piperead+0x83>
80104410:	eb 01                	jmp    80104413 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104412:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	05 38 02 00 00       	add    $0x238,%eax
8010441b:	83 ec 0c             	sub    $0xc,%esp
8010441e:	50                   	push   %eax
8010441f:	e8 61 0a 00 00       	call   80104e85 <wakeup>
80104424:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104427:	8b 45 08             	mov    0x8(%ebp),%eax
8010442a:	83 ec 0c             	sub    $0xc,%esp
8010442d:	50                   	push   %eax
8010442e:	e8 cd 0c 00 00       	call   80105100 <release>
80104433:	83 c4 10             	add    $0x10,%esp
  return i;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010443c:	c9                   	leave  
8010443d:	c3                   	ret    

8010443e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010443e:	55                   	push   %ebp
8010443f:	89 e5                	mov    %esp,%ebp
80104441:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104444:	9c                   	pushf  
80104445:	58                   	pop    %eax
80104446:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104449:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010444c:	c9                   	leave  
8010444d:	c3                   	ret    

8010444e <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010444e:	55                   	push   %ebp
8010444f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104451:	fb                   	sti    
}
80104452:	90                   	nop
80104453:	5d                   	pop    %ebp
80104454:	c3                   	ret    

80104455 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104455:	55                   	push   %ebp
80104456:	89 e5                	mov    %esp,%ebp
80104458:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010445b:	83 ec 08             	sub    $0x8,%esp
8010445e:	68 0c 89 10 80       	push   $0x8010890c
80104463:	68 60 29 11 80       	push   $0x80112960
80104468:	e8 0a 0c 00 00       	call   80105077 <initlock>
8010446d:	83 c4 10             	add    $0x10,%esp
}
80104470:	90                   	nop
80104471:	c9                   	leave  
80104472:	c3                   	ret    

80104473 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104473:	55                   	push   %ebp
80104474:	89 e5                	mov    %esp,%ebp
80104476:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104479:	83 ec 0c             	sub    $0xc,%esp
8010447c:	68 60 29 11 80       	push   $0x80112960
80104481:	e8 13 0c 00 00       	call   80105099 <acquire>
80104486:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104489:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104490:	eb 11                	jmp    801044a3 <allocproc+0x30>
    if(p->state == UNUSED)
80104492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104495:	8b 40 0c             	mov    0xc(%eax),%eax
80104498:	85 c0                	test   %eax,%eax
8010449a:	74 2a                	je     801044c6 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010449c:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801044a3:	81 7d f4 94 4b 11 80 	cmpl   $0x80114b94,-0xc(%ebp)
801044aa:	72 e6                	jb     80104492 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801044ac:	83 ec 0c             	sub    $0xc,%esp
801044af:	68 60 29 11 80       	push   $0x80112960
801044b4:	e8 47 0c 00 00       	call   80105100 <release>
801044b9:	83 c4 10             	add    $0x10,%esp
  return 0;
801044bc:	b8 00 00 00 00       	mov    $0x0,%eax
801044c1:	e9 b4 00 00 00       	jmp    8010457a <allocproc+0x107>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801044c6:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ca:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044d1:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044d6:	8d 50 01             	lea    0x1(%eax),%edx
801044d9:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e2:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801044e5:	83 ec 0c             	sub    $0xc,%esp
801044e8:	68 60 29 11 80       	push   $0x80112960
801044ed:	e8 0e 0c 00 00       	call   80105100 <release>
801044f2:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801044f5:	e8 6c e7 ff ff       	call   80102c66 <kalloc>
801044fa:	89 c2                	mov    %eax,%edx
801044fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ff:	89 50 08             	mov    %edx,0x8(%eax)
80104502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104505:	8b 40 08             	mov    0x8(%eax),%eax
80104508:	85 c0                	test   %eax,%eax
8010450a:	75 11                	jne    8010451d <allocproc+0xaa>
    p->state = UNUSED;
8010450c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104516:	b8 00 00 00 00       	mov    $0x0,%eax
8010451b:	eb 5d                	jmp    8010457a <allocproc+0x107>
  }
  sp = p->kstack + KSTACKSIZE;
8010451d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104520:	8b 40 08             	mov    0x8(%eax),%eax
80104523:	05 00 10 00 00       	add    $0x1000,%eax
80104528:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010452b:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010452f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104532:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104535:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104538:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010453c:	ba d6 66 10 80       	mov    $0x801066d6,%edx
80104541:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104544:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104546:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010454a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104550:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104556:	8b 40 1c             	mov    0x1c(%eax),%eax
80104559:	83 ec 04             	sub    $0x4,%esp
8010455c:	6a 14                	push   $0x14
8010455e:	6a 00                	push   $0x0
80104560:	50                   	push   %eax
80104561:	e8 96 0d 00 00       	call   801052fc <memset>
80104566:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010456f:	ba 51 4d 10 80       	mov    $0x80104d51,%edx
80104574:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104577:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010457a:	c9                   	leave  
8010457b:	c3                   	ret    

8010457c <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010457c:	55                   	push   %ebp
8010457d:	89 e5                	mov    %esp,%ebp
8010457f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104582:	e8 ec fe ff ff       	call   80104473 <allocproc>
80104587:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010458a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458d:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
80104592:	e8 04 38 00 00       	call   80107d9b <setupkvm>
80104597:	89 c2                	mov    %eax,%edx
80104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459c:	89 50 04             	mov    %edx,0x4(%eax)
8010459f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a2:	8b 40 04             	mov    0x4(%eax),%eax
801045a5:	85 c0                	test   %eax,%eax
801045a7:	75 0d                	jne    801045b6 <userinit+0x3a>
    panic("userinit: out of memory?");
801045a9:	83 ec 0c             	sub    $0xc,%esp
801045ac:	68 13 89 10 80       	push   $0x80108913
801045b1:	e8 b0 bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045b6:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045be:	8b 40 04             	mov    0x4(%eax),%eax
801045c1:	83 ec 04             	sub    $0x4,%esp
801045c4:	52                   	push   %edx
801045c5:	68 e0 b4 10 80       	push   $0x8010b4e0
801045ca:	50                   	push   %eax
801045cb:	e8 25 3a 00 00       	call   80107ff5 <inituvm>
801045d0:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801045d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d6:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	8b 40 18             	mov    0x18(%eax),%eax
801045e2:	83 ec 04             	sub    $0x4,%esp
801045e5:	6a 4c                	push   $0x4c
801045e7:	6a 00                	push   $0x0
801045e9:	50                   	push   %eax
801045ea:	e8 0d 0d 00 00       	call   801052fc <memset>
801045ef:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801045f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f5:	8b 40 18             	mov    0x18(%eax),%eax
801045f8:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801045fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104601:	8b 40 18             	mov    0x18(%eax),%eax
80104604:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010460a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460d:	8b 40 18             	mov    0x18(%eax),%eax
80104610:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104613:	8b 52 18             	mov    0x18(%edx),%edx
80104616:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010461a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010461e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104621:	8b 40 18             	mov    0x18(%eax),%eax
80104624:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104627:	8b 52 18             	mov    0x18(%edx),%edx
8010462a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010462e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104635:	8b 40 18             	mov    0x18(%eax),%eax
80104638:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010463f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104642:	8b 40 18             	mov    0x18(%eax),%eax
80104645:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464f:	8b 40 18             	mov    0x18(%eax),%eax
80104652:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465c:	83 c0 6c             	add    $0x6c,%eax
8010465f:	83 ec 04             	sub    $0x4,%esp
80104662:	6a 10                	push   $0x10
80104664:	68 2c 89 10 80       	push   $0x8010892c
80104669:	50                   	push   %eax
8010466a:	e8 90 0e 00 00       	call   801054ff <safestrcpy>
8010466f:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104672:	83 ec 0c             	sub    $0xc,%esp
80104675:	68 35 89 10 80       	push   $0x80108935
8010467a:	e8 a9 de ff ff       	call   80102528 <namei>
8010467f:	83 c4 10             	add    $0x10,%esp
80104682:	89 c2                	mov    %eax,%edx
80104684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104687:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104694:	90                   	nop
80104695:	c9                   	leave  
80104696:	c3                   	ret    

80104697 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104697:	55                   	push   %ebp
80104698:	89 e5                	mov    %esp,%ebp
8010469a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
8010469d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a3:	8b 00                	mov    (%eax),%eax
801046a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046ac:	7e 31                	jle    801046df <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046ae:	8b 55 08             	mov    0x8(%ebp),%edx
801046b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b4:	01 c2                	add    %eax,%edx
801046b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bc:	8b 40 04             	mov    0x4(%eax),%eax
801046bf:	83 ec 04             	sub    $0x4,%esp
801046c2:	52                   	push   %edx
801046c3:	ff 75 f4             	pushl  -0xc(%ebp)
801046c6:	50                   	push   %eax
801046c7:	e8 76 3a 00 00       	call   80108142 <allocuvm>
801046cc:	83 c4 10             	add    $0x10,%esp
801046cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046d6:	75 3e                	jne    80104716 <growproc+0x7f>
      return -1;
801046d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046dd:	eb 59                	jmp    80104738 <growproc+0xa1>
  } else if(n < 0){
801046df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046e3:	79 31                	jns    80104716 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801046e5:	8b 55 08             	mov    0x8(%ebp),%edx
801046e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046eb:	01 c2                	add    %eax,%edx
801046ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f3:	8b 40 04             	mov    0x4(%eax),%eax
801046f6:	83 ec 04             	sub    $0x4,%esp
801046f9:	52                   	push   %edx
801046fa:	ff 75 f4             	pushl  -0xc(%ebp)
801046fd:	50                   	push   %eax
801046fe:	e8 08 3b 00 00       	call   8010820b <deallocuvm>
80104703:	83 c4 10             	add    $0x10,%esp
80104706:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104709:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010470d:	75 07                	jne    80104716 <growproc+0x7f>
      return -1;
8010470f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104714:	eb 22                	jmp    80104738 <growproc+0xa1>
  }
  proc->sz = sz;
80104716:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471f:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104721:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104727:	83 ec 0c             	sub    $0xc,%esp
8010472a:	50                   	push   %eax
8010472b:	e8 52 37 00 00       	call   80107e82 <switchuvm>
80104730:	83 c4 10             	add    $0x10,%esp
  return 0;
80104733:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104738:	c9                   	leave  
80104739:	c3                   	ret    

8010473a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010473a:	55                   	push   %ebp
8010473b:	89 e5                	mov    %esp,%ebp
8010473d:	57                   	push   %edi
8010473e:	56                   	push   %esi
8010473f:	53                   	push   %ebx
80104740:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104743:	e8 2b fd ff ff       	call   80104473 <allocproc>
80104748:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010474b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010474f:	75 0a                	jne    8010475b <fork+0x21>
    return -1;
80104751:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104756:	e9 68 01 00 00       	jmp    801048c3 <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010475b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104761:	8b 10                	mov    (%eax),%edx
80104763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104769:	8b 40 04             	mov    0x4(%eax),%eax
8010476c:	83 ec 08             	sub    $0x8,%esp
8010476f:	52                   	push   %edx
80104770:	50                   	push   %eax
80104771:	e8 33 3c 00 00       	call   801083a9 <copyuvm>
80104776:	83 c4 10             	add    $0x10,%esp
80104779:	89 c2                	mov    %eax,%edx
8010477b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010477e:	89 50 04             	mov    %edx,0x4(%eax)
80104781:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104784:	8b 40 04             	mov    0x4(%eax),%eax
80104787:	85 c0                	test   %eax,%eax
80104789:	75 30                	jne    801047bb <fork+0x81>
    kfree(np->kstack);
8010478b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478e:	8b 40 08             	mov    0x8(%eax),%eax
80104791:	83 ec 0c             	sub    $0xc,%esp
80104794:	50                   	push   %eax
80104795:	e8 2f e4 ff ff       	call   80102bc9 <kfree>
8010479a:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010479d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047aa:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047b6:	e9 08 01 00 00       	jmp    801048c3 <fork+0x189>
  }
  np->sz = proc->sz;
801047bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c1:	8b 10                	mov    (%eax),%edx
801047c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c6:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047c8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801047d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d8:	8b 50 18             	mov    0x18(%eax),%edx
801047db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e1:	8b 40 18             	mov    0x18(%eax),%eax
801047e4:	89 c3                	mov    %eax,%ebx
801047e6:	b8 13 00 00 00       	mov    $0x13,%eax
801047eb:	89 d7                	mov    %edx,%edi
801047ed:	89 de                	mov    %ebx,%esi
801047ef:	89 c1                	mov    %eax,%ecx
801047f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801047f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f6:	8b 40 18             	mov    0x18(%eax),%eax
801047f9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104800:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104807:	eb 43                	jmp    8010484c <fork+0x112>
    if(proc->ofile[i])
80104809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104812:	83 c2 08             	add    $0x8,%edx
80104815:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104819:	85 c0                	test   %eax,%eax
8010481b:	74 2b                	je     80104848 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
8010481d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104823:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104826:	83 c2 08             	add    $0x8,%edx
80104829:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010482d:	83 ec 0c             	sub    $0xc,%esp
80104830:	50                   	push   %eax
80104831:	e8 ca c7 ff ff       	call   80101000 <filedup>
80104836:	83 c4 10             	add    $0x10,%esp
80104839:	89 c1                	mov    %eax,%ecx
8010483b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010483e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104841:	83 c2 08             	add    $0x8,%edx
80104844:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104848:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010484c:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104850:	7e b7                	jle    80104809 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104852:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104858:	8b 40 68             	mov    0x68(%eax),%eax
8010485b:	83 ec 0c             	sub    $0xc,%esp
8010485e:	50                   	push   %eax
8010485f:	e8 cc d0 ff ff       	call   80101930 <idup>
80104864:	83 c4 10             	add    $0x10,%esp
80104867:	89 c2                	mov    %eax,%edx
80104869:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010486c:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010486f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104875:	8d 50 6c             	lea    0x6c(%eax),%edx
80104878:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487b:	83 c0 6c             	add    $0x6c,%eax
8010487e:	83 ec 04             	sub    $0x4,%esp
80104881:	6a 10                	push   $0x10
80104883:	52                   	push   %edx
80104884:	50                   	push   %eax
80104885:	e8 75 0c 00 00       	call   801054ff <safestrcpy>
8010488a:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
8010488d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104890:	8b 40 10             	mov    0x10(%eax),%eax
80104893:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104896:	83 ec 0c             	sub    $0xc,%esp
80104899:	68 60 29 11 80       	push   $0x80112960
8010489e:	e8 f6 07 00 00       	call   80105099 <acquire>
801048a3:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048a9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048b0:	83 ec 0c             	sub    $0xc,%esp
801048b3:	68 60 29 11 80       	push   $0x80112960
801048b8:	e8 43 08 00 00       	call   80105100 <release>
801048bd:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048c6:	5b                   	pop    %ebx
801048c7:	5e                   	pop    %esi
801048c8:	5f                   	pop    %edi
801048c9:	5d                   	pop    %ebp
801048ca:	c3                   	ret    

801048cb <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048cb:	55                   	push   %ebp
801048cc:	89 e5                	mov    %esp,%ebp
801048ce:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048d1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048d8:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048dd:	39 c2                	cmp    %eax,%edx
801048df:	75 0d                	jne    801048ee <exit+0x23>
    panic("init exiting");
801048e1:	83 ec 0c             	sub    $0xc,%esp
801048e4:	68 37 89 10 80       	push   $0x80108937
801048e9:	e8 78 bc ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801048ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801048f5:	eb 48                	jmp    8010493f <exit+0x74>
    if(proc->ofile[fd]){
801048f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104900:	83 c2 08             	add    $0x8,%edx
80104903:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104907:	85 c0                	test   %eax,%eax
80104909:	74 30                	je     8010493b <exit+0x70>
      fileclose(proc->ofile[fd]);
8010490b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104911:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104914:	83 c2 08             	add    $0x8,%edx
80104917:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010491b:	83 ec 0c             	sub    $0xc,%esp
8010491e:	50                   	push   %eax
8010491f:	e8 2d c7 ff ff       	call   80101051 <fileclose>
80104924:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104927:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104930:	83 c2 08             	add    $0x8,%edx
80104933:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010493a:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010493b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010493f:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104943:	7e b2                	jle    801048f7 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104945:	e8 03 ec ff ff       	call   8010354d <begin_op>
  iput(proc->cwd);
8010494a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104950:	8b 40 68             	mov    0x68(%eax),%eax
80104953:	83 ec 0c             	sub    $0xc,%esp
80104956:	50                   	push   %eax
80104957:	e8 de d1 ff ff       	call   80101b3a <iput>
8010495c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010495f:	e8 75 ec ff ff       	call   801035d9 <end_op>
  proc->cwd = 0;
80104964:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104971:	83 ec 0c             	sub    $0xc,%esp
80104974:	68 60 29 11 80       	push   $0x80112960
80104979:	e8 1b 07 00 00       	call   80105099 <acquire>
8010497e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104987:	8b 40 14             	mov    0x14(%eax),%eax
8010498a:	83 ec 0c             	sub    $0xc,%esp
8010498d:	50                   	push   %eax
8010498e:	e8 b0 04 00 00       	call   80104e43 <wakeup1>
80104993:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104996:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010499d:	eb 3f                	jmp    801049de <exit+0x113>
    if(p->parent == proc){
8010499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a2:	8b 50 14             	mov    0x14(%eax),%edx
801049a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ab:	39 c2                	cmp    %eax,%edx
801049ad:	75 28                	jne    801049d7 <exit+0x10c>
      p->parent = initproc;
801049af:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801049b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b8:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	8b 40 0c             	mov    0xc(%eax),%eax
801049c1:	83 f8 05             	cmp    $0x5,%eax
801049c4:	75 11                	jne    801049d7 <exit+0x10c>
        wakeup1(initproc);
801049c6:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801049cb:	83 ec 0c             	sub    $0xc,%esp
801049ce:	50                   	push   %eax
801049cf:	e8 6f 04 00 00       	call   80104e43 <wakeup1>
801049d4:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d7:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801049de:	81 7d f4 94 4b 11 80 	cmpl   $0x80114b94,-0xc(%ebp)
801049e5:	72 b8                	jb     8010499f <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801049e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ed:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801049f4:	e8 61 02 00 00       	call   80104c5a <sched>
  panic("zombie exit");
801049f9:	83 ec 0c             	sub    $0xc,%esp
801049fc:	68 44 89 10 80       	push   $0x80108944
80104a01:	e8 60 bb ff ff       	call   80100566 <panic>

80104a06 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a06:	55                   	push   %ebp
80104a07:	89 e5                	mov    %esp,%ebp
80104a09:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a0c:	83 ec 0c             	sub    $0xc,%esp
80104a0f:	68 60 29 11 80       	push   $0x80112960
80104a14:	e8 80 06 00 00       	call   80105099 <acquire>
80104a19:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a1c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a23:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a2a:	e9 a9 00 00 00       	jmp    80104ad8 <wait+0xd2>
      if(p->parent != proc)
80104a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a32:	8b 50 14             	mov    0x14(%eax),%edx
80104a35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3b:	39 c2                	cmp    %eax,%edx
80104a3d:	0f 85 8d 00 00 00    	jne    80104ad0 <wait+0xca>
        continue;
      havekids = 1;
80104a43:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104a50:	83 f8 05             	cmp    $0x5,%eax
80104a53:	75 7c                	jne    80104ad1 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a58:	8b 40 10             	mov    0x10(%eax),%eax
80104a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a61:	8b 40 08             	mov    0x8(%eax),%eax
80104a64:	83 ec 0c             	sub    $0xc,%esp
80104a67:	50                   	push   %eax
80104a68:	e8 5c e1 ff ff       	call   80102bc9 <kfree>
80104a6d:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7d:	8b 40 04             	mov    0x4(%eax),%eax
80104a80:	83 ec 0c             	sub    $0xc,%esp
80104a83:	50                   	push   %eax
80104a84:	e8 3f 38 00 00       	call   801082c8 <freevm>
80104a89:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a99:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aad:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104abb:	83 ec 0c             	sub    $0xc,%esp
80104abe:	68 60 29 11 80       	push   $0x80112960
80104ac3:	e8 38 06 00 00       	call   80105100 <release>
80104ac8:	83 c4 10             	add    $0x10,%esp
        return pid;
80104acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ace:	eb 5b                	jmp    80104b2b <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104ad0:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad1:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104ad8:	81 7d f4 94 4b 11 80 	cmpl   $0x80114b94,-0xc(%ebp)
80104adf:	0f 82 4a ff ff ff    	jb     80104a2f <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104ae5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ae9:	74 0d                	je     80104af8 <wait+0xf2>
80104aeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af1:	8b 40 24             	mov    0x24(%eax),%eax
80104af4:	85 c0                	test   %eax,%eax
80104af6:	74 17                	je     80104b0f <wait+0x109>
      release(&ptable.lock);
80104af8:	83 ec 0c             	sub    $0xc,%esp
80104afb:	68 60 29 11 80       	push   $0x80112960
80104b00:	e8 fb 05 00 00       	call   80105100 <release>
80104b05:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b0d:	eb 1c                	jmp    80104b2b <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b15:	83 ec 08             	sub    $0x8,%esp
80104b18:	68 60 29 11 80       	push   $0x80112960
80104b1d:	50                   	push   %eax
80104b1e:	e8 74 02 00 00       	call   80104d97 <sleep>
80104b23:	83 c4 10             	add    $0x10,%esp
  }
80104b26:	e9 f1 fe ff ff       	jmp    80104a1c <wait+0x16>
}
80104b2b:	c9                   	leave  
80104b2c:	c3                   	ret    

80104b2d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b2d:	55                   	push   %ebp
80104b2e:	89 e5                	mov    %esp,%ebp
80104b30:	53                   	push   %ebx
80104b31:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b34:	e8 15 f9 ff ff       	call   8010444e <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b39:	83 ec 0c             	sub    $0xc,%esp
80104b3c:	68 60 29 11 80       	push   $0x80112960
80104b41:	e8 53 05 00 00       	call   80105099 <acquire>
80104b46:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b49:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104b50:	e9 e3 00 00 00       	jmp    80104c38 <scheduler+0x10b>
      if(p->state != RUNNABLE)
80104b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b58:	8b 40 0c             	mov    0xc(%eax),%eax
80104b5b:	83 f8 03             	cmp    $0x3,%eax
80104b5e:	0f 85 cc 00 00 00    	jne    80104c30 <scheduler+0x103>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b67:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b6d:	83 ec 0c             	sub    $0xc,%esp
80104b70:	ff 75 f4             	pushl  -0xc(%ebp)
80104b73:	e8 0a 33 00 00       	call   80107e82 <switchuvm>
80104b78:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      if (strncmp(p->name, "sh", 2) == 0 || strncmp(p->name, "spin", 4) == 0) {
80104b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b88:	83 c0 6c             	add    $0x6c,%eax
80104b8b:	83 ec 04             	sub    $0x4,%esp
80104b8e:	6a 02                	push   $0x2
80104b90:	68 50 89 10 80       	push   $0x80108950
80104b95:	50                   	push   %eax
80104b96:	e8 b6 08 00 00       	call   80105451 <strncmp>
80104b9b:	83 c4 10             	add    $0x10,%esp
80104b9e:	85 c0                	test   %eax,%eax
80104ba0:	74 1d                	je     80104bbf <scheduler+0x92>
80104ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba5:	83 c0 6c             	add    $0x6c,%eax
80104ba8:	83 ec 04             	sub    $0x4,%esp
80104bab:	6a 04                	push   $0x4
80104bad:	68 53 89 10 80       	push   $0x80108953
80104bb2:	50                   	push   %eax
80104bb3:	e8 99 08 00 00       	call   80105451 <strncmp>
80104bb8:	83 c4 10             	add    $0x10,%esp
80104bbb:	85 c0                	test   %eax,%eax
80104bbd:	75 3f                	jne    80104bfe <scheduler+0xd1>
        cprintf("Process %s is of Process ID %d,  Queue Type %d, Quantum Size %d", p->name, p->pid, p->queuetype, p->quantumsize);
80104bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc2:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80104bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcb:	8b 50 7c             	mov    0x7c(%eax),%edx
80104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd1:	8b 40 10             	mov    0x10(%eax),%eax
80104bd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80104bd7:	83 c3 6c             	add    $0x6c,%ebx
80104bda:	83 ec 0c             	sub    $0xc,%esp
80104bdd:	51                   	push   %ecx
80104bde:	52                   	push   %edx
80104bdf:	50                   	push   %eax
80104be0:	53                   	push   %ebx
80104be1:	68 58 89 10 80       	push   $0x80108958
80104be6:	e8 db b7 ff ff       	call   801003c6 <cprintf>
80104beb:	83 c4 20             	add    $0x20,%esp
        cprintf("\n");
80104bee:	83 ec 0c             	sub    $0xc,%esp
80104bf1:	68 98 89 10 80       	push   $0x80108998
80104bf6:	e8 cb b7 ff ff       	call   801003c6 <cprintf>
80104bfb:	83 c4 10             	add    $0x10,%esp
      }
      swtch(&cpu->scheduler, proc->context);
80104bfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c04:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c07:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c0e:	83 c2 04             	add    $0x4,%edx
80104c11:	83 ec 08             	sub    $0x8,%esp
80104c14:	50                   	push   %eax
80104c15:	52                   	push   %edx
80104c16:	e8 55 09 00 00       	call   80105570 <swtch>
80104c1b:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104c1e:	e8 42 32 00 00       	call   80107e65 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c23:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c2a:	00 00 00 00 
80104c2e:	eb 01                	jmp    80104c31 <scheduler+0x104>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104c30:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c31:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104c38:	81 7d f4 94 4b 11 80 	cmpl   $0x80114b94,-0xc(%ebp)
80104c3f:	0f 82 10 ff ff ff    	jb     80104b55 <scheduler+0x28>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104c45:	83 ec 0c             	sub    $0xc,%esp
80104c48:	68 60 29 11 80       	push   $0x80112960
80104c4d:	e8 ae 04 00 00       	call   80105100 <release>
80104c52:	83 c4 10             	add    $0x10,%esp

  }
80104c55:	e9 da fe ff ff       	jmp    80104b34 <scheduler+0x7>

80104c5a <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c5a:	55                   	push   %ebp
80104c5b:	89 e5                	mov    %esp,%ebp
80104c5d:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c60:	83 ec 0c             	sub    $0xc,%esp
80104c63:	68 60 29 11 80       	push   $0x80112960
80104c68:	e8 5f 05 00 00       	call   801051cc <holding>
80104c6d:	83 c4 10             	add    $0x10,%esp
80104c70:	85 c0                	test   %eax,%eax
80104c72:	75 0d                	jne    80104c81 <sched+0x27>
    panic("sched ptable.lock");
80104c74:	83 ec 0c             	sub    $0xc,%esp
80104c77:	68 9a 89 10 80       	push   $0x8010899a
80104c7c:	e8 e5 b8 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104c81:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c87:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c8d:	83 f8 01             	cmp    $0x1,%eax
80104c90:	74 0d                	je     80104c9f <sched+0x45>
    panic("sched locks");
80104c92:	83 ec 0c             	sub    $0xc,%esp
80104c95:	68 ac 89 10 80       	push   $0x801089ac
80104c9a:	e8 c7 b8 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104c9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca8:	83 f8 04             	cmp    $0x4,%eax
80104cab:	75 0d                	jne    80104cba <sched+0x60>
    panic("sched running");
80104cad:	83 ec 0c             	sub    $0xc,%esp
80104cb0:	68 b8 89 10 80       	push   $0x801089b8
80104cb5:	e8 ac b8 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104cba:	e8 7f f7 ff ff       	call   8010443e <readeflags>
80104cbf:	25 00 02 00 00       	and    $0x200,%eax
80104cc4:	85 c0                	test   %eax,%eax
80104cc6:	74 0d                	je     80104cd5 <sched+0x7b>
    panic("sched interruptible");
80104cc8:	83 ec 0c             	sub    $0xc,%esp
80104ccb:	68 c6 89 10 80       	push   $0x801089c6
80104cd0:	e8 91 b8 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104cd5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cdb:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104ce1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104ce4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cea:	8b 40 04             	mov    0x4(%eax),%eax
80104ced:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cf4:	83 c2 1c             	add    $0x1c,%edx
80104cf7:	83 ec 08             	sub    $0x8,%esp
80104cfa:	50                   	push   %eax
80104cfb:	52                   	push   %edx
80104cfc:	e8 6f 08 00 00       	call   80105570 <swtch>
80104d01:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104d04:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d0d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d13:	90                   	nop
80104d14:	c9                   	leave  
80104d15:	c3                   	ret    

80104d16 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d16:	55                   	push   %ebp
80104d17:	89 e5                	mov    %esp,%ebp
80104d19:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d1c:	83 ec 0c             	sub    $0xc,%esp
80104d1f:	68 60 29 11 80       	push   $0x80112960
80104d24:	e8 70 03 00 00       	call   80105099 <acquire>
80104d29:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d32:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d39:	e8 1c ff ff ff       	call   80104c5a <sched>
  release(&ptable.lock);
80104d3e:	83 ec 0c             	sub    $0xc,%esp
80104d41:	68 60 29 11 80       	push   $0x80112960
80104d46:	e8 b5 03 00 00       	call   80105100 <release>
80104d4b:	83 c4 10             	add    $0x10,%esp
}
80104d4e:	90                   	nop
80104d4f:	c9                   	leave  
80104d50:	c3                   	ret    

80104d51 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d51:	55                   	push   %ebp
80104d52:	89 e5                	mov    %esp,%ebp
80104d54:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d57:	83 ec 0c             	sub    $0xc,%esp
80104d5a:	68 60 29 11 80       	push   $0x80112960
80104d5f:	e8 9c 03 00 00       	call   80105100 <release>
80104d64:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d67:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d6c:	85 c0                	test   %eax,%eax
80104d6e:	74 24                	je     80104d94 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d70:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d77:	00 00 00 
    iinit(ROOTDEV);
80104d7a:	83 ec 0c             	sub    $0xc,%esp
80104d7d:	6a 01                	push   $0x1
80104d7f:	e8 ba c8 ff ff       	call   8010163e <iinit>
80104d84:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104d87:	83 ec 0c             	sub    $0xc,%esp
80104d8a:	6a 01                	push   $0x1
80104d8c:	e8 9e e5 ff ff       	call   8010332f <initlog>
80104d91:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d94:	90                   	nop
80104d95:	c9                   	leave  
80104d96:	c3                   	ret    

80104d97 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d97:	55                   	push   %ebp
80104d98:	89 e5                	mov    %esp,%ebp
80104d9a:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da3:	85 c0                	test   %eax,%eax
80104da5:	75 0d                	jne    80104db4 <sleep+0x1d>
    panic("sleep");
80104da7:	83 ec 0c             	sub    $0xc,%esp
80104daa:	68 da 89 10 80       	push   $0x801089da
80104daf:	e8 b2 b7 ff ff       	call   80100566 <panic>

  if(lk == 0)
80104db4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104db8:	75 0d                	jne    80104dc7 <sleep+0x30>
    panic("sleep without lk");
80104dba:	83 ec 0c             	sub    $0xc,%esp
80104dbd:	68 e0 89 10 80       	push   $0x801089e0
80104dc2:	e8 9f b7 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104dc7:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104dce:	74 1e                	je     80104dee <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104dd0:	83 ec 0c             	sub    $0xc,%esp
80104dd3:	68 60 29 11 80       	push   $0x80112960
80104dd8:	e8 bc 02 00 00       	call   80105099 <acquire>
80104ddd:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104de0:	83 ec 0c             	sub    $0xc,%esp
80104de3:	ff 75 0c             	pushl  0xc(%ebp)
80104de6:	e8 15 03 00 00       	call   80105100 <release>
80104deb:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104dee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df4:	8b 55 08             	mov    0x8(%ebp),%edx
80104df7:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104dfa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e00:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e07:	e8 4e fe ff ff       	call   80104c5a <sched>

  // Tidy up.
  proc->chan = 0;
80104e0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e12:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e19:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104e20:	74 1e                	je     80104e40 <sleep+0xa9>
    release(&ptable.lock);
80104e22:	83 ec 0c             	sub    $0xc,%esp
80104e25:	68 60 29 11 80       	push   $0x80112960
80104e2a:	e8 d1 02 00 00       	call   80105100 <release>
80104e2f:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e32:	83 ec 0c             	sub    $0xc,%esp
80104e35:	ff 75 0c             	pushl  0xc(%ebp)
80104e38:	e8 5c 02 00 00       	call   80105099 <acquire>
80104e3d:	83 c4 10             	add    $0x10,%esp
  }
}
80104e40:	90                   	nop
80104e41:	c9                   	leave  
80104e42:	c3                   	ret    

80104e43 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e43:	55                   	push   %ebp
80104e44:	89 e5                	mov    %esp,%ebp
80104e46:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e49:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104e50:	eb 27                	jmp    80104e79 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104e52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e55:	8b 40 0c             	mov    0xc(%eax),%eax
80104e58:	83 f8 02             	cmp    $0x2,%eax
80104e5b:	75 15                	jne    80104e72 <wakeup1+0x2f>
80104e5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e60:	8b 40 20             	mov    0x20(%eax),%eax
80104e63:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e66:	75 0a                	jne    80104e72 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e6b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e72:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104e79:	81 7d fc 94 4b 11 80 	cmpl   $0x80114b94,-0x4(%ebp)
80104e80:	72 d0                	jb     80104e52 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e82:	90                   	nop
80104e83:	c9                   	leave  
80104e84:	c3                   	ret    

80104e85 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e85:	55                   	push   %ebp
80104e86:	89 e5                	mov    %esp,%ebp
80104e88:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e8b:	83 ec 0c             	sub    $0xc,%esp
80104e8e:	68 60 29 11 80       	push   $0x80112960
80104e93:	e8 01 02 00 00       	call   80105099 <acquire>
80104e98:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e9b:	83 ec 0c             	sub    $0xc,%esp
80104e9e:	ff 75 08             	pushl  0x8(%ebp)
80104ea1:	e8 9d ff ff ff       	call   80104e43 <wakeup1>
80104ea6:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104ea9:	83 ec 0c             	sub    $0xc,%esp
80104eac:	68 60 29 11 80       	push   $0x80112960
80104eb1:	e8 4a 02 00 00       	call   80105100 <release>
80104eb6:	83 c4 10             	add    $0x10,%esp
}
80104eb9:	90                   	nop
80104eba:	c9                   	leave  
80104ebb:	c3                   	ret    

80104ebc <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ebc:	55                   	push   %ebp
80104ebd:	89 e5                	mov    %esp,%ebp
80104ebf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ec2:	83 ec 0c             	sub    $0xc,%esp
80104ec5:	68 60 29 11 80       	push   $0x80112960
80104eca:	e8 ca 01 00 00       	call   80105099 <acquire>
80104ecf:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ed2:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104ed9:	eb 48                	jmp    80104f23 <kill+0x67>
    if(p->pid == pid){
80104edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ede:	8b 40 10             	mov    0x10(%eax),%eax
80104ee1:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ee4:	75 36                	jne    80104f1c <kill+0x60>
      p->killed = 1;
80104ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef3:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef6:	83 f8 02             	cmp    $0x2,%eax
80104ef9:	75 0a                	jne    80104f05 <kill+0x49>
        p->state = RUNNABLE;
80104efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104efe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f05:	83 ec 0c             	sub    $0xc,%esp
80104f08:	68 60 29 11 80       	push   $0x80112960
80104f0d:	e8 ee 01 00 00       	call   80105100 <release>
80104f12:	83 c4 10             	add    $0x10,%esp
      return 0;
80104f15:	b8 00 00 00 00       	mov    $0x0,%eax
80104f1a:	eb 25                	jmp    80104f41 <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f1c:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104f23:	81 7d f4 94 4b 11 80 	cmpl   $0x80114b94,-0xc(%ebp)
80104f2a:	72 af                	jb     80104edb <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f2c:	83 ec 0c             	sub    $0xc,%esp
80104f2f:	68 60 29 11 80       	push   $0x80112960
80104f34:	e8 c7 01 00 00       	call   80105100 <release>
80104f39:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f41:	c9                   	leave  
80104f42:	c3                   	ret    

80104f43 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f43:	55                   	push   %ebp
80104f44:	89 e5                	mov    %esp,%ebp
80104f46:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f49:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104f50:	e9 da 00 00 00       	jmp    8010502f <procdump+0xec>
    if(p->state == UNUSED)
80104f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f58:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5b:	85 c0                	test   %eax,%eax
80104f5d:	0f 84 c4 00 00 00    	je     80105027 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f66:	8b 40 0c             	mov    0xc(%eax),%eax
80104f69:	83 f8 05             	cmp    $0x5,%eax
80104f6c:	77 23                	ja     80104f91 <procdump+0x4e>
80104f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f71:	8b 40 0c             	mov    0xc(%eax),%eax
80104f74:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f7b:	85 c0                	test   %eax,%eax
80104f7d:	74 12                	je     80104f91 <procdump+0x4e>
      state = states[p->state];
80104f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f82:	8b 40 0c             	mov    0xc(%eax),%eax
80104f85:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f8f:	eb 07                	jmp    80104f98 <procdump+0x55>
    else
      state = "???";
80104f91:	c7 45 ec f1 89 10 80 	movl   $0x801089f1,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9b:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa1:	8b 40 10             	mov    0x10(%eax),%eax
80104fa4:	52                   	push   %edx
80104fa5:	ff 75 ec             	pushl  -0x14(%ebp)
80104fa8:	50                   	push   %eax
80104fa9:	68 f5 89 10 80       	push   $0x801089f5
80104fae:	e8 13 b4 ff ff       	call   801003c6 <cprintf>
80104fb3:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb9:	8b 40 0c             	mov    0xc(%eax),%eax
80104fbc:	83 f8 02             	cmp    $0x2,%eax
80104fbf:	75 54                	jne    80105015 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc4:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fc7:	8b 40 0c             	mov    0xc(%eax),%eax
80104fca:	83 c0 08             	add    $0x8,%eax
80104fcd:	89 c2                	mov    %eax,%edx
80104fcf:	83 ec 08             	sub    $0x8,%esp
80104fd2:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104fd5:	50                   	push   %eax
80104fd6:	52                   	push   %edx
80104fd7:	e8 76 01 00 00       	call   80105152 <getcallerpcs>
80104fdc:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fe6:	eb 1c                	jmp    80105004 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104feb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fef:	83 ec 08             	sub    $0x8,%esp
80104ff2:	50                   	push   %eax
80104ff3:	68 fe 89 10 80       	push   $0x801089fe
80104ff8:	e8 c9 b3 ff ff       	call   801003c6 <cprintf>
80104ffd:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105000:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105004:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105008:	7f 0b                	jg     80105015 <procdump+0xd2>
8010500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105011:	85 c0                	test   %eax,%eax
80105013:	75 d3                	jne    80104fe8 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105015:	83 ec 0c             	sub    $0xc,%esp
80105018:	68 98 89 10 80       	push   $0x80108998
8010501d:	e8 a4 b3 ff ff       	call   801003c6 <cprintf>
80105022:	83 c4 10             	add    $0x10,%esp
80105025:	eb 01                	jmp    80105028 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105027:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105028:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
8010502f:	81 7d f0 94 4b 11 80 	cmpl   $0x80114b94,-0x10(%ebp)
80105036:	0f 82 19 ff ff ff    	jb     80104f55 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010503c:	90                   	nop
8010503d:	c9                   	leave  
8010503e:	c3                   	ret    

8010503f <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010503f:	55                   	push   %ebp
80105040:	89 e5                	mov    %esp,%ebp
80105042:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105045:	9c                   	pushf  
80105046:	58                   	pop    %eax
80105047:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010504a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010504d:	c9                   	leave  
8010504e:	c3                   	ret    

8010504f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010504f:	55                   	push   %ebp
80105050:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105052:	fa                   	cli    
}
80105053:	90                   	nop
80105054:	5d                   	pop    %ebp
80105055:	c3                   	ret    

80105056 <sti>:

static inline void
sti(void)
{
80105056:	55                   	push   %ebp
80105057:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105059:	fb                   	sti    
}
8010505a:	90                   	nop
8010505b:	5d                   	pop    %ebp
8010505c:	c3                   	ret    

8010505d <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010505d:	55                   	push   %ebp
8010505e:	89 e5                	mov    %esp,%ebp
80105060:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105063:	8b 55 08             	mov    0x8(%ebp),%edx
80105066:	8b 45 0c             	mov    0xc(%ebp),%eax
80105069:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010506c:	f0 87 02             	lock xchg %eax,(%edx)
8010506f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105072:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105075:	c9                   	leave  
80105076:	c3                   	ret    

80105077 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105077:	55                   	push   %ebp
80105078:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010507a:	8b 45 08             	mov    0x8(%ebp),%eax
8010507d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105080:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105083:	8b 45 08             	mov    0x8(%ebp),%eax
80105086:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010508c:	8b 45 08             	mov    0x8(%ebp),%eax
8010508f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105096:	90                   	nop
80105097:	5d                   	pop    %ebp
80105098:	c3                   	ret    

80105099 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105099:	55                   	push   %ebp
8010509a:	89 e5                	mov    %esp,%ebp
8010509c:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010509f:	e8 52 01 00 00       	call   801051f6 <pushcli>
  if(holding(lk))
801050a4:	8b 45 08             	mov    0x8(%ebp),%eax
801050a7:	83 ec 0c             	sub    $0xc,%esp
801050aa:	50                   	push   %eax
801050ab:	e8 1c 01 00 00       	call   801051cc <holding>
801050b0:	83 c4 10             	add    $0x10,%esp
801050b3:	85 c0                	test   %eax,%eax
801050b5:	74 0d                	je     801050c4 <acquire+0x2b>
    panic("acquire");
801050b7:	83 ec 0c             	sub    $0xc,%esp
801050ba:	68 2c 8a 10 80       	push   $0x80108a2c
801050bf:	e8 a2 b4 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050c4:	90                   	nop
801050c5:	8b 45 08             	mov    0x8(%ebp),%eax
801050c8:	83 ec 08             	sub    $0x8,%esp
801050cb:	6a 01                	push   $0x1
801050cd:	50                   	push   %eax
801050ce:	e8 8a ff ff ff       	call   8010505d <xchg>
801050d3:	83 c4 10             	add    $0x10,%esp
801050d6:	85 c0                	test   %eax,%eax
801050d8:	75 eb                	jne    801050c5 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050da:	8b 45 08             	mov    0x8(%ebp),%eax
801050dd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050e4:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050e7:	8b 45 08             	mov    0x8(%ebp),%eax
801050ea:	83 c0 0c             	add    $0xc,%eax
801050ed:	83 ec 08             	sub    $0x8,%esp
801050f0:	50                   	push   %eax
801050f1:	8d 45 08             	lea    0x8(%ebp),%eax
801050f4:	50                   	push   %eax
801050f5:	e8 58 00 00 00       	call   80105152 <getcallerpcs>
801050fa:	83 c4 10             	add    $0x10,%esp
}
801050fd:	90                   	nop
801050fe:	c9                   	leave  
801050ff:	c3                   	ret    

80105100 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105100:	55                   	push   %ebp
80105101:	89 e5                	mov    %esp,%ebp
80105103:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105106:	83 ec 0c             	sub    $0xc,%esp
80105109:	ff 75 08             	pushl  0x8(%ebp)
8010510c:	e8 bb 00 00 00       	call   801051cc <holding>
80105111:	83 c4 10             	add    $0x10,%esp
80105114:	85 c0                	test   %eax,%eax
80105116:	75 0d                	jne    80105125 <release+0x25>
    panic("release");
80105118:	83 ec 0c             	sub    $0xc,%esp
8010511b:	68 34 8a 10 80       	push   $0x80108a34
80105120:	e8 41 b4 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105125:	8b 45 08             	mov    0x8(%ebp),%eax
80105128:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010512f:	8b 45 08             	mov    0x8(%ebp),%eax
80105132:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105139:	8b 45 08             	mov    0x8(%ebp),%eax
8010513c:	83 ec 08             	sub    $0x8,%esp
8010513f:	6a 00                	push   $0x0
80105141:	50                   	push   %eax
80105142:	e8 16 ff ff ff       	call   8010505d <xchg>
80105147:	83 c4 10             	add    $0x10,%esp

  popcli();
8010514a:	e8 ec 00 00 00       	call   8010523b <popcli>
}
8010514f:	90                   	nop
80105150:	c9                   	leave  
80105151:	c3                   	ret    

80105152 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105152:	55                   	push   %ebp
80105153:	89 e5                	mov    %esp,%ebp
80105155:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105158:	8b 45 08             	mov    0x8(%ebp),%eax
8010515b:	83 e8 08             	sub    $0x8,%eax
8010515e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105161:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105168:	eb 38                	jmp    801051a2 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010516a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010516e:	74 53                	je     801051c3 <getcallerpcs+0x71>
80105170:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105177:	76 4a                	jbe    801051c3 <getcallerpcs+0x71>
80105179:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010517d:	74 44                	je     801051c3 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010517f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105182:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105189:	8b 45 0c             	mov    0xc(%ebp),%eax
8010518c:	01 c2                	add    %eax,%edx
8010518e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105191:	8b 40 04             	mov    0x4(%eax),%eax
80105194:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105196:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105199:	8b 00                	mov    (%eax),%eax
8010519b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010519e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051a2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051a6:	7e c2                	jle    8010516a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051a8:	eb 19                	jmp    801051c3 <getcallerpcs+0x71>
    pcs[i] = 0;
801051aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b7:	01 d0                	add    %edx,%eax
801051b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051bf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051c3:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051c7:	7e e1                	jle    801051aa <getcallerpcs+0x58>
    pcs[i] = 0;
}
801051c9:	90                   	nop
801051ca:	c9                   	leave  
801051cb:	c3                   	ret    

801051cc <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051cc:	55                   	push   %ebp
801051cd:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051cf:	8b 45 08             	mov    0x8(%ebp),%eax
801051d2:	8b 00                	mov    (%eax),%eax
801051d4:	85 c0                	test   %eax,%eax
801051d6:	74 17                	je     801051ef <holding+0x23>
801051d8:	8b 45 08             	mov    0x8(%ebp),%eax
801051db:	8b 50 08             	mov    0x8(%eax),%edx
801051de:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051e4:	39 c2                	cmp    %eax,%edx
801051e6:	75 07                	jne    801051ef <holding+0x23>
801051e8:	b8 01 00 00 00       	mov    $0x1,%eax
801051ed:	eb 05                	jmp    801051f4 <holding+0x28>
801051ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051f4:	5d                   	pop    %ebp
801051f5:	c3                   	ret    

801051f6 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051f6:	55                   	push   %ebp
801051f7:	89 e5                	mov    %esp,%ebp
801051f9:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051fc:	e8 3e fe ff ff       	call   8010503f <readeflags>
80105201:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105204:	e8 46 fe ff ff       	call   8010504f <cli>
  if(cpu->ncli++ == 0)
80105209:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105210:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105216:	8d 48 01             	lea    0x1(%eax),%ecx
80105219:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010521f:	85 c0                	test   %eax,%eax
80105221:	75 15                	jne    80105238 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105223:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105229:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010522c:	81 e2 00 02 00 00    	and    $0x200,%edx
80105232:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105238:	90                   	nop
80105239:	c9                   	leave  
8010523a:	c3                   	ret    

8010523b <popcli>:

void
popcli(void)
{
8010523b:	55                   	push   %ebp
8010523c:	89 e5                	mov    %esp,%ebp
8010523e:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105241:	e8 f9 fd ff ff       	call   8010503f <readeflags>
80105246:	25 00 02 00 00       	and    $0x200,%eax
8010524b:	85 c0                	test   %eax,%eax
8010524d:	74 0d                	je     8010525c <popcli+0x21>
    panic("popcli - interruptible");
8010524f:	83 ec 0c             	sub    $0xc,%esp
80105252:	68 3c 8a 10 80       	push   $0x80108a3c
80105257:	e8 0a b3 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
8010525c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105262:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105268:	83 ea 01             	sub    $0x1,%edx
8010526b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105271:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105277:	85 c0                	test   %eax,%eax
80105279:	79 0d                	jns    80105288 <popcli+0x4d>
    panic("popcli");
8010527b:	83 ec 0c             	sub    $0xc,%esp
8010527e:	68 53 8a 10 80       	push   $0x80108a53
80105283:	e8 de b2 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105288:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010528e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105294:	85 c0                	test   %eax,%eax
80105296:	75 15                	jne    801052ad <popcli+0x72>
80105298:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010529e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052a4:	85 c0                	test   %eax,%eax
801052a6:	74 05                	je     801052ad <popcli+0x72>
    sti();
801052a8:	e8 a9 fd ff ff       	call   80105056 <sti>
}
801052ad:	90                   	nop
801052ae:	c9                   	leave  
801052af:	c3                   	ret    

801052b0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052b0:	55                   	push   %ebp
801052b1:	89 e5                	mov    %esp,%ebp
801052b3:	57                   	push   %edi
801052b4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052b8:	8b 55 10             	mov    0x10(%ebp),%edx
801052bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801052be:	89 cb                	mov    %ecx,%ebx
801052c0:	89 df                	mov    %ebx,%edi
801052c2:	89 d1                	mov    %edx,%ecx
801052c4:	fc                   	cld    
801052c5:	f3 aa                	rep stos %al,%es:(%edi)
801052c7:	89 ca                	mov    %ecx,%edx
801052c9:	89 fb                	mov    %edi,%ebx
801052cb:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052ce:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052d1:	90                   	nop
801052d2:	5b                   	pop    %ebx
801052d3:	5f                   	pop    %edi
801052d4:	5d                   	pop    %ebp
801052d5:	c3                   	ret    

801052d6 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801052d6:	55                   	push   %ebp
801052d7:	89 e5                	mov    %esp,%ebp
801052d9:	57                   	push   %edi
801052da:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052db:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052de:	8b 55 10             	mov    0x10(%ebp),%edx
801052e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e4:	89 cb                	mov    %ecx,%ebx
801052e6:	89 df                	mov    %ebx,%edi
801052e8:	89 d1                	mov    %edx,%ecx
801052ea:	fc                   	cld    
801052eb:	f3 ab                	rep stos %eax,%es:(%edi)
801052ed:	89 ca                	mov    %ecx,%edx
801052ef:	89 fb                	mov    %edi,%ebx
801052f1:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052f4:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052f7:	90                   	nop
801052f8:	5b                   	pop    %ebx
801052f9:	5f                   	pop    %edi
801052fa:	5d                   	pop    %ebp
801052fb:	c3                   	ret    

801052fc <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052fc:	55                   	push   %ebp
801052fd:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105302:	83 e0 03             	and    $0x3,%eax
80105305:	85 c0                	test   %eax,%eax
80105307:	75 43                	jne    8010534c <memset+0x50>
80105309:	8b 45 10             	mov    0x10(%ebp),%eax
8010530c:	83 e0 03             	and    $0x3,%eax
8010530f:	85 c0                	test   %eax,%eax
80105311:	75 39                	jne    8010534c <memset+0x50>
    c &= 0xFF;
80105313:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010531a:	8b 45 10             	mov    0x10(%ebp),%eax
8010531d:	c1 e8 02             	shr    $0x2,%eax
80105320:	89 c1                	mov    %eax,%ecx
80105322:	8b 45 0c             	mov    0xc(%ebp),%eax
80105325:	c1 e0 18             	shl    $0x18,%eax
80105328:	89 c2                	mov    %eax,%edx
8010532a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532d:	c1 e0 10             	shl    $0x10,%eax
80105330:	09 c2                	or     %eax,%edx
80105332:	8b 45 0c             	mov    0xc(%ebp),%eax
80105335:	c1 e0 08             	shl    $0x8,%eax
80105338:	09 d0                	or     %edx,%eax
8010533a:	0b 45 0c             	or     0xc(%ebp),%eax
8010533d:	51                   	push   %ecx
8010533e:	50                   	push   %eax
8010533f:	ff 75 08             	pushl  0x8(%ebp)
80105342:	e8 8f ff ff ff       	call   801052d6 <stosl>
80105347:	83 c4 0c             	add    $0xc,%esp
8010534a:	eb 12                	jmp    8010535e <memset+0x62>
  } else
    stosb(dst, c, n);
8010534c:	8b 45 10             	mov    0x10(%ebp),%eax
8010534f:	50                   	push   %eax
80105350:	ff 75 0c             	pushl  0xc(%ebp)
80105353:	ff 75 08             	pushl  0x8(%ebp)
80105356:	e8 55 ff ff ff       	call   801052b0 <stosb>
8010535b:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010535e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105361:	c9                   	leave  
80105362:	c3                   	ret    

80105363 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105363:	55                   	push   %ebp
80105364:	89 e5                	mov    %esp,%ebp
80105366:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105369:	8b 45 08             	mov    0x8(%ebp),%eax
8010536c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010536f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105372:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105375:	eb 30                	jmp    801053a7 <memcmp+0x44>
    if(*s1 != *s2)
80105377:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010537a:	0f b6 10             	movzbl (%eax),%edx
8010537d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105380:	0f b6 00             	movzbl (%eax),%eax
80105383:	38 c2                	cmp    %al,%dl
80105385:	74 18                	je     8010539f <memcmp+0x3c>
      return *s1 - *s2;
80105387:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538a:	0f b6 00             	movzbl (%eax),%eax
8010538d:	0f b6 d0             	movzbl %al,%edx
80105390:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105393:	0f b6 00             	movzbl (%eax),%eax
80105396:	0f b6 c0             	movzbl %al,%eax
80105399:	29 c2                	sub    %eax,%edx
8010539b:	89 d0                	mov    %edx,%eax
8010539d:	eb 1a                	jmp    801053b9 <memcmp+0x56>
    s1++, s2++;
8010539f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053a3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053a7:	8b 45 10             	mov    0x10(%ebp),%eax
801053aa:	8d 50 ff             	lea    -0x1(%eax),%edx
801053ad:	89 55 10             	mov    %edx,0x10(%ebp)
801053b0:	85 c0                	test   %eax,%eax
801053b2:	75 c3                	jne    80105377 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053b9:	c9                   	leave  
801053ba:	c3                   	ret    

801053bb <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053bb:	55                   	push   %ebp
801053bc:	89 e5                	mov    %esp,%ebp
801053be:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053c7:	8b 45 08             	mov    0x8(%ebp),%eax
801053ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053d3:	73 54                	jae    80105429 <memmove+0x6e>
801053d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053d8:	8b 45 10             	mov    0x10(%ebp),%eax
801053db:	01 d0                	add    %edx,%eax
801053dd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053e0:	76 47                	jbe    80105429 <memmove+0x6e>
    s += n;
801053e2:	8b 45 10             	mov    0x10(%ebp),%eax
801053e5:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053e8:	8b 45 10             	mov    0x10(%ebp),%eax
801053eb:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053ee:	eb 13                	jmp    80105403 <memmove+0x48>
      *--d = *--s;
801053f0:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053f4:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053fb:	0f b6 10             	movzbl (%eax),%edx
801053fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105401:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105403:	8b 45 10             	mov    0x10(%ebp),%eax
80105406:	8d 50 ff             	lea    -0x1(%eax),%edx
80105409:	89 55 10             	mov    %edx,0x10(%ebp)
8010540c:	85 c0                	test   %eax,%eax
8010540e:	75 e0                	jne    801053f0 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105410:	eb 24                	jmp    80105436 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105412:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105415:	8d 50 01             	lea    0x1(%eax),%edx
80105418:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010541b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010541e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105421:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105424:	0f b6 12             	movzbl (%edx),%edx
80105427:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105429:	8b 45 10             	mov    0x10(%ebp),%eax
8010542c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010542f:	89 55 10             	mov    %edx,0x10(%ebp)
80105432:	85 c0                	test   %eax,%eax
80105434:	75 dc                	jne    80105412 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105436:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105439:	c9                   	leave  
8010543a:	c3                   	ret    

8010543b <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010543b:	55                   	push   %ebp
8010543c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010543e:	ff 75 10             	pushl  0x10(%ebp)
80105441:	ff 75 0c             	pushl  0xc(%ebp)
80105444:	ff 75 08             	pushl  0x8(%ebp)
80105447:	e8 6f ff ff ff       	call   801053bb <memmove>
8010544c:	83 c4 0c             	add    $0xc,%esp
}
8010544f:	c9                   	leave  
80105450:	c3                   	ret    

80105451 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105451:	55                   	push   %ebp
80105452:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105454:	eb 0c                	jmp    80105462 <strncmp+0x11>
    n--, p++, q++;
80105456:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010545a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010545e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105462:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105466:	74 1a                	je     80105482 <strncmp+0x31>
80105468:	8b 45 08             	mov    0x8(%ebp),%eax
8010546b:	0f b6 00             	movzbl (%eax),%eax
8010546e:	84 c0                	test   %al,%al
80105470:	74 10                	je     80105482 <strncmp+0x31>
80105472:	8b 45 08             	mov    0x8(%ebp),%eax
80105475:	0f b6 10             	movzbl (%eax),%edx
80105478:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547b:	0f b6 00             	movzbl (%eax),%eax
8010547e:	38 c2                	cmp    %al,%dl
80105480:	74 d4                	je     80105456 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105482:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105486:	75 07                	jne    8010548f <strncmp+0x3e>
    return 0;
80105488:	b8 00 00 00 00       	mov    $0x0,%eax
8010548d:	eb 16                	jmp    801054a5 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010548f:	8b 45 08             	mov    0x8(%ebp),%eax
80105492:	0f b6 00             	movzbl (%eax),%eax
80105495:	0f b6 d0             	movzbl %al,%edx
80105498:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549b:	0f b6 00             	movzbl (%eax),%eax
8010549e:	0f b6 c0             	movzbl %al,%eax
801054a1:	29 c2                	sub    %eax,%edx
801054a3:	89 d0                	mov    %edx,%eax
}
801054a5:	5d                   	pop    %ebp
801054a6:	c3                   	ret    

801054a7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054a7:	55                   	push   %ebp
801054a8:	89 e5                	mov    %esp,%ebp
801054aa:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054ad:	8b 45 08             	mov    0x8(%ebp),%eax
801054b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054b3:	90                   	nop
801054b4:	8b 45 10             	mov    0x10(%ebp),%eax
801054b7:	8d 50 ff             	lea    -0x1(%eax),%edx
801054ba:	89 55 10             	mov    %edx,0x10(%ebp)
801054bd:	85 c0                	test   %eax,%eax
801054bf:	7e 2c                	jle    801054ed <strncpy+0x46>
801054c1:	8b 45 08             	mov    0x8(%ebp),%eax
801054c4:	8d 50 01             	lea    0x1(%eax),%edx
801054c7:	89 55 08             	mov    %edx,0x8(%ebp)
801054ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801054cd:	8d 4a 01             	lea    0x1(%edx),%ecx
801054d0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054d3:	0f b6 12             	movzbl (%edx),%edx
801054d6:	88 10                	mov    %dl,(%eax)
801054d8:	0f b6 00             	movzbl (%eax),%eax
801054db:	84 c0                	test   %al,%al
801054dd:	75 d5                	jne    801054b4 <strncpy+0xd>
    ;
  while(n-- > 0)
801054df:	eb 0c                	jmp    801054ed <strncpy+0x46>
    *s++ = 0;
801054e1:	8b 45 08             	mov    0x8(%ebp),%eax
801054e4:	8d 50 01             	lea    0x1(%eax),%edx
801054e7:	89 55 08             	mov    %edx,0x8(%ebp)
801054ea:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801054ed:	8b 45 10             	mov    0x10(%ebp),%eax
801054f0:	8d 50 ff             	lea    -0x1(%eax),%edx
801054f3:	89 55 10             	mov    %edx,0x10(%ebp)
801054f6:	85 c0                	test   %eax,%eax
801054f8:	7f e7                	jg     801054e1 <strncpy+0x3a>
    *s++ = 0;
  return os;
801054fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054fd:	c9                   	leave  
801054fe:	c3                   	ret    

801054ff <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054ff:	55                   	push   %ebp
80105500:	89 e5                	mov    %esp,%ebp
80105502:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105505:	8b 45 08             	mov    0x8(%ebp),%eax
80105508:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010550b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010550f:	7f 05                	jg     80105516 <safestrcpy+0x17>
    return os;
80105511:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105514:	eb 31                	jmp    80105547 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105516:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010551a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010551e:	7e 1e                	jle    8010553e <safestrcpy+0x3f>
80105520:	8b 45 08             	mov    0x8(%ebp),%eax
80105523:	8d 50 01             	lea    0x1(%eax),%edx
80105526:	89 55 08             	mov    %edx,0x8(%ebp)
80105529:	8b 55 0c             	mov    0xc(%ebp),%edx
8010552c:	8d 4a 01             	lea    0x1(%edx),%ecx
8010552f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105532:	0f b6 12             	movzbl (%edx),%edx
80105535:	88 10                	mov    %dl,(%eax)
80105537:	0f b6 00             	movzbl (%eax),%eax
8010553a:	84 c0                	test   %al,%al
8010553c:	75 d8                	jne    80105516 <safestrcpy+0x17>
    ;
  *s = 0;
8010553e:	8b 45 08             	mov    0x8(%ebp),%eax
80105541:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105544:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105547:	c9                   	leave  
80105548:	c3                   	ret    

80105549 <strlen>:

int
strlen(const char *s)
{
80105549:	55                   	push   %ebp
8010554a:	89 e5                	mov    %esp,%ebp
8010554c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010554f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105556:	eb 04                	jmp    8010555c <strlen+0x13>
80105558:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010555c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010555f:	8b 45 08             	mov    0x8(%ebp),%eax
80105562:	01 d0                	add    %edx,%eax
80105564:	0f b6 00             	movzbl (%eax),%eax
80105567:	84 c0                	test   %al,%al
80105569:	75 ed                	jne    80105558 <strlen+0xf>
    ;
  return n;
8010556b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010556e:	c9                   	leave  
8010556f:	c3                   	ret    

80105570 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105570:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105574:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105578:	55                   	push   %ebp
  pushl %ebx
80105579:	53                   	push   %ebx
  pushl %esi
8010557a:	56                   	push   %esi
  pushl %edi
8010557b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010557c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010557e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105580:	5f                   	pop    %edi
  popl %esi
80105581:	5e                   	pop    %esi
  popl %ebx
80105582:	5b                   	pop    %ebx
  popl %ebp
80105583:	5d                   	pop    %ebp
  ret
80105584:	c3                   	ret    

80105585 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105585:	55                   	push   %ebp
80105586:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105588:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010558e:	8b 00                	mov    (%eax),%eax
80105590:	3b 45 08             	cmp    0x8(%ebp),%eax
80105593:	76 12                	jbe    801055a7 <fetchint+0x22>
80105595:	8b 45 08             	mov    0x8(%ebp),%eax
80105598:	8d 50 04             	lea    0x4(%eax),%edx
8010559b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055a1:	8b 00                	mov    (%eax),%eax
801055a3:	39 c2                	cmp    %eax,%edx
801055a5:	76 07                	jbe    801055ae <fetchint+0x29>
    return -1;
801055a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ac:	eb 0f                	jmp    801055bd <fetchint+0x38>
  *ip = *(int*)(addr);
801055ae:	8b 45 08             	mov    0x8(%ebp),%eax
801055b1:	8b 10                	mov    (%eax),%edx
801055b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b6:	89 10                	mov    %edx,(%eax)
  return 0;
801055b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055bd:	5d                   	pop    %ebp
801055be:	c3                   	ret    

801055bf <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055bf:	55                   	push   %ebp
801055c0:	89 e5                	mov    %esp,%ebp
801055c2:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801055c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055cb:	8b 00                	mov    (%eax),%eax
801055cd:	3b 45 08             	cmp    0x8(%ebp),%eax
801055d0:	77 07                	ja     801055d9 <fetchstr+0x1a>
    return -1;
801055d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d7:	eb 46                	jmp    8010561f <fetchstr+0x60>
  *pp = (char*)addr;
801055d9:	8b 55 08             	mov    0x8(%ebp),%edx
801055dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055df:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e7:	8b 00                	mov    (%eax),%eax
801055e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ef:	8b 00                	mov    (%eax),%eax
801055f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055f4:	eb 1c                	jmp    80105612 <fetchstr+0x53>
    if(*s == 0)
801055f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f9:	0f b6 00             	movzbl (%eax),%eax
801055fc:	84 c0                	test   %al,%al
801055fe:	75 0e                	jne    8010560e <fetchstr+0x4f>
      return s - *pp;
80105600:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105603:	8b 45 0c             	mov    0xc(%ebp),%eax
80105606:	8b 00                	mov    (%eax),%eax
80105608:	29 c2                	sub    %eax,%edx
8010560a:	89 d0                	mov    %edx,%eax
8010560c:	eb 11                	jmp    8010561f <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010560e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105612:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105615:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105618:	72 dc                	jb     801055f6 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010561a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010561f:	c9                   	leave  
80105620:	c3                   	ret    

80105621 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105621:	55                   	push   %ebp
80105622:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105624:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010562a:	8b 40 18             	mov    0x18(%eax),%eax
8010562d:	8b 40 44             	mov    0x44(%eax),%eax
80105630:	8b 55 08             	mov    0x8(%ebp),%edx
80105633:	c1 e2 02             	shl    $0x2,%edx
80105636:	01 d0                	add    %edx,%eax
80105638:	83 c0 04             	add    $0x4,%eax
8010563b:	ff 75 0c             	pushl  0xc(%ebp)
8010563e:	50                   	push   %eax
8010563f:	e8 41 ff ff ff       	call   80105585 <fetchint>
80105644:	83 c4 08             	add    $0x8,%esp
}
80105647:	c9                   	leave  
80105648:	c3                   	ret    

80105649 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105649:	55                   	push   %ebp
8010564a:	89 e5                	mov    %esp,%ebp
8010564c:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010564f:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105652:	50                   	push   %eax
80105653:	ff 75 08             	pushl  0x8(%ebp)
80105656:	e8 c6 ff ff ff       	call   80105621 <argint>
8010565b:	83 c4 08             	add    $0x8,%esp
8010565e:	85 c0                	test   %eax,%eax
80105660:	79 07                	jns    80105669 <argptr+0x20>
    return -1;
80105662:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105667:	eb 3b                	jmp    801056a4 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105669:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010566f:	8b 00                	mov    (%eax),%eax
80105671:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105674:	39 d0                	cmp    %edx,%eax
80105676:	76 16                	jbe    8010568e <argptr+0x45>
80105678:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010567b:	89 c2                	mov    %eax,%edx
8010567d:	8b 45 10             	mov    0x10(%ebp),%eax
80105680:	01 c2                	add    %eax,%edx
80105682:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105688:	8b 00                	mov    (%eax),%eax
8010568a:	39 c2                	cmp    %eax,%edx
8010568c:	76 07                	jbe    80105695 <argptr+0x4c>
    return -1;
8010568e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105693:	eb 0f                	jmp    801056a4 <argptr+0x5b>
  *pp = (char*)i;
80105695:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105698:	89 c2                	mov    %eax,%edx
8010569a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010569d:	89 10                	mov    %edx,(%eax)
  return 0;
8010569f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056a4:	c9                   	leave  
801056a5:	c3                   	ret    

801056a6 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056a6:	55                   	push   %ebp
801056a7:	89 e5                	mov    %esp,%ebp
801056a9:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056af:	50                   	push   %eax
801056b0:	ff 75 08             	pushl  0x8(%ebp)
801056b3:	e8 69 ff ff ff       	call   80105621 <argint>
801056b8:	83 c4 08             	add    $0x8,%esp
801056bb:	85 c0                	test   %eax,%eax
801056bd:	79 07                	jns    801056c6 <argstr+0x20>
    return -1;
801056bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c4:	eb 0f                	jmp    801056d5 <argstr+0x2f>
  return fetchstr(addr, pp);
801056c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056c9:	ff 75 0c             	pushl  0xc(%ebp)
801056cc:	50                   	push   %eax
801056cd:	e8 ed fe ff ff       	call   801055bf <fetchstr>
801056d2:	83 c4 08             	add    $0x8,%esp
}
801056d5:	c9                   	leave  
801056d6:	c3                   	ret    

801056d7 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801056d7:	55                   	push   %ebp
801056d8:	89 e5                	mov    %esp,%ebp
801056da:	53                   	push   %ebx
801056db:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801056de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e4:	8b 40 18             	mov    0x18(%eax),%eax
801056e7:	8b 40 1c             	mov    0x1c(%eax),%eax
801056ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056f1:	7e 30                	jle    80105723 <syscall+0x4c>
801056f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f6:	83 f8 15             	cmp    $0x15,%eax
801056f9:	77 28                	ja     80105723 <syscall+0x4c>
801056fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fe:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105705:	85 c0                	test   %eax,%eax
80105707:	74 1a                	je     80105723 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105709:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010570f:	8b 58 18             	mov    0x18(%eax),%ebx
80105712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105715:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010571c:	ff d0                	call   *%eax
8010571e:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105721:	eb 34                	jmp    80105757 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105723:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105729:	8d 50 6c             	lea    0x6c(%eax),%edx
8010572c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105732:	8b 40 10             	mov    0x10(%eax),%eax
80105735:	ff 75 f4             	pushl  -0xc(%ebp)
80105738:	52                   	push   %edx
80105739:	50                   	push   %eax
8010573a:	68 5a 8a 10 80       	push   $0x80108a5a
8010573f:	e8 82 ac ff ff       	call   801003c6 <cprintf>
80105744:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105747:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574d:	8b 40 18             	mov    0x18(%eax),%eax
80105750:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105757:	90                   	nop
80105758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010575b:	c9                   	leave  
8010575c:	c3                   	ret    

8010575d <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010575d:	55                   	push   %ebp
8010575e:	89 e5                	mov    %esp,%ebp
80105760:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105763:	83 ec 08             	sub    $0x8,%esp
80105766:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105769:	50                   	push   %eax
8010576a:	ff 75 08             	pushl  0x8(%ebp)
8010576d:	e8 af fe ff ff       	call   80105621 <argint>
80105772:	83 c4 10             	add    $0x10,%esp
80105775:	85 c0                	test   %eax,%eax
80105777:	79 07                	jns    80105780 <argfd+0x23>
    return -1;
80105779:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577e:	eb 50                	jmp    801057d0 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105783:	85 c0                	test   %eax,%eax
80105785:	78 21                	js     801057a8 <argfd+0x4b>
80105787:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578a:	83 f8 0f             	cmp    $0xf,%eax
8010578d:	7f 19                	jg     801057a8 <argfd+0x4b>
8010578f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105795:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105798:	83 c2 08             	add    $0x8,%edx
8010579b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010579f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a6:	75 07                	jne    801057af <argfd+0x52>
    return -1;
801057a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ad:	eb 21                	jmp    801057d0 <argfd+0x73>
  if(pfd)
801057af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057b3:	74 08                	je     801057bd <argfd+0x60>
    *pfd = fd;
801057b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057bb:	89 10                	mov    %edx,(%eax)
  if(pf)
801057bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057c1:	74 08                	je     801057cb <argfd+0x6e>
    *pf = f;
801057c3:	8b 45 10             	mov    0x10(%ebp),%eax
801057c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c9:	89 10                	mov    %edx,(%eax)
  return 0;
801057cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057d0:	c9                   	leave  
801057d1:	c3                   	ret    

801057d2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057d2:	55                   	push   %ebp
801057d3:	89 e5                	mov    %esp,%ebp
801057d5:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057df:	eb 30                	jmp    80105811 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057ea:	83 c2 08             	add    $0x8,%edx
801057ed:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057f1:	85 c0                	test   %eax,%eax
801057f3:	75 18                	jne    8010580d <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057fb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057fe:	8d 4a 08             	lea    0x8(%edx),%ecx
80105801:	8b 55 08             	mov    0x8(%ebp),%edx
80105804:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105808:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010580b:	eb 0f                	jmp    8010581c <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010580d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105811:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105815:	7e ca                	jle    801057e1 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105817:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010581c:	c9                   	leave  
8010581d:	c3                   	ret    

8010581e <sys_dup>:

int
sys_dup(void)
{
8010581e:	55                   	push   %ebp
8010581f:	89 e5                	mov    %esp,%ebp
80105821:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105824:	83 ec 04             	sub    $0x4,%esp
80105827:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010582a:	50                   	push   %eax
8010582b:	6a 00                	push   $0x0
8010582d:	6a 00                	push   $0x0
8010582f:	e8 29 ff ff ff       	call   8010575d <argfd>
80105834:	83 c4 10             	add    $0x10,%esp
80105837:	85 c0                	test   %eax,%eax
80105839:	79 07                	jns    80105842 <sys_dup+0x24>
    return -1;
8010583b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105840:	eb 31                	jmp    80105873 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105842:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105845:	83 ec 0c             	sub    $0xc,%esp
80105848:	50                   	push   %eax
80105849:	e8 84 ff ff ff       	call   801057d2 <fdalloc>
8010584e:	83 c4 10             	add    $0x10,%esp
80105851:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105854:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105858:	79 07                	jns    80105861 <sys_dup+0x43>
    return -1;
8010585a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010585f:	eb 12                	jmp    80105873 <sys_dup+0x55>
  filedup(f);
80105861:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105864:	83 ec 0c             	sub    $0xc,%esp
80105867:	50                   	push   %eax
80105868:	e8 93 b7 ff ff       	call   80101000 <filedup>
8010586d:	83 c4 10             	add    $0x10,%esp
  return fd;
80105870:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105873:	c9                   	leave  
80105874:	c3                   	ret    

80105875 <sys_read>:

int
sys_read(void)
{
80105875:	55                   	push   %ebp
80105876:	89 e5                	mov    %esp,%ebp
80105878:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010587b:	83 ec 04             	sub    $0x4,%esp
8010587e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105881:	50                   	push   %eax
80105882:	6a 00                	push   $0x0
80105884:	6a 00                	push   $0x0
80105886:	e8 d2 fe ff ff       	call   8010575d <argfd>
8010588b:	83 c4 10             	add    $0x10,%esp
8010588e:	85 c0                	test   %eax,%eax
80105890:	78 2e                	js     801058c0 <sys_read+0x4b>
80105892:	83 ec 08             	sub    $0x8,%esp
80105895:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105898:	50                   	push   %eax
80105899:	6a 02                	push   $0x2
8010589b:	e8 81 fd ff ff       	call   80105621 <argint>
801058a0:	83 c4 10             	add    $0x10,%esp
801058a3:	85 c0                	test   %eax,%eax
801058a5:	78 19                	js     801058c0 <sys_read+0x4b>
801058a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058aa:	83 ec 04             	sub    $0x4,%esp
801058ad:	50                   	push   %eax
801058ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058b1:	50                   	push   %eax
801058b2:	6a 01                	push   $0x1
801058b4:	e8 90 fd ff ff       	call   80105649 <argptr>
801058b9:	83 c4 10             	add    $0x10,%esp
801058bc:	85 c0                	test   %eax,%eax
801058be:	79 07                	jns    801058c7 <sys_read+0x52>
    return -1;
801058c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c5:	eb 17                	jmp    801058de <sys_read+0x69>
  return fileread(f, p, n);
801058c7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058ca:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d0:	83 ec 04             	sub    $0x4,%esp
801058d3:	51                   	push   %ecx
801058d4:	52                   	push   %edx
801058d5:	50                   	push   %eax
801058d6:	e8 b5 b8 ff ff       	call   80101190 <fileread>
801058db:	83 c4 10             	add    $0x10,%esp
}
801058de:	c9                   	leave  
801058df:	c3                   	ret    

801058e0 <sys_write>:

int
sys_write(void)
{
801058e0:	55                   	push   %ebp
801058e1:	89 e5                	mov    %esp,%ebp
801058e3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058e6:	83 ec 04             	sub    $0x4,%esp
801058e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058ec:	50                   	push   %eax
801058ed:	6a 00                	push   $0x0
801058ef:	6a 00                	push   $0x0
801058f1:	e8 67 fe ff ff       	call   8010575d <argfd>
801058f6:	83 c4 10             	add    $0x10,%esp
801058f9:	85 c0                	test   %eax,%eax
801058fb:	78 2e                	js     8010592b <sys_write+0x4b>
801058fd:	83 ec 08             	sub    $0x8,%esp
80105900:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105903:	50                   	push   %eax
80105904:	6a 02                	push   $0x2
80105906:	e8 16 fd ff ff       	call   80105621 <argint>
8010590b:	83 c4 10             	add    $0x10,%esp
8010590e:	85 c0                	test   %eax,%eax
80105910:	78 19                	js     8010592b <sys_write+0x4b>
80105912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105915:	83 ec 04             	sub    $0x4,%esp
80105918:	50                   	push   %eax
80105919:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010591c:	50                   	push   %eax
8010591d:	6a 01                	push   $0x1
8010591f:	e8 25 fd ff ff       	call   80105649 <argptr>
80105924:	83 c4 10             	add    $0x10,%esp
80105927:	85 c0                	test   %eax,%eax
80105929:	79 07                	jns    80105932 <sys_write+0x52>
    return -1;
8010592b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105930:	eb 17                	jmp    80105949 <sys_write+0x69>
  return filewrite(f, p, n);
80105932:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105935:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593b:	83 ec 04             	sub    $0x4,%esp
8010593e:	51                   	push   %ecx
8010593f:	52                   	push   %edx
80105940:	50                   	push   %eax
80105941:	e8 02 b9 ff ff       	call   80101248 <filewrite>
80105946:	83 c4 10             	add    $0x10,%esp
}
80105949:	c9                   	leave  
8010594a:	c3                   	ret    

8010594b <sys_close>:

int
sys_close(void)
{
8010594b:	55                   	push   %ebp
8010594c:	89 e5                	mov    %esp,%ebp
8010594e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105951:	83 ec 04             	sub    $0x4,%esp
80105954:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105957:	50                   	push   %eax
80105958:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010595b:	50                   	push   %eax
8010595c:	6a 00                	push   $0x0
8010595e:	e8 fa fd ff ff       	call   8010575d <argfd>
80105963:	83 c4 10             	add    $0x10,%esp
80105966:	85 c0                	test   %eax,%eax
80105968:	79 07                	jns    80105971 <sys_close+0x26>
    return -1;
8010596a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596f:	eb 28                	jmp    80105999 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105971:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105977:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010597a:	83 c2 08             	add    $0x8,%edx
8010597d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105984:	00 
  fileclose(f);
80105985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105988:	83 ec 0c             	sub    $0xc,%esp
8010598b:	50                   	push   %eax
8010598c:	e8 c0 b6 ff ff       	call   80101051 <fileclose>
80105991:	83 c4 10             	add    $0x10,%esp
  return 0;
80105994:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105999:	c9                   	leave  
8010599a:	c3                   	ret    

8010599b <sys_fstat>:

int
sys_fstat(void)
{
8010599b:	55                   	push   %ebp
8010599c:	89 e5                	mov    %esp,%ebp
8010599e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801059a1:	83 ec 04             	sub    $0x4,%esp
801059a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059a7:	50                   	push   %eax
801059a8:	6a 00                	push   $0x0
801059aa:	6a 00                	push   $0x0
801059ac:	e8 ac fd ff ff       	call   8010575d <argfd>
801059b1:	83 c4 10             	add    $0x10,%esp
801059b4:	85 c0                	test   %eax,%eax
801059b6:	78 17                	js     801059cf <sys_fstat+0x34>
801059b8:	83 ec 04             	sub    $0x4,%esp
801059bb:	6a 14                	push   $0x14
801059bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059c0:	50                   	push   %eax
801059c1:	6a 01                	push   $0x1
801059c3:	e8 81 fc ff ff       	call   80105649 <argptr>
801059c8:	83 c4 10             	add    $0x10,%esp
801059cb:	85 c0                	test   %eax,%eax
801059cd:	79 07                	jns    801059d6 <sys_fstat+0x3b>
    return -1;
801059cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d4:	eb 13                	jmp    801059e9 <sys_fstat+0x4e>
  return filestat(f, st);
801059d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059dc:	83 ec 08             	sub    $0x8,%esp
801059df:	52                   	push   %edx
801059e0:	50                   	push   %eax
801059e1:	e8 53 b7 ff ff       	call   80101139 <filestat>
801059e6:	83 c4 10             	add    $0x10,%esp
}
801059e9:	c9                   	leave  
801059ea:	c3                   	ret    

801059eb <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059eb:	55                   	push   %ebp
801059ec:	89 e5                	mov    %esp,%ebp
801059ee:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059f1:	83 ec 08             	sub    $0x8,%esp
801059f4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059f7:	50                   	push   %eax
801059f8:	6a 00                	push   $0x0
801059fa:	e8 a7 fc ff ff       	call   801056a6 <argstr>
801059ff:	83 c4 10             	add    $0x10,%esp
80105a02:	85 c0                	test   %eax,%eax
80105a04:	78 15                	js     80105a1b <sys_link+0x30>
80105a06:	83 ec 08             	sub    $0x8,%esp
80105a09:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a0c:	50                   	push   %eax
80105a0d:	6a 01                	push   $0x1
80105a0f:	e8 92 fc ff ff       	call   801056a6 <argstr>
80105a14:	83 c4 10             	add    $0x10,%esp
80105a17:	85 c0                	test   %eax,%eax
80105a19:	79 0a                	jns    80105a25 <sys_link+0x3a>
    return -1;
80105a1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a20:	e9 68 01 00 00       	jmp    80105b8d <sys_link+0x1a2>

  begin_op();
80105a25:	e8 23 db ff ff       	call   8010354d <begin_op>
  if((ip = namei(old)) == 0){
80105a2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a2d:	83 ec 0c             	sub    $0xc,%esp
80105a30:	50                   	push   %eax
80105a31:	e8 f2 ca ff ff       	call   80102528 <namei>
80105a36:	83 c4 10             	add    $0x10,%esp
80105a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a40:	75 0f                	jne    80105a51 <sys_link+0x66>
    end_op();
80105a42:	e8 92 db ff ff       	call   801035d9 <end_op>
    return -1;
80105a47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4c:	e9 3c 01 00 00       	jmp    80105b8d <sys_link+0x1a2>
  }

  ilock(ip);
80105a51:	83 ec 0c             	sub    $0xc,%esp
80105a54:	ff 75 f4             	pushl  -0xc(%ebp)
80105a57:	e8 0e bf ff ff       	call   8010196a <ilock>
80105a5c:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a66:	66 83 f8 01          	cmp    $0x1,%ax
80105a6a:	75 1d                	jne    80105a89 <sys_link+0x9e>
    iunlockput(ip);
80105a6c:	83 ec 0c             	sub    $0xc,%esp
80105a6f:	ff 75 f4             	pushl  -0xc(%ebp)
80105a72:	e8 b3 c1 ff ff       	call   80101c2a <iunlockput>
80105a77:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a7a:	e8 5a db ff ff       	call   801035d9 <end_op>
    return -1;
80105a7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a84:	e9 04 01 00 00       	jmp    80105b8d <sys_link+0x1a2>
  }

  ip->nlink++;
80105a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a90:	83 c0 01             	add    $0x1,%eax
80105a93:	89 c2                	mov    %eax,%edx
80105a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a98:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a9c:	83 ec 0c             	sub    $0xc,%esp
80105a9f:	ff 75 f4             	pushl  -0xc(%ebp)
80105aa2:	e8 e9 bc ff ff       	call   80101790 <iupdate>
80105aa7:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105aaa:	83 ec 0c             	sub    $0xc,%esp
80105aad:	ff 75 f4             	pushl  -0xc(%ebp)
80105ab0:	e8 13 c0 ff ff       	call   80101ac8 <iunlock>
80105ab5:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105ab8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105abb:	83 ec 08             	sub    $0x8,%esp
80105abe:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105ac1:	52                   	push   %edx
80105ac2:	50                   	push   %eax
80105ac3:	e8 7c ca ff ff       	call   80102544 <nameiparent>
80105ac8:	83 c4 10             	add    $0x10,%esp
80105acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ace:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ad2:	74 71                	je     80105b45 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105ad4:	83 ec 0c             	sub    $0xc,%esp
80105ad7:	ff 75 f0             	pushl  -0x10(%ebp)
80105ada:	e8 8b be ff ff       	call   8010196a <ilock>
80105adf:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae5:	8b 10                	mov    (%eax),%edx
80105ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aea:	8b 00                	mov    (%eax),%eax
80105aec:	39 c2                	cmp    %eax,%edx
80105aee:	75 1d                	jne    80105b0d <sys_link+0x122>
80105af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af3:	8b 40 04             	mov    0x4(%eax),%eax
80105af6:	83 ec 04             	sub    $0x4,%esp
80105af9:	50                   	push   %eax
80105afa:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105afd:	50                   	push   %eax
80105afe:	ff 75 f0             	pushl  -0x10(%ebp)
80105b01:	e8 86 c7 ff ff       	call   8010228c <dirlink>
80105b06:	83 c4 10             	add    $0x10,%esp
80105b09:	85 c0                	test   %eax,%eax
80105b0b:	79 10                	jns    80105b1d <sys_link+0x132>
    iunlockput(dp);
80105b0d:	83 ec 0c             	sub    $0xc,%esp
80105b10:	ff 75 f0             	pushl  -0x10(%ebp)
80105b13:	e8 12 c1 ff ff       	call   80101c2a <iunlockput>
80105b18:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b1b:	eb 29                	jmp    80105b46 <sys_link+0x15b>
  }
  iunlockput(dp);
80105b1d:	83 ec 0c             	sub    $0xc,%esp
80105b20:	ff 75 f0             	pushl  -0x10(%ebp)
80105b23:	e8 02 c1 ff ff       	call   80101c2a <iunlockput>
80105b28:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b2b:	83 ec 0c             	sub    $0xc,%esp
80105b2e:	ff 75 f4             	pushl  -0xc(%ebp)
80105b31:	e8 04 c0 ff ff       	call   80101b3a <iput>
80105b36:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b39:	e8 9b da ff ff       	call   801035d9 <end_op>

  return 0;
80105b3e:	b8 00 00 00 00       	mov    $0x0,%eax
80105b43:	eb 48                	jmp    80105b8d <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105b45:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105b46:	83 ec 0c             	sub    $0xc,%esp
80105b49:	ff 75 f4             	pushl  -0xc(%ebp)
80105b4c:	e8 19 be ff ff       	call   8010196a <ilock>
80105b51:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b57:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b5b:	83 e8 01             	sub    $0x1,%eax
80105b5e:	89 c2                	mov    %eax,%edx
80105b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b63:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b67:	83 ec 0c             	sub    $0xc,%esp
80105b6a:	ff 75 f4             	pushl  -0xc(%ebp)
80105b6d:	e8 1e bc ff ff       	call   80101790 <iupdate>
80105b72:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b75:	83 ec 0c             	sub    $0xc,%esp
80105b78:	ff 75 f4             	pushl  -0xc(%ebp)
80105b7b:	e8 aa c0 ff ff       	call   80101c2a <iunlockput>
80105b80:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b83:	e8 51 da ff ff       	call   801035d9 <end_op>
  return -1;
80105b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b8d:	c9                   	leave  
80105b8e:	c3                   	ret    

80105b8f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b8f:	55                   	push   %ebp
80105b90:	89 e5                	mov    %esp,%ebp
80105b92:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b95:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b9c:	eb 40                	jmp    80105bde <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba1:	6a 10                	push   $0x10
80105ba3:	50                   	push   %eax
80105ba4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ba7:	50                   	push   %eax
80105ba8:	ff 75 08             	pushl  0x8(%ebp)
80105bab:	e8 28 c3 ff ff       	call   80101ed8 <readi>
80105bb0:	83 c4 10             	add    $0x10,%esp
80105bb3:	83 f8 10             	cmp    $0x10,%eax
80105bb6:	74 0d                	je     80105bc5 <isdirempty+0x36>
      panic("isdirempty: readi");
80105bb8:	83 ec 0c             	sub    $0xc,%esp
80105bbb:	68 76 8a 10 80       	push   $0x80108a76
80105bc0:	e8 a1 a9 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105bc5:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bc9:	66 85 c0             	test   %ax,%ax
80105bcc:	74 07                	je     80105bd5 <isdirempty+0x46>
      return 0;
80105bce:	b8 00 00 00 00       	mov    $0x0,%eax
80105bd3:	eb 1b                	jmp    80105bf0 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd8:	83 c0 10             	add    $0x10,%eax
80105bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bde:	8b 45 08             	mov    0x8(%ebp),%eax
80105be1:	8b 50 18             	mov    0x18(%eax),%edx
80105be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be7:	39 c2                	cmp    %eax,%edx
80105be9:	77 b3                	ja     80105b9e <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105beb:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bf0:	c9                   	leave  
80105bf1:	c3                   	ret    

80105bf2 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bf2:	55                   	push   %ebp
80105bf3:	89 e5                	mov    %esp,%ebp
80105bf5:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bf8:	83 ec 08             	sub    $0x8,%esp
80105bfb:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bfe:	50                   	push   %eax
80105bff:	6a 00                	push   $0x0
80105c01:	e8 a0 fa ff ff       	call   801056a6 <argstr>
80105c06:	83 c4 10             	add    $0x10,%esp
80105c09:	85 c0                	test   %eax,%eax
80105c0b:	79 0a                	jns    80105c17 <sys_unlink+0x25>
    return -1;
80105c0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c12:	e9 bc 01 00 00       	jmp    80105dd3 <sys_unlink+0x1e1>

  begin_op();
80105c17:	e8 31 d9 ff ff       	call   8010354d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c1c:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c1f:	83 ec 08             	sub    $0x8,%esp
80105c22:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c25:	52                   	push   %edx
80105c26:	50                   	push   %eax
80105c27:	e8 18 c9 ff ff       	call   80102544 <nameiparent>
80105c2c:	83 c4 10             	add    $0x10,%esp
80105c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c36:	75 0f                	jne    80105c47 <sys_unlink+0x55>
    end_op();
80105c38:	e8 9c d9 ff ff       	call   801035d9 <end_op>
    return -1;
80105c3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c42:	e9 8c 01 00 00       	jmp    80105dd3 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105c47:	83 ec 0c             	sub    $0xc,%esp
80105c4a:	ff 75 f4             	pushl  -0xc(%ebp)
80105c4d:	e8 18 bd ff ff       	call   8010196a <ilock>
80105c52:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c55:	83 ec 08             	sub    $0x8,%esp
80105c58:	68 88 8a 10 80       	push   $0x80108a88
80105c5d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c60:	50                   	push   %eax
80105c61:	e8 51 c5 ff ff       	call   801021b7 <namecmp>
80105c66:	83 c4 10             	add    $0x10,%esp
80105c69:	85 c0                	test   %eax,%eax
80105c6b:	0f 84 4a 01 00 00    	je     80105dbb <sys_unlink+0x1c9>
80105c71:	83 ec 08             	sub    $0x8,%esp
80105c74:	68 8a 8a 10 80       	push   $0x80108a8a
80105c79:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c7c:	50                   	push   %eax
80105c7d:	e8 35 c5 ff ff       	call   801021b7 <namecmp>
80105c82:	83 c4 10             	add    $0x10,%esp
80105c85:	85 c0                	test   %eax,%eax
80105c87:	0f 84 2e 01 00 00    	je     80105dbb <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c8d:	83 ec 04             	sub    $0x4,%esp
80105c90:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c93:	50                   	push   %eax
80105c94:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c97:	50                   	push   %eax
80105c98:	ff 75 f4             	pushl  -0xc(%ebp)
80105c9b:	e8 32 c5 ff ff       	call   801021d2 <dirlookup>
80105ca0:	83 c4 10             	add    $0x10,%esp
80105ca3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ca6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105caa:	0f 84 0a 01 00 00    	je     80105dba <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105cb0:	83 ec 0c             	sub    $0xc,%esp
80105cb3:	ff 75 f0             	pushl  -0x10(%ebp)
80105cb6:	e8 af bc ff ff       	call   8010196a <ilock>
80105cbb:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cc5:	66 85 c0             	test   %ax,%ax
80105cc8:	7f 0d                	jg     80105cd7 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105cca:	83 ec 0c             	sub    $0xc,%esp
80105ccd:	68 8d 8a 10 80       	push   $0x80108a8d
80105cd2:	e8 8f a8 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cda:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cde:	66 83 f8 01          	cmp    $0x1,%ax
80105ce2:	75 25                	jne    80105d09 <sys_unlink+0x117>
80105ce4:	83 ec 0c             	sub    $0xc,%esp
80105ce7:	ff 75 f0             	pushl  -0x10(%ebp)
80105cea:	e8 a0 fe ff ff       	call   80105b8f <isdirempty>
80105cef:	83 c4 10             	add    $0x10,%esp
80105cf2:	85 c0                	test   %eax,%eax
80105cf4:	75 13                	jne    80105d09 <sys_unlink+0x117>
    iunlockput(ip);
80105cf6:	83 ec 0c             	sub    $0xc,%esp
80105cf9:	ff 75 f0             	pushl  -0x10(%ebp)
80105cfc:	e8 29 bf ff ff       	call   80101c2a <iunlockput>
80105d01:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d04:	e9 b2 00 00 00       	jmp    80105dbb <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105d09:	83 ec 04             	sub    $0x4,%esp
80105d0c:	6a 10                	push   $0x10
80105d0e:	6a 00                	push   $0x0
80105d10:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d13:	50                   	push   %eax
80105d14:	e8 e3 f5 ff ff       	call   801052fc <memset>
80105d19:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d1c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d1f:	6a 10                	push   $0x10
80105d21:	50                   	push   %eax
80105d22:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d25:	50                   	push   %eax
80105d26:	ff 75 f4             	pushl  -0xc(%ebp)
80105d29:	e8 01 c3 ff ff       	call   8010202f <writei>
80105d2e:	83 c4 10             	add    $0x10,%esp
80105d31:	83 f8 10             	cmp    $0x10,%eax
80105d34:	74 0d                	je     80105d43 <sys_unlink+0x151>
    panic("unlink: writei");
80105d36:	83 ec 0c             	sub    $0xc,%esp
80105d39:	68 9f 8a 10 80       	push   $0x80108a9f
80105d3e:	e8 23 a8 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80105d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d46:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d4a:	66 83 f8 01          	cmp    $0x1,%ax
80105d4e:	75 21                	jne    80105d71 <sys_unlink+0x17f>
    dp->nlink--;
80105d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d53:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d57:	83 e8 01             	sub    $0x1,%eax
80105d5a:	89 c2                	mov    %eax,%edx
80105d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5f:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d63:	83 ec 0c             	sub    $0xc,%esp
80105d66:	ff 75 f4             	pushl  -0xc(%ebp)
80105d69:	e8 22 ba ff ff       	call   80101790 <iupdate>
80105d6e:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d71:	83 ec 0c             	sub    $0xc,%esp
80105d74:	ff 75 f4             	pushl  -0xc(%ebp)
80105d77:	e8 ae be ff ff       	call   80101c2a <iunlockput>
80105d7c:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d82:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d86:	83 e8 01             	sub    $0x1,%eax
80105d89:	89 c2                	mov    %eax,%edx
80105d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d92:	83 ec 0c             	sub    $0xc,%esp
80105d95:	ff 75 f0             	pushl  -0x10(%ebp)
80105d98:	e8 f3 b9 ff ff       	call   80101790 <iupdate>
80105d9d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105da0:	83 ec 0c             	sub    $0xc,%esp
80105da3:	ff 75 f0             	pushl  -0x10(%ebp)
80105da6:	e8 7f be ff ff       	call   80101c2a <iunlockput>
80105dab:	83 c4 10             	add    $0x10,%esp

  end_op();
80105dae:	e8 26 d8 ff ff       	call   801035d9 <end_op>

  return 0;
80105db3:	b8 00 00 00 00       	mov    $0x0,%eax
80105db8:	eb 19                	jmp    80105dd3 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105dba:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105dbb:	83 ec 0c             	sub    $0xc,%esp
80105dbe:	ff 75 f4             	pushl  -0xc(%ebp)
80105dc1:	e8 64 be ff ff       	call   80101c2a <iunlockput>
80105dc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dc9:	e8 0b d8 ff ff       	call   801035d9 <end_op>
  return -1;
80105dce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dd3:	c9                   	leave  
80105dd4:	c3                   	ret    

80105dd5 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dd5:	55                   	push   %ebp
80105dd6:	89 e5                	mov    %esp,%ebp
80105dd8:	83 ec 38             	sub    $0x38,%esp
80105ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105dde:	8b 55 10             	mov    0x10(%ebp),%edx
80105de1:	8b 45 14             	mov    0x14(%ebp),%eax
80105de4:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105de8:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dec:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105df0:	83 ec 08             	sub    $0x8,%esp
80105df3:	8d 45 de             	lea    -0x22(%ebp),%eax
80105df6:	50                   	push   %eax
80105df7:	ff 75 08             	pushl  0x8(%ebp)
80105dfa:	e8 45 c7 ff ff       	call   80102544 <nameiparent>
80105dff:	83 c4 10             	add    $0x10,%esp
80105e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e09:	75 0a                	jne    80105e15 <create+0x40>
    return 0;
80105e0b:	b8 00 00 00 00       	mov    $0x0,%eax
80105e10:	e9 90 01 00 00       	jmp    80105fa5 <create+0x1d0>
  ilock(dp);
80105e15:	83 ec 0c             	sub    $0xc,%esp
80105e18:	ff 75 f4             	pushl  -0xc(%ebp)
80105e1b:	e8 4a bb ff ff       	call   8010196a <ilock>
80105e20:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e23:	83 ec 04             	sub    $0x4,%esp
80105e26:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e29:	50                   	push   %eax
80105e2a:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e2d:	50                   	push   %eax
80105e2e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e31:	e8 9c c3 ff ff       	call   801021d2 <dirlookup>
80105e36:	83 c4 10             	add    $0x10,%esp
80105e39:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e40:	74 50                	je     80105e92 <create+0xbd>
    iunlockput(dp);
80105e42:	83 ec 0c             	sub    $0xc,%esp
80105e45:	ff 75 f4             	pushl  -0xc(%ebp)
80105e48:	e8 dd bd ff ff       	call   80101c2a <iunlockput>
80105e4d:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e50:	83 ec 0c             	sub    $0xc,%esp
80105e53:	ff 75 f0             	pushl  -0x10(%ebp)
80105e56:	e8 0f bb ff ff       	call   8010196a <ilock>
80105e5b:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e5e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e63:	75 15                	jne    80105e7a <create+0xa5>
80105e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e6c:	66 83 f8 02          	cmp    $0x2,%ax
80105e70:	75 08                	jne    80105e7a <create+0xa5>
      return ip;
80105e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e75:	e9 2b 01 00 00       	jmp    80105fa5 <create+0x1d0>
    iunlockput(ip);
80105e7a:	83 ec 0c             	sub    $0xc,%esp
80105e7d:	ff 75 f0             	pushl  -0x10(%ebp)
80105e80:	e8 a5 bd ff ff       	call   80101c2a <iunlockput>
80105e85:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e88:	b8 00 00 00 00       	mov    $0x0,%eax
80105e8d:	e9 13 01 00 00       	jmp    80105fa5 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e92:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e99:	8b 00                	mov    (%eax),%eax
80105e9b:	83 ec 08             	sub    $0x8,%esp
80105e9e:	52                   	push   %edx
80105e9f:	50                   	push   %eax
80105ea0:	e8 14 b8 ff ff       	call   801016b9 <ialloc>
80105ea5:	83 c4 10             	add    $0x10,%esp
80105ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eaf:	75 0d                	jne    80105ebe <create+0xe9>
    panic("create: ialloc");
80105eb1:	83 ec 0c             	sub    $0xc,%esp
80105eb4:	68 ae 8a 10 80       	push   $0x80108aae
80105eb9:	e8 a8 a6 ff ff       	call   80100566 <panic>

  ilock(ip);
80105ebe:	83 ec 0c             	sub    $0xc,%esp
80105ec1:	ff 75 f0             	pushl  -0x10(%ebp)
80105ec4:	e8 a1 ba ff ff       	call   8010196a <ilock>
80105ec9:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecf:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ed3:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eda:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ede:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee5:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105eeb:	83 ec 0c             	sub    $0xc,%esp
80105eee:	ff 75 f0             	pushl  -0x10(%ebp)
80105ef1:	e8 9a b8 ff ff       	call   80101790 <iupdate>
80105ef6:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ef9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105efe:	75 6a                	jne    80105f6a <create+0x195>
    dp->nlink++;  // for ".."
80105f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f03:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f07:	83 c0 01             	add    $0x1,%eax
80105f0a:	89 c2                	mov    %eax,%edx
80105f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0f:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f13:	83 ec 0c             	sub    $0xc,%esp
80105f16:	ff 75 f4             	pushl  -0xc(%ebp)
80105f19:	e8 72 b8 ff ff       	call   80101790 <iupdate>
80105f1e:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f24:	8b 40 04             	mov    0x4(%eax),%eax
80105f27:	83 ec 04             	sub    $0x4,%esp
80105f2a:	50                   	push   %eax
80105f2b:	68 88 8a 10 80       	push   $0x80108a88
80105f30:	ff 75 f0             	pushl  -0x10(%ebp)
80105f33:	e8 54 c3 ff ff       	call   8010228c <dirlink>
80105f38:	83 c4 10             	add    $0x10,%esp
80105f3b:	85 c0                	test   %eax,%eax
80105f3d:	78 1e                	js     80105f5d <create+0x188>
80105f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f42:	8b 40 04             	mov    0x4(%eax),%eax
80105f45:	83 ec 04             	sub    $0x4,%esp
80105f48:	50                   	push   %eax
80105f49:	68 8a 8a 10 80       	push   $0x80108a8a
80105f4e:	ff 75 f0             	pushl  -0x10(%ebp)
80105f51:	e8 36 c3 ff ff       	call   8010228c <dirlink>
80105f56:	83 c4 10             	add    $0x10,%esp
80105f59:	85 c0                	test   %eax,%eax
80105f5b:	79 0d                	jns    80105f6a <create+0x195>
      panic("create dots");
80105f5d:	83 ec 0c             	sub    $0xc,%esp
80105f60:	68 bd 8a 10 80       	push   $0x80108abd
80105f65:	e8 fc a5 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6d:	8b 40 04             	mov    0x4(%eax),%eax
80105f70:	83 ec 04             	sub    $0x4,%esp
80105f73:	50                   	push   %eax
80105f74:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f77:	50                   	push   %eax
80105f78:	ff 75 f4             	pushl  -0xc(%ebp)
80105f7b:	e8 0c c3 ff ff       	call   8010228c <dirlink>
80105f80:	83 c4 10             	add    $0x10,%esp
80105f83:	85 c0                	test   %eax,%eax
80105f85:	79 0d                	jns    80105f94 <create+0x1bf>
    panic("create: dirlink");
80105f87:	83 ec 0c             	sub    $0xc,%esp
80105f8a:	68 c9 8a 10 80       	push   $0x80108ac9
80105f8f:	e8 d2 a5 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80105f94:	83 ec 0c             	sub    $0xc,%esp
80105f97:	ff 75 f4             	pushl  -0xc(%ebp)
80105f9a:	e8 8b bc ff ff       	call   80101c2a <iunlockput>
80105f9f:	83 c4 10             	add    $0x10,%esp

  return ip;
80105fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105fa5:	c9                   	leave  
80105fa6:	c3                   	ret    

80105fa7 <sys_open>:

int
sys_open(void)
{
80105fa7:	55                   	push   %ebp
80105fa8:	89 e5                	mov    %esp,%ebp
80105faa:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105fad:	83 ec 08             	sub    $0x8,%esp
80105fb0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fb3:	50                   	push   %eax
80105fb4:	6a 00                	push   $0x0
80105fb6:	e8 eb f6 ff ff       	call   801056a6 <argstr>
80105fbb:	83 c4 10             	add    $0x10,%esp
80105fbe:	85 c0                	test   %eax,%eax
80105fc0:	78 15                	js     80105fd7 <sys_open+0x30>
80105fc2:	83 ec 08             	sub    $0x8,%esp
80105fc5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fc8:	50                   	push   %eax
80105fc9:	6a 01                	push   $0x1
80105fcb:	e8 51 f6 ff ff       	call   80105621 <argint>
80105fd0:	83 c4 10             	add    $0x10,%esp
80105fd3:	85 c0                	test   %eax,%eax
80105fd5:	79 0a                	jns    80105fe1 <sys_open+0x3a>
    return -1;
80105fd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fdc:	e9 61 01 00 00       	jmp    80106142 <sys_open+0x19b>

  begin_op();
80105fe1:	e8 67 d5 ff ff       	call   8010354d <begin_op>

  if(omode & O_CREATE){
80105fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe9:	25 00 02 00 00       	and    $0x200,%eax
80105fee:	85 c0                	test   %eax,%eax
80105ff0:	74 2a                	je     8010601c <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105ff2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ff5:	6a 00                	push   $0x0
80105ff7:	6a 00                	push   $0x0
80105ff9:	6a 02                	push   $0x2
80105ffb:	50                   	push   %eax
80105ffc:	e8 d4 fd ff ff       	call   80105dd5 <create>
80106001:	83 c4 10             	add    $0x10,%esp
80106004:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106007:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010600b:	75 75                	jne    80106082 <sys_open+0xdb>
      end_op();
8010600d:	e8 c7 d5 ff ff       	call   801035d9 <end_op>
      return -1;
80106012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106017:	e9 26 01 00 00       	jmp    80106142 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010601c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010601f:	83 ec 0c             	sub    $0xc,%esp
80106022:	50                   	push   %eax
80106023:	e8 00 c5 ff ff       	call   80102528 <namei>
80106028:	83 c4 10             	add    $0x10,%esp
8010602b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010602e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106032:	75 0f                	jne    80106043 <sys_open+0x9c>
      end_op();
80106034:	e8 a0 d5 ff ff       	call   801035d9 <end_op>
      return -1;
80106039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603e:	e9 ff 00 00 00       	jmp    80106142 <sys_open+0x19b>
    }
    ilock(ip);
80106043:	83 ec 0c             	sub    $0xc,%esp
80106046:	ff 75 f4             	pushl  -0xc(%ebp)
80106049:	e8 1c b9 ff ff       	call   8010196a <ilock>
8010604e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106054:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106058:	66 83 f8 01          	cmp    $0x1,%ax
8010605c:	75 24                	jne    80106082 <sys_open+0xdb>
8010605e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106061:	85 c0                	test   %eax,%eax
80106063:	74 1d                	je     80106082 <sys_open+0xdb>
      iunlockput(ip);
80106065:	83 ec 0c             	sub    $0xc,%esp
80106068:	ff 75 f4             	pushl  -0xc(%ebp)
8010606b:	e8 ba bb ff ff       	call   80101c2a <iunlockput>
80106070:	83 c4 10             	add    $0x10,%esp
      end_op();
80106073:	e8 61 d5 ff ff       	call   801035d9 <end_op>
      return -1;
80106078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010607d:	e9 c0 00 00 00       	jmp    80106142 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106082:	e8 0c af ff ff       	call   80100f93 <filealloc>
80106087:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010608a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010608e:	74 17                	je     801060a7 <sys_open+0x100>
80106090:	83 ec 0c             	sub    $0xc,%esp
80106093:	ff 75 f0             	pushl  -0x10(%ebp)
80106096:	e8 37 f7 ff ff       	call   801057d2 <fdalloc>
8010609b:	83 c4 10             	add    $0x10,%esp
8010609e:	89 45 ec             	mov    %eax,-0x14(%ebp)
801060a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801060a5:	79 2e                	jns    801060d5 <sys_open+0x12e>
    if(f)
801060a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060ab:	74 0e                	je     801060bb <sys_open+0x114>
      fileclose(f);
801060ad:	83 ec 0c             	sub    $0xc,%esp
801060b0:	ff 75 f0             	pushl  -0x10(%ebp)
801060b3:	e8 99 af ff ff       	call   80101051 <fileclose>
801060b8:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801060bb:	83 ec 0c             	sub    $0xc,%esp
801060be:	ff 75 f4             	pushl  -0xc(%ebp)
801060c1:	e8 64 bb ff ff       	call   80101c2a <iunlockput>
801060c6:	83 c4 10             	add    $0x10,%esp
    end_op();
801060c9:	e8 0b d5 ff ff       	call   801035d9 <end_op>
    return -1;
801060ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d3:	eb 6d                	jmp    80106142 <sys_open+0x19b>
  }
  iunlock(ip);
801060d5:	83 ec 0c             	sub    $0xc,%esp
801060d8:	ff 75 f4             	pushl  -0xc(%ebp)
801060db:	e8 e8 b9 ff ff       	call   80101ac8 <iunlock>
801060e0:	83 c4 10             	add    $0x10,%esp
  end_op();
801060e3:	e8 f1 d4 ff ff       	call   801035d9 <end_op>

  f->type = FD_INODE;
801060e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060eb:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060f7:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106107:	83 e0 01             	and    $0x1,%eax
8010610a:	85 c0                	test   %eax,%eax
8010610c:	0f 94 c0             	sete   %al
8010610f:	89 c2                	mov    %eax,%edx
80106111:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106114:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010611a:	83 e0 01             	and    $0x1,%eax
8010611d:	85 c0                	test   %eax,%eax
8010611f:	75 0a                	jne    8010612b <sys_open+0x184>
80106121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106124:	83 e0 02             	and    $0x2,%eax
80106127:	85 c0                	test   %eax,%eax
80106129:	74 07                	je     80106132 <sys_open+0x18b>
8010612b:	b8 01 00 00 00       	mov    $0x1,%eax
80106130:	eb 05                	jmp    80106137 <sys_open+0x190>
80106132:	b8 00 00 00 00       	mov    $0x0,%eax
80106137:	89 c2                	mov    %eax,%edx
80106139:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010613c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010613f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106142:	c9                   	leave  
80106143:	c3                   	ret    

80106144 <sys_mkdir>:

int
sys_mkdir(void)
{
80106144:	55                   	push   %ebp
80106145:	89 e5                	mov    %esp,%ebp
80106147:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010614a:	e8 fe d3 ff ff       	call   8010354d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010614f:	83 ec 08             	sub    $0x8,%esp
80106152:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106155:	50                   	push   %eax
80106156:	6a 00                	push   $0x0
80106158:	e8 49 f5 ff ff       	call   801056a6 <argstr>
8010615d:	83 c4 10             	add    $0x10,%esp
80106160:	85 c0                	test   %eax,%eax
80106162:	78 1b                	js     8010617f <sys_mkdir+0x3b>
80106164:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106167:	6a 00                	push   $0x0
80106169:	6a 00                	push   $0x0
8010616b:	6a 01                	push   $0x1
8010616d:	50                   	push   %eax
8010616e:	e8 62 fc ff ff       	call   80105dd5 <create>
80106173:	83 c4 10             	add    $0x10,%esp
80106176:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106179:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010617d:	75 0c                	jne    8010618b <sys_mkdir+0x47>
    end_op();
8010617f:	e8 55 d4 ff ff       	call   801035d9 <end_op>
    return -1;
80106184:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106189:	eb 18                	jmp    801061a3 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010618b:	83 ec 0c             	sub    $0xc,%esp
8010618e:	ff 75 f4             	pushl  -0xc(%ebp)
80106191:	e8 94 ba ff ff       	call   80101c2a <iunlockput>
80106196:	83 c4 10             	add    $0x10,%esp
  end_op();
80106199:	e8 3b d4 ff ff       	call   801035d9 <end_op>
  return 0;
8010619e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061a3:	c9                   	leave  
801061a4:	c3                   	ret    

801061a5 <sys_mknod>:

int
sys_mknod(void)
{
801061a5:	55                   	push   %ebp
801061a6:	89 e5                	mov    %esp,%ebp
801061a8:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801061ab:	e8 9d d3 ff ff       	call   8010354d <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801061b0:	83 ec 08             	sub    $0x8,%esp
801061b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061b6:	50                   	push   %eax
801061b7:	6a 00                	push   $0x0
801061b9:	e8 e8 f4 ff ff       	call   801056a6 <argstr>
801061be:	83 c4 10             	add    $0x10,%esp
801061c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c8:	78 4f                	js     80106219 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801061ca:	83 ec 08             	sub    $0x8,%esp
801061cd:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061d0:	50                   	push   %eax
801061d1:	6a 01                	push   $0x1
801061d3:	e8 49 f4 ff ff       	call   80105621 <argint>
801061d8:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801061db:	85 c0                	test   %eax,%eax
801061dd:	78 3a                	js     80106219 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061df:	83 ec 08             	sub    $0x8,%esp
801061e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061e5:	50                   	push   %eax
801061e6:	6a 02                	push   $0x2
801061e8:	e8 34 f4 ff ff       	call   80105621 <argint>
801061ed:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061f0:	85 c0                	test   %eax,%eax
801061f2:	78 25                	js     80106219 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061f7:	0f bf c8             	movswl %ax,%ecx
801061fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061fd:	0f bf d0             	movswl %ax,%edx
80106200:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106203:	51                   	push   %ecx
80106204:	52                   	push   %edx
80106205:	6a 03                	push   $0x3
80106207:	50                   	push   %eax
80106208:	e8 c8 fb ff ff       	call   80105dd5 <create>
8010620d:	83 c4 10             	add    $0x10,%esp
80106210:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106213:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106217:	75 0c                	jne    80106225 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106219:	e8 bb d3 ff ff       	call   801035d9 <end_op>
    return -1;
8010621e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106223:	eb 18                	jmp    8010623d <sys_mknod+0x98>
  }
  iunlockput(ip);
80106225:	83 ec 0c             	sub    $0xc,%esp
80106228:	ff 75 f0             	pushl  -0x10(%ebp)
8010622b:	e8 fa b9 ff ff       	call   80101c2a <iunlockput>
80106230:	83 c4 10             	add    $0x10,%esp
  end_op();
80106233:	e8 a1 d3 ff ff       	call   801035d9 <end_op>
  return 0;
80106238:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010623d:	c9                   	leave  
8010623e:	c3                   	ret    

8010623f <sys_chdir>:

int
sys_chdir(void)
{
8010623f:	55                   	push   %ebp
80106240:	89 e5                	mov    %esp,%ebp
80106242:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106245:	e8 03 d3 ff ff       	call   8010354d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010624a:	83 ec 08             	sub    $0x8,%esp
8010624d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106250:	50                   	push   %eax
80106251:	6a 00                	push   $0x0
80106253:	e8 4e f4 ff ff       	call   801056a6 <argstr>
80106258:	83 c4 10             	add    $0x10,%esp
8010625b:	85 c0                	test   %eax,%eax
8010625d:	78 18                	js     80106277 <sys_chdir+0x38>
8010625f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106262:	83 ec 0c             	sub    $0xc,%esp
80106265:	50                   	push   %eax
80106266:	e8 bd c2 ff ff       	call   80102528 <namei>
8010626b:	83 c4 10             	add    $0x10,%esp
8010626e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106271:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106275:	75 0c                	jne    80106283 <sys_chdir+0x44>
    end_op();
80106277:	e8 5d d3 ff ff       	call   801035d9 <end_op>
    return -1;
8010627c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106281:	eb 6e                	jmp    801062f1 <sys_chdir+0xb2>
  }
  ilock(ip);
80106283:	83 ec 0c             	sub    $0xc,%esp
80106286:	ff 75 f4             	pushl  -0xc(%ebp)
80106289:	e8 dc b6 ff ff       	call   8010196a <ilock>
8010628e:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106294:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106298:	66 83 f8 01          	cmp    $0x1,%ax
8010629c:	74 1a                	je     801062b8 <sys_chdir+0x79>
    iunlockput(ip);
8010629e:	83 ec 0c             	sub    $0xc,%esp
801062a1:	ff 75 f4             	pushl  -0xc(%ebp)
801062a4:	e8 81 b9 ff ff       	call   80101c2a <iunlockput>
801062a9:	83 c4 10             	add    $0x10,%esp
    end_op();
801062ac:	e8 28 d3 ff ff       	call   801035d9 <end_op>
    return -1;
801062b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b6:	eb 39                	jmp    801062f1 <sys_chdir+0xb2>
  }
  iunlock(ip);
801062b8:	83 ec 0c             	sub    $0xc,%esp
801062bb:	ff 75 f4             	pushl  -0xc(%ebp)
801062be:	e8 05 b8 ff ff       	call   80101ac8 <iunlock>
801062c3:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801062c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062cc:	8b 40 68             	mov    0x68(%eax),%eax
801062cf:	83 ec 0c             	sub    $0xc,%esp
801062d2:	50                   	push   %eax
801062d3:	e8 62 b8 ff ff       	call   80101b3a <iput>
801062d8:	83 c4 10             	add    $0x10,%esp
  end_op();
801062db:	e8 f9 d2 ff ff       	call   801035d9 <end_op>
  proc->cwd = ip;
801062e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062e9:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062f1:	c9                   	leave  
801062f2:	c3                   	ret    

801062f3 <sys_exec>:

int
sys_exec(void)
{
801062f3:	55                   	push   %ebp
801062f4:	89 e5                	mov    %esp,%ebp
801062f6:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062fc:	83 ec 08             	sub    $0x8,%esp
801062ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106302:	50                   	push   %eax
80106303:	6a 00                	push   $0x0
80106305:	e8 9c f3 ff ff       	call   801056a6 <argstr>
8010630a:	83 c4 10             	add    $0x10,%esp
8010630d:	85 c0                	test   %eax,%eax
8010630f:	78 18                	js     80106329 <sys_exec+0x36>
80106311:	83 ec 08             	sub    $0x8,%esp
80106314:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010631a:	50                   	push   %eax
8010631b:	6a 01                	push   $0x1
8010631d:	e8 ff f2 ff ff       	call   80105621 <argint>
80106322:	83 c4 10             	add    $0x10,%esp
80106325:	85 c0                	test   %eax,%eax
80106327:	79 0a                	jns    80106333 <sys_exec+0x40>
    return -1;
80106329:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010632e:	e9 c6 00 00 00       	jmp    801063f9 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106333:	83 ec 04             	sub    $0x4,%esp
80106336:	68 80 00 00 00       	push   $0x80
8010633b:	6a 00                	push   $0x0
8010633d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106343:	50                   	push   %eax
80106344:	e8 b3 ef ff ff       	call   801052fc <memset>
80106349:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010634c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106356:	83 f8 1f             	cmp    $0x1f,%eax
80106359:	76 0a                	jbe    80106365 <sys_exec+0x72>
      return -1;
8010635b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106360:	e9 94 00 00 00       	jmp    801063f9 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106368:	c1 e0 02             	shl    $0x2,%eax
8010636b:	89 c2                	mov    %eax,%edx
8010636d:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106373:	01 c2                	add    %eax,%edx
80106375:	83 ec 08             	sub    $0x8,%esp
80106378:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010637e:	50                   	push   %eax
8010637f:	52                   	push   %edx
80106380:	e8 00 f2 ff ff       	call   80105585 <fetchint>
80106385:	83 c4 10             	add    $0x10,%esp
80106388:	85 c0                	test   %eax,%eax
8010638a:	79 07                	jns    80106393 <sys_exec+0xa0>
      return -1;
8010638c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106391:	eb 66                	jmp    801063f9 <sys_exec+0x106>
    if(uarg == 0){
80106393:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106399:	85 c0                	test   %eax,%eax
8010639b:	75 27                	jne    801063c4 <sys_exec+0xd1>
      argv[i] = 0;
8010639d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a0:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801063a7:	00 00 00 00 
      break;
801063ab:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801063ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063af:	83 ec 08             	sub    $0x8,%esp
801063b2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063b8:	52                   	push   %edx
801063b9:	50                   	push   %eax
801063ba:	e8 b2 a7 ff ff       	call   80100b71 <exec>
801063bf:	83 c4 10             	add    $0x10,%esp
801063c2:	eb 35                	jmp    801063f9 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801063c4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063cd:	c1 e2 02             	shl    $0x2,%edx
801063d0:	01 c2                	add    %eax,%edx
801063d2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063d8:	83 ec 08             	sub    $0x8,%esp
801063db:	52                   	push   %edx
801063dc:	50                   	push   %eax
801063dd:	e8 dd f1 ff ff       	call   801055bf <fetchstr>
801063e2:	83 c4 10             	add    $0x10,%esp
801063e5:	85 c0                	test   %eax,%eax
801063e7:	79 07                	jns    801063f0 <sys_exec+0xfd>
      return -1;
801063e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ee:	eb 09                	jmp    801063f9 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801063f4:	e9 5a ff ff ff       	jmp    80106353 <sys_exec+0x60>
  return exec(path, argv);
}
801063f9:	c9                   	leave  
801063fa:	c3                   	ret    

801063fb <sys_pipe>:

int
sys_pipe(void)
{
801063fb:	55                   	push   %ebp
801063fc:	89 e5                	mov    %esp,%ebp
801063fe:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106401:	83 ec 04             	sub    $0x4,%esp
80106404:	6a 08                	push   $0x8
80106406:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106409:	50                   	push   %eax
8010640a:	6a 00                	push   $0x0
8010640c:	e8 38 f2 ff ff       	call   80105649 <argptr>
80106411:	83 c4 10             	add    $0x10,%esp
80106414:	85 c0                	test   %eax,%eax
80106416:	79 0a                	jns    80106422 <sys_pipe+0x27>
    return -1;
80106418:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641d:	e9 af 00 00 00       	jmp    801064d1 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106422:	83 ec 08             	sub    $0x8,%esp
80106425:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106428:	50                   	push   %eax
80106429:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010642c:	50                   	push   %eax
8010642d:	e8 0f dc ff ff       	call   80104041 <pipealloc>
80106432:	83 c4 10             	add    $0x10,%esp
80106435:	85 c0                	test   %eax,%eax
80106437:	79 0a                	jns    80106443 <sys_pipe+0x48>
    return -1;
80106439:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643e:	e9 8e 00 00 00       	jmp    801064d1 <sys_pipe+0xd6>
  fd0 = -1;
80106443:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010644a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010644d:	83 ec 0c             	sub    $0xc,%esp
80106450:	50                   	push   %eax
80106451:	e8 7c f3 ff ff       	call   801057d2 <fdalloc>
80106456:	83 c4 10             	add    $0x10,%esp
80106459:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010645c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106460:	78 18                	js     8010647a <sys_pipe+0x7f>
80106462:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106465:	83 ec 0c             	sub    $0xc,%esp
80106468:	50                   	push   %eax
80106469:	e8 64 f3 ff ff       	call   801057d2 <fdalloc>
8010646e:	83 c4 10             	add    $0x10,%esp
80106471:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106474:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106478:	79 3f                	jns    801064b9 <sys_pipe+0xbe>
    if(fd0 >= 0)
8010647a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010647e:	78 14                	js     80106494 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106480:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106486:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106489:	83 c2 08             	add    $0x8,%edx
8010648c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106493:	00 
    fileclose(rf);
80106494:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106497:	83 ec 0c             	sub    $0xc,%esp
8010649a:	50                   	push   %eax
8010649b:	e8 b1 ab ff ff       	call   80101051 <fileclose>
801064a0:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801064a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064a6:	83 ec 0c             	sub    $0xc,%esp
801064a9:	50                   	push   %eax
801064aa:	e8 a2 ab ff ff       	call   80101051 <fileclose>
801064af:	83 c4 10             	add    $0x10,%esp
    return -1;
801064b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b7:	eb 18                	jmp    801064d1 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801064b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064bf:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064c4:	8d 50 04             	lea    0x4(%eax),%edx
801064c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ca:	89 02                	mov    %eax,(%edx)
  return 0;
801064cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064d1:	c9                   	leave  
801064d2:	c3                   	ret    

801064d3 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801064d3:	55                   	push   %ebp
801064d4:	89 e5                	mov    %esp,%ebp
801064d6:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064d9:	e8 5c e2 ff ff       	call   8010473a <fork>
}
801064de:	c9                   	leave  
801064df:	c3                   	ret    

801064e0 <sys_exit>:

int
sys_exit(void)
{
801064e0:	55                   	push   %ebp
801064e1:	89 e5                	mov    %esp,%ebp
801064e3:	83 ec 08             	sub    $0x8,%esp
  exit();
801064e6:	e8 e0 e3 ff ff       	call   801048cb <exit>
  return 0;  // not reached
801064eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064f0:	c9                   	leave  
801064f1:	c3                   	ret    

801064f2 <sys_wait>:

int
sys_wait(void)
{
801064f2:	55                   	push   %ebp
801064f3:	89 e5                	mov    %esp,%ebp
801064f5:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064f8:	e8 09 e5 ff ff       	call   80104a06 <wait>
}
801064fd:	c9                   	leave  
801064fe:	c3                   	ret    

801064ff <sys_kill>:

int
sys_kill(void)
{
801064ff:	55                   	push   %ebp
80106500:	89 e5                	mov    %esp,%ebp
80106502:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106505:	83 ec 08             	sub    $0x8,%esp
80106508:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010650b:	50                   	push   %eax
8010650c:	6a 00                	push   $0x0
8010650e:	e8 0e f1 ff ff       	call   80105621 <argint>
80106513:	83 c4 10             	add    $0x10,%esp
80106516:	85 c0                	test   %eax,%eax
80106518:	79 07                	jns    80106521 <sys_kill+0x22>
    return -1;
8010651a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651f:	eb 0f                	jmp    80106530 <sys_kill+0x31>
  return kill(pid);
80106521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106524:	83 ec 0c             	sub    $0xc,%esp
80106527:	50                   	push   %eax
80106528:	e8 8f e9 ff ff       	call   80104ebc <kill>
8010652d:	83 c4 10             	add    $0x10,%esp
}
80106530:	c9                   	leave  
80106531:	c3                   	ret    

80106532 <sys_getpid>:

int
sys_getpid(void)
{
80106532:	55                   	push   %ebp
80106533:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106535:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010653b:	8b 40 10             	mov    0x10(%eax),%eax
}
8010653e:	5d                   	pop    %ebp
8010653f:	c3                   	ret    

80106540 <sys_sbrk>:

int
sys_sbrk(void)
{
80106540:	55                   	push   %ebp
80106541:	89 e5                	mov    %esp,%ebp
80106543:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106546:	83 ec 08             	sub    $0x8,%esp
80106549:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010654c:	50                   	push   %eax
8010654d:	6a 00                	push   $0x0
8010654f:	e8 cd f0 ff ff       	call   80105621 <argint>
80106554:	83 c4 10             	add    $0x10,%esp
80106557:	85 c0                	test   %eax,%eax
80106559:	79 07                	jns    80106562 <sys_sbrk+0x22>
    return -1;
8010655b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106560:	eb 28                	jmp    8010658a <sys_sbrk+0x4a>
  addr = proc->sz;
80106562:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106568:	8b 00                	mov    (%eax),%eax
8010656a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010656d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106570:	83 ec 0c             	sub    $0xc,%esp
80106573:	50                   	push   %eax
80106574:	e8 1e e1 ff ff       	call   80104697 <growproc>
80106579:	83 c4 10             	add    $0x10,%esp
8010657c:	85 c0                	test   %eax,%eax
8010657e:	79 07                	jns    80106587 <sys_sbrk+0x47>
    return -1;
80106580:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106585:	eb 03                	jmp    8010658a <sys_sbrk+0x4a>
  return addr;
80106587:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010658a:	c9                   	leave  
8010658b:	c3                   	ret    

8010658c <sys_sleep>:

int
sys_sleep(void)
{
8010658c:	55                   	push   %ebp
8010658d:	89 e5                	mov    %esp,%ebp
8010658f:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106592:	83 ec 08             	sub    $0x8,%esp
80106595:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106598:	50                   	push   %eax
80106599:	6a 00                	push   $0x0
8010659b:	e8 81 f0 ff ff       	call   80105621 <argint>
801065a0:	83 c4 10             	add    $0x10,%esp
801065a3:	85 c0                	test   %eax,%eax
801065a5:	79 07                	jns    801065ae <sys_sleep+0x22>
    return -1;
801065a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ac:	eb 77                	jmp    80106625 <sys_sleep+0x99>
  acquire(&tickslock);
801065ae:	83 ec 0c             	sub    $0xc,%esp
801065b1:	68 a0 4b 11 80       	push   $0x80114ba0
801065b6:	e8 de ea ff ff       	call   80105099 <acquire>
801065bb:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065be:	a1 e0 53 11 80       	mov    0x801153e0,%eax
801065c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065c6:	eb 39                	jmp    80106601 <sys_sleep+0x75>
    if(proc->killed){
801065c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065ce:	8b 40 24             	mov    0x24(%eax),%eax
801065d1:	85 c0                	test   %eax,%eax
801065d3:	74 17                	je     801065ec <sys_sleep+0x60>
      release(&tickslock);
801065d5:	83 ec 0c             	sub    $0xc,%esp
801065d8:	68 a0 4b 11 80       	push   $0x80114ba0
801065dd:	e8 1e eb ff ff       	call   80105100 <release>
801065e2:	83 c4 10             	add    $0x10,%esp
      return -1;
801065e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ea:	eb 39                	jmp    80106625 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801065ec:	83 ec 08             	sub    $0x8,%esp
801065ef:	68 a0 4b 11 80       	push   $0x80114ba0
801065f4:	68 e0 53 11 80       	push   $0x801153e0
801065f9:	e8 99 e7 ff ff       	call   80104d97 <sleep>
801065fe:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106601:	a1 e0 53 11 80       	mov    0x801153e0,%eax
80106606:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106609:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010660c:	39 d0                	cmp    %edx,%eax
8010660e:	72 b8                	jb     801065c8 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106610:	83 ec 0c             	sub    $0xc,%esp
80106613:	68 a0 4b 11 80       	push   $0x80114ba0
80106618:	e8 e3 ea ff ff       	call   80105100 <release>
8010661d:	83 c4 10             	add    $0x10,%esp
  return 0;
80106620:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106625:	c9                   	leave  
80106626:	c3                   	ret    

80106627 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106627:	55                   	push   %ebp
80106628:	89 e5                	mov    %esp,%ebp
8010662a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
8010662d:	83 ec 0c             	sub    $0xc,%esp
80106630:	68 a0 4b 11 80       	push   $0x80114ba0
80106635:	e8 5f ea ff ff       	call   80105099 <acquire>
8010663a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010663d:	a1 e0 53 11 80       	mov    0x801153e0,%eax
80106642:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106645:	83 ec 0c             	sub    $0xc,%esp
80106648:	68 a0 4b 11 80       	push   $0x80114ba0
8010664d:	e8 ae ea ff ff       	call   80105100 <release>
80106652:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106655:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106658:	c9                   	leave  
80106659:	c3                   	ret    

8010665a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010665a:	55                   	push   %ebp
8010665b:	89 e5                	mov    %esp,%ebp
8010665d:	83 ec 08             	sub    $0x8,%esp
80106660:	8b 55 08             	mov    0x8(%ebp),%edx
80106663:	8b 45 0c             	mov    0xc(%ebp),%eax
80106666:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010666a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010666d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106671:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106675:	ee                   	out    %al,(%dx)
}
80106676:	90                   	nop
80106677:	c9                   	leave  
80106678:	c3                   	ret    

80106679 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106679:	55                   	push   %ebp
8010667a:	89 e5                	mov    %esp,%ebp
8010667c:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010667f:	6a 34                	push   $0x34
80106681:	6a 43                	push   $0x43
80106683:	e8 d2 ff ff ff       	call   8010665a <outb>
80106688:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010668b:	68 9c 00 00 00       	push   $0x9c
80106690:	6a 40                	push   $0x40
80106692:	e8 c3 ff ff ff       	call   8010665a <outb>
80106697:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010669a:	6a 2e                	push   $0x2e
8010669c:	6a 40                	push   $0x40
8010669e:	e8 b7 ff ff ff       	call   8010665a <outb>
801066a3:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
801066a6:	83 ec 0c             	sub    $0xc,%esp
801066a9:	6a 00                	push   $0x0
801066ab:	e8 7b d8 ff ff       	call   80103f2b <picenable>
801066b0:	83 c4 10             	add    $0x10,%esp
}
801066b3:	90                   	nop
801066b4:	c9                   	leave  
801066b5:	c3                   	ret    

801066b6 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801066b6:	1e                   	push   %ds
  pushl %es
801066b7:	06                   	push   %es
  pushl %fs
801066b8:	0f a0                	push   %fs
  pushl %gs
801066ba:	0f a8                	push   %gs
  pushal
801066bc:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801066bd:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801066c1:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801066c3:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801066c5:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801066c9:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801066cb:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801066cd:	54                   	push   %esp
  call trap
801066ce:	e8 d7 01 00 00       	call   801068aa <trap>
  addl $4, %esp
801066d3:	83 c4 04             	add    $0x4,%esp

801066d6 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801066d6:	61                   	popa   
  popl %gs
801066d7:	0f a9                	pop    %gs
  popl %fs
801066d9:	0f a1                	pop    %fs
  popl %es
801066db:	07                   	pop    %es
  popl %ds
801066dc:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801066dd:	83 c4 08             	add    $0x8,%esp
  iret
801066e0:	cf                   	iret   

801066e1 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801066e1:	55                   	push   %ebp
801066e2:	89 e5                	mov    %esp,%ebp
801066e4:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801066e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801066ea:	83 e8 01             	sub    $0x1,%eax
801066ed:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801066f1:	8b 45 08             	mov    0x8(%ebp),%eax
801066f4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066f8:	8b 45 08             	mov    0x8(%ebp),%eax
801066fb:	c1 e8 10             	shr    $0x10,%eax
801066fe:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106702:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106705:	0f 01 18             	lidtl  (%eax)
}
80106708:	90                   	nop
80106709:	c9                   	leave  
8010670a:	c3                   	ret    

8010670b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010670b:	55                   	push   %ebp
8010670c:	89 e5                	mov    %esp,%ebp
8010670e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106711:	0f 20 d0             	mov    %cr2,%eax
80106714:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106717:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010671a:	c9                   	leave  
8010671b:	c3                   	ret    

8010671c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010671c:	55                   	push   %ebp
8010671d:	89 e5                	mov    %esp,%ebp
8010671f:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106722:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106729:	e9 c3 00 00 00       	jmp    801067f1 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010672e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106731:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106738:	89 c2                	mov    %eax,%edx
8010673a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673d:	66 89 14 c5 e0 4b 11 	mov    %dx,-0x7feeb420(,%eax,8)
80106744:	80 
80106745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106748:	66 c7 04 c5 e2 4b 11 	movw   $0x8,-0x7feeb41e(,%eax,8)
8010674f:	80 08 00 
80106752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106755:	0f b6 14 c5 e4 4b 11 	movzbl -0x7feeb41c(,%eax,8),%edx
8010675c:	80 
8010675d:	83 e2 e0             	and    $0xffffffe0,%edx
80106760:	88 14 c5 e4 4b 11 80 	mov    %dl,-0x7feeb41c(,%eax,8)
80106767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676a:	0f b6 14 c5 e4 4b 11 	movzbl -0x7feeb41c(,%eax,8),%edx
80106771:	80 
80106772:	83 e2 1f             	and    $0x1f,%edx
80106775:	88 14 c5 e4 4b 11 80 	mov    %dl,-0x7feeb41c(,%eax,8)
8010677c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677f:	0f b6 14 c5 e5 4b 11 	movzbl -0x7feeb41b(,%eax,8),%edx
80106786:	80 
80106787:	83 e2 f0             	and    $0xfffffff0,%edx
8010678a:	83 ca 0e             	or     $0xe,%edx
8010678d:	88 14 c5 e5 4b 11 80 	mov    %dl,-0x7feeb41b(,%eax,8)
80106794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106797:	0f b6 14 c5 e5 4b 11 	movzbl -0x7feeb41b(,%eax,8),%edx
8010679e:	80 
8010679f:	83 e2 ef             	and    $0xffffffef,%edx
801067a2:	88 14 c5 e5 4b 11 80 	mov    %dl,-0x7feeb41b(,%eax,8)
801067a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ac:	0f b6 14 c5 e5 4b 11 	movzbl -0x7feeb41b(,%eax,8),%edx
801067b3:	80 
801067b4:	83 e2 9f             	and    $0xffffff9f,%edx
801067b7:	88 14 c5 e5 4b 11 80 	mov    %dl,-0x7feeb41b(,%eax,8)
801067be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c1:	0f b6 14 c5 e5 4b 11 	movzbl -0x7feeb41b(,%eax,8),%edx
801067c8:	80 
801067c9:	83 ca 80             	or     $0xffffff80,%edx
801067cc:	88 14 c5 e5 4b 11 80 	mov    %dl,-0x7feeb41b(,%eax,8)
801067d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d6:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801067dd:	c1 e8 10             	shr    $0x10,%eax
801067e0:	89 c2                	mov    %eax,%edx
801067e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e5:	66 89 14 c5 e6 4b 11 	mov    %dx,-0x7feeb41a(,%eax,8)
801067ec:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801067ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067f1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067f8:	0f 8e 30 ff ff ff    	jle    8010672e <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067fe:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106803:	66 a3 e0 4d 11 80    	mov    %ax,0x80114de0
80106809:	66 c7 05 e2 4d 11 80 	movw   $0x8,0x80114de2
80106810:	08 00 
80106812:	0f b6 05 e4 4d 11 80 	movzbl 0x80114de4,%eax
80106819:	83 e0 e0             	and    $0xffffffe0,%eax
8010681c:	a2 e4 4d 11 80       	mov    %al,0x80114de4
80106821:	0f b6 05 e4 4d 11 80 	movzbl 0x80114de4,%eax
80106828:	83 e0 1f             	and    $0x1f,%eax
8010682b:	a2 e4 4d 11 80       	mov    %al,0x80114de4
80106830:	0f b6 05 e5 4d 11 80 	movzbl 0x80114de5,%eax
80106837:	83 c8 0f             	or     $0xf,%eax
8010683a:	a2 e5 4d 11 80       	mov    %al,0x80114de5
8010683f:	0f b6 05 e5 4d 11 80 	movzbl 0x80114de5,%eax
80106846:	83 e0 ef             	and    $0xffffffef,%eax
80106849:	a2 e5 4d 11 80       	mov    %al,0x80114de5
8010684e:	0f b6 05 e5 4d 11 80 	movzbl 0x80114de5,%eax
80106855:	83 c8 60             	or     $0x60,%eax
80106858:	a2 e5 4d 11 80       	mov    %al,0x80114de5
8010685d:	0f b6 05 e5 4d 11 80 	movzbl 0x80114de5,%eax
80106864:	83 c8 80             	or     $0xffffff80,%eax
80106867:	a2 e5 4d 11 80       	mov    %al,0x80114de5
8010686c:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106871:	c1 e8 10             	shr    $0x10,%eax
80106874:	66 a3 e6 4d 11 80    	mov    %ax,0x80114de6
  
  initlock(&tickslock, "time");
8010687a:	83 ec 08             	sub    $0x8,%esp
8010687d:	68 dc 8a 10 80       	push   $0x80108adc
80106882:	68 a0 4b 11 80       	push   $0x80114ba0
80106887:	e8 eb e7 ff ff       	call   80105077 <initlock>
8010688c:	83 c4 10             	add    $0x10,%esp
}
8010688f:	90                   	nop
80106890:	c9                   	leave  
80106891:	c3                   	ret    

80106892 <idtinit>:

void
idtinit(void)
{
80106892:	55                   	push   %ebp
80106893:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106895:	68 00 08 00 00       	push   $0x800
8010689a:	68 e0 4b 11 80       	push   $0x80114be0
8010689f:	e8 3d fe ff ff       	call   801066e1 <lidt>
801068a4:	83 c4 08             	add    $0x8,%esp
}
801068a7:	90                   	nop
801068a8:	c9                   	leave  
801068a9:	c3                   	ret    

801068aa <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801068aa:	55                   	push   %ebp
801068ab:	89 e5                	mov    %esp,%ebp
801068ad:	57                   	push   %edi
801068ae:	56                   	push   %esi
801068af:	53                   	push   %ebx
801068b0:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801068b3:	8b 45 08             	mov    0x8(%ebp),%eax
801068b6:	8b 40 30             	mov    0x30(%eax),%eax
801068b9:	83 f8 40             	cmp    $0x40,%eax
801068bc:	75 3e                	jne    801068fc <trap+0x52>
    if(proc->killed)
801068be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068c4:	8b 40 24             	mov    0x24(%eax),%eax
801068c7:	85 c0                	test   %eax,%eax
801068c9:	74 05                	je     801068d0 <trap+0x26>
      exit();
801068cb:	e8 fb df ff ff       	call   801048cb <exit>
    proc->tf = tf;
801068d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068d6:	8b 55 08             	mov    0x8(%ebp),%edx
801068d9:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801068dc:	e8 f6 ed ff ff       	call   801056d7 <syscall>
    if(proc->killed)
801068e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068e7:	8b 40 24             	mov    0x24(%eax),%eax
801068ea:	85 c0                	test   %eax,%eax
801068ec:	0f 84 1b 02 00 00    	je     80106b0d <trap+0x263>
      exit();
801068f2:	e8 d4 df ff ff       	call   801048cb <exit>
    return;
801068f7:	e9 11 02 00 00       	jmp    80106b0d <trap+0x263>
  }

  switch(tf->trapno){
801068fc:	8b 45 08             	mov    0x8(%ebp),%eax
801068ff:	8b 40 30             	mov    0x30(%eax),%eax
80106902:	83 e8 20             	sub    $0x20,%eax
80106905:	83 f8 1f             	cmp    $0x1f,%eax
80106908:	0f 87 c0 00 00 00    	ja     801069ce <trap+0x124>
8010690e:	8b 04 85 84 8b 10 80 	mov    -0x7fef747c(,%eax,4),%eax
80106915:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106917:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010691d:	0f b6 00             	movzbl (%eax),%eax
80106920:	84 c0                	test   %al,%al
80106922:	75 3d                	jne    80106961 <trap+0xb7>
      acquire(&tickslock);
80106924:	83 ec 0c             	sub    $0xc,%esp
80106927:	68 a0 4b 11 80       	push   $0x80114ba0
8010692c:	e8 68 e7 ff ff       	call   80105099 <acquire>
80106931:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106934:	a1 e0 53 11 80       	mov    0x801153e0,%eax
80106939:	83 c0 01             	add    $0x1,%eax
8010693c:	a3 e0 53 11 80       	mov    %eax,0x801153e0
      wakeup(&ticks);
80106941:	83 ec 0c             	sub    $0xc,%esp
80106944:	68 e0 53 11 80       	push   $0x801153e0
80106949:	e8 37 e5 ff ff       	call   80104e85 <wakeup>
8010694e:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106951:	83 ec 0c             	sub    $0xc,%esp
80106954:	68 a0 4b 11 80       	push   $0x80114ba0
80106959:	e8 a2 e7 ff ff       	call   80105100 <release>
8010695e:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106961:	e8 bf c6 ff ff       	call   80103025 <lapiceoi>
    break;
80106966:	e9 1c 01 00 00       	jmp    80106a87 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010696b:	e8 c8 be ff ff       	call   80102838 <ideintr>
    lapiceoi();
80106970:	e8 b0 c6 ff ff       	call   80103025 <lapiceoi>
    break;
80106975:	e9 0d 01 00 00       	jmp    80106a87 <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010697a:	e8 a8 c4 ff ff       	call   80102e27 <kbdintr>
    lapiceoi();
8010697f:	e8 a1 c6 ff ff       	call   80103025 <lapiceoi>
    break;
80106984:	e9 fe 00 00 00       	jmp    80106a87 <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106989:	e8 60 03 00 00       	call   80106cee <uartintr>
    lapiceoi();
8010698e:	e8 92 c6 ff ff       	call   80103025 <lapiceoi>
    break;
80106993:	e9 ef 00 00 00       	jmp    80106a87 <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106998:	8b 45 08             	mov    0x8(%ebp),%eax
8010699b:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010699e:	8b 45 08             	mov    0x8(%ebp),%eax
801069a1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069a5:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801069a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069ae:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801069b1:	0f b6 c0             	movzbl %al,%eax
801069b4:	51                   	push   %ecx
801069b5:	52                   	push   %edx
801069b6:	50                   	push   %eax
801069b7:	68 e4 8a 10 80       	push   $0x80108ae4
801069bc:	e8 05 9a ff ff       	call   801003c6 <cprintf>
801069c1:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801069c4:	e8 5c c6 ff ff       	call   80103025 <lapiceoi>
    break;
801069c9:	e9 b9 00 00 00       	jmp    80106a87 <trap+0x1dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801069ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069d4:	85 c0                	test   %eax,%eax
801069d6:	74 11                	je     801069e9 <trap+0x13f>
801069d8:	8b 45 08             	mov    0x8(%ebp),%eax
801069db:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801069df:	0f b7 c0             	movzwl %ax,%eax
801069e2:	83 e0 03             	and    $0x3,%eax
801069e5:	85 c0                	test   %eax,%eax
801069e7:	75 40                	jne    80106a29 <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069e9:	e8 1d fd ff ff       	call   8010670b <rcr2>
801069ee:	89 c3                	mov    %eax,%ebx
801069f0:	8b 45 08             	mov    0x8(%ebp),%eax
801069f3:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069f6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069fc:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069ff:	0f b6 d0             	movzbl %al,%edx
80106a02:	8b 45 08             	mov    0x8(%ebp),%eax
80106a05:	8b 40 30             	mov    0x30(%eax),%eax
80106a08:	83 ec 0c             	sub    $0xc,%esp
80106a0b:	53                   	push   %ebx
80106a0c:	51                   	push   %ecx
80106a0d:	52                   	push   %edx
80106a0e:	50                   	push   %eax
80106a0f:	68 08 8b 10 80       	push   $0x80108b08
80106a14:	e8 ad 99 ff ff       	call   801003c6 <cprintf>
80106a19:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106a1c:	83 ec 0c             	sub    $0xc,%esp
80106a1f:	68 3a 8b 10 80       	push   $0x80108b3a
80106a24:	e8 3d 9b ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a29:	e8 dd fc ff ff       	call   8010670b <rcr2>
80106a2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a31:	8b 45 08             	mov    0x8(%ebp),%eax
80106a34:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a37:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a3d:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a40:	0f b6 d8             	movzbl %al,%ebx
80106a43:	8b 45 08             	mov    0x8(%ebp),%eax
80106a46:	8b 48 34             	mov    0x34(%eax),%ecx
80106a49:	8b 45 08             	mov    0x8(%ebp),%eax
80106a4c:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a55:	8d 78 6c             	lea    0x6c(%eax),%edi
80106a58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a5e:	8b 40 10             	mov    0x10(%eax),%eax
80106a61:	ff 75 e4             	pushl  -0x1c(%ebp)
80106a64:	56                   	push   %esi
80106a65:	53                   	push   %ebx
80106a66:	51                   	push   %ecx
80106a67:	52                   	push   %edx
80106a68:	57                   	push   %edi
80106a69:	50                   	push   %eax
80106a6a:	68 40 8b 10 80       	push   $0x80108b40
80106a6f:	e8 52 99 ff ff       	call   801003c6 <cprintf>
80106a74:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106a77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a7d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a84:	eb 01                	jmp    80106a87 <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a86:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a87:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a8d:	85 c0                	test   %eax,%eax
80106a8f:	74 24                	je     80106ab5 <trap+0x20b>
80106a91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a97:	8b 40 24             	mov    0x24(%eax),%eax
80106a9a:	85 c0                	test   %eax,%eax
80106a9c:	74 17                	je     80106ab5 <trap+0x20b>
80106a9e:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106aa5:	0f b7 c0             	movzwl %ax,%eax
80106aa8:	83 e0 03             	and    $0x3,%eax
80106aab:	83 f8 03             	cmp    $0x3,%eax
80106aae:	75 05                	jne    80106ab5 <trap+0x20b>
    exit();
80106ab0:	e8 16 de ff ff       	call   801048cb <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106abb:	85 c0                	test   %eax,%eax
80106abd:	74 1e                	je     80106add <trap+0x233>
80106abf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ac5:	8b 40 0c             	mov    0xc(%eax),%eax
80106ac8:	83 f8 04             	cmp    $0x4,%eax
80106acb:	75 10                	jne    80106add <trap+0x233>
80106acd:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad0:	8b 40 30             	mov    0x30(%eax),%eax
80106ad3:	83 f8 20             	cmp    $0x20,%eax
80106ad6:	75 05                	jne    80106add <trap+0x233>
    yield();
80106ad8:	e8 39 e2 ff ff       	call   80104d16 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106add:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ae3:	85 c0                	test   %eax,%eax
80106ae5:	74 27                	je     80106b0e <trap+0x264>
80106ae7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aed:	8b 40 24             	mov    0x24(%eax),%eax
80106af0:	85 c0                	test   %eax,%eax
80106af2:	74 1a                	je     80106b0e <trap+0x264>
80106af4:	8b 45 08             	mov    0x8(%ebp),%eax
80106af7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106afb:	0f b7 c0             	movzwl %ax,%eax
80106afe:	83 e0 03             	and    $0x3,%eax
80106b01:	83 f8 03             	cmp    $0x3,%eax
80106b04:	75 08                	jne    80106b0e <trap+0x264>
    exit();
80106b06:	e8 c0 dd ff ff       	call   801048cb <exit>
80106b0b:	eb 01                	jmp    80106b0e <trap+0x264>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106b0d:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b11:	5b                   	pop    %ebx
80106b12:	5e                   	pop    %esi
80106b13:	5f                   	pop    %edi
80106b14:	5d                   	pop    %ebp
80106b15:	c3                   	ret    

80106b16 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106b16:	55                   	push   %ebp
80106b17:	89 e5                	mov    %esp,%ebp
80106b19:	83 ec 14             	sub    $0x14,%esp
80106b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106b1f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b23:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106b27:	89 c2                	mov    %eax,%edx
80106b29:	ec                   	in     (%dx),%al
80106b2a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106b2d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106b31:	c9                   	leave  
80106b32:	c3                   	ret    

80106b33 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b33:	55                   	push   %ebp
80106b34:	89 e5                	mov    %esp,%ebp
80106b36:	83 ec 08             	sub    $0x8,%esp
80106b39:	8b 55 08             	mov    0x8(%ebp),%edx
80106b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b3f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b43:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b46:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b4a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b4e:	ee                   	out    %al,(%dx)
}
80106b4f:	90                   	nop
80106b50:	c9                   	leave  
80106b51:	c3                   	ret    

80106b52 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b52:	55                   	push   %ebp
80106b53:	89 e5                	mov    %esp,%ebp
80106b55:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b58:	6a 00                	push   $0x0
80106b5a:	68 fa 03 00 00       	push   $0x3fa
80106b5f:	e8 cf ff ff ff       	call   80106b33 <outb>
80106b64:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b67:	68 80 00 00 00       	push   $0x80
80106b6c:	68 fb 03 00 00       	push   $0x3fb
80106b71:	e8 bd ff ff ff       	call   80106b33 <outb>
80106b76:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b79:	6a 0c                	push   $0xc
80106b7b:	68 f8 03 00 00       	push   $0x3f8
80106b80:	e8 ae ff ff ff       	call   80106b33 <outb>
80106b85:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b88:	6a 00                	push   $0x0
80106b8a:	68 f9 03 00 00       	push   $0x3f9
80106b8f:	e8 9f ff ff ff       	call   80106b33 <outb>
80106b94:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b97:	6a 03                	push   $0x3
80106b99:	68 fb 03 00 00       	push   $0x3fb
80106b9e:	e8 90 ff ff ff       	call   80106b33 <outb>
80106ba3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106ba6:	6a 00                	push   $0x0
80106ba8:	68 fc 03 00 00       	push   $0x3fc
80106bad:	e8 81 ff ff ff       	call   80106b33 <outb>
80106bb2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106bb5:	6a 01                	push   $0x1
80106bb7:	68 f9 03 00 00       	push   $0x3f9
80106bbc:	e8 72 ff ff ff       	call   80106b33 <outb>
80106bc1:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bc4:	68 fd 03 00 00       	push   $0x3fd
80106bc9:	e8 48 ff ff ff       	call   80106b16 <inb>
80106bce:	83 c4 04             	add    $0x4,%esp
80106bd1:	3c ff                	cmp    $0xff,%al
80106bd3:	74 6e                	je     80106c43 <uartinit+0xf1>
    return;
  uart = 1;
80106bd5:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106bdc:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bdf:	68 fa 03 00 00       	push   $0x3fa
80106be4:	e8 2d ff ff ff       	call   80106b16 <inb>
80106be9:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106bec:	68 f8 03 00 00       	push   $0x3f8
80106bf1:	e8 20 ff ff ff       	call   80106b16 <inb>
80106bf6:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106bf9:	83 ec 0c             	sub    $0xc,%esp
80106bfc:	6a 04                	push   $0x4
80106bfe:	e8 28 d3 ff ff       	call   80103f2b <picenable>
80106c03:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106c06:	83 ec 08             	sub    $0x8,%esp
80106c09:	6a 00                	push   $0x0
80106c0b:	6a 04                	push   $0x4
80106c0d:	e8 c8 be ff ff       	call   80102ada <ioapicenable>
80106c12:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c15:	c7 45 f4 04 8c 10 80 	movl   $0x80108c04,-0xc(%ebp)
80106c1c:	eb 19                	jmp    80106c37 <uartinit+0xe5>
    uartputc(*p);
80106c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c21:	0f b6 00             	movzbl (%eax),%eax
80106c24:	0f be c0             	movsbl %al,%eax
80106c27:	83 ec 0c             	sub    $0xc,%esp
80106c2a:	50                   	push   %eax
80106c2b:	e8 16 00 00 00       	call   80106c46 <uartputc>
80106c30:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c33:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3a:	0f b6 00             	movzbl (%eax),%eax
80106c3d:	84 c0                	test   %al,%al
80106c3f:	75 dd                	jne    80106c1e <uartinit+0xcc>
80106c41:	eb 01                	jmp    80106c44 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106c43:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106c44:	c9                   	leave  
80106c45:	c3                   	ret    

80106c46 <uartputc>:

void
uartputc(int c)
{
80106c46:	55                   	push   %ebp
80106c47:	89 e5                	mov    %esp,%ebp
80106c49:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106c4c:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106c51:	85 c0                	test   %eax,%eax
80106c53:	74 53                	je     80106ca8 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c5c:	eb 11                	jmp    80106c6f <uartputc+0x29>
    microdelay(10);
80106c5e:	83 ec 0c             	sub    $0xc,%esp
80106c61:	6a 0a                	push   $0xa
80106c63:	e8 d8 c3 ff ff       	call   80103040 <microdelay>
80106c68:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c6f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c73:	7f 1a                	jg     80106c8f <uartputc+0x49>
80106c75:	83 ec 0c             	sub    $0xc,%esp
80106c78:	68 fd 03 00 00       	push   $0x3fd
80106c7d:	e8 94 fe ff ff       	call   80106b16 <inb>
80106c82:	83 c4 10             	add    $0x10,%esp
80106c85:	0f b6 c0             	movzbl %al,%eax
80106c88:	83 e0 20             	and    $0x20,%eax
80106c8b:	85 c0                	test   %eax,%eax
80106c8d:	74 cf                	je     80106c5e <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c92:	0f b6 c0             	movzbl %al,%eax
80106c95:	83 ec 08             	sub    $0x8,%esp
80106c98:	50                   	push   %eax
80106c99:	68 f8 03 00 00       	push   $0x3f8
80106c9e:	e8 90 fe ff ff       	call   80106b33 <outb>
80106ca3:	83 c4 10             	add    $0x10,%esp
80106ca6:	eb 01                	jmp    80106ca9 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106ca8:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106ca9:	c9                   	leave  
80106caa:	c3                   	ret    

80106cab <uartgetc>:

static int
uartgetc(void)
{
80106cab:	55                   	push   %ebp
80106cac:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106cae:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106cb3:	85 c0                	test   %eax,%eax
80106cb5:	75 07                	jne    80106cbe <uartgetc+0x13>
    return -1;
80106cb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cbc:	eb 2e                	jmp    80106cec <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106cbe:	68 fd 03 00 00       	push   $0x3fd
80106cc3:	e8 4e fe ff ff       	call   80106b16 <inb>
80106cc8:	83 c4 04             	add    $0x4,%esp
80106ccb:	0f b6 c0             	movzbl %al,%eax
80106cce:	83 e0 01             	and    $0x1,%eax
80106cd1:	85 c0                	test   %eax,%eax
80106cd3:	75 07                	jne    80106cdc <uartgetc+0x31>
    return -1;
80106cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cda:	eb 10                	jmp    80106cec <uartgetc+0x41>
  return inb(COM1+0);
80106cdc:	68 f8 03 00 00       	push   $0x3f8
80106ce1:	e8 30 fe ff ff       	call   80106b16 <inb>
80106ce6:	83 c4 04             	add    $0x4,%esp
80106ce9:	0f b6 c0             	movzbl %al,%eax
}
80106cec:	c9                   	leave  
80106ced:	c3                   	ret    

80106cee <uartintr>:

void
uartintr(void)
{
80106cee:	55                   	push   %ebp
80106cef:	89 e5                	mov    %esp,%ebp
80106cf1:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106cf4:	83 ec 0c             	sub    $0xc,%esp
80106cf7:	68 ab 6c 10 80       	push   $0x80106cab
80106cfc:	e8 f8 9a ff ff       	call   801007f9 <consoleintr>
80106d01:	83 c4 10             	add    $0x10,%esp
}
80106d04:	90                   	nop
80106d05:	c9                   	leave  
80106d06:	c3                   	ret    

80106d07 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $0
80106d09:	6a 00                	push   $0x0
  jmp alltraps
80106d0b:	e9 a6 f9 ff ff       	jmp    801066b6 <alltraps>

80106d10 <vector1>:
.globl vector1
vector1:
  pushl $0
80106d10:	6a 00                	push   $0x0
  pushl $1
80106d12:	6a 01                	push   $0x1
  jmp alltraps
80106d14:	e9 9d f9 ff ff       	jmp    801066b6 <alltraps>

80106d19 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d19:	6a 00                	push   $0x0
  pushl $2
80106d1b:	6a 02                	push   $0x2
  jmp alltraps
80106d1d:	e9 94 f9 ff ff       	jmp    801066b6 <alltraps>

80106d22 <vector3>:
.globl vector3
vector3:
  pushl $0
80106d22:	6a 00                	push   $0x0
  pushl $3
80106d24:	6a 03                	push   $0x3
  jmp alltraps
80106d26:	e9 8b f9 ff ff       	jmp    801066b6 <alltraps>

80106d2b <vector4>:
.globl vector4
vector4:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $4
80106d2d:	6a 04                	push   $0x4
  jmp alltraps
80106d2f:	e9 82 f9 ff ff       	jmp    801066b6 <alltraps>

80106d34 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d34:	6a 00                	push   $0x0
  pushl $5
80106d36:	6a 05                	push   $0x5
  jmp alltraps
80106d38:	e9 79 f9 ff ff       	jmp    801066b6 <alltraps>

80106d3d <vector6>:
.globl vector6
vector6:
  pushl $0
80106d3d:	6a 00                	push   $0x0
  pushl $6
80106d3f:	6a 06                	push   $0x6
  jmp alltraps
80106d41:	e9 70 f9 ff ff       	jmp    801066b6 <alltraps>

80106d46 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d46:	6a 00                	push   $0x0
  pushl $7
80106d48:	6a 07                	push   $0x7
  jmp alltraps
80106d4a:	e9 67 f9 ff ff       	jmp    801066b6 <alltraps>

80106d4f <vector8>:
.globl vector8
vector8:
  pushl $8
80106d4f:	6a 08                	push   $0x8
  jmp alltraps
80106d51:	e9 60 f9 ff ff       	jmp    801066b6 <alltraps>

80106d56 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $9
80106d58:	6a 09                	push   $0x9
  jmp alltraps
80106d5a:	e9 57 f9 ff ff       	jmp    801066b6 <alltraps>

80106d5f <vector10>:
.globl vector10
vector10:
  pushl $10
80106d5f:	6a 0a                	push   $0xa
  jmp alltraps
80106d61:	e9 50 f9 ff ff       	jmp    801066b6 <alltraps>

80106d66 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d66:	6a 0b                	push   $0xb
  jmp alltraps
80106d68:	e9 49 f9 ff ff       	jmp    801066b6 <alltraps>

80106d6d <vector12>:
.globl vector12
vector12:
  pushl $12
80106d6d:	6a 0c                	push   $0xc
  jmp alltraps
80106d6f:	e9 42 f9 ff ff       	jmp    801066b6 <alltraps>

80106d74 <vector13>:
.globl vector13
vector13:
  pushl $13
80106d74:	6a 0d                	push   $0xd
  jmp alltraps
80106d76:	e9 3b f9 ff ff       	jmp    801066b6 <alltraps>

80106d7b <vector14>:
.globl vector14
vector14:
  pushl $14
80106d7b:	6a 0e                	push   $0xe
  jmp alltraps
80106d7d:	e9 34 f9 ff ff       	jmp    801066b6 <alltraps>

80106d82 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $15
80106d84:	6a 0f                	push   $0xf
  jmp alltraps
80106d86:	e9 2b f9 ff ff       	jmp    801066b6 <alltraps>

80106d8b <vector16>:
.globl vector16
vector16:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $16
80106d8d:	6a 10                	push   $0x10
  jmp alltraps
80106d8f:	e9 22 f9 ff ff       	jmp    801066b6 <alltraps>

80106d94 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d94:	6a 11                	push   $0x11
  jmp alltraps
80106d96:	e9 1b f9 ff ff       	jmp    801066b6 <alltraps>

80106d9b <vector18>:
.globl vector18
vector18:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $18
80106d9d:	6a 12                	push   $0x12
  jmp alltraps
80106d9f:	e9 12 f9 ff ff       	jmp    801066b6 <alltraps>

80106da4 <vector19>:
.globl vector19
vector19:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $19
80106da6:	6a 13                	push   $0x13
  jmp alltraps
80106da8:	e9 09 f9 ff ff       	jmp    801066b6 <alltraps>

80106dad <vector20>:
.globl vector20
vector20:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $20
80106daf:	6a 14                	push   $0x14
  jmp alltraps
80106db1:	e9 00 f9 ff ff       	jmp    801066b6 <alltraps>

80106db6 <vector21>:
.globl vector21
vector21:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $21
80106db8:	6a 15                	push   $0x15
  jmp alltraps
80106dba:	e9 f7 f8 ff ff       	jmp    801066b6 <alltraps>

80106dbf <vector22>:
.globl vector22
vector22:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $22
80106dc1:	6a 16                	push   $0x16
  jmp alltraps
80106dc3:	e9 ee f8 ff ff       	jmp    801066b6 <alltraps>

80106dc8 <vector23>:
.globl vector23
vector23:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $23
80106dca:	6a 17                	push   $0x17
  jmp alltraps
80106dcc:	e9 e5 f8 ff ff       	jmp    801066b6 <alltraps>

80106dd1 <vector24>:
.globl vector24
vector24:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $24
80106dd3:	6a 18                	push   $0x18
  jmp alltraps
80106dd5:	e9 dc f8 ff ff       	jmp    801066b6 <alltraps>

80106dda <vector25>:
.globl vector25
vector25:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $25
80106ddc:	6a 19                	push   $0x19
  jmp alltraps
80106dde:	e9 d3 f8 ff ff       	jmp    801066b6 <alltraps>

80106de3 <vector26>:
.globl vector26
vector26:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $26
80106de5:	6a 1a                	push   $0x1a
  jmp alltraps
80106de7:	e9 ca f8 ff ff       	jmp    801066b6 <alltraps>

80106dec <vector27>:
.globl vector27
vector27:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $27
80106dee:	6a 1b                	push   $0x1b
  jmp alltraps
80106df0:	e9 c1 f8 ff ff       	jmp    801066b6 <alltraps>

80106df5 <vector28>:
.globl vector28
vector28:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $28
80106df7:	6a 1c                	push   $0x1c
  jmp alltraps
80106df9:	e9 b8 f8 ff ff       	jmp    801066b6 <alltraps>

80106dfe <vector29>:
.globl vector29
vector29:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $29
80106e00:	6a 1d                	push   $0x1d
  jmp alltraps
80106e02:	e9 af f8 ff ff       	jmp    801066b6 <alltraps>

80106e07 <vector30>:
.globl vector30
vector30:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $30
80106e09:	6a 1e                	push   $0x1e
  jmp alltraps
80106e0b:	e9 a6 f8 ff ff       	jmp    801066b6 <alltraps>

80106e10 <vector31>:
.globl vector31
vector31:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $31
80106e12:	6a 1f                	push   $0x1f
  jmp alltraps
80106e14:	e9 9d f8 ff ff       	jmp    801066b6 <alltraps>

80106e19 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $32
80106e1b:	6a 20                	push   $0x20
  jmp alltraps
80106e1d:	e9 94 f8 ff ff       	jmp    801066b6 <alltraps>

80106e22 <vector33>:
.globl vector33
vector33:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $33
80106e24:	6a 21                	push   $0x21
  jmp alltraps
80106e26:	e9 8b f8 ff ff       	jmp    801066b6 <alltraps>

80106e2b <vector34>:
.globl vector34
vector34:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $34
80106e2d:	6a 22                	push   $0x22
  jmp alltraps
80106e2f:	e9 82 f8 ff ff       	jmp    801066b6 <alltraps>

80106e34 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $35
80106e36:	6a 23                	push   $0x23
  jmp alltraps
80106e38:	e9 79 f8 ff ff       	jmp    801066b6 <alltraps>

80106e3d <vector36>:
.globl vector36
vector36:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $36
80106e3f:	6a 24                	push   $0x24
  jmp alltraps
80106e41:	e9 70 f8 ff ff       	jmp    801066b6 <alltraps>

80106e46 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $37
80106e48:	6a 25                	push   $0x25
  jmp alltraps
80106e4a:	e9 67 f8 ff ff       	jmp    801066b6 <alltraps>

80106e4f <vector38>:
.globl vector38
vector38:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $38
80106e51:	6a 26                	push   $0x26
  jmp alltraps
80106e53:	e9 5e f8 ff ff       	jmp    801066b6 <alltraps>

80106e58 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $39
80106e5a:	6a 27                	push   $0x27
  jmp alltraps
80106e5c:	e9 55 f8 ff ff       	jmp    801066b6 <alltraps>

80106e61 <vector40>:
.globl vector40
vector40:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $40
80106e63:	6a 28                	push   $0x28
  jmp alltraps
80106e65:	e9 4c f8 ff ff       	jmp    801066b6 <alltraps>

80106e6a <vector41>:
.globl vector41
vector41:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $41
80106e6c:	6a 29                	push   $0x29
  jmp alltraps
80106e6e:	e9 43 f8 ff ff       	jmp    801066b6 <alltraps>

80106e73 <vector42>:
.globl vector42
vector42:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $42
80106e75:	6a 2a                	push   $0x2a
  jmp alltraps
80106e77:	e9 3a f8 ff ff       	jmp    801066b6 <alltraps>

80106e7c <vector43>:
.globl vector43
vector43:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $43
80106e7e:	6a 2b                	push   $0x2b
  jmp alltraps
80106e80:	e9 31 f8 ff ff       	jmp    801066b6 <alltraps>

80106e85 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $44
80106e87:	6a 2c                	push   $0x2c
  jmp alltraps
80106e89:	e9 28 f8 ff ff       	jmp    801066b6 <alltraps>

80106e8e <vector45>:
.globl vector45
vector45:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $45
80106e90:	6a 2d                	push   $0x2d
  jmp alltraps
80106e92:	e9 1f f8 ff ff       	jmp    801066b6 <alltraps>

80106e97 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $46
80106e99:	6a 2e                	push   $0x2e
  jmp alltraps
80106e9b:	e9 16 f8 ff ff       	jmp    801066b6 <alltraps>

80106ea0 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $47
80106ea2:	6a 2f                	push   $0x2f
  jmp alltraps
80106ea4:	e9 0d f8 ff ff       	jmp    801066b6 <alltraps>

80106ea9 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $48
80106eab:	6a 30                	push   $0x30
  jmp alltraps
80106ead:	e9 04 f8 ff ff       	jmp    801066b6 <alltraps>

80106eb2 <vector49>:
.globl vector49
vector49:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $49
80106eb4:	6a 31                	push   $0x31
  jmp alltraps
80106eb6:	e9 fb f7 ff ff       	jmp    801066b6 <alltraps>

80106ebb <vector50>:
.globl vector50
vector50:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $50
80106ebd:	6a 32                	push   $0x32
  jmp alltraps
80106ebf:	e9 f2 f7 ff ff       	jmp    801066b6 <alltraps>

80106ec4 <vector51>:
.globl vector51
vector51:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $51
80106ec6:	6a 33                	push   $0x33
  jmp alltraps
80106ec8:	e9 e9 f7 ff ff       	jmp    801066b6 <alltraps>

80106ecd <vector52>:
.globl vector52
vector52:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $52
80106ecf:	6a 34                	push   $0x34
  jmp alltraps
80106ed1:	e9 e0 f7 ff ff       	jmp    801066b6 <alltraps>

80106ed6 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $53
80106ed8:	6a 35                	push   $0x35
  jmp alltraps
80106eda:	e9 d7 f7 ff ff       	jmp    801066b6 <alltraps>

80106edf <vector54>:
.globl vector54
vector54:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $54
80106ee1:	6a 36                	push   $0x36
  jmp alltraps
80106ee3:	e9 ce f7 ff ff       	jmp    801066b6 <alltraps>

80106ee8 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $55
80106eea:	6a 37                	push   $0x37
  jmp alltraps
80106eec:	e9 c5 f7 ff ff       	jmp    801066b6 <alltraps>

80106ef1 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $56
80106ef3:	6a 38                	push   $0x38
  jmp alltraps
80106ef5:	e9 bc f7 ff ff       	jmp    801066b6 <alltraps>

80106efa <vector57>:
.globl vector57
vector57:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $57
80106efc:	6a 39                	push   $0x39
  jmp alltraps
80106efe:	e9 b3 f7 ff ff       	jmp    801066b6 <alltraps>

80106f03 <vector58>:
.globl vector58
vector58:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $58
80106f05:	6a 3a                	push   $0x3a
  jmp alltraps
80106f07:	e9 aa f7 ff ff       	jmp    801066b6 <alltraps>

80106f0c <vector59>:
.globl vector59
vector59:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $59
80106f0e:	6a 3b                	push   $0x3b
  jmp alltraps
80106f10:	e9 a1 f7 ff ff       	jmp    801066b6 <alltraps>

80106f15 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $60
80106f17:	6a 3c                	push   $0x3c
  jmp alltraps
80106f19:	e9 98 f7 ff ff       	jmp    801066b6 <alltraps>

80106f1e <vector61>:
.globl vector61
vector61:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $61
80106f20:	6a 3d                	push   $0x3d
  jmp alltraps
80106f22:	e9 8f f7 ff ff       	jmp    801066b6 <alltraps>

80106f27 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $62
80106f29:	6a 3e                	push   $0x3e
  jmp alltraps
80106f2b:	e9 86 f7 ff ff       	jmp    801066b6 <alltraps>

80106f30 <vector63>:
.globl vector63
vector63:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $63
80106f32:	6a 3f                	push   $0x3f
  jmp alltraps
80106f34:	e9 7d f7 ff ff       	jmp    801066b6 <alltraps>

80106f39 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $64
80106f3b:	6a 40                	push   $0x40
  jmp alltraps
80106f3d:	e9 74 f7 ff ff       	jmp    801066b6 <alltraps>

80106f42 <vector65>:
.globl vector65
vector65:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $65
80106f44:	6a 41                	push   $0x41
  jmp alltraps
80106f46:	e9 6b f7 ff ff       	jmp    801066b6 <alltraps>

80106f4b <vector66>:
.globl vector66
vector66:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $66
80106f4d:	6a 42                	push   $0x42
  jmp alltraps
80106f4f:	e9 62 f7 ff ff       	jmp    801066b6 <alltraps>

80106f54 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $67
80106f56:	6a 43                	push   $0x43
  jmp alltraps
80106f58:	e9 59 f7 ff ff       	jmp    801066b6 <alltraps>

80106f5d <vector68>:
.globl vector68
vector68:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $68
80106f5f:	6a 44                	push   $0x44
  jmp alltraps
80106f61:	e9 50 f7 ff ff       	jmp    801066b6 <alltraps>

80106f66 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $69
80106f68:	6a 45                	push   $0x45
  jmp alltraps
80106f6a:	e9 47 f7 ff ff       	jmp    801066b6 <alltraps>

80106f6f <vector70>:
.globl vector70
vector70:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $70
80106f71:	6a 46                	push   $0x46
  jmp alltraps
80106f73:	e9 3e f7 ff ff       	jmp    801066b6 <alltraps>

80106f78 <vector71>:
.globl vector71
vector71:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $71
80106f7a:	6a 47                	push   $0x47
  jmp alltraps
80106f7c:	e9 35 f7 ff ff       	jmp    801066b6 <alltraps>

80106f81 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $72
80106f83:	6a 48                	push   $0x48
  jmp alltraps
80106f85:	e9 2c f7 ff ff       	jmp    801066b6 <alltraps>

80106f8a <vector73>:
.globl vector73
vector73:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $73
80106f8c:	6a 49                	push   $0x49
  jmp alltraps
80106f8e:	e9 23 f7 ff ff       	jmp    801066b6 <alltraps>

80106f93 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $74
80106f95:	6a 4a                	push   $0x4a
  jmp alltraps
80106f97:	e9 1a f7 ff ff       	jmp    801066b6 <alltraps>

80106f9c <vector75>:
.globl vector75
vector75:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $75
80106f9e:	6a 4b                	push   $0x4b
  jmp alltraps
80106fa0:	e9 11 f7 ff ff       	jmp    801066b6 <alltraps>

80106fa5 <vector76>:
.globl vector76
vector76:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $76
80106fa7:	6a 4c                	push   $0x4c
  jmp alltraps
80106fa9:	e9 08 f7 ff ff       	jmp    801066b6 <alltraps>

80106fae <vector77>:
.globl vector77
vector77:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $77
80106fb0:	6a 4d                	push   $0x4d
  jmp alltraps
80106fb2:	e9 ff f6 ff ff       	jmp    801066b6 <alltraps>

80106fb7 <vector78>:
.globl vector78
vector78:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $78
80106fb9:	6a 4e                	push   $0x4e
  jmp alltraps
80106fbb:	e9 f6 f6 ff ff       	jmp    801066b6 <alltraps>

80106fc0 <vector79>:
.globl vector79
vector79:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $79
80106fc2:	6a 4f                	push   $0x4f
  jmp alltraps
80106fc4:	e9 ed f6 ff ff       	jmp    801066b6 <alltraps>

80106fc9 <vector80>:
.globl vector80
vector80:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $80
80106fcb:	6a 50                	push   $0x50
  jmp alltraps
80106fcd:	e9 e4 f6 ff ff       	jmp    801066b6 <alltraps>

80106fd2 <vector81>:
.globl vector81
vector81:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $81
80106fd4:	6a 51                	push   $0x51
  jmp alltraps
80106fd6:	e9 db f6 ff ff       	jmp    801066b6 <alltraps>

80106fdb <vector82>:
.globl vector82
vector82:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $82
80106fdd:	6a 52                	push   $0x52
  jmp alltraps
80106fdf:	e9 d2 f6 ff ff       	jmp    801066b6 <alltraps>

80106fe4 <vector83>:
.globl vector83
vector83:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $83
80106fe6:	6a 53                	push   $0x53
  jmp alltraps
80106fe8:	e9 c9 f6 ff ff       	jmp    801066b6 <alltraps>

80106fed <vector84>:
.globl vector84
vector84:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $84
80106fef:	6a 54                	push   $0x54
  jmp alltraps
80106ff1:	e9 c0 f6 ff ff       	jmp    801066b6 <alltraps>

80106ff6 <vector85>:
.globl vector85
vector85:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $85
80106ff8:	6a 55                	push   $0x55
  jmp alltraps
80106ffa:	e9 b7 f6 ff ff       	jmp    801066b6 <alltraps>

80106fff <vector86>:
.globl vector86
vector86:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $86
80107001:	6a 56                	push   $0x56
  jmp alltraps
80107003:	e9 ae f6 ff ff       	jmp    801066b6 <alltraps>

80107008 <vector87>:
.globl vector87
vector87:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $87
8010700a:	6a 57                	push   $0x57
  jmp alltraps
8010700c:	e9 a5 f6 ff ff       	jmp    801066b6 <alltraps>

80107011 <vector88>:
.globl vector88
vector88:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $88
80107013:	6a 58                	push   $0x58
  jmp alltraps
80107015:	e9 9c f6 ff ff       	jmp    801066b6 <alltraps>

8010701a <vector89>:
.globl vector89
vector89:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $89
8010701c:	6a 59                	push   $0x59
  jmp alltraps
8010701e:	e9 93 f6 ff ff       	jmp    801066b6 <alltraps>

80107023 <vector90>:
.globl vector90
vector90:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $90
80107025:	6a 5a                	push   $0x5a
  jmp alltraps
80107027:	e9 8a f6 ff ff       	jmp    801066b6 <alltraps>

8010702c <vector91>:
.globl vector91
vector91:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $91
8010702e:	6a 5b                	push   $0x5b
  jmp alltraps
80107030:	e9 81 f6 ff ff       	jmp    801066b6 <alltraps>

80107035 <vector92>:
.globl vector92
vector92:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $92
80107037:	6a 5c                	push   $0x5c
  jmp alltraps
80107039:	e9 78 f6 ff ff       	jmp    801066b6 <alltraps>

8010703e <vector93>:
.globl vector93
vector93:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $93
80107040:	6a 5d                	push   $0x5d
  jmp alltraps
80107042:	e9 6f f6 ff ff       	jmp    801066b6 <alltraps>

80107047 <vector94>:
.globl vector94
vector94:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $94
80107049:	6a 5e                	push   $0x5e
  jmp alltraps
8010704b:	e9 66 f6 ff ff       	jmp    801066b6 <alltraps>

80107050 <vector95>:
.globl vector95
vector95:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $95
80107052:	6a 5f                	push   $0x5f
  jmp alltraps
80107054:	e9 5d f6 ff ff       	jmp    801066b6 <alltraps>

80107059 <vector96>:
.globl vector96
vector96:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $96
8010705b:	6a 60                	push   $0x60
  jmp alltraps
8010705d:	e9 54 f6 ff ff       	jmp    801066b6 <alltraps>

80107062 <vector97>:
.globl vector97
vector97:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $97
80107064:	6a 61                	push   $0x61
  jmp alltraps
80107066:	e9 4b f6 ff ff       	jmp    801066b6 <alltraps>

8010706b <vector98>:
.globl vector98
vector98:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $98
8010706d:	6a 62                	push   $0x62
  jmp alltraps
8010706f:	e9 42 f6 ff ff       	jmp    801066b6 <alltraps>

80107074 <vector99>:
.globl vector99
vector99:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $99
80107076:	6a 63                	push   $0x63
  jmp alltraps
80107078:	e9 39 f6 ff ff       	jmp    801066b6 <alltraps>

8010707d <vector100>:
.globl vector100
vector100:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $100
8010707f:	6a 64                	push   $0x64
  jmp alltraps
80107081:	e9 30 f6 ff ff       	jmp    801066b6 <alltraps>

80107086 <vector101>:
.globl vector101
vector101:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $101
80107088:	6a 65                	push   $0x65
  jmp alltraps
8010708a:	e9 27 f6 ff ff       	jmp    801066b6 <alltraps>

8010708f <vector102>:
.globl vector102
vector102:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $102
80107091:	6a 66                	push   $0x66
  jmp alltraps
80107093:	e9 1e f6 ff ff       	jmp    801066b6 <alltraps>

80107098 <vector103>:
.globl vector103
vector103:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $103
8010709a:	6a 67                	push   $0x67
  jmp alltraps
8010709c:	e9 15 f6 ff ff       	jmp    801066b6 <alltraps>

801070a1 <vector104>:
.globl vector104
vector104:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $104
801070a3:	6a 68                	push   $0x68
  jmp alltraps
801070a5:	e9 0c f6 ff ff       	jmp    801066b6 <alltraps>

801070aa <vector105>:
.globl vector105
vector105:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $105
801070ac:	6a 69                	push   $0x69
  jmp alltraps
801070ae:	e9 03 f6 ff ff       	jmp    801066b6 <alltraps>

801070b3 <vector106>:
.globl vector106
vector106:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $106
801070b5:	6a 6a                	push   $0x6a
  jmp alltraps
801070b7:	e9 fa f5 ff ff       	jmp    801066b6 <alltraps>

801070bc <vector107>:
.globl vector107
vector107:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $107
801070be:	6a 6b                	push   $0x6b
  jmp alltraps
801070c0:	e9 f1 f5 ff ff       	jmp    801066b6 <alltraps>

801070c5 <vector108>:
.globl vector108
vector108:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $108
801070c7:	6a 6c                	push   $0x6c
  jmp alltraps
801070c9:	e9 e8 f5 ff ff       	jmp    801066b6 <alltraps>

801070ce <vector109>:
.globl vector109
vector109:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $109
801070d0:	6a 6d                	push   $0x6d
  jmp alltraps
801070d2:	e9 df f5 ff ff       	jmp    801066b6 <alltraps>

801070d7 <vector110>:
.globl vector110
vector110:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $110
801070d9:	6a 6e                	push   $0x6e
  jmp alltraps
801070db:	e9 d6 f5 ff ff       	jmp    801066b6 <alltraps>

801070e0 <vector111>:
.globl vector111
vector111:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $111
801070e2:	6a 6f                	push   $0x6f
  jmp alltraps
801070e4:	e9 cd f5 ff ff       	jmp    801066b6 <alltraps>

801070e9 <vector112>:
.globl vector112
vector112:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $112
801070eb:	6a 70                	push   $0x70
  jmp alltraps
801070ed:	e9 c4 f5 ff ff       	jmp    801066b6 <alltraps>

801070f2 <vector113>:
.globl vector113
vector113:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $113
801070f4:	6a 71                	push   $0x71
  jmp alltraps
801070f6:	e9 bb f5 ff ff       	jmp    801066b6 <alltraps>

801070fb <vector114>:
.globl vector114
vector114:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $114
801070fd:	6a 72                	push   $0x72
  jmp alltraps
801070ff:	e9 b2 f5 ff ff       	jmp    801066b6 <alltraps>

80107104 <vector115>:
.globl vector115
vector115:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $115
80107106:	6a 73                	push   $0x73
  jmp alltraps
80107108:	e9 a9 f5 ff ff       	jmp    801066b6 <alltraps>

8010710d <vector116>:
.globl vector116
vector116:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $116
8010710f:	6a 74                	push   $0x74
  jmp alltraps
80107111:	e9 a0 f5 ff ff       	jmp    801066b6 <alltraps>

80107116 <vector117>:
.globl vector117
vector117:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $117
80107118:	6a 75                	push   $0x75
  jmp alltraps
8010711a:	e9 97 f5 ff ff       	jmp    801066b6 <alltraps>

8010711f <vector118>:
.globl vector118
vector118:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $118
80107121:	6a 76                	push   $0x76
  jmp alltraps
80107123:	e9 8e f5 ff ff       	jmp    801066b6 <alltraps>

80107128 <vector119>:
.globl vector119
vector119:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $119
8010712a:	6a 77                	push   $0x77
  jmp alltraps
8010712c:	e9 85 f5 ff ff       	jmp    801066b6 <alltraps>

80107131 <vector120>:
.globl vector120
vector120:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $120
80107133:	6a 78                	push   $0x78
  jmp alltraps
80107135:	e9 7c f5 ff ff       	jmp    801066b6 <alltraps>

8010713a <vector121>:
.globl vector121
vector121:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $121
8010713c:	6a 79                	push   $0x79
  jmp alltraps
8010713e:	e9 73 f5 ff ff       	jmp    801066b6 <alltraps>

80107143 <vector122>:
.globl vector122
vector122:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $122
80107145:	6a 7a                	push   $0x7a
  jmp alltraps
80107147:	e9 6a f5 ff ff       	jmp    801066b6 <alltraps>

8010714c <vector123>:
.globl vector123
vector123:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $123
8010714e:	6a 7b                	push   $0x7b
  jmp alltraps
80107150:	e9 61 f5 ff ff       	jmp    801066b6 <alltraps>

80107155 <vector124>:
.globl vector124
vector124:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $124
80107157:	6a 7c                	push   $0x7c
  jmp alltraps
80107159:	e9 58 f5 ff ff       	jmp    801066b6 <alltraps>

8010715e <vector125>:
.globl vector125
vector125:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $125
80107160:	6a 7d                	push   $0x7d
  jmp alltraps
80107162:	e9 4f f5 ff ff       	jmp    801066b6 <alltraps>

80107167 <vector126>:
.globl vector126
vector126:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $126
80107169:	6a 7e                	push   $0x7e
  jmp alltraps
8010716b:	e9 46 f5 ff ff       	jmp    801066b6 <alltraps>

80107170 <vector127>:
.globl vector127
vector127:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $127
80107172:	6a 7f                	push   $0x7f
  jmp alltraps
80107174:	e9 3d f5 ff ff       	jmp    801066b6 <alltraps>

80107179 <vector128>:
.globl vector128
vector128:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $128
8010717b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107180:	e9 31 f5 ff ff       	jmp    801066b6 <alltraps>

80107185 <vector129>:
.globl vector129
vector129:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $129
80107187:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010718c:	e9 25 f5 ff ff       	jmp    801066b6 <alltraps>

80107191 <vector130>:
.globl vector130
vector130:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $130
80107193:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107198:	e9 19 f5 ff ff       	jmp    801066b6 <alltraps>

8010719d <vector131>:
.globl vector131
vector131:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $131
8010719f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801071a4:	e9 0d f5 ff ff       	jmp    801066b6 <alltraps>

801071a9 <vector132>:
.globl vector132
vector132:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $132
801071ab:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801071b0:	e9 01 f5 ff ff       	jmp    801066b6 <alltraps>

801071b5 <vector133>:
.globl vector133
vector133:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $133
801071b7:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801071bc:	e9 f5 f4 ff ff       	jmp    801066b6 <alltraps>

801071c1 <vector134>:
.globl vector134
vector134:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $134
801071c3:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071c8:	e9 e9 f4 ff ff       	jmp    801066b6 <alltraps>

801071cd <vector135>:
.globl vector135
vector135:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $135
801071cf:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071d4:	e9 dd f4 ff ff       	jmp    801066b6 <alltraps>

801071d9 <vector136>:
.globl vector136
vector136:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $136
801071db:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071e0:	e9 d1 f4 ff ff       	jmp    801066b6 <alltraps>

801071e5 <vector137>:
.globl vector137
vector137:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $137
801071e7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071ec:	e9 c5 f4 ff ff       	jmp    801066b6 <alltraps>

801071f1 <vector138>:
.globl vector138
vector138:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $138
801071f3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071f8:	e9 b9 f4 ff ff       	jmp    801066b6 <alltraps>

801071fd <vector139>:
.globl vector139
vector139:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $139
801071ff:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107204:	e9 ad f4 ff ff       	jmp    801066b6 <alltraps>

80107209 <vector140>:
.globl vector140
vector140:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $140
8010720b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107210:	e9 a1 f4 ff ff       	jmp    801066b6 <alltraps>

80107215 <vector141>:
.globl vector141
vector141:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $141
80107217:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010721c:	e9 95 f4 ff ff       	jmp    801066b6 <alltraps>

80107221 <vector142>:
.globl vector142
vector142:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $142
80107223:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107228:	e9 89 f4 ff ff       	jmp    801066b6 <alltraps>

8010722d <vector143>:
.globl vector143
vector143:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $143
8010722f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107234:	e9 7d f4 ff ff       	jmp    801066b6 <alltraps>

80107239 <vector144>:
.globl vector144
vector144:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $144
8010723b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107240:	e9 71 f4 ff ff       	jmp    801066b6 <alltraps>

80107245 <vector145>:
.globl vector145
vector145:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $145
80107247:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010724c:	e9 65 f4 ff ff       	jmp    801066b6 <alltraps>

80107251 <vector146>:
.globl vector146
vector146:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $146
80107253:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107258:	e9 59 f4 ff ff       	jmp    801066b6 <alltraps>

8010725d <vector147>:
.globl vector147
vector147:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $147
8010725f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107264:	e9 4d f4 ff ff       	jmp    801066b6 <alltraps>

80107269 <vector148>:
.globl vector148
vector148:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $148
8010726b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107270:	e9 41 f4 ff ff       	jmp    801066b6 <alltraps>

80107275 <vector149>:
.globl vector149
vector149:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $149
80107277:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010727c:	e9 35 f4 ff ff       	jmp    801066b6 <alltraps>

80107281 <vector150>:
.globl vector150
vector150:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $150
80107283:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107288:	e9 29 f4 ff ff       	jmp    801066b6 <alltraps>

8010728d <vector151>:
.globl vector151
vector151:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $151
8010728f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107294:	e9 1d f4 ff ff       	jmp    801066b6 <alltraps>

80107299 <vector152>:
.globl vector152
vector152:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $152
8010729b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801072a0:	e9 11 f4 ff ff       	jmp    801066b6 <alltraps>

801072a5 <vector153>:
.globl vector153
vector153:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $153
801072a7:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801072ac:	e9 05 f4 ff ff       	jmp    801066b6 <alltraps>

801072b1 <vector154>:
.globl vector154
vector154:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $154
801072b3:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801072b8:	e9 f9 f3 ff ff       	jmp    801066b6 <alltraps>

801072bd <vector155>:
.globl vector155
vector155:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $155
801072bf:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801072c4:	e9 ed f3 ff ff       	jmp    801066b6 <alltraps>

801072c9 <vector156>:
.globl vector156
vector156:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $156
801072cb:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072d0:	e9 e1 f3 ff ff       	jmp    801066b6 <alltraps>

801072d5 <vector157>:
.globl vector157
vector157:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $157
801072d7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072dc:	e9 d5 f3 ff ff       	jmp    801066b6 <alltraps>

801072e1 <vector158>:
.globl vector158
vector158:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $158
801072e3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072e8:	e9 c9 f3 ff ff       	jmp    801066b6 <alltraps>

801072ed <vector159>:
.globl vector159
vector159:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $159
801072ef:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072f4:	e9 bd f3 ff ff       	jmp    801066b6 <alltraps>

801072f9 <vector160>:
.globl vector160
vector160:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $160
801072fb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107300:	e9 b1 f3 ff ff       	jmp    801066b6 <alltraps>

80107305 <vector161>:
.globl vector161
vector161:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $161
80107307:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010730c:	e9 a5 f3 ff ff       	jmp    801066b6 <alltraps>

80107311 <vector162>:
.globl vector162
vector162:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $162
80107313:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107318:	e9 99 f3 ff ff       	jmp    801066b6 <alltraps>

8010731d <vector163>:
.globl vector163
vector163:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $163
8010731f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107324:	e9 8d f3 ff ff       	jmp    801066b6 <alltraps>

80107329 <vector164>:
.globl vector164
vector164:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $164
8010732b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107330:	e9 81 f3 ff ff       	jmp    801066b6 <alltraps>

80107335 <vector165>:
.globl vector165
vector165:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $165
80107337:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010733c:	e9 75 f3 ff ff       	jmp    801066b6 <alltraps>

80107341 <vector166>:
.globl vector166
vector166:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $166
80107343:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107348:	e9 69 f3 ff ff       	jmp    801066b6 <alltraps>

8010734d <vector167>:
.globl vector167
vector167:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $167
8010734f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107354:	e9 5d f3 ff ff       	jmp    801066b6 <alltraps>

80107359 <vector168>:
.globl vector168
vector168:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $168
8010735b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107360:	e9 51 f3 ff ff       	jmp    801066b6 <alltraps>

80107365 <vector169>:
.globl vector169
vector169:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $169
80107367:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010736c:	e9 45 f3 ff ff       	jmp    801066b6 <alltraps>

80107371 <vector170>:
.globl vector170
vector170:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $170
80107373:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107378:	e9 39 f3 ff ff       	jmp    801066b6 <alltraps>

8010737d <vector171>:
.globl vector171
vector171:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $171
8010737f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107384:	e9 2d f3 ff ff       	jmp    801066b6 <alltraps>

80107389 <vector172>:
.globl vector172
vector172:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $172
8010738b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107390:	e9 21 f3 ff ff       	jmp    801066b6 <alltraps>

80107395 <vector173>:
.globl vector173
vector173:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $173
80107397:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010739c:	e9 15 f3 ff ff       	jmp    801066b6 <alltraps>

801073a1 <vector174>:
.globl vector174
vector174:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $174
801073a3:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801073a8:	e9 09 f3 ff ff       	jmp    801066b6 <alltraps>

801073ad <vector175>:
.globl vector175
vector175:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $175
801073af:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801073b4:	e9 fd f2 ff ff       	jmp    801066b6 <alltraps>

801073b9 <vector176>:
.globl vector176
vector176:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $176
801073bb:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801073c0:	e9 f1 f2 ff ff       	jmp    801066b6 <alltraps>

801073c5 <vector177>:
.globl vector177
vector177:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $177
801073c7:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073cc:	e9 e5 f2 ff ff       	jmp    801066b6 <alltraps>

801073d1 <vector178>:
.globl vector178
vector178:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $178
801073d3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801073d8:	e9 d9 f2 ff ff       	jmp    801066b6 <alltraps>

801073dd <vector179>:
.globl vector179
vector179:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $179
801073df:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073e4:	e9 cd f2 ff ff       	jmp    801066b6 <alltraps>

801073e9 <vector180>:
.globl vector180
vector180:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $180
801073eb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073f0:	e9 c1 f2 ff ff       	jmp    801066b6 <alltraps>

801073f5 <vector181>:
.globl vector181
vector181:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $181
801073f7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073fc:	e9 b5 f2 ff ff       	jmp    801066b6 <alltraps>

80107401 <vector182>:
.globl vector182
vector182:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $182
80107403:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107408:	e9 a9 f2 ff ff       	jmp    801066b6 <alltraps>

8010740d <vector183>:
.globl vector183
vector183:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $183
8010740f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107414:	e9 9d f2 ff ff       	jmp    801066b6 <alltraps>

80107419 <vector184>:
.globl vector184
vector184:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $184
8010741b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107420:	e9 91 f2 ff ff       	jmp    801066b6 <alltraps>

80107425 <vector185>:
.globl vector185
vector185:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $185
80107427:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010742c:	e9 85 f2 ff ff       	jmp    801066b6 <alltraps>

80107431 <vector186>:
.globl vector186
vector186:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $186
80107433:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107438:	e9 79 f2 ff ff       	jmp    801066b6 <alltraps>

8010743d <vector187>:
.globl vector187
vector187:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $187
8010743f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107444:	e9 6d f2 ff ff       	jmp    801066b6 <alltraps>

80107449 <vector188>:
.globl vector188
vector188:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $188
8010744b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107450:	e9 61 f2 ff ff       	jmp    801066b6 <alltraps>

80107455 <vector189>:
.globl vector189
vector189:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $189
80107457:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010745c:	e9 55 f2 ff ff       	jmp    801066b6 <alltraps>

80107461 <vector190>:
.globl vector190
vector190:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $190
80107463:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107468:	e9 49 f2 ff ff       	jmp    801066b6 <alltraps>

8010746d <vector191>:
.globl vector191
vector191:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $191
8010746f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107474:	e9 3d f2 ff ff       	jmp    801066b6 <alltraps>

80107479 <vector192>:
.globl vector192
vector192:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $192
8010747b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107480:	e9 31 f2 ff ff       	jmp    801066b6 <alltraps>

80107485 <vector193>:
.globl vector193
vector193:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $193
80107487:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010748c:	e9 25 f2 ff ff       	jmp    801066b6 <alltraps>

80107491 <vector194>:
.globl vector194
vector194:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $194
80107493:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107498:	e9 19 f2 ff ff       	jmp    801066b6 <alltraps>

8010749d <vector195>:
.globl vector195
vector195:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $195
8010749f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801074a4:	e9 0d f2 ff ff       	jmp    801066b6 <alltraps>

801074a9 <vector196>:
.globl vector196
vector196:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $196
801074ab:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801074b0:	e9 01 f2 ff ff       	jmp    801066b6 <alltraps>

801074b5 <vector197>:
.globl vector197
vector197:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $197
801074b7:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801074bc:	e9 f5 f1 ff ff       	jmp    801066b6 <alltraps>

801074c1 <vector198>:
.globl vector198
vector198:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $198
801074c3:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074c8:	e9 e9 f1 ff ff       	jmp    801066b6 <alltraps>

801074cd <vector199>:
.globl vector199
vector199:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $199
801074cf:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074d4:	e9 dd f1 ff ff       	jmp    801066b6 <alltraps>

801074d9 <vector200>:
.globl vector200
vector200:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $200
801074db:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074e0:	e9 d1 f1 ff ff       	jmp    801066b6 <alltraps>

801074e5 <vector201>:
.globl vector201
vector201:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $201
801074e7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074ec:	e9 c5 f1 ff ff       	jmp    801066b6 <alltraps>

801074f1 <vector202>:
.globl vector202
vector202:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $202
801074f3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074f8:	e9 b9 f1 ff ff       	jmp    801066b6 <alltraps>

801074fd <vector203>:
.globl vector203
vector203:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $203
801074ff:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107504:	e9 ad f1 ff ff       	jmp    801066b6 <alltraps>

80107509 <vector204>:
.globl vector204
vector204:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $204
8010750b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107510:	e9 a1 f1 ff ff       	jmp    801066b6 <alltraps>

80107515 <vector205>:
.globl vector205
vector205:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $205
80107517:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010751c:	e9 95 f1 ff ff       	jmp    801066b6 <alltraps>

80107521 <vector206>:
.globl vector206
vector206:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $206
80107523:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107528:	e9 89 f1 ff ff       	jmp    801066b6 <alltraps>

8010752d <vector207>:
.globl vector207
vector207:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $207
8010752f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107534:	e9 7d f1 ff ff       	jmp    801066b6 <alltraps>

80107539 <vector208>:
.globl vector208
vector208:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $208
8010753b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107540:	e9 71 f1 ff ff       	jmp    801066b6 <alltraps>

80107545 <vector209>:
.globl vector209
vector209:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $209
80107547:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010754c:	e9 65 f1 ff ff       	jmp    801066b6 <alltraps>

80107551 <vector210>:
.globl vector210
vector210:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $210
80107553:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107558:	e9 59 f1 ff ff       	jmp    801066b6 <alltraps>

8010755d <vector211>:
.globl vector211
vector211:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $211
8010755f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107564:	e9 4d f1 ff ff       	jmp    801066b6 <alltraps>

80107569 <vector212>:
.globl vector212
vector212:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $212
8010756b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107570:	e9 41 f1 ff ff       	jmp    801066b6 <alltraps>

80107575 <vector213>:
.globl vector213
vector213:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $213
80107577:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010757c:	e9 35 f1 ff ff       	jmp    801066b6 <alltraps>

80107581 <vector214>:
.globl vector214
vector214:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $214
80107583:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107588:	e9 29 f1 ff ff       	jmp    801066b6 <alltraps>

8010758d <vector215>:
.globl vector215
vector215:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $215
8010758f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107594:	e9 1d f1 ff ff       	jmp    801066b6 <alltraps>

80107599 <vector216>:
.globl vector216
vector216:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $216
8010759b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801075a0:	e9 11 f1 ff ff       	jmp    801066b6 <alltraps>

801075a5 <vector217>:
.globl vector217
vector217:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $217
801075a7:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801075ac:	e9 05 f1 ff ff       	jmp    801066b6 <alltraps>

801075b1 <vector218>:
.globl vector218
vector218:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $218
801075b3:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801075b8:	e9 f9 f0 ff ff       	jmp    801066b6 <alltraps>

801075bd <vector219>:
.globl vector219
vector219:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $219
801075bf:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801075c4:	e9 ed f0 ff ff       	jmp    801066b6 <alltraps>

801075c9 <vector220>:
.globl vector220
vector220:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $220
801075cb:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075d0:	e9 e1 f0 ff ff       	jmp    801066b6 <alltraps>

801075d5 <vector221>:
.globl vector221
vector221:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $221
801075d7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075dc:	e9 d5 f0 ff ff       	jmp    801066b6 <alltraps>

801075e1 <vector222>:
.globl vector222
vector222:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $222
801075e3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075e8:	e9 c9 f0 ff ff       	jmp    801066b6 <alltraps>

801075ed <vector223>:
.globl vector223
vector223:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $223
801075ef:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075f4:	e9 bd f0 ff ff       	jmp    801066b6 <alltraps>

801075f9 <vector224>:
.globl vector224
vector224:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $224
801075fb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107600:	e9 b1 f0 ff ff       	jmp    801066b6 <alltraps>

80107605 <vector225>:
.globl vector225
vector225:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $225
80107607:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010760c:	e9 a5 f0 ff ff       	jmp    801066b6 <alltraps>

80107611 <vector226>:
.globl vector226
vector226:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $226
80107613:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107618:	e9 99 f0 ff ff       	jmp    801066b6 <alltraps>

8010761d <vector227>:
.globl vector227
vector227:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $227
8010761f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107624:	e9 8d f0 ff ff       	jmp    801066b6 <alltraps>

80107629 <vector228>:
.globl vector228
vector228:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $228
8010762b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107630:	e9 81 f0 ff ff       	jmp    801066b6 <alltraps>

80107635 <vector229>:
.globl vector229
vector229:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $229
80107637:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010763c:	e9 75 f0 ff ff       	jmp    801066b6 <alltraps>

80107641 <vector230>:
.globl vector230
vector230:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $230
80107643:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107648:	e9 69 f0 ff ff       	jmp    801066b6 <alltraps>

8010764d <vector231>:
.globl vector231
vector231:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $231
8010764f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107654:	e9 5d f0 ff ff       	jmp    801066b6 <alltraps>

80107659 <vector232>:
.globl vector232
vector232:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $232
8010765b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107660:	e9 51 f0 ff ff       	jmp    801066b6 <alltraps>

80107665 <vector233>:
.globl vector233
vector233:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $233
80107667:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010766c:	e9 45 f0 ff ff       	jmp    801066b6 <alltraps>

80107671 <vector234>:
.globl vector234
vector234:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $234
80107673:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107678:	e9 39 f0 ff ff       	jmp    801066b6 <alltraps>

8010767d <vector235>:
.globl vector235
vector235:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $235
8010767f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107684:	e9 2d f0 ff ff       	jmp    801066b6 <alltraps>

80107689 <vector236>:
.globl vector236
vector236:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $236
8010768b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107690:	e9 21 f0 ff ff       	jmp    801066b6 <alltraps>

80107695 <vector237>:
.globl vector237
vector237:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $237
80107697:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010769c:	e9 15 f0 ff ff       	jmp    801066b6 <alltraps>

801076a1 <vector238>:
.globl vector238
vector238:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $238
801076a3:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801076a8:	e9 09 f0 ff ff       	jmp    801066b6 <alltraps>

801076ad <vector239>:
.globl vector239
vector239:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $239
801076af:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801076b4:	e9 fd ef ff ff       	jmp    801066b6 <alltraps>

801076b9 <vector240>:
.globl vector240
vector240:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $240
801076bb:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801076c0:	e9 f1 ef ff ff       	jmp    801066b6 <alltraps>

801076c5 <vector241>:
.globl vector241
vector241:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $241
801076c7:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076cc:	e9 e5 ef ff ff       	jmp    801066b6 <alltraps>

801076d1 <vector242>:
.globl vector242
vector242:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $242
801076d3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801076d8:	e9 d9 ef ff ff       	jmp    801066b6 <alltraps>

801076dd <vector243>:
.globl vector243
vector243:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $243
801076df:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076e4:	e9 cd ef ff ff       	jmp    801066b6 <alltraps>

801076e9 <vector244>:
.globl vector244
vector244:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $244
801076eb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076f0:	e9 c1 ef ff ff       	jmp    801066b6 <alltraps>

801076f5 <vector245>:
.globl vector245
vector245:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $245
801076f7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076fc:	e9 b5 ef ff ff       	jmp    801066b6 <alltraps>

80107701 <vector246>:
.globl vector246
vector246:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $246
80107703:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107708:	e9 a9 ef ff ff       	jmp    801066b6 <alltraps>

8010770d <vector247>:
.globl vector247
vector247:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $247
8010770f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107714:	e9 9d ef ff ff       	jmp    801066b6 <alltraps>

80107719 <vector248>:
.globl vector248
vector248:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $248
8010771b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107720:	e9 91 ef ff ff       	jmp    801066b6 <alltraps>

80107725 <vector249>:
.globl vector249
vector249:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $249
80107727:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010772c:	e9 85 ef ff ff       	jmp    801066b6 <alltraps>

80107731 <vector250>:
.globl vector250
vector250:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $250
80107733:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107738:	e9 79 ef ff ff       	jmp    801066b6 <alltraps>

8010773d <vector251>:
.globl vector251
vector251:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $251
8010773f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107744:	e9 6d ef ff ff       	jmp    801066b6 <alltraps>

80107749 <vector252>:
.globl vector252
vector252:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $252
8010774b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107750:	e9 61 ef ff ff       	jmp    801066b6 <alltraps>

80107755 <vector253>:
.globl vector253
vector253:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $253
80107757:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010775c:	e9 55 ef ff ff       	jmp    801066b6 <alltraps>

80107761 <vector254>:
.globl vector254
vector254:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $254
80107763:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107768:	e9 49 ef ff ff       	jmp    801066b6 <alltraps>

8010776d <vector255>:
.globl vector255
vector255:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $255
8010776f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107774:	e9 3d ef ff ff       	jmp    801066b6 <alltraps>

80107779 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107779:	55                   	push   %ebp
8010777a:	89 e5                	mov    %esp,%ebp
8010777c:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010777f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107782:	83 e8 01             	sub    $0x1,%eax
80107785:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107789:	8b 45 08             	mov    0x8(%ebp),%eax
8010778c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107790:	8b 45 08             	mov    0x8(%ebp),%eax
80107793:	c1 e8 10             	shr    $0x10,%eax
80107796:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010779a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010779d:	0f 01 10             	lgdtl  (%eax)
}
801077a0:	90                   	nop
801077a1:	c9                   	leave  
801077a2:	c3                   	ret    

801077a3 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801077a3:	55                   	push   %ebp
801077a4:	89 e5                	mov    %esp,%ebp
801077a6:	83 ec 04             	sub    $0x4,%esp
801077a9:	8b 45 08             	mov    0x8(%ebp),%eax
801077ac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801077b0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077b4:	0f 00 d8             	ltr    %ax
}
801077b7:	90                   	nop
801077b8:	c9                   	leave  
801077b9:	c3                   	ret    

801077ba <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801077ba:	55                   	push   %ebp
801077bb:	89 e5                	mov    %esp,%ebp
801077bd:	83 ec 04             	sub    $0x4,%esp
801077c0:	8b 45 08             	mov    0x8(%ebp),%eax
801077c3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801077c7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077cb:	8e e8                	mov    %eax,%gs
}
801077cd:	90                   	nop
801077ce:	c9                   	leave  
801077cf:	c3                   	ret    

801077d0 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801077d0:	55                   	push   %ebp
801077d1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077d3:	8b 45 08             	mov    0x8(%ebp),%eax
801077d6:	0f 22 d8             	mov    %eax,%cr3
}
801077d9:	90                   	nop
801077da:	5d                   	pop    %ebp
801077db:	c3                   	ret    

801077dc <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801077dc:	55                   	push   %ebp
801077dd:	89 e5                	mov    %esp,%ebp
801077df:	8b 45 08             	mov    0x8(%ebp),%eax
801077e2:	05 00 00 00 80       	add    $0x80000000,%eax
801077e7:	5d                   	pop    %ebp
801077e8:	c3                   	ret    

801077e9 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801077e9:	55                   	push   %ebp
801077ea:	89 e5                	mov    %esp,%ebp
801077ec:	8b 45 08             	mov    0x8(%ebp),%eax
801077ef:	05 00 00 00 80       	add    $0x80000000,%eax
801077f4:	5d                   	pop    %ebp
801077f5:	c3                   	ret    

801077f6 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077f6:	55                   	push   %ebp
801077f7:	89 e5                	mov    %esp,%ebp
801077f9:	53                   	push   %ebx
801077fa:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801077fd:	e8 ca b7 ff ff       	call   80102fcc <cpunum>
80107802:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107808:	05 60 23 11 80       	add    $0x80112360,%eax
8010780d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107813:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107825:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107830:	83 e2 f0             	and    $0xfffffff0,%edx
80107833:	83 ca 0a             	or     $0xa,%edx
80107836:	88 50 7d             	mov    %dl,0x7d(%eax)
80107839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107840:	83 ca 10             	or     $0x10,%edx
80107843:	88 50 7d             	mov    %dl,0x7d(%eax)
80107846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107849:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010784d:	83 e2 9f             	and    $0xffffff9f,%edx
80107850:	88 50 7d             	mov    %dl,0x7d(%eax)
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010785a:	83 ca 80             	or     $0xffffff80,%edx
8010785d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107863:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107867:	83 ca 0f             	or     $0xf,%edx
8010786a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010786d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107870:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107874:	83 e2 ef             	and    $0xffffffef,%edx
80107877:	88 50 7e             	mov    %dl,0x7e(%eax)
8010787a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107881:	83 e2 df             	and    $0xffffffdf,%edx
80107884:	88 50 7e             	mov    %dl,0x7e(%eax)
80107887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010788e:	83 ca 40             	or     $0x40,%edx
80107891:	88 50 7e             	mov    %dl,0x7e(%eax)
80107894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107897:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010789b:	83 ca 80             	or     $0xffffff80,%edx
8010789e:	88 50 7e             	mov    %dl,0x7e(%eax)
801078a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a4:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801078a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ab:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801078b2:	ff ff 
801078b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b7:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801078be:	00 00 
801078c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c3:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801078ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cd:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078d4:	83 e2 f0             	and    $0xfffffff0,%edx
801078d7:	83 ca 02             	or     $0x2,%edx
801078da:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078ea:	83 ca 10             	or     $0x10,%edx
801078ed:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078fd:	83 e2 9f             	and    $0xffffff9f,%edx
80107900:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107909:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107910:	83 ca 80             	or     $0xffffff80,%edx
80107913:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107923:	83 ca 0f             	or     $0xf,%edx
80107926:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010792c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107936:	83 e2 ef             	and    $0xffffffef,%edx
80107939:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010793f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107942:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107949:	83 e2 df             	and    $0xffffffdf,%edx
8010794c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107955:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010795c:	83 ca 40             	or     $0x40,%edx
8010795f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010796f:	83 ca 80             	or     $0xffffff80,%edx
80107972:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107985:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010798c:	ff ff 
8010798e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107991:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107998:	00 00 
8010799a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801079a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ae:	83 e2 f0             	and    $0xfffffff0,%edx
801079b1:	83 ca 0a             	or     $0xa,%edx
801079b4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bd:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079c4:	83 ca 10             	or     $0x10,%edx
801079c7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079d7:	83 ca 60             	or     $0x60,%edx
801079da:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801079ea:	83 ca 80             	or     $0xffffff80,%edx
801079ed:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079fd:	83 ca 0f             	or     $0xf,%edx
80107a00:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a09:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a10:	83 e2 ef             	and    $0xffffffef,%edx
80107a13:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a23:	83 e2 df             	and    $0xffffffdf,%edx
80107a26:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a36:	83 ca 40             	or     $0x40,%edx
80107a39:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a42:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107a49:	83 ca 80             	or     $0xffffff80,%edx
80107a4c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a55:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107a66:	ff ff 
80107a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6b:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107a72:	00 00 
80107a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a77:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a81:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a88:	83 e2 f0             	and    $0xfffffff0,%edx
80107a8b:	83 ca 02             	or     $0x2,%edx
80107a8e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a97:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a9e:	83 ca 10             	or     $0x10,%edx
80107aa1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aaa:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ab1:	83 ca 60             	or     $0x60,%edx
80107ab4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ac4:	83 ca 80             	or     $0xffffff80,%edx
80107ac7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ad7:	83 ca 0f             	or     $0xf,%edx
80107ada:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107aea:	83 e2 ef             	and    $0xffffffef,%edx
80107aed:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107afd:	83 e2 df             	and    $0xffffffdf,%edx
80107b00:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b09:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b10:	83 ca 40             	or     $0x40,%edx
80107b13:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107b23:	83 ca 80             	or     $0xffffff80,%edx
80107b26:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2f:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	05 b4 00 00 00       	add    $0xb4,%eax
80107b3e:	89 c3                	mov    %eax,%ebx
80107b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b43:	05 b4 00 00 00       	add    $0xb4,%eax
80107b48:	c1 e8 10             	shr    $0x10,%eax
80107b4b:	89 c2                	mov    %eax,%edx
80107b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b50:	05 b4 00 00 00       	add    $0xb4,%eax
80107b55:	c1 e8 18             	shr    $0x18,%eax
80107b58:	89 c1                	mov    %eax,%ecx
80107b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5d:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107b64:	00 00 
80107b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b69:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b73:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b83:	83 e2 f0             	and    $0xfffffff0,%edx
80107b86:	83 ca 02             	or     $0x2,%edx
80107b89:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b92:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b99:	83 ca 10             	or     $0x10,%edx
80107b9c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bac:	83 e2 9f             	and    $0xffffff9f,%edx
80107baf:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107bbf:	83 ca 80             	or     $0xffffff80,%edx
80107bc2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bd2:	83 e2 f0             	and    $0xfffffff0,%edx
80107bd5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bde:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107be5:	83 e2 ef             	and    $0xffffffef,%edx
80107be8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bf8:	83 e2 df             	and    $0xffffffdf,%edx
80107bfb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c04:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c0b:	83 ca 40             	or     $0x40,%edx
80107c0e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c17:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107c1e:	83 ca 80             	or     $0xffffff80,%edx
80107c21:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2a:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c33:	83 c0 70             	add    $0x70,%eax
80107c36:	83 ec 08             	sub    $0x8,%esp
80107c39:	6a 38                	push   $0x38
80107c3b:	50                   	push   %eax
80107c3c:	e8 38 fb ff ff       	call   80107779 <lgdt>
80107c41:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107c44:	83 ec 0c             	sub    $0xc,%esp
80107c47:	6a 18                	push   $0x18
80107c49:	e8 6c fb ff ff       	call   801077ba <loadgs>
80107c4e:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c54:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107c5a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107c61:	00 00 00 00 
}
80107c65:	90                   	nop
80107c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c69:	c9                   	leave  
80107c6a:	c3                   	ret    

80107c6b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c6b:	55                   	push   %ebp
80107c6c:	89 e5                	mov    %esp,%ebp
80107c6e:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c71:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c74:	c1 e8 16             	shr    $0x16,%eax
80107c77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80107c81:	01 d0                	add    %edx,%eax
80107c83:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c89:	8b 00                	mov    (%eax),%eax
80107c8b:	83 e0 01             	and    $0x1,%eax
80107c8e:	85 c0                	test   %eax,%eax
80107c90:	74 18                	je     80107caa <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c95:	8b 00                	mov    (%eax),%eax
80107c97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c9c:	50                   	push   %eax
80107c9d:	e8 47 fb ff ff       	call   801077e9 <p2v>
80107ca2:	83 c4 04             	add    $0x4,%esp
80107ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ca8:	eb 48                	jmp    80107cf2 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107caa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107cae:	74 0e                	je     80107cbe <walkpgdir+0x53>
80107cb0:	e8 b1 af ff ff       	call   80102c66 <kalloc>
80107cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cbc:	75 07                	jne    80107cc5 <walkpgdir+0x5a>
      return 0;
80107cbe:	b8 00 00 00 00       	mov    $0x0,%eax
80107cc3:	eb 44                	jmp    80107d09 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107cc5:	83 ec 04             	sub    $0x4,%esp
80107cc8:	68 00 10 00 00       	push   $0x1000
80107ccd:	6a 00                	push   $0x0
80107ccf:	ff 75 f4             	pushl  -0xc(%ebp)
80107cd2:	e8 25 d6 ff ff       	call   801052fc <memset>
80107cd7:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107cda:	83 ec 0c             	sub    $0xc,%esp
80107cdd:	ff 75 f4             	pushl  -0xc(%ebp)
80107ce0:	e8 f7 fa ff ff       	call   801077dc <v2p>
80107ce5:	83 c4 10             	add    $0x10,%esp
80107ce8:	83 c8 07             	or     $0x7,%eax
80107ceb:	89 c2                	mov    %eax,%edx
80107ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cf0:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cf5:	c1 e8 0c             	shr    $0xc,%eax
80107cf8:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cfd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d07:	01 d0                	add    %edx,%eax
}
80107d09:	c9                   	leave  
80107d0a:	c3                   	ret    

80107d0b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d0b:	55                   	push   %ebp
80107d0c:	89 e5                	mov    %esp,%ebp
80107d0e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107d11:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d1f:	8b 45 10             	mov    0x10(%ebp),%eax
80107d22:	01 d0                	add    %edx,%eax
80107d24:	83 e8 01             	sub    $0x1,%eax
80107d27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d2f:	83 ec 04             	sub    $0x4,%esp
80107d32:	6a 01                	push   $0x1
80107d34:	ff 75 f4             	pushl  -0xc(%ebp)
80107d37:	ff 75 08             	pushl  0x8(%ebp)
80107d3a:	e8 2c ff ff ff       	call   80107c6b <walkpgdir>
80107d3f:	83 c4 10             	add    $0x10,%esp
80107d42:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d45:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d49:	75 07                	jne    80107d52 <mappages+0x47>
      return -1;
80107d4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d50:	eb 47                	jmp    80107d99 <mappages+0x8e>
    if(*pte & PTE_P)
80107d52:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d55:	8b 00                	mov    (%eax),%eax
80107d57:	83 e0 01             	and    $0x1,%eax
80107d5a:	85 c0                	test   %eax,%eax
80107d5c:	74 0d                	je     80107d6b <mappages+0x60>
      panic("remap");
80107d5e:	83 ec 0c             	sub    $0xc,%esp
80107d61:	68 0c 8c 10 80       	push   $0x80108c0c
80107d66:	e8 fb 87 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80107d6b:	8b 45 18             	mov    0x18(%ebp),%eax
80107d6e:	0b 45 14             	or     0x14(%ebp),%eax
80107d71:	83 c8 01             	or     $0x1,%eax
80107d74:	89 c2                	mov    %eax,%edx
80107d76:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d79:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d81:	74 10                	je     80107d93 <mappages+0x88>
      break;
    a += PGSIZE;
80107d83:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d8a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107d91:	eb 9c                	jmp    80107d2f <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107d93:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107d94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d99:	c9                   	leave  
80107d9a:	c3                   	ret    

80107d9b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d9b:	55                   	push   %ebp
80107d9c:	89 e5                	mov    %esp,%ebp
80107d9e:	53                   	push   %ebx
80107d9f:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107da2:	e8 bf ae ff ff       	call   80102c66 <kalloc>
80107da7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107daa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107dae:	75 0a                	jne    80107dba <setupkvm+0x1f>
    return 0;
80107db0:	b8 00 00 00 00       	mov    $0x0,%eax
80107db5:	e9 8e 00 00 00       	jmp    80107e48 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107dba:	83 ec 04             	sub    $0x4,%esp
80107dbd:	68 00 10 00 00       	push   $0x1000
80107dc2:	6a 00                	push   $0x0
80107dc4:	ff 75 f0             	pushl  -0x10(%ebp)
80107dc7:	e8 30 d5 ff ff       	call   801052fc <memset>
80107dcc:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107dcf:	83 ec 0c             	sub    $0xc,%esp
80107dd2:	68 00 00 00 0e       	push   $0xe000000
80107dd7:	e8 0d fa ff ff       	call   801077e9 <p2v>
80107ddc:	83 c4 10             	add    $0x10,%esp
80107ddf:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107de4:	76 0d                	jbe    80107df3 <setupkvm+0x58>
    panic("PHYSTOP too high");
80107de6:	83 ec 0c             	sub    $0xc,%esp
80107de9:	68 12 8c 10 80       	push   $0x80108c12
80107dee:	e8 73 87 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107df3:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107dfa:	eb 40                	jmp    80107e3c <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e05:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0b:	8b 58 08             	mov    0x8(%eax),%ebx
80107e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e11:	8b 40 04             	mov    0x4(%eax),%eax
80107e14:	29 c3                	sub    %eax,%ebx
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	8b 00                	mov    (%eax),%eax
80107e1b:	83 ec 0c             	sub    $0xc,%esp
80107e1e:	51                   	push   %ecx
80107e1f:	52                   	push   %edx
80107e20:	53                   	push   %ebx
80107e21:	50                   	push   %eax
80107e22:	ff 75 f0             	pushl  -0x10(%ebp)
80107e25:	e8 e1 fe ff ff       	call   80107d0b <mappages>
80107e2a:	83 c4 20             	add    $0x20,%esp
80107e2d:	85 c0                	test   %eax,%eax
80107e2f:	79 07                	jns    80107e38 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107e31:	b8 00 00 00 00       	mov    $0x0,%eax
80107e36:	eb 10                	jmp    80107e48 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e38:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e3c:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107e43:	72 b7                	jb     80107dfc <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107e48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e4b:	c9                   	leave  
80107e4c:	c3                   	ret    

80107e4d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107e4d:	55                   	push   %ebp
80107e4e:	89 e5                	mov    %esp,%ebp
80107e50:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e53:	e8 43 ff ff ff       	call   80107d9b <setupkvm>
80107e58:	a3 38 54 11 80       	mov    %eax,0x80115438
  switchkvm();
80107e5d:	e8 03 00 00 00       	call   80107e65 <switchkvm>
}
80107e62:	90                   	nop
80107e63:	c9                   	leave  
80107e64:	c3                   	ret    

80107e65 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e65:	55                   	push   %ebp
80107e66:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107e68:	a1 38 54 11 80       	mov    0x80115438,%eax
80107e6d:	50                   	push   %eax
80107e6e:	e8 69 f9 ff ff       	call   801077dc <v2p>
80107e73:	83 c4 04             	add    $0x4,%esp
80107e76:	50                   	push   %eax
80107e77:	e8 54 f9 ff ff       	call   801077d0 <lcr3>
80107e7c:	83 c4 04             	add    $0x4,%esp
}
80107e7f:	90                   	nop
80107e80:	c9                   	leave  
80107e81:	c3                   	ret    

80107e82 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e82:	55                   	push   %ebp
80107e83:	89 e5                	mov    %esp,%ebp
80107e85:	56                   	push   %esi
80107e86:	53                   	push   %ebx
  pushcli();
80107e87:	e8 6a d3 ff ff       	call   801051f6 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107e8c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e92:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e99:	83 c2 08             	add    $0x8,%edx
80107e9c:	89 d6                	mov    %edx,%esi
80107e9e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ea5:	83 c2 08             	add    $0x8,%edx
80107ea8:	c1 ea 10             	shr    $0x10,%edx
80107eab:	89 d3                	mov    %edx,%ebx
80107ead:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107eb4:	83 c2 08             	add    $0x8,%edx
80107eb7:	c1 ea 18             	shr    $0x18,%edx
80107eba:	89 d1                	mov    %edx,%ecx
80107ebc:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107ec3:	67 00 
80107ec5:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107ecc:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107ed2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ed9:	83 e2 f0             	and    $0xfffffff0,%edx
80107edc:	83 ca 09             	or     $0x9,%edx
80107edf:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ee5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107eec:	83 ca 10             	or     $0x10,%edx
80107eef:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ef5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107efc:	83 e2 9f             	and    $0xffffff9f,%edx
80107eff:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f05:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f0c:	83 ca 80             	or     $0xffffff80,%edx
80107f0f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107f15:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f1c:	83 e2 f0             	and    $0xfffffff0,%edx
80107f1f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f25:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f2c:	83 e2 ef             	and    $0xffffffef,%edx
80107f2f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f35:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f3c:	83 e2 df             	and    $0xffffffdf,%edx
80107f3f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f45:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f4c:	83 ca 40             	or     $0x40,%edx
80107f4f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f55:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f5c:	83 e2 7f             	and    $0x7f,%edx
80107f5f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f65:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107f6b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f71:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f78:	83 e2 ef             	and    $0xffffffef,%edx
80107f7b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107f81:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f87:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107f8d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f93:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107f9a:	8b 52 08             	mov    0x8(%edx),%edx
80107f9d:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107fa3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107fa6:	83 ec 0c             	sub    $0xc,%esp
80107fa9:	6a 30                	push   $0x30
80107fab:	e8 f3 f7 ff ff       	call   801077a3 <ltr>
80107fb0:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80107fb6:	8b 40 04             	mov    0x4(%eax),%eax
80107fb9:	85 c0                	test   %eax,%eax
80107fbb:	75 0d                	jne    80107fca <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80107fbd:	83 ec 0c             	sub    $0xc,%esp
80107fc0:	68 23 8c 10 80       	push   $0x80108c23
80107fc5:	e8 9c 85 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107fca:	8b 45 08             	mov    0x8(%ebp),%eax
80107fcd:	8b 40 04             	mov    0x4(%eax),%eax
80107fd0:	83 ec 0c             	sub    $0xc,%esp
80107fd3:	50                   	push   %eax
80107fd4:	e8 03 f8 ff ff       	call   801077dc <v2p>
80107fd9:	83 c4 10             	add    $0x10,%esp
80107fdc:	83 ec 0c             	sub    $0xc,%esp
80107fdf:	50                   	push   %eax
80107fe0:	e8 eb f7 ff ff       	call   801077d0 <lcr3>
80107fe5:	83 c4 10             	add    $0x10,%esp
  popcli();
80107fe8:	e8 4e d2 ff ff       	call   8010523b <popcli>
}
80107fed:	90                   	nop
80107fee:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107ff1:	5b                   	pop    %ebx
80107ff2:	5e                   	pop    %esi
80107ff3:	5d                   	pop    %ebp
80107ff4:	c3                   	ret    

80107ff5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107ff5:	55                   	push   %ebp
80107ff6:	89 e5                	mov    %esp,%ebp
80107ff8:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107ffb:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108002:	76 0d                	jbe    80108011 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108004:	83 ec 0c             	sub    $0xc,%esp
80108007:	68 37 8c 10 80       	push   $0x80108c37
8010800c:	e8 55 85 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108011:	e8 50 ac ff ff       	call   80102c66 <kalloc>
80108016:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108019:	83 ec 04             	sub    $0x4,%esp
8010801c:	68 00 10 00 00       	push   $0x1000
80108021:	6a 00                	push   $0x0
80108023:	ff 75 f4             	pushl  -0xc(%ebp)
80108026:	e8 d1 d2 ff ff       	call   801052fc <memset>
8010802b:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010802e:	83 ec 0c             	sub    $0xc,%esp
80108031:	ff 75 f4             	pushl  -0xc(%ebp)
80108034:	e8 a3 f7 ff ff       	call   801077dc <v2p>
80108039:	83 c4 10             	add    $0x10,%esp
8010803c:	83 ec 0c             	sub    $0xc,%esp
8010803f:	6a 06                	push   $0x6
80108041:	50                   	push   %eax
80108042:	68 00 10 00 00       	push   $0x1000
80108047:	6a 00                	push   $0x0
80108049:	ff 75 08             	pushl  0x8(%ebp)
8010804c:	e8 ba fc ff ff       	call   80107d0b <mappages>
80108051:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108054:	83 ec 04             	sub    $0x4,%esp
80108057:	ff 75 10             	pushl  0x10(%ebp)
8010805a:	ff 75 0c             	pushl  0xc(%ebp)
8010805d:	ff 75 f4             	pushl  -0xc(%ebp)
80108060:	e8 56 d3 ff ff       	call   801053bb <memmove>
80108065:	83 c4 10             	add    $0x10,%esp
}
80108068:	90                   	nop
80108069:	c9                   	leave  
8010806a:	c3                   	ret    

8010806b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010806b:	55                   	push   %ebp
8010806c:	89 e5                	mov    %esp,%ebp
8010806e:	53                   	push   %ebx
8010806f:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108072:	8b 45 0c             	mov    0xc(%ebp),%eax
80108075:	25 ff 0f 00 00       	and    $0xfff,%eax
8010807a:	85 c0                	test   %eax,%eax
8010807c:	74 0d                	je     8010808b <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
8010807e:	83 ec 0c             	sub    $0xc,%esp
80108081:	68 54 8c 10 80       	push   $0x80108c54
80108086:	e8 db 84 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010808b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108092:	e9 95 00 00 00       	jmp    8010812c <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108097:	8b 55 0c             	mov    0xc(%ebp),%edx
8010809a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809d:	01 d0                	add    %edx,%eax
8010809f:	83 ec 04             	sub    $0x4,%esp
801080a2:	6a 00                	push   $0x0
801080a4:	50                   	push   %eax
801080a5:	ff 75 08             	pushl  0x8(%ebp)
801080a8:	e8 be fb ff ff       	call   80107c6b <walkpgdir>
801080ad:	83 c4 10             	add    $0x10,%esp
801080b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080b7:	75 0d                	jne    801080c6 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
801080b9:	83 ec 0c             	sub    $0xc,%esp
801080bc:	68 77 8c 10 80       	push   $0x80108c77
801080c1:	e8 a0 84 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801080c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080c9:	8b 00                	mov    (%eax),%eax
801080cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801080d3:	8b 45 18             	mov    0x18(%ebp),%eax
801080d6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080d9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801080de:	77 0b                	ja     801080eb <loaduvm+0x80>
      n = sz - i;
801080e0:	8b 45 18             	mov    0x18(%ebp),%eax
801080e3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080e9:	eb 07                	jmp    801080f2 <loaduvm+0x87>
    else
      n = PGSIZE;
801080eb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801080f2:	8b 55 14             	mov    0x14(%ebp),%edx
801080f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801080fb:	83 ec 0c             	sub    $0xc,%esp
801080fe:	ff 75 e8             	pushl  -0x18(%ebp)
80108101:	e8 e3 f6 ff ff       	call   801077e9 <p2v>
80108106:	83 c4 10             	add    $0x10,%esp
80108109:	ff 75 f0             	pushl  -0x10(%ebp)
8010810c:	53                   	push   %ebx
8010810d:	50                   	push   %eax
8010810e:	ff 75 10             	pushl  0x10(%ebp)
80108111:	e8 c2 9d ff ff       	call   80101ed8 <readi>
80108116:	83 c4 10             	add    $0x10,%esp
80108119:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010811c:	74 07                	je     80108125 <loaduvm+0xba>
      return -1;
8010811e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108123:	eb 18                	jmp    8010813d <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108125:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010812c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108132:	0f 82 5f ff ff ff    	jb     80108097 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108138:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010813d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108140:	c9                   	leave  
80108141:	c3                   	ret    

80108142 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108142:	55                   	push   %ebp
80108143:	89 e5                	mov    %esp,%ebp
80108145:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108148:	8b 45 10             	mov    0x10(%ebp),%eax
8010814b:	85 c0                	test   %eax,%eax
8010814d:	79 0a                	jns    80108159 <allocuvm+0x17>
    return 0;
8010814f:	b8 00 00 00 00       	mov    $0x0,%eax
80108154:	e9 b0 00 00 00       	jmp    80108209 <allocuvm+0xc7>
  if(newsz < oldsz)
80108159:	8b 45 10             	mov    0x10(%ebp),%eax
8010815c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010815f:	73 08                	jae    80108169 <allocuvm+0x27>
    return oldsz;
80108161:	8b 45 0c             	mov    0xc(%ebp),%eax
80108164:	e9 a0 00 00 00       	jmp    80108209 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108169:	8b 45 0c             	mov    0xc(%ebp),%eax
8010816c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108171:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108176:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108179:	eb 7f                	jmp    801081fa <allocuvm+0xb8>
    mem = kalloc();
8010817b:	e8 e6 aa ff ff       	call   80102c66 <kalloc>
80108180:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108183:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108187:	75 2b                	jne    801081b4 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108189:	83 ec 0c             	sub    $0xc,%esp
8010818c:	68 95 8c 10 80       	push   $0x80108c95
80108191:	e8 30 82 ff ff       	call   801003c6 <cprintf>
80108196:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108199:	83 ec 04             	sub    $0x4,%esp
8010819c:	ff 75 0c             	pushl  0xc(%ebp)
8010819f:	ff 75 10             	pushl  0x10(%ebp)
801081a2:	ff 75 08             	pushl  0x8(%ebp)
801081a5:	e8 61 00 00 00       	call   8010820b <deallocuvm>
801081aa:	83 c4 10             	add    $0x10,%esp
      return 0;
801081ad:	b8 00 00 00 00       	mov    $0x0,%eax
801081b2:	eb 55                	jmp    80108209 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
801081b4:	83 ec 04             	sub    $0x4,%esp
801081b7:	68 00 10 00 00       	push   $0x1000
801081bc:	6a 00                	push   $0x0
801081be:	ff 75 f0             	pushl  -0x10(%ebp)
801081c1:	e8 36 d1 ff ff       	call   801052fc <memset>
801081c6:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081c9:	83 ec 0c             	sub    $0xc,%esp
801081cc:	ff 75 f0             	pushl  -0x10(%ebp)
801081cf:	e8 08 f6 ff ff       	call   801077dc <v2p>
801081d4:	83 c4 10             	add    $0x10,%esp
801081d7:	89 c2                	mov    %eax,%edx
801081d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dc:	83 ec 0c             	sub    $0xc,%esp
801081df:	6a 06                	push   $0x6
801081e1:	52                   	push   %edx
801081e2:	68 00 10 00 00       	push   $0x1000
801081e7:	50                   	push   %eax
801081e8:	ff 75 08             	pushl  0x8(%ebp)
801081eb:	e8 1b fb ff ff       	call   80107d0b <mappages>
801081f0:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801081f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fd:	3b 45 10             	cmp    0x10(%ebp),%eax
80108200:	0f 82 75 ff ff ff    	jb     8010817b <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108206:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108209:	c9                   	leave  
8010820a:	c3                   	ret    

8010820b <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010820b:	55                   	push   %ebp
8010820c:	89 e5                	mov    %esp,%ebp
8010820e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108211:	8b 45 10             	mov    0x10(%ebp),%eax
80108214:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108217:	72 08                	jb     80108221 <deallocuvm+0x16>
    return oldsz;
80108219:	8b 45 0c             	mov    0xc(%ebp),%eax
8010821c:	e9 a5 00 00 00       	jmp    801082c6 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108221:	8b 45 10             	mov    0x10(%ebp),%eax
80108224:	05 ff 0f 00 00       	add    $0xfff,%eax
80108229:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010822e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108231:	e9 81 00 00 00       	jmp    801082b7 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108239:	83 ec 04             	sub    $0x4,%esp
8010823c:	6a 00                	push   $0x0
8010823e:	50                   	push   %eax
8010823f:	ff 75 08             	pushl  0x8(%ebp)
80108242:	e8 24 fa ff ff       	call   80107c6b <walkpgdir>
80108247:	83 c4 10             	add    $0x10,%esp
8010824a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010824d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108251:	75 09                	jne    8010825c <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108253:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010825a:	eb 54                	jmp    801082b0 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010825c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010825f:	8b 00                	mov    (%eax),%eax
80108261:	83 e0 01             	and    $0x1,%eax
80108264:	85 c0                	test   %eax,%eax
80108266:	74 48                	je     801082b0 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826b:	8b 00                	mov    (%eax),%eax
8010826d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108272:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108275:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108279:	75 0d                	jne    80108288 <deallocuvm+0x7d>
        panic("kfree");
8010827b:	83 ec 0c             	sub    $0xc,%esp
8010827e:	68 ad 8c 10 80       	push   $0x80108cad
80108283:	e8 de 82 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108288:	83 ec 0c             	sub    $0xc,%esp
8010828b:	ff 75 ec             	pushl  -0x14(%ebp)
8010828e:	e8 56 f5 ff ff       	call   801077e9 <p2v>
80108293:	83 c4 10             	add    $0x10,%esp
80108296:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108299:	83 ec 0c             	sub    $0xc,%esp
8010829c:	ff 75 e8             	pushl  -0x18(%ebp)
8010829f:	e8 25 a9 ff ff       	call   80102bc9 <kfree>
801082a4:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801082a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801082b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082bd:	0f 82 73 ff ff ff    	jb     80108236 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801082c3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082c6:	c9                   	leave  
801082c7:	c3                   	ret    

801082c8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801082c8:	55                   	push   %ebp
801082c9:	89 e5                	mov    %esp,%ebp
801082cb:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801082ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801082d2:	75 0d                	jne    801082e1 <freevm+0x19>
    panic("freevm: no pgdir");
801082d4:	83 ec 0c             	sub    $0xc,%esp
801082d7:	68 b3 8c 10 80       	push   $0x80108cb3
801082dc:	e8 85 82 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801082e1:	83 ec 04             	sub    $0x4,%esp
801082e4:	6a 00                	push   $0x0
801082e6:	68 00 00 00 80       	push   $0x80000000
801082eb:	ff 75 08             	pushl  0x8(%ebp)
801082ee:	e8 18 ff ff ff       	call   8010820b <deallocuvm>
801082f3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082fd:	eb 4f                	jmp    8010834e <freevm+0x86>
    if(pgdir[i] & PTE_P){
801082ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108302:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108309:	8b 45 08             	mov    0x8(%ebp),%eax
8010830c:	01 d0                	add    %edx,%eax
8010830e:	8b 00                	mov    (%eax),%eax
80108310:	83 e0 01             	and    $0x1,%eax
80108313:	85 c0                	test   %eax,%eax
80108315:	74 33                	je     8010834a <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108321:	8b 45 08             	mov    0x8(%ebp),%eax
80108324:	01 d0                	add    %edx,%eax
80108326:	8b 00                	mov    (%eax),%eax
80108328:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010832d:	83 ec 0c             	sub    $0xc,%esp
80108330:	50                   	push   %eax
80108331:	e8 b3 f4 ff ff       	call   801077e9 <p2v>
80108336:	83 c4 10             	add    $0x10,%esp
80108339:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010833c:	83 ec 0c             	sub    $0xc,%esp
8010833f:	ff 75 f0             	pushl  -0x10(%ebp)
80108342:	e8 82 a8 ff ff       	call   80102bc9 <kfree>
80108347:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010834a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010834e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108355:	76 a8                	jbe    801082ff <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108357:	83 ec 0c             	sub    $0xc,%esp
8010835a:	ff 75 08             	pushl  0x8(%ebp)
8010835d:	e8 67 a8 ff ff       	call   80102bc9 <kfree>
80108362:	83 c4 10             	add    $0x10,%esp
}
80108365:	90                   	nop
80108366:	c9                   	leave  
80108367:	c3                   	ret    

80108368 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108368:	55                   	push   %ebp
80108369:	89 e5                	mov    %esp,%ebp
8010836b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010836e:	83 ec 04             	sub    $0x4,%esp
80108371:	6a 00                	push   $0x0
80108373:	ff 75 0c             	pushl  0xc(%ebp)
80108376:	ff 75 08             	pushl  0x8(%ebp)
80108379:	e8 ed f8 ff ff       	call   80107c6b <walkpgdir>
8010837e:	83 c4 10             	add    $0x10,%esp
80108381:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108384:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108388:	75 0d                	jne    80108397 <clearpteu+0x2f>
    panic("clearpteu");
8010838a:	83 ec 0c             	sub    $0xc,%esp
8010838d:	68 c4 8c 10 80       	push   $0x80108cc4
80108392:	e8 cf 81 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80108397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839a:	8b 00                	mov    (%eax),%eax
8010839c:	83 e0 fb             	and    $0xfffffffb,%eax
8010839f:	89 c2                	mov    %eax,%edx
801083a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a4:	89 10                	mov    %edx,(%eax)
}
801083a6:	90                   	nop
801083a7:	c9                   	leave  
801083a8:	c3                   	ret    

801083a9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801083a9:	55                   	push   %ebp
801083aa:	89 e5                	mov    %esp,%ebp
801083ac:	53                   	push   %ebx
801083ad:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801083b0:	e8 e6 f9 ff ff       	call   80107d9b <setupkvm>
801083b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083bc:	75 0a                	jne    801083c8 <copyuvm+0x1f>
    return 0;
801083be:	b8 00 00 00 00       	mov    $0x0,%eax
801083c3:	e9 f8 00 00 00       	jmp    801084c0 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
801083c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083cf:	e9 c4 00 00 00       	jmp    80108498 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801083d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d7:	83 ec 04             	sub    $0x4,%esp
801083da:	6a 00                	push   $0x0
801083dc:	50                   	push   %eax
801083dd:	ff 75 08             	pushl  0x8(%ebp)
801083e0:	e8 86 f8 ff ff       	call   80107c6b <walkpgdir>
801083e5:	83 c4 10             	add    $0x10,%esp
801083e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083eb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083ef:	75 0d                	jne    801083fe <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801083f1:	83 ec 0c             	sub    $0xc,%esp
801083f4:	68 ce 8c 10 80       	push   $0x80108cce
801083f9:	e8 68 81 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801083fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108401:	8b 00                	mov    (%eax),%eax
80108403:	83 e0 01             	and    $0x1,%eax
80108406:	85 c0                	test   %eax,%eax
80108408:	75 0d                	jne    80108417 <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010840a:	83 ec 0c             	sub    $0xc,%esp
8010840d:	68 e8 8c 10 80       	push   $0x80108ce8
80108412:	e8 4f 81 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108417:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841a:	8b 00                	mov    (%eax),%eax
8010841c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108421:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108424:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108427:	8b 00                	mov    (%eax),%eax
80108429:	25 ff 0f 00 00       	and    $0xfff,%eax
8010842e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108431:	e8 30 a8 ff ff       	call   80102c66 <kalloc>
80108436:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108439:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010843d:	74 6a                	je     801084a9 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010843f:	83 ec 0c             	sub    $0xc,%esp
80108442:	ff 75 e8             	pushl  -0x18(%ebp)
80108445:	e8 9f f3 ff ff       	call   801077e9 <p2v>
8010844a:	83 c4 10             	add    $0x10,%esp
8010844d:	83 ec 04             	sub    $0x4,%esp
80108450:	68 00 10 00 00       	push   $0x1000
80108455:	50                   	push   %eax
80108456:	ff 75 e0             	pushl  -0x20(%ebp)
80108459:	e8 5d cf ff ff       	call   801053bb <memmove>
8010845e:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108461:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108464:	83 ec 0c             	sub    $0xc,%esp
80108467:	ff 75 e0             	pushl  -0x20(%ebp)
8010846a:	e8 6d f3 ff ff       	call   801077dc <v2p>
8010846f:	83 c4 10             	add    $0x10,%esp
80108472:	89 c2                	mov    %eax,%edx
80108474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108477:	83 ec 0c             	sub    $0xc,%esp
8010847a:	53                   	push   %ebx
8010847b:	52                   	push   %edx
8010847c:	68 00 10 00 00       	push   $0x1000
80108481:	50                   	push   %eax
80108482:	ff 75 f0             	pushl  -0x10(%ebp)
80108485:	e8 81 f8 ff ff       	call   80107d0b <mappages>
8010848a:	83 c4 20             	add    $0x20,%esp
8010848d:	85 c0                	test   %eax,%eax
8010848f:	78 1b                	js     801084ac <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108491:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010849e:	0f 82 30 ff ff ff    	jb     801083d4 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801084a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a7:	eb 17                	jmp    801084c0 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801084a9:	90                   	nop
801084aa:	eb 01                	jmp    801084ad <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801084ac:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801084ad:	83 ec 0c             	sub    $0xc,%esp
801084b0:	ff 75 f0             	pushl  -0x10(%ebp)
801084b3:	e8 10 fe ff ff       	call   801082c8 <freevm>
801084b8:	83 c4 10             	add    $0x10,%esp
  return 0;
801084bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084c3:	c9                   	leave  
801084c4:	c3                   	ret    

801084c5 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801084c5:	55                   	push   %ebp
801084c6:	89 e5                	mov    %esp,%ebp
801084c8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084cb:	83 ec 04             	sub    $0x4,%esp
801084ce:	6a 00                	push   $0x0
801084d0:	ff 75 0c             	pushl  0xc(%ebp)
801084d3:	ff 75 08             	pushl  0x8(%ebp)
801084d6:	e8 90 f7 ff ff       	call   80107c6b <walkpgdir>
801084db:	83 c4 10             	add    $0x10,%esp
801084de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801084e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e4:	8b 00                	mov    (%eax),%eax
801084e6:	83 e0 01             	and    $0x1,%eax
801084e9:	85 c0                	test   %eax,%eax
801084eb:	75 07                	jne    801084f4 <uva2ka+0x2f>
    return 0;
801084ed:	b8 00 00 00 00       	mov    $0x0,%eax
801084f2:	eb 29                	jmp    8010851d <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801084f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f7:	8b 00                	mov    (%eax),%eax
801084f9:	83 e0 04             	and    $0x4,%eax
801084fc:	85 c0                	test   %eax,%eax
801084fe:	75 07                	jne    80108507 <uva2ka+0x42>
    return 0;
80108500:	b8 00 00 00 00       	mov    $0x0,%eax
80108505:	eb 16                	jmp    8010851d <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850a:	8b 00                	mov    (%eax),%eax
8010850c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108511:	83 ec 0c             	sub    $0xc,%esp
80108514:	50                   	push   %eax
80108515:	e8 cf f2 ff ff       	call   801077e9 <p2v>
8010851a:	83 c4 10             	add    $0x10,%esp
}
8010851d:	c9                   	leave  
8010851e:	c3                   	ret    

8010851f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010851f:	55                   	push   %ebp
80108520:	89 e5                	mov    %esp,%ebp
80108522:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108525:	8b 45 10             	mov    0x10(%ebp),%eax
80108528:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010852b:	eb 7f                	jmp    801085ac <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010852d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108530:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108535:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108538:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853b:	83 ec 08             	sub    $0x8,%esp
8010853e:	50                   	push   %eax
8010853f:	ff 75 08             	pushl  0x8(%ebp)
80108542:	e8 7e ff ff ff       	call   801084c5 <uva2ka>
80108547:	83 c4 10             	add    $0x10,%esp
8010854a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010854d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108551:	75 07                	jne    8010855a <copyout+0x3b>
      return -1;
80108553:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108558:	eb 61                	jmp    801085bb <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010855a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010855d:	2b 45 0c             	sub    0xc(%ebp),%eax
80108560:	05 00 10 00 00       	add    $0x1000,%eax
80108565:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108568:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010856b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010856e:	76 06                	jbe    80108576 <copyout+0x57>
      n = len;
80108570:	8b 45 14             	mov    0x14(%ebp),%eax
80108573:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108576:	8b 45 0c             	mov    0xc(%ebp),%eax
80108579:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010857c:	89 c2                	mov    %eax,%edx
8010857e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108581:	01 d0                	add    %edx,%eax
80108583:	83 ec 04             	sub    $0x4,%esp
80108586:	ff 75 f0             	pushl  -0x10(%ebp)
80108589:	ff 75 f4             	pushl  -0xc(%ebp)
8010858c:	50                   	push   %eax
8010858d:	e8 29 ce ff ff       	call   801053bb <memmove>
80108592:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108598:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010859b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010859e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801085a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085a4:	05 00 10 00 00       	add    $0x1000,%eax
801085a9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801085ac:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801085b0:	0f 85 77 ff ff ff    	jne    8010852d <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801085b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085bb:	c9                   	leave  
801085bc:	c3                   	ret    
