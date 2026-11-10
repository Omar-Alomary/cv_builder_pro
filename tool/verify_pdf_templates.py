from pathlib import Path
import json
import pdfplumber
import pypdfium2 as pdfium
from pypdf import PdfReader
from PIL import Image, ImageDraw
root=Path('tmp/pdfs/templates')
required=['EDU-DEGREE','EDU-INSTITUTION','GRADE-A','EDU-DESCRIPTION','COMPANY','COURSE-NAME','COURSE-PROVIDER','https://cert.example.com','CERT-NAME','CERT-ORG','CREDENTIAL-123','PROJECT-NAME','PROJECT-DESCRIPTION','Flutter','Web, Mobile','ACHIEVEMENT-NAME','ACHIEVEMENT-DESCRIPTION','AWARD-ORG','CUSTOM-CATEGORY','CUSTOM-INTEREST','alice@example.com','https://portfolio.example.com']
thumbs=[];results=[]
for path in sorted(root.glob('*.pdf')):
 reader=PdfReader(path)
 text='\n'.join(p.extract_text() or '' for p in reader.pages)
 for value in required:
  assert value in text,(path.name,'missing',value)
 if path.stem.endswith('_en'):
  assert 'Alice Developer' in text
  if path.stem.startswith('technical'):
   assert text.index('PROJECTS') < text.index('EXPERIENCE')
 with pdfplumber.open(path) as pdf:
  for page in pdf.pages:
   for char in page.chars:
    assert char['x0']>=37 and char['x1']<=page.width-37,(path.name,'horizontal bounds',char)
    assert char['top']>=28 and char['bottom']<=page.height-28,(path.name,'vertical bounds',char)
 doc=pdfium.PdfDocument(path)
 for i in sorted({0,len(doc)-1}):
  img=doc[i].render(scale=1.2).to_pil().convert('RGB');img.save(root/f'{path.stem}_{i+1}.png');img.thumbnail((290,410))
  tile=Image.new('RGB',(310,450),'white');tile.paste(img,(10,30));ImageDraw.Draw(tile).text((10,8),f'{path.stem} p{i+1}',fill='black');thumbs.append(tile)
 results.append({'sample':path.stem,'pages':len(reader.pages),'characters':len(text)})
contact=Image.new('RGB',(1240,450*((len(thumbs)+3)//4)),'#ddd')
for i,tile in enumerate(thumbs):contact.paste(tile,((i%4)*310,(i//4)*450))
contact.save(root/'contact_sheet.png')
(root/'verification.json').write_text(json.dumps(results,indent=2),encoding='utf8')
print(json.dumps(results))
