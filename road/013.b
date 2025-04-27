/* 013.b - Function parameters */
main()
{
  auto y;
  
  y = choose(1, 'TR', 'FL');
  putchar(y);
  
  putchar(' ');
  
  y = choose(0, 'TR', 'FL');
  putchar(y);
  
  putchar('*n');
}

choose(x, a, b)
{
  if (x) {
    return(a);
  }
  
  return(b);
}

/* output:
TR FL

*/

