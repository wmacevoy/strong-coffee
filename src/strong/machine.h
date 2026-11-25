/*
  Machine: the coffee machine whole. It has a Credit, a PodRack and a WaterTank, and is the one
  home of the rules that span them. Until this stage the edge kept those rules, and the edge is
  not proved:

  - a drink is sold only when the credit covers its price, its slot has a pod, and the tank has a
    cup of water; then one pod, one cup and the price are taken, and the rest is change (buy);
  - the machine owes at most 10.00 at once: the credit not yet spent and the change not yet given
    back (the invariant).

  Each part is proved alone and knows nothing of the others or of drinks. The machine changes a
  part only by that part's own methods, so each part keeps its own rule here too.
*/
#pragma once
#include <cstdint>

#include "credit.h"
#include "podrack.h"
#include "watertank.h"

namespace Strong {

class Machine
{
public:
  static const uint32_t CUP = 250;    /* ml of water a cup takes */
  static const uint32_t OWED = 1000;  /* the most the machine owes at once, in cents */

  Machine() : credit(), rack(), tank(), change( 0 ) {}

  /* A coin put in: taken if the credit takes it and the machine would owe no more than 10.00. */
  bool insert_checked( uint32_t cents )
  {
    if ( cents > OWED - credit.getBalance_checked() - change ) return false;
    uint32_t before = credit.getBalance_checked();
    credit.insert_checked( cents );
    return credit.getBalance_checked() != before;
  }

  /* A drink from a slot, at a price. It answers
       0  sold: a pod and a cup of water are taken, the price is paid, the rest is change
       1  not enough credit
       2  sold out (or no such slot)
       3  out of water
     and changes nothing unless it is sold. */
  uint32_t buy_checked( uint32_t slot, uint32_t price )
  {
    uint32_t paid = credit.getBalance_checked();
    if ( paid < price ) return 1;
    if ( rack.podsIn_checked( slot ) == 0 ) return 2;
    if ( tank.getLevel_checked() < CUP ) return 3;
    rack.take_checked( slot );
    tank.draw_checked( CUP );
    credit.pay_checked( price );
    change = change + ( paid - price );
    return 0;
  }

  /* The change of what was sold, given back. */
  uint32_t takeChange_checked()
  {
    uint32_t c = change;
    change = 0;
    return c;
  }

  /* Everything owed, given back: the credit, and any change. */
  uint32_t refund_checked()
  {
    uint32_t all = credit.getBalance_checked() + change;
    credit.refund_checked();
    change = 0;
    return all;
  }

  /* Pods put in a slot, if they fit (the rack's own rule). */
  bool restock_checked( uint32_t slot, uint32_t pods )
  {
    if ( slot >= 4 ) return false;
    uint32_t before = rack.podsIn_checked( slot );
    rack.restock_checked( slot, pods );
    return pods == 0 || rack.podsIn_checked( slot ) != before;
  }

  /* Water poured in; what does not fit runs over (the tank's own rule). */
  void fill_checked( uint32_t ml ) { tank.fill_checked( ml ); }

  uint32_t getBalance_checked() const { return credit.getBalance_checked(); }
  uint32_t podsIn_checked( uint32_t slot ) const { return rack.podsIn_checked( slot ); }
  uint32_t getLevel_checked() const { return tank.getLevel_checked(); }

  /* It never owes more than 10.00: the credit and the change together. */
  bool invariant() const { return change <= OWED - credit.getBalance_checked(); }

private:
  Credit credit;
  PodRack rack;
  WaterTank tank;
  uint32_t change;
};

}
