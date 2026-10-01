# River Listener line — design proposal

The [move identity draft](../battle/river-listener-moves-draft.md) describes four working moves per stage and the battle rules needed before its defensive kit can be implemented.

**Status:** Preston selected River Listener as the first nonstarter three-stage line to develop. Its stage labels, exact designs, evolution trigger, and art remain proposals and are not connected to creature resources.

**Roster role:** one of the current 20 proposed three-stage lines (60 forms total), separate from the six starter lines. Cinderhide's starter line is the currently linked evolution prototype.

**Research anchor:** Missouri Department of Conservation describes the paddlefish's paddle-shaped rostrum, filter-feeding gill rakers, and electrosensory ability. Smithsonian reports that Late Cretaceous paddlefish fossils show very similar filter-feeding anatomy. Hollowtide borrows the idea of sensing a river through unusual anatomy; it does not depict a real paddlefish or claim that this fictional creature's biology is factual. [MDC Paddlefish field guide](https://mdc.mo.gov/discover-nature/field-guide/paddlefish) · [Smithsonian National Museum of Natural History](https://www.smithsonianmag.com/blogs/national-museum-of-natural-history/2026/09/22/meet-the-spatula-nosed-fish-whose-anatomy-has-hardly-changed-since-the-cretaceous/)

## Line identity

The line senses changes in water pressure and faint electrical fields through a split, shovel-like brow and flexible gill fans. It is not a shark, catfish, turtle, or armored lizard. Its repeated shape language is **two offset sensory paddles, ribbed gill fans, and open negative space beneath the brow**.

- **Essence path:** Tide -> Tide -> Tide/Hollow (working proposal). Hollow represents the line's late-stage sensitivity to absences and misleading echoes, not death or evil.
- **Battle job:** defensive scout; interrupts, redirects, or protects rather than winning through raw damage.
- **Habitat role:** a fictional cutbank and backwater specialist. Specific local habitat placement is a design choice, not a claim about paddlefish behavior.
- **Capture character:** wary but curious; it follows steady taps across submerged stones and retreats from loud, irregular noise.
- **Field skill, later:** distinguish a live call from an echo or reveal a safe shallow crossing. Keep this out of the first battle slice until exploration needs it.
- **Names:** “River Listener” is a descriptive line label. Cutbank Listener, Bend Caller, and Quietwater Warden are working stage names pending collision review and Preston's approval.

## Stage silhouettes

### Stage I — Cutbank Listener (working label)

Small and low to the ground, with a compressed body, short bracing fins, two shallow paddle lobes at the brow, and three narrow gill fans. It taps stones to map nearby space. The silhouette is alert and quick, with the split brow readable at the Forge's 100-by-100 logical-grid target and at its actual battle display size. The generated image must be checked; the prompt alone does not prove that grid was obeyed.

An earlier hand-drawn silhouette study exists in this folder. It is not production art and must not be used as the sprite or as a later-stage reference. Make this line's art through Hollowtide Sprite Forge.

### Stage II — Bend Caller (working label)

The trunk lengthens and the gill fans widen into three rigid, backward-swept plates. A second brow ridge creates a small resonance chamber. Its call can bend around a riverbank, but the creature has not learned to tell a living reply from an old echo. It should look broader and more deliberate than Stage I, not simply larger.

### Stage III — Quietwater Warden (working label)

Long, powerful, and grounded, with layered dorsal ridges and dark glass-like gill chambers. The split brow becomes a pair of broad, asymmetrical sensory vanes. Its Hollow aspect lets it recognize when a sound has no living source. It guides other creatures around unstable channels rather than commanding or attacking them.

## Evolution and implementation notes

- Keep the line one-to-one: Stage I -> Stage II -> Stage III. No branching, shared destinations, or loops.
- Evolution should change silhouette and field behavior as well as battle role. The exact trigger remains open; do not link any resource until Preston approves the trigger and generated forms.
- The code already has an `evolves_into` resource field, a battle transformation sequence, and linked Cinderhide → Clinkerhide → Ironvent resources. River Listener has no resource links yet. A proposed Tide/Hollow final form also needs secondary-essence support before it can be represented in `CreatureData`.
- The six starter lines each have three stages under the current concept. Develop this nonstarter line alongside that roster goal without treating its proposed stage names as locked canon.
- The Stage I, II, and III briefs are in `docs/creatures/creature-roster-draft.md`. Hollowtide Sprite Forge has an optional Previous Stage Sprite image input. For Stage II and III, attach only the immediately previous approved form; the current Forge v4 image-continuity path still needs output review.
