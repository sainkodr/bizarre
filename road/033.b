/* 033.b - Add two numbers */
main()
{
  printn(add(2, 2), 10); putchar('*n');
  printn(add(60, 9), 10); putchar('*n');
  putchar(add('B', 1)); putchar('*n');
}

add(a, b)
{
  while (b > 0) {
    ++a;
    --b;
  }
  return(a);
}

/* output:
4
69
C

*/

