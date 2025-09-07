/* bootstrap.c - translate B to C */
/* gcc -Wall -Wextra -o bootstrap bootstrap.c */
/*************************************************************************************************/
#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*************************************************************************************************/
#define numof(array) (sizeof(array)/sizeof((array)[0]))
/*************************************************************************************************/
typedef struct Operator {
  int o_operator_length;
  int o_equivalent_length;
  const char *o_operator_string;
  const char *o_equivalent_string;
} Operator;
/*************************************************************************************************/
typedef struct String {
  char *s_string;
  int   s_length;
} String;
/*************************************************************************************************/
typedef unsigned long long U;
typedef signed long long   W;
/*************************************************************************************************/
#define CSS(s) (s).s_length, (s).s_string
#define EMPTY ((String){"",0})
#define CSTRING(S) ((String){(S),sizeof(S)-1})
#define NAME_PREFIX "B"
/*************************************************************************************************/
#define O(opr, eqv) { sizeof(opr)-1, sizeof(eqv)-1, (opr), (eqv) }
/*************************************************************************************************/
static const Operator operator_table_prefix[] = {
O("++", "++"), O("--", "--"), O("-", "-"), O("!", "!"), O("&", "(W)&"), O("*", "*(W*)")
};
/*************************************************************************************************/
static const Operator operator_table_binary[] = {
O("=<<", "<<="),O("=>>", ">>="),
O("=+", "+="),O("=-", "-="),O("=*", "*="),O("=/", "/="),O("=%", "%="),O("=&", "&="),O("=|", "|="),
O("==", "=="),O("!=", "!="),O("<=", "<="),O(">=", ">="),O("<<", "<<"),O(">>", ">>"),
O("=", "="),O("?", "?"),O(":", ":"),O("|", "|"),O("&", "&"),O("<", "<"),O(">", ">"),O("+", "+"),
O("-", "-"),O("*", "*"),O("/", "/"),O("%", "%")
};
/*************************************************************************************************/
static char input[0x100000], decls[0x100000], globals[0x100000], source[0x100000];
static char *inp = input,    *dcl = decls,    *glb = globals,    *src = source;
static String function_names[256];
static size_t function_count;
/*************************************************************************************************/
void die(const char *last_words)
{
  fprintf(stderr, "ERROR: %s\nOFFSET: %i\n", last_words, (int)(inp - input));
  exit(EXIT_FAILURE);
}
/*************************************************************************************************/
void save_function(String prefixless_name)
{
  if (function_count >= numof(function_names)) die("too many functions");
  
  function_names[function_count] = prefixless_name;
  ++function_count;
}
/*************************************************************************************************/
int is_function(String prefixless_name)
{
  size_t i;
  
  for (i = 0; i < function_count; ++i)
  {
    if (prefixless_name.s_length == function_names[i].s_length
     && memcmp(prefixless_name.s_string, function_names[i].s_string, prefixless_name.s_length) == 0)
    {
      return 1;
    }
  }
  
  return 0;
}
/*************************************************************************************************/
void spaces(void)
{
start:

  while (isspace(*inp))
  {
    ++inp;
  }
  
  if (inp[0] == '/' && inp[1] == '*')
  {
    inp += 2;
    
    while (*inp != '\0' && !(inp[0] == '*' && inp[1] == '/'))
    {
      ++inp;
    }
    
    inp += 2;
    
    goto start;
  }
}
/*************************************************************************************************/
int match_string(size_t length, const char *string)
{
  spaces();
  
  if (memcmp(inp, string, length) != 0) return 0;
  
  inp += length;
  return 1;
}
/*************************************************************************************************/
#define match_cstring(cstring) match_string(sizeof(cstring) - 1, (cstring))
/*************************************************************************************************/
const Operator *match_operator(size_t num, const Operator *tab)
{
  size_t i;
  
  for (i = 0; i < num; ++i)
  {
    if (match_string(tab[i].o_operator_length, tab[i].o_operator_string))
    {
      return &tab[i];
    }
  }
  
  return NULL;
}
/*************************************************************************************************/
__attribute__((format(printf, 1, 2)))
String stringf(const char *format, ...)
{
  String s;
  va_list args;

  va_start(args, format);
  s.s_length = vsnprintf(NULL, 0, format, args);
  va_end(args);
  
  s.s_string = calloc(s.s_length + 1, 1);
  
  va_start(args, format);
  vsprintf(s.s_string, format, args);
  va_end(args);
  
  return s;
}
/*************************************************************************************************/
String convert_expression(int is_statement);
/*************************************************************************************************/
String quoted_value(int end)
{
  static char string[0x10000]; /* up to 64KB strings is enough for everyone */
  
  size_t length;
  int ch;
  
  memset(string, 0, 10);
  length = 0;
  
  for (;;)
  {
    if (iscntrl(*inp)) die("endless string");
    
    if (*inp == end) break;
    
    if (length >= sizeof(string) - 1) die("the string is too long");
    
    /**/ if (inp[0] == '*' && inp[1] == '*')  { ch = '*';  inp += 2; }
    else if (inp[0] == '*' && inp[1] == 'n')  { ch = '\n'; inp += 2; }
    else if (inp[0] == '*' && inp[1] == 't')  { ch = '\t'; inp += 2; }
    else if (inp[0] == '*' && inp[1] == 'r')  { ch = '\r'; inp += 2; }
    else if (inp[0] == '*' && inp[1] == '0')  { ch = '\0'; inp += 2; }
    else if (inp[0] == '*' && inp[1] == 'e')  { ch = '\0'; inp += 2; }
    else if (inp[0] == '*' && inp[1] == '\'') { ch = '\''; inp += 2; }
    else if (inp[0] == '*' && inp[1] == '"')  { ch = '"';  inp += 2; }
    else if (inp[0] == '*' && inp[1] == '(')  { ch = '{';  inp += 2; }
    else if (inp[0] == '*' && inp[1] == ')')  { ch = '}';  inp += 2; }
    else                                            { ch = *inp; ++inp; }

    string[length] = ch;
    ++length;
  }
  
  string[length] = '\0';
  ++inp;
  
  return (String) { string, length };
}
/*************************************************************************************************/
String generate_string(String values)
{
  String lit;
  int i;
  
  lit.s_length = 4 + values.s_length * 4 + 1;
  lit.s_string = calloc(lit.s_length + 1, 1);
  sprintf(lit.s_string, "(W)\"");
  lit.s_string[lit.s_length - 1] = '"';

  for (i = 0; i < values.s_length; ++i)
  {
    snprintf(lit.s_string + 4 + i * 4, 4, "\\x%02X", values.s_string[i]);
  }

  return lit;
}
/*************************************************************************************************/
String convert_unary(void)
{
  const Operator *o;
  String prefix, atom, subexpr;
  
  prefix = EMPTY;
  
  /* convert prefix */
  
  for (;;)
  {
    o = match_operator(numof(operator_table_prefix), operator_table_prefix);
    
    if (o == NULL) break;
    
    prefix = stringf("%.*s%.*s", CSS(prefix), o->o_equivalent_length, o->o_equivalent_string);
  }
  
  /* convert atom */
  
  spaces();
  
  atom.s_string = inp;
  
  if (isalnum(*inp))
  {
    int is_integer;
    
    is_integer = isdigit(*inp);
    
    while (isalnum(*inp))
    {
      ++inp;
    }
    
    atom.s_length = inp - atom.s_string;
    
    if (is_integer)
    {
      atom = stringf("%.*sLL", CSS(atom));
    }
    else
    {
      atom = stringf("%s"NAME_PREFIX"%.*s", is_function(atom) ? "(W)" : "", CSS(atom));
    }
  }
  else if (match_cstring("'"))
  {
    atom = stringf("0x%"PRIX64"LL", *(U*)quoted_value('\'').s_string);
  }
  else if (match_cstring("\""))
  {
    atom = generate_string(quoted_value('"'));
  }
  else if (match_cstring("("))
  {
    atom = convert_expression(0);
    
    if (!match_cstring(")")) die("no ')'");
    
    atom = stringf("(%.*s)", CSS(atom));
  }
  else
  {
    die("no atom");
  }
  
  /* convert suffixes */
  
  for (;;)
  {
    if (match_cstring("("))
    {
      String argv, arg1;
      int argc;
      
      argv = EMPTY;
      argc = 0;

      spaces();
      
      if (*inp != ')')
      {
        for (;;)
        {
          arg1 = convert_expression(0);
          
          ++argc;
          
          if (match_cstring(","))
          {
            argv = stringf("%.*s%.*s, ", CSS(argv), CSS(arg1));
            spaces();
          }
          else
          {
            argv = stringf("%.*s%.*s", CSS(argv), CSS(arg1));
            break;
          }
        }
      }

      if (!match_cstring(")")) die("no ')'");
      
      argc = (argc != 0) ? argc * 2 - 1 : 0;
      /* up to 16 arguments is enough for everyone */
      atom = stringf("((W(*)(%.*s))(%.*s))(%.*s)", argc, "W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,", CSS(atom), CSS(argv));
    }
    else if (match_cstring("["))
    {
      subexpr = convert_expression(0);
      atom = stringf("((W*)(%.*s))[%.*s]", CSS(atom), CSS(subexpr));
      
      if (!match_cstring("]")) die("no ']'");
    }
    else if (match_cstring("++") || match_cstring("--"))
    {
      atom = stringf("%.*s%.*s", CSS(atom), 2, inp - 2);
    }
    else
    {
      break;
    }
  }
  
  if (prefix.s_length != 0)
  {
    atom = stringf("%.*s%.*s", CSS(prefix), CSS(atom));
  }
  
  return atom;
}
/*************************************************************************************************/
String convert_expression(int is_statement)
{
  const Operator *o;
  String left, right;
  
  left = convert_unary();
  
  if (is_statement && match_cstring(":"))
  {
    return stringf("%.*s:", CSS(left));
  }
  
  for (;;)
  {
    o = match_operator(numof(operator_table_binary), operator_table_binary);
    
    if (o == NULL) break;
    
    right = convert_unary();
    left = stringf("%.*s %.*s %.*s", CSS(left), o->o_equivalent_length, o->o_equivalent_string, CSS(right));
  }
  
  if (is_statement)
  {
    if (!match_cstring(";")) die("no ';'");

    left = stringf("%.*s;", CSS(left));
  }
  
  return left;
}
/*************************************************************************************************/
/* up to 16 nesting levels is enough for everyone */
#define NESTING nesting, "                                "
/*************************************************************************************************/
void convert_statement(int nesting)
{
  String expr;
  const char *kwstr;
  int kwlen;
  
  kwstr = inp;
  
  /**/ if (match_cstring("{"))
  {
    src += sprintf(src, "%.*s{\n", NESTING);

    while (!match_cstring("}"))
    {
      if (*inp == '\0') die("no '}'");
      
      convert_statement(nesting + 2);
    }

    src += sprintf(src, "%.*s}\n", NESTING);
  }
  else if (match_cstring(";"))
  {
    src += sprintf(src, "%.*s;\n", NESTING);
  }
  else if (match_cstring("extrn"))
  {
    while (*inp != '\0' && *inp != ';')
    {
      ++inp;
    }
    
    if (!match_cstring(";")) die("no ';'");
  }
  else if (match_cstring("auto"))
  {
    String var;
    
    src += sprintf(src, "%.*sW ", NESTING);
    
    for (;;)
    {
      spaces();
      var.s_string = inp;
      
      if (!isalpha(*inp)) die("no name");
      
      while (isalnum(*inp))
      {
        ++inp;
      }
      
      var.s_length = inp - var.s_string;
      
      src += sprintf(src, NAME_PREFIX"%.*s", CSS(var));
      
      if (match_cstring("["))
      {
        expr = convert_expression(0);
        
        if (!match_cstring("]")) die("no ']'");
        
        src += sprintf(src, "_[(%.*s) + 1], "NAME_PREFIX"%.*s = (W)"NAME_PREFIX"%.*s_", CSS(expr), CSS(var), CSS(var));
      }
      
      if (!match_cstring(",")) break;
      
      src += sprintf(src, ", ");
    }
    
    if (!match_cstring(";")) die("no ';'");

    src += sprintf(src, ";\n");
  }
  else if (match_cstring("if") || match_cstring("while") || match_cstring("switch"))
  {
    kwlen = inp - kwstr;
    expr = convert_expression(0);
    src += sprintf(src, "%.*s%.*s (%.*s)\n", NESTING, kwlen, kwstr, CSS(expr));
    convert_statement(nesting + 2);
  }
  else if (match_cstring("break;") || match_cstring("continue;") || match_cstring("default:"))
  {
    kwlen = inp - kwstr;
    src += sprintf(src, "%.*s%.*s\n", NESTING, kwlen, kwstr);
  }
  else if (match_cstring("else"))
  {
    src += sprintf(src, "%.*selse\n", NESTING);
    convert_statement(nesting + 2);
  }
  else
  {
    src += sprintf(src, "%.*s", NESTING);
    
    if (match_cstring("return"))
    {
      src += sprintf(src, "return");
      
      if (*inp == ';')
      {
        ++inp;
        
        src += sprintf(src, " 0;\n");
        return;
      }
    }
    else if (match_cstring("goto ") || match_cstring("case "))
    {
      src += sprintf(src, "%.*s ", 5, inp - 5);
    }
    
    expr = convert_expression(1);
    src += sprintf(src, "%.*s\n", CSS(expr));
  }
}
/*************************************************************************************************/
void convert_definition(void)
{
  String name, arg1, maxi, d;
  
  dcl += sprintf(dcl, "extern ");
  d.s_string = dcl;
  
  spaces();
  
  if (!isalpha(*inp)) die("no name");
  
  name.s_string = inp;
  
  while (isalnum(*inp))
  {
    ++inp;
  }
  
  name.s_length = inp - name.s_string;
  
  dcl += sprintf(dcl, "W "NAME_PREFIX"%.*s", CSS(name));
  
  if (match_cstring("("))
  {
    int no_stmtlist;
    
    save_function(name);
    
    dcl += sprintf(dcl, "(");
    
    spaces();
    
    if (*inp != ')')
    {
      for (;;)
      {
        arg1 = convert_expression(0);
        dcl += sprintf(dcl, "W %.*s", CSS(arg1));

        if (!match_cstring(",")) break;

        dcl += sprintf(dcl, ", ");
      }
    }
    
    if (!match_cstring(")")) die("no ')'");
    
    dcl += sprintf(dcl, ")");
    d.s_length = dcl - d.s_string;
    dcl += sprintf(dcl, ";\n");
    src += sprintf(src, "%.*s\n", CSS(d));
    
    spaces();
    no_stmtlist = (*inp != '{');
    if (no_stmtlist) src += sprintf(src, "{\n");
    convert_statement(0);
    if (no_stmtlist) src += sprintf(src, "}\n");
  }
  else
  {
    int is_vector, num;
    
    d.s_length = dcl - d.s_string;
    glb += sprintf(glb, "%.*s", CSS(d));
    dcl += sprintf(dcl, ";\n");
    
    if ((is_vector = match_cstring("[")))
    {
      if (match_cstring("]"))
      {
        glb += sprintf(glb, "_[]");
      }
      else
      {
        maxi = convert_expression(0);
        glb += sprintf(glb, "_[(%.*s) + 1]", CSS(maxi));
        
        if (!match_cstring("]")) die("no ']'");
      }
    }
    
    if (match_cstring(";")) goto end_global;

    glb += sprintf(glb, " = ");
    
    if (is_vector) glb += sprintf(glb, "\n{\n  ");
    
    num = 0;
    
    for (;;)
    {
      if (num >= 8)
      {
        glb += sprintf(glb, "\n  ");
        num = 0;
      }
      
      arg1 = convert_expression(0);
      glb += sprintf(glb, "%.*s", CSS(arg1));
      ++num;

      if (!match_cstring(",")) break;

      glb += sprintf(glb, ", ");
    }
    
    if (!match_cstring(";")) die("no ';'");
    
    if (is_vector) glb += sprintf(glb, "\n}");
   
  end_global:
    glb += sprintf(glb, ";\n");
    
    if (is_vector)
    {
      glb += sprintf(glb, "W "NAME_PREFIX"%.*s = w("NAME_PREFIX"%.*s_);\n", CSS(name), CSS(name));
    }
  }
}
/*************************************************************************************************/
int main(int argc, char *argv[])
{
  FILE *input_stream, *output_stream;
  
  if (argc != 3)
  {
    die("invalid arguments");
  }
  
  input_stream  = fopen(argv[1], "rb");
  output_stream = fopen(argv[2], "wb");
  
  if (input_stream  == NULL) die("no input");
  if (output_stream == NULL) die("can't output");
  
  fread(input, 1, sizeof(input) - 1, input_stream);
  fclose(input_stream);
  
  save_function(CSTRING("write"));
  save_function(CSTRING("read"));
  save_function(CSTRING("char"));
  save_function(CSTRING("lchar"));
  save_function(CSTRING("putchar"));
  save_function(CSTRING("getchar"));
  save_function(CSTRING("printn"));
  save_function(CSTRING("exit"));
  
  while (!match_cstring("\0"))
  {
    convert_definition();
  }
  
  fprintf(output_stream, "%s\n%s\n%s\n%s\n%s\n",
    "#include <stdint.h>\n"
    "#include <stdio.h>\n"
    "#include <stdlib.h>\n"
    "#include <string.h>\n"
    "#include <unistd.h>\n"
    "\n"
    "#define w(x) (W)(x)\n"
    "\n"
    "typedef int64_t  W;\n"
    "typedef uint64_t U;\n"
    "\n"
    "W "NAME_PREFIX"argv;\n"
    "\n"
    "W "NAME_PREFIX"write(W fd, W buff, W size)\n"
    "{\n"
    "  return write(fd, (void *)buff, size);\n"
    "}\n"
    "\n"
    "W "NAME_PREFIX"read(W fd, W buff, W size)\n"
    "{\n"
    "  return read(fd, (void *)buff, size);\n"
    "}\n"
    "\n"
    "W "NAME_PREFIX"char(W s, W i)\n"
    "{\n"
    "  return ((uint8_t *)s)[i];\n"
    "}\n"
    "\n"
    "W "NAME_PREFIX"lchar(W s, W i, W c)\n"
    "{\n"
    "  ((uint8_t *)s)[i] = (U)c;\n"
    "  return c;\n"
    "}\n"
    "\n"
    "W "NAME_PREFIX"putchar(W c0)\n"
    "{\n"
    "  U t, c;\n"
    "  \n"
    "  for (t = c0, c = c0; c != 0; c >>= 8)\n"
    "  {\n"
    "    putchar(c & 0xFF);\n"
    "  }\n"
    "  \n"
    "  return t;\n"
    "}\n"
    "\n"
    "W "NAME_PREFIX"getchar(void)\n"
    "{\n"
    "  int c;\n"
    "  \n"
    "  c = getchar();\n"
    "  return (c == EOF) ? 0 : c;\n"
    "}\n"
    "\n"
    "W "NAME_PREFIX"printn(W n, W b)\n"
    "{\n"
    "  W nn, d; \n"
    "  \n"
    "  if (n < 0)\n"
    "  {\n"
    "    n = -n;\n"
    "    putchar('-');\n"
    "  }\n"
    "  \n"
    "  nn = n / b;\n"
    "  \n"
    "  if (nn != 0)\n"
    "  {\n"
    "    "NAME_PREFIX"printn(nn, b);\n"
    "  }\n"
    "  \n"
    "  d = n % b;\n"
    "  putchar(((d >= 10) ? 'A' - 10 : '0') + d);\n"
    "}\n"
    "\n"
    "W "NAME_PREFIX"exit(void)\n"
    "{\n"
    "  exit(EXIT_SUCCESS);\n"
    "}\n",
    decls, globals, source,
    "int main(int argc, char *argv[])\n"
    "{\n"
    "  "NAME_PREFIX"argv = w(argv);\n"
    "  *(W*)"NAME_PREFIX"argv = argc - 1;\n"
    "  return "NAME_PREFIX"main();\n"
    "}\n");
  
  return 0;
}
