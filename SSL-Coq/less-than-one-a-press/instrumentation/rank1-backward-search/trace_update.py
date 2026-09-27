"""Development full-interval fixture. Supplied scene, never gameplay evidence."""
import argparse,json,time,hashlib
from pathlib import Path
from clight import ROOT,seq,outer_items,sequence,walk,items
from trace_engine import TraceEngine,Checkpoint,Unsupported,word,z
from engine import OBJECT,STATE,TOP
from search import HEIGHT,bits
from benchmark_updates import peak_working_set


def fixture(e):
    def global_set(name,value,size=4):
        address=e.initialize_global(name);e.seed(address,value,size);return address
    u=e.unit('object_list_processor');fields=u.layout('_Object')[2]
    for address,label in ((OBJECT,'fixture Mario'),(TOP,'fixture pyramid top')):
        e.region(address,u.layout('_Object')[0],label,zero=True)
        e.seed(address+fields['_activeFlags'],1,2)
    global_set('_gMarioObject',OBJECT)
    global_set('_gMarioState',STATE)
    e.initialize_global('_gMarioStates')
    sf=u.layout('_MarioState')[2]
    e.seed(STATE+sf['_marioObj'],OBJECT)
    global_set('_gCurrLevelNum',8,2) # SSL
    global_set('_gTimeStopState',64|16)
    global_set('_gMarioPlatform',0)
    # Valid circular object rings. Even a frozen fixture must not evade the
    # update by omitting Mario or its supporting owner from the live lists.
    lists=e.initialize_global('_gObjectListArray')
    node_size,_,nf=u.layout('_ObjectNode')
    for i in range(13):
        head=lists+i*node_size
        e.seed(head+nf['_next'],head);e.seed(head+nf['_prev'],head)
    for i,obj in ((0,OBJECT),(9,TOP)):
        head=lists+i*node_size
        e.seed(head+nf['_next'],obj);e.seed(head+nf['_prev'],obj)
        # ObjectNode is the prefix of Object in the actual generated layout.
        e.seed(obj+nf['_next'],head);e.seed(obj+nf['_prev'],head)
    for j,value in enumerate((bits(-2200),HEIGHT,bits(-1024))):
        e.seed(OBJECT+160+4*j,value)
        e.seed(STATE+sf['_pos']+4*j,value)
        e.seed(OBJECT+32+4*j,value)
    # Checked timer-131 face (0,2,3), with the previously checked plane bits.
    collision=e.unit('surface_collision');fs=collision.layout('_Surface')[2]
    node,surface=0x08000000,0x09000000
    e.region(node,8,'fixture surface node',zero=True)
    e.region(surface,collision.layout('_Surface')[0],'fixture checked face',zero=True)
    e.seed(node+4,surface)
    for i,vertex in enumerate(((-2297,1528,-1715),(-2779,1528,-812),(-2087,2039,-1023)),1):
        for j,v in enumerate(vertex):e.seed(surface+fs['_vertex'+str(i)]+2*j,v,2)
    for j,raw in enumerate((3206524120,1060440647,3198842415)):
        e.seed(surface+fs['_normal']+4*j,raw)
    e.seed(surface+fs['_originOffset'],3309356130)
    e.seed(surface+fs['_object'],TOP)
    partition=e.initialize_global('_gDynamicSurfacePartition')
    # Signed16 (-2200,-1024), 1024-wide cells, 16 by 16 partitions.
    cell=(((-1024+8192)//1024)*16+((-2200+8192)//1024))*24
    e.seed(partition+cell,node)
    # The stock Area-1 level script's CALL_LOOP(1, lvl_init_or_update).
    script=e.initialize_global('_level_ssl_entry')
    unit,ty,init=e.data_definition('_level_ssl_entry')
    offsets=[];cursor=0
    for i,value in enumerate(init):
        if value.tag=='Init_int32' and int(value.args[0].args[0].tag)==302514177:
            if init[i+1].tag=='Init_addrof' and init[i+1].args[0].tag=='_lvl_init_or_update':offsets.append(cursor)
        cursor+=4 # this script's actual initializer consists of 32-bit words
    if len(offsets)!=1:raise Unsupported('SSL script CALL_LOOP selector')
    pc=script+offsets[0]
    # Standard initialized controller pointers; supplied neutral sample.
    controllers=e.initialize_global('_gControllers');pads=e.initialize_global('_gControllerPads')
    cf=e.unit('game_init').layout('_Controller')[2]
    global_set('_gPlayer1Controller',controllers)
    global_set('_gPlayer3Controller',controllers+2*e.unit('game_init').layout('_Controller')[0])
    e.seed(controllers+cf['_controllerData'],pads)
    return dict(pc=pc,controller=controllers,pads=pads,surface=surface,
        scope='Supplied finite stopped scene; not stock SSL reachability or a new gap producer.')


def controller_cut(e):
    fn=e.function('game_init','read_controller_inputs')
    parts=outer_items(fn.body)
    points=[i for i,n in enumerate(parts) if n.tag=='Scall' and n.args[1].tag=='Evar' and n.args[1].args[0].tag=='_run_demo_inputs']
    if len(points)!=1:raise Unsupported('Controller post-hardware boundary changed')
    return fn,seq(parts[points[0]:]),dict(firstOriginalStatement=points[0],totalOriginalStatements=len(parts),
        start='Immediately after the OS has supplied controller pads; includes run_demo_inputs, edges, sticks and port copy.')


def enable_mario(e,scene):
    """A supplied retry predecessor. Reachability is deliberately NOT claimed."""
    u=e.unit('mario');sf=u.layout('_MarioState')[2];of=u.layout('_Object')[2]
    e.seed(e.global_address('_gTimeStopState'),64) # Mario runs; top stays stopped
    bhv=e.initialize_global('_bhvMario')
    e.seed(OBJECT+of['_curBhvCommand'],bhv+28)
    e.seed(OBJECT+of['_bhvStackIndex'],1)
    e.seed(OBJECT+of['_bhvStack'],bhv+28)
    e.seed(OBJECT+of['_behavior'],bhv)
    e.seed(STATE+sf['_action'],0x00001300) # supplied disappeared action, not an accepted warp
    e.seed(STATE+sf['_actionArg'],0x00040002) # WARP_OP_WARP_OBJECT countdown; no new acceptance here
    e.seed(STATE+sf['_pos']+4,bits(768));e.seed(OBJECT+164,bits(768))
    e.seed(STATE+sf['_controller'],scene['controller'])
    e.seed(STATE+sf['_health'],0x880,2)
    for field,glob in (('_marioBodyState','_gBodyStates'),('_statusForCamera','_gPlayerCameraState')):
        e.seed(STATE+sf[field],e.initialize_global(glob))
    area=e.initialize_global('_gAreaData')
    e.seed(STATE+sf['_area'],area);e.seed(e.initialize_global('_gCurrentArea'),area)
    # Ordinary allocated animation cache. Index 14 is already resident, so the
    # original loader checks equality and performs no DMA in this fixture.
    animation=e.initialize_global('_gMarioAnimsBuf')
    e.seed(STATE+sf['_animList'],animation)
    af=u.layout('_DmaHandlerList')[2]
    table,target=0x09100000,0x09200000
    e.region(table,1024,'fixture animation table',zero=True)
    e.region(target,128,'fixture animation',zero=True)
    e.seed(animation+af['_dmaTable'],table)
    e.seed(animation+af['_bufTarget'],target)
    df=u.layout('_DmaTable')[2]
    e.seed(table+df['_count'],15)
    e.seed(table+df['_srcAddr'],target)
    e.seed(animation+af['_currentAddr'],target)
    # The cache carries an actual animation struct; no callee is skipped.
    gfx=u.layout('_GraphNodeObject')[2]
    animinfo=u.layout('_AnimInfo')[2]
    e.seed(OBJECT+gfx['_animInfo']+animinfo['_animID'],14,2)
    e.seed(OBJECT+gfx['_animInfo']+animinfo['_curAnim'],target)
    scene['scope']='Supplied retry/disappeared predecessor with real Mario update; no claim of a newly accepted warp or reachable initial gap.'


def execute(e,scene):
    controller,body,cut=controller_cut(e)
    # Verify adjacency in the original thread loop instead of inventing a
    # caller schedule. Hardware sampling is the declared starting boundary.
    thread=e.function('game_init','thread5_game_loop')
    loops=[n for _,n in walk(thread.body) if n.tag in ('Swhile','Sloop')]
    adjacent=False
    for loop in loops:
        parts=sequence(loop.args[1] if loop.tag=='Swhile' else loop.args[0])
        for left,right in zip(parts,parts[1:]):
            if left.tag=='Scall' and right.tag=='Scall':
                adjacent |= left.args[1].tag=='Evar' and left.args[1].args[0].tag=='_read_controller_inputs' and right.args[1].tag=='Evar' and right.args[1].args[0].tag=='_level_script_execute'
    if not adjacent:raise Unsupported('Original controller/level-call adjacency not found')
    e.call(controller,body=body)
    e.checkpoint=('update_objects','update_mario_platform')
    try:e.call(e.function('level_script','level_script_execute'),[word(scene['pc'])])
    except Checkpoint:pass
    else:raise Unsupported('Requested top-retention checkpoint not reached')
    if e.floor_result is None:raise Unsupported('No actual final floor result')
    result,args=e.floor_result
    pressed=scene['controller']+e.unit('game_init').layout('_Controller')[2]['_buttonPressed']
    goal=z.And(e.bytes_read(e.global_address('_gMarioPlatform'),4)==word(TOP),
        e.bytes_read(OBJECT+532,4)==word(TOP),z.fpToIEEEBV(result)==word(HEIGHT),
        z.fpToIEEEBV(args[0])==word(bits(-2200)),z.fpToIEEEBV(args[2])==word(bits(-1024)),
        (e.bytes_read(pressed,2)&z.BitVecVal(0x8000,16))==z.BitVecVal(0,16))
    return goal,cut


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--version',choices=('us','jp'),default='jp')
    p.add_argument('--output',type=Path,required=True);p.add_argument('--mario',action='store_true');a=p.parse_args()
    a.output.parent.mkdir(parents=True,exist_ok=True)
    t=time.perf_counter();e=TraceEngine(a.version,supplemental=ROOT/'build/rank1-backward-search/supplemental-generated')
    result=dict(version=a.version,exhaustiveOneUpdatePreimageComplete=False,fixtureComplete=False)
    try:
        scene=fixture(e)
        if a.mario:enable_mario(e,scene)
        goal,cut=execute(e,scene)
        print('checkpoint',e.steps,len(e.events),len(e.call_trace),time.perf_counter()-t,flush=True)
        if not z.is_true(e.concrete(goal)):raise Unsupported('Executed scene misses the target')
        pred=e.predecessor(goal)
        instance=e.initial_instance(pred)
        print('backward instance',instance,time.perf_counter()-t,flush=True)
        if not z.is_true(instance):raise Unsupported('Trace did not verify its own backward condition')
        # The unrestricted formula retains predecessor bytes; the selected
        # witness valuation is checked separately. Do not count this one path
        # as an exhaustive update preimage or controller-reachable state.
        smt=z.Solver();smt.add(pred)
        a.output.with_suffix('.smt2').write_text(smt.to_smt2(),encoding='utf-8')
        result.update(fixtureComplete=True,completedConditionalUpdatePaths=1,cut=cut,scene=scene,
            status='complete conditional fixture trace and reverse substitution',
            predecessorSHA256=hashlib.sha256(smt.to_smt2().encode()).hexdigest(),
            predecessorFreeBytes=len(__import__('loop_engine').get_vars(pred)))
        axes=[scene['pads']+2,scene['pads']+3]
        grouped=e.initial_instance(pred,leave=axes)
        x,y=[z.SignExt(24,e.cells[n]) for n in axes]
        expected=z.And(x>=word(-7),x<=word(7),y>=word(-7),y<=word(7))
        check=z.Solver();check.set(timeout=15000);check.add(z.Xor(grouped,expected))
        status=check.check()
        result['neutralButtonStickGroup']=dict(check=str(status),samples=225 if status==z.unsat else None,
            meaning='Exact input set for this one complete trace path, with the other supplied entry bytes fixed. Other paths are not excluded.')
        print('whole-interval input group:',status,flush=True)
    except Exception as error:
        result.update(status='incomplete',error=repr(error),at=e.context(),path=e.current_path)
        print(result['error'],e.current_path,flush=True)
        print('last calls:',[c['function'] for c in e.call_trace[-8:]],flush=True)
    result.update(seconds=time.perf_counter()-t,statements=e.steps,events=len(e.events),calls=e.call_trace,
        floorCalls=e.floor_calls,indirectCalls=e.indirect_calls,libraryDomains=e.library_domains,
        peakWorkingSetBytes=peak_working_set(),
        generatedUnits={str(e.unit(n).path.relative_to(ROOT)):e.unit(n).digest for n in e.image.modules},
        implementationHashes={n:hashlib.sha256(Path(__file__).with_name(n).read_bytes()).hexdigest()
            for n in ('clight.py','engine.py','loop_engine.py','relational_engine.py','program_image.py','trace_engine.py','trace_update.py','test_trace_update.py')})
    a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    if not result['fixtureComplete'] or result.get('neutralButtonStickGroup',{}).get('check')!='unsat':
        raise SystemExit(1)


if __name__=='__main__':main()
