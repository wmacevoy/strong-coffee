import vend_checkedProofOwed

/-! The proofs of what vend_checked.proof.cpp claims, as gen/vend_checkedProofOwed.lean states it.
Trusted for nothing: checked against that statement and audited. Each takes the branches of
`vend_checked` in turn, as the C++ writes its conditions, and leaves the comparisons to
`bv_omega`. -/

namespace vend_checkedProof
namespace Claims

/-- Whatever the balance, the answer is "sell" unless the balance is short of the price. -/
theorem sells_unless_short (b price : BitVec 32) :
    ∃ x, (if b < price then some (({} : vend_checked), 1#32) else some ({}, 0#32)) = some ({}, x) ∧
      (x = 0#32 ∨ b < price) := by
  by_cases hp : b < price <;> simp [hp]

/-- Everything owed. -/
theorem owed : vend_checkedProof.Owed where
  a_drink_is_sold_exactly_when_it_is_paid_for_and_can_be_made_loop4 := by
    intro credit price pods water
    simp only [vend_checked.call, vend_checked.raw]
    by_cases h1 : credit < price
    · simp [h1]
    · by_cases h2 : pods = 0#32
      · simp [h1, h2]
      · by_cases h3 : 250#32 ≤ water
        · simp [h1, h2, h3]; bv_omega
        · simp [h1, h2, h3]; bv_omega
  a_full_machine_sells_whenever_the_credit_covers_the_price_loop3 := by
    intro coin price slot _ hs
    have hcases : slot = 0#32 ∨ slot = 1#32 ∨ slot = 2#32 ∨ slot = 3#32 := by bv_omega
    rcases hcases with rfl | rfl | rfl | rfl <;>
      simp [Credit.new, PodRack.new, PodRack.raw, WaterTank.new, Credit.insert_checked, Credit.getBalance_checked,
        PodRack.podsIn_checked, WaterTank.getLevel_checked, vend_checked.call, vend_checked.raw,
        Prooc.set_of_lt, Prooc.get_of_lt] <;>
      by_cases h1 : ((¬coin = 5#32 ∧ ¬coin = 10#32) ∧ ¬coin = 25#32) ∧ ¬coin = 100#32 <;>
      by_cases h2 : 1000#32 < coin
    all_goals first
      | (refine ⟨{ balance := 0#32 }, ⟨0#8, ?_⟩, sells_unless_short _ price⟩; simp [h1]; done)
      | (refine ⟨{ balance := 0#32 }, ⟨0#8, ?_⟩, sells_unless_short _ price⟩; simp [h1, h2]; done)
      | (refine ⟨{ balance := coin }, ⟨1#8, ?_⟩, sells_unless_short _ price⟩; simp [h1, h2]; done)

end Claims
end vend_checkedProof
