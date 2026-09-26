"""Compare generated documentation images with the published ones.

For every PNG in docs/images, download the image of the same name from the
published documentation site and write a side-by-side comparison (published
left, generated right) to docs-review/compare/, plus an index.html listing
them all. Images identical to the published ones are skipped. Used by the
deploy workflow on pull requests.
"""

import html
import io
import sys
import urllib.error
import urllib.request
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

SITE = "https://ortools4mtex.github.io/ORTools/images/"
ROOT = Path(__file__).resolve().parents[2]
IMAGES = ROOT / "docs" / "images"
OUT = ROOT / "docs-review" / "compare"
HEIGHT = 700  # both images are scaled to this height
LABEL = 40


def published(name):
    """Return the bytes of the published image, or None if there is none."""
    try:
        with urllib.request.urlopen(SITE + name, timeout=30) as response:
            return response.read()
    except urllib.error.HTTPError as err:
        if err.code == 404:
            return None
        raise


def scaled(img):
    width = round(img.width * HEIGHT / img.height)
    return img.resize((width, HEIGHT), Image.LANCZOS)


def placeholder(text):
    img = Image.new("RGB", (HEIGHT, HEIGHT), "white")
    ImageDraw.Draw(img).text((20, HEIGHT // 2), text, fill="gray", font=font(28))
    return img


def font(size):
    try:
        return ImageFont.truetype("DejaVuSans.ttf", size)
    except OSError:
        return ImageFont.load_default()


def side_by_side(left, right):
    panels = [("Published", left), ("Generated", right)]
    width = sum(img.width for _, img in panels) + 20
    out = Image.new("RGB", (width, HEIGHT + LABEL), "white")
    draw = ImageDraw.Draw(out)
    x = 0
    for label, img in panels:
        draw.text((x + 10, 5), label, fill="black", font=font(28))
        out.paste(img, (x, LABEL))
        x += img.width + 20
    return out


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rows = []
    for path in sorted(IMAGES.glob("*.png")):
        data = published(path.name)
        if data == path.read_bytes():
            continue  # unchanged, e.g. the logos and GUI screenshots
        old = None if data is None else Image.open(io.BytesIO(data)).convert("RGB")
        new = Image.open(path).convert("RGB")
        status = "new image" if old is None else f"{old.width}x{old.height} -> {new.width}x{new.height}"
        left = placeholder("not on the site") if old is None else scaled(old)
        side_by_side(left, scaled(new)).save(OUT / path.name)
        rows.append((path.name, status))
        print(f"{path.name}: {status}")

    items = "\n".join(
        f'<h2>{html.escape(name)} <small>({html.escape(status)})</small></h2>\n'
        f'<img src="{html.escape(name)}" style="max-width:100%">'
        for name, status in rows
    )
    (OUT / "index.html").write_text(
        "<!doctype html><meta charset=utf-8><title>Documentation images</title>\n"
        "<body style='font-family:sans-serif'>\n"
        "<h1>Published (left) vs generated (right)</h1>\n" + items + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    sys.exit(main())
