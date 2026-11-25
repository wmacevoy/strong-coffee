/*
  What is claimed of Machine, as a test that cannot be run: each loop is over every 32-bit number.
  The prover reads it as a statement about every round, and Lean checks a proof of it
  (Machine.proof-claims.lean).
*/
#include <cstdint>

#include "src/strong/machine.h"

#include "forall.h"

/* A machine just filled, whatever coin is put in, sells any drink the credit covers, from any slot:
   one pod, one cup of water and the whole credit are taken. And a drink the credit does not cover
   takes nothing. */
PROOF( a_full_machine_sells_exactly_when_the_credit_covers_the_price )
{
  for ( uint32_t coin : all<uint32_t>() ) {
    for ( uint32_t price : all<uint32_t>() ) {
      for ( uint32_t slot : all<uint32_t>( 0, 3 ) ) {
        /* two machines given the same coin: one shows what was paid, the other buys */
        Strong::Machine paid;
        paid.insert_checked( coin );
        Strong::Machine machine;
        machine.insert_checked( coin );
        machine.buy_checked( slot, price );
        PROVE( paid.getBalance_checked() < price
               || ( machine.podsIn_checked( slot ) == 9 && machine.getLevel_checked() == 1750 && machine.getBalance_checked() == 0 ) );
        PROVE( paid.getBalance_checked() >= price
               || ( machine.podsIn_checked( slot ) == 10 && machine.getLevel_checked() == 2000
                    && machine.getBalance_checked() == paid.getBalance_checked() ) );
      }
    }
  }
}
