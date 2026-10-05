# Hollowtide — Game Soul

> **Priority: Locked** — This document defines the durable soul of Hollowtide. All design, art, audio, and gameplay work must align with these pillars. Do not alter core rules without explicit confirmation.

---

## 1. The Soul & Pitch
**Hollowtide** is a moody, character-led monster-collecting RPG built in 2D top-down pixel art with tactical turn-based combat.

You play as a courier for the **Wayline Compact** in the **Siltward Reach** (a misted river watershed inspired by historical river towns like St. Joseph, Missouri). You deliver messages, steward forgotten river routes, and study the wild. The central mystery is the **Hollowtide** — an eerie recurring hush across the watershed that alters creature migration, echoes dead voices, and disrupts line communications.

---

## 2. Core Pillars

1. **No Grinding, No Filler:** Battles are deliberate and consequential. Victory comes from elemental mastery, matchup strategy, and body capabilities, never mindless level-grinding or RNG rolling.
2. **No Items in Battle:** Battles are pure creature encounters. Capture is a free action that scales as the wild creature's HP drops. No disposable capture capsules or combat potions.
3. **Evolution Changes Identity, Not Just Numbers:** Every evolution line has a strict maximum of 3 stages. Evolution is strictly linear (no branching, no converging). Each stage has a distinct role and identity in combat, not just inflated stats.
4. **Every Route Connects People:** Routes and wilderness aren't empty obstacle courses; they are living pathways that connect communities, carrying parcels, mail, lore, and courier duties.
5. **Authentic Bodies and Move Legality:** A creature cannot use a move unless its body physical features (vents, claws, shells, kiln chambers, split tails) support the action.

---

## 3. The Eight Essences

The essence chart is intuitive and grounded:
* **The Cycle:** Ember burns Bloom, Bloom breaks Stone, Stone dams Tide, Tide quenches Ember.
* **Gale:** Neutral scattering element; acts as high-speed scout.
* **Hollow:** Consumes everything; a high-risk glass cannon (deals 2.0× to everything, takes 2.0× from everything).
* **Electric & Ice:** Electric is strong into Tide and weak into Stone. Ice is the cold counterpart to Bloom and Ember.

---

## 4. Roles & Jobs
Every creature line has one distinct job. Two forms in the same essence never share the same role:
* **Starter:** Reliable stage 1, wins neutral duels against peers.
* **Runner:** Highest speed in bracket; strikes first, lower HP.
* **Cannon:** Overwhelming offensive power, low speed, heavy wind-up.
* **Wall:** Massive HP/Defense, resilient anchor.
* **Protector:** Guard specialist (reserved exclusively for the Punchybuns line).

---

## 5. Reserved Canon & Special Directives
* **Punchybuns Line:** An Electric ferret protector line reserved in memory of Adrianna. It features boxer stances, a pink mask/star, puffy cheeks, and the game's only Guard Ultimate ("Star Shield").
* **Ultimates vs Signatures:**
  * **Ultimate:** Final-stage exclusive scene-taking attack (e.g., *Molten Glass* for Vitrecrag, *Furnace Roar* for Ironvent, *Kingstone Rail* for Oxbowarchon). Takes 2 uses max. Cannot be taught to other lines.
  * **Signature:** A characteristic body move that can be taught only to other creatures possessing all required body parts (verified through `MoveGate`).

---

## 6. Technical Foundations
* **Engine:** Summer Engine (Godot 4.7 Forward Plus technical base).
* **Resolution & Display:** 1152×648 base viewport, canvas_items stretch mode, pixel-snap rendering.
* **Language:** GDScript (`.gd`) with strict static typing and explicit signal signatures.
