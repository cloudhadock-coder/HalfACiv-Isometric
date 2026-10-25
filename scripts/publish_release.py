"""Publish only the exact tested HEAD, using Git Credential Manager in memory.
No credentials are printed, persisted or passed in command arguments.
"""
from pathlib import Path
import subprocess,json,urllib.request,urllib.error,hashlib,sys
ROOT=Path(__file__).resolve().parents[1]
GIT=r'C:\Program Files\Git\cmd\git.exe'
REPO='cloudhadock-coder/HalfACiv-Isometric'
def git(*args):return subprocess.check_output([GIT,'-C',str(ROOT),*args],text=True).strip()
def main():
 if git('status','--porcelain'):raise SystemExit('BLOCKED: working tree is not clean')
 commit=git('rev-parse','HEAD');tag='v'+(ROOT/'VERSION').read_text().strip()
 if git('rev-list','-n','1',tag)!=commit:raise SystemExit('BLOCKED: tag differs from tested commit')
 credential=subprocess.run([GIT,'credential','fill'],input='protocol=https\nhost=github.com\n\n',capture_output=True,text=True)
 fields=dict(line.split('=',1) for line in credential.stdout.splitlines() if '=' in line)
 token=fields.get('password')
 if not token:raise SystemExit('BLOCKED: GitHub authentication unavailable in Git Credential Manager')
 def request(url,method='GET',data=None,content_type='application/json'):
  if not url.startswith('https://api.github.com/') and not url.startswith('https://uploads.github.com/'):raise ValueError('Unexpected API host')
  body=json.dumps(data).encode() if isinstance(data,dict) else data
  req=urllib.request.Request(url,data=body,method=method,headers={'Authorization':'Bearer '+token,'Accept':'application/vnd.github+json','Content-Type':content_type,'User-Agent':'HalfACiv-Release'})
  with urllib.request.urlopen(req,timeout=120) as response:return json.load(response)
 api='https://api.github.com/repos/'+REPO
 remote=request(api+'/git/ref/tags/'+tag)
 if remote['object']['sha']!=commit:raise SystemExit('BLOCKED: remote tag differs')
 notes=(ROOT/'docs/RELEASE_NOTES.md').read_text(encoding='utf-8').replace('sera registrado pelo script de publicacao a partir do HEAD exato.',commit).replace('{{COMMIT}}',commit)
 archive=ROOT/'dist'/tag/('HalfACiv-Isometric-'+tag+'-Windows-x64.zip')
 build=json.loads((archive.parent/'BUILD_INFO.json').read_text(encoding='utf-8'))
 if build['commit']!=commit or build['version']!=(ROOT/'VERSION').read_text().strip():raise SystemExit('BLOCKED: build metadata differs from tested commit')
 checksum=hashlib.sha256(archive.read_bytes()).hexdigest();notes+='\n\nSHA256 do ZIP: `'+checksum+'`\n'
 try:release=request(api+'/releases/tags/'+tag)
 except urllib.error.HTTPError as exc:
  if exc.code!=404:raise
  release=request(api+'/releases','POST',{'tag_name':tag,'target_commitish':commit,'name':'HalfACiv Isometric '+tag,'body':notes,'draft':True,'prerelease':False})
 if not release['draft']:raise SystemExit('Release already published; refusing to replace assets')
 if not any(a['name']==archive.name for a in release['assets']):
  request(release['upload_url'].split('{')[0]+'?name='+archive.name,'POST',archive.read_bytes(),'application/zip')
 published=request(api+'/releases/'+str(release['id']),'PATCH',{'draft':False,'body':notes})
 verified=request(api+'/releases/tags/'+tag)
 if verified['draft'] or not any(a['name']==archive.name and a['size']==archive.stat().st_size and a.get('digest') in [None,'sha256:'+checksum] for a in verified['assets']):raise SystemExit('BLOCKED: publication verification failed')
 print('RELEASE_PUBLISHED',verified['html_url']);print('COMMIT',commit);print('ZIP_SHA256',checksum)
if __name__=='__main__':main()
