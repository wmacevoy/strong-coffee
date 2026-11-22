// tests/counterexamples.cpp: each error the proofs found, as the one input that shows it. A proof
// that does not go through says where to look; one input that breaks the rule says the code is
// wrong, not the proof. Each line prints "holds" or "FALSE", and the program fails if any is false.
// Every one of these is a sequence of calls a domain must take, from a state its invariant allows.

#include <cstdint>
#include <cstdio>

#include "strong/credit.h"
#include "strong/podrack.h"
#include "strong/vend.h"
#include "strong/watertank.h"

static int wrong = 0;

static void say( bool holds, const char* what )
{
  printf( "%-5s  %s\n", holds ? "holds" : "FALSE", what );
  if ( !holds ) wrong++;
}

int main()
{
  say( Strong::vend_checked( 200, 150, 0, 2000 ) != 0, "vend: a drink is not sold from an empty slot (paid, no pod, water)" );
  say( Strong::vend_checked( 200, 150, 5, 250 ) == 0, "vend: a drink is sold with exactly a cup of water left (250 ml)" );
  {
    Strong::Credit credit;
    credit.insert_checked( 3 );
    say( credit.getBalance_checked() == 0, "Credit: a 3-cent coin is refused" );
  }
  {
    Strong::Credit credit;
    for ( int i = 0; i < 11; i++ ) credit.insert_checked( 100 );
    say( credit.invariant(), "Credit: eleven dollar coins leave at most 1000 cents" );
  }
  {
    Strong::Credit credit;
    credit.insert_checked( 100 );
    credit.pay_checked( 50 );
    say( credit.getBalance_checked() == 0, "Credit: once a price is paid, nothing is left to be given back again" );
  }
  {
    Strong::Credit credit;
    credit.pay_checked( 1 );
    say( credit.invariant(), "Credit: a price more than the balance leaves at most 1000 cents" );
  }
  {
    Strong::PodRack rack;
    for ( int i = 0; i < 11; i++ ) rack.take_checked( 0 );
    say( rack.invariant(), "PodRack: eleven pods taken from a slot of ten leave at most 10 in it" );
  }
  {
    Strong::PodRack rack;
    rack.restock_checked( 0, 1 );
    say( rack.invariant(), "PodRack: a pod put in a full slot leaves at most 10 in it" );
  }
  {
    Strong::WaterTank tank;
    tank.fill_checked( 4294967295u );
    say( tank.getLevel_checked() == 2000, "WaterTank: a full tank, poured into, stays full (4294967295 ml)" );
  }
  if ( wrong ) printf( "counterexamples: %d rules broken\n", wrong );
  else printf( "counterexamples: none: every rule holds on these inputs\n" );
  return wrong ? 1 : 0;
}
