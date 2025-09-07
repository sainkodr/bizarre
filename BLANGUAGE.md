# B PROGRAMMING LANGUAGE

## symbol

```c
/* multiline comment */
alpha then any number of alnum  /* name */
digit then any number of alnum  /* integer */
' up to WORD_SIZE print/mapch ' /* character */
" any number of print/mapch "   /* string ('*e' terminated, NOT '\0') */
/* punctuators and operators: */
=<= =>= === =!= =<< =>>
++ -- << >> <= >= == != =+ =- =* =/ =% =| =& =< =>
{ } ( ) [ ] ! * / % + - < > & | ? : = , ;
```

## extdef

```c
name() { ... }                                    /* function definition */
name(name0, name1, name3) { ... }                 /* function definition with parameters */
name;                                             /* global variable declaration */
name constant;                                    /* global variable definition */
name constant0, constant1, constant2;             /* global variable? definition */
name[max_index];                                  /* global vector declaration */
name[] constant0, constant1, constant2;           /* global vector definition */
name[max_index] constant0, constant1, constant2;  /* global vector definition */
/* max_index is the number of elements minus one;
   constant is an integer or character, positive or negative (for example: 0 42 -100 'A' '*n') */
```

## mapch

```
*0   *e    *t   *n   *r   *(   *)   **   *'   *"
\0   \04   \t   \n   \r    {    }    *    '    "
```

## stmt

```c
;                            /* empty statement */
{ ... }                      /* statement list */
expr;                        /* expression statement */
return(expr);                /* return statement */
return;                      /* return statement (no value) */
auto name0, name1, name2;    /* local variable declaration */
extrn name0, name1, name2;   /* external symbol declaration */
if (expr) stmt               /* if statement */
if (expr) stmt else stmt     /* if-else statement */
while (expr) stmt            /* while statement */
name:                        /* label */
goto name;                   /* jump to a label */
switch expr { ... }          /* switch statement */
case constant:               /* case inside of a switch statement */
```

## expr

```
 0  L  integer character name string (subexpr)
 1  L  x(...) x[y] x++ x--
 2  R  &x *x -x !x ++x --x
 3  L  * / %
 4  L  + -
 5  L  << >>
 6  L  < > <= >= == !=
 7  L  &
 8  L  |
 9  R  a?b:c
10  R  = =+ =- =* =/ =% =| =& =< => =<= =>= === =!= =<< =>>
11  R  ,
```

## libb

```c
/* classic runtime: */
{ main(); exit(); }
/* implement first: */
c      = char(string, i);             /* get ith byte in a string */
error  = close(file);                 /* close a file stream */
file   = creat(string, mode);         /* create a file */
         exit();                      /* terminate the program */
char   = getchar();                   /* read a byte from stdin */
         lchar(string, i, char);      /* set ith byte in a string */
file   = open(string, mode);          /* open a file */
         printf(format, argl, ...);   /* print formated text (%d %o %c %s %%) */
         printn(number, base);        /* print a number in a base */
         putchar(char);               /* print WORD_SIZE characters */
nread  = read(file, buffer, count);   /* read bytes from a file stream */
error  = seek(file, offset, type);    /* offset a file stream (type: 0 begin, 1 current, 2 end) */
nwrite = write(file, buffer, count);  /* read bytes to a file stream */
         argv[]                       /* arguments where argv[0]+1 is argc */
/* implement second: */
error = chdir(string) ;
error = chmod(string, mode);
error = chown(string, owner);
        ctime(time, date);
        execl(string, arg0, arg1, ..., 0);
        execv(string, argv, count);
error = fork();
error = fstat(file, status);
id    = getuid();
error = gtty(file, ttystat);
error = link(string1, string2);
error = mkdir(string, mode);
error = setuid(id);
error = stat(string, status);
error = stty(file, ttystat);
        time(timev);
error = unlink(string);
error = wait();
```
