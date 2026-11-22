/*
  What is claimed of WaterTank, as a test that cannot be run, for every amount drawn and every
  amount poured in after. Lean checks a proof of it (WaterTank.proof-claims.lean).
*/
#include <cstdint>

#include "src/strong/watertank.h"

#include "forall.h"

/* Pouring water into a full tank leaves it full, whatever is poured. */
PROOF( a_full_tank_stays_full )
{
  for ( uint32_t ml : all<uint32_t>() ) {
    Strong::WaterTank tank;
    tank.fill_checked( ml );
    PROVE( tank.getLevel_checked() == 2000 );
  }
}

/* Pouring in at least what was drawn fills the tank again. */
PROOF( pouring_back_what_was_drawn_fills_it )
{
  for ( uint32_t drawn : all<uint32_t>() ) {
    for ( uint32_t ml : all<uint32_t>() ) {
      Strong::WaterTank tank;
      tank.draw_checked( drawn );
      tank.fill_checked( ml );
      PROVE( ml < drawn || tank.getLevel_checked() == 2000 );
    }
  }
}
