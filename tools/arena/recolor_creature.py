"""New colours for lines that read as plain Earth animals (Claude, 2026-10-11; Preston: "recolor all the creatures
that have regular earth animal colors, like Tallowroot, Kithflare and Rimefin. You choose colors").

Each scheme moves hue bands of a line to new hues, keeps every pixel's own lightness (so the shading and the
pixel work survive), and leaves the dark outline alone. The same rule is applied to every file of the line,
so all sizes, walks, actions and portraits stay matched.
  python tools/arena/recolor_creature.py preview <scheme> [<scheme> ...] <out.png>
  python tools/arena/recolor_creature.py apply <scheme>     rewrites the line's game files in place
Backups: docs/creatures/recolor-2026-10-11/before/<same path>.

Schemes (Claude's choices, proposals for Preston):
  ember   Kithflare's line: the tan-orange gecko becomes crimson with a molten-gold belly and markings.
  jade    Tallowroot's line: the plain green becomes jade-teal, the brown bark a deep plum; bright leaves stay.
  tide    Rimefin's line: the grey-blue catfish becomes deep ultramarine with bright aqua fins and an icy belly.
"""
import colorsys, shutil, sys, time
from pathlib import Path
from PIL import Image

BACKUP = Path("docs/creatures/recolor-2026-10-11/before")


def _ember(h, l, s):
    if h <= 55 / 360 or h >= 345 / 360:
        if l > 0.62 and s > 0.15:                       # the pale belly and markings: molten gold
            return 44 / 360, min(0.92, l * 1.02), max(s, 0.72)
        return 352 / 360, l * 0.95, min(1.0, s * 1.15 + 0.12)   # the body: crimson
    return None


def _jade(h, l, s):
    if 55 / 360 <= h <= 140 / 360:
        if l > 0.6 and s > 0.35:                        # bright new leaves stay spring green
            return None
        return 162 / 360, l, min(1.0, s * 1.1 + 0.08)   # the body: jade-teal
    if 10 / 360 <= h < 55 / 360 and s > 0.12:
        return 326 / 360, l * 0.92, min(0.38, s * 0.75)  # bark and soil browns: a dark plum wood
    return None


def _tide(h, l, s):
    if 170 / 360 <= h <= 250 / 360:
        if h < 190 / 360 or l > 0.66:                  # fins and highlights: bright aqua
            return 178 / 360, l, max(s, 0.55)
        return 232 / 360, l * 0.95, max(s, 0.5)         # the body: deep ultramarine
    if s < 0.12 and 0.35 < l < 0.93:                    # the grey belly: icy, a breath of cyan
        return 190 / 360, l, 0.22
    return None


def band(hues, smax=1.0, lmin=0.0, lmax=1.0, to=0.0, sat=0.35, greys=None, smin=0.12):
    """A rule: pixels whose hue falls in `hues` (degrees, may wrap) and whose saturation and lightness are in
    range take hue `to` and saturation `sat` (blended with their own so ramps keep some life); greys inside
    `greys` (lightness range) are tinted the same way. Everything else (outline, eyes, job gear) stays."""
    lo, hi = hues

    def rule(h, l, s):
        d = h * 360
        inside = (lo <= d <= hi) if lo <= hi else (d >= lo or d <= hi)
        if s >= smin and inside and s <= smax and lmin <= l <= lmax:
            return to / 360, l, min(1.0, 0.65 * sat + 0.35 * s + 0.08)
        if greys and s < 0.12 and greys[0] <= l <= greys[1]:
            return to / 360, l, sat * 0.7
        return None
    return rule


def _toward(h, target, amount):
    """Turn hue h (degrees) toward target by `amount` degrees along the short way round."""
    d = (target - h + 540) % 360 - 180
    step = max(-abs(d), min(abs(d), amount)) if d >= 0 else -max(-abs(d), min(abs(d), amount))
    return (h + (amount if d > 0 else -amount) if abs(d) > amount else target) % 360


def ramp(hues, base, peak=0.55, shift=22, smin=0.12, smax=1.0, lmin=0.0, lmax=1.0, pale=None, greys=None):
    """A hand-made-looking ramp (2026-10-11, second pass; Preston: "use synthesis and do another recolor").
    From pixel-art palette practice (SLYNYRD's Pixelblog on colour ramps): highlights warm toward yellow and
    shadows cool toward blue-violet as brightness changes, saturation peaks in the midtones and falls off
    in the brightest tones. Body pixels in `hues` get the `base` ramp; pale pixels (lightness above
    pale[0], the belly and undersides) get a secondary ramp on hue pale[1]; greys in `greys` join the body."""
    lo, hi = hues

    def colour(l, h0, pk):
        t = max(-1.0, min(1.0, (l - 0.5) * 2.2))       # -1 deep shadow .. +1 bright highlight
        h = _toward(h0, 58, shift * t) if t > 0 else _toward(h0, 250, shift * -t)
        sat = pk * (1.0 - 0.75 * max(0.0, t) ** 1.5) * (1.0 + 0.15 * max(0.0, -t))
        return h / 360, l, max(0.1, min(0.95, sat))

    def rule(h, l, s):
        d = h * 360
        inside = (lo <= d <= hi) if lo <= hi else (d >= lo or d <= hi)
        body = (s >= smin and inside and s <= smax and lmin <= l <= lmax) or (greys and s < 0.12 and greys[0] <= l <= greys[1])
        if not body:
            return None
        if pale and l > pale[0]:
            return colour(l, pale[1], pale[2] if len(pale) > 2 else 0.4)
        return colour(l, base, peak)
    return rule


def stylize(hues, base, sat, smax=1.0, smin=0.0, lmin=0.0, lmax=1.0, accent=None, greys=None, pull=0.6):
    """Third pass (Preston, 2026-10-11: "use synthesis to do a different recolor"). How finished monster games
    colour animal-based creatures: the animal's own colour family kept but made clean, warm and toy-like
    (more saturation, a tint in the greys, more light-dark contrast), and the 'monster' coming from ONE bold
    accent region in an unnatural colour tied to its type. Body pixels move `pull` of the way to hue `base`;
    pixels of the body in the accent's lightness range take the accent hue: accent = (lmin, lmax, hue, sat)."""
    lo, hi = hues

    def rule(h, l, s):
        d = h * 360
        inside = (lo <= d <= hi) if lo <= hi else (d >= lo or d <= hi)
        body = (s >= smin and s <= smax and inside and lmin <= l <= lmax) or (greys and s < 0.12 and greys[0] <= l <= greys[1])
        if not body:
            return None
        nl = min(0.94, max(0.13, 0.5 + (l - 0.5) * 1.12))   # a little more contrast
        if accent and accent[0] <= l <= accent[1]:
            t = (l - accent[0]) / max(0.01, accent[1] - accent[0])
            return ((accent[2] + 10 * (t - 0.5)) % 360) / 360, nl, accent[3]
        dh = (base - d + 540) % 360 - 180
        nh = (d + dh * pull) % 360
        ns = min(0.85, max(sat * (1.0 - 0.6 * max(0.0, nl - 0.6)), s * 1.35 + 0.05))
        return nh / 360, nl, ns
    return rule


def polish(lift=1.15, contrast=1.06):
    """For creatures whose palettes already read as monsters: the same hues, a little cleaner and crisper."""
    def rule(h, l, s):
        if s < 0.06:
            return None
        return h, min(0.94, max(0.13, 0.5 + (l - 0.5) * contrast)), min(0.9, s * lift + 0.02)
    return rule


SCHEMES = {
    # The starters, redone the same way as everyone else (Preston, 2026-10-11: "including starters ALL CREATURES").
    "ember": {"forms": ["kithflare", "sparkwick", "stormwick"], "rule": stylize((0, 55), 24, 0.6, smax=0.75, pull=0.5)},
    "jade": {"forms": ["tallowroot", "huskward", "rampartroot"], "rule": stylize((55, 135), 100, 0.5, smax=0.6, lmax=0.6, pull=0.5)},
    "tide": {"forms": ["rimefin", "riftfin", "scourmaw"], "rule": stylize((170, 250), 205, 0.42, smax=0.5, pull=0.5, greys=(0.35, 0.85))},
    # The others, third pass: their own colour families made clean and warm, accents placed on real features separately (Preston chose B), a Missouri
    # river palette (mud, rust, river teal, moss, slate). Claude's choices, proposals for Preston.
    "canvaswing": {"forms": ["canvaswing", "windcut", "galeshear"], "rule": stylize((350, 45), 24, 0.38, smax=0.3, lmax=0.55, greys=(0.15, 0.5))},
    "dustkite": {"forms": ["dustkite", "waywhistle", "highsignal"], "rule": stylize((25, 60), 38, 0.45, smax=0.4, greys=(0.35, 0.75))},
    "troughspine": {"forms": ["troughspine", "archroot", "springvault"], "rule": stylize((180, 240), 205, 0.32, smax=0.3, greys=(0.35, 0.85))},
    "mirekit": {"forms": ["mirekit"], "rule": stylize((0, 40), 28, 0.3, smax=0.35, lmax=0.6, greys=(0.2, 0.6))},
    "whinet": {"forms": ["whinet"], "rule": stylize((10, 60), 30, 0.35, smax=0.3, lmax=0.75)},
    "gruntle": {"forms": ["gruntle"], "rule": stylize((330, 40), 18, 0.38, smax=0.3, greys=(0.2, 0.6)), "accent": {"near": [(54, 43, 42)], "tol": 16, "hue": 352, "sat": 0.62, "floor": 0.3}},
    "skimlet": {"forms": ["skimlet"], "rule": stylize((340, 40), 15, 0.45, smax=0.45)},
    "ozbender": {"forms": ["ozbender"], "rule": stylize((0, 60), 24, 0.6, smax=0.6), "accent": {"near": [(142, 117, 66)], "tol": 8, "hue": 50, "sat": 0.82, "floor": 0.55}},
    "valvekin": {"forms": ["valvekin"], "rule": stylize((20, 70), 75, 0.45, smax=0.5), "accent": {"near": [(136, 126, 63)], "tol": 18, "hue": 176, "sat": 0.45, "floor": 0.4}},
    "swaphoard": {"forms": ["swaphoard"], "rule": stylize((340, 30), 30, 0.3, smax=0.25, greys=(0.3, 0.7))},
    "inkhoot": {"forms": ["inkhoot"], "rule": stylize((340, 40), 30, 0.3, smax=0.3, greys=(0.2, 0.7)), "accent": {"near": [(96, 84, 78)], "tol": 14, "hue": 222, "sat": 0.5, "floor": 0.3}},
    "cairnshell": {"forms": ["cairnshell"], "rule": stylize((30, 75), 70, 0.42, smin=0.1, smax=0.42, lmax=0.52)},
    "grubbit": {"forms": ["grubbit"], "rule": stylize((190, 250), 228, 0.3, smax=0.3)},
    "muskin": {"forms": ["muskin"], "rule": stylize((330, 20), 22, 0.45, smax=0.28)},
    "slipjaw": {"forms": ["slipjaw"], "rule": stylize((340, 32), 25, 0.5, smax=0.5, lmax=0.62)},
    "stillwade": {"forms": ["stillwade"], "rule": stylize((180, 240), 210, 0.4, smax=0.6), "accent": {"near": [(35, 53, 84)], "tol": 10, "hue": 44, "sat": 0.7, "floor": 0.42}},
    # Accents on real features (Preston chose B, 2026-10-11): the colour of the feature in the original art,
    # found by clustering its palette, and the accent it takes.
    # gruntle: its bristle mane, crimson; inkhoot: its ink-line feather bars, ink blue; stillwade: its crest,
    # gold; ozbender: its spots, yellow (Missouri's spotted salamander); valvekin: its shell's growth bands, river teal.
    # Every other creature, not the starters ("do all creatures"), keeps its hues, cleaned and crisper.
    "cinderhide": {"forms": ["cinderhide", "clinkerhide", "ironvent"], "rule": polish()},
    "fusern": {"forms": ["fusern", "slagglass", "vitrecrag"], "rule": polish()},
    "preostmar": {"forms": ["preostmar", "oathfen", "oxbowarchon"], "rule": polish()},
    "punchybun": {"forms": ["punchybun", "sparkjab", "starward"], "rule": polish(1.1, 1.04)},
    "listener": {"forms": ["listener", "caller", "warden"], "rule": polish()},
    "wayling": {"forms": ["wayling"], "rule": polish(1.08, 1.04)},
    "pouchbill": {"forms": ["pouchbill"], "rule": polish(1.08, 1.04)},
    "crawdukes": {"forms": ["crawdukes"], "rule": stylize((330, 45), 10, 0.6, smax=0.8, pull=0.4)},   # its own red, cleaned and warmed (Preston, 2026-10-11). A verdigris accent on its plates was tried and dropped: matching by colour left teal smears across the shell; its whistle and rope tape are its accents
    "wickglow": {"forms": ["wickglow"], "rule": polish(1.05, 1.04)},
    "rinsepaw": {"forms": ["rinsepaw"], "rule": stylize((0, 60), 28, 0.3, smax=0.35, greys=(0.25, 0.78), pull=0.5)},   # the cook: its own grey-brown, warmed; no accent (its hands share the tail rings' colour, so a ring accent turned them into teal gloves; the apron is its accent, like Muskin's satchel)
}


def recolor(im: Image.Image, rule, accent=None) -> Image.Image:
    im = im.convert("RGBA")
    orig = im.copy().load()
    px = im.load()
    cache = {}
    is_accent = {}   # original colours that took the accent
    plain = {}       # what those colours would be without it
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            key = (r, g, b)
            if key not in cache:
                h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
                out = None if l < 0.12 else rule(h, l, s)   # the outline stays
                body_out = out
                if accent and l >= 0.12 and min(sum((c1 - c2) ** 2 for c1, c2 in zip(key, c)) for c in accent["near"]) <= accent["tol"] ** 2:
                    al = min(0.8, max(accent.get("floor", 0.28), l * 1.15))   # an accent dark enough to vanish is lifted
                    out = ((accent["hue"] + 12 * (al - 0.45)) % 360 / 360, al, accent["sat"])
                    is_accent[key] = True
                if out is None:
                    cache[key] = key
                else:
                    nr, ng, nb = colorsys.hls_to_rgb(*out)
                    cache[key] = (round(nr * 255), round(ng * 255), round(nb * 255))
                if is_accent.get(key):
                    if body_out is None:
                        plain[key] = key
                    else:
                        br, bg, bb = colorsys.hls_to_rgb(*body_out)
                        plain[key] = (round(br * 255), round(bg * 255), round(bb * 255))
            px[x, y] = cache[key] + (a,)
    if is_accent:
        _drop_specks(im, px, is_accent, plain, original=orig)
    return im


def _drop_specks(im, px, is_accent, plain, original):
    """Accent pixels count only where they form a real patch (a mane, a band, spots): groups smaller than about
    0.4% of the creature go back to the body colour, so no scattered specks or smears are left."""
    from collections import deque
    w, h = im.size
    acc = [[original[x, y][3] > 0 and is_accent.get(original[x, y][:3], False) for x in range(w)] for y in range(h)]
    area = sum(1 for y in range(h) for x in range(w) if original[x, y][3] > 0)
    need = max(5, int(area * 0.004))
    seen = [[False] * w for _ in range(h)]
    for y in range(h):
        for x in range(w):
            if not acc[y][x] or seen[y][x]:
                continue
            group = [(x, y)]; seen[y][x] = True; q = deque(group)
            while q:
                cx, cy = q.popleft()
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
                    nx, ny = cx + dx, cy + dy
                    if 0 <= nx < w and 0 <= ny < h and acc[ny][nx] and not seen[ny][nx]:
                        seen[ny][nx] = True; group.append((nx, ny)); q.append((nx, ny))
            if len(group) < need:
                for gx, gy in group:
                    r, g, b, a = original[gx, gy]
                    px[gx, gy] = plain[(r, g, b)] + (a,)


def files(form: str) -> list:
    """Every file the game reads for a form, plus the walk and action sheets its sets are rebuilt from."""
    out = sorted(Path(f"assets/sprites/arena/{form}").rglob("*.png"))
    out += sorted(Path("assets/sprites/ui/dialogue").glob(f"{form}*.png"))
    out += [p for p in sorted(Path("assets/sprites/creatures").rglob("*.png")) if form in p.name.lower() or form in str(p.parent).lower()]
    out += sorted(Path("docs/creatures/arena-starters-2026-10-07/walk").glob(f"{form}_*_sheet.png"))
    out += sorted(Path("docs/creatures/actions-2026-10-09").glob(f"{form}*.png"))
    return list(dict.fromkeys(out))


def preview(names, out):
    rows = []
    for n in names:
        for form in SCHEMES[n]["forms"]:
            p = Path(f"assets/sprites/arena/{form}/s.png")
            if p.exists():
                rows.append(Image.open(p).convert("RGBA"))
    cell = 132
    sheet = Image.new("RGBA", (cell * 2 * 3, cell * len(names)), (232, 226, 210, 255))
    for i, im in enumerate(rows):
        r, c = i // 3, i % 3
        im.thumbnail((cell - 4, cell - 4))
        after = recolor(im, SCHEMES[names[r]]["rule"], SCHEMES[names[r]].get("accent"))
        sheet.paste(im, (c * cell * 2 + 2, r * cell + 2), im)
        sheet.paste(after, (c * cell * 2 + cell + 2, r * cell + 2), after)
    sheet.save(out)


def apply(name):
    n = 0
    for form in SCHEMES[name]["forms"]:
        for p in files(form):
            keep = BACKUP / p
            if not keep.exists():
                keep.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(p, keep)
            out = recolor(Image.open(keep), SCHEMES[name]["rule"], SCHEMES[name].get("accent"))   # always from the original
            for attempt in range(6):   # Windows can hold a file for a moment (Errno 22); try again
                try:
                    out.save(p)
                    break
                except OSError:
                    time.sleep(0.5)
            else:
                print("could not write", p)
            n += 1
    print(name, "files recoloured:", n)


if __name__ == "__main__":
    if sys.argv[1] == "preview":
        preview(sys.argv[2:-1], sys.argv[-1])
    elif sys.argv[1] == "apply":
        for name in sys.argv[2:]:
            apply(name)
