/*
  WaterTank: the water for brewing. Its rule: it holds at most 2000 ml.
*/
#pragma once
#include <cstdint>

namespace Strong {

class WaterTank
{
public:
  WaterTank() { level = 2000; }

  uint32_t getLevel() const { return level; }

  /* Water poured in; what does not fit runs over. */
  void fill( uint32_t ml )
  {
    level = level + ml;
    if ( level > 2000 ) level = 2000;
  }

  /* Water drawn for a cup, if there is that much. */
  bool draw( uint32_t ml )
  {
    if ( level < ml ) return false;
    level = level - ml;
    return true;
  }

  /* It never holds more than 2000 ml. */
  bool invariant() const { return level <= 2000; }

private:
  uint32_t level;
};

}
