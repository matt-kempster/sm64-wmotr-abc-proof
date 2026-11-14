"""Generate a retail-JP diagnostic probe from a fully disclosed Wafel recipe.

The native prefix/shell preparation is the established conditional preparation.
The receiving Bob-omb profile and initial Mario pose are explicit grants. No
diagnostic ranking writes belong in this replay. All subsequent cuts must be
actor XYZ; the native behavior, collision and floor queries remain active.
"""
import argparse, json, re, struct
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[1]
DECOMP=ROOT.parents[2]/'reference-sm64-decomp'

def scalar(offset,value,width=32,isfloat=False):
    bits=struct.unpack('>I',struct.pack('>f',value))[0] if isfloat else int(value)&((1<<width)-1)
    return offset,width,bits

def fields():
    text=(DECOMP/'include/object_fields.h').read_text()
    return {name:(int(off,16),typ=='F32') for off,name,typ in re.findall(r'#define /\*0x([0-9a-fA-F]+)\*/\s+(\w+)\s+OBJECT_FIELD_(\w+)\(',text)}

def convert(edit,table):
    path=edit['path'];value=edit['after']
    m=re.fullmatch(r'gObjectPool\[(\d+)\]\.(.+)',path)
    if m:
        base=0x8033c118+int(m[1])*0x260;key=m[2]
    elif path.startswith('gMarioObject.'):
        base=0x8033c118+67*0x260;key=path[len('gMarioObject.'):]
    else:
        base=0x80339e00;key=path.removeprefix('gMarioState.')
        assert path.startswith('gMarioState.'),path
        spec={'pos':(0x3c,32,True,3),'vel':(0x48,32,True,3),
              'forwardVel':(0x54,32,True,1),'faceAngle':(0x2c,16,False,3),
              'action':(0xc,32,False,1),'actionState':(0x18,16,False,1),
              'actionTimer':(0x1a,16,False,1)}
        assert key in spec,path
        off,width,flt,count=spec[key]
        vals=value if count>1 else [value]
        return [scalar(base+off+i*width//8,v,width,flt) for i,v in enumerate(vals)]
    extra={'header.gfx.pos':(0x20,32,True,3),'header.gfx.scale':(0x2c,32,True,3),
           'header.gfx.node.flags':(2,16,False,1),'hitboxRadius':(0x1f8,32,True,1),
           'hitboxHeight':(0x1fc,32,True,1),'hurtboxRadius':(0x200,32,True,1),
           'hurtboxHeight':(0x204,32,True,1),'hitboxDownOffset':(0x208,32,True,1)}
    if key in table:
        off,flt=table[key];width=32;count=1
    else:
        assert key in extra,path
        off,width,flt,count=extra[key]
    vals=value if count>1 else [value]
    return [scalar(base+off+i*width//8,v,width,flt) for i,v in enumerate(vals)]

def write_lines(edits,table):
    return '\n'.join('  sw%d(0x%08xu,0x%08xu,%s);'%(width,addr,value,json.dumps(edit['path']))
                     for edit in edits for addr,width,value in convert(edit,table))

def main():
    ap=argparse.ArgumentParser();ap.add_argument('case',type=Path);ap.add_argument('output',type=Path);a=ap.parse_args()
    case=json.loads(a.case.read_text());table=fields()
    assert case['controls'][0]['buttons']==0x2000
    assert all(not p['buttons']&0x8000 for p in case['controls'])
    for c in case['cuts']:
        assert all(re.fullmatch(r'gObjectPool\[\d+\]\.oPos[XYZ]',e['path']) for e in c['edits'])
    base=(ROOT/'instrumentation/ink-floor768-diagnosis/probe.c').read_text()
    base=base.replace('/* Original JP floor-cache diagnosis.', '/* Generated enlarged Bob-omb case, with explicitly supplied initial profile.\n * Original JP floor-cache diagnosis.')
    base=base[:base.index('EXPORT void CALL GetKeys')]
    boblog=r'''
static void eb_bob(void){uint32_t b=SC_PUSH;
 fprintf(stderr,"EB_BOB,bridge=%d,active=%u,type=%u,subtype=%u,intangible=%d,status=%u,action=%u,timer=%u,held=%u,fuse=%u,command=%08x,behavior=%08x,radius=%.9g,height=%.9g,scale=(%.9g,%.9g,%.9g),pos=(%.9g,%.9g,%.9g),vel=(%.9g,%.9g,%.9g),forward=%.9g\n",sc_bridge,R16(b+0x74),R32(b+0x130),R32(b+0x190),(int32_t)R32(b+0x9c),R32(b+0x134),R32(b+0x14c),R32(b+0x154),R32(b+0x124),R32(b+0xfc),R32(b+0x1cc),R32(b+0x20c),rfloat(b+0x1f8),rfloat(b+0x1fc),rfloat(b+0x2c),rfloat(b+0x30),rfloat(b+0x34),rfloat(b+0xa0),rfloat(b+0xa4),rfloat(b+0xa8),rfloat(b+0xac),rfloat(b+0xb0),rfloat(b+0xb4),rfloat(b+0xb8));
}
'''
    base=base.replace('static void sc_update(unsigned int pc){',boblog+'\nstatic void sc_update(unsigned int pc){')
    base=base.replace('if(sc_started&&sc_bridge<=35)sc_log("SC_STATE");','if(sc_started&&sc_bridge<=45){sc_log("SC_STATE");eb_bob();}')
    # Keep the inherited query/quarter hooks and authenticated prefix. Expand
    # only the observation horizon, never freeze behavior or physics.
    base=base.replace('sc_bridge<=35','sc_bridge<=45').replace('sc_bridge<=5','sc_bridge<=8')
    pads=',\n'.join('{%d,%d,%d}'%(p['buttons'],*p['stick']) for p in case['controls'])
    base+='\nstatic const int case_pads[][3]={'+pads+'};\n'
    body=r'''
EXPORT void CALL GetKeys(int control,BUTTONS *keys){
 clean_get_keys(control,keys);if(control||!gTop)return;
 if(!sc_started&&(R16(A_CURR_AREA)!=1||R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4))return;
 memset(keys,0,sizeof(*keys));
 if(!sc_armed){unsigned i;uint32_t pcs[]={SC_CAMERA,FD_QUERY,FD_QUERY_RETURN,FD_GROUND,FD_GROUND_RETURN,FD_QUARTER,FD_QUARTER_RETURN,FD_QUARTER_CHECK,FD_QUARTER_COMMIT,FD_LOAD_MODEL,FD_LOAD_SURFACES};if(DSetCallbacks(debugger_init_callback,sc_update,debugger_vi_callback)!=M64ERR_SUCCESS){fprintf(stderr,"SC_ERROR,callback\n");return;}for(i=0;i<sizeof(pcs)/sizeof(pcs[0]);i++)if(!add_exec_breakpoint(pcs[i])){fprintf(stderr,"SC_ERROR,arm\n");return;}sc_armed=1;}
 if(!sc_started){sc_started=1;sc_log("SC_START");}
 if(sc_step==0)sw32(A_OBJECT_POOL+32*OBJECT_SIZE+O_ACTION,4,"shellBoxAction");
 if(sc_step==2){if(R32(SC_SHELL+O_INTERACT_TYPE)!=INTERACT_KOOPA_SHELL){fprintf(stderr,"SC_ERROR,shell-not-initialized\n");return;}sp(5900,51,3380);sa(0);sv(SC_SHELL+O_POS_X,6100,51,3380,"shellPosition");keys->B_BUTTON=1;}
 if(sc_step==6){if(R32(A_MARIO_STATES+M_ACTION)!=0x383||R32(A_MARIO_STATES+M_USED_OBJ)!=A_OBJECT_POOL+23*OBJECT_SIZE){fprintf(stderr,"SC_ERROR,pickup-entry\n");return;}sw32(A_MARIO_STATES+M_USED_OBJ,SC_SHELL,"usedReference");}
 if(sc_step==19){if(R32(A_MARIO_STATES+M_ACTION)!=0x08000207||R32(A_MARIO_STATES+M_HELD_OBJ)!=SC_SHELL){fprintf(stderr,"SC_ERROR,hold-idle\n");return;}keys->B_BUTTON=1;}
 if(sc_step==25){if(R32(A_MARIO_STATES+M_ACTION)!=0x80000588u||R16(A_MARIO_STATES+0x1a)!=6){fprintf(stderr,"SC_ERROR,throw-phase\n");return;}sv(R32(A_MARIO_STATES+0x98)+0x18,-1950,19890,-971,"highHOLP");}
'''
    body+=' if(sc_step>=43&&sc_bridge<0&&R32(gTop+O_ACTION)==1&&R32(gTop+O_TIMER)==%d){\n  sc_bridge=0;sc_log("SC_BEFORE_CUT");\n'%case['seedPhase']
    body+=write_lines(case['initialEdits'],table)+'\n  sc_log("SC_AFTER_CUT");\n }\n'
    for cut in case['cuts']:
        body+=' if(sc_bridge>=0&&sc_bridge==%d){\n'%(cut['phase']-case['seedPhase'])
        body+=write_lines(cut['edits'],table)+'\n  sc_log("SC_AFTER_PUSH_CUT");\n }\n'
    body+=r'''
 if(sc_bridge>=0&&(unsigned)sc_bridge<sizeof(case_pads)/sizeof(case_pads[0])){
  int buttons=case_pads[sc_bridge][0];keys->B_BUTTON=(buttons&0x4000)!=0;keys->Z_TRIG=(buttons&0x2000)!=0;keys->X_AXIS=case_pads[sc_bridge][1];keys->Y_AXIS=case_pads[sc_bridge][2];
 }
 if(sc_bridge<=45)fprintf(stderr,"SC_INPUT,step=%d,bridge=%d,buttons=%u,x=%d,y=%d,A=0\n",sc_step+1,sc_bridge<0?-1:sc_bridge+1,(keys->B_BUTTON?16384:0)|(keys->Z_TRIG?8192:0),keys->X_AXIS,keys->Y_AXIS);
 ++sc_step;if(sc_bridge>=0)++sc_bridge;
}
'''
    a.output.write_bytes((base+body).encode('utf-8'))
    print('Generated',case['name'],len(case['initialEdits']),'initial writes,',len(case['cuts']),'actor cuts')
if __name__=='__main__':main()
