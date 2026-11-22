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

  /* A coin put in. */
  void insert_checked( uint32_t cents ) { balance = balance + cents; }

  uint32_t getBalance_checked() const { return balance; }

  /* A price paid from the balance: what comes back is the change. */
  uint32_t pay_checked( uint32_t price )
  {
    balance = balance - price;
    return balance;
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
