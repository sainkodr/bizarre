/* 038.b - Fill vector */
main()
{
  extrn vectr;
  
  putv(vectr, 6);
  fill(vectr, 10, 3);
  putv(vectr, 6);
  fill(vectr, 99, 6);
  putv(vectr, 6);
}

fill(v, x, n)
{
  auto i;
  
  i = n - 1;
  while (i >= 0) {
    v[i--] = x;
  }
}

putv(v, n)
{
  auto i;
  
  putchar('[ ');
  i = 0;
  while (i < n) {
    printn(v[i++], 10);
    putchar(' ');
  }
  putchar(']*n');
}

vectr[] 20, 85, 70, 18, 52, 37;

/* output:
[ 20 85 70 18 52 37 ]
[ 10 10 10 18 52 37 ]
[ 99 99 99 99 99 99 ]

*/

