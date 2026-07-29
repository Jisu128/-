#!/usr/bin/env python3
"""web/art/stage0..7.webp 를 base64 데이터 URI로 web/index.html 에 심는다.

사용법: python3 scripts/embed_art.py
<script id="stage-art"> 블록의 내용만 교체하므로 몇 번을 다시 실행해도 안전하다.
"""
import base64
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
html_path = root / "web" / "index.html"
art_dir = root / "web" / "art"

uris = []
for i in range(8):
    p = art_dir / f"stage{i}.webp"
    if not p.exists():
        sys.exit(f"missing {p}")
    b64 = base64.b64encode(p.read_bytes()).decode()
    uris.append(f'"data:image/webp;base64,{b64}"')

block = (
    '<script id="stage-art">\n'
    "/* 스테이지 일러스트 (scripts/embed_art.py 가 생성) */\n"
    "window.STAGE_ART = [\n" + ",\n".join(uris) + "\n];\n"
    "</script>"
)

html = html_path.read_text(encoding="utf-8")
new_html, n = re.subn(
    r'<script id="stage-art">.*?</script>', lambda m: block, html, count=1, flags=re.S
)
if n != 1:
    sys.exit("stage-art script block not found")
html_path.write_text(new_html, encoding="utf-8")
print(f"embedded {len(uris)} images, index.html = {len(new_html)/1024:.0f} KB")
