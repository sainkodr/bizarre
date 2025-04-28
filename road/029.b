/* 029.b - In a library... */
main()
{
  extrn buff;
  auto n;
  
  n = read(0, buff, 29);
  atolower(buff, n);
  write(1, buff, n);
}

atolower(s, n)
{
  auto i, c;
  
  i = 0;
  while (i < n) {
    c = char(s, i);
    lchar(s, i, tolower(c));
    i = i + 1;
  }
}

tolower(c)
{
  if (c < 'A' | 'Z' < c) {
    return(c);
  }
  return(c - 'A' + 'a');
}

buff[29]; /* guaranteed to fit up to 30 characters */

/* input:
YOU SHALL NOT PASS

*/

/* input:
you shall not pass

*/

