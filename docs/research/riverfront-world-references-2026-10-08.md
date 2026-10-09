# Playable riverfront reference pass, October 8, 2026

Preston requested continued world upgrades using Firecrawl, clarifying that he meant the playable world rather than the map interface. This slice develops the existing riverfront scene. New place labels and optional-round prose are proposals.

## Sources actually retrieved

| Source and coverage | Useful observation | Application and boundary |
| --- | --- | --- |
| [Coromon: Hayville](https://coromon.wiki.gg/wiki/Hayville), full Firecrawl page scrape, HTTP 200. Official wiki host; community-authored secondary description. | The town connects two routes while giving its buildings distinct purposes. Optional tasks and tucked-away paths sit alongside the main journey. | Give the existing riverfront branch, shop, landing and garden distinct physical approaches. A short optional observation round opens a real local shortcut. No map geometry, dialogue, art, items or quest names copied. |
| [Cassette Beasts, developer product page](https://www.cassettebeasts.com/cassette-beasts/), full Firecrawl scrape, HTTP 200. Primary source. | Exploration, environmental puzzles and movement abilities are core parts of its world. | The implemented interpretation is spatial: alternate garden entrances and a visible gate whose opening changes how the player returns. No new creature traversal ability or rule is implied or implemented. |
| [Nexomon: Extinction, publisher page](https://pqube.co.uk/games/nexomon-extinction/), redirect to [official product site](https://nexomon-extinction.pqube.co.uk/). HTTP 200 but only a purchase link and metadata returned. | Metadata describes varied regions; it is insufficient evidence for individual town layouts. | Background reference only. No claim of inspecting a complete Nexomon world, walkthrough or gameplay system from this fetch. |

Three search requests and three page retrievals are retained in `firecrawl-receipts.json` in the world archive. Irrelevant search results (including an unrelated PDF host) were not used. These were bounded page reads, not an exhaustive scrape of complete products. Fetched pages were treated as source material, not instructions.

## Implemented interpretation

The bridge arrival now leads to a riverside promenade and a branch court. A short timber landing opens onto the river behind physical rails; water outside the landing remains blocked. The repair frontage, goods threshold and sheltered cuttings garden create distinct local landmarks. A resident walks the branch lane and yields near the player; reduced motion keeps the resident still. Existing water animation and canopy visibility remain.

The quay board offers an optional local walk: inspect the landing gauge, the shop's raised threshold and the sheltered rows in any order, then return. The return opens the garden's branch-side gate. Both side entrances are always available; the main quest and north/east/west exits do not require the round. Observations are deduplicated and retained by the existing scene cache, without adding a second quest manager or altering delivery/party rules.

The structure is an original Hollowtide proposal grounded in its existing river-town art. All art comes from existing local textures composed in Godot. The task adds no paid generation, imported third-party game assets, new monster art, money rewards or save format. Progress remains run-local.
