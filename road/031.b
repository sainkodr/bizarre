/* 031.b - Fibonacci sequence */
main()
{
  auto a, b, c;
  
  a = 1;
  b = 0;
  while (b != 46368) {
    printn(a, 10); putchar('*n');
    c = a;
    a =+ b;
    b = c;
  }
}

/* output:
1
1
2
3
5
8
13
21
34
55
89
144
233
377
610
987
1597
2584
4181
6765
10946
17711
28657
46368

*/

