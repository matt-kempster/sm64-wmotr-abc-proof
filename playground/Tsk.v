From Coq Require Import ZArith List Lia.
From SM64.Proofs.WMotRRequiresA Require ObjWorld FieldWin.
From SM64.Proofs.WMotRRequiresA Require Import WMotRWorld.
Module OW := ObjWorld.
Open Scope Z_scope.
Goal forall off, In off OW.traj_offs -> OW.ccl off (off + 4).
Proof.
  intros off H. unfold OW.traj_offs in H. cbn [In] in H.
  destruct H as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]];
  unfold OW.O_ACTION, O_POSX, O_POSY, O_POSZ, RAW_OFF, OW.ccl, FieldWin.ucl_h,
    OW.O_TIMER, OW.O_PREVACT, OW.O_HOMEX, OW.O_HOMEY, OW.O_HOMEZ; idtac.
  all: try lia.
  all: match goal with |- ?g => fail 0 g end.
Qed.
