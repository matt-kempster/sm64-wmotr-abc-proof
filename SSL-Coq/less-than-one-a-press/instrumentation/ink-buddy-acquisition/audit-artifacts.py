"""Read-only receipt and Git line-ending audit; no emulator execution."""
import gzip,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def main():
 checks=0
 def require(p,digest):
  nonlocal checks
  assert sha(p)==digest,(p,sha(p),digest);checks+=1
 w=read(HERE/'wafel-check.json')
 for name,key in [('inputs.jsonl','inputSha256'),('wafel-trace.json.gz','traceSha256'),('search.py','searchSha256'),('verify-wafel.py','verifierSha256')]:require(HERE/name,w[key])
 require(ROOT/'build/wafel-pilot/sm64_jp.dll',w['runtimeSha256'])
 require(HERE/'search-records.json.gz',read(HERE/'search-check.json')['archiveSha256'])
 n=read(HERE/'native-record/receipt.json');p=read(HERE/'native-record/provenance.json')
 raw=gzip.decompress((HERE/'native-record/raw.log.gz').read_bytes())
 assert hashlib.sha256(raw).hexdigest()==n['hashes']['rawLog']==p['rawLogSha256'];checks+=1
 require(HERE/'native-record/raw.log.gz',p['rawArchiveSha256'])
 for name,key in [('inputs.jsonl','inputs'),('controller.inputs','controllerInputs'),('wafel-trace.json.gz','wafelTrace'),('native-probe.c','probe'),('check-native.py','checker')]:require(HERE/name,n['hashes'][key])
 sourcefiles=[]
 for name,digest in p['sourceSha256'].items():require(ROOT/name,digest);sourcefiles.append(ROOT/name)
 native_plugin=ROOT/Path(p['sourceCapture'])/'probe.so'
 if native_plugin.exists():require(native_plugin,n['hashes']['plugin'])
 files=set(sourcefiles+[x for x in HERE.rglob('*')if x.is_file()and '__pycache__'not in x.parts]+[ROOT/'docs/notes/ink-buddy-acquisition-runtime.md'])
 for f in files:
  if f.suffix!='.gz':assert b'\r\n'not in f.read_bytes(),f
  raw_oid=subprocess.check_output(['git','hash-object','--no-filters',str(f)],cwd=ROOT).strip()
  clean_oid=subprocess.check_output(['git','hash-object','--path='+str(f.relative_to(ROOT)).replace('\\','/'),str(f)],cwd=ROOT).strip()
  assert raw_oid==clean_oid,('Git normalization changes bytes',f,raw_oid,clean_oid)
 print(json.dumps(dict(passed=True,sha256ReferencesChecked=checks,filesWithIdenticalRawAndGitFilteredBlob=len(files),allTextAlreadyLF=True,nativeLogUnmodified=True,compiledPluginHashChecked=native_plugin.exists(),emulatorRerun=False),indent=2))
if __name__=='__main__':main()
