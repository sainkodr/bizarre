/* 015.b - And, or, octal numbers */
main()
{
  putbinar(0);
  putbinar(1);
  putbinar(7);
  putbinar(8);
  putbinar(10);
  putbinar(15);
}

putbinar(n)
{
  auto a, b, c, d;
  
  a = n & 001;
  b = n & 002;
  c = n & 004;
  d = n & 010;
  
  putchar('0b');
  putchar('0'       | tobool(d));
  putchar(tobool(c) | '0');
  putchar(48        | tobool(b));
  putchar(tobool(a) | 060);
  putchar('*n');
}

tobool(x) {
  if (x) {
    return(1);
  }
  return(0);
}

/* output:
0b0000
0b0001
0b0111
0b1000
0b1010
0b1111

*/

