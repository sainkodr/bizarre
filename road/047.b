/* 047.b - Function pointer */
toupp(c)
{
  if ('a' <= c & c <= 'z')
  {
    return(c + 'A' - 'a');
  }
  
  return(c);
}

tolow(c)
{
  if ('A' <= c & c <= 'Z')
  {
    return(c + 'a' - 'A');
  }
  
  return(c);
}

main()
{
  putsfn("Hello, Function Pointer!*n", toupp);
  putsfn("Hello, Function Pointer!*n", tolow);
}

putsfn(s, f)
{
  auto i;
  
  i = 0;
  
  while (char(s, i) != '*e')
  {
    putchar(f(char(s, i)));
    ++i;
  }
}

/* output:
HELLO, FUNCTION POINTER!
hello, function pointer!

*/

