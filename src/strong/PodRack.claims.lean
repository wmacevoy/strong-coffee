import PodRackOwed

/-! The proofs of what is owed of PodRack: no method reads or writes outside its four slots, and
each keeps the invariant, at most 10 pods in a slot. A slot is a number below 4 once it has been
tested (`slot ≥ 4` returns first), so each proof takes the four slots one at a time. -/

namespace PodRack
namespace Claims

theorem new_safe : PodRack.new.isSome := by simp [PodRack.new, Prooc.set_of_lt]

theorem new_inv : ∀ (me : PodRack), PodRack.new = some me → Inv me := by
  intro me h; simp [PodRack.new, Prooc.set_of_lt] at h; subst h; simp [Inv, PodRack.raw]

theorem podsIn_checked_safe : ∀ (me : PodRack) (slot : BitVec 32), Inv me → (PodRack.podsIn_checked me slot).isSome := by
  intro me slot _
  simp only [PodRack.podsIn_checked]
  split
  · simp
  · have hk : slot.toNat < 4 := by bv_omega
    simp [Prooc.get_of_lt, hk]

theorem podsIn_checked_same : ∀ (me : PodRack) (slot : BitVec 32) (me' : PodRack) (r : BitVec 32),
    PodRack.podsIn_checked me slot = some (me', r) → me' = me := by
  intro me slot me' r h
  simp only [PodRack.podsIn_checked] at h
  split at h
  · simp at h; exact h.1.symm
  · have hk : slot.toNat < 4 := by bv_omega
    simp [Prooc.get_of_lt, hk] at h; exact h.1.symm

theorem take_checked_safe : ∀ (me : PodRack) (slot : BitVec 32), Inv me → (PodRack.take_checked me slot).isSome := by
  intro me slot _
  simp only [PodRack.take_checked]
  split
  · simp
  · have hk : slot.toNat < 4 := by bv_omega
    simp [Prooc.get_of_lt, Prooc.set_of_lt, hk]
    split <;> simp

theorem take_checked_inv : ∀ (me : PodRack) (slot : BitVec 32) (me' : PodRack) (r : BitVec 8),
    Inv me → PodRack.take_checked me slot = some (me', r) → Inv me' := by
  intro me slot me' r hinv h
  simp only [PodRack.take_checked] at h
  split at h
  · simp at h; rw [← h.1]; exact hinv
  · have hk : slot.toNat < 4 := by bv_omega
    simp [Prooc.get_of_lt, Prooc.set_of_lt, hk] at h
    split at h
    · simp at h; rw [← h.1]; exact hinv
    · simp at h
      rw [← h.1]
      rename_i hz
      generalize slot.toNat = k at hk hz
      have hcases : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 := by omega
      simp only [Inv] at hinv ⊢
      rcases hcases with rfl | rfl | rfl | rfl <;> simp at hz ⊢ <;> bv_omega

theorem restock_checked_safe : ∀ (me : PodRack) (slot pods : BitVec 32), Inv me → (PodRack.restock_checked me slot pods).isSome := by
  intro me slot pods _
  simp only [PodRack.restock_checked]
  split
  · simp
  · have hk : slot.toNat < 4 := by bv_omega
    simp [Prooc.get_of_lt, Prooc.set_of_lt, hk]
    split <;> simp

theorem restock_checked_inv : ∀ (me : PodRack) (slot pods : BitVec 32) (me' : PodRack) (r : BitVec 8),
    Inv me → PodRack.restock_checked me slot pods = some (me', r) → Inv me' := by
  intro me slot pods me' r hinv h
  simp only [PodRack.restock_checked] at h
  split at h
  · simp at h; rw [← h.1]; exact hinv
  · have hk : slot.toNat < 4 := by bv_omega
    simp [Prooc.get_of_lt, Prooc.set_of_lt, hk] at h
    split at h
    · simp at h; rw [← h.1]; exact hinv
    · simp at h
      rw [← h.1]
      rename_i hfit
      generalize slot.toNat = k at hk hfit
      have hcases : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 := by omega
      simp only [Inv] at hinv ⊢
      rcases hcases with rfl | rfl | rfl | rfl <;> simp at hfit ⊢ <;> bv_omega

/-- Everything owed. -/
theorem owed : PodRack.Owed :=
  { new_safe, new_inv, podsIn_checked_safe, podsIn_checked_same, take_checked_safe, take_checked_inv,
    restock_checked_safe, restock_checked_inv }

end Claims
end PodRack
