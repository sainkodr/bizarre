/* 023.b - Compare vectors */
main()
{
  printn(compare(v0, v1, 4), 8); putchar('*n');
  printn(compare(v0, v2, 4), 8); putchar('*n');
  printn(compare(v0, v3, 4), 8); putchar('*n');
}

compare(a, b, n)
{
  while (n > 0) {
    /**/ if (*a > *b) {
      return( 1);
    }
    else if (*a < *b) {
      return(-1);
    }
    a = &a[1];
    b = &b[1];
    n = n - 1;
  }
  return(0);
}

v0[3] 0, 1, 2, 3;
v1[3] 4, 3, 5, 7;
v2[3] 0, 1, 2, 3;
v3[3] 0, 1, 1, 0;

/* output:
-1
0
1

*/

