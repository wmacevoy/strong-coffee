import CreditProofOwed

/-! The proofs of what Credit.proof.cpp claims, as gen/CreditProofOwed.lean states it. Trusted
for nothing: checked against that statement and audited. Each runs the methods (`simp`), takes
each branch (`split`), and leaves the comparisons to `bv_omega`. -/

namespace CreditProof
namespace Claims

macro "run_credit" : tactic =>
  `(tactic| (intros
             simp only [Credit.new, Credit.insert_checked, Credit.pay_checked, Credit.getBalance_checked]
             all_goals (repeat' split)
             all_goals simp_all
             all_goals (try bv_omega)
             all_goals (repeat' split)
             all_goals (try simp_all)
             all_goals (try bv_omega)))

/-- Everything owed. -/
theorem owed : CreditProof.Owed where
  only_the_four_coins_are_taken_loop1 := by run_credit
  nothing_is_left_once_paid_loop2 := by
    intro coin price
    simp only [Credit.new, Credit.insert_checked, Credit.pay_checked, Credit.getBalance_checked]
    by_cases hp : coin < price
    · by_cases h1 : coin = 5#32 ∨ coin = 10#32 ∨ coin = 25#32 ∨ coin = 100#32
      · rcases h1 with rfl | rfl | rfl | rfl <;> simp_all
      · by_cases h0 : 0#32 < price <;> simp_all
    · by_cases h1 : coin = 5#32 ∨ coin = 10#32 ∨ coin = 25#32 ∨ coin = 100#32
      · rcases h1 with rfl | rfl | rfl | rfl <;> simp_all <;> rw [ite_eq_right (by bv_omega)] <;> simp
      · by_cases h0 : 0#32 < price <;> simp_all

end Claims
end CreditProof
