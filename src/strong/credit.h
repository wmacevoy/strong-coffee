/*
  Credit: the money a customer has put in and not yet spent. Its rule: it never holds more than
  10.00 (1000 cents), the most the machine will take. Nothing here knows about coins being
  dropped in a slot or change rattling out: that is the edge's (src/machine.cpp).
*/
#pragma once
#include <cstdint>

namespace Strong {

class Credit
{
public:
  Credit() { balance = 0; }

  /* A coin put in: 5, 10, 25 or 100 cents, while the balance stays at most 1000. Any other is
     refused: it is not taken, and comes back out. */
  bool insert_checked( uint32_t cents )
  {
    if ( cents != 5 && cents != 10 && cents != 25 && cents != 100 ) return false;
    if ( cents > 1000 - balance ) return false;
    balance = balance + cents;
    return true;
  }

  uint32_t getBalance_checked() const { return balance; }

  /* A price paid from the balance: what comes back is the change, and nothing is left. A price
     more than the balance is not paid: nothing changes, and no change comes back. */
  uint32_t pay_checked( uint32_t price )
  {
    if ( price > balance ) return 0;
    uint32_t change = balance - price;
    balance = 0;
    return change;
  }

  /* Everything put in, given back. */
  uint32_t refund_checked()
  {
    uint32_t all = balance;
    balance = 0;
    return all;
  }

  /* It never holds more than the machine takes. */
  bool invariant() const { return balance <= 1000; }

private:
  uint32_t balance;
};

}
