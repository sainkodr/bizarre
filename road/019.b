/* 019.b - View the bytes */
main()
{
  auto c, n;
  
  n = 0;
loop:
  if ('*e' != (c = getchar())) {
    putchar('0');
    printn(c, 8);
    n = n + 1;
    putchar('  ');
    if (n == 8) {
      putchar('*n');
      n = 0;
    }
    goto loop;
  }
  putchar('*n');
}

/* input:
Bye
^D
*/

/* output:
0102  0171  0145  012

*/

