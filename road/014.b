/* 014.b - Introgoose goto */
main()
{
  putline(1);
  putline(2);
  putline(3);
}

putline(n)
{
start:
  if (n == 0) {
    putchar('*n');
    return;
  }
  n = n - 1;
  putchar('[]');
  goto start;
}

/* output:
[]
[][]
[][][]

*/

