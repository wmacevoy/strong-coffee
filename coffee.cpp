// A pod coffee machine, as it might first be written: it works for the cases tried.
//
// Commands, one per line, on standard input:
//   coin CENTS        put a coin in (5, 10, 25 or 100)
//   buy SLOT          buy the drink in slot 0 to 3
//   refund            give back what has been put in
//   restock SLOT N    put N pods in a slot (a slot holds 10)
//   fill ML           pour water into the tank (it holds 2000 ml; a cup is 250)
//   status            say what the machine holds

#include <cstdio>
#include <cstdlib>
#include <cstring>

int credit = 0;
int pods[4] = { 10, 10, 10, 10 };
int water = 2000;
int prices[4] = { 150, 175, 200, 125 };
const char* names[4] = { "espresso", "americano", "caramel macchiato", "tea" };
char display[24];

void show( const char* text )
{
  strcpy( display, text );
  printf( "%s\n", display );
}

int main()
{
  char line[64];
  while ( fgets( line, sizeof line, stdin ) ) {
    char word[16];
    int a = 0, b = 0;
    if ( sscanf( line, "%15s %d %d", word, &a, &b ) < 1 ) continue;

    if ( strcmp( word, "coin" ) == 0 ) {
      credit += a;
      printf( "credit %d\n", credit );
    } else if ( strcmp( word, "buy" ) == 0 ) {
      if ( credit < prices[a] ) {
        show( "not enough credit" );
      } else if ( pods[a] < 0 ) {
        show( "sold out" );
      } else if ( water > 250 ) {
        pods[a]--;
        water -= 250;
        int change = credit - prices[a];
        credit -= prices[a];
        char text[64];
        sprintf( text, "enjoy your %s", names[a] );
        show( text );
        printf( "change %d\n", change );
      } else {
        show( "out of water" );
      }
    } else if ( strcmp( word, "refund" ) == 0 ) {
      printf( "change %d\n", credit );
      credit = 0;
    } else if ( strcmp( word, "restock" ) == 0 ) {
      pods[a] += b;
      printf( "slot %d has %d\n", a, pods[a] );
    } else if ( strcmp( word, "fill" ) == 0 ) {
      water += a;
      if ( water > 2000 ) water = 2000;
      printf( "water %d\n", water );
    } else if ( strcmp( word, "status" ) == 0 ) {
      printf( "credit %d water %d pods %d %d %d %d\n", credit, water, pods[0], pods[1], pods[2], pods[3] );
    } else {
      show( "unknown command" );
    }
  }
  return 0;
}
