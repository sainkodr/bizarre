/* 025.b - Hex to bin */
main()
{
  auto c, byte, n;
  
  n = 0;
  byte = 0;
  
  while (1) {
    c = getchar();
    while (c != '*e' & !ishex(c)) {
      c = getchar();
    }
    if (c == '*e') {
      return;
    }
    if (n == 0) {
      n = 1;
      byte = tonum(c);
    }
    else {
      n = 0;
      byte = byte * 16 + tonum(c);
      putchar(byte);
    }
  }
}

isdig(c)
{
  return('0' <= c & c <= '9');
}

tonum(c)
{
  if (isdig(c)) {
    return(c - '0');
  }
  return(c - 'A' + 10);
}

ishex(c)
{
  return(isdig(c) | ('A' <= c & c <= 'F'));
}

/* input:
62 20 63 6F 6D 70 69 6C 65 72 0A
^D

*/

/* output:
b compiler

*/

