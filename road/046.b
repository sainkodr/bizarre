/* 046.b - Print who? */
main()
{
  auto var;

  var = 69;
  printone("Hello, %s!*n", "World");
  printone("var = %d*n", var);
}

printone(fmt, arg)
{
  auto ci, c;
  
  ci = -1;
  while ((c = char(fmt, ++ci)) != '*e') {
    if (c == '%') {
      c = char(fmt, ++ci);
      /**/ if (c == 'd') {
        printn(arg, 10);
      }
      else if (c == 's') {
        printone(arg, 0);
      }
      else {
        putchar('%');
      }
    }
    else {
      putchar(c);
    }
  }
}

/* output:
Hello, World!
var = 69

*/

