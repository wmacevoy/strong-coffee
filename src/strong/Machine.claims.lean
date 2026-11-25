import MachineOwed
import CreditClaims
import PodRackClaims
import WaterTankClaims

/-! The proofs of what is owed of Machine, which has-a a Credit, a PodRack and a WaterTank: no
method commits a memory error, and each keeps the invariant, that the machine owes at most 10.00
at once (the credit and the change together).

Each part was proved alone. Here the machine is proved from what each part's methods do: that a
part's method commits no memory error, and keeps the part's own invariant, is had from the part's
proof; what is the machine's own is the rule that spans the credit and the change. The rack and
the tank are used only through their proofs. -/

namespace Machine
namespace Claims

/-- The invariant, as plain arithmetic: each part's own, and the credit and the change together
at most 1000 cents. -/
theorem inv_iff (me : Machine) :
    Inv me ↔ Credit.Inv me.credit ∧ PodRack.Inv me.rack ∧ WaterTank.Inv me.tank ∧
      me.change ≤ 1000#32 - me.credit.balance := by
  simp [Inv, Credit.getBalance_checked]

/-! What each part's methods do, from the part's own proof. -/

theorem podsIn (r : PodRack) (s : BitVec 32) (h : PodRack.Inv r) :
    ∃ x, PodRack.podsIn_checked r s = some (r, x) := by
  obtain ⟨⟨r', x⟩, e⟩ := Option.isSome_iff_exists.mp (PodRack.Claims.podsIn_checked_safe r s h)
  have := PodRack.Claims.podsIn_checked_same r s r' x e
  subst this; exact ⟨x, e⟩

theorem take (r : PodRack) (s : BitVec 32) (h : PodRack.Inv r) :
    ∃ r' x, PodRack.take_checked r s = some (r', x) ∧ PodRack.Inv r' := by
  obtain ⟨⟨r', x⟩, e⟩ := Option.isSome_iff_exists.mp (PodRack.Claims.take_checked_safe r s h)
  exact ⟨r', x, e, PodRack.Claims.take_checked_inv r s r' x h e⟩

theorem restock (r : PodRack) (s n : BitVec 32) (h : PodRack.Inv r) :
    ∃ r' x, PodRack.restock_checked r s n = some (r', x) ∧ PodRack.Inv r' := by
  obtain ⟨⟨r', x⟩, e⟩ := Option.isSome_iff_exists.mp (PodRack.Claims.restock_checked_safe r s n h)
  exact ⟨r', x, e, PodRack.Claims.restock_checked_inv r s n r' x h e⟩

theorem draw (t : WaterTank) (ml : BitVec 32) (h : WaterTank.Inv t) :
    ∃ t' x, WaterTank.draw_checked t ml = some (t', x) ∧ WaterTank.Inv t' := by
  obtain ⟨⟨t', x⟩, e⟩ := Option.isSome_iff_exists.mp (WaterTank.Claims.draw_checked_safe t ml h)
  exact ⟨t', x, e, WaterTank.Claims.draw_checked_inv t ml t' x h e⟩

theorem fill (t : WaterTank) (ml : BitVec 32) (h : WaterTank.Inv t) :
    ∃ t', WaterTank.fill_checked t ml = some (t', ()) ∧ WaterTank.Inv t' := by
  obtain ⟨⟨t', u⟩, e⟩ := Option.isSome_iff_exists.mp (WaterTank.Claims.fill_checked_safe t ml h)
  exact ⟨t', e, WaterTank.Claims.fill_checked_inv t ml t' u h e⟩

/-! The machine's methods. -/

theorem new_safe : Machine.new.isSome := by
  simp [Machine.new, Credit.new, PodRack.new, WaterTank.new, Prooc.set_of_lt]

theorem new_inv : ∀ (me : Machine), Machine.new = some me → Inv me := by
  intro me h
  obtain ⟨r, hr⟩ := Option.isSome_iff_exists.mp PodRack.Claims.new_safe
  have hri := PodRack.Claims.new_inv r hr
  simp [Machine.new, Credit.new, WaterTank.new, hr] at h
  subst h
  rw [inv_iff]
  exact ⟨by simp [Credit.Inv], hri, by simp [WaterTank.Inv], by simp⟩

theorem insert_checked_safe : ∀ (me : Machine) (cents : BitVec 32), Inv me → (Machine.insert_checked me cents).isSome := by
  intro me cents _
  simp only [Machine.insert_checked, Credit.getBalance_checked, Credit.insert_checked]
  by_cases a : cents > 1000#32 - me.credit.balance - me.change
  · simp [a]
  by_cases b : ((cents ≠ 5#32 ∧ cents ≠ 10#32) ∧ cents ≠ 25#32) ∧ cents ≠ 100#32
  · simp [a, b]
  by_cases c : cents > 1000#32 - me.credit.balance
  · simp [a, b, c]
  simp [a, b, c]

theorem insert_checked_inv : ∀ (me : Machine) (cents : BitVec 32) (me' : Machine) (r : BitVec 8),
    Inv me → Machine.insert_checked me cents = some (me', r) → Inv me' := by
  intro me cents me' r hi h
  rw [inv_iff] at hi ⊢
  obtain ⟨hc, hr, ht, ho⟩ := hi
  simp only [Credit.Inv] at hc
  simp only [Machine.insert_checked, Credit.getBalance_checked, Credit.insert_checked] at h
  by_cases a : cents > 1000#32 - me.credit.balance - me.change
  · simp [a] at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr, ht, ho⟩
  by_cases b : ((cents ≠ 5#32 ∧ cents ≠ 10#32) ∧ cents ≠ 25#32) ∧ cents ≠ 100#32
  · simp [a, b] at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr, ht, ho⟩
  by_cases c : cents > 1000#32 - me.credit.balance
  · simp [a, b, c] at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr, ht, ho⟩
  simp [a, b, c] at h
  obtain ⟨rfl, -⟩ := h
  simp only [Credit.Inv]
  exact ⟨by bv_omega, hr, ht, by bv_omega⟩

theorem buy_checked_safe : ∀ (me : Machine) (slot : BitVec 32) (price : BitVec 32), Inv me → (Machine.buy_checked me slot price).isSome := by
  intro me slot price hi
  rw [inv_iff] at hi
  obtain ⟨-, hr, ht, -⟩ := hi
  obtain ⟨n, hn⟩ := podsIn me.rack slot hr
  obtain ⟨r', x, hx, -⟩ := take me.rack slot hr
  obtain ⟨t', y, hy, -⟩ := draw me.tank 250#32 ht
  simp only [Machine.buy_checked, Credit.getBalance_checked, WaterTank.getLevel_checked, Credit.pay_checked, hn]
  by_cases a : me.credit.balance < price
  · simp [a]
  by_cases b : n = 0#32
  · simp [a, b]
  by_cases c : me.tank.level < 250#32
  · simp [a, b, c]
  simp [a, b, c, hx, hy]

theorem buy_checked_inv : ∀ (me : Machine) (slot : BitVec 32) (price : BitVec 32) (me' : Machine) (r : BitVec 32),
    Inv me → Machine.buy_checked me slot price = some (me', r) → Inv me' := by
  intro me slot price me' r hi h
  rw [inv_iff] at hi ⊢
  obtain ⟨hc, hr, ht, ho⟩ := hi
  simp only [Credit.Inv] at hc
  obtain ⟨n, hn⟩ := podsIn me.rack slot hr
  obtain ⟨r', x, hx, hr'⟩ := take me.rack slot hr
  obtain ⟨t', y, hy, ht'⟩ := draw me.tank 250#32 ht
  simp only [Machine.buy_checked, Credit.getBalance_checked, WaterTank.getLevel_checked, Credit.pay_checked, hn] at h
  by_cases a : me.credit.balance < price
  · simp [a] at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr, ht, ho⟩
  by_cases b : n = 0#32
  · simp [a, b] at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr, ht, ho⟩
  by_cases c : me.tank.level < 250#32
  · simp [a, b, c] at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr, ht, ho⟩
  simp [a, b, c, hx, hy] at h
  obtain ⟨rfl, -⟩ := h
  simp only [Credit.Inv]
  exact ⟨by bv_omega, hr', ht', by bv_omega⟩

theorem takeChange_checked_safe : ∀ (me : Machine), Inv me → (Machine.takeChange_checked me).isSome := by
  intro me _; simp [Machine.takeChange_checked]

theorem takeChange_checked_inv : ∀ (me : Machine) (me' : Machine) (r : BitVec 32),
    Inv me → Machine.takeChange_checked me = some (me', r) → Inv me' := by
  intro me me' r hi h
  rw [inv_iff] at hi ⊢
  simp [Machine.takeChange_checked] at h
  obtain ⟨rfl, -⟩ := h
  exact ⟨hi.1, hi.2.1, hi.2.2.1, by bv_omega⟩

theorem refund_checked_safe : ∀ (me : Machine), Inv me → (Machine.refund_checked me).isSome := by
  intro me _; simp [Machine.refund_checked, Credit.getBalance_checked, Credit.refund_checked]

theorem refund_checked_inv : ∀ (me : Machine) (me' : Machine) (r : BitVec 32),
    Inv me → Machine.refund_checked me = some (me', r) → Inv me' := by
  intro me me' r hi h
  rw [inv_iff] at hi ⊢
  simp [Machine.refund_checked, Credit.getBalance_checked, Credit.refund_checked] at h
  obtain ⟨rfl, -⟩ := h
  exact ⟨by simp [Credit.Inv], hi.2.1, hi.2.2.1, by simp⟩

theorem restock_checked_safe : ∀ (me : Machine) (slot : BitVec 32) (pods : BitVec 32), Inv me → (Machine.restock_checked me slot pods).isSome := by
  intro me slot pods hi
  rw [inv_iff] at hi
  obtain ⟨-, hr, -, -⟩ := hi
  obtain ⟨n, hn⟩ := podsIn me.rack slot hr
  obtain ⟨r', x, hx, hr'⟩ := restock me.rack slot pods hr
  obtain ⟨m, hm⟩ := podsIn r' slot hr'
  simp only [Machine.restock_checked]
  by_cases a : slot ≥ 4#32
  · simp [a]
  simp [a, hn, hx, hm]
  split <;> simp

theorem restock_checked_inv : ∀ (me : Machine) (slot : BitVec 32) (pods : BitVec 32) (me' : Machine) (r : BitVec 8),
    Inv me → Machine.restock_checked me slot pods = some (me', r) → Inv me' := by
  intro me slot pods me' r hi h
  rw [inv_iff] at hi ⊢
  obtain ⟨hc, hr, ht, ho⟩ := hi
  obtain ⟨n, hn⟩ := podsIn me.rack slot hr
  obtain ⟨r', x, hx, hr'⟩ := restock me.rack slot pods hr
  obtain ⟨m, hm⟩ := podsIn r' slot hr'
  simp only [Machine.restock_checked] at h
  by_cases a : slot ≥ 4#32
  · simp [a] at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr, ht, ho⟩
  simp [a, hn, hx, hm] at h
  split at h <;> (simp at h; obtain ⟨rfl, -⟩ := h; exact ⟨hc, hr', ht, ho⟩)

theorem fill_checked_safe : ∀ (me : Machine) (ml : BitVec 32), Inv me → (Machine.fill_checked me ml).isSome := by
  intro me ml hi
  rw [inv_iff] at hi
  obtain ⟨t', ht, -⟩ := fill me.tank ml hi.2.2.1
  simp [Machine.fill_checked, ht]

theorem fill_checked_inv : ∀ (me : Machine) (ml : BitVec 32) (me' : Machine) (r : Unit),
    Inv me → Machine.fill_checked me ml = some (me', r) → Inv me' := by
  intro me ml me' r hi h
  rw [inv_iff] at hi ⊢
  obtain ⟨t', ht, ht'⟩ := fill me.tank ml hi.2.2.1
  simp [Machine.fill_checked, ht] at h
  obtain ⟨rfl, -⟩ := h
  exact ⟨hi.1, hi.2.1, ht', hi.2.2.2⟩

theorem getBalance_checked_safe : ∀ (me : Machine), Inv me → (Machine.getBalance_checked me).isSome := by
  intro me _; simp [Machine.getBalance_checked, Credit.getBalance_checked]

theorem getBalance_checked_same : ∀ (me : Machine) (me' : Machine) (r : BitVec 32), Machine.getBalance_checked me = some (me', r) → me' = me := by
  intro me me' r h; simp [Machine.getBalance_checked, Credit.getBalance_checked] at h; exact h.1.symm

theorem podsIn_checked_safe : ∀ (me : Machine) (slot : BitVec 32), Inv me → (Machine.podsIn_checked me slot).isSome := by
  intro me slot hi
  rw [inv_iff] at hi
  obtain ⟨n, hn⟩ := podsIn me.rack slot hi.2.1
  simp [Machine.podsIn_checked, hn]

theorem podsIn_checked_same : ∀ (me : Machine) (slot : BitVec 32) (me' : Machine) (r : BitVec 32), Machine.podsIn_checked me slot = some (me', r) → me' = me := by
  intro me slot me' r h
  simp only [Machine.podsIn_checked] at h
  cases e : PodRack.podsIn_checked me.rack slot with
  | none => simp [e] at h
  | some p => simp [e] at h; exact h.1.symm

theorem getLevel_checked_safe : ∀ (me : Machine), Inv me → (Machine.getLevel_checked me).isSome := by
  intro me _; simp [Machine.getLevel_checked, WaterTank.getLevel_checked]

theorem getLevel_checked_same : ∀ (me : Machine) (me' : Machine) (r : BitVec 32), Machine.getLevel_checked me = some (me', r) → me' = me := by
  intro me me' r h; simp [Machine.getLevel_checked, WaterTank.getLevel_checked] at h; exact h.1.symm

/-- Everything owed. -/
theorem owed : Machine.Owed :=
  { new_safe, new_inv, insert_checked_safe, insert_checked_inv, buy_checked_safe, buy_checked_inv,
    takeChange_checked_safe, takeChange_checked_inv, refund_checked_safe, refund_checked_inv,
    restock_checked_safe, restock_checked_inv, fill_checked_safe, fill_checked_inv,
    getBalance_checked_safe, getBalance_checked_same, podsIn_checked_safe, podsIn_checked_same,
    getLevel_checked_safe, getLevel_checked_same }

end Claims
end Machine
