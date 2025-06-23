/* 041.b - Introbooz local vectors */
main()
{
  auto a[2], b[2], c[2];
  
  v3set(a, 2, 8, 3);
  v3set(b, 6, 1, 4);
  v3add(c, a, b);
  v3put(a, 'a');
  v3put(b, 'b');
  v3put(c, 'c');
}

v3add(y, x1, x2)
{
  auto i;
  
  i = -1;
  while (++i < 3) {
    y[i] = x1[i] + x2[i];
  }
}

v3set(v, x, y, z)
{
  v[0] = x;
  v[1] = y;
  v[2] = z;
}

v3put(v, name)
{
  putchar(name);
  putchar(' = ');
  putchar('{ x ');
  printn(v[0], 10);
  putchar(', y ');
  printn(v[1], 10);
  putchar(', z ');
  printn(v[2], 10);
  putchar(' };*n');
}

/* output:
a = { x 2, y 8, z 3 };
b = { x 6, y 1, z 4 };
c = { x 8, y 9, z 7 };

*/

