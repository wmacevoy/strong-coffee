/*
  What is claimed of Credit, as a test that cannot be run: for every coin and every price. Lean
  checks a proof of it (Credit.proof-claims.lean).
*/
#include <cstdint>

#include "src/strong/credit.h"

#include "forall.h"

/* Into a new credit, a coin of 5, 10, 25 or 100 cents is taken, and any other is refused. */
PROOF( only_the_four_coins_are_taken )
{
  for ( uint32_t coin : all<uint32_t>() ) {
    Strong::Credit credit;
    credit.insert_checked( coin );
    PROVE( credit.getBalance_checked() == ( ( coin == 5 || coin == 10 || coin == 25 || coin == 100 ) ? coin : 0 ) );
  }
}

/* A price the coin covers is paid, and nothing is left behind to be given back twice. */
PROOF( nothing_is_left_once_paid )
{
  for ( uint32_t coin : all<uint32_t>() ) {
    for ( uint32_t price : all<uint32_t>() ) {
      Strong::Credit credit;
      credit.insert_checked( coin );
      credit.pay_checked( price );
      PROVE( credit.getBalance_checked() == 0 || price > coin );
    }
  }
}
