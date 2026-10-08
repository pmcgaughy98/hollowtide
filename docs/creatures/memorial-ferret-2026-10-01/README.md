# The electric ferret line, for Adrianna (2026-10-01)

Reserved in `docs/creatures/DESIGN_RULES.md` (2026-10-02). This line stays. It is not a generic Electric starter and it is not optional. In the project today: this note, `stage1_prompt.json`, and `stage1_front_128_take1.png`. Stages II and III are designed below and are not drawn yet. No creature data file yet.

Made for Adrianna ("Punchybuns"), at the request of her twin sister Gabrielle. Gabrielle's direction: three stages, electric, a ferret, inspired by Pikachu without echoing it. Adrianna loved Steven Universe. Everything below is a proposal for Gabrielle and Preston to change.

## The idea: a ferret who protects the people it loves
- **Stage I (proposal name: Punchybun).** A round, spunky kit that does the ferret "war dance" to build static. Little boxer fists (punchy) and puffy cheeks (buns). Cream fur, a pink ferret mask, a pink star on its forehead, a sparking bottle-brush tail. First take: `stage1_front_128_take1.png`.
- **Stage II (name open).** A longer, springier ferret in a boxer's stance. Its paw pads glow with charge, and the star marking spreads into a crackle of tiny stars down its back.
- **Stage III (name open; could carry Adrianna's name if Gabrielle wants).** A large, graceful guardian ferret whose long body flows in an S like a lightning bolt. The star becomes a glowing pink star-gem on its chest, a nod to the gems in Steven Universe. Its signature move could be a star-shaped electric shield that protects instead of attacks, the show's big idea of protecting the people you love. The battle code already supports guard moves; none use it yet.

**Nods to Adrianna:** her handle in the Stage I name; the star (Steven's shirt) and pink (Rose Quartz) from Steven Universe; Pikachu's spirit (a cheerful electric partner) without its look: cream not yellow, no red cheeks.

## Open questions for Gabrielle
Her favourite colours and three words for her personality (to tune the palette and the creature's attitude), and the names for Stages II and III.

## Next
Gabrielle approves or changes Stage I, then Stage II is made from it, then Stage III, each rotated to 8 directions with Retro Diffusion.

## In the game, provisionally (2026-10-05)

Preston asked to add Punchybuns "for now". `data/creatures/2101_punchybun.tres` is Stage I only: take 1 art (`assets/sprites/creatures/punchybun_2026_10_05/punchybun_front.png`), Electric, default 60 stats, no moves (Strike), no back view (the battle shows the front), no evolution. Name "Punchybun" and Dex 2101 are placeholders. Stages II and III still wait for Gabrielle's answers.

## Stage II and III candidates (2026-10-08)

Preston asked directly: "make Punchybun stage 2 and 3." Gabrielle's open questions above are still open, so these are candidates built from the stage descriptions in this note, names still hers to give. Retro Diffusion `rd_pro__default` with the stage 1 front as the reference, three takes each: `stage2_front_take1..3.png` (144 px, the longer boxer: upright stance, fists up, glowing paw pads, the star crackling down its back) and `stage3_front_take1..3.png` (160 px, the guardian: the S-curve body, the pink star-gem on the chest, the big crackling tail). $1.08 together; strip `stage2_3_candidates.png`. Preston picks one of each; then rotations and back views follow the usual method, and the data files get `evolves_into` links.

**Preston chose take a for both (2026-10-08).** Installed as `assets/sprites/creatures/punchybun_2026_10_05/punchybun_stage2_front.png` and `punchybun_stage3_front.png`, with data files `data/creatures/2102_punchybun2.tres` and `2103_punchybun3.tres` (placeholder names "Punchybun II" and "Punchybun III", Electric, default stats, no moves) and the evolution chain 2101 to 2102 to 2103 (`CreatureRoster.validate_evolutions` passes, 21 creatures). Back views by the back-view method: an RD image edit of each front ("turn this exact same creature around", $0.36 together), then `tools/unity_port/finish_back.py` locked each to its front's colours, outline and canvas (`stage2_back_edit.png` raw, `stage2_back_finished.png` installed; same for stage 3; review strip `backs_review.png`). Stage I still has no back view. Not in the arena: the arena forms (take, rotation, walks, about $3) and the Protector kit with the star-shield guard are a later slice, after Grok's kit. Names remain Gabrielle's.

## Taken over (Preston, 2026-10-08, later)

"Gabrielle isn't interested anymore, so we're taking over. You make the names, then do what we need to get Punchybuns' line ready and into the arena." So the open questions above are closed by Preston and Claude:
- **Names (Claude's):** Punchybun (kept: Adrianna's handle), **Sparkjab** (the boxer whose jabs spark), **Starward** (the guardian; "ward" says what it does). Data files renamed `2102_sparkjab.tres`, `2103_starward.tres`; the chain still validates.
- **Arena:** the line is the seventh picker column and the roster's **Protector**, the first support: Spark Jab, Static Dance, Star Guard, Counter Jab, passive Guardian, signature **Starshield**. Write-up: `docs/creatures/arena-starward-2026-10-08/README.md`.
- The memorial framing stays: the pink, the star, protecting the people it loves.

