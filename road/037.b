/* 037.b - GCD */
main()
{
  extrn numbs;
  auto i, k;
  
  i = 0;
  while (i < 5) {
    k = i;
    while (k < 5) {
      printn(numbs[i], 10); putchar('  ');
      printn(numbs[k], 10); putchar('  ');
      printn(gcd(numbs[i], numbs[k]), 10); putchar('*n');
      ++k;
    }
    ++i;
  }
}

gcd(a, b)
{
  a =% b;
  
  if (a == 0) {
    return(b);
  }
  
  return(gcd(b, a));
}

numbs[4] 92, 33, 84, 21, 42;

/* output:
92  92  92
92  33  1
92  84  4
92  21  1
92  42  2
33  33  33
33  84  3
33  21  3
33  42  3
84  84  84
84  21  21
84  42  42
21  21  21
21  42  21
42  42  42

*/

