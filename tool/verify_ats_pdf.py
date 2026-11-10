"""Inspect and render the app's ATS PDF fixtures without app dependencies."""
import json
import unicodedata
from pathlib import Path
import pdfplumber
import pypdfium2 as pdfium
from PIL import Image, ImageOps, ImageDraw
from pypdf import PdfReader

root = Path(__file__).resolve().parents[1] / 'tmp' / 'pdfs'
results = []
thumbnails = []
for name in ('ats_en', 'ats_ar'):
    path = root / f'{name}.pdf'
    reader = PdfReader(path)
    text = '\n'.join(page.extract_text() or '' for page in reader.pages)
    assert 'PROFESSIONAL SUMMARY' in text, (name, 'missing summary heading')
    normalized = unicodedata.normalize('NFKC', text)
    assert ('Alice' if name == 'ats_en' else 'عمر') in normalized, (name, 'name extraction failed')
    font_names = set()
    sizes = set()
    body_gaps = []
    with pdfplumber.open(path) as document:
        for page in document.pages:
            assert not page.images, (name, 'unexpected image')
            assert abs(page.width - 595.28) < .1 and abs(page.height - 841.89) < .1
            body_lines = sorted({round(char['top'], 2) for char in page.chars if char['size'] == 11})
            body_gaps.extend(b - a for a, b in zip(body_lines, body_lines[1:]))
            for char in page.chars:
                font_names.add(char['fontname'])
                sizes.add(round(char['size']))
                assert char['non_stroking_color'] == (0, 0, 0), (name, 'colored text')
                assert char['x0'] >= 53, (name, 'left margin', char)
                assert char['x1'] <= page.width - 53, (name, 'right margin', char)
                assert char['top'] >= 45 and char['bottom'] <= page.height - 45, (name, 'vertical bounds', char)
    assert len(font_names) == 1, font_names
    assert sizes == {11, 14, 20}, sizes
    if name == 'ats_ar':
        assert any(abs(gap - 15.4) < .02 for gap in body_gaps), 'Body line height must be 11 x 1.4'
    rendered = pdfium.PdfDocument(path)
    for index, page in enumerate(rendered):
        image = page.render(scale=1.3).to_pil().convert('RGB')
        if index == 0 or index == len(rendered) - 1:
            image.save(root / f'{name}_{index + 1}.png')
        image.thumbnail((290, 410))
        thumb = Image.new('RGB', (310, 450), 'white')
        thumb.paste(image, (10, 30))
        ImageDraw.Draw(thumb).text((10, 8), f'{name} page {index + 1}', fill='black')
        thumbnails.append(thumb)
    (root / f'{name}.txt').write_text(text, encoding='utf-8')
    results.append({'sample': name, 'pages': len(reader.pages), 'text_characters': len(text), 'fonts': sorted(font_names)})
rows = (len(thumbnails) + 3) // 4
contact = Image.new('RGB', (1240, rows * 450), '#dddddd')
for index, thumb in enumerate(thumbnails):
    contact.paste(ImageOps.expand(thumb, border=1, fill='#999999'), ((index % 4) * 310, (index // 4) * 450))
contact.save(root / 'ats_contact_sheet.png')
print(json.dumps(results, ensure_ascii=True))
