"""Join original JP framebuffers to camera states and prepare the third Ink film."""
from pathlib import Path
import hashlib, json, re, shutil
ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
SOURCE = ROOT / 'build/jp-high-solid-support-20261114-a'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
raw = (SOURCE/'raw.log').read_text(encoding='utf-8')
receipt = json.loads((SOURCE/'receipt.json').read_text(encoding='utf-8'))
states = {int(r['timer']): r for r in receipt['states']}
requests = [dict(re.findall(r'(\w+)=([^,\n]+)',r)) for r in raw.splitlines() if r.startswith('ENTRY_SCREENSHOT,')]
shots = sorted((SOURCE/'shots').glob('super_mario_64-*.png'))
cores = [int(x) for x in re.findall(r'Core: Captured screenshot for frame (\d+)\.',raw)]
assert len(shots)==len(cores)==len(requests)+1
mapping=[]
for i,p in enumerate(shots):
    request=requests[i] if i<len(requests) else None
    timer=int(request['requestTimer'])-1 if request else None
    state=states.get(timer)
    mapping.append(dict(file=p.name,sha256=sha(p),requestTimer=timer+1 if timer else None,
        framebufferTimer=timer,coreCaptureFrame=cores[i],completedInput=int(state['step']) if state else None,state=state))
mapping_record=dict(source=str(SOURCE.relative_to(ROOT)),rawLogSha256=sha(SOURCE/'raw.log'),
    receiptSha256=sha(SOURCE/'receipt.json'),join='Rice previous completed framebuffer: requestTimer - 1; null means no joined observation.',frameMap=mapping)
(HERE/'frame-map.json').write_text(json.dumps(mapping_record,indent=2)+'\n',encoding='utf-8')
segments=[]
def card(title,seconds,diagram,shot,tag,lines,footer,badge='A released throughout / annotated original JP replay'):
    segments.append(dict(title=title,seconds=seconds,diagram=diagram,shot=shot,tag=tag,lines=lines,footer=footer,badge=badge))
card('A live box creates the slide',9,'roles',5,'CONDITIONAL ORIGINAL-JP SUCCESS',[
    'This time, Mario starts airborne. The game creates DIVE_SLIDE.',
    'A later shell shove completes Ink and changes the Area 2 spawn.'],
    'High Mario, the live box and the shell placement are supplied. This is not a complete gameplay route.')
card('What the test supplies',11,'setup',5,'SETUP CUT / BEFORE UPDATE 1',[
    'Mario is supplied in FREEFALL at Y 25001, with eastward speed 32.',
    'The large box is live at Y 24800. Its solid top reaches Y 25000.'],
    'Left: paused replay after update 1. Right: initial setup diagram. Shell availability is also supplied.')
card('One unit outside the edge',10,'edge',5,'GEOMETRY / ENLARGED, NOT TO SCALE',[
    'Mario starts at X -1950. The west edge of the box is X -1949.',
    'The next air-step candidate crosses the edge and encounters its floor.'],
    'Mario and box share Z -939. This diagram shows collision coordinates, not the rendered model.')
card('B makes a dive; landing makes a slide',10,'action',5,'UPDATE 1 / STORED TOP TIMER 129 TO 130',[
    'Press B once, with neutral stick. A remains released.',
    'FREEFALL enters DIVE, then the landing result selects DIVE_SLIDE.'],
    'No ground action is written into Mario. All inputs after this B press are neutral.')
card('The landing keeps the low cache',12,'cache',5,'SOURCE EXPLANATION / MATCHED NATIVE BOUNDARY',[
    'The high box floor triggers LANDED, but the clearance test rejects X/Z.',
    'Mario gets the high Y while his earlier low floor cache stays at 768.'],
    'Default no-ceiling height 20000 minus floor 25000 is not greater than 160; no physical ceiling is needed.')
card('High slide, still outside the box',10,'landed',5,'AFTER UPDATE 1 / NATIVE OBSERVATION',[
    'M, C and G all have Y 25000. The action is now DIVE_SLIDE.',
    'X remains -1950, outside the box. This is not ordinary standing on top.'],
    'Cache 768; no platform. G means Stored Graphics (gfx.pos), not the visibly rendered pose.')
card('Now supply only the shell position',10,'shell',5,'FINAL SETUP CUT / BEFORE UPDATE 2',[
    'Place the shell at (-1971, 25000, -939), then give neutral input.',
    'Mario is not edited again. The large box stays live and fixed.'],
    'The shell is never held, used or ridden in the observed suffix. Its job here is a fallback contact shove.')
card('A sideways shove preserves the slide',9,'push',6,'UPDATE 2 / STORED TOP TIMER 130 TO 131',[
    'A fresh floor lookup keeps 768. Contact pushes Mario 68 units east.',
    'The nonmounting shell shove reaches the slide and floor-alignment code.'],
    'The shell supplies the shove; the live box already supplied the landing result that created the action.')
card('Store high graphics, then snap movement',11,'copy',6,'INSIDE UPDATE 2 / EXPLANATORY DIAGRAM',[
    'The stopped ground step saves high movement into G: Stored Graphics.',
    'Floor alignment then snaps movement Y to the cached low floor.'],
    'This is an immediate store and snap, not a visible fall of 24232 units.')
card('The producer has made Ink',9,'gap',6,'AFTER UPDATE 2 / NATIVE OBSERVATION',[
    'Movement and collision are now (-1882, 768, -939).',
    'Stored Graphics is (-1882, 25000, -939): a 24232-unit Y gap.'],
    'The action ends as GROUND_BONK; alignment has run. On the next update, the box mesh unloads by distance.')
card('Low contact, high floor retry',11,'retry',7,'UPDATE 3 / STORED TOP TIMER 131 TO 132',[
    'Low collision contacts the real upper warp. The failed floor lookup retries at G.',
    'The spinning top is loaded now, so the retry selects its surface.'],
    'The high live box mesh is no longer loaded. This is a floor query at Stored Graphics, not a high warp.')
card('The top becomes the platform',9,'capture',7,'AFTER UPDATE 3 / NATIVE OBSERVATION',[
    'The warp is accepted. Floor owner and platform both name the spinning top.',
    'M, C and G reunite at Y 1818.9613 while Mario is DISAPPEARED.'],
    'Used warp: slot 64. Captured platform: top slot 61. A position gap alone would not establish this.')
card('The reference survives the countdown',7,'retention',8,'SLOW REPLAY / OBSERVED AREA 1 CONTINUATION',[
    'The recorded Area 1 samples keep the top as Mario\'s platform.',
    'Its inactive reference remains at the last observed Area 1 boundary.'],
    'This section advances through joined native images; each is held longer than one game update.')
segments[-1].update(range=[8,26],repeat=11)
card('Two transition observations are missing',9,'gaps',26,'EVIDENCE BOUNDARY / NO FRAMES INVENTED',[
    'Native step 27 records the inactive top and retained platform.',
    'Steps 28 and 29 have no camera observations; we do not fill them in.'],
    'Left: paused native step 26. Wafel separately records continuous retention through the transition.')
card('A different Area 2 spawn',11,'arrival',28,'UPDATE 26 FROM THE HIGH CUT / NATIVE STEP 30',[
    'The first Area 2 position is (365.593, 5500, -1096.803).',
    'That differs from the ordinary warp spawn (0, 5500, 256).'],
    'The first Area 2 framebuffer is dark during transition; the coordinates come from the matched native log.')
card('The original replay continues',5,'arrival',34,'LATER AREA 2 IMAGES / SLOWED REPLAY',[
    'The camera reveals the arrival while the recorded neutral inputs continue.',
    'The comparison arrow marks two spawn locations, not a travelled path.'],
    'The first-spawn coordinates at right belong to update 26, not every later image in this sequence.')
segments[-1].update(range=[34,52],repeat=8)
card('A frozen clone did not replace the floor',11,'clone',52,'SEPARATE WAFEL CONTROL / NOT SHOWN AS ROM FOOTAGE',[
    'A supplied frozen carry-script box loads no high solid mesh and fails to land.',
    'Moving raw object XYZ does not, by itself, rebuild collision triangles there.'],
    'The working box stays live. High delivery by gameplay remains unresolved; no general clone impossibility is proved.')
segments[-1]['sourceLabel']='Successful JP replay / reference image'
segments[-1]['badge']='Paused success image / not the failed clone control'
card('A real action predecessor; delivery is open',12,'summary',52,'WHAT THIS VIDEO ESTABLISHES',[
    'One original-JP positive creates the ground slide and useful displacement.',
    'Getting Mario, a live high box and the timed shell here through play is still open.'],
    '27 supplied writes. 1035/1080 compared components match; 45 subtype differences remain. No new Coq theorem.')
scope='Conditional original-JP replay with supplied high FREEFALL/live large box and timed shell placement; no ground action supplied. On-screen visual commentary plus original instrumental music. G = Stored Graphics (gfx.pos), not rendered pose.'
story=dict(schema=1,scope=scope,fps=30,posterSegment=9,segments=segments,frameMap='frame-map.json')
(HERE/'storyboard.json').write_text(json.dumps(story,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
chosen=set()
for s in segments: chosen.update(range(s['range'][0],s['range'][1]+1) if 'range' in s else [s['shot']])
(HERE/'frames').mkdir(exist_ok=True)
for i in sorted(chosen):
    assert mapping[i]['completedInput'] is not None
    shutil.copyfile(shots[i],HERE/'frames'/shots[i].name)
print('Preserved native images:',len(chosen),'duration:',sum((s['range'][1]-s['range'][0]+1)*s['repeat']/30 if 'range' in s else s['seconds'] for s in segments))
