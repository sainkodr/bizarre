/* 010.b - More than 1 function */
main()
{
  extrn v;

  v = '5';
  putv();
}

putv()
{
  extrn v;

  putchar(v);
  v = v - 1;
  if (v == '0') {
    putchar('*n');
    exit();
  }
  putv();
}

v;

/* output:
54321

*/

