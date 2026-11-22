import CreditOwed

/-! The proofs of what is owed of Credit: that no method commits a memory error, and that each
keeps the invariant, never more than 1000 cents. Nothing here is trusted: `Credit.Owed`
(generated from the class) says what must be proved, and `owed`, at the end, is a proof of it,
which the audit and Lean's kernel check. Each proof opens the method (`simp`), takes each branch
(`split`), and leaves comparisons of 32-bit numbers to `bv_omega`. -/

namespace Credit
namespace Claims

theorem new_safe : Credit.new.isSome := by simp [Credit.new]

theorem new_inv : ∀ (me : Credit), Credit.new = some me → Inv me := by
  intro me h; simp [Credit.new] at h; subst h; simp [Inv]

theorem insert_checked_safe : ∀ (me : Credit) (cents : BitVec 32), Inv me → (Credit.insert_checked me cents).isSome := by
  intro me cents _; simp only [Credit.insert_checked]; split <;> (try split) <;> simp

theorem insert_checked_inv : ∀ (me : Credit) (cents : BitVec 32) (me' : Credit) (r : BitVec 8),
    Inv me → Credit.insert_checked me cents = some (me', r) → Inv me' := by
  intro me cents me' r hinv h
  simp only [Credit.insert_checked] at h
  split at h
  · simp at h; rw [← h.1]; exact hinv
  · split at h
    · simp at h; rw [← h.1]; exact hinv
    · simp at h; rw [← h.1]; simp only [Inv] at *; bv_omega

theorem getBalance_checked_safe : ∀ (me : Credit), Inv me → (Credit.getBalance_checked me).isSome := by
  intro me _; simp [Credit.getBalance_checked]

theorem getBalance_checked_same : ∀ (me me' : Credit) (r : BitVec 32), Credit.getBalance_checked me = some (me', r) → me' = me := by
  intro me me' r h; simp [Credit.getBalance_checked] at h; exact h.1.symm

theorem pay_checked_safe : ∀ (me : Credit) (price : BitVec 32), Inv me → (Credit.pay_checked me price).isSome := by
  intro me price _; simp only [Credit.pay_checked]; split <;> simp

theorem pay_checked_inv : ∀ (me : Credit) (price : BitVec 32) (me' : Credit) (r : BitVec 32),
    Inv me → Credit.pay_checked me price = some (me', r) → Inv me' := by
  intro me price me' r hinv h
  simp only [Credit.pay_checked] at h
  split at h
  · simp at h; rw [← h.1]; exact hinv
  · simp at h; rw [← h.1]; simp [Inv]

theorem refund_checked_safe : ∀ (me : Credit), Inv me → (Credit.refund_checked me).isSome := by
  intro me _; simp [Credit.refund_checked]

theorem refund_checked_inv : ∀ (me : Credit) (me' : Credit) (r : BitVec 32),
    Inv me → Credit.refund_checked me = some (me', r) → Inv me' := by
  intro me me' r _ h; simp [Credit.refund_checked] at h; rw [← h.1]; simp [Inv]

/-- Everything owed. -/
theorem owed : Credit.Owed :=
  { new_safe, new_inv, insert_checked_safe, insert_checked_inv, getBalance_checked_safe,
    getBalance_checked_same, pay_checked_safe, pay_checked_inv, refund_checked_safe, refund_checked_inv }

end Claims
end Credit
