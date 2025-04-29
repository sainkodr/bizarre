/* 035.b - Parse hex */
main()
{
  auto y;
  
  y = parsehex("10", 2);
  printn(y, 10); putchar('*n');
  
  y = parsehex("F1", 2);
  printn(y, 10); putchar('*n');
  
  y = parsehex("AB0B", 4);
  printn(y, 10); putchar('*n');
}

parsehex(s, n)
{
  auto c, i, x;
  
  i = 0;
  x = 0;
  while (i < n) {
    c = char(s, i);
    x =<< 4;
    x =| tonumber(c);
    ++i;
  }
  return(x);
}

tonumber(c)
{
  if ('0' <= c & c <= '9') {
    return(c - '0');
  }
  return(c - 'A' + 10);
}

/* output:
16
241
43787

*/

