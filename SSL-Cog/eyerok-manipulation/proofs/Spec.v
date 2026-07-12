From Coq Require Import Lia ZArith.

Local Open Scope Z_scope.

Inductive hand_rank : Type := FirstHand | SecondHand.

Inductive vertical_mode : Type :=
| Controlled
| Ballistic
| Runaway
| Deleted.

Definition eyerok_home_y : Z := -1534.
Definition direct_position_y_max : Z := -934.
Definition area3_static_y_max : Z := 896.
Definition hand_collision_top_max : Z := 507.
Definition upward_travel_max : Z := 300.

Definition support_ceiling (rank : hand_rank) : Z :=
  match rank with
  | FirstHand => area3_static_y_max
  | SecondHand => 1703
  end.

Definition height_ceiling (rank : hand_rank) : Z :=
  support_ceiling rank + upward_travel_max.

Definition global_height_ceiling : Z := 2003.

Definition attacked_ascent_budget : Z := 98.
Definition die_ascent_budget : Z := 288.
Definition double_pound_ascent_budget : Z := 285.
Definition runaway_delta : Z := 100.

Lemma ceiling_values :
  support_ceiling FirstHand = 896 /\
  height_ceiling FirstHand = 1196 /\
  support_ceiling SecondHand = 1703 /\
  height_ceiling SecondHand = global_height_ceiling.
Proof. repeat split; reflexivity. Qed.

Lemma support_plus_budget_is_height_ceiling : forall rank,
  support_ceiling rank + upward_travel_max = height_ceiling rank.
Proof. reflexivity. Qed.

Lemma height_ceiling_le_global : forall rank,
  height_ceiling rank <= global_height_ceiling.
Proof. destruct rank; cbv [height_ceiling support_ceiling global_height_ceiling
  upward_travel_max area3_static_y_max]; lia. Qed.

Lemma direct_position_below_every_ceiling : forall rank,
  direct_position_y_max <= height_ceiling rank.
Proof. destruct rank; cbv [direct_position_y_max height_ceiling support_ceiling
  upward_travel_max area3_static_y_max]; lia. Qed.

Lemma upward_travel_max_nonnegative : 0 <= upward_travel_max.
Proof. cbv [upward_travel_max]. lia. Qed.

Lemma authentic_budgets_are_conservative :
  0 <= attacked_ascent_budget <= upward_travel_max /\
  0 <= die_ascent_budget <= upward_travel_max /\
  0 <= double_pound_ascent_budget <= upward_travel_max.
Proof.
  cbv [attacked_ascent_budget die_ascent_budget double_pound_ascent_budget
    upward_travel_max].
  repeat split; lia.
Qed.
