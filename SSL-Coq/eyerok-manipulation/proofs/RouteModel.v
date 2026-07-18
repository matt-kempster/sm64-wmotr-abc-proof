From Coq Require Import ZArith.

Local Open Scope Z_scope.

Inductive ssl_area : Type := Area2 | Area3.

Inductive route_floor : Type :=
| HandSurface
| Area3Warp1D
| Area2Base896
| Area2Mid1280
| Area2Mid1967
| Area2Mid2940
| Area2Upper4429
| Area2Star4815
| FloorPending.

Inductive route_motion : Type := RouteAirborne | RouteGrounded.

Record mario_route_state : Type := {
  route_area : ssl_area;
  route_x : Z;
  route_y : Z;
  route_z : Z;
  route_vx : Z;
  route_vy : Z;
  route_vz : Z;
  route_floor_of : route_floor;
  route_motion_of : route_motion
}.

Definition enter_area2 (before : mario_route_state) : mario_route_state :=
  {| route_area := Area2;
     route_x := route_x before;
     route_y := route_y before;
     route_z := route_z before;
     route_vx := route_vx before;
     route_vy := route_vy before;
     route_vz := route_vz before;
     route_floor_of := FloorPending;
     route_motion_of := route_motion_of before |}.

Inductive instant_warp_step : mario_route_state -> mario_route_state -> Prop :=
| area3_warp_1d_to_area2 : forall before,
    route_area before = Area3 ->
    route_floor_of before = Area3Warp1D ->
    instant_warp_step before (enter_area2 before).

Definition with_floor
    (state : mario_route_state) (floor : route_floor) : mario_route_state :=
  {| route_area := route_area state;
     route_x := route_x state;
     route_y := route_y state;
     route_z := route_z state;
     route_vx := route_vx state;
     route_vy := route_vy state;
     route_vz := route_vz state;
     route_floor_of := floor;
     route_motion_of := route_motion_of state |}.

Definition between (low value high : Z) : Prop := low <= value <= high.

Definition in_area3_warp_footprint (state : mario_route_state) : Prop :=
  between (-191) (route_x state) 192 /\
  between (-1222) (route_z state) (-1023).

Definition in_area2_upper_overlap (state : mario_route_state) : Prop :=
  between (-204) (route_x state) 512 /\
  between (-1125) (route_z state) (-767).

Definition in_area2_mid1967 (state : mario_route_state) : Prop :=
  between 131 (route_x state) 387 /\
  between (-716) (route_z state) (-460).

Definition floor_query_eligible (query_y floor_y : Z) : Prop :=
  floor_y - 78 <= query_y.

Inductive arrival_floor_selection : mario_route_state -> route_floor -> Prop :=
| arrival_select_upper : forall state,
    route_area state = Area2 ->
    in_area2_upper_overlap state ->
    floor_query_eligible (route_y state) 4429 ->
    arrival_floor_selection state Area2Upper4429
| arrival_select_base : forall state,
    route_area state = Area2 ->
    in_area3_warp_footprint state ->
    (~ in_area2_upper_overlap state \/ route_y state < 4351) ->
    floor_query_eligible (route_y state) 896 ->
    arrival_floor_selection state Area2Base896
| arrival_select_mid1280_audited : forall state,
    route_area state = Area2 ->
    route_x state = 0 ->
    route_y state = 1264 ->
    route_z state = -829 ->
    arrival_floor_selection state Area2Mid1280.

Definition controlled_air_frame
    (dx dz gravity : Z) (before : mario_route_state) : mario_route_state :=
  {| route_area := route_area before;
     route_x := route_x before + dx;
     route_y := route_y before + route_vy before;
     route_z := route_z before + dz;
     route_vx := dx;
     route_vy := route_vy before - gravity;
     route_vz := dz;
     route_floor_of := FloorPending;
     route_motion_of := RouteAirborne |}.

Fixpoint controlled_air_frames
    (frames : nat) (dx dz gravity : Z) (state : mario_route_state)
    : mario_route_state :=
  match frames with
  | O => state
  | S rest =>
      controlled_air_frames rest dx dz gravity
        (controlled_air_frame dx dz gravity state)
  end.

Definition can_land_on_mid1967
    (dx dz : Z) (before : mario_route_state) : Prop :=
  let intended := controlled_air_frame dx dz 2 before in
  route_area before = Area2 /\
  route_y before >= 1967 /\
  route_y intended <= 1967 /\
  in_area2_mid1967 intended.

Definition land_on_mid1967
    (dx dz : Z) (before : mario_route_state) : mario_route_state :=
  let intended := controlled_air_frame dx dz 2 before in
  {| route_area := Area2;
     route_x := route_x intended;
     route_y := 1967;
     route_z := route_z intended;
     route_vx := dx;
     route_vy := 0;
     route_vz := dz;
     route_floor_of := Area2Mid1967;
     route_motion_of := RouteGrounded |}.

Definition within_air_speed_48 (dx dz : Z) : Prop :=
  dx * dx + dz * dz <= 48 * 48.

Definition inside_ancient_pyramid_star_horizontal
    (state : mario_route_state) : Prop :=
  (route_x state - 500) * (route_x state - 500) +
  (route_z state + 500) * (route_z state + 500) < 117 * 117.

Definition inside_ancient_pyramid_star_vertical
    (state : mario_route_state) : Prop :=
  between 4890 (route_y state) 5100.

Definition can_collect_inside_ancient_pyramid_star
    (state : mario_route_state) : Prop :=
  route_area state = Area2 /\
  inside_ancient_pyramid_star_horizontal state /\
  inside_ancient_pyramid_star_vertical state.
