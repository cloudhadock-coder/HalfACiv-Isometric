"""Rebuild and package the exact clean tagged commit, keeping restricted sprites embedded."""
from pathlib import Path
import sys,subprocess,json,hashlib,zipfile,shutil,re
ROOT=Path(__file__).resolve().parents[1]
GIT=shutil.which('git') or r'C:\Program Files\Git\cmd\git.exe'
def git(*args):return subprocess.check_output([GIT,'-C',str(ROOT),*args],text=True).strip()
def run(command,log):
 result=subprocess.run([str(c) for c in command],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',errors='replace')
 log.write_text(result.stdout+result.stderr,encoding='utf-8')
 if result.returncode or 'SCRIPT ERROR' in result.stdout+result.stderr or 'ERROR:' in result.stdout+result.stderr:
  print((result.stdout+result.stderr)[-6000:]);raise SystemExit('Validation failed: '+log.name)
 print(log.name+': OK',flush=True)
 return result.stdout

def main():
 if git('status','--porcelain'):raise SystemExit('Commit validated sources before building: working tree must be clean')
 version=(ROOT/'VERSION').read_text().strip()
 if not re.fullmatch(r'\d+\.\d+\.\d+',version):raise SystemExit('VERSION must be semantic')
 tag='v'+version;commit=git('rev-parse','HEAD')
 if git('rev-list','-n','1',tag)!=commit:raise SystemExit('Tag must match HEAD')
 output=ROOT/'dist'/tag;output.mkdir(parents=True,exist_ok=True)
 engine=next((ROOT/'tools/godot').glob('Godot*_win64_console.exe'))
 run([sys.executable,ROOT/'tests/test_assets.py'],output/'assets-test.log')
 run([engine,'--headless','--path',ROOT,'--script','tests/test_runner.gd'],output/'logic-test.log')
 run([engine,'--path',ROOT,'--script','tests/integration.gd'],output/'integration-test.log')
 run([engine,'--headless','--path',ROOT,'--export-release','Windows Desktop',output/'HalfACiv-Isometric.exe'],output/'export.log')
 smoke=run([output/'HalfACiv-Isometric.exe','--headless','--','--smoke'],output/'smoke.log')
 if 'SMOKE_OK version='+version not in smoke:raise SystemExit('Exported executable did not confirm version')
 if git('status','--porcelain'):raise SystemExit('Build changed tracked or unignored files: review before release')
 exe=output/'HalfACiv-Isometric.exe'
 report={'version':version,'commit':commit,'engine':'4.7.2-stable','platform':'Windows x64','exe_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'checks':['5 Python asset tests','21084 GDScript assertions','18 integration assertions','Windows executable smoke'],'benchmark':json.loads((ROOT/'docs/benchmark-v0.2.0.json').read_text())}
 (output/'BUILD_INFO.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
 notes=(ROOT/'docs/RELEASE_NOTES.md').read_text(encoding='utf-8').replace('{{COMMIT}}',commit)
 (output/'RELEASE_NOTES.md').write_text(notes,encoding='utf-8')
 (output/'README.txt').write_text('HalfACiv Isometric '+tag+' — Vida na aldeia\n\nExtraia o ZIP e execute HalfACiv-Isometric.exe no Windows 10/11 x64.\nWASD: câmera; roda: zoom; botão do meio: arrastar.\nSelecione categoria e construção, depois clique no terreno livre.\nClique em um morador para inspecionar e trocar seu ofício.\nHabitantes e retratos: galeria selecionável.\n1 / 2 / 4: velocidade; Espaço / Esc: pausa; F5: salvar.\n\nSaves da v0.1.0 são migrados. A primeira gravação mantém realm.json.v0.1.bak.\nSave: %APPDATA%/Godot/app_userdata/HalfACiv Isometric/realm.json\n\nConsulte RELEASE_NOTES.md para recursos, limites e créditos.\n',encoding='utf-8')
 shutil.copy2(ROOT/'LICENSE',output/'LICENSE.txt')
 shutil.copy2(ROOT/'assets/tilesets/ATTRIBUTION.md',output/'CREDITS.md')
 shutil.copy2(ROOT/'assets/original/GandalfHardcore/READ ME.txt',output/'GandalfHardcore-LICENSE.txt')
 # Same 4.7.2 engine license, included in source for reproducible packaging.
 shutil.copy2(ROOT/'assets/ui/Godot-LICENSE.txt',output/'Godot-LICENSE.txt')
 archive=output/('HalfACiv-Isometric-'+tag+'-Windows-x64.zip')
 names=['HalfACiv-Isometric.exe','README.txt','RELEASE_NOTES.md','CREDITS.md','LICENSE.txt','Godot-LICENSE.txt','GandalfHardcore-LICENSE.txt','BUILD_INFO.json']
 with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
  for name in names:
   record=zipfile.ZipInfo(name,date_time=(2026,10,24,0,0,0));record.compress_type=zipfile.ZIP_DEFLATED;z.writestr(record,(output/name).read_bytes())
 with zipfile.ZipFile(archive) as z:
  if z.testzip() is not None:raise SystemExit('ZIP integrity check failed')
 print('BUILD_READY',archive);print('COMMIT',commit);print('ZIP_SHA256',hashlib.sha256(archive.read_bytes()).hexdigest())
if __name__=='__main__':main()
