/* bizarre.b - B compiler */
/*************************************************************************************************/
exeb;
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
main() {
  auto fd;
  
  exeb = bnew(16);
  
  /* MS-DOS Stub */
  bemitx(&exeb, 16, "4D5A80000100000004001000FFFF0000");
  bemitx(&exeb, 16, "40010000000000004000000000000000");
  bemitx(&exeb, 16, "00000000000000000000000000000000");
  bemitx(&exeb, 16, "00000000000000000000000080000000");
  bemitx(&exeb, 16, "0E1FBA0E00B409CD21B8014CCD215468");
  bemitx(&exeb, 16, "69732070726F6772616D2063616E6E6F");
  bemitx(&exeb, 16, "742062652072756E20696E20444F5320");
  bemitx(&exeb, 16, "6D6F64652E0D0A240000000000000000");
  
  /* save the executable */
  fd = open("a.exe", 1);
  if (fd < 0) die("can't open");
  write(fd, exeb, *bsize(&exeb));
  close(fd);

  putchar('*nok*n*n');
  return(0);
}
