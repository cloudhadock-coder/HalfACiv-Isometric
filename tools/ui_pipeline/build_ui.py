"""Builds the HUD chrome in assets/ui/: beveled 9-slice frames and 12x12 resource icons.

Deterministic and hand-specified pixel by pixel (no filters, noise or resampling). The frames
follow the layout logic of classic 4X sidebars (raised bevels, framed boxes) in the project's own
palette; they are replaceable: keep each file's size and 9-slice margins (see src/ui/ui_theme.gd).

    python tools/ui_pipeline/build_ui.py
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "python_libs"))
from PIL import Image  # noqa: E402

OUT = ROOT / "assets" / "ui"

INK = (13, 20, 22, 255)
PALETTE = {
    "panel_fill": (23, 37, 43, 255), "panel_dither": (27, 42, 48, 255),
    "bronze_hi": (196, 168, 110, 255), "bronze": (141, 121, 85, 255), "bronze_lo": (86, 71, 46, 255),
    "rivet": (230, 205, 140, 255),
    "bar_fill": (31, 44, 47, 255), "bar_dither": (35, 49, 52, 255),
    "title_fill": (44, 36, 26, 255), "title_dither": (50, 41, 29, 255),
}
BUTTONS = {
    #             fill               light              dark
    "normal":   ((42, 62, 66, 255), (111, 133, 128, 255), (17, 27, 31, 255)),
    "hover":    ((58, 82, 80, 255), (145, 165, 150, 255), (22, 34, 36, 255)),
    "pressed":  ((33, 50, 47, 255), (17, 27, 31, 255), (96, 116, 108, 255)),
    "disabled": ((32, 40, 42, 255), (62, 72, 72, 255), (20, 26, 28, 255)),
    "field":    ((15, 26, 29, 255), (10, 16, 18, 255), (78, 94, 92, 255)),
}


def dithered(size, fill, dither):
    img = Image.new("RGBA", size, fill)
    for y in range(size[1]):
        for x in range(size[0]):
            if (x + y) % 4 == 0 and x % 2 == 0:
                img.putpixel((x, y), dither)
    return img


def bevel(img, inset, light, dark):
    w, h = img.size
    for i in range(w - 2 * inset):
        img.putpixel((inset + i, inset), light)
        img.putpixel((inset + i, h - 1 - inset), dark)
    for j in range(h - 2 * inset):
        img.putpixel((inset, inset + j), light)
        img.putpixel((w - 1 - inset, inset + j), dark)
    # Bevel corners: the shared corners belong to the darker side.
    img.putpixel((w - 1 - inset, inset), dark)
    img.putpixel((inset, h - 1 - inset), dark)


def outline(img, inset, colour):
    w, h = img.size
    for i in range(inset, w - inset):
        img.putpixel((i, inset), colour)
        img.putpixel((i, h - 1 - inset), colour)
    for j in range(inset, h - inset):
        img.putpixel((inset, j), colour)
        img.putpixel((w - 1 - inset, j), colour)


def framed(fill, dither, rivets=True):
    """32x32 window frame, 9-slice margin 6: ink, raised bronze bevel, bronze, ink, dithered body."""
    img = dithered((32, 32), PALETTE[fill], PALETTE[dither])
    outline(img, 0, INK)
    bevel(img, 1, PALETTE["bronze_hi"], PALETTE["bronze_lo"])
    outline(img, 2, PALETTE["bronze"])
    bevel(img, 3, PALETTE["bronze_lo"], PALETTE["bronze_hi"])
    outline(img, 4, INK)
    if rivets:
        for x, y in ((2, 2), (29, 2), (2, 29), (29, 29)):
            img.putpixel((x, y), PALETTE["rivet"])
    return img


def bar():
    """Menu bar strip, 16x16, margins 3: body with a bronze rule along the bottom."""
    img = dithered((16, 16), PALETTE["bar_fill"], PALETTE["bar_dither"])
    for x in range(16):
        img.putpixel((x, 0), (52, 68, 70, 255))
        img.putpixel((x, 13), PALETTE["bronze_lo"])
        img.putpixel((x, 14), PALETTE["bronze"])
        img.putpixel((x, 15), INK)
    return img


def title():
    """Window title strip, 16x16, margins 3: warm body, bronze rule underneath."""
    img = dithered((16, 16), PALETTE["title_fill"], PALETTE["title_dither"])
    for x in range(16):
        img.putpixel((x, 14), PALETTE["bronze"])
        img.putpixel((x, 15), PALETTE["bronze_lo"])
    return img


def button(state):
    """16x16 button, margins 3: ink outline and a two-pixel bevel (inverted when pressed)."""
    fill, light, dark = BUTTONS[state]
    img = Image.new("RGBA", (16, 16), fill)
    outline(img, 0, INK)
    bevel(img, 1, light, dark)
    if state != "field":
        bevel(img, 2, tuple((a + b) // 2 for a, b in zip(light, fill)), tuple((a + b) // 2 for a, b in zip(dark, fill)))
    return img


def grabber():
    img = Image.new("RGBA", (8, 16), PALETTE["bronze"])
    outline(img, 0, INK)
    bevel(img, 1, PALETTE["bronze_hi"], PALETTE["bronze_lo"])
    return img


# 12x12 icons drawn as character maps. "." is transparent.
ICON_COLOURS = {
    "k": INK, "y": (232, 196, 92, 255), "Y": (178, 138, 52, 255), "w": (246, 232, 180, 255),
    "b": (150, 98, 54, 255), "B": (104, 66, 38, 255), "t": (196, 146, 92, 255),
    "g": (164, 168, 164, 255), "G": (112, 118, 118, 255), "h": (210, 214, 206, 255),
    "r": (168, 58, 52, 255), "R": (112, 36, 36, 255), "s": (226, 186, 146, 255), "c": (70, 112, 150, 255), "C": (46, 74, 104, 255),
}
ICONS = {
    "food": [  # loaf of bread
        "............",
        "............",
        "....kkkk....",
        "..kkyywykk..",
        ".kyywyyywyk.",
        ".kyyyyyyyyk.",
        "kYyyyyyyyyYk",
        "kYYyyyyyyYYk",
        ".kYYYYYYYYk.",
        "..kkkkkkkk..",
        "............",
        "............",
    ],
    "wood": [  # two stacked logs
        "............",
        "............",
        "..kkkkkkkk..",
        ".ktbbbbbbbk.",
        "kttBkbbbbbBk",
        ".ktbbbbbbbk.",
        "..kkkkkkkkk.",
        ".ktbbbbbbbk.",
        "kttBbbbkbbBk",
        ".ktbbbbbbbk.",
        "..kkkkkkkk..",
        "............",
    ],
    "stone": [
        "............",
        "............",
        "....kkkk....",
        "...khhggk...",
        "..khggggGk..",
        ".khgggggGGk.",
        ".kggggGgGGk.",
        "kgggGgggGGGk",
        "kGgggggGGGGk",
        ".kGGGGGGGGk.",
        "..kkkkkkkk..",
        "............",
    ],
    "gold": [  # coin
        "............",
        "...kkkkkk...",
        "..kyyyyyyk..",
        ".kywYYYYyYk.",
        ".kyYyyyyYYk.",
        ".kyYyyyyYYk.",
        ".kyYyyyyYYk.",
        ".kyYyyyyYYk.",
        ".kyyYYYYYYk.",
        "..kYYYYYYk..",
        "...kkkkkk...",
        "............",
    ],
    "influence": [  # crown
        "............",
        "............",
        ".k...k...k..",
        "kyk.kyk.kyk.",
        "kyykkyykkyyk",
        "kyyyyyyyyyyk",
        "kyrYyyyyrYyk",
        "kyyyyyyyyyyk",
        "kYYYYYYYYYYk",
        ".kkkkkkkkkk.",
        "............",
        "............",
    ],
    "people": [
        "............",
        "....kkkk....",
        "...kssssk...",
        "...kssssk...",
        "...kssssk...",
        "....kkkk....",
        "..kkccCCkk..",
        ".kccccccCCk.",
        ".kccccccCCk.",
        ".kccccccCCk.",
        ".kkkkkkkkkk.",
        "............",
    ],
}


def icon(rows):
    img = Image.new("RGBA", (12, 12), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        assert len(row) == 12, row
        for x, ch in enumerate(row):
            if ch != ".":
                img.putpixel((x, y), ICON_COLOURS[ch])
    return img


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    outputs = {
        "panel.png": framed("panel_fill", "panel_dither"),
        "bar.png": bar(),
        "title.png": title(),
        "grabber.png": grabber(),
    }
    for state in BUTTONS:
        outputs[f"button_{state}.png"] = button(state)
    for name, rows in ICONS.items():
        outputs[f"icon_{name}.png"] = icon(rows)
    for name, img in outputs.items():
        img.save(OUT / name)
    print(f"UI_ASSETS_OK {len(outputs)} files in {OUT}")


if __name__ == "__main__":
    main()
