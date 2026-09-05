/* Rank 9 diagnostic: immutable stock static collision, not a game replay.
 * No process/emulator access, controller injection, or game-memory writes.
 * Every arithmetic operation corresponding to a C float is rounded to f32.
 * sqrtf uses Math.sqrt then fround; its agreement with retail is not certified.
 */
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const source = path.join(root, 'build/pinned-sm64');
const read = p => fs.readFileSync(path.join(source, p), 'utf8');
const f = Math.fround, add = (a,b) => f(a+b), sub = (a,b) => f(a-b);
const mul = (a,b) => f(a*b), div = (a,b) => f(a/b);
const vertices = [], triangles = [];
let type;
for (const line of read('levels/ssl/areas/2/collision.inc.c').split(/\r?\n/)) {
  let m = /COL_VERTEX\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)/.exec(line);
  if (m) { vertices.push(m.slice(1).map(Number)); continue; }
  m = /COL_TRI_INIT\(\s*([^,]+)/.exec(line);
  if (m) { type = m[1]; continue; }
  m = /COL_TRI(?:_SPECIAL)?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/.exec(line);
  if (m) triangles.push({id:triangles.length, type, v:m.slice(1).map(i => vertices[+i])});
}
assert.equal(vertices.length, 1080); assert.equal(triangles.length, 1558);
const lowerCell = x => Math.max(0, Math.floor(Math.max(0,x+8192)/1024) - (Math.max(0,x+8192)%1024<50 ? 1:0));
const upperCell = x => Math.min(15, Math.floor(Math.max(0,x+8192)/1024) + (Math.max(0,x+8192)%1024>974 ? 1:0));
for (const t of triangles) {
  const [a,b,c] = t.v, u=b.map((x,i)=>x-a[i]), v=c.map((x,i)=>x-b[i]);
  const n=[f(u[1]*v[2]-u[2]*v[1]),f(u[2]*v[0]-u[0]*v[2]),f(u[0]*v[1]-u[1]*v[0])];
  const magnitude=f(Math.sqrt(add(add(mul(n[0],n[0]),mul(n[1],n[1])),mul(n[2],n[2]))));
  assert(magnitude>=0.0001);
  t.n=n.map(x=>mul(x,f(1/magnitude)));
  t.oo=f(-add(add(mul(t.n[0],a[0]),mul(t.n[1],a[1])),mul(t.n[2],a[2])));
  t.kind=t.n[1]>0.01 ? 'floor' : t.n[1]<-0.01 ? 'ceil' : 'wall';
  t.xProjection=Math.abs(t.n[0])>0.707;
  t.loY=Math.min(...t.v.map(v=>v[1]))-5; t.hiY=Math.max(...t.v.map(v=>v[1]))+5;
  t.cells=[0,2].map(axis=>[lowerCell(Math.min(...t.v.map(v=>v[axis]))),upperCell(Math.max(...t.v.map(v=>v[axis])))]);
}
function cellList(p, kind) {
  const xyz=p.map(x=>Math.trunc(x));
  assert(xyz.every(x=>x>=-32768&&x<=32767), 'diagnostic only supports ordinary signed-16 coordinates');
  const [x,,z]=xyz;
  if(x<=-8192||x>=8192||z<=-8192||z>=8192) return [];
  const cells=[x,z].map(x=>Math.floor((x+8192)/1024)&15);
  const dir=kind==='floor'?1:kind==='ceil'?-1:0;
  return triangles.filter(t=>t.kind===kind&&t.type!=='SURFACE_CAMERA_BOUNDARY'&&
    t.cells.every(([lo,hi],i)=>lo<=cells[i]&&cells[i]<=hi))
    .sort((a,b)=>dir*(b.v[0][1]-a.v[0][1]) || a.id-b.id);
}
function planeQuery(p, kind) {
  const [x,y,z]=p.map(Math.trunc), floor=kind==='floor';
  for(const t of cellList(p,kind)) {
    const sides=t.v.map((a,i)=>{const b=t.v[(i+1)%3];return (a[2]-z)*(b[0]-a[0])-(a[0]-x)*(b[2]-a[2]);});
    if(sides.some(s=>floor?s<0:s>0)) continue;
    const h=div(f(-add(add(mul(x,t.n[0]),mul(t.n[2],z)),t.oo)),t.n[1]);
    if(floor ? sub(y,sub(h,78))<0 : sub(y,add(h,78))>0) continue;
    assert(t.type!=='SURFACE_INTANGIBLE', 'this fixture must not need the intangible-floor retry');
    return {id:t.id, h};
  }
  return {id:null,h:floor?-11000:20000};
}
function walls(p, offsetY, radius) {
  const result=p.slice(), [x,,z]=p, y=add(p[1],offsetY), ids=[];
  for(const t of cellList(p,'wall')) {
    if(y<t.loY||y>t.hiY) continue;
    const offset=add(add(add(mul(t.n[0],x),mul(t.n[1],y)),mul(t.n[2],z)),t.oo);
    if(offset<-radius||offset>radius) continue;
    const w=t.v.map(v=>t.xProjection?-v[2]:v[0]), py=t.xProjection?-z:x;
    const positive=t.n[t.xProjection?0:2]>0;
    const sides=t.v.map((a,i)=>{const j=(i+1)%3;return sub(mul(sub(a[1],y),w[j]-w[i]),mul(sub(w[i],py),t.v[j][1]-a[1]));});
    if(sides.some(s=>positive?s>0:s<0)) continue;
    assert(t.type!=='SURFACE_VANISH_CAP_WALLS', 'no cap-specific wall assumption allowed here');
    result[0]=add(result[0],mul(t.n[0],sub(radius,offset)));
    result[2]=add(result[2],mul(t.n[2],sub(radius,offset)));
    ids.push(t.id);
  }
  return {p:result,ids,selected:ids.slice(0,4).at(-1)??null};
}
// The caller's ordinary geometry-input walls execute before its action.
function geometry(p) {
  const first=walls(p,60,50), second=walls(first.p,30,24);
  return {p:second.p, wallIds:[first.ids,second.ids], floor:planeQuery(second.p,'floor')};
}
function quarter(p,velocity,ledgeEnabled=true) {
  const intended=p.map((x,i)=>add(x,div(velocity[i],4)));
  const upper=walls(intended,150,50), lower=walls(upper.p,30,50), next=lower.p;
  const floor=planeQuery(next,'floor');
  // vec3f_find_ceil asks at floorHeight+80, not Mario's Y.
  const ceil=planeQuery([next[0],add(floor.h,80),next[2]],'ceil');
  const receipt={intended,upper:upper.ids,lower:lower.ids,next,floor,ceil};
  assert(floor.id!==null,'fixture unexpectedly needs a null-floor branch');
  if(next[1]<=floor.h) {
    assert(sub(ceil.h,floor.h)>160,'fixture unexpectedly needs a tight-clearance landing');
    return {...receipt,result:'landed',p:[next[0],floor.h,next[2]]};
  }
  if(add(next[1],160)>ceil.h) return {...receipt,result:'ceiling',p};
  if(ledgeEnabled&&upper.selected===null&&lower.selected!==null&&velocity[1]<=0) {
    const dot=add(mul(sub(next[0],intended[0]),velocity[0]),mul(sub(next[2],intended[2]),velocity[2]));
    if(dot<=0) {
      const wall=triangles[lower.selected];
      const probe=[sub(next[0],mul(wall.n[0],60)),add(next[1],160),sub(next[2],mul(wall.n[2],60))];
      const ledge=planeQuery(probe,'floor');
      if(sub(ledge.h,next[1])>100) return {...receipt,result:'ledge',probe,ledge,p:[probe[0],ledge.h,probe[2]]};
    }
  }
  return {...receipt,result:'ordinary',p:next};
}

const inputPose=[340,4700,-850], prepared=geometry(inputPose);
const first=quarter(prepared.p,[0,-50,0]);
assert.equal(first.result,'ledge');
assert.deepEqual(first.p,[397,4815,-850]);
const following=geometry(first.p);
const second=quarter(following.p,[0,sub(-50,3.2),0]);
assert.equal(second.result,'landed'); assert.deepEqual(second.p,first.p);
// All integral first-quarter entry heights at this fixed X/Z/velocity.
const pass=[];
for(let y=4600;y<=4800;y++) {
  const caught=quarter(geometry([340,y,-850]).p,[0,-50,0]);
  if(caught.result!=='ledge') continue;
  assert.deepEqual(caught.p,[397,4815,-850]);
  assert.equal(quarter(geometry(caught.p).p,[0,sub(-50,3.2),0]).result,'landed');
  pass.push(y);
}
assert.deepEqual(pass,Array.from({length:50},(_,i)=>4678+i));
// Nearby lower and upper failures distinguish a window from unrestricted ascent.
assert.notEqual(quarter(geometry([340,4600,-850]).p,[0,-50,0]).result,'ledge');
assert.notEqual(quarter(geometry([340,4800,-850]).p,[0,-50,0]).result,'ledge');
assert.notEqual(quarter(prepared.p,[0,-50,0],false).result,'ledge');
const report={inputPose,geometryInputs:prepared,firstQuarter:first,nextGeometryInputs:following,nextQuarter:second,
  integralHeightWindow:{first:pass[0],last:pass.at(-1),count:pass.length},
  scope:'Static Float32 source diagnostic only. No controller prefix, live dynamic lists, coin/star lifecycle, or linked Clight query execution.'};
console.log(JSON.stringify(report,null,2));
