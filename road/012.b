/* 012.b - Return a value */
main()
{
  extrn a, b;
  auto c;
  
  a = 'A';
  b = 5;
  c = getsum();
  putchar(c); /* -> 'F' */
  putchar('*n');
}

getsum()
{
  extrn a, b;
  
  return(a + b);
}

a;
b;

/* output:
F

*/

