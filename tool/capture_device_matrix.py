"""Capture actual Android PreviewScreen states, never substitute desktop renders."""
from pathlib import Path
import subprocess, xml.etree.ElementTree as ET, re, json, time

ADB = r'C:\Flutter\Android\AndroidSDK\platform-tools\adb.exe'
SERIAL = 'R38M906C8XE'
ROOT = Path('deliveries/ui_redesign/device_matrix_v5')
ROOT.mkdir(parents=True, exist_ok=True)

def adb(*args, check=True):
    return subprocess.run([ADB, '-s', SERIAL, *args], capture_output=True, check=check)

records = json.loads((ROOT/'capture_manifest.json').read_text()) if (ROOT/'capture_manifest.json').exists() else []
for i in range(len(records),90):
    template = ['modern','classic','business','technical','ats'][i // 18]
    language = ['ar','en','mixed'][(i // 6) % 3]
    font = ['Cairo','Sukar','Poppins'][(i // 2) % 3]
    mode = 'dark' if i % 2 else 'light'
    name = f'{i:02}_{template}_{language}_{font}_{mode}'
    data = None
    for attempt in range(40):
        result = adb('exec-out','run-as','com.example.cv_builder_pro','cat',f'cache/cv_qa_matrix_v5/{name}.pdf',check=False)
        if result.returncode == 0 and result.stdout.startswith(b'%PDF-'):
            data = result.stdout
            break
        if attempt in (2,10,20):
            adb('shell','uiautomator','dump','/data/local/tmp/matrix.xml')
            state=adb('shell','cat','/data/local/tmp/matrix.xml').stdout.decode('utf8')
            previous=f'{i-1:02}_'
            if previous in state and name not in state:
                node=next(n for n in ET.fromstring(state).iter('node') if n.get('content-desc')=='QA NEXT' or n.get('text')=='QA NEXT')
                x0,y0,x1,y1=map(int,re.findall(r'\d+',node.get('bounds')))
                adb('shell','input','tap',str((x0+x1)//2),str((y0+y1)//2))
        time.sleep(.5)
    if data is None: raise RuntimeError(f'No generated PDF: {name}')
    adb('shell','uiautomator','dump','/data/local/tmp/matrix.xml')
    xml = adb('shell','cat','/data/local/tmp/matrix.xml').stdout.decode('utf8')
    if name not in xml: raise RuntimeError(f'Wrong UI case: {name}')
    if 'failed_to_generate_preview' in xml or 'تعذر إنشاء' in xml: raise RuntimeError(f'Preview error: {name}')
    time.sleep(.8) # Allow the platform PDF raster to paint after the PDF was generated.
    (ROOT/f'{name}.pdf').write_bytes(data)
    (ROOT/f'{name}.png').write_bytes(adb('exec-out','screencap','-p').stdout)
    (ROOT/f'{name}.xml').write_text(xml, encoding='utf8')
    records.append(dict(index=i,template=template,language=language,font=font,mode=mode,name=name,visual_review='pending'))
    (ROOT/'capture_manifest.json').write_text(json.dumps(records,indent=2),encoding='utf8')
    print('CAPTURED',name,flush=True)
    if i < 89:
        node = next(n for n in ET.fromstring(xml).iter('node') if n.get('content-desc') == 'QA NEXT' or n.get('text') == 'QA NEXT')
        x0,y0,x1,y1 = map(int,re.findall(r'\d+',node.get('bounds')))
        adb('shell','input','tap',str((x0+x1)//2),str((y0+y1)//2))
print('CAPTURE COMPLETE: 90 actual device screenshots',flush=True)
