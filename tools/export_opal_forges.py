"""Turn the exported Opal Forges into ready-to-paste Gemini skills (Preston, 2026-09-30).

Google is shutting Opal down on 2026-11-17 (runs stop after 11-16). Each Forge
is a small workflow file: some inputs the user fills in (a text brief, reference
images), one image-generation step whose instructions hold all the house
rules, and a review page that only displays the result. A Gemini skill is a
saved set of instructions you call in chat with /name, so the instructions
carry over and the inputs become "type the brief, attach these images".

  python tools/export_opal_forges.py
Reads the Forge files Preston downloaded into OneDrive "HollowTide Sprites/Opal",
copies them untouched into docs/forges/opal-export/ (the backup), and writes one
skill file per Forge into docs/forges/gemini-skills/.
"""
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = Path.home() / "OneDrive/Documents/HollowTide Sprites/Opal"
BACKUP = ROOT / "docs/forges/opal-export"
SKILLS = ROOT / "docs/forges/gemini-skills"

# Opal writes an input into a prompt as {{"type":"in","path":"ask_user_x","title":"X"}}.
PLACEHOLDER = re.compile(r'\{(\{"type":\s*"in".*?\})\}')
MODEL = {"image-pro": "Nano Banana Pro (Gemini's best image model)", "image": "Nano Banana (standard image model)",
         "text-3-flash": "Gemini Flash (text)"}
KIND = {"Text": "text you type", "Image": "an image you attach", "Any": "text or an image"}


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower().replace("hollowtide", "")).strip("-")


def fill(text: str, titles: dict) -> str:
    """Opal's input markers become plain [Input Name] labels."""
    def one(m: re.Match) -> str:
        try:
            info = json.loads(m.group(1))
        except json.JSONDecodeError:
            return m.group(0)
        return f"[{info.get('title') or titles.get(info.get('path'), info.get('path'))}]"
    return PLACEHOLDER.sub(one, text)


def prompt_text(config: dict) -> str:
    for key in ("config$prompt", "text"):
        if key in config:
            return "\n".join(p.get("text", "") for p in config[key].get("parts", []))
    return ""


def export(path: Path) -> str:
    graph = json.loads(path.read_text(encoding="utf-8"))
    name = graph.get("title", path.name)
    inputs, steps = [], []
    for node in graph["nodes"]:
        cfg = node.get("configuration", {})
        title = node.get("metadata", {}).get("title", node["id"])
        if node["id"].startswith("ask_user") or "p-modality" in cfg:
            hint = " ".join(p.get("text", "") for p in cfg.get("description", {}).get("parts", []))
            inputs.append((node["id"], title, cfg.get("p-modality", "Any"), hint))
        elif "generation-mode" in cfg:
            steps.append((title, cfg["generation-mode"], cfg.get("p-aspect-ratio"), prompt_text(cfg)))
    titles = {i[0]: i[1] for i in inputs}

    lines = [f"# {name}: Gemini skill", "",
             f"Exported from Opal on 2026-09-30 by `tools/export_opal_forges.py`. {graph.get('description', '')}", "",
             f"**Skill name to use in Gemini:** `{slug(name)}`", "",
             "## What you give it each run", ""]
    for _, title, kind, hint in inputs:
        lines.append(f"- **{title}:** {KIND.get(kind, kind)}. {hint}".rstrip())
    lines += ["", "## Model", ""]
    for title, mode, aspect, _ in steps:
        extra = f", aspect ratio {aspect}" if aspect else ""
        lines.append(f"- {title}: {MODEL.get(mode, mode)}{extra}")
    lines += ["", "The Opal review page (it only displayed the result) is not part of the skill.", ""]
    for n, (title, mode, _, text) in enumerate(steps, 1):
        header = "Skill instructions (paste this into the skill)" if n == 1 else f"Follow-up step {n}: {title}"
        lines += [f"## {header}", "", "```text"]
        if n == 1:
            names = ", ".join(f"[{t}]" for _, t, _, _ in inputs)
            lines.append(f"Each time this skill runs, I will give you {names} in my message. Use them exactly as described below.")
            lines.append("")
        lines += [fill(text, titles).strip(), "```", ""]
    out = SKILLS / f"{slug(name)}.md"
    out.write_text("\n".join(lines), encoding="utf-8")
    return f"{name}: {len(inputs)} inputs, {len(steps)} generation step(s) -> {out.relative_to(ROOT)}"


if __name__ == "__main__":
    BACKUP.mkdir(parents=True, exist_ok=True)
    SKILLS.mkdir(parents=True, exist_ok=True)
    for f in sorted(SOURCE.glob("Hollowtide*")):
        shutil.copy2(f, BACKUP / (f.name + ".json"))
        print(export(f))
