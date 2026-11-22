import vend_checkedOwed

/-! What is owed of vend_checked, a function: that it ends with no memory error, for every
argument. It has no state, so there is no invariant to keep. -/

namespace vend_checked
namespace Claims

theorem new_safe : vend_checked.new.isSome := by simp [vend_checked.new]

theorem new_inv : ∀ (me : vend_checked), vend_checked.new = some me → Inv me := by
  intro me _; simp [Inv]

theorem call_safe : ∀ (me : vend_checked) (credit price pods water : BitVec 32), Inv me →
    (vend_checked.call me credit price pods water).isSome := by
  intro me credit price pods water _
  simp only [vend_checked.call]
  repeat' split
  all_goals simp

/-- Everything owed. -/
theorem owed : vend_checked.Owed := { new_safe, new_inv, call_safe }

end Claims
end vend_checked
