import re, sys, glob
bad=0
for p in sorted(set(glob.glob('ui/**/*.lua',recursive=True)+glob.glob('services/*.lua')+glob.glob('*.lua'))):
    src=open(p,encoding='utf-8').read().splitlines()
    defs={}
    for i,l in enumerate(src):
        m=re.match(r'\s*local function (\w+)', l)
        if m: defs.setdefault(m.group(1), i)
    for name,defline in defs.items():
        for i,l in enumerate(src[:defline]):
            if re.search(r'(?<![\w.:])'+name+r'\s*\(', l) and not l.strip().startswith('--'):
                print(f"  {p}:{i+1} calls {name}() defined at line {defline+1}")
                bad+=1
print(f"forward references to local functions: {bad}")
