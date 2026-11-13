# Crazy Box handoff storyboard

**Getting inside the top remains an open setup step.** In the successful replay, the script moves Mario directly into the spinning top with crawl already supplied. During the split update his Y1741 feet lie between the Y1523 underside and the upper face near Y1914.34. Existing controller histories reach several useful components, including a late box-assisted roof ascent and a separate low hands-free crawl. A continuous no-A history that enters this interior high-crawl state with a usable box at the required time has yet to be demonstrated.

Open **crazy-box-handoff.mp4** in a video player. The 2:05 video is silent, with large captions. The left panel uses stock-camera images from the third chapter of the original Japanese ROM recording. The right panel is a schematic cutaway or plan view. Its outlines and markers are explanatory graphics drawn from the trace and source, with the horizontal distance enlarged in the cutaway. The actual warp has no visible model.

| Video time | What to look for |
| --- | --- |
| 0:00 | The floating top is above the pyramid summit. The low pad and invisible warp are below it. The supplied start puts Mario and the Crazy Box up inside the top's outline. The left panel still shows Mario at his earlier position before the setup edit. |
| 0:11 | Before input 5, the replay script supplies the crawl action. Input 5 gives Mario his native 100-unit crawl hitbox. Before input 6, the script supplies Mario's movement, collision and display coordinates at (−1950, 1741, −939) and box 49 at (−1989, 1741, −939). The replay uses the documented debug level-select startup. The high crawl and box placement are supplied, and the inherited floor height is 1024. |
| 0:22 | **Input 6, first event.** Geometry lookup starts over the low pad. Mario's remembered floor becomes the pad at Y 768, even though Mario is high. |
| 0:32 | **Same input.** The box acts as a bumper. Mario's movement shifts +68 X, from −1950 to −1882, crossing the pad's east edge at X −1945. The shove keeps Y 1741. |
| 0:42 | **Same input.** The crawl quarter checks a higher local floor (roof Y 1280) and the underside at Y 1523. The ceiling check stops the quarter before its local result can replace Mario's remembered floor. This order comes from the game code and geometry. The native trace samples the end of the update. |
| 0:53 | **Same input.** The ground step refreshes the display position while movement is still high. The crawl alignment then snaps movement to the remembered Y 768, and collision copies movement. The diagram stages those events while the game image stays frozen. |
| 1:03 | **Input 6 complete.** Collision and movement overlap at Y 768. Display stays at Y 1741 at the same X/Z, giving the 973-unit gap. The solid top obscures the display position. |
| 1:13 | **Input 7, next update.** The early object collision pass registers low contact with the warp. The floor lookup at low movement Y misses past the pad edge, so the game retries from the high display point. |
| 1:24 | **Same input.** The top has rotated into a pose where its local floor at Y 1818.9613 qualifies for the retry. The game handles the warp contact and Mario disappears. The selected top is saved as his platform. The trace records the same owner for the floor and platform and all three positions at Y 1818.9613. |
| 1:35 | The warp counts down. The footage advances through the original capture sequence. |
| 1:39 | **Input 30.** The JP platform reference carries across the area change and the result is a displaced Area 2 entry near (365.593, 5500, −1096.803). The star wipe hides that exact position. The plan compares its X/Z with the usual elevator entry at (0, 256). The arrow compares endpoints, and the native trace samples the resulting position. |
| 1:49 | The original footage shows Mario appear on the upper walkway after the wipe. |
| 1:54 | The open route problem is to bring a live, free box and an already-high crawler together above the pad at the useful moment in the spin. The source recording's three chapters are independent. The supplied handoff demonstrates the mechanism and resulting elevator bypass. Ordinary-play reachability remains open. |

## Evidence and checks

- The local checkout and remote proof branch match commit `3d9db857bd078f554e269f608dbd896667e71f17`. The original three-chapter video and its local site copy match the archived video hash.
- I reran the repository's handoff checker against the saved raw run, in read-only mode. Its computed receipt matched the archived receipt, including the ROM, trace and all 146 screenshot hashes. It verified the 13 setup writes, zero A inputs, 100-unit crawl hitbox, split, top capture and displaced arrival.
- I paired screenshot request records with completed game states using the preceding-framebuffer rule. The split and capture are PNGs 6 and 7. The first Area 2 state is input 30 and appears in PNG 28. Inputs 28 and 29 have no camera callback during the transition. The old video pauses on PNG 30, later in the wipe.
- The cutaway is an edited explanatory panel. It uses the native position trace, the authored pad and warp geometry, and the crawl-stop and next-phase floor query in the proof notes. The earlier candidate-view screenshots use illustrative poses and are absent from this video. The video was composed from the saved original captures without running a modified game or changing its camera, inputs, physics or timing. The in-update explanation uses the source ordering, with the recorded update endpoints as checks.
- Source references in the proof repository include `instrumentation/jp-ink-handsfree-demo/run-handoff.sh`, `check-handoff.py`, the archived `docs/media/ink-handsfree-native/supplied-handoff-trace.txt`, and `docs/notes/ink-timer130-handoff.md` for geometry and crawl order. That note's separate Wafel shell trial supplies a different actor and extra fields. This video uses the original-JP Crazy Box fixture.

