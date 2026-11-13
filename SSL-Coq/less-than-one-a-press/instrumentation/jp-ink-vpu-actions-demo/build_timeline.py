"""Build the visual commentary manifest from the six checked native receipts.

Only the new original-ROM captures are accepted. The renderer separately checks
every receipt and used framebuffer hash and rejects unmapped framebuffers.
"""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parent.parent
KINDS = ("crawl", "slide", "walk", "x-slide", "x-walk", "xy-slide")
runs = {}
for kind in KINDS:
    relative = Path("build") / f"jp-ink-vpu-actions-{kind}-20261113"
    receipt = PROJECT / relative / "receipt.json"
    data = json.loads(receipt.read_text(encoding="utf-8"))
    runs[kind] = dict(
        shots=(relative / "shots").as_posix(),
        receipt=(relative / "receipt.json").as_posix(),
        receiptSha256=hashlib.sha256(receipt.read_bytes()).hexdigest(),
        scope=data["scope"],
        romSha256=data["romSha256"],
        emulator=data["emulator"],
        milestones=data["milestones"],
        observationLimit=data["observationLimit"],
    )

segments = []
SOURCE = "Original JP ROM"
WITHIN = "Right: JP source + Wafel within-update explanation. Left: recorded ROM end state."
SUPPLIED = "Supplied-state original-ROM replay. High entry and Crazy Box delivery are not controller-reachable demonstrations."
CAPTURE = "Native input 7 records disappearance + top floor/platform. Local top height is not shifted by 65536."
ARRIVAL = "Coordinates describe first Area 2 input 30. Visible footage is later in the same independent supplied-state replay."

def card(run, shot, seconds, diagram, title, line1, line2, *,
         tag="", footer=SUPPLIED, badge="", range_=None, repeat=None):
    item = dict(run=run, shot=shot, seconds=seconds, diagram=diagram,
                title=title, tag=tag, sourceLabel=SOURCE,
                lines=[line1, line2], footer=footer, badge=badge)
    if range_:
        item["range"] = list(range_)
        item["repeat"] = repeat
        del item["shot"]
        del item["seconds"]
    segments.append(item)

def playback(run, chapter):
    card(run, None, None, "capture", "The top stays captured during the warp",
         "The native recording advances while the disappearance action runs.",
         "The right panel keeps the input 7 capture snapshot for reference.",
         tag=chapter, range_=(7,26), repeat=4,
         footer="Left: consecutive native inputs 7-26 at quarter speed. Right: input 7 snapshot, not current moving coordinates.")
    if run == "crawl":
        card(run,26,7,"retention","An inactive top is still remembered",
             "At input 27, the top is inactive but Mario still retains it as platform.",
             "This stored reference survives the disappearance before Area 2 loads.",
             tag=chapter,badge="Paused at input 26 / next-update telemetry on right",
             footer="Native input 27 telemetry records topActive=0 and retained platform. No exactly joined screenshot exists for that input.")
    card(run, None, None, "arrival", "Follow the warp into Area 2",
         "The transition fades, then the stock camera reaches the pyramid interior.",
         "First Area 2 position: (365.593, 5500, -1096.803), away from normal entry.",
         tag=chapter, range_=(28,145), repeat=2,
         footer="Left: consecutive native inputs 30-147 at half speed. Unmapped transition frame 27 is omitted. Right: first arrival.")

card("crawl",85,8,"summary","VPU crawl, slides and walking",
     "Three supplied vertical tests reach a useful Area 2 entry.",
     "Horizontal tests show why repeating terrain queries are not enough.",
     tag="INK HANDOFF / SIX INDEPENDENT JP ROM TESTS",
     badge="Silent visual commentary / pauses and slow motion",
     footer="Original JP ROM footage with explicit setup edits; explanatory diagrams are not game footage. No complete route is claimed.")
card("crawl",5,8,"query","A VPU repeats queries, not the whole world",
     "Here, VPU means +65536 in Y: actual height 67277 queries as 1741.",
     "The floor still returns a local height. The real warp and top stay below.",
     tag="READING THE DIAGRAM / M, C AND D ARE DIFFERENT STORES",
     badge="Native frame before the supplied high cut",
     footer="D means stored graphics position; the floor-alignment matrix can draw Mario elsewhere. Broken axis, not to scale.")

crawl="1 / 4  VPU CRAWL / INDEPENDENT SUPPLIED TEST"
card("crawl",5,7,"start","Start with a high crawler and a high box",
     "Supply Mario at (-1950, 67277, -939), already crawling, speed 5.",
     "Supply the Crazy Box at (-1989, 67277, -939), beside him; top phase 130.",
     tag=crawl,badge="Diagram shows the supplied pose before input 6")
card("crawl",6,7,"query","The first lookup remembers the low pad",
     "At Mario's initial X/Z, the high floor query aliases to Y 1741.",
     "It refreshes the cached floor to the actual low pad at Y 768.",
     tag=crawl,badge="Input 6 end state / diagram expands that update",footer=WITHIN)
card("crawl",6,7,"push","The box moves M sideways while M stays high",
     "The box interaction pushes movement X from -1950 to -1882.",
     "Movement Y remains 67277. The cached floor still remembers 768.",
     tag=crawl,badge="No new input between these explanatory stages",footer=WITHIN)
card("crawl",6,8,"stop","The high quarter-step stops before installing a floor",
     "The proposed step finds roof 1280, but the no-ceiling value is 20000.",
     "Raw Y 67277 + 160 reaches that value, so the old floor cache survives.",
     tag=crawl,badge="Top collision is unloaded here / zero top faces",footer=WITHIN)
card("crawl",6,7,"copy","Save high graphics, then snap movement low",
     "The ground step copies high movement into stored graphics D.",
     "Floor alignment sets M to cached Y 768; collision C then copies low M.",
     tag=crawl,badge="Instantaneous assignments / not a fall through space",footer=WITHIN)
card("crawl",6,7,"gap","The end of input 6 contains the 66509-unit split",
     "M and C are (-1882, 768, -939). Stored graphics D is still at Y 67277.",
     "Low C is near the real warp; high D is available for the next floor retry.",
     tag=crawl,badge="Native receipt: crawl / floor 768 / no platform",
     footer="Native end-update coordinates are measured. Stock camera may not show the high stored pose; use the M/C/D diagram.")
card("crawl",7,8,"retry","Next update: low contact, high retry",
     "Low C reaches the warp and permits the real top collision to load again.",
     "The low floor lookup fails; retrying from D aliases 67277 to 1741.",
     tag=crawl,badge="Top collision: zero to six faces in Wafel trace",footer=WITHIN)
card("crawl",7,8,"capture","Warp accepted; the spinning top is captured",
     "Mario disappears for the warp. Floor owner and platform both name the top.",
     "The new floor is local Y 1818.9613, with no +65536 added.",
     tag=crawl,badge="Native input 7: disappeared action + top platform",footer=CAPTURE)
playback("crawl",crawl)
card("crawl",85,7,"arrival","Crawling reaches the useful interior side",
     "The first Area 2 state is outside the usual elevator entry footprint.",
     "Later native frames show Mario beside the upper interior walkway.",
     tag=crawl,badge="Later visible footage / coordinates at first arrival",footer=ARRIVAL)

slide="2 / 4  VPU BUTT SLIDE / NEW INDEPENDENT REPLAY"
card("slide",5,7,"slide","Replace the crawler with a ground butt slide",
     "Supply the same high position and box, but ACT_BUTT_SLIDE at speed 20.",
     "This is an established ground slide, not an airborne slide animation.",
     tag=slide,badge="Native frame before the supplied high cut")
card("slide",6,8,"slide","A ground bonk does not prevent this alignment",
     "The stopped ground step changes the action to GROUND_BONK.",
     "The common slide helper still aligns with the old floor after that change.",
     tag=slide,badge="Within one input / bonk then floor alignment",footer=WITHIN)
card("slide",6,7,"gap","The slide makes the same recorded split",
     "Input 6 ends with M/C at 768 and D at 67277: a gap of 66509.",
     "The end action is GROUND_BONK; that alone does not defeat the handoff.",
     tag=slide,badge="Native receipt: ground bonk / floor 768")
card("slide",7,7,"capture","The separate slide run captures the top too",
     "Input 7 accepts the warp and records the spinning top as platform.",
     "We keep following this slide replay through the actual Area 2 transition.",
     tag=slide,badge="Same capture coordinates; independently recorded run",footer=CAPTURE)
playback("slide",slide)
card("slide",85,6,"arrival","Butt sliding also reaches the useful arrival",
     "The independently recorded slide reaches the same first Area 2 position.",
     "High slide entry and box delivery were supplied, so route reachability stays open.",
     tag=slide,badge="Later visible slide-run footage",footer=ARRIVAL)

walk="3 / 4  VPU WALKING TO CROUCH SLIDE / TWO SUPPLIED CUTS"
card("walk",5,8,"walkprep","Walking supplies the slide speed locally",
     "First supply walking on the low roof at Y 1280 and speed 20.",
     "One native walking update initializes slide velocity, still on that low roof.",
     tag=walk,badge="Input 5 / native walking on the low roof",
     footer="Preparation starts from a supplied low walking state. No climb or transport to the VPU is demonstrated.")
card("walk",6,9,"walkcut","A second cut moves the prepared walker high",
     "Supply high synchronized M/C/D and the high box; retain native walking speeds.",
     "Z selects CROUCH_SLIDE; its stopped step bonks and still aligns with the floor.",
     tag=walk,badge="Input 6 / second supplied relocation, then Z",
     footer="This is walking-to-crouch-slide after a supplied high cut. Ordinary walking does not itself make the split.")
card("walk",6,7,"gap","The walking-to-slide update produces the gap",
     "M/C again end at 768 while D remains at 67277; the gap is 66509.",
     "The native end action is GROUND_BONK, just as in the butt-slide replay.",
     tag=walk,badge="Native record after the Z transition")
card("walk",7,7,"capture","The next update completes the same local handoff",
     "The warp is accepted and the actual spinning top becomes Mario's platform.",
     "The run continues without another setup write after the high cut.",
     tag=walk,badge="Native input 7 / top captured",footer=CAPTURE)
playback("walk",walk)
card("walk",85,7,"arrival","Walking-to-slide reaches Area 2, conditionally",
     "This third replay also reaches (365.593, 5500, -1096.803) at first arrival.",
     "The missing route is how to obtain the supplied high pose and high box legally.",
     tag=walk,badge="Later visible walking-to-slide replay footage",footer=ARRIVAL)

pu="4 / 4  HORIZONTAL PU COMPARISONS / SEPARATE FAILING TESTS"
card("x-slide",6,7,"horizontal","Now move X by 65536 instead of Y",
     "The X-only tests start at (63586, 1741, -939), with the box beside Mario.",
     "Terrain queries alias back, but Mario is far from the actual warp and top.",
     tag=pu,badge="Original JP ROM / X-only supplied slide",
     footer="Horizontal PU means an X offset here. This finite comparison does not establish impossibility for every horizontal route.")
card("x-slide",6,7,"horizontal","Horizontal slide: no gap and no handoff",
     "The ground slide leaves the floor: M = C = D at Y 1741 after input 6.",
     "Its floor cache is 1280; raw X remains about 63659, far from the real warp.",
     tag=pu,badge="Input 6 / gap 0 / no top platform",
     footer="Native X-only butt-slide replay: no accepted warp, no top capture, no Area 2 handoff in the observed run.")
card("x-slide",None,None,"horizontal","Watch the X-only slide continue",
     "The remote state keeps evolving without entering the real warp.",
     "An aliased terrain query has not returned Mario's actual X coordinate.",
     tag=pu,range_=(7,66),repeat=2,
     footer="Consecutive native inputs 7-66 at half speed. Right panel explains the spatial separation, not exact changing Y.")
card("x-walk",6,7,"horizontal","Horizontal walking-to-slide fails here too",
     "The prepared walker receives Z at the X-offset cut and becomes airborne.",
     "Input 6 has no split: all three stores remain at Y 1741, with no top platform.",
     tag=pu,badge="Separate X-only walking-to-slide replay",
     footer="Native X-only walking-to-slide replay: no accepted warp, no top capture, no Area 2 handoff in the observed run.")
card("x-walk",None,None,"horizontal","Watch the X-only walking case continue",
     "This separate remote run also stays away from the real warp and top.",
     "The repeated floor coordinates are not a repeated set of interactive objects.",
     tag=pu,range_=(7,66),repeat=2,
     footer="Consecutive native inputs 7-66 at half speed. Right panel is a location diagram, not an additional game camera.")
card("xy-slide",6,8,"horizontal_gap","Both offsets: a huge gap can still fail",
     "At X +65536 and Y +65536, the slide makes the same 66509-unit Y split.",
     "But low C is still at X 63654. Snapping Y does not move X back to the warp.",
     tag=pu,badge="Native XY slide / gap 66509 / no warp",
     footer="Supplied XY butt-slide test: M/C=(63654,768,-939), D=(63654,67277,-939) after input 6.")
card("xy-slide",7,7,"horizontal","On the next update, the failed split disappears",
     "The retry restores M/C/D to Y 67277; the new floor cache is 1280.",
     "The real top is not captured, and no useful Area 2 arrival follows.",
     tag=pu,badge="Native input 7 / X 63654 / no platform",
     footer="This XY failure separates a position gap from a completed handoff. Terrain aliasing alone is insufficient.")
card("walk",85,9,"summary","Local handoffs demonstrated; route still open",
     "All three vertical supplied tests complete the handoff in original JP ROM runs.",
     "The horizontal comparisons fail; reaching the high setup without a new A remains open.",
     tag="RESULT / CONDITIONAL SUCCESSES, NOT A COMPLETE NO-A ROUTE",
     badge="Six replays / no A input in the recorded continuations",
     footer="Footage and end states: original JP ROM. Within-update ordering and collision-face counts: source + Wafel evidence.")

story = dict(
    schema=1,
    scope=("Silent visual commentary matching the earlier crawl demo. Six independent "
           "original JP ROM supplied-state replays: three vertical handoffs and three "
           "horizontal comparisons. Source/Wafel diagrams expand within-update ordering; "
           "native logs observe end-update states. No continuous controller-reachable "
           "high entry or box delivery is claimed. The stock camera is unmodified."),
    posterSegment=7,
    runs=runs,
    segments=segments,
)
target = HERE / "timeline.json"
target.write_text(json.dumps(story, indent=2, ensure_ascii=False)+"\n", encoding="utf-8")
frames = sum((s["range"][1]-s["range"][0]+1)*s["repeat"] if "range" in s
             else round(s["seconds"]*30) for s in segments)
print(json.dumps(dict(manifest=str(target), segments=len(segments), frames=frames,
                     seconds=frames/30), indent=2))
