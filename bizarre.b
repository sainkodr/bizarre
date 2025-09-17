/* bizarre.b - B compiler */
/*
type hints in names:
  *b - dynamic buffer
  *f - offset

*/
/*************************************************************************************************/
outb; /* the output of the compiler */
outkind; /* 0 - PE Executable, 1 - ELF Executable, 2 - COFF Object, 3 - ELF Object */
outbss; /* size of zero initialized memory */
/*************************************************************************************************/
/*-----------------------------------------------------------------------------------------------*/
/*                                                                                               */
/* Basic Utilities                                                                               */
/*                                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/*************************************************************************************************/
slen(s) {
  auto n;

  n = 0; while (char(s, n) != '*e') { ++n; }
  return(n);
}
/*************************************************************************************************/
die(s) {
  write(2, s, slen(s));
  write(2, "*n", 1);
  exit();
}
/*************************************************************************************************/
copy(d, s, n) {
  auto i;
  
  i = 0; while (i < n) {
    lchar(d, i, char(s, i));
    ++i;
  }
  
  return(d);
}
/*************************************************************************************************/
mset(n, a, v)
{
  auto i;
  
  i = 0; while (i < n) {
    lchar(a, i, v);
    ++i;
  }
  
  return(a);
}
/*************************************************************************************************/
xrelloc(oldptr, newsize) {
  auto p;
  
  p = bzrelloc(oldptr, newsize);
  if (p == 0) { die("xrelloc"); }
  return(p);
}
/*************************************************************************************************/
dtoi(c) { if ('0' <= c & c <= '9') { return(c - '0'); } else { return(c - 'A' + 10); } }
/*************************************************************************************************/
/*-----------------------------------------------------------------------------------------------*/
/*                                                                                               */
/* Dynamic Buffer                                                                                */
/*                                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/*************************************************************************************************/
bsize(bp)   { return(&bp[0][-1]); }
bcapact(bp) { return(&bp[0][-2]); }
boffset(bp) { return(&bp[0][-3]); }
/*************************************************************************************************/
bnew(capact0) {
  auto b;

  b = xrelloc(0, bzwsize * 3 + capact0 + 1) + bzwsize * 3;
  *bcapact(&b) = capact0;
  return(b);
}
/*************************************************************************************************/
bneed(bp, n) {
  auto newsize;

  if (*bcapact(bp) >= n) { return(0); }
  n =* 2;
  newsize = bzwsize * 3 + n + 1;
  *bp = xrelloc(*bp - bzwsize * 3, newsize) + bzwsize * 3;
  *bcapact(bp) = n;
  return(1);
}
/*************************************************************************************************/
btake(bp, n) {
  auto off;

  off = *boffset(bp);
  *boffset(bp) =+ n;
  
  if (*boffset(bp) > *bsize(bp)) {
    bneed(bp, *boffset(bp));
    *bsize(bp) = *boffset(bp);
  }
  
  return(off);
}
/*************************************************************************************************/
bemit(bp, size, data) {
  auto off;
  
  off = btake(bp, size);
  copy(*bp + off, data, size);
  return(off);
}
/*************************************************************************************************/
bemitx(bp, n, bytes) {
  auto i, byte, off;
  
  off = btake(bp, n);

  i = 0; while (i < n) {
    byte = 16 * dtoi(char(bytes, i * 2)) + dtoi(char(bytes, i * 2 + 1));
    lchar(*bp + off, i, byte);
    ++i;
  }
  
  return(off);
}
/*************************************************************************************************/
bemitc(bp, n, code)
{
  auto bi, ci, v, off;
  
  off = btake(bp, n);
  
  bi = 0; ci = 0; while (bi < n) {
    v = 0;
    
    v =|  (char(code, ci + 0) - '0') & 077;
    v =| ((char(code, ci + 1) - '0') & 077) << 6;
    v =| ((char(code, ci + 2) - '0') & 077) << 12;
    v =| ((char(code, ci + 3) - '0') & 077) << 18;
    ci =+ 4;
    
    lchar(*bp + off, bi + 0, v >> 16);
    lchar(*bp + off, bi + 1, v >> 8 );
    lchar(*bp + off, bi + 2, v      );
    bi =+ 3;
  }
  
  return(off);
}
/*************************************************************************************************/
balign(bp, x)
{
  auto off;

  off = *boffset(bp);
  
  if (off % x != 0) {
    btake(bp, x - (off % x));
  }
  
  return(off);
}
/*************************************************************************************************/
balignop(bp, x)
{
  auto off;

  off = balign(bp, x);
  mset(*boffset(bp) - off, *bp + off, 144); /* 144 == 0x90 == nop */
  return(off);
}
/*************************************************************************************************/
/*-----------------------------------------------------------------------------------------------*/
/*                                                                                               */
/* PE Module                                                                                     */
/*                                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/*************************************************************************************************/
petextva 07000; /* .text section virtual address + offset */
/*************************************************************************************************/
pebegin() /* generate the headers and libb */
{
  /* INSERT: DOS header, DOS stub, PE header, PE optional header, data directories, sections,
     function names, import table, IAT, ILT, libb */
  bemitc(&outb,96,"0ZEC0400400000100loo104000000000000@00000000000000000000000000000000000000000000000POh000hP^=W0]1PK8Qd<CYQ6E`1bLWmVL]5VLQ=68_iVK");
  bemitc(&outb,96,"R12Mb1BIPhFMPhFJCm4A_e68^D6ITX@300000000@10000@A1H8I000000000000000000?0;8`;0HP000100000000000000HAM@000000000400000@000000000P0");
  bemitc(&outb,96,"00010000400000000000@000000000P000000<00000000100000@00000000000@00000000000000400000000@000000000000000@20000040005000000000000");
  bemitc(&outb,96,"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001\0070000000000000000000000000");
  bemitc(&outb,96,"00000000^000hE6M000M@000000000040P0020000000000000000000P100P3000000000000000000000000000000000000000000000000000000000000000000");
  bemitc(&outb,96,"0000000000000000000000000000000000000000]100SIgL^@WL\a6I0000\=60U=gK0000U1gK00PKO100dEfLTmFK00@IU100dU6N0000UM60X=6M08GH`100SAGM");
  bemitc(&outb,96,"b56J0000QEVL000I\100UEfL00`JbM70UAGJ0000\5fHSm6K0000U970\aFH0<fK]100ceFI0@GI0000WmeG]AGI^UFHW9GH00`L0000`20000040000000000000004");
  bemitc(&outb,96,"04180000000000000000@`000000000000150000L00000040000@P2000000000001<0000j00000040000@@4000000000001C0000D10000040000@`5000000000");
  bemitc(&outb,96,"00QI0000`10000040000@X700000000000000000<00000040000@@100000000000170000X00000040000@0300000000000Q>0000410000040000@`4000000000");
  bemitc(&outb,96,"001E0000L10000040000@H6000000000001L0000j10000040000000000000000@29T@29T@29T@29T@29T8E5T8ENRP`NP0000=U8B5]849V449bT`2RNd00@10?6B");
  bemitc(&outb,96,"0<Lb44004DP0@5`09RDE1RDi003k8100@dDREU8B;R468QAA0PoP5@h300000X@jh20000005T>00000380^i200040P9V409V4b;Rd`91AA<9LR<5MRX[MR0D`9SQ40");
  bemitc(&outb,96,"9R4`hROA00809V405]h`9V4n9bT`9bDd=P^f00@15]8B3W<n9RDE1RDi002k8100@dDREU8BhR4600@0000091008=LR@DdR2WHBAW8CJW8CoK5j9ooo8Ee`8ENRP`NP");
  bemitc(&outb,96,"0000000^9100<9LRX7MR0@P_3W<09RDE1RDi003kX3000@P\5U805]8oh?8o0Pko00000Ci30PoP5@h300000P@j;200YcOA00@10P;000000?6BE=LbUW8B\78B000<");
  bemitc(&outb,96,"9R4081ACHDER5]8B3R44?00n0DBS8100000^00000000=]8BYP449R4bh2AA00@;9V409bT`1QNd00015]8B;R448QACgSDV9RDn8QOAhGdRh?8B4n0000@6;R409QAA");
  bemitc(&outb,96,"8=LRhGdR2WHBAW8CJW8Co;8j8moo@DdR=]8BIR46iO?BEU8B;R4l81OA:PoP000^?00032LW?00n0D0QY30000P2`P;000000D@jh20000`=SQ40;R4`81OC9QL0<9LR");
  bemitc(&outb,96,"X7MR0<P]3W<09RDE1RDi003k8100@dDR5]8B9R448QOA@DdR5U8B;R4l81OA0PoP[@h300000h@j8100`GdRX7<B9R42[3OA;Rdg81OAo3NP00002WHBAW8C3h5j[300");
  bemitc(&outb,96,";RTf9SOA8Ee`8ENRP`NP0000=U8B9R44<QAEPDDRPDdR0WHB5]8B9V465]h`9V449bT`9bDdWP^f00`00?6BE=LbUW8B\78B00089R4081ACHDER5U8C;R4881BA0PoP");
  bemitc(&outb,96,"000^?00032<U?00n0D0QY30000P<;R4081BA1PoP000^?00032<U?00n0D0QY30000P22P;000000D@jh20000@05T>00000000^9100;2LR9QAA;>LR91AA<9LR<5MR");
  bemitc(&outb,96,"X[MR08PXSQ403W<`9RDE1RDi002k8100@dDREU8B9b46;2BA91BA81LRHDdR3WHB@DdR2WHBAW8CJW8C2h6j810093lH8Ee`8ENR``NP0000=U8B9R448QAEHDdR0?8B");
  bemitc(&outb,96,"9R428QAA@DdRh?8B5n00000FhR4000@0000091008=LRHDdR2WHBAW8CJW8C2<2j8100hGDR5]8B3R4n?00n0l@Q8100000^0000000000Mj8100hGdR=]8B9R46;R42");
  bemitc(&outb,96,"8QOA80lP0PKj8100@DdRX?8B;R429R4281OCHDdR=]8BiP4l?n0b0006;R4081AA8PnP=]8B9R46;R42Y3AA000P;R4081AA8PnP=]8B9V469Vdb9bT`9bDdKR^f00@0");
  bemitc(&outb,96,"5U8B;R4n8QOA0PoP?Dh300000P;B000000002U>000005]8B;R4l8QOC85L0HDdRE]8BYP4l9V4d0P;`00003WHB:WHBAW8CJW8C145j8100hGdR=]8B9R46;R428QOA");
  bemitc(&outb,96,"80lPE=LbUW8B\78B00089R4081AC@DdR3WHB0P;B000000009V409bT`9bDdCR^foo_oE=LbUW8B\78B000D=R4000@18100T@DR1P;800001WHB5e8B9V4l=R4`9QOA");
  bemitc(&outb,96,"8=LR\GDS2WHBAW8CJW8C0<=j8100hGdR5T8B0000;R4000@1;2003bNC85@j8UlHhR@R00809V400Pk`00002WHBAW8CJW8C0h5jh20000809V401Pk`00002WHBAW8C");
  bemitc(&outb,96,"JW8C0<4jh20000809V402Pk`00002WHBAW8CJW8C0P2jX30000009V409bT`NPNd00000P;B000000003W<0[EboooOn]EboooOn_EboooOnaEboooOncEboooOneEbo");
  bemitc(&outb,45,"ooOngEboooOniEboooOnkEboooOnmEboooOnoEboooOn1FboooOn3FboooOn");

  /*
  TODO:
  rela at 1251 = 'dummy' -4
  rela at 1307 = 'argv'  -4
  rela at 1314 = 'argv'  -4
  rela at 1412 = 'main'  -4
  define     ? = 'dummy' (size 256)
  define     ? = 'argv'  (size 8)
  define     0 = 'close'
  define    44 = 'open'
  define   164 = 'creat'
  define   216 = 'exit'
  define   245 = 'getchar'
  define   310 = 'printn'
  define   521 = 'putchar'
  define   615 = 'read'
  define   673 = 'seek'
  define   812 = 'write'
  define   870 = 'bzrelloc'
  define  1189 = 'bzmalloc'
  define  1237 = 'entry'
  
  INFO:
  code_offset_in_text = 416 (aka skip names, import table, IAT, and ILT)
  size of .text = 1855
  */
}
/*************************************************************************************************/
peend() /* relocate/resolve/backpatch and finish the output file */
{
  /* TODO: calc final sizes */

  /* backpatch */
  balign(&outb, 512);
}
/*************************************************************************************************/
/*-----------------------------------------------------------------------------------------------*/
/*                                                                                               */
/* main and command options                                                                      */
/*                                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/*************************************************************************************************/
main() {
  auto fd;

  outb = bnew(1024 * 6);
  
  /* begin the ouput */
  pebegin();

  /* compile */
  /* ... */
  
  /* end the ouput */
  peend();
  
  /* save the executable */
  fd = open("./a.exe", 1);
  write(fd, outb, *bsize(&outb));
  
  write(2, "*nok*n*n", 5);
  return(0);
}
