/* 024.b - Range ranger! */
main()
{
  auto x, y, a, b;
  
  x = 0;
  while (x <= 10) {
    if (inrange(x, 3, 7)) {
      putchar('0' + x);
    }
    else {
      y = torange(x, 3, 7);
      putchar('A' + y);
    }
    x = x + 1;
  }
  putchar('*n');
}

torange(x, a, b)
{
  if (a >= x) {
    return(a);
  }
  if (x >= b) {
    return(b);
  }
  return(x);
}

inrange(x, a, b)
{
  return(a <= x & x <= b);
}

/* output:
DDD34567HHH

*/

