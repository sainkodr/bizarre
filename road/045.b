/* 045.b - Introfuse switch statements */
main()
{
  auto p, n;
  
  p = 4;
  n = 0;
  while (++n < 10) {
    putnasw(p);
    putchar('*n');
    p =* 2;
    p =- 3;
  }
}

putnasw(n)
{
  if (n < 0) {
    puts("minus ");
    n = -n;
  }

  /**/ if (n <= 20 | (n < 100 & n % 10 == 0)) {
    smplcase(n);
  }
  else if (n < 100) {
    smplcase(n - (n % 10));
    putchar(' ');
    smplcase(n % 10);
  }
  else {
    putnasw(n / 100);
    puts(" hundred");
    if (n % 100 != 0) {
      putchar(' ');
      putnasw(n % 100);
    }
  }
}

smplcase(n)
{
  switch (n) {
  case 0: puts("zero"); break;
  case 1: puts("one"); break;
  case 2: puts("two"); break;
  case 3: puts("three"); break;
  case 4: puts("four"); break;
  case 5: puts("five"); break;
  case 6: puts("six"); break;
  case 7: puts("seven"); break;
  case 8: puts("eight"); break;
  case 9: puts("nine"); break;
  
  case 10: puts("ten"); break;
  case 11: puts("eleven"); break;
  case 12: puts("twelve"); break;
  case 13: puts("thirteen"); break;
  case 14: puts("fourteen"); break;
  case 15: puts("fifteen"); break;
  case 16: puts("sixteen"); break;
  case 17: puts("seventeen"); break;
  case 18: puts("eighteen"); break;
  case 19: puts("nineteen"); break;
  
  case 20: puts("twenty"); break;
  case 30: puts("thirty"); break;
  case 40: puts("forty"); break;
  case 50: puts("fifty"); break;
  case 60: puts("sixty"); break;
  case 70: puts("seventy"); break;
  case 80: puts("eighty"); break;
  case 90: puts("ninety"); break;
  
  default: break;
  }
}

puts(s)
{
  auto i;
  
  i = -1;
  while (char(s, ++i) != '*e') {
    putchar(char(s, i));
  }
}

/* output:
four
five
seven
eleven
nineteen
thirty five
sixty seven
one hundred thirty one
two hundred fifty nine

*/

