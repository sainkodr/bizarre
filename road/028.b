/* 028.b - In space... */
main()
{
  scream("I'm in space!*n");
}

scream(s)
{
  auto i;
  
  i = 0;
  while (char(s, i) != '*e') {
    putchar(toupper(char(s, i)));
    i = i + 1;
  }
}

toupper(c)
{
  if (c < 'a' | 'z' < c) {
    return(c);
  }
  return(c - 'a' + 'A');
}

/* output:
I'M IN SPACE!

*/

