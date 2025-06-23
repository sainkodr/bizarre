/* 042.b - Introdude the ternary operator */
main()
{
  extrn numbs;
  auto i, k;

  i = -1;
  while (++i < 6) {
    k = i - 1;
    while (++k < 6) {
      putfunc('min', numbs[i], numbs[k], min(numbs[i], numbs[k]));
      putchar('    ');
      putfunc('max', numbs[i], numbs[k], max(numbs[i], numbs[k]));
      putchar('*n');
    }
  }
}

putfunc(name, a, b, y)
{
  putchar(name);
  putchar('(');
  printn(a, 10);
  putchar(', ');
  printn(b, 10);
  putchar(') =>');
  putchar(' ');
  printn(y, 10);
}

min(a, b)
{
  return(a < b ? a : b);
}

max(a, b)
{
  return(a > b ? a : b);
}

numbs[] 81, 57, 46, 95, 19, 69;

/* output:
min(81, 81) => 81    max(81, 81) => 81
min(81, 57) => 57    max(81, 57) => 81
min(81, 46) => 46    max(81, 46) => 81
min(81, 95) => 81    max(81, 95) => 95
min(81, 19) => 19    max(81, 19) => 81
min(81, 69) => 69    max(81, 69) => 81
min(57, 57) => 57    max(57, 57) => 57
min(57, 46) => 46    max(57, 46) => 57
min(57, 95) => 57    max(57, 95) => 95
min(57, 19) => 19    max(57, 19) => 57
min(57, 69) => 57    max(57, 69) => 69
min(46, 46) => 46    max(46, 46) => 46
min(46, 95) => 46    max(46, 95) => 95
min(46, 19) => 19    max(46, 19) => 46
min(46, 69) => 46    max(46, 69) => 69
min(95, 95) => 95    max(95, 95) => 95
min(95, 19) => 19    max(95, 19) => 95
min(95, 69) => 69    max(95, 69) => 95
min(19, 19) => 19    max(19, 19) => 19
min(19, 69) => 19    max(19, 69) => 69
min(69, 69) => 69    max(69, 69) => 69

*/

