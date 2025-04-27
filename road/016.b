/* 016.b - Vectorian era */
main()
{
  extrn msg;
  auto i, c;
  
  i = 0;
loop:
  if (c = msg[i]) {
    putchar(c);
    i = i + 1;
    goto loop;
  }
}

msg[] 'Ve', 'ct', 'or', '*n', 0;

/* output:
Vector

*/

