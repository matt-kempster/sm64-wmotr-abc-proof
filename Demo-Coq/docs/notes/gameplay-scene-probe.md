# Raw scene probe paired with actual input reads

`DemoGameplaySceneObservation.v` defines a total memory probe and pairs its result
with `demo_gameplay_consumption_observation` at exactly the same history index.
Every existing actual read has a result, including all failure results. There is
no level, demo stream, header, source owner, index range, active flag, successful
materialization or phase condition that can suppress a read.

The probe first resolves the actual generated `gCurrentArea` identifier and loads
its pointer cell with `Mptr`. It distinguishes a missing symbol, failed cell load,
the actual `Vzero` null value, and any other nonpointer value. A pointer triggers
the eight snapshot loads, in this fixed order: index, flags, geometry, terrain,
rooms, macros, object spawns, camera. The chunks and offsets are those of the
frozen `DemoAreaSceneObservation` API: signed-byte index/flags at 0/1 and pointer
fields at 4/8/12/16/32/36, relative to the loaded pointer offset.

The nested matches return `SceneProbeUnavailableField` for the first failed
typed load and retain its raw `option val`. A successful index/flags load must
be `Some (Vint _)`; any integer is accepted, while `Some Vundef` remains an
explicit typed-load failure rather than becoming zero. Each of the other six
fields accepts any `Some val`, including null and `Vundef`. A `None` for one of
these fields records that field. Later fields are consulted only after all
earlier fields succeed. This failure order follows the computed definition;
there is no separate theorem classifying every failure constructor.

`demo_gameplay_scene_probe_present_holds` proves that a present result satisfies
all eight exact `Mem.load` equations and the actual current-area symbol/pointer
load, under the explicit generated-compatible `demo_area_snapshot_layout`.
`demo_gameplay_scene_probe_null_holds` proves that the null result implies the
actual current-area symbol and `Some Vzero` cell load. Pairing requires no layout
premise; `demo_actual_read_has_scene_probe` proves total pairing, and
`demo_paired_scene_observation_is_actual_read` retains both the original read
observation and its actual `Clight.step2` edge. Present/null paired results also
give the frozen snapshot/no-current-area predicates at the same index.

The aggregate is `demo_gameplay_scene_observation_claim`, proved by
`checked_demo_gameplay_scene_observation`. This is an observation certificate,
not a scene-owner classification, a proof that every retail gameplay input read
is covered by the existing read observer, a boot or external-event refinement,
or a global no-desync theorem. The gameplay verdict remains open.

Validation: the existing `pipeline/build.sh audit-build` compiled the isolated
probe target successfully with the established switch, compiler and limits.
The ignored snapshot dependency is byte-identical to the canonical promoted
snapshot (`D3C5F5B17E7651BCA0492797E8A35BB30F2E07BA47DCFD1B2D2C9D3800B1CC12`).
The probe source SHA256 is
`EBE8519AF0347CD3382C9CBE5C2F05FF06BEAC7A5D65147269B557C85F604DD1`.
The build receipt is `build/gameplay-scene-probe/probe-build.log`; canonical
integration must recompile without the isolated namespace mapping.
