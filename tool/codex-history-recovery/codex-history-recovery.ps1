param(
  [switch]$Apply,
  [switch]$RefreshOnly,
  [string[]]$ThreadIds,
  [string]$CodexVersion = '0.154.0',
  [string]$BackupRoot
)

$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'PowerShell 7+ is required.' }
$Python = Get-Command python -ErrorAction SilentlyContinue
$Npx = Get-Command npx -ErrorAction SilentlyContinue
if (-not $Python) { throw 'Python 3 was not found in PATH.' }
if (-not $Npx) { throw 'npx was not found in PATH. Install Node.js/npm first.' }

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$Db = Join-Path $CodexHome 'thread_history_1.sqlite'
$Sessions = Join-Path $CodexHome 'sessions'
if (-not (Test-Path -LiteralPath $Db)) { throw "Database not found: $Db" }
if (-not (Test-Path -LiteralPath $Sessions)) { throw "Sessions not found: $Sessions" }
if (-not $BackupRoot) { $BackupRoot = [Environment]::GetFolderPath('Desktop') }
if (-not $BackupRoot) { $BackupRoot = (Get-Location).Path }

if ($Apply -or $RefreshOnly) {
  $running = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match '^Codex$' }
  if ($running) { throw 'Close Codex Desktop before applying repairs or refreshing threads.' }
}

$env:CHR_DB=$Db; $env:CHR_SESSIONS=$Sessions; $env:CHR_BACKUP=$BackupRoot
$env:CHR_APPLY=if($Apply){'1'}else{'0'}; $env:CHR_REFRESH=if($RefreshOnly){'1'}else{'0'}
$env:CHR_VERSION=$CodexVersion; $env:CHR_IDS=if($ThreadIds){$ThreadIds|ConvertTo-Json -Compress}else{'[]'}

@'
import os,json,sqlite3,shutil,subprocess,queue,threading,time
from pathlib import Path
from datetime import datetime

DB=Path(os.environ['CHR_DB']); SESS=Path(os.environ['CHR_SESSIONS']); BACK=Path(os.environ['CHR_BACKUP'])
APPLY=os.environ['CHR_APPLY']=='1'; REFRESH=os.environ['CHR_REFRESH']=='1'; VER=os.environ['CHR_VERSION']
IDS=json.loads(os.environ['CHR_IDS'])

def ro(): return sqlite3.connect(DB.resolve().as_uri()+'?mode=ro',uri=True,timeout=30)

def validate():
    c=ro()
    try:
        if c.execute('PRAGMA integrity_check').fetchone()[0] != 'ok': raise SystemExit('SQLite integrity_check failed.')
        need={'thread_history_projection_state':{'thread_id','next_rollout_byte_offset','next_rollout_ordinal'},'thread_items':{'thread_id'},'thread_turns':{'thread_id'}}
        tables={r[0] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        for t,cols in need.items():
            if t not in tables: raise SystemExit(f'Unsupported schema: missing table {t}')
            have={r[1] for r in c.execute(f'PRAGMA table_info({t})')}
            if not cols<=have: raise SystemExit(f'Unsupported schema: {t} missing {sorted(cols-have)}')
    finally: c.close()

def rollout(tid):
    m=list(SESS.rglob(f'rollout-*{tid}.jsonl')); return m[0] if len(m)==1 else None

def at(path,off):
    try:
        with path.open('rb') as f: f.seek(off); return json.loads(f.readline())
    except: return None

def prev(path,off):
    if off<=0:return None
    with path.open('rb') as f:
        p=off-1
        while p>=0:
            f.seek(p); ch=f.read(1)
            if ch not in (b'\n',b'\r'): break
            p-=1
        end=p+1
        while p>=0:
            f.seek(p)
            if f.read(1)==b'\n': start=p+1; break
            p-=1
        else:start=0
        f.seek(start); raw=f.read(end-start).rstrip(b'\r\n')
    try:return json.loads(raw)
    except:return None

def known(r):
    if not isinstance(r,dict) or r.get('type')!='event_msg': return False
    p=r.get('payload'); rl=p.get('rate_limits') if isinstance(p,dict) and p.get('type')=='token_count' else None
    return isinstance(rl,dict) and any(isinstance(rl.get(k),dict) for k in ('primary','secondary','credits'))

def state(tid):
    c=ro()
    try:
        p=c.execute('SELECT next_rollout_byte_offset,next_rollout_ordinal FROM thread_history_projection_state WHERE thread_id=?',(tid,)).fetchone()
        i=c.execute('SELECT COUNT(*) FROM thread_items WHERE thread_id=?',(tid,)).fetchone()[0]
        t=c.execute('SELECT COUNT(*) FROM thread_turns WHERE thread_id=?',(tid,)).fetchone()[0]
        return p,i,t
    finally:c.close()

def refresh(ids):
    ids=list(dict.fromkeys(ids))
    if not ids:return True
    npx=shutil.which('npx.cmd') or shutil.which('npx')
    p=subprocess.Popen([npx,'-y',f'@openai/codex@{VER}','app-server'],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,encoding='utf-8',errors='replace',bufsize=1)
    q=queue.Queue(); pending={}; nxt=1
    def reader():
        for line in p.stdout:
            try:q.put(json.loads(line))
            except:pass
    threading.Thread(target=reader,daemon=True).start()
    def call(method,params):
        nonlocal nxt
        rid=nxt;nxt+=1;p.stdin.write(json.dumps({'id':rid,'method':method,'params':params})+'\n');p.stdin.flush();deadline=time.time()+180
        while time.time()<deadline:
            if rid in pending:return pending.pop(rid)
            try:m=q.get(timeout=.25)
            except queue.Empty:continue
            mid=m.get('id')
            if mid==rid and ('result'in m or'error'in m):return m
            if mid is not None and ('result'in m or'error'in m):pending[mid]=m
        raise TimeoutError(f'thread refresh timeout: {rid}')
    init=call('initialize',{'clientInfo':{'name':'codex-history-recovery','title':'Codex History Recovery','version':'1.0.0'}})
    if 'error' in init: raise RuntimeError(init['error'])
    p.stdin.write(json.dumps({'method':'initialized','params':{}})+'\n');p.stdin.flush()
    ok=True
    try:
        for n,tid in enumerate(ids,1):
            before=state(tid); print(f'[{n}/{len(ids)}] {tid} before={before}')
            r=call('thread/resume',{'threadId':tid})
            if 'error'in r: print('  FAILED:',r['error']);ok=False;continue
            try:call('thread/unsubscribe',{'threadId':tid})
            except:pass
            time.sleep(.2); print('  after =',state(tid))
    finally:
        try:p.stdin.close();p.wait(timeout=5)
        except:
            try:p.terminate()
            except:pass
    return ok

validate()
if REFRESH:
    if not IDS: raise SystemExit('-RefreshOnly requires -ThreadIds.')
    raise SystemExit(0 if refresh(IDS) else 2)

c=ro()
try: rows=c.execute('SELECT thread_id,next_rollout_byte_offset,next_rollout_ordinal FROM thread_history_projection_state ORDER BY thread_id').fetchall()
finally:c.close()

cand=[]; suspicious=[]
for tid,off,n in rows:
    f=rollout(tid)
    if not f: continue
    cur=at(f,off)
    if not cur or cur.get('ordinal')==n: continue
    pre=prev(f,off)
    co=cur.get('ordinal'); po=pre.get('ordinal') if isinstance(pre,dict) else None
    if isinstance(n,int) and isinstance(co,int) and co==n+1 and po==n and known(pre):
        cand.append((tid,f,off,n,co))
    else:suspicious.append((tid,n,co,po))

print('SAFE REPAIR CANDIDATES')
for tid,f,off,n,co in cand: print(f'  {tid}: ordinal {n} -> {co} | {f}')
print('Safe candidates:',len(cand)); print('Suspicious states:',len(suspicious))
for x in suspicious: print('  NOT MODIFIED:',x)

if not APPLY:
    print('DRY RUN COMPLETE - no files were modified.'); raise SystemExit(0)
if not cand:
    print('Nothing to repair. Use -RefreshOnly for an already-repaired thread.'); raise SystemExit(0)

stamp=datetime.now().strftime('%Y%m%d-%H%M%S'); bdir=BACK/f'codex-history-recovery-{stamp}'; bdir.mkdir(parents=True)
src=sqlite3.connect(DB); dst=sqlite3.connect(bdir/'thread_history_1.sqlite'); src.backup(dst);dst.close();src.close()
(bdir/'rollouts').mkdir()
for _,f,_,_,_ in cand: shutil.copy2(f,bdir/'rollouts'/f.name)
(bdir/'repair-plan.json').write_text(json.dumps([{'thread_id':t,'rollout':str(f),'offset':o,'old_ordinal':n,'new_ordinal':co} for t,f,o,n,co in cand],indent=2),encoding='utf-8')

c=sqlite3.connect(DB)
try:
    c.execute('BEGIN IMMEDIATE')
    for tid,_,off,n,co in cand:
        cur=c.execute('UPDATE thread_history_projection_state SET next_rollout_ordinal=? WHERE thread_id=? AND next_rollout_byte_offset=? AND next_rollout_ordinal=?',(co,tid,off,n))
        if cur.rowcount!=1: raise RuntimeError(f'projection state changed: {tid}')
    c.commit()
    if c.execute('PRAGMA integrity_check').fetchone()[0] != 'ok': raise RuntimeError('post-repair integrity_check failed')
except:
    c.rollback(); raise
finally:c.close()

print('Backup:',bdir)
print('Cursor repair complete; refreshing threads...')
raise SystemExit(0 if refresh([x[0] for x in cand]) else 2)
'@ | & $Python.Source -
