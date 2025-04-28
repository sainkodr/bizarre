/* 026.b - putnumb */
main()
{
  putnumb(42, 10);
  putchar('*n0');
  putnumb(42, 8);
  putchar('*nx');
  putnumb(42, 16);
  putchar('*nb');
  putnumb(42, 2);
  putchar('*n');
}

putnumb(num, base)
{
  auto tmp;

  if (num < 0) {
    putchar('-');
    num = -num;
  }
  
  tmp = num / base;
  if (tmp != 0) {
    putnumb(tmp, base);
  }
  
  putchar(todigit(num % base));
}

todigit(num)
{
  if (num < 10) {
    return('0' + num);
  }
  else {
    return('A' + num - 10);
  }
}

/* output:
42
052
x2A
b101010

*/

