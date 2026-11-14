"""Archive the authenticated native log and provenance without ROM/runtime bytes."""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 capture=Path(sys.argv[1]);out=HERE/'native-record';out.mkdir(exist_ok=True)
 receipt=json.loads((capture/'buddy-acquisition-check.json').read_text());assert receipt['passed']
 with gzip.GzipFile(filename=str(out/'raw.log.gz'),mode='wb',mtime=0)as f:f.write((capture/'raw.log').read_bytes())
 (out/'receipt.json').write_bytes((capture/'buddy-acquisition-check.json').read_bytes())
 files=['instrumentation/ink-buddy-acquisition/native-probe.c','instrumentation/ink-buddy-acquisition/check-native.py','instrumentation/wafel-jp-pilot/capture.c','instrumentation/wafel-jp-pilot/capture.sh','instrumentation/jp-warp-acceptance/probe.c','instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c','instrumentation/jp-ranks13-18/verify.py','instrumentation/jp-rank5-state-split/verify.sh']
 provenance=dict(date='2026-11-14',proofRevision='49807c387f90e29856e2ae34a656f9394137ec19',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',stockPin='9921382a68bb0c865e5e45eb594d9c64db59b1af',emulator='Mupen64Plus2.5.9 interpreter (--emumode0)',graphics='Rice2.5.9',rsp='HLE',audio='dummy',runtime='Ubuntu-24.04 WSL',sourceCapture=str(capture),startup='--cheats6 existing debug level-select entry',postEntryGameWrites=0,controllerSource='inputs.jsonl,3471 all-A-off inputs',command='WAFEL_PILOT_PROBE=instrumentation/ink-buddy-acquisition/native-probe.c bash instrumentation/wafel-jp-pilot/capture.sh ../../../reference-sm64-decomp/baserom.jp.z64 instrumentation/ink-buddy-acquisition/controller.inputs',rawLogSha256=digest(capture/'raw.log'),rawArchiveSha256=digest(out/'raw.log.gz'),sourceSha256={p:digest(ROOT/p)for p in files})
 (out/'provenance.json').write_bytes((json.dumps(provenance,indent=2)+'\n').encode())
 print('Preserved native log and receipt:',out)
if __name__=='__main__':main()
