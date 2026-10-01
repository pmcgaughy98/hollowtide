"""Turn downloaded Opal Forges into portable Gemini instructions.

Keep the downloaded graphs intact. Merge separately recorded, verified prompt
revisions before rendering instructions, without calling the result a live app
backup. Stop if a revised Forge's downloaded graph no longer matches its recorded
base: a newer download needs review before an older revision is applied.

  python tools/export_opal_forges.py
Reads the Forge files Preston downloaded into OneDrive "HollowTide Sprites/Opal",
copies them untouched into docs/forges/opal-export/ (the backup), and writes one
skill file per Forge into docs/forges/gemini-skills/.

  python tools/export_opal_forges.py --forge character-model-forge --forge walk-cycle-forge
Exports only the named Forges. Revision metadata lives in
docs/forges/records/verified-export-revisions.json.
"""
import argparse
import copy
import hashlib
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = Path.home() / "OneDrive/Documents/HollowTide Sprites/Opal"
BACKUP = ROOT / "docs/forges/opal-export"
SKILLS = ROOT / "docs/forges/gemini-skills"
REVISIONS = ROOT / "docs/forges/records/verified-export-revisions.json"
PROTECTED = {"character-model-forge", "walk-cycle-forge"}

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
    return PLACEHOLDER.sub(one, text).replace("\ufeff", "")


def prompt_text(config: dict) -> str:
    for key in ("config$prompt", "text"):
        if key in config:
            return "\n".join(p.get("text", "") for p in config[key].get("parts", []))
    return ""


def graph_digest(graph: dict) -> str:
    encoded = json.dumps(graph, sort_keys=True, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def load_revisions() -> dict:
    data = json.loads(REVISIONS.read_text(encoding="utf-8"))
    if data.get("schema_version") != 1:
        raise ValueError("Unsupported verified-export-revisions schema")
    entries = {entry["forge_slug"]: entry for entry in data["revisions"]}
    if not PROTECTED.issubset(entries):
        raise ValueError("Character and Walk verified revisions must be present before export")
    return entries


def apply_revision(graph: dict, revisions: dict) -> tuple[dict, dict | None]:
    key = slug(graph["title"])
    entry = revisions.get(key)
    if entry is None:
        return graph, None
    if graph_digest(graph) != entry["base_graph_sha256"]:
        raise ValueError(f"{graph['title']}: downloaded graph differs from the recorded base. "
                         "Review the newer graph and refresh its revision record; current instructions were not overwritten.")

    record_path = ROOT / entry["record_path"]
    record = json.loads(record_path.read_text(encoding="utf-8"))
    group = entry["record_group"]
    verification = record["verification"]
    if not (verification.get(f"{group}_generate_reopened") is True
            and verification.get(f"{group}_review_reopened") is True):
        raise ValueError(f"{graph['title']}: saved prompts lack reopen verification")

    effective = copy.deepcopy(graph)
    nodes = {node["id"]: node for node in effective["nodes"]}
    input_ids = {node["id"] for node in effective["nodes"]
                 if node["id"].startswith("ask_user") or "p-modality" in node.get("configuration", {})}
    if input_ids != set(entry["input_hints"]) or verification.get(f"{group}_inputs") != len(input_ids):
        raise ValueError(f"{graph['title']}: revision input mapping does not match the downloaded graph")

    prompt = record[group]["after"]
    linked_inputs = {json.loads(match.group(1))["path"] for match in PLACEHOLDER.finditer(prompt)}
    if linked_inputs != input_ids:
        raise ValueError(f"{graph['title']}: verified prompt is missing a reference input")
    generate = nodes[entry["generate_node"]]
    if "generation-mode" not in generate["configuration"]:
        raise ValueError(f"{graph['title']}: recorded Generate node is not an image step")
    generate["metadata"]["title"] = record["payload"][entry["generate_title_key"]]
    generate["configuration"]["config$prompt"] = {"role": "user", "parts": [{"text": prompt}]}
    review = nodes[entry["review_node"]]
    review["configuration"]["text"] = {"role": "user", "parts": [{"text": record[group]["review_after"]}]}
    for node_id, payload_key in entry["input_hints"].items():
        nodes[node_id]["configuration"]["description"] = {
            "role": "user", "parts": [{"text": record["payload"][payload_key]}]}
    return effective, {"date": record["date"], "record_path": entry["record_path"]}


def backup_download(path: Path) -> None:
    """Retain earlier downloads when a newer raw file replaces their named backup."""
    target = BACKUP / (path.name + ".json")
    if target.exists() and target.read_bytes() != path.read_bytes():
        digest = hashlib.sha256(target.read_bytes()).hexdigest()[:16]
        history = BACKUP / "history"
        history.mkdir(parents=True, exist_ok=True)
        archived = history / f"{slug(path.name)}-{digest}.json"
        if not archived.exists():
            shutil.copy2(target, archived)
    shutil.copy2(path, target)


def export(path: Path, graph: dict, revision: dict | None) -> str:
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
             "Built from a downloaded Opal graph by `tools/export_opal_forges.py`. "
             "The raw graph remains in `../opal-export/`.", "",
             f"**Skill name to use in Gemini:** `{slug(name)}`", "",
             "## What you give it each run", ""]
    if revision:
        record_link = (ROOT / revision["record_path"]).relative_to(ROOT / "docs/forges")
        lines[4:4] = [f"Includes the saved {revision['date']} Generate prompt and input hints from "
                      f"[the verified revision](../{record_link.as_posix()}). "
                      "Checked after reopening in Opal; no generation-quality claim. "
                      "This is a merged instruction export, not a fresh live app backup.", ""]
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
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--forge", action="append", default=[], metavar="SLUG",
                        help="Export only this Forge slug; repeat to select more than one")
    args = parser.parse_args()
    sources = sorted(path for path in SOURCE.glob("Hollowtide*") if path.is_file())
    requested = set(args.forge)
    available = {slug(path.stem if path.suffix == ".json" else path.name) for path in sources}
    if requested - available:
        parser.error(f"Unknown Forge slug(s): {', '.join(sorted(requested - available))}")
    if requested:
        sources = [path for path in sources if slug(path.stem if path.suffix == ".json" else path.name) in requested]
    try:
        revisions = load_revisions()
        prepared = []
        # Validate every selected graph before writing any portable instructions.
        for path in sources:
            graph = json.loads(path.read_text(encoding="utf-8"))
            graph, revision = apply_revision(graph, revisions)
            prepared.append((path, graph, revision))
    except (ValueError, KeyError, OSError) as error:
        parser.exit(1, f"Export stopped: {error}\n")
    BACKUP.mkdir(parents=True, exist_ok=True)
    SKILLS.mkdir(parents=True, exist_ok=True)
    for path, graph, revision in prepared:
        backup_download(path)
        print(export(path, graph, revision))
