"""Export actual native-drop positive and contact-height negative for JP replay."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def read(name):return json.loads(gzip.decompress((HERE/name).read_bytes()))
def export(t,name,source):
 return dict(schema=1,name=name,seedPhase=126,initialEdits=t['profileInstall']['writes']+t['setupEdits'],cuts=[dict(phase=128,edits=t['airEdits'])],controls=[t['releaseInput'],t['waitInput']]+t['controls'],expectedRichSamples=[t['release'],t['afterWait']]+t['samples'],events=[t['releaseEvents'],[]]+t['events'],diagnosticForks=t['diagnosticForks'],profileInstall=t['profileInstall'],sourceArtifact=source,sourceSha256=hashlib.sha256((HERE/source).read_bytes()).hexdigest(),recipe=dict(kind='supplied carrying/HOLP state then actual native Z drop126; Mario-only aircut128',releaseY=t['releaseY'],noActorEditsAfterRelease=True),expectedCapture=t['capture'],expectedUsefulSpawn=t['samples'][-1]['M'])
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 entries=[('positive-case.json','results.json.gz',1920),('high-miss-case.json','edge-results.json.gz',2014)]
 for name,source,y in entries:
  t=next(t for t in read(source)['results']['trials']if t['releaseY']==y);out=export(t,name[:-5],source);p=HERE/name
  if a.verify:assert json.loads(p.read_text())==json.loads(json.dumps(out))
  else:assert not p.exists();p.write_bytes((json.dumps(out,indent=2)+'\n').encode())
  print(name,'capture',t['capture'],'useful',t['useful'],'observations',len(out['expectedRichSamples']))
if __name__=='__main__':main()
