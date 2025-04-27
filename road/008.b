/* 008.b - Equal */
main()
{
  if (67 == 'C') { /* 1 */
    putchar('A');
  }
  if (128 == 0) { /* 0 */
    putchar('B');
  }
  if ('A' == 'a') { /* 0 */
    putchar('C');
  }
  putchar('*n');
}

/* output:
A

*/

