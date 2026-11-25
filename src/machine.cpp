// The pod coffee machine's edge: it reads commands and prints what the machine says. The rules are
// the machine's (src/strong/machine.h), and its parts': this file only reads, asks it, and
// writes. It is not proved, and it is safe (make safe).
//
// Commands, one per line, on standard input:
//   coin CENTS        put a coin in (5, 10, 25 or 100)
//   buy SLOT          buy the drink in slot 0 to 3
//   refund            give back what has been put in
//   restock SLOT N    put N pods in a slot (a slot holds 10)
//   fill ML           pour water into the tank (it holds 2000 ml; a cup is 250)
//   status            say what the machine holds

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "strong/machine.h"

namespace {

const uint32_t prices[4] = { 150, 175, 200, 125 };
const char* const names[4] = { "espresso", "americano", "caramel macchiato", "tea" };

/* A number as the customer typed it, made a 32-bit one: what is too big or negative wraps. */
uint32_t number( const char* text ) { return (uint32_t) strtoul( text, nullptr, 10 ); }

}

int main()
{
  Strong::Machine machine;

  char line[64];
  while ( fgets( line, sizeof line, stdin ) ) {
    char word[16], first[24] = "0", second[24] = "0";
    if ( sscanf( line, "%15s %23s %23s", word, first, second ) < 1 ) continue;
    uint32_t a = number( first ), b = number( second );

    if ( strcmp( word, "coin" ) == 0 ) {
      if ( !machine.insert_checked( a ) ) printf( "coin returned\n" );
      printf( "credit %u\n", machine.getBalance_checked() );
    } else if ( strcmp( word, "buy" ) == 0 ) {
      if ( a >= 4 ) {
        printf( "no such slot\n" );
        continue;
      }
      switch ( machine.buy_checked( a, prices[a] ) ) {
        case 0:
          printf( "enjoy your %s\n", names[a] );
          printf( "change %u\n", machine.takeChange_checked() );
          break;
        case 1: printf( "not enough credit\n" ); break;
        case 2: printf( "sold out\n" ); break;
        default: printf( "out of water\n" ); break;
      }
    } else if ( strcmp( word, "refund" ) == 0 ) {
      printf( "change %u\n", machine.refund_checked() );
    } else if ( strcmp( word, "restock" ) == 0 ) {
      if ( a >= 4 ) printf( "no such slot\n" );
      else if ( !machine.restock_checked( a, b ) ) printf( "slot %u has room for %u\n", a, 10 - machine.podsIn_checked( a ) );
      else printf( "slot %u has %u\n", a, machine.podsIn_checked( a ) );
    } else if ( strcmp( word, "fill" ) == 0 ) {
      machine.fill_checked( a );
      printf( "water %u\n", machine.getLevel_checked() );
    } else if ( strcmp( word, "status" ) == 0 ) {
      printf( "credit %u water %u pods %u %u %u %u\n", machine.getBalance_checked(), machine.getLevel_checked(), machine.podsIn_checked( 0 ),
              machine.podsIn_checked( 1 ), machine.podsIn_checked( 2 ), machine.podsIn_checked( 3 ) );
    } else {
      printf( "unknown command\n" );
    }
  }
  return 0;
}
