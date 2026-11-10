"""Capture page two by scrolling the real Android PDF preview."""
from pathlib import Path
import subprocess, time, json, re, xml.etree.ElementTree as ET

root=Path('deliveries/ui_redesign/device_matrix_v5')
records=json.loads((root/'capture_manifest.json').read_text())
indices=[54,55,58,59,60,61,66,67,70,71]
def adb(*args):
    return subprocess.run([r'C:\Flutter\Android\AndroidSDK\platform-tools\adb.exe','-s','R38M906C8XE',*args],capture_output=True,check=True).stdout

for i in indices:
    name=records[i]['name']
    time.sleep(1.5)
    adb('shell','uiautomator','dump','/data/local/tmp/matrix.xml')
    xml=adb('shell','cat','/data/local/tmp/matrix.xml').decode('utf8')
    assert name in xml,(name,'unexpected screen')
    for _ in range(2):
        adb('shell','input','swipe','540','1500','540','550','400')
        time.sleep(.8)
    (root/(name+'_page2.png')).write_bytes(adb('exec-out','screencap','-p'))
    print('PAGE TWO',name,flush=True)
    if i!=indices[-1]:
        node=next(n for n in ET.fromstring(xml).iter('node') if n.get('text')=='QA NEXT' or n.get('content-desc')=='QA NEXT')
        x0,y0,x1,y1=map(int,re.findall(r'\d+',node.get('bounds')))
        adb('shell','input','tap',str((x0+x1)//2),str((y0+y1)//2))
