/* 034.b - Print bits */
main()
{
  putbits(00);  putchar('*n');
  putbits(01);  putchar('*n');
  putbits(07);  putchar('*n');
  putbits(04);  putchar('*n');
  putbits(016); putchar('*n');
  putbits(42); putchar('*n');
}

putbits(x)
{
  auto b, t, zeros;
  
  if (x == 0) {
    putchar('0');
    return;
  }
  
  b = 1;
  t = 8;
  while (t != 0) {
    b = b << 1;
    --t;
  }
  
  zeros = 0;
  while (b != 0) {
    if (x & b) {
      putchar('1');
      zeros = 1;
    }
    else if (zeros != 0) {
      putchar('0');
    }
    b = b >> 1;
  }
}

/* output:
0
1
111
100
1110
101010

*/

