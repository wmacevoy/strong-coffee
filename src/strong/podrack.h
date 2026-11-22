/*
  PodRack: the pods in the machine's four slots. Its rule: a slot holds at most 10.
*/
#pragma once
#include <cstdint>

namespace Strong {

class PodRack
{
public:
  PodRack()
  {
    count[0] = 10;
    count[1] = 10;
    count[2] = 10;
    count[3] = 10;
  }

  /* How many pods are in a slot (none, for a slot there is not). */
  uint32_t podsIn_checked( uint32_t slot ) const
  {
    if ( slot >= 4 ) return 0;
    return count[slot];
  }

  /* One pod taken from a slot, to brew. */
  bool take_checked( uint32_t slot )
  {
    if ( slot >= 4 ) return false;
    count[slot] = count[slot] - 1;
    return true;
  }

  /* Pods put in a slot. */
  bool restock_checked( uint32_t slot, uint32_t pods )
  {
    if ( slot >= 4 ) return false;
    count[slot] = count[slot] + pods;
    return true;
  }

  /* No slot holds more than 10. */
  bool invariant() const { return count[0] <= 10 && count[1] <= 10 && count[2] <= 10 && count[3] <= 10; }

private:
  uint32_t count[4];
};

}
