"""Full-input codec, three-target separation and resumable-count integrity."""
import copy
import hashlib
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch
from product_sweep import (INPUTS, NAMES, GATED_MASK, decode_input, input_count, pose_templates,
                           resume_counts, specification, ordered_input, INPUT_STRIDE,
                           check_ledger, run)
from controller_inputs import button_masks
from search import bits


class ProductTests(unittest.TestCase):
    def test_requested_gate_removes_exactly_l_and_four_dpad_bits(self):
        self.assertEqual(input_count('stock-gameplay'),16777216)
        self.assertEqual(input_count('all-non-a')//input_count('stock-gameplay'),32)
        masks=[decode_input(i*65536+32896,'released','stock-gameplay').buttons for i in range(256)]
        self.assertEqual(len(set(masks)),256)
        self.assertTrue(all(not mask&GATED_MASK for mask in masks))
        self.assertEqual(max(masks),0x701f)
        self.assertEqual(decode_input(16777215,'held','stock-gameplay').buttons,0xf01f)
        with self.assertRaises(ValueError):decode_input(16777216,'released','stock-gameplay')

    def test_complete_mask_codec_matches_declared_buttons(self):
        masks=list(button_masks('all-non-a'))
        self.assertEqual([decode_input(i*65536+32896,'released').buttons
                          for i in range(8192)],masks)
        self.assertTrue(all(not m&0x80c0 for m in masks))

    def test_all_raw_pairs_have_exact_endpoints_and_no_duplicates(self):
        controls=[decode_input(i,'released') for i in range(65536)]
        self.assertEqual(len({(c.x,c.y) for c in controls}),65536)
        self.assertEqual((controls[0].x,controls[0].y),(-128,-128))
        self.assertEqual((controls[-1].x,controls[-1].y),(127,127))
        self.assertEqual((controls[32896].x,controls[32896].y),(0,0))
        self.assertEqual(decode_input(INPUTS-1,'held').buttons,0xff3f)
        for bad in (-1,INPUTS):
            with self.assertRaises(ValueError): decode_input(bad,'released')

    def test_three_distinct_fixture_and_checkpoint_definitions(self):
        expected={'original':(768.,1938.8648681640625),
                  'variant':(1861.,768.),'hybrid':(1861.,1938.8648681640625)}
        for name,(movement,display) in expected.items():
            accepted,fixture=specification(name)
            self.assertEqual(fixture['movement'][1],bits(movement))
            self.assertEqual(fixture['display'][1],bits(display))
            self.assertEqual(fixture['collision'][1],bits(768.))
            self.assertEqual(accepted['movement'][1],bits(1938.8648681640625 if name=='original' else 1861.))
        self.assertEqual([len(list(pose_templates(specification(n)[0]))) for n in NAMES],[7,6,7])

    def test_resume_cannot_drop_or_invent_cases_or_consume_timing_sample(self):
        signature={'aMode':'released','sourceHashes':{'source':'checked'}}
        old={'signature':signature,'mode':'contiguous-exhaustive-stream','nextCase':3,
             'counts':{'original':{'accepted-projection':1},'variant':{'rejected':1},
                       'hybrid':{'rejected-event':1}},'searchSeconds':1.5}
        self.assertEqual(resume_counts(old,signature,10)[0],3)
        for field,value in (('nextCase',4),('nextCase',-1),('mode','stratified-timing')):
            bad=copy.deepcopy(old);bad[field]=value
            with self.assertRaises(ValueError):resume_counts(bad,signature,10)
        bad=copy.deepcopy(old);bad['counts']['variant']['rejected']=-1
        with self.assertRaises(ValueError):resume_counts(bad,signature,10)
        with self.assertRaises(ValueError):resume_counts(old,{'aMode':'held'},10)

    def test_mixed_order_is_invertible_and_keeps_batch_boundaries(self):
        for mode in ('stock-gameplay','all-non-a'):
            count=input_count(mode)
            inverse=pow(INPUT_STRIDE,-1,count)
            ordinals=list(range(65536))+[count-1]
            indices=[ordered_input(i,mode,'mixed') for i in ordinals]
            self.assertEqual(len(set(indices)),len(indices))
            self.assertEqual([(i*inverse)%count for i in indices],ordinals)
            self.assertEqual(ordered_input(249,mode,'mixed'),indices[249])
            self.assertEqual(ordered_input(250,mode,'mixed'),indices[250])
        with self.assertRaises(ValueError):ordered_input(-1,'stock-gameplay','mixed')
        with self.assertRaises(ValueError):ordered_input(0,'stock-gameplay','representative')

    def test_ledger_requires_every_declared_case_and_matching_counts(self):
        signature={'aMode':'released','inputSpace':{'buttonsMode':'stock-gameplay'},'order':'mixed'}
        jobs=[{'setup':n,'move':SimpleNamespace(name='pose-'+n)} for n in NAMES]
        records=[]
        for case in range(6):
            ordinal,job_id=divmod(case,3)
            index=ordered_input(ordinal,'stock-gameplay','mixed')
            records.append({'case':case,'jobId':job_id,'inputIndex':index,
                            'input':decode_input(index,'released','stock-gameplay').record(),
                            'setup':NAMES[job_id],'pose':'pose-'+NAMES[job_id],
                            'status':'accepted-projection' if job_id==0 else 'rejected'})
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'ledger.jsonl'
            def write(rows):
                path.write_text('\n'.join(json.dumps(r) for r in
                    [{'kind':'manifest','signature':signature}]+rows)+'\n',encoding='utf-8')
                return hashlib.sha256(path.read_bytes()).hexdigest()
            old={'nextCase':6,'counts':{'original':{'accepted-projection':2},
                 'variant':{'rejected':2},'hybrid':{'rejected':2}},'ledger':{'sha256':write(records)}}
            self.assertEqual(check_ledger(path,old,signature,jobs),6)
            path.write_text(path.read_text()+'{}\n',encoding='utf-8')
            with self.assertRaises(ValueError):check_ledger(path,old,signature,jobs)
            for mutation in ('missing','duplicate','wrong-input','wrong-status'):
                bad=copy.deepcopy(records)
                if mutation=='missing':bad.pop()
                elif mutation=='duplicate':bad[2]=bad[1]
                elif mutation=='wrong-input':bad[2]['input']['buttons']=0x4000
                else:bad[2]['status']='unknown'
                old['ledger']['sha256']=write(bad)
                with self.assertRaises(ValueError):check_ledger(path,old,signature,jobs)

    def test_missing_resume_does_not_start_the_runtime(self):
        with tempfile.TemporaryDirectory() as directory:
            args=SimpleNamespace(resume=True,output=Path(directory)/'missing.json')
            with patch('product_sweep.make_jobs') as prepare:
                with self.assertRaises(ValueError):run(args)
                prepare.assert_not_called()


if __name__=='__main__':
    unittest.main()
