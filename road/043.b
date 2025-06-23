/* 043.b - Bubblebee */
main()
{
  extrn words, numwords;

  putwords();
  bubble(words, numwords);
  putwords();
}

putwords()
{
  extrn words, numwords;
  auto i, k, w;
  
  putchar('word');
  putchar('s[] ');
  i = -1;
  while (++i < numwords) {
    putchar('*"');
    
    w = words[i];
    k = -1;
    while (char(w, ++k) != '*e') {
      putchar(char(w, k));
    }
    
    if (i != numwords - 1) {
      putchar('*", ');
    }
    else {
      putchar('*"');
    }
  }
  putchar(';*n');
}

compare(a, b)
{
  auto i;
  
  i = 0;
  while (char(a, i) != '*e' & char(a, i) == char(b, i)) {
    ++i;
  }
  return(char(a, i) - char(b, i));
}

bubble(items, numitems)
{
  auto i, k, x, xi, tmp;
  
  i = -1;
  while (++i < numitems) {
    x = items[i];
    xi = i;
    k = i;
    while (++k < numitems) {
      if (compare(items[k], x) < 0) {
        xi = k;
        x = items[xi];
      }
    }
    items[xi] = items[i];
    items[i] = x;
  }
}

words[] "leadership", "address", "pie", "protect", "farewell", "face", "movement", "apathy", "relative", "blame";
numwords 10;

/* output:
words[] "leadership", "address", "pie", "protect", "farewell", "face", "movement", "apathy", "relative", "blame";
words[] "address", "apathy", "blame", "face", "farewell", "leadership", "movement", "pie", "protect", "relative";

*/

