/* 020.b - Intronews uadr and uind */
main()
{
  auto a, b;
  
  a = 13;
  b = 42;
  
  putvar('a', a);
  putvar('b', b);
  
  swap(&a, &b);
  
  putvar('a', a);
  putvar('b', b);
}

putvar(name, value)
{
  putchar(name);
  putchar(' =');
  putchar(' ');
  printn(value, 10);
  putchar('*n');
}

swap(ap, bp)
{
  auto tmp;
  
  tmp = *ap;
  *ap = *bp;
  *bp = tmp;
}

/* output:
a = 13
b = 42
a = 42
b = 13

*/

