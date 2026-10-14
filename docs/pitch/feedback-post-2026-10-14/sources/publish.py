from pathlib import Path
import hashlib,json,shutil,sys,re
W=Path(__file__).parent;R=Path('C:/Users/pmcga/dev/hollowtide');D=W/'delivery';F=R/'docs/pitch/feedback-post-2026-10-14';B=json.loads((W/'protected.json').read_text(encoding='utf-8'))
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return h.hexdigest()
def write(p,t):
    p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(t.replace('\r\n','\n').replace('\n','\r\n').encode('utf-8'))
def protect():
    changes=[rel for rel,h in B.items() if not (R/rel).is_file() or sha(R/rel)!=h];assert not changes,changes;return len(B)
mode=sys.argv[1]
if mode=='install':
    count=protect();assert not F.exists()
    clips=json.loads((D/'clips.json').read_text(encoding='utf-8'));assert all(c['review']=='passed' for c in clips['clips'])
    shutil.copytree(D,F);write(F/'.gdignore','');(F/'sources').mkdir()
    for name in ['build.py','publish.py','serve.py','protected.json']:shutil.copy2(W/name,F/'sources'/name)
    (F/'preservation.json').write_text(json.dumps({'protected_files':count,'unchanged':count,'unexpected_changes':[],'scope':'existing game scripts/scenes/data/dialogue, trailer tools, V3, full V4, Storage-only media and four October12 GIFs','new_generation':False,'external_posting':False},indent=2),encoding='utf-8')
    print('Installed five clips, gallery and exact-source receipts;',count,'protected files exact.')
elif mode=='docs':
    ui=json.loads((F/'browser-check.json').read_text());assert ui['status']=='passed'
    count=protect();clips=json.loads((F/'clips.json').read_text())['clips'];assert len(clips)==5
    rows='\n'.join(f"| [{c['title']}]({c['id']}.gif) | {c['gif_seconds']:.2f}s | {c['frames']} | {c['gif_bytes']/1000000:.2f}MB | [{c['mp4_bytes']/1000000:.2f}MB MP4]({c['id']}.mp4) |" for c in clips)
    summary=f'Current feedback media COMPLETE: five fresh GIFs from the checked October14 V4 raw take, plus silent MP4 alternatives and a local play/pause/download gallery at docs/pitch/feedback-post-2026-10-14/index.html. Four current subjects replace old feedback attachments (mail, painted water, defeat, Warden); fifth shows the installed Storage interior and one-berry deposit/withdraw. All768x432/15fps; mail98 frames/6.54s GIF, other four120 frames/8.00s; every GIF below8MiB. All frames decoded, five MP4s decoded end-to-end, source ranges checked and contact sheets reviewed. Gallery checked in browser for playback/pause/download links and narrow layout. Updated feedback draft has source-accurate AI disclosure and links the99.7s V4 pitch. All{count} protected game/source/V3/V4/Storage-shot/old-GIF files exact. No new native run, generation, paid call, export, posting or commit. Original October14 queue and both game integrations remain complete.'
    readme=f'''# Current feedback clips, October 14, 2026

[Open the local preview](index.html) · [Updated post draft](../feedback-post-2026-10-14.md) · [Full V4 pitch](../../trailer/v4/full/hollowtide_pitch_v4_share.mp4)

Five new silent clips from the actual [V4 raw recording](../../trailer/v4/full/raw.avi), with current art and indoor Storage. The earlier four October12 GIFs and all V3/V4 media remain byte-exact. No upload or external post.

| GIF | Measured duration | Frames | GIF size | Smaller video |
|---|---|---|---|---|
{rows}

All are768x432 at15fps, an exact2x of the384x216 game grid. GIF delays are quantized to centiseconds:98 frames measure6.54s rather than the MP4's6.533333s. GIFs loop; MP4s have no audio and support play/pause/seeking in the gallery. There is no automatic playback. The originals' engine sound and the full pitch mix remain available in V4.

## Source and preparation

Each clip is one contiguous excerpt at its original speed, with no composited/generated frames, captions burned into the game, or new model output. [clips.json](clips.json) records exact30fps source frame bounds, hashes, measured media facts and review status. [commands.json](commands.json) records FFmpeg GIF palette/dither, MP4, probe and full decode commands. Frames were reduced to15fps and nearest-resized to768x432; GIF's256-colour palette/dithering is a lossy presentation copy. Source AVI is unchanged. Poster stills and four-frame review sheets are beside each clip.

Mail call shows routes and crew portraits. Water shows two shoreline heights with the party clear of the HUD. Defeat shows the partner reaction and information panel; this short excerpt ends before the return-to-town input. Stand-off shows Starward and the Warden, without revealing the later stone outcome. Storage shows the room/counter and bag/kept Reedberry counts2/0→1/1→2/0. The same staged private-state V4 capture passed26/26 native checks; this task did not rerun Godot or claim an uninterrupted playthrough.

These are **recorded game rendering with AI-assisted Python/Pillow/FFmpeg preparation**, not generative video. The visible creature/scenery art and stored narrative retain their [AI inventory classifications](../ai-asset-inventory.md). Storage's shell/props derive from existing built-in imagegen outputs; creature portraits/animations include Retro Diffusion and earlier generated sources. No music/sound is included in these silent files. Exact model versions remain unknown where the inventory says so. The updated post draft avoids the earlier unverified claim of human hand editing and names Suno for the linked full pitch.

## Verification and preservation

All578 GIF frames decode through Pillow; GIF dimensions, loop flag, total delays and per-file8MiB preparation budget checked. Each MP4's H.264/15fps/frame count/duration checked by ffprobe and decoded end-to-end without errors. Native rendered content was reviewed in the four-frame sheets for all five clips. [Browser check](browser-check.json) and desktop/narrow screenshots record loaded videos, play/pause, pause-all and local download targets. [Preservation receipt](preservation.json): all{count} existing protected files exact, including game code, trailer tools, full V4, Storage-only media and original four feedback GIFs. Pre-edit Markdown bytes and drivers are in `sources/`.

## Reproduce

Copy `sources/build.py` into a fresh D-work directory and run with the bundled Python/Pillow plus FFmpeg/ffprobe. It reads the current repo's `docs/trailer/v4/full/raw.avi` and measured markers, creates `delivery/`, records protected input hashes and refuses existing clip outputs. Preserve this delivery; use a fresh directory. Current source raw SHA256 is in `clips.json`; compare it before using different marker files. The original run was `python D:/dev/hollowtide-feedback-v4-20261014/build.py`. The exact recorded FFmpeg commands retain the D-work output paths as evidence.

Community rules and export/template availability were not re-researched. The old October12 community survey remains dated history; this pack and draft do not claim platform permission or a playable export. Nothing was posted or messaged.
'''
    # 98+4*120=578 decoded GIF frames.
    assert sum(c['frames'] for c in clips)==578
    draft='''# Feedback post draft, October 14, 2026

Local review copy for Preston. [Preview all five clips](feedback-post-2026-10-14/index.html); [sources, sizes and individual downloads](feedback-post-2026-10-14/README.md). The full video is the [99.7-second V4 share MP4](../trailer/v4/full/hollowtide_pitch_v4_share.mp4). This supersedes the old draft's media attachments and AI paragraph; no post has been sent. Choose the attachments that fit wherever you post and check that community's current rules first. The October12 survey was not revalidated here.

## Proposed title

Hollowtide: a courier-guild dungeon crawl on a flooded river. Does the loop read?

## Proposed body

I'm making Hollowtide, a turn-based dungeon crawl where you wake up as a creature, join a courier guild and carry the mail through river ruins. Explorers of Sky is an influence.

These short clips show the guild handing out mail routes, water rising through a dungeon floor, the partner's reaction when the leader goes down, a stand-off with the Warden, and the new Storage room where supplies can be kept between runs. They were staged and recorded in the actual game, then cut for this preview.

From the clips alone:

- Do you understand what you'd do in the game?
- Does carrying the mail feel like a reason to enter the dungeons?
- Which moment would you want to play, and what would stop you trying it?

AI disclosure: the prototype uses AI-generated creature and environment art, animation, portraits and narrative drafts. Retro Diffusion, earlier Opal workflows and built-in image-generation tools are among the recorded sources. The linked full pitch also includes generated music and sound from Suno and ElevenLabs. Claude and Codex helped write code and prepare/edit the assets under my direction; that preparation is not a claim of human-drawn art. These clips are recordings of prepared assets and stored dialogue, with no live generative service in the reviewed gameplay. The clips themselves contain no audio. [Detailed asset inventory](ai-asset-inventory.md).

## Attachment order

1. [Mail call GIF](feedback-post-2026-10-14/mail_call.gif)
2. [Rising water GIF](feedback-post-2026-10-14/water_rises.gif)
3. [Carried home GIF](feedback-post-2026-10-14/carried_home.gif)
4. [Stand-off GIF](feedback-post-2026-10-14/standoff.gif)
5. [Storage GIF](feedback-post-2026-10-14/storage.gif)

Smaller silent MP4 versions are on the preview page. The clips demonstrate selected moments; they are not evidence of outside playtests or a downloadable build.
'''
    updates={}
    for rel in ['docs/team/CODEX_START_HERE_2026-10-14.md','docs/team/CODEX_TASKS_2026-10-14.md','docs/AI_COLLABORATION.md','docs/pitch/ai-asset-inventory.md','docs/pitch/pitch-kit.md','docs/pitch/feedback-post-2026-10-12.md']:
        p=R/rel;backup=F/'sources'/'before-docs'/rel;backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,backup);t=p.read_text(encoding='utf-8')
        if 'START_HERE' in rel:t=t.replace('## Current status\n\n','## Current status\n\n'+summary+'\n\n',1)
        elif 'CODEX_TASKS' in rel:t+='\n\nCodex, October14: '+summary+'\n'
        elif 'AI_COLLABORATION' in rel:
            i=t.index('\n')+1;t=t[:i]+'\n## Codex: current feedback clips and preview (October14,2026)\n\n'+summary+'\n'+t[i:]
        elif 'ai-asset-inventory' in rel:
            needle='\nThese October 12 recordings predate';assert needle in t
            row='| **Five current feedback clips**, October14 | [Local gallery](feedback-post-2026-10-14/index.html), [source/command/verification record](feedback-post-2026-10-14/README.md): mail, painted water, defeat, Warden and indoor Storage; all768x432/15fps. Mail98-frame GIF measures6.54s; four120-frame GIFs measure8.00s. Silent H.264 MP4 alternatives preserve the same ranges (mail6.533333s). Contiguous real engine excerpts from the checked V4 raw take, with AI-assisted Python/Pillow/FFmpeg resizing, frame reduction and GIF palette/dithering; **no generative video or new model output**. Generated visible art/narrative keep their classifications above. Each GIF below8MiB; all578 frames decoded, five MP4 streams decoded and gallery checked in browser. Original four October12 GIFs and V3/V4 outputs exact. [Current draft/disclosure](feedback-post-2026-10-14.md); no posting authorized or performed by this task. |\n'
            t=t.replace(needle,row+needle,1)
        elif 'pitch-kit' in rel:
            old='`docs/pitch/feedback-post-2026-10-12.md` (you post; read each sidebar first).';assert old in t
            t=t.replace(old,'[current draft and five current clips](feedback-post-2026-10-14.md) (you post; check current rules first).\n   The October12 survey/draft remains preserved as history; this media refresh did not revalidate community rules.',1)
        else:
            first=t.index('\n')+1;t=t[:first]+'\n**October14 media update:** use the [current five-clip pack and revised disclosure](feedback-post-2026-10-14.md) with the V4 video. The October12 copy and community survey below are historical; claims of human hand editing are superseded by the current asset inventory. No post has been sent.\n'+t[first:]
        updates[rel]=t
    for rel in updates:assert sha(R/rel)==sha(F/'sources'/'before-docs'/rel),rel
    assert not (R/'docs/pitch/feedback-post-2026-10-14.md').exists()
    for rel,t in updates.items():write(R/rel,t)
    write(F/'README.md',readme);write(R/'docs/pitch/feedback-post-2026-10-14.md',draft)
    write(R/'docs/team/CODEX_HANDOFF_2026-10-14_feedback_clips.md','# Current feedback clips handoff, October14,2026\n\n'+summary+'\n\n[Preview](../pitch/feedback-post-2026-10-14/index.html) · [Draft](../pitch/feedback-post-2026-10-14.md) · [Evidence](../pitch/feedback-post-2026-10-14/README.md). All assigned queue work remains complete. No posting or new game features are implied. Preserve Claude\'s creature proposals and training workspace.\n')
    checked=[];broken=[]
    for p in [F/'README.md',R/'docs/pitch/feedback-post-2026-10-14.md',R/'docs/team/CODEX_HANDOFF_2026-10-14_feedback_clips.md',R/'docs/pitch/ai-asset-inventory.md',R/'docs/pitch/pitch-kit.md']:
        for dest in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
            if dest.startswith(('http:','https:','#')):continue
            target=(p.parent/dest.split('#')[0]).resolve();checked.append(str(target))
            if not target.exists():broken.append((str(p),dest))
    assert not broken,broken
    for c in clips:
        for ext in ['gif','mp4']:assert sha(F/(c['id']+'.'+ext))==c[ext+'_sha256']
    (F/'final-check.json').write_text(json.dumps({'local_links_resolved':len(checked),'protected_files_exact':count,'five_gifs_and_mp4_hashes':'passed','browser':ui,'documents_updated':list(updates),'new_draft':'docs/pitch/feedback-post-2026-10-14.md'},indent=2),encoding='utf-8')
    print('COMPLETE;',len(checked),'links resolve;',count,'protected files exact.')
else:raise ValueError(mode)
