import MachineProofOwed

/-! The proof of what Machine.proof.cpp claims, as gen/MachineProofOwed.lean states it. Trusted for
nothing: checked against that statement and audited. A machine just made is a known state, so each
case is computed: the slot, one of four, and the coin, one of the four the credit takes (its
balance is then that coin) or any other (its balance stays 0). What is left is one test of the
price, taken both ways (`split`), with the arithmetic left to `bv_omega`. -/

namespace MachineProof
namespace Claims

/-- Everything owed. -/
theorem owed : MachineProof.Owed where
  a_full_machine_sells_exactly_when_the_credit_covers_the_price_loop3 := by
    intro coin price slot _ hs
    have hk : slot = 0#32 ∨ slot = 1#32 ∨ slot = 2#32 ∨ slot = 3#32 := by bv_omega
    by_cases hv : coin = 5#32 ∨ coin = 10#32 ∨ coin = 25#32 ∨ coin = 100#32
    · -- a coin the credit takes
      rcases hv with rfl | rfl | rfl | rfl <;> rcases hk with rfl | rfl | rfl | rfl <;>
      · simp [Machine.new, Credit.new, PodRack.new, WaterTank.new, PodRack.raw, Prooc.set_of_lt, Prooc.get_of_lt,
          Machine.insert_checked, Credit.insert_checked, Credit.getBalance_checked, Machine.getBalance_checked,
          Machine.buy_checked, PodRack.podsIn_checked, WaterTank.getLevel_checked, PodRack.take_checked,
          WaterTank.draw_checked, Credit.pay_checked, Machine.podsIn_checked, Machine.getLevel_checked]
        split <;> simp_all <;> bv_omega
    · -- any other coin: refused, and the credit stays 0
      have hb : ((¬coin = 5#32 ∧ ¬coin = 10#32) ∧ ¬coin = 25#32) ∧ ¬coin = 100#32 := by
        simp only [not_or] at hv; exact ⟨⟨⟨hv.1, hv.2.1⟩, hv.2.2.1⟩, hv.2.2.2⟩
      rcases hk with rfl | rfl | rfl | rfl <;>
      · simp [hb, Machine.new, Credit.new, PodRack.new, WaterTank.new, PodRack.raw, Prooc.set_of_lt, Prooc.get_of_lt,
          Machine.insert_checked, Credit.insert_checked, Credit.getBalance_checked, Machine.getBalance_checked,
          Machine.buy_checked, PodRack.podsIn_checked, WaterTank.getLevel_checked, PodRack.take_checked,
          WaterTank.draw_checked, Credit.pay_checked, Machine.podsIn_checked, Machine.getLevel_checked]
        split <;> simp_all <;> bv_omega

end Claims
end MachineProof
