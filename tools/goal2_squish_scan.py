#!/usr/bin/env python3
"""
GOAL-2 squish-trigger scan (2026-10-20): can INPUT_SQUISHED ever fire in WMotR?

update_mario_geometry_inputs (mario.c:1344-1350) sets INPUT_SQUISHED only when
Mario's floor or ceiling is an OBJECT surface (SURFACE_FLAG_DYNAMIC) and
0 <= ceilHeight - floorHeight <= 150.  That input starts the squish cancel
(check_common_airborne_cancels -> ACT_SQUISHED -> act_squished's push ->
ACT_IDLE in mid-air), a move Phi's catalog does not have.

WMotR's only collision-loading objects are the wing-cap boxes
(exclamation_box_outline mesh, x2 scale: bottom face +60, top face +104) and
the two closed cannon lids (a flat floor at the lid's y); see
pipeline/tu/wmotr_level_data.c.  For each, this scans its xz footprint on a
4-unit grid and reports the nearest static floor below a dynamic ceiling and
the nearest static ceiling above a dynamic floor.  Finding (2026-10-20): the
smallest gap is 276 (> 150), so no fixed placement squishes Mario.  Not yet a
proof: it assumes the objects sit at their spawn positions (the boxes do not
move; a lid only moves when its cannon opens) and it uses real arithmetic.
"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import goal2_ladder as L
verts,secs=L.parse_collision(L.COLLISION)
floors=[];ceils=[]
for st,tris in secs:
    for (i,j,k) in tris:
        v1,v2,v3=verts[i],verts[j],verts[k]
        c,ny,lo,hi=L.classify(v1,v2,v3)
        if c=='floor': floors.append((v1,v2,v3,st))
        if c=='ceil': ceils.append((v1,v2,v3,st))
def heights(tris,x,z):
    out=[]
    for v1,v2,v3,st in tris:
        if L.point_in_tri_xz(v1,v2,v3,x,z):
            h=L.plane_height(v1,v2,v3,x,z)
            if h is not None: out.append(h)
    return out
def scan(name,x0,z0,half,dyn_y,mode):
    # mode 'dynceil': dynamic ceiling at dyn_y; look for static floors in [dyn_y-150, dyn_y]
    # mode 'dynfloor': dynamic floor at dyn_y; static ceilings in [dyn_y, dyn_y+150]
    best=None
    for dx in range(-half,half+1,4):
        for dz in range(-half,half+1,4):
            x,z=x0+dx,z0+dz
            if mode=='dynceil':
                for h in heights(floors,x,z):
                    if h<=dyn_y:
                        g=dyn_y-h
                        if best is None or g<best[0]: best=(g,x,z,h)
            else:
                for h in heights(ceils,x,z):
                    if h>=dyn_y:
                        g=h-dyn_y
                        if best is None or g<best[0]: best=(g,x,z,h)
    flag = best is not None and best[0]<=150
    print(f"{name:34s} {mode:8s} dyn_y={dyn_y:6d} nearest gap={'none' if best is None else round(best[0],1)} {'<-- SQUISH RANGE' if flag else ''}")
for (x,y,z,ln) in L.WING_CAP_BOXES:
    scan(f"cap box ({x},{y},{z})",x,z,52,y+60,'dynceil')
    scan(f"cap box ({x},{y},{z})",x,z,52,y+104,'dynfloor')
for (x,y,z) in [(-4456,827,191),(3712,-2740,5200)]:
    scan(f"cannon lid ({x},{y},{z})",x,z,111,y,'dynfloor')
