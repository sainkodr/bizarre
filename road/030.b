/* 030.b - Weird sequence */
main()
{
  sequence(2745);
}

sequence(x)
{
  while (x > 1) {
    printn(x, 10); putchar('*n');
    x = numbits(x);
  }
  putchar('*n');
}

numbits(x)
{
  auto n, i;
  
  n = 0;
  i = 0;
  while (i < 16) {
    if (x & 1) {
      n = n + 1;
    }
    x = x >> 1;
    i = i + 1;
  }
  return(n);
}

/* output:
2745
7
3
2

*/

