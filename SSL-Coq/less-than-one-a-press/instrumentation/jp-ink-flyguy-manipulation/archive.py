"""Preserve exact inputs, observations, strict failure and native log, not ROMs."""
import argparse,gzip,hashlib,json,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser();p.add_argument('prepared',type=Path);p.add_argument('capture',type=Path);p.add_argument('name');a=p.parse_args()
    assert a.name in {'roof','flame-roof','high-slide'}
    dest=HERE/'records'/a.name;dest.mkdir(parents=True,exist_ok=True)
    for name in ['inputs.jsonl','controller.inputs','wafel-trace.json.gz','fields.json','strict-receipt.json','diagnostic.json']:
        if (dest/name).exists() and name not in {'strict-receipt.json','diagnostic.json'}:
            assert (dest/name).read_bytes()==(a.prepared/name).read_bytes(),name
        shutil.copyfile(a.prepared/name,dest/name)
    compressed=gzip.compress((a.capture/'raw.log').read_bytes(),mtime=0)
    if (dest/'raw.log.gz').exists():assert (dest/'raw.log.gz').read_bytes()==compressed
    (dest/'raw.log.gz').write_bytes(compressed)
    paths=[HERE/n for n in ['native-probe.c','prepare.py','check.py','diagnose.py','archive.py']]
    paths += [ROOT/n for n in ['instrumentation/wafel-jp-pilot/capture.c','instrumentation/wafel-jp-pilot/capture.sh','instrumentation/wafel-jp-pilot/replay.py','instrumentation/jp-warp-acceptance/probe.c']]
    meta=dict(proofRevision='4813e95d33286a30882caf0759dd838c95ee48f2',stockSource='9921382a68bb0c865e5e45eb594d9c64db59b1af',
        runtime='Wafel 0.8.5 JP, Python 3.9.13; original JP via Mupen64Plus 2.5.9 interpreter, Rice 2.5.9, HLE RSP, dummy audio',
        romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',romMD5='85d61f5525af708c9f1e84dce6dc10e9',
        runtimeDllSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),capture=a.capture.name,
        startupGrant='existing debug level-selection entry only; all subsequent writes controller inputs, A off',
        sourceFiles={str(x.relative_to(ROOT)).replace('\\','/'):sha(x)for x in paths},
        files={x.name:sha(x)for x in dest.iterdir()if x.is_file()and x.name!='provenance.json'})
    (dest/'provenance.json').write_bytes((json.dumps(meta,indent=2)+'\n').encode())
    print('Archived',a.name,len(meta['files']),'files')
if __name__=='__main__':main()
