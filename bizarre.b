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
pefnames[] "__getmainargs", "_setmode", "exit", "_read", "_write", "calloc", "realloc", "memset",
           "memcpy", "_open", "_close", 0;
/*************************************************************************************************/
pebegin() /* generate the headers and libb */
{
  auto i, n, f, fcount, iatsize, addrf, startf, leaf, writef, exitf, msgf;

  /* "auto" syncronized with pefnames */
  fcount = 0; while (pefnames[fcount] != 0) { ++fcount; }
  iatsize = (fcount + 1) * 8;

  /* MS-DOS header + stub */
  bemitx(&outb, 32, "4D5A80000100000004001000FFFF000040010000000000004000000000000000");
  bemitx(&outb, 32, "0000000000000000000000000000000000000000000000000000000080000000");
  bemitx(&outb, 32, "0E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F");
  bemitx(&outb, 32, "742062652072756E20696E20444F53206D6F64652E0D0A240000000000000000");
  /* PE64 header + PE64 optional header */
  bemitx(&outb, 32, "5045000064860100000000000000000000000000F0002F020B02060000000000");
  bemitx(&outb, 32, "0000000000000000000000000010000000004000000000000010000000020000");
  bemitx(&outb, 32, "0400000000000000040000000000000000000000000200000000000003000000");
  bemitx(&outb, 32, "0000100000000000001000000000000000001000000000000010000000000000");
  bemitx(&outb, 8,  "0000000010000000");
  bzs16(outb + 220, 3); /* subsystem (2 - GUI, 3 - Console) */
  /* data directories */
  btake(&outb, 128);
  bzs32(outb + 272, petextva + 512); /* RVA of import directory table */
  bzs32(outb + 276, 40); /* size of import directory table */
  bzs32(outb + 360, petextva + 576); /* RVA of import address table */
  bzs32(outb + 364, iatsize); /* size of import address table */
  /* section table */
  bemit(&outb, 8, ".text*0*0*0");
  bemitx(&outb, 32, "00000000001000000000000000020000000000000000000000000000600000E0");
  /* align to 512 */
  btake(&outb, 80);
  /* write imports */
  btake(&outb, 40);
  bemit(&outb, 11, "msvcrt.dll*0");
  bzs32(outb + 512, petextva + 576 + iatsize); /* ILT */
  bzs32(outb + 524, petextva + 552); /* name */
  bzs32(outb + 528, petextva + 576); /* IAT */
  balignop(&outb, 16);
  /* 576: */
  btake(&outb, 3 * iatsize); /* IAT, ILT, FJT */
  
  i = 0; while (i < fcount) {
    n = slen(pefnames[i]);
    f = bemit(&outb, 2, "*0*0");
    bemit(&outb, n, pefnames[i]);
    bemit(&outb, 1, "*0");
    
    bzs64(outb + 576 + i * 8,                     petextva + f);
    bzs64(outb + 576 + (1 * iatsize) + i * 8,     petextva + f);
    bzs16(outb + 576 + (2 * iatsize) + i * 8,     9727); /* indirect jump instruction (FF25) */
    bzs32(outb + 576 + (2 * iatsize) + i * 8 + 2, iatsize * -2 - 6);
    
    ++i;
  }
  
  balignop(&outb, 16);

  /* write libb */
  
  startf = bemitx(&outb, 19, "554889E54883EC20B90100000041B810000000");
  leaf = bemitx(&outb, 7, "488D1500000000");
  writef = bemitx(&outb, 5, "E800000000");
  bemitx(&outb, 5, "B900000000");
  exitf = bemitx(&outb, 5, "E800000000");
  bemitx(&outb, 2, "C9C3");
  msgf = bemit(&outb, 16, "Hello, Bizarre!*n");
  
  bzs32(outb + leaf + 3, msgf - (leaf + 3) - 4);
  
  addrf = 576 + (2 * iatsize) + 4 * 8; /* 4 is index of write */
  bzs32(outb + writef + 1, addrf - (writef + 1) - 4);
  
  addrf = 576 + (2 * iatsize) + 2 * 8; /* 2 is index of exit */
  bzs32(outb + exitf + 1, addrf - (exitf + 1) - 4);
  
  bzs32(outb + 168, petextva + startf); /* RVA of entry point */
}
/*************************************************************************************************/
peend() /* relocate/resolve/backpatch and finish the output file */
{
  /* backpatch */
  balign(&outb, 512);
  
  bzs32(outb + 400, 512 * 2); /* allocate */
  bzs32(outb + 408, 512 * 2); /* size */
  
  bzs32(outb + 156, 512 * 2); /* code size (x*512) */
  bzs32(outb + 208, 040000); /* total size (how much to allocate) */
}
/*************************************************************************************************/
/*-----------------------------------------------------------------------------------------------*/
/*                                                                                               */
/* main and command options                                                                      */
/*                                                                                               */
/*-----------------------------------------------------------------------------------------------*/
/*************************************************************************************************/
main() {
  outb = bnew(2048);
  
  /* begin the ouput */
  pebegin();

  /* compile */
  /* ... */
  
  /* end the ouput */
  peend();
  
  /* save the executable */
  write(1, outb, *bsize(&outb));
  write(2, "*nok*n*n", 5);
  return(0);
}
