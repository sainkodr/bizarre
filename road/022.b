/* 022.b - Print rectangle */
main()
{
  rect(1, 1);
  rect(2, 3);
  rect(5, 7);
}

rect(w, h)
{
  while (h > 0) {
    line(w);
    h = h - 1;
  }
  putchar('*n');
}

line(w)
{
  while (w > 0) {
    putchar('[]');
    w = w - 1;
  }
  putchar('*n');
}

/* output:
[]

[][]
[][]
[][]

[][][][][]
[][][][][]
[][][][][]
[][][][][]
[][][][][]
[][][][][]
[][][][][]


*/

