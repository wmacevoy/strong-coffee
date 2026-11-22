// A pod coffee machine, as it might first be written: it works for the cases tried.
//
// Commands, one per line, on standard input:
//   coin CENTS        put a coin in (5, 10, 25 or 100)
//   buy SLOT          buy the drink in slot 0 to 3
//   refund            give back what has been put in
//   restock SLOT N    put N pods in a slot (a slot holds 10)
//   fill ML           pour water into the tank (it holds 2000 ml; a cup is 250)
//   status            say what the machine holds

// Stage 2: safe. Every number is unsigned, so its arithmetic always has a meaning (it wraps); every
// index is tested before it is used; text is written with its size. Still messy, and still wrong.

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

uint32_t credit = 0;
uint32_t pods[4] = { 10, 10, 10, 10 };
uint32_t water = 2000;
uint32_t prices[4] = { 150, 175, 200, 125 };
const char* names[4] = { "espresso", "americano", "caramel macchiato", "tea" };
char display[64];

void show( const char* text )
{
  snprintf( display, sizeof display, "%s", text );
  printf( "%s\n", display );
}

/* A number as the customer typed it, made a 32-bit one: what is too big or negative wraps, which
   is defined. strtoul, unlike sscanf's %d, has a meaning for every input. */
uint32_t number( const char* text )
{
  return (uint32_t) strtoul( text, nullptr, 10 );
}

int main()
{
  char line[64];
  while ( fgets( line, sizeof line, stdin ) ) {
    char word[16], first[24] = "0", second[24] = "0";
    if ( sscanf( line, "%15s %23s %23s", word, first, second ) < 1 ) continue;
    uint32_t a = number( first ), b = number( second );

    if ( strcmp( word, "coin" ) == 0 ) {
      credit += a;
      printf( "credit %u\n", credit );
    } else if ( strcmp( word, "buy" ) == 0 ) {
      if ( a >= 4 ) {
        show( "no such slot" );
      } else if ( credit < prices[a] ) {
        show( "not enough credit" );
      } else if ( pods[a] < 0 ) {
        show( "sold out" );
      } else if ( water > 250 ) {
        pods[a]--;
        water -= 250;
        uint32_t change = credit - prices[a];
        credit -= prices[a];
        char text[64];
        snprintf( text, sizeof text, "enjoy your %s", names[a] );
        show( text );
        printf( "change %u\n", change );
      } else {
        show( "out of water" );
      }
    } else if ( strcmp( word, "refund" ) == 0 ) {
      printf( "change %u\n", credit );
      credit = 0;
    } else if ( strcmp( word, "restock" ) == 0 ) {
      if ( a >= 4 ) {
        show( "no such slot" );
      } else {
        pods[a] += b;
        printf( "slot %u has %u\n", a, pods[a] );
      }
    } else if ( strcmp( word, "fill" ) == 0 ) {
      water += a;
      if ( water > 2000 ) water = 2000;
      printf( "water %u\n", water );
    } else if ( strcmp( word, "status" ) == 0 ) {
      printf( "credit %u water %u pods %u %u %u %u\n", credit, water, pods[0], pods[1], pods[2], pods[3] );
    } else {
      show( "unknown command" );
    }
  }
  return 0;
}
