/*
  What is claimed of vend, and of the machine's domains together, as tests that cannot be run:
  each loop is over every 32-bit number. The prover reads them as statements about every round,
  and Lean checks a proof of them (vend_checked.proof-claims.lean). A proof file is of a set: its
  own domain, and every domain proved before it (Credit, PodRack, WaterTank).
*/
#include <cstdint>

#include "src/strong/credit.h"
#include "src/strong/podrack.h"
#include "src/strong/vend.h"
#include "src/strong/watertank.h"

#include "forall.h"

/* A drink is sold exactly when it is paid for, there is a pod for it, and there is water for a
   cup (250 ml). */
PROOF( a_drink_is_sold_exactly_when_it_is_paid_for_and_can_be_made )
{
  for ( uint32_t credit : all<uint32_t>() ) {
    for ( uint32_t price : all<uint32_t>() ) {
      for ( uint32_t pods : all<uint32_t>() ) {
        for ( uint32_t water : all<uint32_t>() ) {
          /* sold only when paid for, with a pod, and water for a cup */
          PROVE( Strong::vend_checked( credit, price, pods, water ) != 0 || ( credit >= price && pods > 0 && water >= 250 ) );
          /* and then always sold */
          PROVE( Strong::vend_checked( credit, price, pods, water ) == 0 || credit < price || pods == 0 || water < 250 );
        }
      }
    }
  }
}

/* The domains together: a machine just filled, whatever coin is put in, sells any drink the
   credit covers, from any slot. */
PROOF( a_full_machine_sells_whenever_the_credit_covers_the_price )
{
  for ( uint32_t coin : all<uint32_t>() ) {
    for ( uint32_t price : all<uint32_t>() ) {
      for ( uint32_t slot : all<uint32_t>( 0, 3 ) ) {
        Strong::Credit credit;
        Strong::PodRack rack;
        Strong::WaterTank tank;
        credit.insert_checked( coin );
        PROVE( Strong::vend_checked( credit.getBalance_checked(), price, rack.podsIn_checked( slot ), tank.getLevel_checked() ) == 0
               || credit.getBalance_checked() < price );
      }
    }
  }
}
