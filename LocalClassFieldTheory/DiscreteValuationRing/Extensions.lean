/-
Copyright (c) 2024 María Inés de Frutos-Fernández, Filippo A. E. Nuccio. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: María Inés de Frutos-Fernández, Filippo A. E. Nuccio
-/
import LocalClassFieldTheory.DiscreteValuationRing.DiscreteNorm
import LocalClassFieldTheory.ForMathlib.DiscreteValuationRing
import LocalClassFieldTheory.ForMathlib.RingTheory.IntegralClosure
import LocalClassFieldTheory.ForMathlib.RingTheory.Valuation.IntPolynomial
import LocalClassFieldTheory.ForMathlib.RingTheory.Valuation.Minpoly

#align_import discrete_valuation_ring.extensions

/-!
# Extensions of discrete valuations

Given a field `K` which is complete with respect to a discrete valuation and a finite dimensional
field extension `L` of `K`, we construct the unique discrete valuation on `L` induced by the
valuation on `K`.

## Main Definitions

* `DiscreteValuation.powExtensionOnUnits` : The map sending `x : Lˣ` to
  `(v ((minpoly K x.1).coeff 0))^((finrank K L)/(minpoly K x.1).nat_degree)`.
* `DiscreteValuation.expExtensionOnUnits` : the natural number `n` such that `of_add (n : ℤ)`
  generates the image of the map `powExtensionOnUnits K L`.
* `DiscreteValuation.extendedValuation` : the unique discrete valuation on `L` induced by the
  valuation on `K`.
* `DiscreteValuation.valuation_subring.algebra` : the valuation subring of `L` with respect to
  `extendedValuation K L` is an algebra over the valuation subring of `K`.

## Main Results

* `DiscreteValuation.expExtensionOnUnits_generates_range` : The image of
 `powExtensionOnUnits K L` is  generated by `of_add (expExtensionOnUnits K L : ℤ)`.
* `DiscreteValuation.expExtensionOnUnits_dvd` : The number `expExtensionOnUnits K L`
  divides the degree of `L` over `K`.
* `DiscreteValuation.Extension.isDiscreteOfFinite` : the extended valuation on `L` is discrete.
* `DiscreteValuation.Extension.complete_space` : `L` is a complete space with respect to the
  topology induced by `extendedValuation`.
* `DiscreteValuation.integral_closure.discreteValuationRing_of_finite_extension` : the integral
  closure of the the valuation subring of `K` in `L` is a discrete valuation ring.


## Tags

valuation, is_discrete, discrete_valuation_ring
-/


-- import for_mathlib.field_theory.minpoly.is_integrally_closed
-- import for_mathlib.field_theory.minpoly.is_integrally_closed
noncomputable section

open AddSubgroup DiscreteValuation DiscreteValuation.DiscreteNormExtension Function Multiplicative
  NNReal FiniteDimensional minpoly Polynomial Subgroup Valuation WithZero

open scoped DiscreteValuation NNReal

theorem Multiplicative.toSubgroup_mem_iff {G : Type _} [AddGroup G] (S : AddSubgroup G)
    (x : Multiplicative G) : x ∈ toSubgroup S ↔ toAdd x ∈ S := by rfl

namespace DiscreteValuation

section Complete

variable {K : Type _} [Field K] [hv : Valued K ℤₘ₀] {L : Type _} [Field L] [Algebra K L]

local notation "K₀" => hv.v.valuationSubring

-- Porting note: In Lean3 the following was already found as an instance, now it has to be specified
instance : Algebra ↥K₀ ↥(integralClosure ↥K₀ L) :=
  Subalgebra.algebra (integralClosure (↥(valuationSubring hv.v)) L)

/- Porting note: I had to add this because otherwise Lean times out while searching for the
  `Add` instance-/
instance : CommRing ↥(integralClosure ↥K₀ L) := inferInstance

--Porting note: In Lean3 the following was already found as an instance, now it has to be specified
instance : SMul ↥K₀ (integralClosure ↥K₀ L) := Algebra.toSMul

--Porting note: In Lean3 the following was already found as an instance, now it has to be specified
instance : MulZeroClass ↥(integralClosure ↥K₀ L) := MulZeroOneClass.toMulZeroClass

instance : NoZeroSMulDivisors K₀ (integralClosure K₀ L)
    where eq_zero_or_eq_zero_of_smul_eq_zero h := by
    { rw [Algebra.smul_def, mul_eq_zero] at h
      refine' h.imp_left fun hc => _
      rw [← _root_.map_zero (algebraMap K₀ (integralClosure K₀ L))] at hc
      exact IsFractionRing.injective K₀ K ((algebraMap K L).injective (Subtype.ext_iff.mp hc)) }

variable [IsDiscrete hv.v] [CompleteSpace K]

theorem map_hMul_aux [FiniteDimensional K L] (x y : Lˣ) :
    Valued.v ((minpoly K ((x : L) * ↑y)).coeff 0) ^
        (finrank K L / (minpoly K ((x : L) * ↑y)).natDegree) =
      Valued.v ((minpoly K (x : L)).coeff 0) ^ (finrank K L / (minpoly K (x : L)).natDegree) *
        Valued.v ((minpoly K (y : L)).coeff 0) ^ (finrank K L / (minpoly K (y : L)).natDegree) := by
  have h_alg : Algebra.IsAlgebraic K L := Algebra.IsAlgebraic.of_finite K L
  have hinj : Injective (withZeroMultIntToNNReal (base_ne_zero K hv.v)) :=
    (withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)).injective
  rw [← Function.Injective.eq_iff hinj, _root_.map_mul, ← Units.val_mul, map_pow_div, map_pow_div,
    map_pow_div, ← mul_rpow, rpow_eq_rpow_iff (Nat.cast_ne_zero.mpr (ne_of_gt finrank_pos))]
  ext
  rw [NNReal.coe_mul, coe_rpow, coe_rpow, coe_rpow, ← eq_root_zero_coeff h_alg, ←
    eq_root_zero_coeff h_alg, ← eq_root_zero_coeff h_alg, Units.val_mul, _root_.map_mul]

variable (K L)

/-- The map sending `x : Lˣ` to the `(finrank K L)/(minpoly K x.1).nat_degree`th power of the
valuation of the zeroth coefficient of its minimal polynomial, that is, to
`(v ((minpoly K x.1).coeff 0))^((finrank K L)/(minpoly K x.1).nat_degree)`, as an
element of `multiplicative ℤ`. -/
def powExtensionOnUnits [FiniteDimensional K L] : Lˣ →* Multiplicative ℤ where
  toFun x := WithZero.unzero (Valuation.unit_pow_ne_zero hv.v x)
  map_one' := by
    simp_all only [Units.val_one, minpoly.one, coeff_sub, coeff_X_zero, coeff_one_zero, zero_sub,
      Valuation.map_neg, _root_.map_one, one_pow, unzero_coe]
    rfl
  map_mul' x y := by
    simp only [Units.val_mul]
    rw [← WithZero.coe_inj, WithZero.coe_mul, WithZero.coe_unzero, WithZero.coe_unzero,
      WithZero.coe_unzero]
    exact map_hMul_aux x y

theorem powExtensionOnUnits_apply [FiniteDimensional K L] (x : Lˣ) :
    powExtensionOnUnits K L x = WithZero.unzero (Valuation.unit_pow_ne_zero hv.v x) :=
  rfl

/-- The natural number `n` such that the image of the map `powExtensionOnUnits K L` is
generated by `of_add (n : ℤ)`. -/
def expExtensionOnUnits [FiniteDimensional K L] : ℕ :=
  Int.natAbs (Int.subgroup_cyclic
    (toAddSubgroup (Subgroup.map (powExtensionOnUnits K L) ⊤))).choose

variable {K L}

theorem expExtensionOnUnits_generates_range' [FiniteDimensional K L] :
    Subgroup.toAddSubgroup (Subgroup.map (powExtensionOnUnits K L) ⊤) =
      AddSubgroup.closure {(expExtensionOnUnits K L : ℤ)} := by
  rw [(Int.subgroup_cyclic (toAddSubgroup (Subgroup.map (powExtensionOnUnits K L) ⊤))).choose_spec,
    ← zmultiples_eq_closure, ← zmultiples_eq_closure, expExtensionOnUnits, Int.zmultiples_natAbs]

variable (K L) in
theorem expExtensionOnUnits_ne_zero [FiniteDimensional K L] : expExtensionOnUnits K L ≠ 0 := by
  sorry
  -- have h_alg : Algebra.IsAlgebraic K L := Algebra.IsAlgebraic.of_finite K L
  -- obtain ⟨x, hx⟩ := exists_Uniformizer_ofDiscrete hv.v
  -- have hx_unit : IsUnit (x : K) := isUnit_iff_ne_zero.mpr (Uniformizer_ne_zero hv.v hx)
  -- rw [IsUniformizer] at hx
  -- set z : Lˣ := Units.map (algebraMap K L).toMonoidHom (IsUnit.unit hx_unit) with hz
  -- by_contra h0
  -- have h := expExtensionOnUnits_generates_range' (K := K) (L := L)
  -- rw [h0, ZMod.natCast_self, closure_singleton_zero, _root_.map_eq_bot_iff,
  --   Subgroup.map_eq_bot_iff, top_le_iff] at h
  -- have hz1 : powExtensionOnUnits K L z = 1 := by rw [← MonoidHom.mem_ker, h]; exact mem_top _
  -- have hzne1 : powExtensionOnUnits K L z ≠ 1 := by
  --   have hv :
  --     Valued.v ((minpoly K ((Units.map (algebraMap K L).toMonoidHom) hx_unit.unit).val).coeff 0) =
  --       Valued.v (x : K) := by
  --     rw [RingHom.toMonoidHom_eq_coe, Units.coe_map, IsUnit.unit_spec, MonoidHom.coe_coe,
  --       Valuation.coeff_zero]
  --   rw [hz, powExtensionOnUnits_apply, ne_eq, ← WithZero.coe_inj, coe_unzero, hv, hx, ←
  --     ofAdd_neg_nat, ← ofAdd_zero, WithZero.coe_inj, RingHom.toMonoidHom_eq_coe, Units.coe_map,
  --       IsUnit.unit_spec, MonoidHom.coe_coe, Int.natCast_div, ofAdd_neg, ofAdd_zero, inv_eq_one,
  --       ofAdd_eq_one, ← Int.natCast_div, Int.natCast_eq_zero,
  --       Nat.div_eq_zero_iff (minpoly.natDegree_pos (isAlgebraic_iff_isIntegral.mp (h_alg _)))]
  --   exact not_lt.mpr (minpoly.natDegree_le z.1)
  -- exact hzne1 hz1

variable (K L)

theorem expExtensionOnUnits_pos [FiniteDimensional K L] : 0 < expExtensionOnUnits K L :=
  Nat.pos_of_ne_zero (expExtensionOnUnits_ne_zero K L)

variable {K L}

/-- The image of `powExtensionOnUnits K L` is generated by
  `of_add (expExtensionOnUnits K L : ℤ)`. -/
theorem expExtensionOnUnits_generates_range [FiniteDimensional K L] :
  Subgroup.map (powExtensionOnUnits K L) ⊤ =
    Subgroup.closure {ofAdd (expExtensionOnUnits K L : ℤ)} := by
  have h :
    toSubgroup (toAddSubgroup (Subgroup.map (powExtensionOnUnits K L) ⊤)) =
      toSubgroup (AddSubgroup.closure {(expExtensionOnUnits K L : ℤ)}) := by
      rw [expExtensionOnUnits_generates_range']
      rfl
  convert h
  ext x
  rw [Subgroup.mem_closure_singleton, ← mem_zpowers_iff, Multiplicative.toSubgroup_mem_iff,
    AddSubgroup.mem_closure_singleton, ← mem_zmultiples_iff]
  rfl

variable (K)

theorem exists_mul_expExtensionOnUnits [FiniteDimensional K L] (x : Lˣ) :
    ∃ n : ℤ,
      ((ofAdd (-1 : ℤ) ^ n) ^ expExtensionOnUnits K L : ℤₘ₀) =
        Valued.v ((minpoly K (x : L)).coeff 0) ^ (finrank K L / (minpoly K (x : L)).natDegree) :=
  by
  set y := WithZero.unzero (Valuation.unit_pow_ne_zero hv.v x)
  have h_mem :
    WithZero.unzero (Valuation.unit_pow_ne_zero hv.v x) ∈
      Subgroup.closure ({ofAdd (expExtensionOnUnits K L : ℤ)} : Set (Multiplicative ℤ)) :=
    by
    rw [← expExtensionOnUnits_generates_range, Subgroup.mem_map]
    exact ⟨x, mem_top x, rfl⟩
  rw [Subgroup.mem_closure_singleton] at h_mem
  obtain ⟨n, hn⟩ := h_mem
  use -n
  rw [WithZero.ofAdd_neg_one_pow_comm n, ← WithZero.coe_zpow, hn, WithZero.coe_unzero]

variable (L)

/-- The number `expExtensionOnUnits K L` divides the degree of `L` over `K`. -/
theorem expExtensionOnUnits_dvd [FiniteDimensional K L] :
  expExtensionOnUnits K L ∣ finrank K L := by sorry
  -- have h_alg := Algebra.IsAlgebraic.of_finite K L
  -- obtain ⟨π, hπ⟩ := exists_Uniformizer_ofDiscrete hv.v
  -- set u : L := algebraMap K L (π : K) with hu_def
  -- have hu0 : u ≠ 0 := by
  --   rw [hu_def, ne_eq, _root_.map_eq_zero]
  --   exact Uniformizer_ne_zero hv.v hπ
  -- obtain ⟨n, hn⟩ := exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hu0).choose
  -- have hu := (isUnit_iff_ne_zero.mpr hu0).choose_spec
  -- have hne_zero : ((minpoly K ((algebraMap K L) ↑π)).natDegree : ℤ) ≠ 0 := by
  --   rw [Nat.cast_ne_zero, ← pos_iff_ne_zero]
  --   exact minpoly.natDegree_pos (isAlgebraic_iff_isIntegral.mp (h_alg _))
  -- have h_dvd : ((minpoly K ((algebraMap K L) ↑π)).natDegree : ℤ) ∣ finrank K L :=
  --   Int.natCast_dvd.mpr (minpoly.degree_dvd (isAlgebraic_iff_isIntegral.mp (h_alg _)))
  -- rw [hu, hu_def, Valuation.coeff_zero, IsUniformizer_iff.mp hπ, ← WithZero.coe_pow, ←
  --   WithZero.coe_zpow, ← WithZero.coe_pow, WithZero.coe_inj, ← zpow_natCast, ← zpow_mul, ← zpow_natCast,
  --   ofAdd_pow_comm, ofAdd_pow_comm (-1)] at hn
  -- simp only [zpow_neg, zpow_one, inv_inj] at hn
  -- replace hn := ofAdd_inj hn
  -- have hn0 : 0 ≤ n := by
  --   refine' nonneg_of_mul_nonneg_left _ (Nat.cast_pos.mpr (expExtensionOnUnits_pos K L))
  --   rw [hn]
  --   exact Nat.cast_nonneg _
  -- rw [Int.natCast_div, eq_comm, Int.ediv_eq_iff_eq_mul_right hne_zero h_dvd] at hn
  -- use(minpoly K ((algebraMap K L) ↑π)).natDegree * n.toNat
  -- rw [mul_comm, ← @Nat.cast_inj ℤ _, hn, Nat.cast_mul, Nat.cast_mul, Int.toNat_of_nonneg hn0,
  --   mul_assoc]

variable {L}

open Classical

/-- The underlying map to the discrete valuation on `L` induced by the valuation on `K`. -/
def extensionDef [FiniteDimensional K L] : L → ℤₘ₀ := fun x => by
  exact
  if hx : x = 0 then 0
  else
  (ofAdd (-1 : ℤ)) ^ (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose

variable {K}

theorem extensionDef_apply [FiniteDimensional K L] (x : L) :
  extensionDef K x =
    if hx : x = 0 then (0 : ℤₘ₀)
    else
    ofAdd (-1 : ℤ) ^ (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose :=
    rfl

theorem extensionDef_mul [FiniteDimensional K L] (x y : L) :
    extensionDef K (x * y) = extensionDef K x * extensionDef K y := by
  sorry
  -- have h_alg : Algebra.IsAlgebraic K L := Algebra.IsAlgebraic.of_finite K L
  -- by_cases hx : x = 0
  -- · have hxy : x * y = 0 := by rw [hx, MulZeroClass.zero_mul]
  --   rw [extensionDef_apply, dif_pos hxy, extensionDef_apply, dif_pos hx, MulZeroClass.zero_mul]
  -- · by_cases hy : y = 0
  --   · have hxy : x * y = 0 := by rw [hy, MulZeroClass.mul_zero]
  --     rw [extensionDef_apply (x * y), dif_pos hxy, extensionDef_apply y, dif_pos hy,
  --     MulZeroClass.mul_zero]
  --   · have hxy : x * y ≠ 0 := mul_ne_zero hx hy
  --     simp only [extensionDef_apply]
  --     rw [dif_neg hx, dif_neg hy, dif_neg (mul_ne_zero hx hy)]
  --     have hinj : Injective (withZeroMultIntToNNReal (base_ne_zero K hv.v)) :=
  --       (withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)).injective
  --     rw [← Function.Injective.eq_iff hinj, ← pow_left_inj _ _ (expExtensionOnUnits_ne_zero K L), ←
  --       NNReal.coe_inj, _root_.map_mul, mul_pow, ← _root_.map_pow,
  --       (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hxy).choose).choose_spec,
  --       NNReal.coe_mul]
  --     nth_rw 2 [← _root_.map_pow]
  --     rw [(exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose_spec]
  --     nth_rw 3 [← _root_.map_pow]
  --     rw [(exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hy).choose).choose_spec,
  --       _root_.map_pow, NNReal.coe_pow, ← pow_eq_pow_root_zero_coeff h_alg, _root_.map_pow,
  --       NNReal.coe_pow, ← pow_eq_pow_root_zero_coeff h_alg, _root_.map_pow, NNReal.coe_pow, ←
  --       pow_eq_pow_root_zero_coeff h_alg, ← mul_pow]
  --     any_goals exact minpoly.degree_dvd (isAlgebraic_iff_isIntegral.mp (h_alg _))
  --     · rw [(isUnit_iff_ne_zero.mpr hx).choose_spec, (isUnit_iff_ne_zero.mpr hy).choose_spec,
  --         (isUnit_iff_ne_zero.mpr hxy).choose_spec, DiscreteNormExtension.mul]
  --     · exact zero_le'
  --     · exact zero_le'

theorem extensionDef_add [FiniteDimensional K L] (x y : L) :
    extensionDef K (x + y) ≤ max (extensionDef K x) (extensionDef K y) := by sorry
  -- let _ : LinearOrderedCommGroup (Multiplicative ℤ) := linearOrderedCommGroup
  -- have h_alg : Algebra.IsAlgebraic K L := Algebra.IsAlgebraic.of_finite K L
  -- by_cases hx : x = 0
  -- · have hxy : x + y = y := by rw [hx, zero_add]
  --   simp only [extensionDef_apply, dif_pos hx, hxy]
  --   rw [max_eq_right]
  --   exact WithZero.zero_le _
  -- · by_cases hy : y = 0
  --   · have hxy : x + y = x := by rw [hy, add_zero]
  --     simp only [extensionDef_apply, dif_pos hy, hxy]
  --     rw [max_eq_left]
  --     simp_all only [add_zero, ↓reduceDite, Int.reduceNeg, ofAdd_neg, WithZero.coe_inv, inv_zpow',
  --       zpow_neg, inv_pow, zero_le']
  --   · by_cases hxy : x + y = 0
  --     · simp only [extensionDef_apply, dif_pos hxy, zero_le']
  --     · simp only [extensionDef_apply, dif_neg hx, dif_neg hy, dif_neg hxy]
  --       set ux := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose
  --         with hux
  --       set uy := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hy).choose).choose
  --         with huy
  --       set uxy := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hxy).choose).choose
  --         with huxy
  --       rw [_root_.le_max_iff]
  --       simp only [← WithZero.coe_zpow, WithZero.coe_le_coe]
  --       have hd : 0 < (expExtensionOnUnits K L : ℤ) := by
  --         rw [Int.natCast_pos]
  --         exact Nat.pos_of_ne_zero (expExtensionOnUnits_ne_zero K L)
  --       rw [← zpow_le_zpow_iff' hd, zpow_natCast, zpow_natCast, ← WithZero.coe_le_coe, WithZero.coe_pow,
  --          WithZero.coe_zpow]
  --       simp_all only [(isUnit_iff_ne_zero.mpr hx).choose_spec, (isUnit_iff_ne_zero.mpr hy).choose_spec,
  --         (isUnit_iff_ne_zero.mpr hxy).choose_spec]
  --       rw [(exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hxy).unit).choose_spec]
  --       rw [WithZero.coe_pow, WithZero.coe_zpow,
  --         (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).unit).choose_spec]
  --       rw [← zpow_le_zpow_iff' hd, zpow_natCast, zpow_natCast]
  --       nth_rw 2 [← WithZero.coe_le_coe]
  --       simp_all only [WithZero.coe_pow, WithZero.coe_zpow,
  --         (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hxy).unit).choose_spec,
  --         (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hy).unit).choose_spec]
  --       simp_all only [← (withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)).le_iff_le, ←
  --         NNReal.coe_le_coe]
  --       rw [_root_.map_pow, NNReal.coe_pow, ← Real.rpow_natCast, Nat.cast_div,
  --         ← pow_eq_pow_root_zero_coeff' h_alg]
  --       --x + y
  --       rw [_root_.map_pow, NNReal.coe_pow, ← Real.rpow_natCast _
  --         (finrank K L / (minpoly K _).natDegree), Nat.cast_div,
  --         ← pow_eq_pow_root_zero_coeff' h_alg]
  --       -- x
  --       rw [_root_.map_pow, NNReal.coe_pow, ← Real.rpow_natCast _
  --         (finrank K L / (minpoly K _).natDegree), Nat.cast_div,
  --         ← pow_eq_pow_root_zero_coeff' h_alg]
  --       -- y
  --       have h_le :
  --         (discreteNormExtension h_alg) (x + y) ≤ (discreteNormExtension h_alg) x ∨
  --           (discreteNormExtension h_alg) (x + y) ≤ (discreteNormExtension h_alg) y := by
  --         rw [← _root_.le_max_iff]
  --         exact (isNonarchimedean h_alg) _ _
  --       cases' h_le with hlex hley
  --       · left
  --         exact pow_le_pow_left (nonneg h_alg _) hlex _
  --       · right
  --         exact pow_le_pow_left (nonneg h_alg _) hley _
  --       repeat' exact minpoly.degree_dvd (isAlgebraic_iff_isIntegral.mp (h_alg _))
  --       repeat'
  --         rw [Nat.cast_ne_zero]
  --         exact ne_of_gt (minpoly.natDegree_pos (isAlgebraic_iff_isIntegral.mp (h_alg _)))

variable (K L)

--Porting note: this lemma has been removed from Mathlib
theorem or_eq_of_eq_false_right {a b : Prop} (h : b = False) : (a ∨ b) = a :=
  h.symm ▸ propext (or_false_iff _)

theorem extensionDef_one [FiniteDimensional K L] : extensionDef K (1 : L) = 1 := by
  have h1 : (1 : L) ≠ 0 := one_ne_zero
  rw [extensionDef_apply, dif_neg h1]
  set u := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr h1).choose).choose with hu_def
  have hu :
    (↑(ofAdd (-1 : ℤ)) ^ u) ^ expExtensionOnUnits K L =
      Valued.v ((minpoly K ((isUnit_iff_ne_zero.mpr h1).choose : L)).coeff 0) ^
        (finrank K L / (minpoly K ((isUnit_iff_ne_zero.mpr h1).choose : L)).natDegree) := by
    have h' := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr h1).unit).choose_spec
    simp only [IsUnit.unit_spec] at h'
    convert h' <;>
    exact Exists.choose_spec (isUnit_iff_ne_zero.mpr h1)
  erw [Exists.choose_spec (isUnit_iff_ne_zero.mpr h1)] at hu
  simp only [IsUnit.unit_spec, minpoly.one, coeff_sub, coeff_X_zero, coeff_one_zero, zero_sub,
    Valuation.map_neg, Valuation.map_one, one_pow, inv_eq_one] at hu
  simp only [← WithZero.coe_one, ← ofAdd_zero, ← WithZero.coe_zpow, ← WithZero.coe_pow,
    WithZero.coe_inj, ← zpow_natCast, ← Int.ofAdd_mul] at hu
  have hu' := Int.eq_zero_or_eq_zero_of_mul_eq_zero hu
  have hf : ((expExtensionOnUnits K L : ℤ) = 0) ↔ False := by
    simp only [expExtensionOnUnits_ne_zero, Nat.cast_eq_zero]
  rw [hf, or_false] at hu'
  rw [← WithZero.coe_one, ← ofAdd_zero, ← WithZero.coe_zpow, WithZero.coe_inj, ← Int.ofAdd_mul]
  apply congr_arg
  rw [hu_def]
  convert hu'

/-- The discrete valuation on `L` induced by the valuation on `K`. -/
def extendedValuation [FiniteDimensional K L] : Valuation L ℤₘ₀
    where
  toFun := extensionDef K
  map_zero' := by rw [extensionDef_apply, dif_pos rfl]
  map_one' := extensionDef_one K L
  map_mul' := extensionDef_mul
  map_add_le_max' := extensionDef_add

namespace Extension

variable {K L}

theorem apply [FiniteDimensional K L] (x : L) :
  extendedValuation K L x =
  if hx : x = 0 then (0 : ℤₘ₀)
  else
  ofAdd (-1 : ℤ) ^ (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose :=
  rfl

theorem apply_if_neg [FiniteDimensional K L] {x : L} (hx : x ≠ 0) :
    extendedValuation K L x =
      ofAdd (-1 : ℤ) ^ (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose :=
  by rw [apply, dif_neg hx]

theorem le_one_iff_discreteNormExtension_le_one [FiniteDimensional K L] (x : L) :
    extendedValuation K L x ≤ (1 : ℤₘ₀) ↔
      discreteNormExtension (Algebra.IsAlgebraic.of_finite K L) x ≤ 1 := by sorry
  -- set h_alg := Algebra.IsAlgebraic.of_finite K L
  -- rw [apply]
  -- split_ifs with hx
  -- · simp only [hx, _root_.map_zero, zero_le_one]
  -- · have h_le_iff :
  --     discreteNormExtension h_alg x ≤ 1 ↔ discreteNormExtension h_alg x ^ finrank K L ≤ 1 := by
  --     rw [pow_le_one_iff_of_nonneg (nonneg h_alg _) (ne_of_gt finrank_pos)]
  --   set n := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose with
  --     hn_def
  --   rw [h_le_iff, pow_eq_pow_root_zero_coeff _ _
  --       (minpoly.degree_dvd (isAlgebraic_iff_isIntegral.mp (h_alg x))), ← NNReal.coe_pow]
  --   rw [← _root_.map_pow]
  --   have h' := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).choose).choose_spec
  --   rw [← hn_def, (isUnit_iff_ne_zero.mpr hx).choose_spec] at h'
  --   rw [← h', ← NNReal.coe_one, NNReal.coe_le_coe,
  --     ← _root_.map_one (withZeroMultIntToNNReal (base_ne_zero K hv.v)),
  --     (withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)).le_iff_le, ← WithZero.coe_one, ←
  --     WithZero.coe_zpow, WithZero.coe_le_coe, ← WithZero.coe_pow, WithZero.coe_le_coe,
  --     ← zpow_natCast, ← Int.ofAdd_mul, ← Int.ofAdd_mul, ← ofAdd_zero, ofAdd_le, ofAdd_le]
  --   exact ⟨fun h => mul_nonpos_of_nonpos_of_nonneg h (Nat.cast_nonneg _), fun h =>
  --     nonpos_of_mul_nonpos_left h (Nat.cast_pos.mpr (expExtensionOnUnits_pos K L))⟩

variable (K L)

theorem exists_generating_Unit [FiniteDimensional K L] :
    ∃ x : Lˣ, powExtensionOnUnits K L x = ofAdd (-expExtensionOnUnits K L : ℤ) := by
  have h_mem :
    ofAdd (expExtensionOnUnits K L : ℤ) ∈
      Subgroup.closure {ofAdd (expExtensionOnUnits K L : ℤ)} :=
    Subgroup.mem_closure_singleton.mpr ⟨1, by rw [zpow_one]⟩
  rw [← expExtensionOnUnits_generates_range, Subgroup.mem_map] at h_mem
  obtain ⟨x, _, hx⟩ := h_mem
  use x⁻¹
  rw [map_inv, hx]
  rfl

/-- The extended valuation on `L` is discrete. -/
instance isDiscrete_of_finite [FiniteDimensional K L] : IsDiscrete (extendedValuation K L) := by
  set x := (exists_generating_Unit K L).choose
  have hx := (exists_generating_Unit K L).choose_spec
  rw [← WithZero.coe_inj] at hx
  simp only [powExtensionOnUnits, MonoidHom.coe_mk, coe_unzero,
    ofAdd_neg_nat, OneHom.coe_mk] at hx
  have hπ1 : extendedValuation K L x = Multiplicative.ofAdd (-1 : ℤ) := by
    rw [Extension.apply_if_neg (Units.ne_zero _),
      ← WithZero.zpow_left_inj (zpow_ne_zero _ WithZero.coe_ne_zero) WithZero.coe_ne_zero
      (Nat.cast_ne_zero.mpr (expExtensionOnUnits_ne_zero K L)), zpow_natCast, zpow_natCast, ← hx,
      ← (exists_mul_expExtensionOnUnits K x).choose_spec]
    congr 3
    ext n
    rw [Exists.choose_spec (x.isUnit)]
  set π : (extendedValuation K L).valuationSubring :=
    ⟨(exists_generating_Unit K L).choose, by
      rw [mem_valuationSubring_iff, hπ1]; exact le_of_lt WithZero.ofAdd_neg_one_lt_one⟩
  have hπ : extendedValuation K L (π : L) = Multiplicative.ofAdd (-1 : ℤ) := hπ1
  apply isDiscreteOfExistsUniformizer (extendedValuation K L) hπ

variable {K L}

/-- The uniform space structure on `L` induced by `discrete_valuation.extendedValuation`. -/
--porting note: the @[protected] attribute has been commented

-- @[protected]
def uniformSpace (h_alg : Algebra.IsAlgebraic K L) : UniformSpace L :=
  discretelyNormedFieldExtensionUniformSpace h_alg

variable (K L)

/-- The normed field structure on `L` induced by the spectral norm.  -/

--porting note: the @[protected] attribute has been commented
-- @[protected]
def normedField [FiniteDimensional K L] : NormedField L := by
  have h_alg := Algebra.IsAlgebraic.of_finite K L
  letI : NontriviallyNormedField K := nontriviallyDiscretelyNormedField K
  exact spectralNormToNormedField h_alg (norm_isNonarchimedean K)

/-- The valued field structure on `L` induced by `discrete_valuation.extendedValuation`.  -/

--porting note: the @[protected] attribute has been commented
-- @[protected]
def valued [FiniteDimensional K L] : Valued L ℤₘ₀ := sorry
  -- letI : NormedField L := normedField K L
  -- { uniformSpace (Algebra.IsAlgebraic.of_finite K L),
  --   @NonUnitalNormedRing.toNormedAddCommGroup L _ with
  --   v := extendedValuation K L
  --   is_topological_valuation := fun U =>  by
  --     have hpos : 0 < (expExtensionOnUnits K L : ℝ) :=
  --       Nat.cast_pos.mpr (expExtensionOnUnits_pos K L)
  --     have hpos' : 0 < (finrank K L : ℝ) := Nat.cast_pos.mpr finrank_pos
  --     have h_alg := Algebra.IsAlgebraic.of_finite K L
  --     rw [Metric.mem_nhds_iff]
  --     refine' ⟨fun h => _, fun h => _⟩
  --     · obtain ⟨ε, hε, h⟩ := h
  --       obtain ⟨δ, hδ⟩ :=
  --         Real.exists_strictMono_lt (withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)) hε
  --       use δ ^ (finrank K L / expExtensionOnUnits K L)
  --       intro x hx
  --       simp only [Set.mem_setOf_eq, Extension.apply] at hx
  --       apply h
  --       rw [mem_ball_zero_iff]
  --       split_ifs at hx  with h0
  --       · rw [h0, norm_zero]; exact hε
  --       · set n := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr h0).unit).choose with
  --           hn_def
  --         set hn := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr h0).unit).choose_spec
  --         simp only [(isUnit_iff_ne_zero.mpr h0).choose_spec] at hx
  --         rw [← hn_def] at hx
  --         have hx' := Real.rpow_lt_rpow (NNReal.coe_nonneg _)
  --             ((withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)) hx) hpos
  --         rw [Real.rpow_natCast, ← NNReal.coe_pow, ← _root_.map_pow, hn, _root_.map_pow,
  --           NNReal.coe_pow, ← DiscreteNormExtension.pow_eq_pow_root_zero_coeff h_alg _
  --             (minpoly.degree_dvd
  --               (isAlgebraic_iff_isIntegral.mp (h_alg ↑(isUnit_iff_ne_zero.mpr h0).unit)))]
  --           at hx'
  --         rw [← Real.rpow_lt_rpow_iff (norm_nonneg _) (le_of_lt hε) hpos', Real.rpow_natCast]
  --         apply lt_trans hx'
  --         simp only [Units.val_pow_eq_pow_val, _root_.map_pow, val_eq_coe, NNReal.coe_pow,
  --           Real.rpow_natCast]
  --         rw [← pow_mul, Nat.div_mul_cancel (expExtensionOnUnits_dvd K L), ← Real.rpow_natCast,
  --           ← Real.rpow_natCast, Real.rpow_lt_rpow_iff (NNReal.coe_nonneg _) (le_of_lt hε) hpos']
  --         exact hδ
  --     · obtain ⟨ε, hε⟩ := h
  --       have hε_pos : 0 < (withZeroMultIntToNNReal (base_ne_zero K hv.v) ε : ℝ) ^
  --           ((expExtensionOnUnits K L : ℝ) / (finrank K L : ℝ)) := by
  --         apply rpow_pos
  --         rw [← _root_.map_zero (withZeroMultIntToNNReal (base_ne_zero K hv.v)),
  --           (withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)).lt_iff_lt]
  --         exact Units.zero_lt _
  --       use(withZeroMultIntToNNReal (base_ne_zero K hv.v) ε : ℝ) ^
  --           ((expExtensionOnUnits K L : ℝ) / (finrank K L : ℝ)),
  --         hε_pos
  --       intro x hx
  --       rw [mem_ball_zero_iff] at hx
  --       apply hε
  --       rw [Set.mem_setOf_eq, Extension.apply]
  --       split_ifs with h0
  --       · exact Units.zero_lt _
  --       · set n := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr h0).unit).choose with
  --           hn_def
  --         set hn := (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr h0).unit).choose_spec
  --         simp only [IsUnit.unit_spec, ← hn_def] at hn
  --         rw [← (withZeroMultIntToNNReal_strictMono (one_lt_base K hv.v)).lt_iff_lt, ←
  --           rpow_lt_rpow_iff hpos, rpow_natCast, ← _root_.map_pow]
  --         simp only [(isUnit_iff_ne_zero.mpr h0).choose_spec]
  --         rw [hn, ← NNReal.coe_lt_coe, _root_.map_pow, NNReal.coe_pow,
  --           ← pow_eq_pow_root_zero_coeff h_alg _
  --             (minpoly.degree_dvd (isAlgebraic_iff_isIntegral.mp (h_alg _))),
  --           ← Real.rpow_lt_rpow_iff (pow_nonneg (DiscreteNormExtension.nonneg h_alg _) _)
  --               (coe_nonneg _) (inv_pos.mpr hpos'),
  --           ← Real.rpow_natCast, ← Real.rpow_mul (DiscreteNormExtension.nonneg h_alg _),
  --           mul_inv_cancel (ne_of_gt hpos'), Real.rpow_one, coe_rpow,
  --           ← Real.rpow_mul (coe_nonneg _)]
  --         exact hx }

attribute [-instance ] Semifield.toCommSemiring
attribute [-instance ] EuclideanDomain.toCommRing

/-- `L` is a complete space with respect to the topology induced by `extended-valuation`. -/
instance (priority := 100) completeSpace [FiniteDimensional K L] :
    @CompleteSpace L (uniformSpace (Algebra.IsAlgebraic.of_finite K L)) :=
  letI : NontriviallyNormedField K := nontriviallyDiscretelyNormedField K
  spectral_norm_completeSpace (Algebra.IsAlgebraic.of_finite K L) (norm_isNonarchimedean K)

--porting note: the @[protected] attribute has been commented
-- @[protected]
theorem isComplete [FiniteDimensional K L] :
    @IsComplete L (uniformSpace (Algebra.IsAlgebraic.of_finite K L)) Set.univ := by
  letI := uniformSpace (Algebra.IsAlgebraic.of_finite K L)
  rw [← completeSpace_iff_isComplete_univ]
  infer_instance

variable {K L}

theorem le_one_of_integer [fr : IsFractionRing hv.v.valuationSubring K] [FiniteDimensional K L]
    (x : integralClosure hv.v.valuationSubring L) : extendedValuation K L (x : L) ≤ 1 :=
  letI : IsFractionRing hv.v.valuationSubring.toSubring K := fr
  (Extension.le_one_iff_discreteNormExtension_le_one _).mpr
    (DiscreteValuation.DiscreteNormExtension.le_one_of_integer _ x)

variable (K L)

theorem integralClosure_eq_integer [FiniteDimensional K L] :
    (integralClosure hv.v.valuationSubring L).toSubring =
      (extendedValuation K L).valuationSubring.toSubring := by sorry
  -- classical
  -- have h_alg : Algebra.IsAlgebraic K L := Algebra.IsAlgebraic.of_finite K L
  -- ext x
  -- simp only [Subalgebra.mem_toSubring, ValuationSubring.mem_toSubring, mem_valuationSubring_iff,
  --   mem_integralClosure_iff, IsIntegral, RingHom.IsIntegralElem]
  -- refine' ⟨fun hx => le_one_of_integer ⟨x, hx⟩, fun hx => _⟩
  -- · rw [Extension.le_one_iff_discreteNormExtension_le_one] at hx
  --   let q := minpoly K x
  --   have hq : ∀ n : ℕ, q.coeff n ∈ hv.v.valuationSubring := (le_one_iff_integral_minpoly _ _).mp hx
  --   set p : Polynomial hv.v.valuationSubring := intPolynomial hv.v hq
  --   refine'
  --     ⟨intPolynomial hv.v hq,
  --       (IntPolynomial.monic_iff hv.v hq).mpr
  --         (minpoly.monic (isAlgebraic_iff_isIntegral.mp (h_alg x))),
  --       by rw [IntPolynomial.eval₂_eq, minpoly.aeval]⟩

end Extension

open Extension

namespace integralClosure


--MI : Otherwise the next instance times out.
instance :  Add (integralClosure hv.v.valuationSubring L) :=
  @AddMemClass.add _ _ _ _ _ (integralClosure (↥Valued.v.valuationSubring) L)

/-- The integral closure of the the valuation subring of `K` in `L` is a discrete valuation ring.
  (Chapter 2, Section 2, Proposition 3 in Serre's Local Fields) -/
instance discreteValuationRing_of_finite_extension [FiniteDimensional K L] :
    DiscreteValuationRing (integralClosure hv.v.valuationSubring L) := by
  letI hw : Valued L ℤₘ₀ := Valued.mk' (extendedValuation K L)
  letI hw_disc : IsDiscrete hw.v := Extension.isDiscrete_of_finite K L
  let e : (extendedValuation K L).valuationSubring ≃+* integralClosure hv.v.valuationSubring L :=
    RingEquiv.subringCongr (integralClosure_eq_integer K L).symm
  exact RingEquiv.discreteValuationRing e

end integralClosure

variable [FiniteDimensional K L]

/- PORTING NOTE: no macro or `[quot_precheck]` instance for syntax kind 'Lean.Parser.Term.proj'
found
  (extendedValuation K L).valuationSubring
This means we cannot eagerly check your notation/quotation for unbound identifiers; you can use
`set_option quotPrecheck false` to disable this check.-/
set_option quotPrecheck false
local notation "L₀" => (extendedValuation K L).valuationSubring

/-- The valuation subring of `L` with respect to `extendedValuation K L` is an algebra over the
  valuation subring of `K`. -/
instance ValuationSubring.algebra : Algebra K₀ L₀ :=
  haveI h : Algebra hv.v.valuationSubring (extendedValuation K L).valuationSubring.toSubring := by
    rw [← integralClosure_eq_integer]
    exact (integralClosure (↥Valued.v.valuationSubring) L).algebra
  h

end Complete

end DiscreteValuation
