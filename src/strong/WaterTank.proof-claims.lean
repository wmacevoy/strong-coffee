import WaterTankProofOwed

/-! The proofs of what WaterTank.proof.cpp claims, as gen/WaterTankProofOwed.lean states it.
Trusted for nothing: checked against that statement and audited. Each case of each `if` is taken
in turn (`by_cases`), as the C++ writes its condition, and the arithmetic is left to `bv_omega`. -/

namespace WaterTankProof
namespace Claims

/-- Everything owed. -/
theorem owed : WaterTankProof.Owed where
  a_full_tank_stays_full_loop1 := by
    intro ml
    simp only [WaterTank.new, WaterTank.fill_checked, WaterTank.getLevel_checked]
    by_cases h : ml > 2000#32 - 2000#32 <;> simp_all <;> bv_omega
  pouring_back_what_was_drawn_fills_it_loop2 := by
    intro drawn ml
    simp only [WaterTank.new, WaterTank.draw_checked, WaterTank.fill_checked, WaterTank.getLevel_checked]
    by_cases hd : 2000#32 < drawn
    · simp [hd]
      by_cases h : 0#32 < ml
      · simp [h]
      · simp [h]; bv_omega
    · simp [hd]
      by_cases h : 2000#32 - (2000#32 - drawn) < ml
      · simp [h]
      · simp [h]; bv_omega

end Claims
end WaterTankProof
