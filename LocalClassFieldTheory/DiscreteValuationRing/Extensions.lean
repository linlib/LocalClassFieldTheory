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

* `discrete_valuation.pow_extension_on_units` : The map sending `x : Lˣ` to
  `(v ((minpoly K x.1).coeff 0))^((finrank K L)/(minpoly K x.1).nat_degree)`.
* `discrete_valuation.exp_extension_on_units` : the natural number `n` such that `of_add (n : ℤ)`
  generates the image of the map `pow_extension_on_units K L`.
* `discrete_valuation.extended_valuation` : the unique discrete valuation on `L` induced by the
  valuation on `K`.
* `discrete_valuation.valuation_subring.algebra` : the valuation subring of `L` with respect to
  `extended_valuation K L` is an algebra over the valuation subring of `K`.

## Main Results

* `discrete_valuation.exp_extension_on_units_generates_range` : The image of
 `pow_extension_on_units K L` is  generated by `of_add (exp_extension_on_units K L : ℤ)`.
* `discrete_valuation.exp_extension_on_units_dvd` : The number `exp_extension_on_units K L`
  divides the degree of `L` over `K`.
* `discrete_valuation.extension.is_discrete_of_finite` : the extended valuation on `L` is discrete.
* `discrete_valuation.extension.complete_space` : `L` is a complete space with respect to the
  topology induced by `extended_valuation`.
* `discrete_valuation.integral_closure.discrete_valuation_ring_of_finite_extension` : the integral
  closure of the the valuation subring of `K` in `L` is a discrete valuation ring.


## Tags

valuation, is_discrete, discrete_valuation_ring
-/


-- import for_mathlib.field_theory.minpoly.is_integrally_closed
-- import for_mathlib.field_theory.minpoly.is_integrally_closed
noncomputable section

open AddSubgroup DiscreteValuation DiscreteValuation.discreteNormExtension Function Multiplicative
  NNReal FiniteDimensional minpoly Polynomial Subgroup Valuation WithZero

open scoped DiscreteValuation NNReal

theorem Multiplicative.toSubgroup_mem_iff {G : Type _} [AddGroup G] (S : AddSubgroup G)
    (x : Multiplicative G) : x ∈ toSubgroup S ↔ x.toAdd ∈ S := by rfl

namespace DiscreteValuation

section Complete

variable {K : Type _} [Field K] [hv : Valued K ℤₘ₀] {L : Type _} [Field L] [Algebra K L]

local notation "K₀" => hv.V.ValuationSubring

instance : NoZeroSMulDivisors K₀ (integralClosure K₀ L)
    where eq_zero_or_eq_zero_of_smul_eq_zero c x h :=
    by
    rw [Algebra.smul_def, mul_eq_zero] at h
    refine' h.imp_left fun hc => _
    rw [← map_zero (algebraMap K₀ (integralClosure K₀ L))] at hc
    exact IsFractionRing.injective K₀ K ((algebraMap K L).Injective (subtype.ext_iff.mp hc))

variable [IsDiscrete hv.V] [CompleteSpace K]

theorem map_hMul_aux [FiniteDimensional K L] (x y : Lˣ) :
    Valued.v ((minpoly K ((x : L) * ↑y)).coeff 0) ^
        (finrank K L / (minpoly K ((x : L) * ↑y)).natDegree) =
      Valued.v ((minpoly K (x : L)).coeff 0) ^ (finrank K L / (minpoly K (x : L)).natDegree) *
        Valued.v ((minpoly K (y : L)).coeff 0) ^ (finrank K L / (minpoly K (y : L)).natDegree) :=
  by
  have h_alg : Algebra.IsAlgebraic K L := Algebra.isAlgebraic_of_finite K L
  have hinj : injective (withZeroMultIntToNnreal (base_ne_zero K hv.v)) :=
    (withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)).Injective
  rw [← Function.Injective.eq_iff hinj, _root_.map_mul, ← Units.val_mul, map_pow_div, map_pow_div,
    map_pow_div, ← mul_rpow, rpow_eq_rpow_iff (nat.cast_ne_zero.mpr (ne_of_gt finrank_pos))]
  ext
  rw [NNReal.coe_mul, coe_rpow, coe_rpow, coe_rpow, ← eq_root_zero_coeff h_alg, ←
    eq_root_zero_coeff h_alg, ← eq_root_zero_coeff h_alg, Units.val_mul, _root_.map_mul]
  · infer_instance
  · infer_instance

variable (K L)

/-- The map sending `x : Lˣ` to the `(finrank K L)/(minpoly K x.1).nat_degree`th power of the
valuation of the zeroth coefficient of its minimal polynomial, that is, to
`(v ((minpoly K x.1).coeff 0))^((finrank K L)/(minpoly K x.1).nat_degree)`, as an
element of `multiplicative ℤ`. -/
def powExtensionOnUnits [FiniteDimensional K L] : Lˣ →* Multiplicative ℤ
    where
  toFun x := WithZero.unzero (Valuation.unit_pow_ne_zero hv.V x)
  map_one' := by
    simp only [Units.val_eq_coe, Units.val_one, one, Polynomial.coeff_sub, Polynomial.coeff_X_zero,
      Polynomial.coeff_one_zero, zero_sub, Valuation.map_neg, Valuation.map_one, one_pow,
      unzero_coe]
  map_mul' x y :=
    by
    have h_alg : Algebra.IsAlgebraic K L := Algebra.isAlgebraic_of_finite K L
    simp only [Units.val_eq_coe, Units.val_mul]
    rw [← WithZero.coe_inj, WithZero.coe_mul, WithZero.coe_unzero, WithZero.coe_unzero,
      WithZero.coe_unzero]
    exact map_mul_aux x y

theorem powExtensionOnUnits_apply [FiniteDimensional K L] (x : Lˣ) :
    powExtensionOnUnits K L x = WithZero.unzero (Valuation.unit_pow_ne_zero hv.V x) :=
  rfl

/-- The natural number `n` such that the image of the map `pow_extension_on_units K L` is
generated by `of_add (n : ℤ)`. -/
def expExtensionOnUnits [FiniteDimensional K L] : ℕ :=
  Int.natAbs (Int.subgroup_cyclic (map (powExtensionOnUnits K L) ⊤).toAddSubgroup).some

variable {K L}

theorem expExtensionOnUnits_generates_range' [FiniteDimensional K L] :
    Subgroup.toAddSubgroup (Subgroup.map (powExtensionOnUnits K L) ⊤) =
      AddSubgroup.closure {(exp_extension_on_units K L : ℤ)} :=
  by
  rw [(Int.subgroup_cyclic (map (pow_extension_on_units K L) ⊤).toAddSubgroup).choose_spec, ←
    zmultiples_eq_closure, ← zmultiples_eq_closure, exp_extension_on_units, Int.zmultiples_natAbs]

theorem expExtensionOnUnits_ne_zero [FiniteDimensional K L] : expExtensionOnUnits K L ≠ 0 :=
  by
  have h_alg : Algebra.IsAlgebraic K L := Algebra.isAlgebraic_of_finite K L
  obtain ⟨x, hx⟩ := exists_uniformizer_of_discrete hv.v
  have hx_unit : IsUnit (x : K) := is_unit_iff_ne_zero.mpr (uniformizer_ne_zero hv.v hx)
  rw [is_uniformizer] at hx
  set z : Lˣ := Units.map (algebraMap K L).toMonoidHom (IsUnit.unit hx_unit) with hz
  by_contra h0
  have h := exp_extension_on_units_generates_range'
  rw [h0, ZMod.nat_cast_self, closure_singleton_zero, _root_.map_eq_bot_iff,
    Subgroup.map_eq_bot_iff, top_le_iff] at h
  have hz1 : pow_extension_on_units K L z = 1 := by rw [← MonoidHom.mem_ker, h]; exact mem_top _
  have hzne1 : pow_extension_on_units K L z ≠ 1 :=
    by
    have hv :
      Valued.v ((minpoly K ((Units.map (algebraMap K L).toMonoidHom) hx_unit.unit).val).coeff 0) =
        Valued.v (x : K) :=
      by
      rw [RingHom.toMonoidHom_eq_coe, Units.val_eq_coe, Units.coe_map, IsUnit.unit_spec,
        RingHom.coe_monoidHom, Valuation.coeff_zero]
    rw [hz, pow_extension_on_units_apply, Ne.def, ← WithZero.coe_inj, coe_unzero, hv, hx, ←
      of_add_neg_nat, ← ofAdd_zero, WithZero.coe_inj, RingHom.toMonoidHom_eq_coe, Units.val_eq_coe,
      Units.coe_map, IsUnit.unit_spec, RingHom.coe_monoidHom, Int.coe_nat_div, ofAdd_neg,
      ofAdd_zero, inv_eq_one, ofAdd_eq_one, ← Int.coe_nat_div, Int.coe_nat_eq_zero,
      Nat.div_eq_zero_iff (minpoly.natDegree_pos (is_algebraic_iff_is_integral.mp (h_alg _)))]
    exact not_lt.mpr (minpoly.natDegree_le (is_algebraic_iff_is_integral.mp (h_alg _)))
  exact hzne1 hz1

variable (K L)

theorem expExtensionOnUnits_pos [FiniteDimensional K L] : 0 < expExtensionOnUnits K L :=
  Nat.pos_of_ne_zero expExtensionOnUnits_ne_zero

variable {K L}

/-- The image of `pow_extension_on_units K L` is generated by
  `of_add (exp_extension_on_units K L : ℤ)`. -/
theorem expExtensionOnUnits_generates_range [FiniteDimensional K L] :
    map (powExtensionOnUnits K L) ⊤ = closure {ofAdd (expExtensionOnUnits K L : ℤ)} :=
  by
  have h :
    to_subgroup (to_add_subgroup (map (pow_extension_on_units K L) ⊤)) =
      to_subgroup (closure {(exp_extension_on_units K L : ℤ)}) :=
    by rw [exp_extension_on_units_generates_range']
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
      Subgroup.closure ({of_add (exp_extension_on_units K L : ℤ)} : Set (Multiplicative ℤ)) :=
    by
    rw [← exp_extension_on_units_generates_range, Subgroup.mem_map]
    exact ⟨x, mem_top x, rfl⟩
  rw [Subgroup.mem_closure_singleton] at h_mem
  obtain ⟨n, hn⟩ := h_mem
  use-n
  rw [WithZero.ofAdd_neg_one_pow_comm n, ← WithZero.coe_zpow, hn, WithZero.coe_unzero]
  rfl

variable (L)

/-- The number `exp_extension_on_units K L` divides the degree of `L` over `K`. -/
theorem expExtensionOnUnits_dvd [FiniteDimensional K L] : expExtensionOnUnits K L ∣ finrank K L :=
  by
  have h_alg := Algebra.isAlgebraic_of_finite K L
  obtain ⟨π, hπ⟩ := exists_uniformizer_of_discrete hv.v
  set u : L := algebraMap K L (π : K) with hu_def
  have hu0 : u ≠ 0 := by
    rw [hu_def, Ne.def, _root_.map_eq_zero]
    exact uniformizer_ne_zero hv.v hπ
  obtain ⟨n, hn⟩ := exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hu0).Unit
  have hu : ((is_unit_iff_ne_zero.mpr hu0).Unit : L) = u := rfl
  have hne_zero : ((minpoly K ((algebraMap K L) ↑π)).natDegree : ℤ) ≠ 0 :=
    by
    rw [Nat.cast_ne_zero, ← pos_iff_ne_zero]
    exact minpoly.natDegree_pos (is_algebraic_iff_is_integral.mp (h_alg _))
  have h_dvd : ((minpoly K ((algebraMap K L) ↑π)).natDegree : ℤ) ∣ finrank K L :=
    int.coe_nat_dvd.mpr (minpoly.degree_dvd (is_algebraic_iff_is_integral.mp (h_alg _)))
  rw [hu, hu_def, Valuation.coeff_zero, is_uniformizer_iff.mp hπ, ← WithZero.coe_pow, ←
    WithZero.coe_zpow, ← WithZero.coe_pow, WithZero.coe_inj, ← zpow_ofNat, ← zpow_mul, ← zpow_ofNat,
    of_add_pow_comm, of_add_pow_comm (-1)] at hn
  simp only [zpow_neg, zpow_one, inv_inj] at hn
  replace hn := of_add_inj hn
  have hn0 : 0 ≤ n :=
    by
    refine' nonneg_of_mul_nonneg_left _ (nat.cast_pos.mpr (exp_extension_on_units_pos K L))
    rw [hn]
    exact Nat.cast_nonneg _
  rw [Int.coe_nat_div, eq_comm, Int.ediv_eq_iff_eq_mul_right hne_zero h_dvd] at hn
  use(minpoly K ((algebraMap K L) ↑π)).natDegree * n.to_nat
  rw [mul_comm, ← @Nat.cast_inj ℤ _, hn, Nat.cast_mul, Nat.cast_mul, Int.toNat_of_nonneg hn0,
    mul_assoc]

variable {L}

/-- The underlying map to the discrete valuation on `L` induced by the valuation on `K`. -/
def extensionDef [FiniteDimensional K L] : L → ℤₘ₀ := fun x => by
  classical exact
    if hx : x = 0 then 0
    else
      of_add (-1 : ℤ) ^ (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hx).Unit).some

variable {K}

theorem extensionDef_apply [FiniteDimensional K L] (x : L) :
    extensionDef K x =
      if hx : x = 0 then 0
      else
        ofAdd (-1 : ℤ) ^ (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).Unit).some :=
  rfl

theorem extensionDef_hMul [FiniteDimensional K L] (x y : L) :
    extensionDef K (x * y) = extensionDef K x * extensionDef K y :=
  by
  have h_alg : Algebra.IsAlgebraic K L := Algebra.isAlgebraic_of_finite K L
  by_cases hx : x = 0
  · have hxy : x * y = 0 := by rw [hx, MulZeroClass.zero_mul]
    rw [extension_def_apply, dif_pos hxy, extension_def_apply, dif_pos hx, MulZeroClass.zero_mul]
  · by_cases hy : y = 0
    · have hxy : x * y = 0 := by rw [hy, MulZeroClass.mul_zero]
      rw [extension_def_apply (x * y), dif_pos hxy, extension_def_apply y, dif_pos hy,
        MulZeroClass.mul_zero]
    · have hxy : x * y ≠ 0 := mul_ne_zero hx hy
      simp only [extension_def_apply]
      rw [dif_neg hx, dif_neg hy, dif_neg (mul_ne_zero hx hy)]
      have hinj : injective (withZeroMultIntToNnreal (base_ne_zero K hv.v)) :=
        (withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)).Injective
      rw [← Function.Injective.eq_iff hinj, ← pow_left_inj _ _ (exp_extension_on_units_pos K L), ←
        NNReal.coe_eq, _root_.map_mul, mul_pow, ← _root_.map_pow,
        (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hxy).Unit).choose_spec,
        NNReal.coe_mul]
      nth_rw 2 [← _root_.map_pow]
      rw [(exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hx).Unit).choose_spec]
      nth_rw 3 [← _root_.map_pow]
      rw [(exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hy).Unit).choose_spec,
        _root_.map_pow, NNReal.coe_pow, ← pow_eq_pow_root_zero_coeff h_alg, _root_.map_pow,
        NNReal.coe_pow, ← pow_eq_pow_root_zero_coeff h_alg, _root_.map_pow, NNReal.coe_pow, ←
        pow_eq_pow_root_zero_coeff h_alg, ← mul_pow, ← mul h_alg]
      rfl
      any_goals exact minpoly.degree_dvd (is_algebraic_iff_is_integral.mp (h_alg _))
      · exact zero_le'
      · exact zero_le'

theorem extensionDef_add [FiniteDimensional K L] (x y : L) :
    extensionDef K (x + y) ≤ max (extensionDef K x) (extensionDef K y) :=
  by
  have h_alg : Algebra.IsAlgebraic K L := Algebra.isAlgebraic_of_finite K L
  by_cases hx : x = 0
  · have hxy : x + y = y := by rw [hx, zero_add]
    simp only [extension_def_apply, dif_pos hx, hxy]
    rw [max_eq_right]
    exact le_refl _
    · exact zero_le'
  · by_cases hy : y = 0
    · have hxy : x + y = x := by rw [hy, add_zero]
      simp only [extension_def_apply, dif_pos hy, hxy]
      rw [max_eq_left]
      exact le_refl _
      · exact zero_le'
    · by_cases hxy : x + y = 0
      · simp only [extension_def_apply, dif_pos hxy, zero_le']
      · simp only [extension_def_apply, dif_neg hx, dif_neg hy, dif_neg hxy]
        set ux := (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hx).Unit).some with
          hux_def
        set uy := (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hy).Unit).some with
          huy_def
        set uxy :=
          (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hxy).Unit).some with
          huxy_def
        rw [← hux_def, ← huy_def, ← huxy_def]
        rw [_root_.le_max_iff]
        simp only [← WithZero.coe_zpow, coe_le_coe]
        have hd : 0 < (exp_extension_on_units K L : ℤ) :=
          by
          rw [Int.coe_nat_pos]
          exact Nat.pos_of_ne_zero exp_extension_on_units_ne_zero
        rw [← zpow_le_zpow_iff' hd, zpow_ofNat, zpow_ofNat, ← coe_le_coe, WithZero.coe_pow,
          WithZero.coe_zpow,
          (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hxy).Unit).choose_spec]
        rw [WithZero.coe_pow, WithZero.coe_zpow,
          (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hx).Unit).choose_spec]
        rw [← zpow_le_zpow_iff' hd, zpow_ofNat, zpow_ofNat]
        nth_rw 2 [← coe_le_coe]
        simp only [WithZero.coe_pow, WithZero.coe_zpow,
          (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hxy).Unit).choose_spec,
          (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hy).Unit).choose_spec]
        simp only [← (withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)).le_iff_le, ←
          NNReal.coe_le_coe]
        rw [_root_.map_pow, NNReal.coe_pow, ← Real.rpow_nat_cast, Nat.cast_div, ←
          pow_eq_pow_root_zero_coeff' h_alg]
        --x + y
        rw [_root_.map_pow, NNReal.coe_pow, ←
          Real.rpow_nat_cast _ (finrank K L / (minpoly K _).natDegree), Nat.cast_div, ←
          pow_eq_pow_root_zero_coeff' h_alg]
        -- x
        rw [_root_.map_pow, NNReal.coe_pow, ←
          Real.rpow_nat_cast _ (finrank K L / (minpoly K _).natDegree), Nat.cast_div, ←
          pow_eq_pow_root_zero_coeff' h_alg]
        -- y
        have h_le :
          (discrete_norm_extension h_alg) (x + y) ≤ (discrete_norm_extension h_alg) x ∨
            (discrete_norm_extension h_alg) (x + y) ≤ (discrete_norm_extension h_alg) y :=
          by
          rw [← _root_.le_max_iff]
          exact (IsNonarchimedean h_alg) _ _
        cases' h_le with hlex hley
        · left
          exact pow_le_pow_of_le_left (nonneg h_alg _) hlex _
        · right
          exact pow_le_pow_of_le_left (nonneg h_alg _) hley _
        repeat' exact minpoly.degree_dvd (is_algebraic_iff_is_integral.mp (h_alg _))
        repeat'
          rw [Nat.cast_ne_zero]
          exact ne_of_gt (minpoly.natDegree_pos (is_algebraic_iff_is_integral.mp (h_alg _)))

variable (K L)

theorem extensionDef_one [FiniteDimensional K L] : extensionDef K (1 : L) = 1 :=
  by
  have h1 : (1 : L) ≠ 0 := one_ne_zero
  rw [extension_def_apply, dif_neg h1]
  set u := (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr h1).Unit).some with hu_def
  have hu :
    (↑(of_add (-1 : ℤ)) ^ u) ^ exp_extension_on_units K L =
      Valued.v ((minpoly K ↑(is_unit_iff_ne_zero.mpr h1).Unit).coeff 0) ^
        (finrank K L / (minpoly K ((is_unit_iff_ne_zero.mpr h1).Unit : L)).natDegree) :=
    (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr h1).Unit).choose_spec
  simp only [IsUnit.unit_spec, one, coeff_sub, coeff_X_zero, coeff_one_zero, zero_sub,
    Valuation.map_neg, Valuation.map_one, one_pow, inv_eq_one] at hu
  simp only [← WithZero.coe_one, ← ofAdd_zero, ← WithZero.coe_zpow, ← WithZero.coe_pow,
    WithZero.coe_inj, ← zpow_ofNat, ← Int.ofAdd_mul] at hu
  have hu' := Int.eq_zero_or_eq_zero_of_mul_eq_zero hu
  rw [← WithZero.coe_one, ← ofAdd_zero, ← WithZero.coe_zpow, WithZero.coe_inj, ← Int.ofAdd_mul,
    (or_eq_of_eq_false_right _).mp hu']
  · simp only [exp_extension_on_units_ne_zero, Nat.cast_eq_zero]

/-- The discrete valuation on `L` induced by the valuation on `K`. -/
def extendedValuation [FiniteDimensional K L] : Valuation L ℤₘ₀
    where
  toFun := extensionDef K
  map_zero' := by rw [extension_def_apply, dif_pos rfl]
  map_one' := extensionDef_one K L
  map_mul' := extensionDef_hMul
  map_add_le_max' := extensionDef_add

namespace Extension

variable {K L}

theorem apply [FiniteDimensional K L] (x : L) :
    extendedValuation K L x =
      if hx : x = 0 then 0
      else
        ofAdd (-1 : ℤ) ^ (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).Unit).some :=
  rfl

theorem apply_if_neg [FiniteDimensional K L] {x : L} (hx : x ≠ 0) :
    extendedValuation K L x =
      ofAdd (-1 : ℤ) ^ (exists_mul_expExtensionOnUnits K (isUnit_iff_ne_zero.mpr hx).Unit).some :=
  by rw [apply, dif_neg hx]

theorem le_one_iff_discreteNormExtension_le_one [FiniteDimensional K L] (x : L) :
    extendedValuation K L x ≤ (1 : ℤₘ₀) ↔
      discreteNormExtension (Algebra.isAlgebraic_of_finite K L) x ≤ 1 :=
  by
  set h_alg := Algebra.isAlgebraic_of_finite K L
  rw [apply]
  split_ifs with hx
  · simp only [hx, _root_.map_zero, zero_le_one]
  · have h_le_iff :
      discrete_norm_extension h_alg x ≤ 1 ↔ discrete_norm_extension h_alg x ^ finrank K L ≤ 1 :=
      by
      rw [pow_le_one_iff_of_nonneg (nonneg h_alg _) (ne_of_gt finrank_pos)]
      repeat' infer_instance
    set n := (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hx).Unit).some with
      hn_def
    rw [← hn_def, h_le_iff,
      pow_eq_pow_root_zero_coeff _ _
        (minpoly.degree_dvd (is_algebraic_iff_is_integral.mp (h_alg x))),
      ← NNReal.coe_pow, ← _root_.map_pow]
    erw [← (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr hx).Unit).choose_spec]
    rw [← hn_def, ← NNReal.coe_one, NNReal.coe_le_coe, ←
      _root_.map_one (withZeroMultIntToNnreal (base_ne_zero K hv.v)),
      (withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)).le_iff_le, ← WithZero.coe_one, ←
      WithZero.coe_zpow, WithZero.coe_le_coe, ← WithZero.coe_pow, WithZero.coe_le_coe, ← zpow_ofNat,
      ← Int.ofAdd_mul, ← Int.ofAdd_mul, ← ofAdd_zero, of_add_le, of_add_le]
    exact
      ⟨fun h => mul_nonpos_of_nonpos_of_nonneg h (Nat.cast_nonneg _), fun h =>
        nonpos_of_mul_nonpos_left h (nat.cast_pos.mpr (exp_extension_on_units_pos K L))⟩

variable (K L)

theorem exists_generating_unit [FiniteDimensional K L] :
    ∃ x : Lˣ, powExtensionOnUnits K L x = ofAdd (-expExtensionOnUnits K L : ℤ) :=
  by
  have h_mem :
    of_add (exp_extension_on_units K L : ℤ) ∈
      Subgroup.closure {of_add (exp_extension_on_units K L : ℤ)} :=
    subgroup.mem_closure_singleton.mpr ⟨1, by rw [zpow_one]⟩
  rw [← exp_extension_on_units_generates_range, Subgroup.mem_map] at h_mem
  obtain ⟨x, _, hx⟩ := h_mem
  use x⁻¹
  rw [map_inv, hx]
  rfl

/-- The extended valuation on `L` is discrete. -/
instance isDiscreteOfFinite [FiniteDimensional K L] : IsDiscrete (extendedValuation K L) :=
  by
  set x := (exists_generating_unit K L).some
  have hx := (exists_generating_unit K L).choose_spec
  rw [← WithZero.coe_inj] at hx
  simp only [pow_extension_on_units, Units.val_eq_coe, MonoidHom.coe_mk, coe_unzero,
    of_add_neg_nat] at hx
  have hπ1 : extended_valuation K L x = Multiplicative.ofAdd (-1 : ℤ) :=
    by
    rw [extension.apply_if_neg, ←
      WithZero.zpow_left_inj _ WithZero.coe_ne_zero
        (nat.cast_ne_zero.mpr exp_extension_on_units_ne_zero)]
    · have hx0 : (x : L) ≠ 0 := Units.ne_zero _
      rw [zpow_ofNat, zpow_ofNat, ← hx]
      erw [(exists_mul_exp_extension_on_units K x).choose_spec]
      rfl
    · exact zpow_ne_zero _ WithZero.coe_ne_zero
      exact Units.ne_zero _
  set π : (extended_valuation K L).ValuationSubring :=
    ⟨(exists_generating_unit K L).some, by
      rw [mem_valuation_subring_iff, hπ1] <;> exact le_of_lt WithZero.ofAdd_neg_one_lt_one⟩
  have hπ : extended_valuation K L (π : L) = Multiplicative.ofAdd (-1 : ℤ) := hπ1
  apply is_discrete_of_exists_uniformizer (extended_valuation K L) hπ

variable {K L}

/-- The uniform space structure on `L` induced by `discrete_valuation.extended_valuation`. -/
@[protected]
def uniformSpace (h_alg : Algebra.IsAlgebraic K L) : UniformSpace L :=
  discretelyNormedFieldExtensionUniformSpace h_alg

variable (K L)

/-- The normed field structure on `L` induced by the spectral norm.  -/
@[protected]
def normedField [FiniteDimensional K L] : NormedField L :=
  by
  have h_alg := Algebra.isAlgebraic_of_finite K L
  letI : NontriviallyNormedField K := nontrivially_discretely_normed_field K
  exact spectralNormToNormedField h_alg (norm_is_nonarchimedean K)

/-- The valued field structure on `L` induced by `discrete_valuation.extended_valuation`.  -/
@[protected]
def valued [FiniteDimensional K L] : Valued L ℤₘ₀ :=
  letI : NormedField L := NormedField K L
  { UniformSpace (Algebra.isAlgebraic_of_finite K L),
    NonUnitalNormedRing.toNormedAddCommGroup with
    V := extended_valuation K L
    is_topological_valuation := fun U =>
      by
      have hpos : 0 < (exp_extension_on_units K L : ℝ) :=
        nat.cast_pos.mpr (exp_extension_on_units_pos K L)
      have hpos' : 0 < (finrank K L : ℝ) := nat.cast_pos.mpr finrank_pos
      have h_alg := Algebra.isAlgebraic_of_finite K L
      rw [Metric.mem_nhds_iff]
      refine' ⟨fun h => _, fun h => _⟩
      · obtain ⟨ε, hε, h⟩ := h
        obtain ⟨δ, hδ⟩ :=
          Real.exists_strictMono_lt (withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)) hε
        use δ ^ (finrank K L / exp_extension_on_units K L)
        intro x hx
        simp only [Set.mem_setOf_eq, extension.apply] at hx
        apply h
        rw [mem_ball_zero_iff]
        split_ifs at hx  with h0 h0
        · rw [h0, norm_zero]; exact hε
        · set n := (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr h0).Unit).some with
            hn_def
          set hn :=
            (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr h0).Unit).choose_spec
          rw [← hn_def] at hx
          have hx' :=
            Real.rpow_lt_rpow (NNReal.coe_nonneg _)
              ((withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)) hx) hpos
          rw [Real.rpow_nat_cast, ← NNReal.coe_pow, ← _root_.map_pow, hn, _root_.map_pow,
            NNReal.coe_pow, ←
            discrete_norm_extension.pow_eq_pow_root_zero_coeff h_alg _
              (minpoly.degree_dvd
                (is_algebraic_iff_is_integral.mp (h_alg ↑(is_unit_iff_ne_zero.mpr h0).Unit)))] at
            hx'
          rw [← Real.rpow_lt_rpow_iff (norm_nonneg _) (le_of_lt hε) hpos', Real.rpow_nat_cast]
          apply lt_trans hx'
          rw [Units.val_pow_eq_pow_val, _root_.map_pow, NNReal.coe_pow, Real.rpow_nat_cast, ←
            pow_mul, Nat.div_mul_cancel (exp_extension_on_units_dvd K L), ← Real.rpow_nat_cast,
            Real.rpow_lt_rpow_iff (NNReal.coe_nonneg _) (le_of_lt hε) hpos']
          exact hδ
      · obtain ⟨ε, hε⟩ := h
        have hε_pos :
          0 <
            (withZeroMultIntToNnreal (base_ne_zero K hv.v) ε : ℝ) ^
              ((exp_extension_on_units K L : ℝ) / (finrank K L : ℝ)) :=
          by
          apply rpow_pos
          rw [← _root_.map_zero (withZeroMultIntToNnreal (base_ne_zero K hv.v)),
            (withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)).lt_iff_lt]
          exact Units.zero_lt _
        use(withZeroMultIntToNnreal (base_ne_zero K hv.v) ε : ℝ) ^
            ((exp_extension_on_units K L : ℝ) / (finrank K L : ℝ)),
          hε_pos
        intro x hx
        rw [mem_ball_zero_iff] at hx
        apply hε
        rw [Set.mem_setOf_eq, extension.apply]
        split_ifs with h0 h0
        · exact Units.zero_lt _
        · set n := (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr h0).Unit).some with
            hn_def
          set hn :=
            (exists_mul_exp_extension_on_units K (is_unit_iff_ne_zero.mpr h0).Unit).choose_spec
          rw [← hn_def] at hn ⊢
          rw [← (withZeroMultIntToNnreal_strictMono (one_lt_base K hv.v)).lt_iff_lt, ←
            rpow_lt_rpow_iff hpos, rpow_nat_cast, ← _root_.map_pow, hn, ← NNReal.coe_lt_coe,
            _root_.map_pow, NNReal.coe_pow, ←
            pow_eq_pow_root_zero_coeff h_alg _
              (minpoly.degree_dvd (is_algebraic_iff_is_integral.mp (h_alg _))),
            ←
            Real.rpow_lt_rpow_iff (pow_nonneg (discrete_norm_extension.nonneg h_alg _) _)
              (coe_nonneg _) (inv_pos.mpr hpos'),
            ← Real.rpow_nat_cast, ← Real.rpow_mul (discrete_norm_extension.nonneg h_alg _),
            mul_inv_cancel (ne_of_gt hpos'), Real.rpow_one, coe_rpow, ←
            Real.rpow_mul (coe_nonneg _)]
          exact hx }

/-- `L` is a complete space with respect to the topology induced by `extended-valuation`. -/
@[protected]
instance (priority := 100) completeSpace [FiniteDimensional K L] :
    @CompleteSpace L (UniformSpace (Algebra.isAlgebraic_of_finite K L)) :=
  letI : NontriviallyNormedField K := nontrivially_discretely_normed_field K
  spectral_norm_completeSpace (Algebra.isAlgebraic_of_finite K L) (norm_is_nonarchimedean K)

@[protected]
theorem isComplete [FiniteDimensional K L] :
    @IsComplete L (UniformSpace (Algebra.isAlgebraic_of_finite K L)) Set.univ :=
  by
  rw [← completeSpace_iff_isComplete_univ]
  infer_instance

variable {K L}

theorem le_one_of_integer [fr : IsFractionRing hv.V.ValuationSubring K] [FiniteDimensional K L]
    (x : integralClosure hv.V.ValuationSubring L) : extendedValuation K L (x : L) ≤ 1 :=
  letI : IsFractionRing hv.v.valuation_subring.to_subring K := fr
  (extension.le_one_iff_discrete_norm_extension_le_one _).mpr (le_one_of_integer _ x)

variable (K L)

theorem integralClosure_eq_integer [FiniteDimensional K L] :
    (integralClosure hv.V.ValuationSubring L).toSubring =
      (extendedValuation K L).ValuationSubring.toSubring :=
  by
  classical
  have h_alg : Algebra.IsAlgebraic K L := Algebra.isAlgebraic_of_finite K L
  ext x
  simp only [Subalgebra.mem_toSubring, ValuationSubring.mem_toSubring, mem_valuation_subring_iff,
    mem_integralClosure_iff, IsIntegral, RingHom.IsIntegralElem]
  refine' ⟨fun hx => le_one_of_integer ⟨x, hx⟩, fun hx => _⟩
  · rw [extension.le_one_iff_discrete_norm_extension_le_one] at hx
    let q := minpoly K x
    have hq : ∀ n : ℕ, q.coeff n ∈ hv.v.valuation_subring := (le_one_iff_integral_minpoly _ _).mp hx
    set p : Polynomial hv.v.valuation_subring := int_polynomial hv.v hq
    refine'
      ⟨int_polynomial hv.v hq,
        (int_polynomial.monic_iff hv.v hq).mpr
          (minpoly.monic (is_algebraic_iff_is_integral.mp (h_alg x))),
        by rw [int_polynomial.eval₂_eq, minpoly.aeval]⟩

end Extension

open Extension

namespace integralClosure

/-- The integral closure of the the valuation subring of `K` in `L` is a discrete valuation ring.
  (Chapter 2, Section 2, Proposition 3 in Serre's Local Fields) -/
instance discreteValuationRing_of_finite_extension [FiniteDimensional K L] :
    DiscreteValuationRing (integralClosure hv.V.ValuationSubring L) :=
  by
  letI hw : Valued L ℤₘ₀ := Valued.mk' (extended_valuation K L)
  letI hw_disc : is_discrete hw.v := extension.is_discrete_of_finite K L
  let e : (extended_valuation K L).ValuationSubring ≃+* integralClosure hv.v.valuation_subring L :=
    RingEquiv.subringCongr (integral_closure_eq_integer K L).symm
  exact RingEquiv.discreteValuationRing e

end integralClosure

variable [FiniteDimensional K L]

local notation "L₀" => (extendedValuation K L).ValuationSubring

/-- The valuation subring of `L` with respect to `extended_valuation K L` is an algebra over the
  valuation subring of `K`. -/
def ValuationSubring.algebra : Algebra K₀ L₀ :=
  haveI h : Algebra hv.v.valuation_subring (extended_valuation K L).ValuationSubring.toSubring :=
    by
    rw [← integral_closure_eq_integer]
    exact (integralClosure (↥valued.v.valuation_subring) L).Algebra
  h

end Complete

end DiscreteValuation
