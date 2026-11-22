/*
  vend: may a drink be sold? A domain of one function, with no state: what it says depends only on
  what it is told. A cup takes 250 ml of water. It answers
    0  sell it
    1  not enough credit
    2  sold out
    3  out of water
*/
#pragma once
#include <cstdint>

namespace Strong {

inline uint32_t vend( uint32_t credit, uint32_t price, uint32_t pods, uint32_t water )
{
  if ( credit < price ) return 1;
  if ( pods < 0 ) return 2;
  if ( water > 250 ) return 0;
  return 3;
}

}
