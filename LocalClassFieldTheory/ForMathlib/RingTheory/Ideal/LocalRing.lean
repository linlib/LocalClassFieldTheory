import Mathlib.LinearAlgebra.FiniteDimensional
import Mathlib.RingTheory.Ideal.LocalRing

noncomputable section

open LocalRing

variable {R S : Type} [CommRing R] [CommRing S] [LocalRing R] [LocalRing S] [Algebra R S]

instance [IsLocalRingHom (algebraMap R S)] : Algebra (ResidueField R) (ResidueField S) :=
  (ResidueField.map (algebraMap R S)).toAlgebra

instance [IsLocalRingHom (algebraMap R S)] : Algebra R (ResidueField S) :=
  ((ResidueField.map <| algebraMap R S).comp <| residue R).toAlgebra

instance [IsLocalRingHom (algebraMap R S)] : IsScalarTower R (ResidueField R) (ResidueField S) :=
  IsScalarTower.of_algebraMap_eq (congrFun rfl)

lemma FiniteDimensional_of_finite (H : IsNoetherian R S) (hloc : IsLocalRingHom (algebraMap R S))
  : FiniteDimensional (ResidueField R) (ResidueField S) := by
  apply IsNoetherian.iff_fg.mp <|
    isNoetherian_of_tower R (S := ResidueField R) (M := ResidueField S) _
  convert isNoetherian_of_surjective S (Ideal.Quotient.mkₐ R (maximalIdeal S)).toLinearMap
    (LinearMap.range_eq_top.mpr Ideal.Quotient.mk_surjective)
  congr
  exact Algebra.algebra_ext _ _ (fun r => rfl)

lemma ResidueField.finite_of_finite (H : IsNoetherian R S) (hloc : IsLocalRingHom (algebraMap R S))
  (hfin : Finite (ResidueField R)) : Finite (ResidueField S) := by
  have := FiniteDimensional_of_finite H
  exact FiniteDimensional.finite_of_finite (ResidueField R) (ResidueField S)
