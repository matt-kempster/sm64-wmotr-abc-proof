"""Soundness guardrails for the heuristic's bookkeeping, not game semantics."""
import copy
import random
import unittest
import ink_handoff_reverse_scattershot as rss


def row(timer=130, area=1):
    return dict(area=area, topTimer=timer, topAction=1, action=rss.CRAWLING,
                actor=dict(slot=49,live=True,tangible=True),collidedSlots=[49],
                floorY=768.,movement=[-1882.,768.,-939.],collision=[-1882.,768.,-939.],
                display=[-1882.,1741.,-939.],used=-1,floorOwner=-1,platform=-1)


class FakeBackend:
    def __init__(self, snapshots, edits):
        self.snapshots=iter(snapshots); self.edits=edits; self.begins=0; self.pads=[]
    def begin(self,recipe):
        self.begins+=1
        return next(self.snapshots),self.edits
    def advance(self,pad):
        self.pads.append(pad)
        return next(self.snapshots),[]


def success_rows(phase=130):
    before=row(phase); before['movement']=list(rss.PAD)
    before['collision']=list(rss.PAD); before['display']=list(rss.PAD)
    after=row(131)
    capture=row(132); capture.update(action=0x1300,used=64,floorOwner=61,platform=61)
    arrival=row(0,2); arrival['movement']=[365.5927734375,5500.,-1096.8026123046875]
    return [before,after,capture,arrival]


class HandoffTests(unittest.TestCase):
    def test_only_one_setup_and_no_suffix_corrections(self):
        backend=FakeBackend(success_rows(),[dict(path='gMarioState.pos')])
        result=rss.replay_suffix(backend,rss.root_recipe())
        self.assertTrue(result['success']); self.assertFalse(result['cleanGameplay'])
        self.assertEqual(backend.begins,1); self.assertEqual(len(backend.pads),3)

    def test_no_patch_is_required_for_clean_label(self):
        backend=FakeBackend(success_rows(),[])
        self.assertTrue(rss.replay_suffix(backend,rss.root_recipe())['cleanGameplay'])

    def test_initial_actor_only_edit_is_still_supplied(self):
        backend=FakeBackend(success_rows(),[dict(path='gObjectPool[49].oPosY')])
        self.assertFalse(rss.replay_suffix(backend,rss.root_recipe())['cleanGameplay'])

    def test_old_phase_cannot_count_as_timer130(self):
        a,b=success_rows()[:2]; a['topTimer']=129
        self.assertFalse(rss.is_handoff(a,b))

    def test_inactive_actor_rejected(self):
        a,b=success_rows()[:2]; a['actor']['live']=False
        self.assertFalse(rss.is_handoff(a,b))

    def test_collision_can_become_eligible_during_update(self):
        a,b=success_rows()[:2]
        a['actor'].update(tangible=False,intangibleTimer=1)
        self.assertTrue(rss.is_handoff(a,b))

    def test_actor_must_be_in_real_collision_list(self):
        a,b=success_rows()[:2]; b['collidedSlots']=[39]
        self.assertFalse(rss.is_handoff(a,b))

    def test_wrong_cache_or_disagreement_rejected(self):
        for field,value in [('floorY',1280.),('collision',[0.,768.,0.]),('action',0x1300)]:
            a,b=success_rows()[:2]; b[field]=value
            self.assertFalse(rss.is_handoff(a,b))

    def test_capture_without_payoff_is_not_parent(self):
        rows=success_rows(); rows[-1]['movement']=[0.,5500.,200.]
        result=rss.replay_suffix(FakeBackend(rows,[]),rss.root_recipe())
        self.assertFalse(result['success']); self.assertEqual(result['status'],'payoff-failed')

    def test_wrong_owner_is_not_capture(self):
        r=success_rows()[2]; r['floorOwner']=-1
        self.assertFalse(rss.is_capture(r))

    def test_a_in_any_suffix_input_rejected(self):
        r=rss.root_recipe(); r['controls'][0]=dict(buttons=0x8000,stick=[0,0])
        with self.assertRaises(ValueError): rss.validate_recipe(r)

    def test_missing_updates_rejected(self):
        r=rss.root_recipe(); r['phase']=129
        with self.assertRaises(ValueError): rss.validate_recipe(r)

    def test_proposals_keep_exact_parent_suffix(self):
        parent=dict(id=9,recipe=rss.root_recipe())
        for serial in range(110):
            r=rss.proposal(parent,serial,random.Random(9+serial),98)
            rss.validate_recipe(r)
            self.assertLess(r['phase'],parent['recipe']['phase'])
            self.assertEqual(r['controls'][-1:],parent['recipe']['controls'])
            self.assertEqual(r['parent'],9)

    def test_seed_reproducibility_and_no_a(self):
        parent=dict(id=9,recipe=rss.root_recipe())
        first=[rss.proposal(parent,i,random.Random(i),98) for i in range(100)]
        second=[rss.proposal(parent,i,random.Random(i),98) for i in range(100)]
        self.assertEqual(first,second)
        for r in first:
            self.assertTrue(all(not p['buttons']&0x8000 for p in r['controls']))

    def test_archive_keeps_distinct_recipe_without_merging(self):
        entries=[]
        for i in range(5):
            recipe=rss.root_recipe(); recipe['phase']=130-i
            entries.append(dict(id=i,recipe=recipe))
        kept=rss.retain(entries,3)
        self.assertEqual([e['id'] for e in kept],[4,3,2])
        self.assertIs(kept[0],entries[4])

    def test_budget_interruption_never_returns_success(self):
        from work_limits import LimitReached
        def stop(): raise LimitReached('search')
        with self.assertRaises(LimitReached):
            rss.replay_suffix(FakeBackend(success_rows(),[]),rss.root_recipe(),stop)


if __name__=='__main__': unittest.main()
