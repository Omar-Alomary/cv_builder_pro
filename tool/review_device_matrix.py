"""Build review sheets exclusively from device screenshots; audit device PDFs."""
from pathlib import Path
import json
from PIL import Image,ImageDraw
from pypdf import PdfReader
import pypdfium2 as pdfium
import pdfplumber

root=Path('deliveries/ui_redesign/device_matrix_v5')
records=json.loads((root/'capture_manifest.json').read_text())
for template in ['modern','classic','business','technical','ats']:
 for language in ['ar','en','mixed']:
  group=[r for r in records if r['template']==template and r['language']==language]
  if len(group)!=6: continue
  sheet=Image.new('RGB',(3240,3410),'#d1d5db')
  for r in group:
   font=['Cairo','Sukar','Poppins'].index(r['font']);row=int(r['mode']=='dark')
   shot=Image.open(root/(r['name']+'.png')).convert('RGB')
   shot=shot.crop((0,85,1080,1790))
   sheet.paste(shot,(font*1080,row*1705))
  sheet.save(root/f'review_{template}_{language}.jpg',quality=95)

audits=[]
for r in records:
 p=root/(r['name']+'.pdf');reader=PdfReader(p)
 assert 1<=len(reader.pages)<=2,(r['name'],'unexpected page count')
 text='\n'.join(page.extract_text() for page in reader.pages)
 for expected in ['omar@example.com','+966500123456','01/2021','12/2024','2020','01/2024','06/2024','Flutter']:
  assert expected in text,(r['name'],expected)
 with pdfplumber.open(p) as pdf:
  for page in pdf.pages:
   for c in page.chars:
    assert c['x0']>=37 and c['x1']<=page.width-37,(r['name'],'horizontal text overflow')
    assert c['top']>=28 and c['bottom']<=page.height-28,(r['name'],'vertical text overflow')
  if r['template']=='ats':
   assert not pdf.pages[0].images,(r['name'],'ATS photo')
   for c in pdf.pages[0].chars:
    col=c.get('non_stroking_color');assert col in (0,(0,),(0,0,0)),(r['name'],'ATS colored text',col)
 if r['mode']=='light' and (root/(r['name'].replace('_light','_dark')+'.pdf')).exists():
  a=pdfium.PdfDocument(p);b=pdfium.PdfDocument(root/(r['name'].replace('_light','_dark')+'.pdf'))
  assert len(a)==len(b),(r['name'],'theme changes page count')
  for page_index in range(len(a)):
   assert a[page_index].render(scale=1).to_pil().tobytes()==b[page_index].render(scale=1).to_pil().tobytes(),(r['name'],'PDF depends on UI theme')
 audits.append(dict(name=r['name'],pages=len(reader.pages),contacts_dates=True,text_bounds=True))
(root/'pdf_audit.json').write_text(json.dumps(audits,indent=2))
print('Audited PDFs:',len(audits),'Review sheets:',len(list(root.glob('review_*.jpg'))))
