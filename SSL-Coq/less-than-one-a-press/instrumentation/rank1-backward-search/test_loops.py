"""Regression tests of real floor bodies; fixtures are not gameplay witnesses."""
import unittest

from clight import Term, parse, seq, outer_items, walk
from engine import MEM, Scope, Path, OBJECT, TOP, word, read, write, z
from loop_engine import LoopEngine, initialized_temporaries
from search import bits, HEIGHT


def bound_fuel(expression, count):
    """Test a specified finite execution budget; never used to claim coverage."""
    cache = {}
    def visit(node):
        key = node.get_id()
        if key in cache: return cache[key]
        if z.is_quantifier(node):
            if node.num_vars() != 1 or not node.is_exists() or not str(node.var_name(0)).endswith('.iterations'):
                raise AssertionError('Unexpected quantifier in loop test')
            value = visit(z.substitute_vars(node.body(),z.IntVal(count)))
        elif z.is_app(node) and node.num_args():
            value = node.decl()(*[visit(c) for c in node.children()])
        else:
            value = node
        cache[key] = value
        return value
    return visit(expression)


class FloorFixture:
    """Byte cells use the actual generated Surface and SurfaceNode layouts."""
    HEIGHT_OUT = 0x07000000
    def __init__(self, engine):
        self.e = engine
        self.u = engine.unit('surface_collision')
        self.memory = z.K(MEM.domain(), z.BitVecVal(0,8))
        self.nodes = []
        self.set(self.HEIGHT_OUT,bits(-11000))
    def set(self, address, value, size=4):
        self.memory = write(self.memory,word(address),word(value),size)
    def surface(self,height=100,kind=0,flags=0,ny=1,triangle=None):
        index = len(self.nodes)
        node, surf = 0x08000000+index*8,0x09000000+index*64
        noff, soff = self.u.layout('_SurfaceNode')[2],self.u.layout('_Surface')[2]
        self.set(node+noff['_surface'],surf)
        if self.nodes: self.set(self.nodes[-1][0]+noff['_next'],node)
        self.set(surf+soff['_type'],kind,2)
        self.set(surf+soff['_flags'],flags,1)
        triangle = triangle or [(-100,0,-100),(-100,0,100),(100,0,0)]
        for n,xyz in enumerate(triangle,1):
            for j,v in enumerate(xyz): self.set(surf+soff['_vertex'+str(n)]+2*j,v,2)
        self.set(surf+soff['_normal']+4,bits(ny))
        self.set(surf+soff['_originOffset'],bits(-height))
        self.nodes.append((node,surf))
        return surf
    def camera(self,value):
        self.set(self.e.global_address('_gCheckingSurfaceCollisionsForCamera'),value,2)


class LoopTests(unittest.TestCase):
    def floor_query(self,version,dynamic,static,expected_index,expected_height,*,include=0,expected_misses=0):
        e=LoopEngine(version,loop_fuel=4)
        fn=e.function('surface_collision','find_floor'); s=Scope(e,fn); f=FloorFixture(e)
        for spec in dynamic+static: f.surface(**spec)
        if dynamic: f.set(f.nodes[len(dynamic)-1][0],0)
        cell_offset=(8*16+8)*3*f.u.layout('_SurfaceNode')[0]
        f.set(e.global_address('_gDynamicSurfacePartition')+cell_offset,f.nodes[0][0] if dynamic else 0)
        f.set(e.global_address('_gStaticSurfacePartition')+cell_offset,f.nodes[len(dynamic)][0] if static else 0)
        f.set(e.global_address('_gFindFloorIncludeSurfaceIntangible'),include,2)
        count_field=next(n for _,n in walk(fn.body) if n.tag=='Efield' and n.args[1].tag=='_floor' and n.args[0].tag=='Evar')
        count_addr=e.global_address('_gNumCalls')+fn.unit.field_offset(e.typeof(count_field.args[0]),'_floor')
        result_addr=0x07100000
        expected=0 if expected_index is None else f.nodes[expected_index][1]
        goal=z.And(z.fpToIEEEBV(s.result)==word(bits(expected_height)),
                   read(MEM,word(result_addr))==word(expected),
                   read(MEM,word(count_addr),2)==z.BitVecVal(1,16),
                   read(MEM,word(e.global_address('_gNumFindFloorMisses')))==word(expected_misses),
                   read(MEM,word(e.global_address('_gFindFloorIncludeSurfaceIntangible')),2)==z.BitVecVal(0,16))
        pred=e.wp(fn.body,[Path(goal)],s)[0].condition
        pred=z.substitute(pred,(MEM,f.memory),(s.temps['_xPos'],z.FPVal(0,z.Float32())),
                          (s.temps['_zPos'],z.FPVal(0,z.Float32())),(s.temps['_yPos'],z.FPVal(1000,z.Float32())),
                          (s.temps['_pfloor'],word(result_addr)))
        result,_,why=e.solve(z.Not(pred))
        self.assertEqual(result,'unsat',(version,dynamic,static,result,why))

    def test_complete_find_floor_selection_and_effects(self):
        for version in ('us','jp'):
            self.floor_query(version,[],[],None,-11000,expected_misses=1)
            self.floor_query(version,[dict(height=200)],[dict(height=100)],0,200)
            self.floor_query(version,[dict(height=100)],[dict(height=200)],1,200)
            # Equal-height tie retains the static result.
            self.floor_query(version,[dict(height=100)],[dict(height=100)],1,100)
            # A retry can miss while retaining the intangible floor's height.
            self.floor_query(version,[],[dict(height=200,kind=18)],None,200,expected_misses=1)
            self.floor_query(version,[],[dict(height=200,kind=18),dict(height=0)],1,-0.0)
            self.floor_query(version,[],[dict(height=200,kind=18)],0,200,include=1)

    def test_complete_platform_call_writes_owner_only_after_real_selection(self):
        for version in ('us','jp'):
            for near,owned in ((True,True),(True,False),(False,True)):
                e=LoopEngine(version,loop_fuel=4); e.target_floor_call=False
                fn=e.function('platform_displacement','update_mario_platform'); s=Scope(e,fn)
                f=FloorFixture(e)
                surface=f.surface(height=1938.8648681640625)
                f.set(surface+f.u.layout('_Surface')[2]['_object'],TOP if owned else 0)
                f.set(e.global_address('_gDynamicSurfacePartition')+(8*16+8)*24,f.nodes[0][0])
                f.set(e.global_address('_gMarioObject'),OBJECT)
                f.set(OBJECT+164,HEIGHT if near else bits(768))
                f.set(e.global_address('_gMarioPlatform'),0x12345678)
                f.set(OBJECT+fn.unit.layout('_Object')[2]['_platform'],0x12345678)
                expected=TOP if near and owned else 0
                goal=z.And(read(MEM,word(e.global_address('_gMarioPlatform')))==word(expected),
                           read(MEM,word(OBJECT+fn.unit.layout('_Object')[2]['_platform']))==word(expected))
                pred=e.wp(fn.body,[Path(goal)],s)[0].condition
                pred=z.substitute(pred,(MEM,f.memory))
                result,_,why=e.solve(z.Not(pred))
                self.assertEqual(result,'unsat',(version,near,owned,result,why))

    def run_floor(self, version, specs, expected_index, expected_height, *, y=1000,camera=0,fuel=8):
        e = LoopEngine(version)
        fn = e.function('surface_collision','find_floor_from_list')
        fixture = FloorFixture(e)
        for spec in specs: fixture.surface(**spec)
        fixture.camera(camera)
        scope = Scope(e,fn)
        expected = 0 if expected_index is None else fixture.nodes[expected_index][1]
        goal = z.And(scope.result == word(expected),
                     read(MEM,word(fixture.HEIGHT_OUT)) == word(bits(expected_height)))
        paths = e.wp(fn.body,[Path(goal)],scope)
        expr = bound_fuel(paths[0].condition,fuel)
        values = dict(_surfaceNode=fixture.nodes[0][0] if fixture.nodes else 0,
                      _x=0,_y=y,_z=0,_pheight=fixture.HEIGHT_OUT)
        expr = z.substitute(expr,(MEM,fixture.memory),*[(scope.temps[k],word(v)) for k,v in values.items()])
        result,_,why = e.solve(z.Not(expr))
        self.assertEqual(result,'unsat',(version,specs,result,why))
        self.assertFalse(e.calls)
        return e,scope,fixture,paths[0].condition

    def test_actual_empty_and_first_eligible_order(self):
        for version in ('us','jp'):
            self.run_floor(version,[],None,-11000)
            self.run_floor(version,[dict(height=100)],0,100)
            self.run_floor(version,[dict(height=100),dict(height=200)],0,100)
            self.run_floor(version,[dict(height=200),dict(height=100)],0,200)

    def test_actual_continue_paths_and_78_allowance(self):
        for version in ('us','jp'):
            for skip in (dict(kind=114),dict(ny=0),dict(height=1079),
                         dict(triangle=[(200,0,200),(200,0,300),(300,0,200)])):
                self.run_floor(version,[skip,dict(height=90)],1,90)
            self.run_floor(version,[dict(height=1078)],0,1078)
            self.run_floor(version,[dict(height=1079)],None,-11000)
            self.run_floor(version,[dict(flags=2),dict(height=90)],1,90,camera=1)
            self.run_floor(version,[dict(kind=114)],0,100,camera=1)

    def test_budget_exhaustion_is_not_a_null_floor(self):
        e = LoopEngine('jp')
        fn=e.function('surface_collision','find_floor_from_list'); s=Scope(e,fn)
        f=FloorFixture(e); f.surface(kind=114); f.surface(height=90)
        pred=e.wp(fn.body,[Path(s.result==word(0))],s)[0].condition
        pred=bound_fuel(pred,1)
        pred=z.substitute(pred,(MEM,f.memory),(s.temps['_surfaceNode'],word(f.nodes[0][0])),
                          (s.temps['_x'],word(0)),(s.temps['_y'],word(1000)),
                          (s.temps['_z'],word(0)),(s.temps['_pheight'],word(f.HEIGHT_OUT)))
        self.assertEqual(e.solve(pred)[0],'unsat')

    def test_rejecting_cycle_does_not_return_with_finite_fuel(self):
        e=LoopEngine('jp'); fn=e.function('surface_collision','find_floor_from_list'); s=Scope(e,fn)
        f=FloorFixture(e); f.surface(kind=114)
        f.set(f.nodes[0][0],f.nodes[0][0])
        pred=e.wp(fn.body,[Path(z.BoolVal(True))],s)[0].condition
        pred=bound_fuel(pred,3)
        pred=z.substitute(pred,(MEM,f.memory),(s.temps['_surfaceNode'],word(f.nodes[0][0])),
                          (s.temps['_x'],word(0)),(s.temps['_y'],word(1000)),
                          (s.temps['_z'],word(0)),(s.temps['_pheight'],word(f.HEIGHT_OUT)))
        self.assertEqual(e.solve(pred)[0],'unsat')

    def test_merge_has_one_formula_and_real_three_scans(self):
        for version in ('us','jp'):
            e=LoopEngine(version)
            fn=e.function('platform_displacement','update_mario_platform')
            _,paths=e.start(fn,z.BoolVal(True))
            self.assertEqual(len(paths),1)
            self.assertEqual(len(e.loops),3)
            self.assertEqual(e.finished_functions.count('find_floor_from_list'),3)
            self.assertFalse(e.calls)

    def test_read_before_assignment_is_rejected(self):
        from dataclasses import replace
        e=LoopEngine('jp'); f=e.function('surface_collision','find_floor_from_list')
        bad=replace(f,body=parse('(Sreturn (Some (Etempvar _floor (tptr tvoid))))'))
        with self.assertRaisesRegex(Exception,'uninitialized'):
            initialized_temporaries(bad)

    def test_derived_loop_argument_order_and_continue(self):
        from dataclasses import replace
        # Test-only variants exercise the exact CompCert notation. Neither
        # variant is presented as an original game function or gameplay run.
        for tag in ('Sfor','Sdowhile'):
            e=LoopEngine('jp',loop_fuel=5)
            base=e.function('surface_collision','find_floor_from_list')
            inc=parse('(Sset _x (Ebinop Oadd (Etempvar _x tint) (Econst_int (Int.repr 1) tint) tint))')
            cond=parse('(Ebinop Olt (Etempvar _x tint) (Econst_int (Int.repr 3) tint) tint)')
            if tag == 'Sfor':
                loop=Term('Sfor',(Term('Sskip'),cond,Term('Scontinue'),inc))
            else:
                loop=Term('Sdowhile',(Term('Ssequence',(inc,Term('Scontinue'))),cond))
            body=seq([parse('(Sset _x (Econst_int (Int.repr 0) tint))'),loop])
            fn=replace(base,body=body,digest='test-derived-'+tag)
            initialized_temporaries(fn)
            s=Scope(e,fn)
            pred=e.wp(body,[Path(s.temps['_x']==word(3))],s)[0].condition
            self.assertEqual(e.solve(z.Not(pred))[0],'unsat',tag)

    def test_continue_does_not_hide_an_uninitialized_increment_read(self):
        from dataclasses import replace
        e=LoopEngine('jp'); fn=e.function('surface_collision','find_floor_from_list')
        bad=replace(fn,body=parse('(Sloop Scontinue (Sset _x (Etempvar _floor (tptr tvoid))))'))
        with self.assertRaisesRegex(Exception,'uninitialized'):
            initialized_temporaries(bad)


if __name__=='__main__': unittest.main()
