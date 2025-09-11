/* bizarre.b - B compiler */
/*************************************************************************************************/
outb; /* final PE executable */
/*************************************************************************************************/
die(s) {
  auto n;

  n = 0; while (char(s, n) != '*e') { ++n; }
  write(2, s, n);
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

  if (*bcapact(bp) >= n) { return; }
  n =* 2;
  newsize = bzwsize * 3 + n + 1;
  *bp = xrelloc(*bp - bzwsize * 3, newsize) + bzwsize * 3;
  *bcapact(bp) = n;
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
petextva 07000; /* .text section virtual address + offset */
/*************************************************************************************************/
main() {
  auto fd, i, impoff, iltoff, nameoff, iatoff, exitname, temp, wp, wpend, codeoff, ohchksum;
  
  outb = bnew(2048);
  
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
  /* data directories */
  btake(&outb, 128);
  /* section table */
  bemit(&outb, 8, ".text*0*0*0");
  bemitx(&outb, 32, "00000000001000000000000000020000000000000000000000000000600000E0");

  /* align to 512 */
  btake(&outb, 80);
  
  /* write imports */
  impoff = btake(&outb, 40);
  iatoff = btake(&outb, 16);
  iltoff = btake(&outb, 16);

  nameoff = bemit(&outb, 11, "msvcrt.dll*0");
  exitname = bemit(&outb, 7, "*0*0exit*0");
  
  bzs64(outb + iatoff, petextva + exitname);
  bzs64(outb + iltoff, petextva + exitname);
  
  bzs32(outb + impoff + 0,  petextva + iltoff);
  bzs32(outb + impoff + 12, petextva + nameoff);
  bzs32(outb + impoff + 16, petextva + iatoff);
  
  /* write libb */
  balignop(&outb, 16);
  codeoff = bemitx(&outb, 29, "554889E54881EC20000000B8FF0000004989C24C89D1E800000000C9C3");
  balignop(&outb, 16);
  temp = bemitx(&outb, 8, "FF25000000000000");
  
  bzs32(outb + codeoff + 23, temp - (codeoff + 23) - 4);
  
  temp =+ 2;
  bzs32(outb + temp, iatoff - temp - 4);
  
  /* compile */
  
  /* backpatch */
  balign(&outb, 512);
  
  bzs32(outb + 400, 512); /* allocate */
  bzs32(outb + 408, 512); /* size */
  
  bzs32(outb + 156, 512); /* code size (x*512) */
  bzs32(outb + 168, petextva + codeoff); /* RVA of entry point */
  bzs32(outb + 208, 040000); /* total size (how much to allocate) */
  bzs16(outb + 220, 3); /* subsystem (2 - GUI, 3 - Console) */
  bzs32(outb + 272, petextva + impoff); /* RVA of import directory table */
  bzs32(outb + 276, 40); /* size of import directory table */
  bzs32(outb + 360, petextva + iatoff); /* RVA of import address table */
  bzs32(outb + 364, 16); /* size of import address table */
  
  /* save the executable */
  write(1, outb, *bsize(&outb));
  
  write(2, "*nok*n*n", 5);
  return(0);
}
