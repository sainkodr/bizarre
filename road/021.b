/* 021.b - Next item, please */
main()
{
  putnts(s0);
  putnts(s1);
  putnts(s2);
  putchar('*n');
}

putnts(s)
{
loop:
  if (*s) {
    putchar(s[0]);
    s = &s[1]; /* get pointer to the next element */
    goto loop;
  }
  putchar(' ');
}

s0[] 'Ne', 'xt', 0;
s1[] 'it', 'em', ',',  0;
s2[] 'pl', 'ea', 'se', 0;

/* output:
Next item, please

*/

