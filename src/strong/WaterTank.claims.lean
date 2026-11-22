import WaterTankOwed

/-! The proofs of what is owed of WaterTank: no method commits a memory error, and each keeps the
invariant, at most 2000 ml. -/

namespace WaterTank
namespace Claims

theorem new_safe : WaterTank.new.isSome := by simp [WaterTank.new]

theorem new_inv : ∀ (me : WaterTank), WaterTank.new = some me → Inv me := by
  intro me h; simp [WaterTank.new] at h; subst h; simp [Inv]

theorem getLevel_checked_safe : ∀ (me : WaterTank), Inv me → (WaterTank.getLevel_checked me).isSome := by
  intro me _; simp [WaterTank.getLevel_checked]

theorem getLevel_checked_same : ∀ (me me' : WaterTank) (r : BitVec 32), WaterTank.getLevel_checked me = some (me', r) → me' = me := by
  intro me me' r h; simp [WaterTank.getLevel_checked] at h; exact h.1.symm

theorem fill_checked_safe : ∀ (me : WaterTank) (ml : BitVec 32), Inv me → (WaterTank.fill_checked me ml).isSome := by
  intro me ml _; simp only [WaterTank.fill_checked]; split <;> simp

theorem fill_checked_inv : ∀ (me : WaterTank) (ml : BitVec 32) (me' : WaterTank) (r : Unit),
    Inv me → WaterTank.fill_checked me ml = some (me', r) → Inv me' := by
  intro me ml me' r hinv h
  simp only [WaterTank.fill_checked] at h
  split at h
  · simp at h; rw [← h]; simp [Inv]
  · simp at h; rw [← h]; simp only [Inv] at *; bv_omega

theorem draw_checked_safe : ∀ (me : WaterTank) (ml : BitVec 32), Inv me → (WaterTank.draw_checked me ml).isSome := by
  intro me ml _; simp only [WaterTank.draw_checked]; split <;> simp

theorem draw_checked_inv : ∀ (me : WaterTank) (ml : BitVec 32) (me' : WaterTank) (r : BitVec 8),
    Inv me → WaterTank.draw_checked me ml = some (me', r) → Inv me' := by
  intro me ml me' r hinv h
  simp only [WaterTank.draw_checked] at h
  split at h
  · simp at h; rw [← h.1]; exact hinv
  · simp at h; rw [← h.1]; simp only [Inv] at *; bv_omega

/-- Everything owed. -/
theorem owed : WaterTank.Owed :=
  { new_safe, new_inv, getLevel_checked_safe, getLevel_checked_same, fill_checked_safe, fill_checked_inv,
    draw_checked_safe, draw_checked_inv }

end Claims
end WaterTank
