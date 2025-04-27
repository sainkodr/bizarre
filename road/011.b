/* 011.b - Introthose return */
main()
{
  extrn var, max;

  var = '3';
  max = '7';
  putrange();
  putchar('*n');
}

putrange()
{
  extrn var, max;

  putchar(var);
  var = var + 1;
  if (var == max + 1) {
    return;
  }
  putrange();
}

var;
max;

/* output:
34567

*/

