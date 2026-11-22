// The pod coffee machine's edge: it reads commands and prints what the machine says. The rules are
// the domains' (src/strong/): this file only reads, asks them, and writes. It is not proved, and
// it is safe (make safe).
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

#include "strong/credit.h"
#include "strong/podrack.h"
#include "strong/vend.h"
#include "strong/watertank.h"

namespace {

const uint32_t prices[4] = { 150, 175, 200, 125 };
const char* const names[4] = { "espresso", "americano", "caramel macchiato", "tea" };

/* A number as the customer typed it, made a 32-bit one: what is too big or negative wraps. */
uint32_t number( const char* text ) { return (uint32_t) strtoul( text, nullptr, 10 ); }

}

int main()
{
  Strong::Credit credit;
  Strong::PodRack rack;
  Strong::WaterTank tank;

  char line[64];
  while ( fgets( line, sizeof line, stdin ) ) {
    char word[16], first[24] = "0", second[24] = "0";
    if ( sscanf( line, "%15s %23s %23s", word, first, second ) < 1 ) continue;
    uint32_t a = number( first ), b = number( second );

    if ( strcmp( word, "coin" ) == 0 ) {
      credit.insert( a );
      printf( "credit %u\n", credit.getBalance() );
    } else if ( strcmp( word, "buy" ) == 0 ) {
      if ( a >= 4 ) {
        printf( "no such slot\n" );
        continue;
      }
      switch ( Strong::vend( credit.getBalance(), prices[a], rack.left( a ), tank.getLevel() ) ) {
        case 0:
          rack.take( a );
          tank.draw( 250 );
          printf( "enjoy your %s\n", names[a] );
          printf( "change %u\n", credit.pay( prices[a] ) );
          break;
        case 1: printf( "not enough credit\n" ); break;
        case 2: printf( "sold out\n" ); break;
        default: printf( "out of water\n" ); break;
      }
    } else if ( strcmp( word, "refund" ) == 0 ) {
      printf( "change %u\n", credit.refund() );
    } else if ( strcmp( word, "restock" ) == 0 ) {
      if ( rack.restock( a, b ) ) printf( "slot %u has %u\n", a, rack.left( a ) );
      else printf( "no such slot\n" );
    } else if ( strcmp( word, "fill" ) == 0 ) {
      tank.fill( a );
      printf( "water %u\n", tank.getLevel() );
    } else if ( strcmp( word, "status" ) == 0 ) {
      printf( "credit %u water %u pods %u %u %u %u\n", credit.getBalance(), tank.getLevel(), rack.left( 0 ), rack.left( 1 ),
              rack.left( 2 ), rack.left( 3 ) );
    } else {
      printf( "unknown command\n" );
    }
  }
  return 0;
}
