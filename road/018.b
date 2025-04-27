/* 018.b - A cat */
main()
{
  auto c;
loop:
  if ('*e' != (c = getchar())) {
    putchar(c);
    goto loop;
  }
}

/* input:
Meow
^D
*/

/* output:
Meow

*/

