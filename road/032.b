/* 032.b - Factorial */
main()
{
  auto i;
  
  i = 0;
  while (i < 9) {
    printn(fact(i), 10); putchar('*n');
    i =+ 1;
  }
}

fact(n)
{
  auto r;
  
  r = 1;
  while (n > 1) {
    r =* n;
    n =- 1;
  }
  return(r);
}

/* output:
1
1
2
6
24
120
720
5040
40320

*/

