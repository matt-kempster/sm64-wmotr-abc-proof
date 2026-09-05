/* A conditional, continuous local timing diagnostic, NOT a controller replay.
 * Initial freefall pose and 99 coins are granted; subsequent star placement,
 * freeze, startup lifts, first contact and static catch use one shared state.
 * No emulator/process access or game-memory writes. See the README for omissions.
 */
'use strict';
const assert=require('node:assert/strict');
const {add,sub,mul,geometry,quarter,planeQuery}=require('./check.js');
const row=Array.from({length:5},(_,i)=>[290,4479+128*i,-940]);
function overlap(a,b,radius,height) {
  const dx=sub(a[0],b[0]),dz=sub(a[2],b[2]);
  return Math.fround(Math.sqrt(add(mul(dx,dx),mul(dz,dz))))<add(37,radius)
    && a[1]<=add(b[1],height) && add(a[1],160)>=b[1];
}
function orbit(home) {
  let y=home,vy=50,gravity=-4,action=0;
  const trace=[];
  for(let frame=0;frame<100;frame++) {
    if(action===0 && vy<0 && y<home) {action=1;vy=20;gravity=-1;}
    else if(action===1) {
      if(vy< -4) vy=-4;
      if(vy<0 && y<home) {action=2;vy=0;gravity=0;}
    }
    vy=add(vy,gravity);y=add(y,vy);
    assert(Math.abs(y)<12000,'ordinary object movement bound');
    trace.push({frame,action,y,vy,gravity});
    if(action===2) return trace;
  }
  assert.fail('star failed to settle');
}
function attempt(baseY=4578,completedLifts=0) {
  const liftSum=k=>k*(21-k);
  // Late controls use X=337 from the outset: horizontal placement cannot
  // repair their vertical deficit, and no horizontal star flight is modeled.
  let p=[completedLifts===0?340:337,baseY+liftSum(completedLifts),-850],timer=completedLifts;
  const initial=p.slice();
  const coin=row.find(c=>overlap(p,c,100,64));
  assert(coin,'no surviving row coin can be in contact');
  // detect_object_collisions runs before Mario; interact_coin spawns the star
  // at the raw Mario object. Only one COIN handler is dispatched per frame.
  let star={p:p.slice(),home:null,tangible:false},coins=100;
  const trace=[{event:'coin_99_to_100',p:p.slice(),timer,coin}];
  function startup() {
    const before=p.slice(),g=geometry(p);p=g.p;
    const ceil=planeQuery([p[0],add(g.floor.h,80),p[2]],'ceil');
    const lift=timer<10 ? 20-2*timer : 0;
    const allowed=timer<10 && add(add(p[1],lift),160)<ceil.h;
    if(allowed) p[1]=add(p[1],lift);
    timer++;
    trace.push({event:'startup',timer,before,p:p.slice(),walls:g.wallIds,
      floor:g.floor,ceil,lift:allowed?lift:0,vy:-50});
  }
  // Z in freefall enters timer zero. For the late controls we grant an already
  // running startup; these are not alternate controller histories.
  startup();
  // bhv_mario_update copies this post-action pose before the LEVEL-list star.
  assert.equal(p[0],star.p[0]);assert.equal(p[2],star.p[2]);
  star.home=add(p[1],250);
  const flight=orbit(star.home);
  star.p[1]=flight.at(-1).y;
  trace.push({event:'star_settled_while_mario_frozen',p:p.slice(),timer,
    homeY:star.home,star:star.p.slice(),objectUpdates:flight.length});
  // Camera completion is granted, not simulated. The source's clear branch
  // and hitbox-install branch are different LEVEL-list updates.
  trace.push({event:'clear_time_stop_without_hitbox',p:p.slice(),timer,cameraCompletionGranted:true});
  let firstContact=null;
  while(timer<=15) {
    // Every collision phase precedes the Mario action and later star update.
    if(star.tangible && overlap(p,star.p,80,50)) {
      firstContact={p:p.slice(),timer};
      trace.push({event:'first_star_contact',...firstContact});
      break;
    }
    if(timer===15) break; // next action is a downward pound, not another lift
    startup();
    star.tangible=true;
  }
  if(!firstContact) return {initial,coins,star,firstContact,trace};
  // Star selection keeps the pound's -50 Y speed and stops horizontal speed.
  const g=geometry(p),catchStep=quarter(g.p,[0,-50,0]);
  const landing=catchStep.result==='ledge'
    ? quarter(geometry(catchStep.p).p,[0,sub(-50,3.2),0]) : null;
  return {initial,coins,star,firstContact,catchStep,landing,trace};
}
const witness=attempt();
assert.equal(witness.star.home,4848);
assert.deepEqual(witness.star.p,[340,4843,-850]);
assert.deepEqual(witness.firstContact,{p:[337,4686,-850],timer:9});
assert.deepEqual(witness.catchStep.p,[397,4815,-850]);
assert.equal(witness.catchStep.result,'ledge');
assert.equal(witness.landing.result,'landed');
assert.deepEqual(witness.landing.p,witness.catchStep.p);
const late=Array.from({length:9},(_,i)=>attempt(4578,i+1));
assert(late.every(r=>r.firstContact===null));
const bases=[];
for(let y=4560;y<=4620;y++) {
  const r=attempt(y);
  if(r.catchStep?.result==='ledge') bases.push(y);
}
assert.deepEqual(bases,Array.from({length:50},(_,i)=>4570+i));
console.log(JSON.stringify({witness,
  sameStartupLateControls:late.map((r,i)=>({completedLiftsBeforeCoin:i+1,
    homeY:r.star.home,starY:r.star.p[1],highestMarioY:r.trace.at(-1).p[1],
    remainingVerticalGap:sub(r.star.p[1],add(r.trace.at(-1).p[1],160))})),
  integralInitialFreefallHeights:{first:bases[0],last:bases.at(-1),count:bases.length},
  scope:'Conditional source-shaped timing + static queries. No clean arrival/99-coin prefix, live object list, camera/animation execution, dance completion, or Act-3 collection.'},null,2));
