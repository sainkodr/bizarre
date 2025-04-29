/* 036.b - Memequ */
main()
{
  putbool(memequ("abcd", "abcd", 4));
  putbool(memequ("aBcdE", "abcDf", 5));
  putbool(memequ("123456789", "123ABCD", 3));
  putbool(memequ("123456789", "123ABCD", 6));
}

memequ(a, b, n)
{
  auto i, r;
  
  i = 0;
  r = 1;
  while (i < n) {
    r =& char(a, i) == char(b, i);
    ++i;
  }
  return(r);
}

putbool(b)
{
  if (b) {
    putchar('tr');
    putchar('ue');
    putchar('*n');
  }
  else {
    putchar('fa');
    putchar('ls');
    putchar('e*n');
  }
}

/* output:
true
false
true
false

*/

