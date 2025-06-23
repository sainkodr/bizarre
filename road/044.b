/* 044.b - Find */
main()
{
  extrn numbs, numnumbs;
  auto v, i;
  
  v = -1;
  while (++v < 100) {
    i = find(numbs, numnumbs, v);
    if (i >= 0) {
      putchar(' ');
      printn(i, 10);
    }
  }
  putchar('*n');
}

find(array, count, value)
{
  auto i;
  
  i = -1;
  while (++i < count) {
    if (array[i] == value) {
      return(i);
    }
  }

  return(-1);
}

numbs[] 84, 44, 77, 29, 83, 65, 56, 55, 74, 11;
numnumbs 10;

/* output:
 9 3 1 7 6 5 8 2 4 0

*/

