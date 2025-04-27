/* 017.b - Copyright violation */
main()
{
  extrn gmsg, cmsg;
  
  copy(cmsg, gmsg, 4);
  putsome(gmsg, 2);
  putsome(cmsg, 4);
}

copy(dst, src, num) /* num - the number of elements (max index + 1) */
{
start:
  if (num) {
    num = num - 1;
    dst[num] = src[num];
    goto start;
  }
}

putsome(vec, num)
{
  auto i;
  
  i = 0;
loop:
  if (num - i) {
    putchar(vec[i]);
    i = i + 1;
    goto loop;
  }
  putchar('*n');
}

gmsg[] 'n', 'o', 't', 'e';
cmsg[3]; /* 3 - max index (4 elements) */

/* output:
no
note

*/

