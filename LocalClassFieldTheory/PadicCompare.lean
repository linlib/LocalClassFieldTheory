import LocalClassFieldTheory.DiscreteValuationRing.Complete
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.NumberTheory.Padics.PadicIntegers
import Mathlib.RingTheory.DedekindDomain.AdicValuation
import LocalClassFieldTheory.ForMathlib.NumberTheory.Padics.PadicIntegers
import LocalClassFieldTheory.ForMathlib.RingTheory.DedekindDomain.Ideal
import LocalClassFieldTheory.FromMathlib.SpecificLimits

/-!

## Main definitions
* `Int.pHeightOneIdeal` the ideal `pℤ` as term of the height_one_spectrum of `ℤ`.

### The field `Q_p`
* `Q_p` is the adic completion of ℚ defined as the uniform completion of the valued field
  `ℚ` endowed with its `p`-adic valued structure.
* `padicPkg'` is the abstract completion of `ℚ` whose underlying space is `Q_p`.
* `padicPkg` is the abstract completion of `ℚ` (endowed with the uniformity coming from the
  `p`-adic valued structure) whose underlying space is "usual" `ℚ_[p]` defined in terms of the
  `p`-adic metric. In particular, terms of `padic_pkg'.space` are limits of abstract Cauchy filters
    as in `topology.uniform_space.completion` while terms of `padic_pkg.space = ℚ_[p]` are limits
    of Cauchy sequences.
* `padic_valued` The valued structure on `ℚ` induced from the `p`-adic valuation.
* `compare` is the uniform equivalence `Q_p p ≃ᵤ ℚ_[p]` among the underlying spaces of the two
  abstract completions `padic_pkg'` and `padic_pkg`.
* `padicEquiv : (Q_p p) ≃+* ℚ_[p] :=` The uniform equivalence `compare` as a ring equivalence.

### The integers
* `Z_p` is the unit ball inside `Q_p`.
* `Padic'Int.heightOneIdeal` The maximal ideal of `Z_p p` as term of the height-one spectrum.
* `padic_int.valuation_subring` Is `ℤ_[p]` seen as valuation_subring if `ℚ_[p]`.
* `comap_Zp` Is the valuation subring of `ℚ_[p]` that is the image via the isomorphism
  `padicEquiv` of `Z_p`.
* `padic_int_ring_equiv` Is the ring equivalence between `Z_p p` and `ℤ_[p]`.
* `residue_field` Is the ring equivalence between the residue field of `Z_p p` and `ℤ/pℤ`.


## Main results
* `padic_valued_valuation_p` and `padic'.valuation_p` show that the valuation of `p : ℚ` is the
  same, namely `(-1 : ℤₘ₀), both when coerced to `ℚ_[p]` and to `Q_p p`.
* `valuation_subrings_eq` The equality (as valuation subrings of `ℚ_[p]`) between
  `padic_int.valuation_subring` and `comap_Zp`.
* `Padic'Int.heightOneIdeal_is_principal` is the proof that the maximal ideal of `Z_p` is
  the ideal generated by `p`.


## Implementation details
* In order to put a valued instance on `ℚ` coming from the `p`-adic valuation on `ℤ` we have to
  locally remove several instances on it, notably the metric one, the normed one, the densely
  normed field one, the division ring one, the normed additive commutative group one. With these in
  force, there would be clashes between different uniform structures.
* To create the abstract completion `padic_pkg` we regard `ℚ_[p]` we need a coercion from `ℚ` to
  its completion `ℚ_[p]` that is not definitionally equal to the coercion from `ℚ` to any field of
  characteristic zero. In particular, we need to manually upgrade this coercion to a ring map in the
  `definition coe_ring_hom : ℚ →+* ℚ_[p]`.-/


noncomputable section

open IsDedekindDomain IsDedekindDomain.HeightOneSpectrum

/-- The ideal `pℤ` as term of the height_one_spectrum of `ℤ`.-/
def Int.pHeightOneIdeal (p : semiOutParam ℕ) [hp : Fact p.Prime] : HeightOneSpectrum ℤ
    where
  asIdeal := Ideal.span {(p : ℤ)}
  isPrime := by
    rw [Ideal.span_singleton_prime]
    exacts [Nat.prime_iff_prime_int.mp hp.1, NeZero.natCast_ne p ℤ]
  ne_bot := by
    simp only [Ne.def, Ideal.span_singleton_eq_bot, Nat.cast_eq_zero]
    exact NeZero.ne p

variable (p : outParam ℕ) [Fact p.Prime]

namespace Padic'

open Valuation Int

open scoped DiscreteValuation

attribute [-instance] Rat.instMetricSpaceRat Rat.normedField Rat.denselyNormedField Rat.divisionRing
  Rat.normedAddCommGroup

instance : T0Space ℚ_[p] := inferInstance

/-- The valued structure on `ℚ` induced by the `p`-adic valuation. -/
def padicValued : Valued ℚ ℤₘ₀ := (pHeightOneIdeal p).adicValued


/-- The adic completion of ℚ defined as the uniform completion of the valued field
`ℚ` endowed with its `p`-adic valued structure.-/
@[reducible]
def Q_p : Type _ :=
  adicCompletion ℚ (pHeightOneIdeal p)

instance : IsDiscrete (@Valued.v (Q_p p) _ ℤₘ₀ _ _) :=
  Completion.isDiscrete _ _ _

instance : NormedField (Q_p p) :=
  RankOneValuation.ValuedField.toNormedField (Q_p p) ℤₘ₀

/-- The abstract completion of `ℚ` whose underlying space is `Q_p`. -/
def padicPkg' :
  letI := (padicValued p).toUniformSpace
  AbstractCompletion ℚ :=
  let _ := (padicValued p).toUniformSpace
  { space := Q_p p,
    coe := UniformSpace.Completion.coe' ℚ,
    uniformStruct := inferInstance,
    complete := inferInstance,
    separation := inferInstance,
    uniformInducing := (UniformSpace.Completion.uniformEmbedding_coe ℚ).1,
    dense := UniformSpace.Completion.denseRange_coe }


end Padic'

namespace PadicComparison

open NNReal Polynomial Int NormalizationMonoid Multiplicative Padic Valuation

open scoped Classical NNReal DiscreteValuation

attribute [-instance] Rat.instMetricSpaceRat Rat.normedField Rat.denselyNormedField Rat.divisionRing
  Rat.normedAddCommGroup

/-- This is the valued structure on `ℚ` induced from the `p`-adic valuation. -/
def padicValued : Valued ℚ ℤₘ₀ :=
  (pHeightOneIdeal p).adicValued

instance : T0Space ℚ_[p] := inferInstance

section Valuation

-- porting note: added in Lean4
lemma NNReal_Cast.p_ne_zero : ((p : ℝ≥0) ≠ 0) := by
  have := @Nat.Prime.ne_zero p Fact.out
  simp_all only [ne_eq, Nat.cast_eq_zero, not_false_eq_true]


theorem padicNorm_of_Int_eq_val_norm (x : ℤ) : (padicNorm p x : ℝ) =
  withZeroMultIntToNNReal (NNReal_Cast.p_ne_zero p) ((@padicValued p _).v x) := by
  classical
  by_cases hx : x = 0
  · simp only [hx, padicNorm.zero, algebraMap.coe_zero, _root_.map_zero, cast_zero, padicNorm.zero,
      Rat.cast_zero, _root_.map_zero, NNReal.coe_zero]
  · have hx0 : ¬(x : ℚ) = 0 := cast_ne_zero.mpr hx
    have hv0 : ((@padicValued p _).v x) ≠ (0 : ℤₘ₀) := by rw [Ne.def, zero_iff]; exact hx0
    have heq : Multiplicative.ofAdd (-(Associates.mk (pHeightOneIdeal p).asIdeal).count
      (Associates.mk (Ideal.span {x} : Ideal ℤ)).factors : ℤ) = WithZero.unzero hv0 := by
      erw [← WithZero.coe_inj, ← intValuationDef_if_neg _ hx, WithZero.coe_unzero,
        valuation_of_algebraMap]
      rfl
    rw [padicNorm.eq_zpow_of_nonzero hx0, withZeroMultIntToNNReal, Rat.cast_zpow, Rat.cast_natCast,
      MonoidWithZeroHom.coe_mk, ZeroHom.coe_mk, withZeroMultIntToNNRealDef_neg_apply, ← heq,
      padicValRat.of_int, @padicValInt.of_ne_one_ne_zero p x (Nat.Prime.ne_one Fact.out) hx,
      toAdd_ofAdd]
    simp only [UniqueFactorizationMonoid.multiplicity_eq_count_normalizedFactors
        (Nat.prime_iff_prime_int.mp Fact.out).irreducible hx, normalize_apply,
          PartENat.get_natCast']
    have h_x_span : (Ideal.span {x} : Ideal ℤ) ≠ 0 := by
      rwa [Ideal.zero_eq_bot, Ne.def, Ideal.span_singleton_eq_bot]
    have h_p_span : (Ideal.span {(p : ℤ)} : Ideal ℤ).IsPrime := by
      simp only [Ideal.span_singleton_prime (NeZero.ne (p : ℤ)), Nat.prime_iff_prime_int.mp Fact.out]
    have h_p_span_ne : (Ideal.span {(p : ℤ)} : Ideal ℤ) ≠ ⊥ := by
      rw [Ne.def, Ideal.span_singleton_eq_bot]
      exact NeZero.ne (p : ℤ)
    erw [count_normalizedFactors_eq_count_normalizedFactors_span hx _ (by rfl),
      ← NormalizationMonoid.count_normalizedFactors_eq_associates_count _ _ _ h_x_span h_p_span
      h_p_span_ne]
    congr
    · exact mul_right_eq_self₀.mpr (Or.inl rfl)
    · exact prime_mul_iff.mpr (Or.inl ⟨Nat.prime_iff_prime_int.mp Fact.out, Units.isUnit _⟩)
    · exact mul_ne_zero (NeZero.ne (p : ℤ)) (Units.ne_zero _)


theorem padicNorm_eq_val_norm (z : ℚ) : (padicNorm p z : ℝ) =
  withZeroMultIntToNNReal (NNReal_Cast.p_ne_zero p) ((@padicValued p _).v z) := by
  by_cases hz : z = 0
  · simp only [hz, padicNorm.zero, algebraMap.coe_zero, _root_.map_zero, Rat.cast_zero,
      NNReal.coe_zero]
  · obtain ⟨x, y, hxy⟩ := IsLocalization.mk'_surjective (nonZeroDivisors ℤ) z
    have hz : IsLocalization.mk' ℚ x y = x / y := by
      simp only [IsFractionRing.mk'_eq_div, eq_intCast,/-  _root_.coe_coe -/]
    erw [← hxy, valuation_of_mk', hz, padicNorm.div,/-  _root_.coe_coe,  -/Rat.cast_div, map_div₀,
      /- Nonneg.coe_div -/]
    apply congr_arg₂ <;>
    · convert padicNorm_of_Int_eq_val_norm p _; erw [valuation_of_algebraMap]

end Valuation

section AbstractCompletion


/-The natural map from ℚ to ℚ_[p], seen as a field of characeristic zero, is uniformInducing when
  the rational field is endowed with the `p`-adic uniformity. -/
theorem uniformInducing_cast : letI := ((@padicValued p _))
  UniformInducing (Rat.cast : ℚ → ℚ_[p]) := by
  let _ := ((@padicValued p _))
  have hp_one : (1 : ℝ≥0) < p := Nat.one_lt_cast.mpr (Nat.Prime.one_lt Fact.out)
  apply UniformInducing.mk'
  simp_rw [@Metric.mem_uniformity_dist ℚ_[p] _ _]
  refine' fun S => ⟨fun hS => _, _⟩
  · obtain ⟨m, ⟨-, hM_sub⟩⟩ := (Valued.hasBasis_uniformity ℚ ℤₘ₀).mem_iff.mp hS
    set M := (withZeroMultIntToNNReal (NNReal_Cast.p_ne_zero p) m.1).1 with hM
    refine' ⟨{p : ℚ_[p] × ℚ_[p] | dist p.1 p.2 < M}, ⟨⟨M, ⟨_, fun _ => _ ⟩⟩, fun x y h => _⟩⟩
    · exact withZeroMultIntToNNReal_pos _ (isUnit_iff_ne_zero.mp (Units.isUnit m))
    · tauto
    · apply hM_sub
      simp only [Set.mem_setOf_eq, dist] at h ⊢
      rwa [hM, ← Padic.coe_sub, padicNormE.eq_padic_norm', padicNorm_eq_val_norm,
        val_eq_coe, coe_lt_coe, @StrictMono.lt_iff_lt _ _ _ _ _
        (withZeroMultIntToNNReal_strictMono hp_one), ← neg_sub, Valuation.map_neg] at h
  · rw [(Valued.hasBasis_uniformity ℚ ℤₘ₀).mem_iff]
    rintro ⟨T, ⟨ε, ⟨hε, H⟩⟩, h⟩
    obtain ⟨M, hM⟩ := Real.exists_strictMono_lt (withZeroMultIntToNNReal_strictMono hp_one) hε
    refine' ⟨M, by triv, fun q hq => _⟩
    simp only [Set.mem_setOf_eq, dist] at H hq
    have : (↑q.fst, ↑q.snd) ∈ T := by
      apply H
      rw [← Padic.coe_sub, padicNormE.eq_padic_norm', padicNorm_eq_val_norm, ← neg_sub,
        Valuation.map_neg]
      exact (NNReal.coe_lt_coe.mpr
        ((withZeroMultIntToNNReal_strictMono hp_one).lt_iff_lt.mpr hq)).trans hM
    exact h _ _ this

/-The natural map from ℚ to ℚ_[p], seen as a field of characeristic zero, has dense range when
  the rational field is endowed with the `p`-adic uniformity. -/
theorem dense_cast : DenseRange (Rat.cast : ℚ → ℚ_[p]) := by
  rw [Metric.denseRange_iff]
  have := Padic.rat_dense p
  intro x r hr
  obtain ⟨s, hs⟩ := this x hr
  use s
  have : ‖x - ↑s‖ = dist x ↑s := by rfl
  rw [this] at hs
  convert hs

/-- The abstract completion of `ℚ` (endowed with the uniformity coming from the `p`-adic valued
  structure) whose underlying space is `ℚ_[p]`-/
def padicPkg : letI := (padicValued p).toUniformSpace
  AbstractCompletion ℚ :=
  let _ := (padicValued p).toUniformSpace
  { space := ℚ_[p]
    coe := Rat.cast
    uniformStruct := inferInstance
    complete := inferInstance
    separation := inferInstance
    uniformInducing := uniformInducing_cast p
    dense := dense_cast p}

/-- The coercion from the uniform space `ℚ` to its uniform completion `ℚ_[p]` as a ring
  homomorphims. Beware that this is not the coercion from `ℚ` to `ℚ_[p]` induced from the structure
  of characteristic-zero field on `ℚ_[p]`. -/
def coeRingHom : ℚ →+* ℚ_[p] :=
  let _ := (padicValued p).toUniformSpace
  { toFun := (padicPkg p).2
    map_one' := Rat.cast_one
    map_mul' := Rat.cast_mul
    map_zero' := Rat.cast_zero
    map_add' := Rat.cast_add }

end AbstractCompletion

open Padic'

section Comparison

/-- The main result is the uniform equivalence from `Q_p p` and `ℚ_[p]`-/
def compare : Q_p p ≃ᵤ ℚ_[p] :=
  let _ := (padicValued p).toUniformSpace
  AbstractCompletion.compareEquiv (padicPkg' p) (padicPkg p)

theorem uniformContinuous_cast : letI := (padicValued p).toUniformSpace
  UniformContinuous (Rat.cast : ℚ → ℚ_[p]) :=
  let _ := (padicValued p).toUniformSpace
  (uniformInducing_iff'.1 (uniformInducing_cast p)).1

/-- The upgrade of the comparison as a ring homomorphism -/
def extensionAsRingHom : Q_p p →+* ℚ_[p] :=
  let _ := (padicValued p).toUniformSpace
  UniformSpace.Completion.extensionHom (coeRingHom p) (uniformContinuous_cast p).continuous

theorem extensionAsRingHom_toFun : letI := (padicValued p).toUniformSpace
  (extensionAsRingHom p).toFun = UniformSpace.Completion.extension (Rat.cast : ℚ → ℚ_[p]) :=
  rfl

theorem extension_eq_compare : (extensionAsRingHom p).toFun = (compare p).toFun := by
  let _ := (padicValued p).toUniformSpace
  simp only [Equiv.toFun_as_coe, UniformEquiv.coe_toEquiv]
  apply UniformSpace.Completion.extension_unique (uniformContinuous_cast p)
    ((padicPkg' p).uniformContinuous_compareEquiv (padicPkg p))
  intro a
  have : (padicPkg p).coe a = (↑a : ℚ_[p]) := rfl
  rw [← this, ← AbstractCompletion.compare_coe]
  rfl

/-- The uniform equivalence `compare` as a ring equivalence -/
def padicEquiv : Q_p p ≃+* ℚ_[p] :=
  { compare p with
    map_mul' := by rw [← extension_eq_compare p]; use (extensionAsRingHom p).map_mul'
    map_add' := by rw [← extension_eq_compare p]; exact (extensionAsRingHom p).map_add' }

instance : CharZero (Q_p p) := (padicEquiv p).toRingHom.charZero

instance : Algebra ℚ_[p] (Q_p p) := RingHom.toAlgebra (PadicComparison.padicEquiv p).symm

instance : IsScalarTower ℚ ℚ_[p] (Q_p p) where smul_assoc r x y :=
  by {simp only [Algebra.smul_def, eq_ratCast, _root_.map_mul, map_ratCast, mul_assoc]}

theorem Padic'.coe_eq (x : ℚ) : letI := (padicValued p).toUniformSpace
   (x : Q_p p) = ((padicPkg' p).coe x : (padicPkg' p).space) := by
  let _ := (padicValued p).toUniformSpace
  have hp : (x : Q_p p) = (padicPkg p).compare (padicPkg' p) (x : ℚ_[p]) := by
    have h : (padicPkg p).compare (padicPkg' p) (x : ℚ_[p]) = algebraMap ℚ_[p] (Q_p p) x := rfl
    rw [h, map_ratCast]
  rw [← AbstractCompletion.compare_coe (padicPkg p) (padicPkg' p), hp]
  rfl

theorem padicValued_valuation_p :
    @Valued.v ℚ _ ℤₘ₀ _ (padicValued p) (p : ℚ) = ofAdd (-1 : ℤ) := by
  have hp : (p : ℚ) = algebraMap ℤ ℚ (p : ℤ) := rfl
  rw [adicValued_apply, hp, valuation_of_algebraMap, intValuation_apply,
    intValuationDef_if_neg (pHeightOneIdeal p) (NeZero.natCast_ne p ℤ)]
  simp only [ofAdd_neg, WithZero.coe_inv, reduceNeg, inv_inj, WithZero.coe_inj,
    EmbeddingLike.apply_eq_iff_eq, Nat.cast_eq_one]
  apply Associates.count_self
  simpa [Associates.irreducible_mk] using (prime (pHeightOneIdeal p)).irreducible


theorem Padic'.valuation_p : Valued.v (p : Q_p p) = ofAdd (-1 : ℤ) := by
  let _ : Valued ℚ ℤₘ₀ := padicValued p
  have hp : (p : Q_p p) = ((Rat.cast : ℚ → Q_p p) p : Q_p p) := by
    have : ∀ x : ℚ, (Rat.cast : ℚ → Q_p p) x = (x : Q_p p) := by intro x; rw [Padic'.coe_eq]
    rw [this]; simp only [Rat.cast_natCast]
  erw [hp, Padic'.coe_eq, Valued.valuedCompletion_apply (p : ℚ), padicValued_valuation_p p]

end Comparison

section Z_p

/-- The unit ball in `Q_p` -/
@[reducible]
def Z_p := (@Valued.v (Q_p p) _ ℤₘ₀ _ _).valuationSubring

theorem exists_mem_le_one_of_lt_one {x : Q_p p} (hx : Valued.v x ≤ (1 : ℤₘ₀)) :
    ∃ y : Z_p p, (y : Q_p p) = x ∧ Valued.v (y : Q_p p) = Valued.v x := by
  have hv := (@Valued.v (Q_p p) _ ℤₘ₀ _ _).isEquiv_valuation_valuationSubring
  use ⟨x,
    ValuationSubring.mem_of_valuation_le_one (Z_p p) x
    (((Valuation.isEquiv_iff_val_le_one _ _).mp hv).mp hx)⟩

theorem exists_mem_lt_one_of_lt_one {x : Q_p p} (hx : Valued.v x < (1 : ℤₘ₀)) :
    ∃ y : Z_p p, (y : Q_p p) = x ∧ Valued.v (y : Q_p p) = Valued.v x := by
  have hv := (@Valued.v (Q_p p) _ ℤₘ₀ _ _).isEquiv_valuation_valuationSubring
  use ⟨x, ValuationSubring.mem_of_valuation_le_one (Z_p p) x
    (le_of_lt <| ((Valuation.isEquiv_iff_val_lt_one _ _).mp hv).mp hx)⟩

instance : CharZero (Z_p p) where cast_injective m n h := by
  { simp only [Subtype.ext_iff, Subring.coe_natCast, Nat.cast_inj] at h
    exact h}

/-- The maximal ideal of `Z_p p` as an element of the height-one spectrum -/
def Padic'Int.heightOneIdeal : HeightOneSpectrum (Z_p p) where
  asIdeal := LocalRing.maximalIdeal (Z_p p)
  isPrime := Ideal.IsMaximal.isPrime (LocalRing.maximalIdeal.isMaximal _)
  ne_bot := by simpa [Ne.def, ← LocalRing.isField_iff_maximalIdeal_eq] using
    DiscreteValuation.not_isField _

theorem Padic'Int.heightOneIdeal_is_principal :
    (Padic'Int.heightOneIdeal p).asIdeal = Ideal.span {(p : Z_p p)} :=
  DiscreteValuation.IsUniformizer_is_generator _ (Padic'.valuation_p p)

instance : Valued (Q_p p) ℤₘ₀ := HeightOneSpectrum.valuedAdicCompletion ℚ (pHeightOneIdeal p)

/-- The ring `ℤ_[p]` as a valuation subring of `ℚ_[p]`. -/
def PadicInt.valuationSubring : ValuationSubring ℚ_[p] where
  toSubring := PadicInt.subring p
  mem_or_inv_mem' := by
    have not_field : ¬IsField ℤ_[p] := DiscreteValuationRing.not_isField _
    -- Marking `not_field` as a separate assumption makes the computation faster
    have := ((DiscreteValuationRing.TFAE ℤ_[p] not_field).out 0 1).mp (by infer_instance)
    intro x
    rcases(ValuationRing.iff_isInteger_or_isInteger ℤ_[p] ℚ_[p]).mp this x with (hx | hx)
    · apply Or.intro_left
      obtain ⟨y, hy⟩ := hx
      rw [← hy]
      simp only [PadicInt.algebraMap_apply, Subring.mem_carrier, PadicInt.mem_subring_iff,
        PadicInt.padic_norm_e_of_padicInt]
      apply PadicInt.norm_le_one
    · apply Or.intro_right
      obtain ⟨y, hy⟩ := hx
      rw [← hy]
      simp only [PadicInt.algebraMap_apply, Subring.mem_carrier, PadicInt.mem_subring_iff,
        PadicInt.padic_norm_e_of_padicInt]
      apply PadicInt.norm_le_one


open Filter

open scoped Filter Topology

/-- The valuation subring of `ℚ_[p]` that is the image via the isomorphism `padicEquiv` of `Z_p`-/
@[reducible]
def comap_Zp : ValuationSubring ℚ_[p] :=
  ValuationSubring.comap (Z_p p) (padicEquiv p).symm.toRingHom


/-- The two lemmas `padic_int.nonunit_mem_iff_top_nilpotent` and
`UnitBall.nonunit_mem_iff_top_nilpotent` have basically the same proof, except that in the first we
 use that `x : ℚ_[p]` satisfies ‖ x ‖ < 1 iff `p ∣ x` and in the other that `x : (Q_p p)` satisfies
 `‖ x ‖ < 1` iff it belongs to the maximal ideal. -/
theorem PadicInt.nonunit_mem_iff_top_nilpotent (x : ℚ_[p]) :
    x ∈ (PadicInt.valuationSubring p).nonunits ↔
    Filter.Tendsto (fun n : ℕ => x ^ n) atTop (𝓝 0) := by
  have aux : ∀ n : ℕ, ‖x ^ n‖ = ‖x‖ ^ n := fun n => norm_pow _ n
  rw [tendsto_zero_iff_norm_tendsto_zero, Filter.tendsto_congr aux]
  refine' ⟨fun H => _, fun H => _⟩
  · obtain ⟨h1, h2⟩ := ValuationSubring.mem_nonunits_iff_exists_mem_maximalIdeal.mp H
    exact _root_.tendsto_pow_atTop_nhds_zero_of_lt_one (norm_nonneg _)
      (PadicInt.mem_nonunits.mp <| (LocalRing.mem_maximalIdeal _).mp h2)
  · have : ‖x‖ < 1 := by
      suffices (⟨‖x‖, norm_nonneg _⟩ : ℝ≥0) < 1 by
        rwa [← NNReal.coe_lt_coe, NNReal.coe_one] at this
      apply NNReal.lt_one_of_tendsto_pow_0
      rwa [← NNReal.tendsto_coe, NNReal.coe_zero]
    apply ValuationSubring.mem_nonunits_iff_exists_mem_maximalIdeal.mpr
    exact
      ⟨(PadicInt.mem_subring_iff p).mpr (le_of_lt this),
        (LocalRing.mem_maximalIdeal _).mpr (PadicInt.mem_nonunits.mpr this)⟩

theorem mem_unit_ball_of_tendsto_zero {x : Q_p p} (H : Tendsto (fun n : ℕ => ‖x‖ ^ n) atTop (𝓝 0))
    /- (h_go : ‖x‖ < 1)  -/: x ∈ (Z_p p).nonunits := by
  apply ValuationSubring.mem_nonunits_iff_exists_mem_maximalIdeal.mpr
  have : ‖x‖ < 1 := by
    suffices (⟨‖x‖, norm_nonneg _⟩ : ℝ≥0) < 1 by
      rwa [← NNReal.coe_lt_coe, NNReal.coe_one] at this
    apply NNReal.lt_one_of_tendsto_pow_0
    rw [← NNReal.tendsto_coe, NNReal.coe_zero]
    exact H
  replace this : Valued.v x < (1 : ℤₘ₀) := by
    apply (RankOneValuation.norm_lt_one_iff_val_lt_one x).mp this
  obtain ⟨y, hy₁, hy₂⟩ := exists_mem_lt_one_of_lt_one p this
  rw [← hy₂] at this
  rw [← hy₁]
  simp only [Subtype.coe_eta, LocalRing.mem_maximalIdeal, mem_nonunits_iff, SetLike.coe_mem,
    exists_const]
  rw [← Completion.adic_of_compl_eq_compl_of_adic ℤ (pHeightOneIdeal p) ℚ ↑y] at this
  have v_lt_one :=
    @IsDedekindDomain.HeightOneSpectrum.valuation_lt_one_iff_dvd (Z_p p) _ _ (Q_p p) _ _ _
      (Completion.maxIdealOfCompletion ℤ (pHeightOneIdeal p) ℚ) y
  have eq_y : (algebraMap (↥(Z_p p)) (Q_p p)) y = (↑y : Q_p p) := rfl
  rw [eq_y] at v_lt_one
  simp only [v_lt_one, Ideal.dvd_span_singleton, mem_nonunits_iff,
    ValuationSubring.algebraMap_apply, /- SetLike.coe_mk,  -/forall_true_left] at this
  exact this

theorem UnitBall.nonunit_mem_iff_top_nilpotent (x : Q_p p) :
    x ∈ (Z_p p).nonunits ↔ Filter.Tendsto (fun n : ℕ => x ^ n) atTop (𝓝 0) := by
  have h_max_ideal : (Padic'Int.heightOneIdeal p).asIdeal = LocalRing.maximalIdeal ↥(Z_p p) :=
    rfl
  have aux : ∀ n : ℕ, ‖x ^ n‖ = ‖x‖ ^ n := fun n => norm_pow _ n
  rw [tendsto_zero_iff_norm_tendsto_zero, Filter.tendsto_congr aux]
  refine' ⟨fun H => _, fun H => _⟩
  · obtain ⟨h, x_mem⟩ := ValuationSubring.mem_nonunits_iff_exists_mem_maximalIdeal.mp H
    have :=
      (@valuation_lt_one_iff_dvd (Z_p p) _ _ (Q_p p) _ _ _ (Padic'Int.heightOneIdeal p)
          ⟨x, h⟩).mpr
    simp only [h_max_ideal, Ideal.dvd_span_singleton, mem_nonunits_iff,
      ValuationSubring.algebraMap_apply, x_mem, forall_true_left] at this
    replace this : Valued.v x < (1 : ℤₘ₀) := by
      convert this using 1
      exact (Completion.adic_of_compl_eq_compl_of_adic ℤ (Int.pHeightOneIdeal p) ℚ x).symm
    exact tendsto_pow_atTop_nhds_zero_of_lt_one (norm_nonneg _)
      ((RankOneValuation.norm_lt_one_iff_val_lt_one _).mpr this)
  · exact mem_unit_ball_of_tendsto_zero p H

theorem mem_nonunits_iff (x : Q_p p) :
    x ∈ (Z_p p).nonunits ↔ (padicEquiv p) x ∈ (comap_Zp p).nonunits := by
  let φ : Z_p p ≃+* comap_Zp p := by
    have := (Z_p p).toSubring.comap_equiv_eq_map_symm (padicEquiv p).symm
    replace this := RingEquiv.subringCongr this.symm
    exact (@RingEquiv.subringMap _ _ _ _ (Z_p p).toSubring (padicEquiv p)).trans this
  refine' ⟨fun hx => _, fun hx => _⟩
  all_goals
    rw [ValuationSubring.mem_nonunits_iff_exists_mem_maximalIdeal] at hx
    rw [ValuationSubring.mem_nonunits_iff_exists_mem_maximalIdeal]
  · refine ⟨_, map_nonunit (f := (↑φ : Z_p p →+* comap_Zp p)) _ hx.choose_spec⟩
  · rcases hx with ⟨h1, h2⟩
    have h3 := ValuationSubring.mem_comap.mp h1
    have : (padicEquiv p).symm.toRingHom ((padicEquiv p) x) =
        (padicEquiv p).symm.toRingHom ((padicEquiv p).toRingHom x) :=
      rfl
    simp_rw [this, ← RingHom.comp_apply, RingEquiv.symm_toRingHom_comp_toRingHom,
      RingHom.id_apply] at h3
    have h4 : φ.symm (⟨(padicEquiv p) x, h1⟩ : { z // z ∈ comap_Zp p }) = ⟨x, h3⟩ := by
      set b : ℚ_[p] := ↑(φ ⟨x, h3⟩) with hb
      have : b = (padicEquiv p) x := rfl
      simp_rw [← this, hb, SetLike.eta, RingEquiv.symm_apply_apply]
    replace h2 := map_nonunit (↑φ.symm : comap_Zp p →+* Z_p p) _ h2
    erw [h4] at h2
    refine ⟨_, h2⟩

theorem valuation_subrings_eq : PadicInt.valuationSubring p = comap_Zp p := by
  rw [← ValuationSubring.nonunits_inj]
  ext x
  refine' ⟨fun hx => _, fun hx => _⟩
  · rw [← (padicEquiv p).apply_symm_apply x]
    rw [← mem_nonunits_iff, UnitBall.nonunit_mem_iff_top_nilpotent, ←
      _root_.map_zero (padicEquiv p).symm]
    simp_rw [← _root_.map_pow (padicEquiv p).symm]
    apply Tendsto.comp
    · exact ((compare p).3.continuous).continuousAt
    rwa [← PadicInt.nonunit_mem_iff_top_nilpotent]
  · rw [← (padicEquiv p).apply_symm_apply x, ← mem_nonunits_iff,
      UnitBall.nonunit_mem_iff_top_nilpotent] at hx
    replace hx :=
      @Tendsto.comp ℕ (Q_p p) ℚ_[p] (fun n => (padicEquiv p).symm x ^ n) (padicEquiv p) atTop
        (𝓝 0) (𝓝 0) ?_ hx
    -- We postpone the verification of the first assumption in `tendsto.comp`
    · simp_rw [← _root_.map_pow (padicEquiv p).symm x, Function.comp,
        RingEquiv.apply_symm_apply] at hx
      rwa [PadicInt.nonunit_mem_iff_top_nilpotent]
    · rw [← _root_.map_zero (padicEquiv p)]
      apply Continuous.tendsto (compare p).symm.3.continuous 0

theorem padic_int_ring_equiv_range :
  (Z_p p).map (padicEquiv p).toRingHom = PadicInt.subring p := by
  have : (comap_Zp p).toSubring = (PadicInt.valuationSubring p).toSubring := by
    rw [← valuation_subrings_eq]
  convert this
  ext x
  simp only [Subring.mem_carrier, Subring.mem_map, mem_valuationSubring_iff, exists_prop,
    ValuationSubring.mem_comap]
  constructor
  · rintro ⟨y, ⟨hy, H⟩⟩
    rw [← H]
    simp only [ValuationSubring.mem_toSubring, ValuationSubring.mem_comap,
      RingEquiv.symm_toRingHom_apply_toRingHom_apply, mem_valuationSubring_iff] at hy ⊢
    exact hy
  · intro hx
    simp at hx
    use(padicEquiv p).symm.toRingHom x
    constructor
    · simp only [ValuationSubring.mem_toSubring, mem_valuationSubring_iff]
      exact hx
    simp only [RingEquiv.toRingHom_apply_symm_toRingHom_apply]

/-- The ring equivalence between `Z_p p` and `ℤ_[p]`. -/
noncomputable def padicIntRingEquiv : Z_p p ≃+* ℤ_[p] :=
  (RingEquiv.subringMap _).trans (RingEquiv.subringCongr (padic_int_ring_equiv_range p))

/-- The ring equivalence between the residue field of `Z_p p` and `ℤ/pℤ`. -/
def residueField : LocalRing.ResidueField (Z_p p) ≃+* ZMod p :=
  (LocalRing.ResidueField.mapEquiv (padicIntRingEquiv p)).trans (PadicInt.residueField p)

end Z_p

end PadicComparison
