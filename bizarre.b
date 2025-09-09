/* bizarre.b - B compiler */
/*************************************************************************************************/
execb; /* final PE executable */
textb; /* .text section */
datab; /* .data section */
basefile 020000000;
basecode 020010000;
basedata 020020000;
/*************************************************************************************************/
die(s) {
  while (char(s, 0) != '*e') {
    putchar(char(s, 0));
    ++s;
  }
  
  putchar('*n');
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
xrelloc(oldptr, newsize) {
  auto p;
  
  p = bzrelloc(oldptr, newsize);
  if (p == 0) die("xrelloc");
  return(p);
}
/*************************************************************************************************/
dtoi(c) { if ('0' <= c & c <= '9') return(c - '0'); else return(c - 'A' + 10); }
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

  if (*bcapact(bp) >= n) return;
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
  
  if (off % x != 0)
  {
    btake(bp, x - (off % x));
  }
  
  return(off);
}
/*************************************************************************************************/
section(si, aloc, addr, size, off)
{
  auto sh;
  
  sh = execb + 392 + si * 40;
  
  bzs32(sh + 8,  aloc);
  bzs32(sh + 12, addr);
  bzs32(sh + 16, size);
  bzs32(sh + 20, off);
  
  return(sh);
}
/*************************************************************************************************/
ohcodesz;   /* x*512 */
ohdatasz;   /* x*512 */
ohentry;    /* RVA to _start */
ohtotlsz;   /* how much to allocate */
ohchksum;   /* checksum for words in the entire file */
ohsubsys 3; /* 2 - GUI, 3 - Console */
ohimpadr;   /* import directory table RVA  */
ohimpsiz;   /* import directory table size */
ohiatadr;   /* import address table RVA  */
ohiatsiz;   /* import address table size */
/*************************************************************************************************/
updateoh()
{
  bzs32(execb + 156, ohcodesz);
  bzs32(execb + 160, ohdatasz);
  bzs32(execb + 168, ohentry);
  bzs32(execb + 208, ohtotlsz);
  bzs32(execb + 216, ohchksum);
  bzs16(execb + 220, ohsubsys);
  bzs32(execb + 272, ohimpadr);
  bzs32(execb + 276, ohimpsiz);
  bzs32(execb + 360, ohiatadr);
  bzs32(execb + 364, ohiatsiz);
}
/*************************************************************************************************/
main() {
  auto fd, i, impoff, iltoff, nameoff, iatoff, exitname, temp, wp, wpend;
  
  execb = bnew(2048);
  textb = bnew(2048);
  datab = bnew(2048);
  
  /* MS-DOS header + stub */
  bemitx(&execb, 32, "4D5A80000100000004001000FFFF000040010000000000004000000000000000");
  bemitx(&execb, 32, "0000000000000000000000000000000000000000000000000000000080000000");
  bemitx(&execb, 32, "0E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F");
  bemitx(&execb, 32, "742062652072756E20696E20444F53206D6F64652E0D0A240000000000000000");
  /* PE64 header + PE64 optional header */
  bemitx(&execb, 32, "5045000064860200000000000000000000000000F0002F020B02060000000000");
  bemitx(&execb, 32, "0000000000000000000000000010000000004000000000000010000000020000");
  bemitx(&execb, 32, "0400000000000000040000000000000000000000000200000000000003000000");
  bemitx(&execb, 32, "0000100000000000001000000000000000001000000000000010000000000000");
  bemitx(&execb, 8,  "0000000010000000");
  /* data directories */
  btake(&execb, 128);
  /* section table */
  bemit(&execb, 8, ".text*0*0*0");
  bemitx(&execb, 32, "0000000000000000000000000000000000000000000000000000000020000060");
  bemit(&execb, 8, ".data*0*0*0");
  bemitx(&execb, 32, "00000000000000000000000000000000000000000000000000000000400000C0");
  /* align to 512 */
  btake(&execb, 40);
  
  /* write .code */
  bemitx(&textb, 29, "554889E54881EC20000000B8450000004989C24C89D1E800000000C9C3");
  balign(&textb, 16);
  temp = bemitx(&textb, 8, "FF25000000000000");
  
  bzs32(textb + 23, temp - 23 - 4);
  
  /* write .data */
  impoff = btake(&datab, 40);
  iatoff = btake(&datab, 16);
  iltoff = btake(&datab, 16);
  
  temp =+ 2;
  bzs32(textb + temp, (basedata + iatoff) - (basecode + temp) - 4);
  
  nameoff = bemit(&datab, 11, "msvcrt.dll*0");
  exitname = bemit(&datab, 7, "*0*0exit*0");
  
  bzs64(datab + iatoff, basedata - basefile + exitname);
  bzs64(datab + iltoff, basedata - basefile + exitname);
  
  bzs32(datab + impoff + 0,  basedata - basefile + iltoff);
  bzs32(datab + impoff + 12, basedata - basefile + nameoff);
  bzs32(datab + impoff + 16, basedata - basefile + iatoff);
  
  /* backpatch */
  bemit(&execb, *bsize(&textb), textb);
  balign(&execb, 512);
  bemit(&execb, *bsize(&datab), datab);
  balign(&execb, 512);
  
  section(0, 512, basecode - basefile, 512, 512);
  section(1, 512, basedata - basefile, 512, 512 * 2);
  
  ohcodesz = 512;
  ohdatasz = 512;
  ohentry = basecode - basefile;
  ohtotlsz = 040000;
  ohimpadr = basedata - basefile + impoff;
  ohimpsiz = 40;
  ohiatadr = basedata - basefile + iatoff;
  ohiatsiz = 16;
  updateoh();
  
  /* calc checksum */
  /* HMMM: do I need this? */
  /*
  ohchksum = 0;
  wp = execb;
  wpend = execb + *bsize(&execb);
  
  while (wp != wpend)
  {
    ohchksum =+ bzg16(wp);
    ohchksum = (ohchksum + (ohchksum >> 16)) & 0177777;
    wp =+ 2;
  }
  
  ohchksum =+ *bsize(&execb);

  updateoh();
  */
  
  /* save the executable */
  fd = open("a.exe", 1);
  if (fd < 0) die("can't open");
  write(fd, execb, *bsize(&execb));
  close(fd);

  putchar('*nok*n*n');
  return(0);
}
